//===- AMDGPUMCInstLower.h MachineInstr Lowering Interface ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_AMDGPU_AMDGPUMCINSTLOWER_H
#define LLVM_LIB_TARGET_AMDGPU_AMDGPUMCINSTLOWER_H

namespace llvm {

class AMDGPUSubtarget;
class MachineBasicBlock;
class MachineInstr;
class MachineOperand;
class MCContext;
class MCExpr;
class MCInst;

class AMDGPUMCInstLower {
  MCContext &Ctx;
  const AMDGPUSubtarget &ST;

  const MCExpr *getLongBranchBlockExpr(const MachineBasicBlock &SrcBB,
                                       const MachineOperand &MO) const;

public:
  AMDGPUMCInstLower(MCContext &ctx, const AMDGPUSubtarget &ST);

  /// \brief Lower a MachineInstr to an MCInst
  void lower(const MachineInstr *MI, MCInst &OutMI) const;

};

} // End namespace llvm

#endif
