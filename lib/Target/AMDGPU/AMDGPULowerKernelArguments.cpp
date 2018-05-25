//===-- AMDGPULowerKernelArguments.cpp ------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// \file This pass replaces accesses to kernel arguments with loads from
/// offsets from the kernarg base pointer.
//
//===----------------------------------------------------------------------===//

#include "AMDGPU.h"
#include "AMDGPUSubtarget.h"
#include "AMDGPUTargetMachine.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/Analysis/DivergenceAnalysis.h"
#include "llvm/Analysis/Loads.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/Attributes.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Operator.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Value.h"
#include "llvm/Pass.h"
#include "llvm/Support/Casting.h"

#define DEBUG_TYPE "amdgpu-lower-kernel-arguments"

using namespace llvm;

namespace {

class AMDGPULowerKernelArguments : public FunctionPass{
public:
  static char ID;

  AMDGPULowerKernelArguments() : FunctionPass(ID) {}

  bool runOnFunction(Function &F) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<TargetPassConfig>();
    AU.setPreservesAll();
 }
};

} // end anonymous namespace

bool AMDGPULowerKernelArguments::runOnFunction(Function &F) {
  CallingConv::ID CC = F.getCallingConv();
  if (CC != CallingConv::AMDGPU_KERNEL || F.arg_empty())
    return false;

  auto &TPC = getAnalysis<TargetPassConfig>();

  const TargetMachine &TM = TPC.getTM<TargetMachine>();
  const SISubtarget &ST = TM.getSubtarget<SISubtarget>(F);

  SmallVector<Type *, 16> ArgTypes;

  for (Argument &Arg : F.args())
    ArgTypes.push_back(Arg.getType());

  LLVMContext &Ctx = F.getParent()->getContext();
  const DataLayout &DL = F.getParent()->getDataLayout();

  StructType *ArgStructTy = StructType::create(Ctx, ArgTypes, F.getName());
  const StructLayout *Layout = DL.getStructLayout(ArgStructTy);

  BasicBlock &EntryBlock = *F.begin();
  IRBuilder<> Builder(&*EntryBlock.begin());

  // Minimum alignment for kern segment is 16.
  unsigned KernArgBaseAlign = std::max(16u, DL.getABITypeAlignment(ArgStructTy));
  const uint64_t BaseOffset = ST.getExplicitKernelArgOffset(F);

  // FIXME: Alignment is broken broken with explicit arg offset.;
  const uint64_t TotalKernArgSize = BaseOffset +
    ST.getKernArgSegmentSize(F, DL.getTypeAllocSize(ArgStructTy));

  CallInst *KernArgSegment =
    Builder.CreateIntrinsic(Intrinsic::amdgcn_kernarg_segment_ptr, nullptr,
                            F.getName() + ".kernarg.segment");


  KernArgSegment->addAttribute(AttributeList::ReturnIndex, Attribute::NonNull);
  KernArgSegment->addAttribute(AttributeList::ReturnIndex,
    Attribute::getWithDereferenceableBytes(Ctx, TotalKernArgSize));
  KernArgSegment->addAttribute(AttributeList::ReturnIndex,
    Attribute::getWithAlignment(Ctx, KernArgBaseAlign));

  Value *KernArgBase = KernArgSegment;
  if (BaseOffset != 0) {
    KernArgBase = Builder.CreateConstInBoundsGEP1_64(KernArgBase, BaseOffset);
    KernArgBaseAlign = MinAlign(KernArgBaseAlign, BaseOffset);
  }

  unsigned AS = KernArgSegment->getType()->getPointerAddressSpace();
  Value *CastStruct = Builder.CreateBitCast(KernArgBase,
                                            ArgStructTy->getPointerTo(AS));
  for (Argument &Arg : F.args()) {
    if (Arg.use_empty())
      continue;

    Value *GEP = Builder.CreateStructGEP(CastStruct, Arg.getArgNo());
    uint64_t EltOffset = Layout->getElementOffset(Arg.getArgNo());

    unsigned EltAlign = MinAlign(EltOffset, KernArgBaseAlign);
    LoadInst *Load = Builder.CreateAlignedLoad(GEP, EltAlign);
    Load->setMetadata(LLVMContext::MD_invariant_load, MDNode::get(Ctx, {}));
    // TODO: Convert noalias arg to !noalias load

    Load->takeName(&Arg);
    Arg.replaceAllUsesWith(Load);

#if 0
    if (PointerType *PT = dyn_cast<PointerType>(Arg.getType())) {
      // FIXME: I think this applies to all targets, it just matters more for SI.
      if (PT->getAddressSpace() == AMDGPUAS::LOCAL_ADDRESS

        ) {
        Metadata *LowAndHigh[] = {
          ConstantAsMetadata::get(ConstantInt::get(IT, 0)),
          ConstantAsMetadata::get(ConstantInt::get(IT, 0xffff))
        };

        II.setMetadata(LLVMContext::MD_range,
                       MDNode::get(II.getContext(), LowAndHigh));
      }
    }
#endif
  }

  return true;
}

INITIALIZE_PASS_BEGIN(AMDGPULowerKernelArguments, DEBUG_TYPE,
                      "AMDGPU Lower Kernel Arguments", false, false)
INITIALIZE_PASS_END(AMDGPULowerKernelArguments, DEBUG_TYPE, "AMDGPU Lower Kernel Arguments",
                    false, false)

char AMDGPULowerKernelArguments::ID = 0;

FunctionPass *llvm::createAMDGPULowerKernelArgumentsPass() {
  return new AMDGPULowerKernelArguments();
}
