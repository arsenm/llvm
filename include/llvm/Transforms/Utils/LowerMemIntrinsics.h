//===- llvm/Transforms/Utils/LowerMemintrinsics.h ---------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Lower aggregate copies, memset, memcpy, memmov intrinsics into loops when the
// size is large or is not a compile-time constant for targetsw without library
// support.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_UTILS_INTEGERDIVISION_H
#define LLVM_TRANSFORMS_UTILS_INTEGERDIVISION_H

namespace llvm {

class Instruction;
class MemCpyInst;
class MemMoveInst;
class MemSetInst;
class Value;

/// Expand instruction \p ConvertedInst into a loop implementing the semantics
/// of llvm.memcpy with the equivalent arguments.
void convertMemCpyToLoop(Instruction *ConvertedInst,
                         Value *SrcAddr, Value *DstAddr, Value *CopyLen,
                         unsigned SrcAlign, unsigned DestAlign,
                         bool SrcIsVolatile, bool DstIsVolatile);
void convertMemCpyToLoop(MemCpyInst *MemCpy);

/// Expand instruction \p ConvertedInst into a loop implementing the semantics
/// of llvm.memcpy with the equivalent arguments.
void convertMemMoveToLoop(Instruction *ConvertedInst,
                          Value *SrcAddr, Value *DstAddr, Value *CopyLen,
                          unsigned SrcAlign, unsigned DestAlign,
                          bool SrcIsVolatile, bool DstIsVolatile);
void convertMemMoveToLoop(MemMoveInst *MemMove);

/// Expand instruction \p ConvertedInst into a loop implementing the semantics
/// of llvm.memset with the equivalent arguments.
void convertMemSetToLoop(Instruction *ConvertedInst,
                         Value *DstAddr, Value *CopyLen, Value *SetValue,
                         unsigned Align, bool IsVolatile);
void convertMemSetToLoop(MemSetInst *MemSet);

} // End llvm namespace

#endif
