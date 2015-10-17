
#include "AMDGPU.h"
#include "AMDGPUIntrinsicInfo.h"

#include "llvm/ADT/SCCIterator.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Analysis/CallGraphSCCPass.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Module.h"


#define DEBUG_TYPE "amdgpu-propagate-kernel-attributes"

using namespace llvm;


namespace {


struct FeatureUsage {
  bool DispatchPtr : 1;
  bool QueuePtr : 1;
  bool DispatchID : 1;
  bool KernargSegmentPtr : 1;
  bool FlatScratchInit : 1;
  bool GridWorkgroupCountX : 1;
  bool GridWorkgroupCountY : 1;
  bool GridWorkgroupCountZ : 1;

  bool WorkGroupIDX : 1;
  bool WorkGroupIDY : 1;
  bool WorkGroupIDZ : 1;
  bool WorkGroupInfo : 1;

  bool WorkItemIDX : 1; // Always initialized
  bool WorkItemIDY : 1;
  bool WorkItemIDZ : 1;

  FeatureUsage() = default;
};

class AMDGPUPropagateKernelAttributes : public CallGraphSCCPass {
public:
  static char ID; // Pass identification, replacement for typeid
  AMDGPUPropagateKernelAttributes() : CallGraphSCCPass(ID) {
    initializeAMDGPUPropagateKernelAttributesPass(*PassRegistry::getPassRegistry());
  }

  bool runOnSCC(CallGraphSCC &SCC) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    CallGraphSCCPass::getAnalysisUsage(AU);
  }

private:
  bool isKernel(Function &F) const {
    return true;
  }

  FeatureUsage getFunctionFeatures(const Function &F) const;

#if 0
  void findOpenCLKernelAttributes(const MDNode *Node);
  void parseOpenCLMetadata(const Module *M);
#endif
};
}

char AMDGPUPropagateKernelAttributes::ID = 0;
char &llvm::AMDGPUPropagateKernelAttributesID
  = AMDGPUPropagateKernelAttributes::ID;


INITIALIZE_PASS_BEGIN(AMDGPUPropagateKernelAttributes, DEBUG_TYPE,
                      "Deduce function attributes", false, false)
INITIALIZE_PASS_END(AMDGPUPropagateKernelAttributes, DEBUG_TYPE,
                    "Deduce function attributes", false, false)

Pass *llvm::createAMDGPUPropagateKernelAttributesPass() {
  return new AMDGPUPropagateKernelAttributes();
}

#if 0
static void parseWorkgroupSize(uint32_t Size[3], const MDNode *Node) {
  unsigned N = Node->getNumOperands();

  for (unsigned I = 0; I < std::min(N - 1, 3u); ++I) {
    const ConstantInt *C = dyn_cast<ConstantInt>(Node->getOperand(I + 1));
    if (!C) {
      // This is malformed, just give up.
      Size[0] = 0;
      Size[1] = 0;
      Size[2] = 0;
      return;
    }

    Size[I] = C->getZExtValue();
  }
}

void AMDGPUPropagateKernelAttributes::findOpenCLKernelAttributes(const MDNode *Node) {
  uint32_t ReqdWorkGroupSize[3];
  uint32_t WorkGroupSizeHint[3];
  bool IsKernel;

  for (unsigned I = 1, E = Node->getNumOperands(); I != E; ++I) {
    const MDNode *Op = dyn_cast<MDNode>(Node->getOperand(I));
    if (!Op)
      continue;

    unsigned N = Op->getNumOperands();
    if (N == 0)
      continue;

    const MDString *NameNode = dyn_cast<MDString>(Op->getOperand(0));
    if (!NameNode)
      continue;

    StringRef Name = NameNode->getString();

    if (N == 4 && Name == "reqd_work_group_size")
      parseWorkgroupSize(ReqdWorkGroupSize, Op);
    else if (N == 4 && Name == "work_group_size_hint")
      parseWorkgroupSize(WorkGroupSizeHint, Op);
    else if (Name == "vec_type_hint") {
      // TODO: Do we care about this at all?
    }
  }
}

void AMDGPUPropagateKernelAttributes::parseOpenCLMetadata(const Module *M) {
  const NamedMDNode *Kernels = M->getNamedMetadata("opencl.kernels");
  if (!Kernels)
    return;

  for (const MDNode *K : Kernels->operands()) {
    unsigned N = K->getNumOperands();
    if (N == 0)
      continue;

    // We expect the first operand to be the function.
    const Value *First = cast<ValueAsMetadata>(K->getOperand(0))->getValue();
    if (First == F) {
      IsKernel = true;
      findOpenCLKernelAttributes(K);
      break;
    }
  }
}
#endif

FeatureUsage AMDGPUPropagateKernelAttributes::getFunctionFeatures(const Function &F) const {
  FeatureUsage Features;

  for (const BasicBlock &BB : F) {
    for (const Instruction &I : BB) {
      ImmutableCallSite CS(&I);
      if (!CS)
        continue;

      // FIXME: This can also return null when the function pointer is bitcasted
      // which we should be able to handle.
      const Function *F = CS.getCalledFunction();
      assert(F && "indirect calls not supported");

      Intrinsic::ID IntID = F->getIntrinsicID();
      switch (IntID) {
      case Intrinsic::r600_read_tgid_x:
        Features.WorkGroupIDX = true;
        break;
      case Intrinsic::r600_read_tgid_y:
        Features.WorkGroupIDY = true;
        break;
      case Intrinsic::r600_read_tgid_z:
        Features.WorkGroupIDZ = true;
        break;
      case Intrinsic::r600_read_tidig_x:
        Features.WorkItemIDX = true;
        break;
      case Intrinsic::r600_read_tidig_y:
        Features.WorkItemIDY = true;
        break;
      case Intrinsic::r600_read_tidig_z:
        Features.WorkItemIDZ = true;
        break;
      }
    }
  }

  return Features;
}


bool AMDGPUPropagateKernelAttributes::runOnSCC(CallGraphSCC &SCC) {

#if 0
  SmallPtrSet<Function *, 8> SCCNodes;

  // Fill SCCNodes with the elements of the SCC.  Used for quickly
  // looking up whether a given CallGraphNode is in this SCC.
  for (CallGraphSCC::iterator I = SCC.begin(), E = SCC.end(); I != E; ++I)
    SCCNodes.insert((*I)->getFunction());
#endif

  for (CallGraphNode *N : SCC) {
    Function *F = N->getFunction();

    // XXX - Why can F be null?
    if (F)
      getFunctionFeatures(*F);
  }

  return false;
}
