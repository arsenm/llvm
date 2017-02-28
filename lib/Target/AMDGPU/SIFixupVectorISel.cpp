//===-- SIFixupVectorISel.cpp ---------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Apply simple patterns that should be done in the DAG, but require knowing if
// we have a vector source or not.
//
//===----------------------------------------------------------------------===//

#include "AMDGPU.h"
#include "AMDGPUSubtarget.h"
#include "SIInstrInfo.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"

using namespace llvm;

#define DEBUG_TYPE "si-fixup-vector-isel"

namespace {

class SIFixupVectorISel : public MachineFunctionPass {
public:
  static char ID;

  SIFixupVectorISel() : MachineFunctionPass(ID) { }

  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override {
    return "SI Fixup Vector ISel";
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }
};

} // End anonymous namespace

INITIALIZE_PASS_BEGIN(SIFixupVectorISel, DEBUG_TYPE,
                     "SI Fixup Vector ISel", false, false)
INITIALIZE_PASS_END(SIFixupVectorISel, DEBUG_TYPE,
                     "SI Fixup Vector ISel", false, false)


char SIFixupVectorISel::ID = 0;

char &llvm::SIFixupVectorISelID = SIFixupVectorISel::ID;

static bool isVALUShl16(const MachineRegisterInfo &MRI,
                        MachineInstr &MI, MachineOperand *&Op) {
  unsigned Opc = MI.getOpcode();
  if (Opc != AMDGPU::V_LSHLREV_B32_e64 &&
      Opc != AMDGPU::V_LSHLREV_B32_e32 &&
      Opc != AMDGPU::V_LSHL_B32_e64 &&
      Opc != AMDGPU::V_LSHL_B32_e32)
    return false;

  MachineOperand *LHS = &MI.getOperand(1);
  MachineOperand *RHS = &MI.getOperand(2);

  if (Opc == AMDGPU::V_LSHLREV_B32_e64 || Opc == AMDGPU::V_LSHLREV_B32_e32)
    std::swap(LHS, RHS);

  uint64_t ShiftAmt;
  if (SIInstrInfo::isImmOrMaterializedImm(MRI, *RHS, ShiftAmt) &&
      ShiftAmt == 16) {
    Op = LHS;
    return true;
  }

  if (SIInstrInfo::isImmOrMaterializedImm(MRI, *LHS, ShiftAmt) &&
      ShiftAmt == 16) {
    Op = RHS;
    return true;
  }

  return false;
}

bool SIFixupVectorISel::runOnMachineFunction(MachineFunction &MF) {
  const SISubtarget &ST = MF.getSubtarget<SISubtarget>();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  const SIInstrInfo *TII = ST.getInstrInfo();

  for (MachineBasicBlock &MBB : MF) {
    for (MachineBasicBlock::iterator I = MBB.begin(), E = MBB.end();
         I != E; ) {
      MachineInstr &MI = *I;
      ++I;

      switch (MI.getOpcode()) {
      case AMDGPU::V_OR_B32_e64: {
        // TODO: This is useful in some situations even with SDWA, but many
        // tests need updates and the logic probably needs merging with the SDWA
        // pass.
        if (ST.hasSDWA())
          break;

        MachineOperand &RHS = MI.getOperand(2);
        if (!RHS.isReg())
          break;

        MachineOperand &LHS = MI.getOperand(1);
        MachineInstr *Def = MRI.getVRegDef(RHS.getReg());

        MachineOperand *Op;
        if (isVALUShl16(MRI, *Def, Op)) {
          uint64_t KnownZero = 0, KnownOne = 0;
          TII->computeKnownBits(MRI, LHS, KnownZero, KnownOne);

          bool LHSKnownHighZero = (KnownZero & 0xffff0000) == 0xffff0000;

          const DebugLoc &DL = MI.getDebugLoc();
          if (LHSKnownHighZero) {
            BuildMI(MBB, &MI, DL, TII->get(AMDGPU::V_CVT_PK_U16_U32_e64),
                    MI.getOperand(0).getReg())
              .add(LHS)
              .add(*Op);
            MI.eraseFromParent();
            MRI.clearKillFlags(Op->getReg());
            continue;
          }
        }


      }
      default:
        break;
      }

    }
  }

  return true;
}
