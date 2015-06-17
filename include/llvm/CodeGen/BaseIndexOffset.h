//===-- llvm/CodeGen/BaseIndexOffset.h --------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef _LLVM_CODEGEN_BASEINDEXOFFSET_H_
#define _LLVM_CODEGEN_BASEINDEXOFFSET_H_

namespace llvm {

/// Helper struct to parse and store a memory address as base + index + offset.
/// We ignore sign extensions when it is safe to do so.
/// The following two expressions are not equivalent. To differentiate we need
/// to store whether there was a sign extension involved in the index
/// computation.
///  (load (i64 add (i64 copyfromreg %c)
///                 (i64 signextend (add (i8 load %index)
///                                      (i8 1))))
/// vs
///
/// (load (i64 add (i64 copyfromreg %c)
///                (i64 signextend (i32 add (i32 signextend (i8 load %index))
///                                         (i32 1)))))
struct BaseIndexOffset {
  SDValue Base;
  SDValue Index;
  int64_t Offset;
  bool IsIndexSignExt;

  BaseIndexOffset() : Offset(0), IsIndexSignExt(false) {}

  BaseIndexOffset(SDValue Base, SDValue Index, int64_t Offset,
                  bool IsIndexSignExt) :
    Base(Base), Index(Index), Offset(Offset), IsIndexSignExt(IsIndexSignExt) {}

  bool equalBaseIndex(const BaseIndexOffset &Other) {
    return Other.Base == Base && Other.Index == Index &&
      Other.IsIndexSignExt == IsIndexSignExt;
  }

  /// Parses tree in Ptr for base, index, offset addresses.
  static BaseIndexOffset match(SDValue Ptr) {
    bool IsIndexSignExt = false;

    // We only can pattern match BASE + INDEX + OFFSET. If Ptr is not an ADD
    // instruction, then it could be just the BASE or everything else we don't
    // know how to handle. Just use Ptr as BASE and give up.
    if (Ptr->getOpcode() != ISD::ADD)
      return BaseIndexOffset(Ptr, SDValue(), 0, IsIndexSignExt);

    // We know that we have at least an ADD instruction. Try to pattern match
    // the simple case of BASE + OFFSET.
    if (isa<ConstantSDNode>(Ptr->getOperand(1))) {
      int64_t Offset = cast<ConstantSDNode>(Ptr->getOperand(1))->getSExtValue();
      return  BaseIndexOffset(Ptr->getOperand(0), SDValue(), Offset,
                              IsIndexSignExt);
    }

    // Inside a loop the current BASE pointer is calculated using an ADD and a
    // MUL instruction. In this case Ptr is the actual BASE pointer.
    // (i64 add (i64 %array_ptr)
    //          (i64 mul (i64 %induction_var)
    //                   (i64 %element_size)))
    if (Ptr->getOperand(1)->getOpcode() == ISD::MUL)
      return BaseIndexOffset(Ptr, SDValue(), 0, IsIndexSignExt);

    // Look at Base + Index + Offset cases.
    SDValue Base = Ptr->getOperand(0);
    SDValue IndexOffset = Ptr->getOperand(1);

    // Skip signextends.
    if (IndexOffset->getOpcode() == ISD::SIGN_EXTEND) {
      IndexOffset = IndexOffset->getOperand(0);
      IsIndexSignExt = true;
    }

    // Either the case of Base + Index (no offset) or something else.
    if (IndexOffset->getOpcode() != ISD::ADD)
      return BaseIndexOffset(Base, IndexOffset, 0, IsIndexSignExt);

    // Now we have the case of Base + Index + offset.
    SDValue Index = IndexOffset->getOperand(0);
    SDValue Offset = IndexOffset->getOperand(1);

    if (!isa<ConstantSDNode>(Offset))
      return BaseIndexOffset(Ptr, SDValue(), 0, IsIndexSignExt);

    // Ignore signextends.
    if (Index->getOpcode() == ISD::SIGN_EXTEND) {
      Index = Index->getOperand(0);
      IsIndexSignExt = true;
    } else IsIndexSignExt = false;

    int64_t Off = cast<ConstantSDNode>(Offset)->getSExtValue();
    return BaseIndexOffset(Base, Index, Off, IsIndexSignExt);
  }
};


/// Holds a pointer to an LSBaseSDNode as well as information on where it
/// is located in a sequence of memory operations connected by a chain.
struct MemOpLink {
  MemOpLink (LSBaseSDNode *N, int64_t Offset, unsigned Seq):
    MemNode(N), OffsetFromBase(Offset), SequenceNum(Seq) { }
  // Ptr to the mem node.
  LSBaseSDNode *MemNode;
  // Offset from the base ptr.
  int64_t OffsetFromBase;
  // What is the sequence number of this mem node.
  // Lowest mem operand in the DAG starts at zero.
  unsigned SequenceNum;

  // Sort the memory operands according to their distance from the base pointer.
  static bool compare(MemOpLink LHS, MemOpLink RHS) {
    return LHS.OffsetFromBase < RHS.OffsetFromBase ||
      (LHS.OffsetFromBase == RHS.OffsetFromBase &&
       LHS.SequenceNum > RHS.SequenceNum);
  }
};

}

#endif
