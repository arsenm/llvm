//===-- SIRewriteVirtRegs.cpp ---------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// This pass reclaims registers reserved for scratch memory access after
/// register allocation once it is known that there are no spills or other
/// reasons to use scratch memory. All assigned physical SGPRs are shifted down
/// to the low numbers. Since 5 SGPRs are required for scratch access and the
/// SGPR allocation granularity is 8 this saves an entire tier of register usage
/// in the common case of having no stack usage.
//
//===----------------------------------------------------------------------===//

#include "AMDGPU.h"
#include "SIMachineFunctionInfo.h"
#include "SIRegisterInfo.h"

#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/VirtRegMap.h"

#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "si-rewrite-virt-regs"

using namespace llvm;

namespace {

class SIRewriteVirtRegs : public MachineFunctionPass {
public:
  static char ID;

  SIRewriteVirtRegs() : MachineFunctionPass(ID) {}

  const char *getPassName() const override {
    return "SI Reassign Virtual Registers";
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesAll();
    AU.addRequired<VirtRegMap>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  bool runOnMachineFunction(MachineFunction &MF) override;
};

}

char SIRewriteVirtRegs::ID = 0;
char &llvm::SIRewriteVirtRegsID = SIRewriteVirtRegs::ID;

INITIALIZE_PASS_BEGIN(SIRewriteVirtRegs, DEBUG_TYPE,
                      "SI Reassign Virtual Registers", false, false)
INITIALIZE_PASS_DEPENDENCY(VirtRegMap)
INITIALIZE_PASS_END(SIRewriteVirtRegs, DEBUG_TYPE,
                    "SI Reassign Virtual Registers", false, false)

bool SIRewriteVirtRegs::runOnMachineFunction(MachineFunction &MF) {
  // If we have stack objects, we really do need the reserved registers.
  if (MF.getFrameInfo()->hasStackObjects())
    return false;

  const AMDGPUSubtarget &STM
    = static_cast<const AMDGPUSubtarget &>(MF.getSubtarget());

  MachineRegisterInfo &MRI = MF.getRegInfo();
  const SIRegisterInfo *TRI
    = static_cast<const SIRegisterInfo *>(STM.getRegisterInfo());

  VirtRegMap &VRM = getAnalysis<VirtRegMap>();

  SIMachineFunctionInfo *MFI = MF.getInfo<SIMachineFunctionInfo>();


  unsigned ScratchRSrcReg = MFI->getScratchRSrcReg();
  unsigned ScratchOffsetReg
    = TRI->getPreloadedValue(MF, SIRegisterInfo::SCRATCH_WAVE_OFFSET);

  const BitVector &Reserved = MRI.getReservedRegs();

  // We usually have a situation that looks like:
  //
  // 0 1 2 3 . . . . . 9 . . . . . . . . . . .
  // _______           _
  //
  // We want to reclaim s[0:3] and s9



  for (unsigned I = 0, E = MRI.getNumVirtRegs(); I != E; ++I) {
    unsigned VReg = TargetRegisterInfo::index2VirtReg(I);
    const TargetRegisterClass *RC = MRI.getRegClass(VReg);
    if (!TRI->isSGPRClass(RC))
      continue;

    assert(VRM.isAssignedReg(VReg));

    unsigned PhysReg = VRM.getPhys(VReg);

    // XXX - Not sure why this happens.
    if (PhysReg == AMDGPU::NoRegister)
      continue;

    switch (PhysReg) {
    case AMDGPU::VCC:
    case AMDGPU::VCC_LO:
    case AMDGPU::VCC_HI:
    case AMDGPU::FLAT_SCR:
    case AMDGPU::FLAT_SCR_LO:
    case AMDGPU::FLAT_SCR_HI:
    case AMDGPU::M0:
      continue;
    default:
      break;
    }

//    BitVector AssignedPhysRegs;

    unsigned BasePhysReg = TRI->getSubReg(PhysReg, AMDGPU::sub0);
    if (BasePhysReg == AMDGPU::NoRegister)
      BasePhysReg = PhysReg;

    if (MRI.isReserved(PhysReg)) {

    }

    DEBUG(dbgs()
          << "Changing SGPR mapping from "
          << PrintReg(VReg, TRI)
          << " => "
          << PrintReg(PhysReg, TRI)
          << " base " << PrintReg(BasePhysReg, TRI)
          << " => " << '\n');

    DEBUG(dbgs() << "  RegUnits:\n");

    for (MCRegUnitIterator RegUnits(PhysReg, TRI);
         RegUnits.isValid(); ++RegUnits) {
      DEBUG(dbgs() << "    " << PrintRegUnit(*RegUnits, TRI) << '\n');
    }



  }

  return true;
}
