//===-- SISoftClauseBundler.cpp - Fix CF live intervals ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// \file Place sequences of adjacent VMEM instructions in a bundle to prevent
/// any later passes breaking apart the soft clause. Add implicit uses of
/// pointer operands to later instructions in the bundle. We want to prevent
/// register allocation from re-using the pointer registers in case the loads
/// and stores need to restart in a soft clause, otherwise no-ops would need to
/// be inserted.
///
//===----------------------------------------------------------------------===//

#include "AMDGPU.h"
#include "SIInstrInfo.h"

#include "llvm/ADT/DenseSet.h"

#include "llvm/CodeGen/LiveIntervalAnalysis.h"

#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

using namespace llvm;

#define DEBUG_TYPE "si-bundle-soft-clauses"

namespace {

class SISoftClauseBundler : public MachineFunctionPass {
public:
  static char ID;

public:
  SISoftClauseBundler() : MachineFunctionPass(ID) {
    initializeSISoftClauseBundlerPass(*PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  const char *getPassName() const override {
    return "SI Bundle Soft Clauses";
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<LiveIntervals>();
    AU.setPreservesAll();
    MachineFunctionPass::getAnalysisUsage(AU);
  }
};

} // End anonymous namespace.

INITIALIZE_PASS_BEGIN(SISoftClauseBundler, DEBUG_TYPE,
                      "SI Bundle Soft Clauses", false, false)
INITIALIZE_PASS_DEPENDENCY(LiveIntervals)
INITIALIZE_PASS_END(SISoftClauseBundler, DEBUG_TYPE,
                    "SI Bundle Soft Clauses", false, false)

char SISoftClauseBundler::ID = 0;

char &llvm::SISoftClauseBundlerID = SISoftClauseBundler::ID;

static MachineOperand &getPointerReg(const SIInstrInfo *TII,
                                     MachineInstr &MI) {
  int OpIdx = -1;

  if (TII->isMUBUF(MI) || TII->isMTBUF(MI)) {
    OpIdx = AMDGPU::getNamedOperandIdx(MI.getOpcode(), AMDGPU::OpName::vaddr);
  } else if (TII->isFLAT(MI)) {
    OpIdx = AMDGPU::getNamedOperandIdx(MI.getOpcode(), AMDGPU::OpName::addr);
  } else if (TII->isSMRD(MI)) {
    OpIdx = AMDGPU::getNamedOperandIdx(MI.getOpcode(), AMDGPU::OpName::sbase);
  }

  assert(OpIdx != -1 && "Couldn't find pointer operand");
  return MI.getOperand(OpIdx);
}

bool SISoftClauseBundler::runOnMachineFunction(MachineFunction &MF) {
  const AMDGPUSubtarget &ST = MF.getSubtarget<AMDGPUSubtarget>();

  // We only worry about this on VI because loads and stores can return out of
  // order.
  if (ST.getGeneration() < AMDGPUSubtarget::VOLCANIC_ISLANDS)
    return false;

  const SIInstrInfo *TII = static_cast<const SIInstrInfo *>(ST.getInstrInfo());
  LiveIntervals *LIS = &getAnalysis<LiveIntervals>();


  for (MachineBasicBlock &MBB : MF) {
    MachineBasicBlock::iterator I, Next;
    for (I = MBB.begin(); I != MBB.end(); I = Next) {
      Next = std::next(I);

      MachineInstr &MI = *I;
      MachineInstr *Bundle;

      if (TII->formsSoftClause(MI)) {
        // Track all pointer operands up to this point used in the soft clause.
        SmallSet<TargetInstrInfo::RegSubRegPair, 4> PtrRegsSet;
        SmallVector<TargetInstrInfo::RegSubRegPair, 4> PtrRegs;
        SmallVector<bool, 4> PtrRegKill;

        MachineInstr *LastInst = Next;
        if (TII->formsSoftClause(*Next)) {

          MachineOperand &PtrOp = getPointerReg(TII, MI);
          PtrOp.setIsKill(false);

          TargetInstrInfo::RegSubRegPair Reg(PtrOp.getReg(), PtrOp.getSubReg());

          PtrRegsSet.insert(Reg);
          PtrRegs.push_back(Reg);
          PtrRegKill.push_back(PtrOp.isKill());

          Bundle = &MI;


          LIS->handleMoveIntoBundle(&*Next, Bundle);
          LIS->RemoveMachineInstrFromMaps(Next);
          Next->bundleWithPred();


          ++Next;
        }


        while (TII->formsSoftClause(*Next)) {
          MachineOperand &PtrOp = getPointerReg(TII, MI);
          TargetInstrInfo::RegSubRegPair Reg(PtrOp.getReg(), PtrOp.getSubReg());

          PtrOp.setIsKill(false);
          if (PtrRegsSet.insert(Reg).second) {
            PtrRegs.push_back(Reg);
            PtrRegKill.push_back(PtrOp.isKill());
          }

#if 1
          for (TargetInstrInfo::RegSubRegPair Ptr : PtrRegs) {
            MachineOperand NewOp
              = MachineOperand::CreateReg(Ptr.Reg, false, true, false,
                                          false, false, false, Ptr.SubReg);
            Next->addOperand(NewOp);
          }
#endif

          LastInst = Next;

          LIS->handleMoveIntoBundle(Next, Bundle);
          LIS->RemoveMachineInstrFromMaps(Next);
          Next->bundleWithPred();

          ++Next;
        }


      }



    }

  }

  return true;
}
