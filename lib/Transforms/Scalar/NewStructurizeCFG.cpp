//===- StructurizeCFG.cpp -------------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/MapVector.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/Analysis/DivergenceAnalysis.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Constant.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Use.h"
#include "llvm/IR/User.h"
#include "llvm/IR/Value.h"
#include "llvm/Pass.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils/SSAUpdater.h"
#include <algorithm>
#include <cassert>
#include <utility>

using namespace llvm;
using namespace llvm::PatternMatch;

#define DEBUG_TYPE "newstructurizecfg"

namespace {
using BBValuePair = std::pair<BasicBlock *, Value *>;

// Definition of the complex types used in this pass.
using BBVector = SmallVector<BasicBlock *, 8>;
using BranchVector = SmallVector<BranchInst *, 8>;
using BBValueVector = SmallVector<BBValuePair, 2>;
using BBValuePair = std::pair<BasicBlock *, Value *>;

using BBSet = SmallPtrSet<BasicBlock *, 8>;
using PhiMap = MapVector<PHINode *, BBValueVector>;
using BB2BBVecMap = MapVector<BasicBlock *, BBVector>;

using BBPhiMap = DenseMap<BasicBlock *, PhiMap>;
using BBPredicates = DenseMap<BasicBlock *, Value *>;
using PredMap = DenseMap<BasicBlock *, BBPredicates>;
using BB2BBMap = DenseMap<BasicBlock *, BasicBlock *>;

/// Finds the nearest common dominator of a set of BasicBlocks.
///
/// For every BB you add to the set, you can specify whether we "remember" the
/// block.  When you get the common dominator, you can also ask whether it's one
/// of the blocks we remembered.
template <class DomTreeType = DominatorTree>
class NearestCommonDominator {
  DomTreeType *DT;
  BasicBlock *Result = nullptr;
  bool ResultIsRemembered = false;

  /// Add BB to the resulting dominator.
  void addBlock(BasicBlock *BB, bool Remember) {
    if (!Result) {
      Result = BB;
      ResultIsRemembered = Remember;
      return;
    }

    BasicBlock *NewResult = DT->findNearestCommonDominator(Result, BB);
    if (NewResult != Result)
      ResultIsRemembered = false;
    if (NewResult == BB)
      ResultIsRemembered |= Remember;
    Result = NewResult;
  }

public:
  explicit NearestCommonDominator(DomTreeType *DomTree) : DT(DomTree) {}

  void addBlock(BasicBlock *BB) {
    addBlock(BB, /* Remember = */ false);
  }

  void addAndRememberBlock(BasicBlock *BB) {
    addBlock(BB, /* Remember = */ true);
  }

  /// Get the nearest common dominator of all the BBs added via addBlock() and
  /// addAndRememberBlock().
  BasicBlock *result() { return Result; }

  /// Is the BB returned by getResult() one of the blocks we added to the set
  /// with addAndRememberBlock()?
  bool resultIsRememberedBlock() { return ResultIsRemembered; }
};

/// @brief Transforms the control flow graph on one single entry/exit region
/// at a time.
///
/// After the transform all "If"/"Then"/"Else" style control flow looks like
/// this:
///
/// \verbatim
/// 1
/// ||
/// | |
/// 2 |
/// | /
/// |/
/// 3
/// ||   Where:
/// | |  1 = "If" block, calculates the condition
/// 4 |  2 = "Then" subregion, runs if the condition is true
/// | /  3 = "Flow" blocks, newly inserted flow blocks, rejoins the flow
/// |/   4 = "Else" optional subregion, runs if the condition is false
/// 5    5 = "End" block, also rejoins the control flow
/// \endverbatim
///
/// Control flow is expressed as a branch where the true exit goes into the
/// "Then"/"Else" region, while the false exit skips the region
/// The condition for the optional "Else" region is expressed as a PHI node.
/// The incoming values of the PHI node are true for the "If" edge and false
/// for the "Then" edge.
///
/// Additionally to that even complicated loops look like this:
///
/// \verbatim
/// 1
/// ||
/// | |
/// 2 ^  Where:
/// | /  1 = "Entry" block
/// |/   2 = "Loop" optional subregion, with all exits at "Flow" block
/// 3    3 = "Flow" block, with back edge to entry block
/// |
/// \endverbatim
///
/// The back edge of the "Flow" block is always on the false side of the branch
/// while the true side continues the general flow. So the loop condition
/// consist of a network of PHI nodes where the true incoming values expresses
/// breaks and the false values expresses continue states.
class NewStructurizeCFG : public FunctionPass {
  bool SkipUniformRegions;

  Type *Boolean;
  ConstantInt *BoolTrue;
  ConstantInt *BoolFalse;
  UndefValue *BoolUndef;

  Function *Func;

  DominatorTree *DT;
  PostDominatorTree *PDT;
  LoopInfo *LI;

//  SmallVector<BasicBlock *, 8> Order;
//  BBSet Visited;

  //BBPhiMap DeletedPhis;
  //BB2BBVecMap AddedPhis;

  //PredMap Predicates;
  //BranchVector Conditions;

  BB2BBMap Loops;
  PredMap LoopPreds;
  BranchVector LoopConds;

  bool isUnstructuredEdge(BasicBlockEdge Edge) const;
  BasicBlock *findCIDOM(ArrayRef<BasicBlock *> BBs) const;
  BasicBlock *findCIPDOM(ArrayRef<BasicBlock *> BBs) const;

public:
  static char ID;

  explicit NewStructurizeCFG(bool SkipUniformRegions = false)
      : FunctionPass(ID), SkipUniformRegions(SkipUniformRegions) {
    initializeNewStructurizeCFGPass(*PassRegistry::getPassRegistry());
  }

  static Value *invert(Value *Condition);
  bool doInitialization(Module &M) override;
  bool runOnFunction(Function &F) override;

  StringRef getPassName() const override {
    return "Structurize control flow";
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    if (SkipUniformRegions)
      AU.addRequired<DivergenceAnalysis>();
    AU.addRequiredID(LowerSwitchID);
    AU.addRequired<DominatorTreeWrapperPass>();
    AU.addRequired<PostDominatorTreeWrapperPass>();
    AU.addRequired<LoopInfoWrapperPass>();

    AU.addPreserved<DominatorTreeWrapperPass>();
    FunctionPass::getAnalysisUsage(AU);
  }
};

} // end anonymous namespace

bool NewStructurizeCFG::isUnstructuredEdge(BasicBlockEdge Edge) const {
  // An edge from block Bi to Bj is said to be unstructured if any of the
  // following three conditions is satisfied:

  //  Block Bi has multiple successors, block Bj has multiple predecessors, and
  //  neither of Bi or Bj dominates nor postdominates the other,
  if (!Edge.getStart()->getSingleSuccessor() &&
      !succ_empty(Edge.getStart()) &&
      !Edge.getEnd()->getSingleSuccessor() &&
      !succ_empty(Edge.getEnd()) &&
      !DT->dominates(Edge.getStart(), Edge.getEnd()) &&
      !DT->dominates(Edge.getEnd(), Edge.getStart()) &&
      !PDT->dominates(Edge.getStart(), Edge.getEnd()) &&
      !PDT->dominates(Edge.getEnd(), Edge.getStart())) {
    return true;
  }

  if (Loop *L0 = LI->getLoopFor(Edge.getEnd())) {
    if (Loop *L1 = LI->getLoopFor(Edge.getStart())) {
      if (L0 != L1) {

      }
    }

  }




// Block Bj is in a loop, block Bi is not in the same loop and Bj does not
// dominate all other blocks of the loop,

//  Block Bi is in a loop, block Bj is not in the same loop and Bi does not
//  postdominate all other blocks of the loop

  return false;
}

BasicBlock *NewStructurizeCFG::findCIDOM(ArrayRef<BasicBlock *> Set) const {
  NearestCommonDominator<> NCD(DT);
  for (BasicBlock *BB : Set)
    NCD.addBlock(BB);
  return NCD.result();
}

BasicBlock *NewStructurizeCFG::findCIPDOM(ArrayRef<BasicBlock *> Set) const {
  NearestCommonDominator<PostDominatorTree> NCD(PDT);
  for (BasicBlock *BB : Set)
    NCD.addBlock(BB);
  return NCD.result();
}

char NewStructurizeCFG::ID = 0;

INITIALIZE_PASS_BEGIN(NewStructurizeCFG, "newstructurizecfg", "Structurize the CFG",
                      false, false)
INITIALIZE_PASS_DEPENDENCY(DivergenceAnalysis)
INITIALIZE_PASS_DEPENDENCY(LowerSwitch)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(PostDominatorTreeWrapperPass)
INITIALIZE_PASS_END(NewStructurizeCFG, "newstructurizecfg", "Structurize the CFG",
                    false, false)

/// \brief Initialize the types and constants used in the pass
bool NewStructurizeCFG::doInitialization(Module &M) {
  LLVMContext &Context = M.getContext();

  Boolean = Type::getInt1Ty(Context);
  BoolTrue = ConstantInt::getTrue(Context);
  BoolFalse = ConstantInt::getFalse(Context);
  BoolUndef = UndefValue::get(Boolean);

  return false;
}

/// \brief Invert the given condition
Value *NewStructurizeCFG::invert(Value *Condition) {
  // First: Check if it's a constant
  if (Constant *C = dyn_cast<Constant>(Condition))
    return ConstantExpr::getNot(C);

  // Second: If the condition is already inverted, return the original value
  if (match(Condition, m_Not(m_Value(Condition))))
    return Condition;

  if (Instruction *Inst = dyn_cast<Instruction>(Condition)) {
    // Third: Check all the users for an invert
    BasicBlock *Parent = Inst->getParent();
    for (User *U : Condition->users())
      if (Instruction *I = dyn_cast<Instruction>(U))
        if (I->getParent() == Parent && match(I, m_Not(m_Specific(Condition))))
          return I;

    // Last option: Create a new instruction
    return BinaryOperator::CreateNot(Condition, "", Parent->getTerminator());
  }

  if (Argument *Arg = dyn_cast<Argument>(Condition)) {
    BasicBlock &EntryBlock = Arg->getParent()->getEntryBlock();
    return BinaryOperator::CreateNot(Condition,
                                     Arg->getName() + ".inv",
                                     EntryBlock.getTerminator());
  }

  llvm_unreachable("Unhandled condition to invert");
}

bool NewStructurizeCFG::runOnFunction(Function &F) {
  if (SkipUniformRegions) {

#if 0
    // TODO: We could probably be smarter here with how we handle sub-regions.
    auto &DA = getAnalysis<DivergenceAnalysis>();
    if (hasOnlyUniformBranches(R, DA)) {
      DEBUG(dbgs() << "Skipping region with uniform control flow: " << *R << '\n');

      // Mark all direct child block terminators as having been treated as
      // uniform. To account for a possible future in which non-uniform
      // sub-regions are treated more cleverly, indirect children are not
      // marked as uniform.
      MDNode *MD = MDNode::get(R->getEntry()->getParent()->getContext(), {});
      for (RegionNode *E : R->elements()) {
        if (E->isSubRegion())
          continue;

        if (Instruction *Term = E->getEntry()->getTerminator())
          Term->setMetadata("structurizecfg.uniform", MD);
      }

      return false;
    }
#endif
  }

  Func = &F;

  DT = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  PDT = &getAnalysis<PostDominatorTreeWrapperPass>().getPostDomTree();
  LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();


  std::vector<BasicBlock *> UnstructuredBlocks;
  scc_iterator<Function *> I = scc_begin(Func);
  for (; !I.isAtEnd(); ++I) {
    const std::vector<BasicBlock *> &Nodes = *I;
    for (BasicBlock *BB : Nodes) {
    }
  }



  return true;
}

namespace llvm {
Pass *createNewStructurizeCFGPass(bool SkipUniformRegions);
}

Pass *llvm::createNewStructurizeCFGPass(bool SkipUniformRegions) {
  return new NewStructurizeCFG(SkipUniformRegions);
}
