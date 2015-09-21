//===-- SIFixSGPRCopies.cpp - Remove potential VGPR => SGPR copies --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// \file
/// Copies from VGPR to SGPR registers are illegal and the register coalescer
/// will sometimes generate these illegal copies in situations like this:
///
///  Register Class <vsrc> is the union of <vgpr> and <sgpr>
///
/// BB0:
///   %vreg0 <sgpr> = SCALAR_INST
///   %vreg1 <vsrc> = COPY %vreg0 <sgpr>
///    ...
///    BRANCH %cond BB1, BB2
///  BB1:
///    %vreg2 <vgpr> = VECTOR_INST
///    %vreg3 <vsrc> = COPY %vreg2 <vgpr>
///  BB2:
///    %vreg4 <vsrc> = PHI %vreg1 <vsrc>, <BB#0>, %vreg3 <vrsc>, <BB#1>
///    %vreg5 <vgpr> = VECTOR_INST %vreg4 <vsrc>
///
///
/// The coalescer will begin at BB0 and eliminate its copy, then the resulting
/// code will look like this:
///
/// BB0:
///   %vreg0 <sgpr> = SCALAR_INST
///    ...
///    BRANCH %cond BB1, BB2
/// BB1:
///   %vreg2 <vgpr> = VECTOR_INST
///   %vreg3 <vsrc> = COPY %vreg2 <vgpr>
/// BB2:
///   %vreg4 <sgpr> = PHI %vreg0 <sgpr>, <BB#0>, %vreg3 <vsrc>, <BB#1>
///   %vreg5 <vgpr> = VECTOR_INST %vreg4 <sgpr>
///
/// Now that the result of the PHI instruction is an SGPR, the register
/// allocator is now forced to constrain the register class of %vreg3 to
/// <sgpr> so we end up with final code like this:
///
/// BB0:
///   %vreg0 <sgpr> = SCALAR_INST
///    ...
///    BRANCH %cond BB1, BB2
/// BB1:
///   %vreg2 <vgpr> = VECTOR_INST
///   %vreg3 <sgpr> = COPY %vreg2 <vgpr>
/// BB2:
///   %vreg4 <sgpr> = PHI %vreg0 <sgpr>, <BB#0>, %vreg3 <sgpr>, <BB#1>
///   %vreg5 <vgpr> = VECTOR_INST %vreg4 <sgpr>
///
/// Now this code contains an illegal copy from a VGPR to an SGPR.
///
/// In order to avoid this problem, this pass searches for PHI instructions
/// which define a <vsrc> register and constrains its definition class to
/// <vgpr> if the user of the PHI's definition register is a vector instruction.
/// If the PHI's definition class is constrained to <vgpr> then the coalescer
/// will be unable to perform the COPY removal from the above example  which
/// ultimately led to the creation of an illegal COPY.
//===----------------------------------------------------------------------===//

#include "AMDGPU.h"
#include "AMDGPUSubtarget.h"
#include "SIInstrInfo.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"

using namespace llvm;

#define DEBUG_TYPE "sgpr-copies"

namespace {

class SIFixSGPRCopies : public MachineFunctionPass {
private:
  static char ID;
  const TargetRegisterClass *inferRegClassFromUses(const SIRegisterInfo *TRI,
                                           const MachineRegisterInfo &MRI,
                                           unsigned Reg,
                                           unsigned SubReg) const;
  const TargetRegisterClass *inferRegClassFromDef(const SIRegisterInfo *TRI,
                                                 const MachineRegisterInfo &MRI,
                                                 unsigned Reg,
                                                 unsigned SubReg) const;

  void addUsersToMoveSet(MachineInstr &MI,
                         const SIInstrInfo *TII,
                         MachineRegisterInfo &MRI,
                         DenseSet<MachineInstr *> &Visited) const;

  bool isVGPRToSGPRCopy(const MachineInstr &Copy, const SIRegisterInfo *TRI,
                        const MachineRegisterInfo &MRI) const;

public:
  SIFixSGPRCopies(TargetMachine &tm) : MachineFunctionPass(ID) { }

  bool runOnMachineFunction(MachineFunction &MF) override;

  const char *getPassName() const override {
    return "SI Fix SGPR copies";
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<MachineDominatorTree>();
    AU.addPreserved<MachineDominatorTree>();
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }
};

} // End anonymous namespace

char SIFixSGPRCopies::ID = 0;

FunctionPass *llvm::createSIFixSGPRCopiesPass(TargetMachine &tm) {
  return new SIFixSGPRCopies(tm);
}

static bool hasVGPROperands(const MachineInstr &MI, const SIRegisterInfo *TRI) {
  const MachineRegisterInfo &MRI = MI.getParent()->getParent()->getRegInfo();
  for (unsigned i = 0, e = MI.getNumOperands(); i != e; ++i) {
    if (!MI.getOperand(i).isReg() ||
        !TargetRegisterInfo::isVirtualRegister(MI.getOperand(i).getReg()))
      continue;

    if (TRI->hasVGPRs(MRI.getRegClass(MI.getOperand(i).getReg())))
      return true;
  }
  return false;
}

/// This functions walks the use list of Reg until it finds an Instruction
/// that isn't a COPY returns the register class of that instruction.
/// \return The register defined by the first non-COPY instruction.
const TargetRegisterClass *SIFixSGPRCopies::inferRegClassFromUses(
                                                 const SIRegisterInfo *TRI,
                                                 const MachineRegisterInfo &MRI,
                                                 unsigned Reg,
                                                 unsigned SubReg) const {

  const TargetRegisterClass *RC
    = TargetRegisterInfo::isVirtualRegister(Reg) ?
    MRI.getRegClass(Reg) :
    TRI->getPhysRegClass(Reg);

  RC = TRI->getSubRegClass(RC, SubReg);
  for (MachineRegisterInfo::use_instr_iterator
       I = MRI.use_instr_begin(Reg), E = MRI.use_instr_end(); I != E; ++I) {
    switch (I->getOpcode()) {
    case AMDGPU::COPY:
      RC = TRI->getCommonSubClass(RC, inferRegClassFromUses(TRI, MRI,
                                  I->getOperand(0).getReg(),
                                  I->getOperand(0).getSubReg()));
      break;
    }
  }

  return RC;
}

const TargetRegisterClass *SIFixSGPRCopies::inferRegClassFromDef(
                                                 const SIRegisterInfo *TRI,
                                                 const MachineRegisterInfo &MRI,
                                                 unsigned Reg,
                                                 unsigned SubReg) const {
  if (!TargetRegisterInfo::isVirtualRegister(Reg)) {
    const TargetRegisterClass *RC = TRI->getPhysRegClass(Reg);
    return TRI->getSubRegClass(RC, SubReg);
  }
  MachineInstr *Def = MRI.getVRegDef(Reg);
  if (Def->getOpcode() != AMDGPU::COPY) {
    return TRI->getSubRegClass(MRI.getRegClass(Reg), SubReg);
  }

  return inferRegClassFromDef(TRI, MRI, Def->getOperand(1).getReg(),
                                   Def->getOperand(1).getSubReg());
}

// Recursively add all user instructions to the set of instructions to move to
// the VALU.
void SIFixSGPRCopies::addUsersToMoveSet(
  MachineInstr &MI,
  const SIInstrInfo *TII,
  MachineRegisterInfo &MRI,
  DenseSet<MachineInstr *> &Visited) const {
  MachineOperand &Dst = MI.getOperand(0);

  if (!Dst.isDef())
    return;

  SmallVector<unsigned, 8> RegWorkList;
  RegWorkList.push_back(Dst.getReg());

  do {
    unsigned Reg = RegWorkList.pop_back_val();

    for (MachineRegisterInfo::use_iterator I = MRI.use_begin(Reg),
           E = MRI.use_end(); I != E; ++I) {
      MachineInstr &UseMI = *I->getParent();

      if (!TII->canReadVGPR(UseMI, I.getOperandNo())) {
        if (!Visited.insert(&UseMI).second)
          continue;

        MachineOperand &UseMIDef = UseMI.getOperand(0);
        if (UseMIDef.isReg() && UseMIDef.isDef())
          RegWorkList.push_back(UseMIDef.getReg());
      }
    }
  } while (!RegWorkList.empty());
}

bool SIFixSGPRCopies::isVGPRToSGPRCopy(const MachineInstr &Copy,
                                      const SIRegisterInfo *TRI,
                                      const MachineRegisterInfo &MRI) const {

  unsigned DstReg = Copy.getOperand(0).getReg();
  unsigned SrcReg = Copy.getOperand(1).getReg();
  unsigned SrcSubReg = Copy.getOperand(1).getSubReg();

  if (!TargetRegisterInfo::isVirtualRegister(DstReg)) {
    // If the destination register is a physical register there isn't really
    // much we can do to fix this.
    return false;
  }

  const TargetRegisterClass *DstRC = MRI.getRegClass(DstReg);

  const TargetRegisterClass *SrcRC;

  if (!TargetRegisterInfo::isVirtualRegister(SrcReg) ||
      MRI.getRegClass(SrcReg) == &AMDGPU::VReg_1RegClass)
    return false;

  SrcRC = TRI->getSubRegClass(MRI.getRegClass(SrcReg), SrcSubReg);
  return TRI->isSGPRClass(DstRC) && TRI->hasVGPRs(SrcRC);
}

bool SIFixSGPRCopies::runOnMachineFunction(MachineFunction &MF) {
  MachineRegisterInfo &MRI = MF.getRegInfo();
  const SIRegisterInfo *TRI =
      static_cast<const SIRegisterInfo *>(MF.getSubtarget().getRegisterInfo());
  const SIInstrInfo *TII =
      static_cast<const SIInstrInfo *>(MF.getSubtarget().getInstrInfo());

  MachineDominatorTree *MDT = &getAnalysis<MachineDominatorTree>();

  SmallVector<MachineBasicBlock *, 32> BBWorkList;
  SmallVector<MachineDomTreeNode *, 32> NodeWorkList;

  NodeWorkList.push_back(MDT->getRootNode());

  // Use the DominatorTree to figure out the order we should visit blocks.
  do {
    MachineDomTreeNode *Node = NodeWorkList.pop_back_val();
    BBWorkList.push_back(Node->getBlock());

    ArrayRef<MachineDomTreeNode *> Children = Node->getChildren();
    NodeWorkList.append(Children.begin(), Children.end());
  } while (!NodeWorkList.empty());


  DenseSet<MachineInstr *> Visited;

  // First, find the set of instructions which we need to move to the
  // VALU. Start at illegal copy sources and recursively collect users. Do this
  // in depth first order so we visit defs before users.
  //
  // We must order the instructions as a second iteration over the function in
  // case we discover we need to move a phi after its input operands may be
  // moved.
  for (MachineBasicBlock *MBB : BBWorkList) {
    for (MachineInstr &MI : *MBB) {
      switch (MI.getOpcode()) {
      default:
        continue;
      case AMDGPU::COPY: {
        if (isVGPRToSGPRCopy(MI, TRI, MRI)) {
          MachineOperand &Dst = MI.getOperand(0);
          const TargetRegisterClass *RC =
            TRI->getEquivalentVGPRClass(MRI.getRegClass(Dst.getReg()));

          if (Visited.insert(&MI).second)
            addUsersToMoveSet(MI, TII, MRI, Visited);
        }

        break;
      }
      case AMDGPU::PHI: {
        MachineOperand &Dst = MI.getOperand(0);
        unsigned Reg = Dst.getReg();
        unsigned SubReg = Dst.getSubReg();

        // XXX - Why are any of these constrainRegClass necessary? No tests fail
        // if I remove them.
        for (unsigned i = 1; i < MI.getNumOperands(); i += 2) {
          const MachineOperand &Op = MI.getOperand(i);
          unsigned Reg = Op.getReg();
          const TargetRegisterClass *RC
            = inferRegClassFromDef(TRI, MRI, Reg, SubReg);

          MRI.constrainRegClass(Op.getReg(), RC);
        }

        const TargetRegisterClass *RC
          = inferRegClassFromUses(TRI, MRI, Reg, SubReg);
        if (TRI->getCommonSubClass(RC, &AMDGPU::VGPR_32RegClass)) {
          MRI.constrainRegClass(Reg, &AMDGPU::VGPR_32RegClass);
        }

        if (!TRI->isSGPRClass(MRI.getRegClass(Reg)))
          break;

        // If a PHI node defines an SGPR and any of its operands are VGPRs,
        // then we need to move it to the VALU.
        //
        // Also, if a PHI node defines an SGPR and has all SGPR operands
        // we must move it to the VALU, because the SGPR operands will
        // all end up being assigned the same register, which means
        // there is a potential for a conflict if different threads take
        // different control flow paths.
        //
        // For Example:
        //
        // sgpr0 = def;
        // ...
        // sgpr1 = def;
        // ...
        // sgpr2 = PHI sgpr0, sgpr1
        // use sgpr2;
        //
        // Will Become:
        //
        // sgpr2 = def;
        // ...
        // sgpr2 = def;
        // ...
        // use sgpr2
        //
        // FIXME: This is OK if the branching decision is made based on an
        // SGPR value.
        bool SGPRBranch = false;

        // The one exception to this rule is when one of the operands
        // is defined by a SI_BREAK, SI_IF_BREAK, or SI_ELSE_BREAK
        // instruction.  In this case, there we know the program will
        // never enter the second block (the loop) without entering
        // the first block (where the condition is computed), so there
        // is no chance for values to be over-written.

        bool HasBreakDef = false;
        for (unsigned i = 1, n = MI.getNumOperands(); i < n; i += 2) {
          unsigned Reg = MI.getOperand(i).getReg();
          if (TRI->hasVGPRs(MRI.getRegClass(Reg))) {
            if (Visited.insert(&MI).second)
              addUsersToMoveSet(MI, TII, MRI, Visited);
            break;
          }
          MachineInstr *DefInstr = MRI.getUniqueVRegDef(Reg);
          assert(DefInstr);
          switch(DefInstr->getOpcode()) {

          case AMDGPU::SI_BREAK:
          case AMDGPU::SI_IF_BREAK:
          case AMDGPU::SI_ELSE_BREAK:
          // If we see a PHI instruction that defines an SGPR, then that PHI
          // instruction has already been considered and should have
          // a *_BREAK as an operand.
          case AMDGPU::PHI:
            HasBreakDef = true;
            break;
          }
        }

        if (!SGPRBranch && !HasBreakDef) {
          if (Visited.insert(&MI).second)
            addUsersToMoveSet(MI, TII, MRI, Visited);
        }

        break;
      }
      case AMDGPU::REG_SEQUENCE: {
        if (TRI->hasVGPRs(TII->getOpRegClass(MI, 0)) ||
            !hasVGPROperands(MI, TRI))
          continue;

        if (Visited.insert(&MI).second)
          addUsersToMoveSet(MI, TII, MRI, Visited);
        break;
      }
      case AMDGPU::INSERT_SUBREG: {
        const TargetRegisterClass *DstRC, *Src0RC, *Src1RC;
        DstRC = MRI.getRegClass(MI.getOperand(0).getReg());
        Src0RC = MRI.getRegClass(MI.getOperand(1).getReg());
        Src1RC = MRI.getRegClass(MI.getOperand(2).getReg());
        if (TRI->isSGPRClass(DstRC) &&
            (TRI->hasVGPRs(Src0RC) || TRI->hasVGPRs(Src1RC))) {
          if (Visited.insert(&MI).second)
            addUsersToMoveSet(MI, TII, MRI, Visited);
        }
        break;
      }
      }
    }
  }

  // Do another depth first walk of the function to produce the worklist. We
  // need to ensure that all defs a use instruction that need to be moved are
  // moved before a use instruction, so we keep the worklist in program order.
  for (MachineBasicBlock *MBB : BBWorkList) {
    for (MachineBasicBlock::iterator I = MBB->begin(), E = MBB->end();
         I != E; ) {
      MachineInstr &MI = *I;
      ++I;

      if (Visited.count(&MI)) {
        DEBUG(dbgs() << "Moving instructions to VALU: " << MI);
        TII->moveToVALU(MI);
      }
    }
  }

  // It's highly unlikely this pass didn't make a change.
  return true;
}
