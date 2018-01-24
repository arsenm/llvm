//===- LinearizeCFG.cpp ---------------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Based on the paper "Taming Control Divergence in GPUs through Control Flow
// Linearization"
//
// Structurize unstructured CFGs blocks by introducing guard blocks around
// unstructured blocks.
//
// Each unstructured block has a guard block inserted as its predecessor. The
// unstructured block assigns a unique block ID for each successor for a guard
// variable. The unstructured block has a single unconditional branch to the
// next block's guard. After linearization a guarded block will have one
// predecessor, the guard block, and one successor, the next guard block.
//
// Each guard block checks the incoming successor ID, and enters the guarded
// block if the ID matches.
//
// An additional guard is introduced for back edges.
//
// This can be applied even to some structured CFGs in order to allow
// interleaving of different divergent subregions.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/MapVector.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/STLExtras.h"

#include "llvm/Analysis/CFG.h"
#include "llvm/Analysis/DivergenceAnalysis.h"
#include "llvm/Analysis/DominanceFrontier.h"
#include "llvm/Analysis/InstructionSimplify.h"
//#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/RegionIterator.h"
#include "llvm/Analysis/TargetTransformInfo.h"
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
#include "llvm/IR/IRBuilder.h"
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
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/SSAUpdater.h"
#include <algorithm>
#include <cassert>
#include <utility>

using namespace llvm;
using namespace llvm::PatternMatch;

#define DEBUG_TYPE "linearize-cfg"

namespace {

raw_ostream &operator<<(raw_ostream &OS, const RegionNode &N) {
  if (N.isSubRegion()) {
    BasicBlock *Enter = N.getNodeAs<Region>()->getEnteringBlock();
    BasicBlock *Exit = N.getNodeAs<Region>()->getExit();

    OS << "  subregion: "
           << (Enter ? Enter->getName() : "<null entry>")
           << " -> "
           << (Exit ? Exit->getName() : "<null exit>");
  } else {
    BasicBlock *BB = N.getNodeAs<BasicBlock>();
    OS << " BB " << BB->getName();
  }

  return OS;
}

// Provide global definitions of inverse depth first iterators...
template <class T>
struct iscc_iterator : public scc_iterator<Inverse<T>> {
  iscc_iterator(const scc_iterator<Inverse<T>> &V)
    : scc_iterator<Inverse<T>>(V) {}
};

template <class T>
iscc_iterator<T> iscc_begin(const T& G) {
  return iscc_iterator<T>::begin(Inverse<T>(G));
}

template <class T>
iscc_iterator<T> iscc_end(const T& G){
  return iscc_iterator<T>::end(Inverse<T>(G));
}


template <class T>
iterator_range<iscc_iterator<T>> inverse_scc(const T& G) {
  return make_range(iscc_begin(G), iscc_end(G));
}


inline bool operator==(const BasicBlockEdge LHS,
                       const BasicBlockEdge RHS) {
  return LHS.getStart() == RHS.getStart() && LHS.getEnd() == RHS.getEnd();
}

bool operator==(const DenseSet<BasicBlock*> &X,
                const DenseSet<BasicBlock*> &Y) {
  if (X.size() != Y.size())
    return false;

  for (const BasicBlock *BB : X) {
    if (!Y.count(BB))
      return false;
  }

  for (const BasicBlock *BB : Y) {
    if (!X.count(BB))
      return false;
  }

  return true;
}





static cl::opt<bool> EnableSkipUniformRegions(
  "unstructured-uniform-regions",
  cl::desc("Don't structurize uniform regions"),
  cl::init(false));


static cl::opt<bool> LinearizeWholeFunction(
  "linearize-whole-function",
  cl::desc("Force linearization even for structured blocks"),
  cl::ReallyHidden,
  cl::init(false));


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

class LinearizeCFG : public FunctionPass {
  const TargetTransformInfo *TTI = nullptr;
  DivergenceAnalysis *DA = nullptr;
  bool SkipUniformRegions;

  ConstantInt *BoolTrue;
  ConstantInt *BoolFalse;

  Function *Func;
  BasicBlock *UnreachableBlock;

  DominatorTree *DT;
  PostDominatorTree *PDT;
  SSAUpdater GuardVarInserter;

  DenseMap<BasicBlock *, BasicBlock *> GuardMap;
  DenseMap<BasicBlock *, BasicBlock *> BEGuardMap;
  DenseMap<BasicBlock *, BasicBlock *> InvGuardMap;
  DenseMap<BasicBlock *, BasicBlock *> InvBEGuardMap;
  DenseMap<BasicBlock *, unsigned> BlockNumbers;


  bool isGuardBlock(const BasicBlock *BB) const {
    return InvGuardMap.find(BB) != InvGuardMap.end();
  }

  bool isBEGuardBlock(const BasicBlock *BB) const {
    return InvBEGuardMap.find(BB) != InvBEGuardMap.end();
  }

  BasicBlock *getBEGuardBlock(const BasicBlock *BB) const;
  BasicBlock *getOrInsertGuardBlock(BasicBlock *BB);
  BasicBlock *getGuardBlock(const BasicBlock *BB) const;

  Value *insertGuardVar(IRBuilder<> &Builder, BasicBlock *BB);
  unsigned getBlockNumber(BasicBlock *BB) const;
  void rebuildSSA();

  bool isUnstructuredEdge(BasicBlockEdge Edge) const;
  void findUnstructuredEdges() const;
  BasicBlock *findCIDOM(ArrayRef<BasicBlock *> BBs) const;
  BasicBlock *findCIPDOM(ArrayRef<BasicBlock *> BBs) const;

  BasicBlock *findCIDOM(const DenseSet<BasicBlock *> &BBs) const;
  BasicBlock *findCIPDOM(const DenseSet<BasicBlock *> &BBs) const;

public:
  static char ID;

  explicit LinearizeCFG(bool SkipUniformRegions = false)
      : FunctionPass(ID), SkipUniformRegions(SkipUniformRegions) {
    initializeLinearizeCFGPass(*PassRegistry::getPassRegistry());

    if (EnableSkipUniformRegions.getNumOccurrences() > 0)
      this->SkipUniformRegions = EnableSkipUniformRegions;
  }

  static Value *invert(Value *Condition);
  BasicBlock *getUnreachableBlock();
  BasicBlock *cloneBlock(BasicBlock *BB);

  bool doInitialization(Module &M) override;

  void addAndUpdatePhis(BasicBlock *PrevGuard, BasicBlock *Guard);

  void addEdge(
    IRBuilder<> &Builder,
    BasicBlock *PrevGuard, BasicBlock *Guard,
    BasicBlock *GuardVarBlock,
    StringRef CmpSuffix = "prevbb.cmp");

  void addBrPrevGuardToGuard(
    IRBuilder<> &Builder,
    BasicBlock *PrevGuard, BasicBlock *Guard,
    BasicBlock *GuardVarBlock,
    StringRef CmpSuffix = "prevbb.cmp");
  void removeBranchTo(
    IRBuilder<> &Builder, BasicBlock *BB, BasicBlock *Dest,
    BasicBlock *PhiReplacePred = nullptr);

  void numberBlocks();

  void identifyUnstructuredEdges(
    SmallVectorImpl<BasicBlockEdge> &UnstructuredEdges);

  void pickBlocksToGuard(SmallVectorImpl<BasicBlock *> &Blocks,
                         ArrayRef<BasicBlockEdge> UnstructEdges);

  void pruneExtraEdge(IRBuilder<> &Builder,
                      ArrayRef<BasicBlock *> OrderedUnstructuredBlocks,
                      BasicBlock *Guard, BasicBlock *PrevBlock,
                      BasicBlock *PrevGuard);
  void linearizeBlocks(ArrayRef<BasicBlock *> OrderedUnstructuredBlocks);
  bool verifyGuardedBlockEdges(ArrayRef<BasicBlock *> GuardedBlocks) const;

  void releaseMemory() override;
  bool runOnFunction(Function &F) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    if (SkipUniformRegions)
      AU.addRequired<DivergenceAnalysis>();
    AU.addRequiredID(LowerSwitchID);
    AU.addPreservedID(LowerSwitchID);
    AU.addRequired<DominatorTreeWrapperPass>();
    AU.addRequired<PostDominatorTreeWrapperPass>();
    //AU.addRequired<LoopInfoWrapperPass>();

    AU.addPreserved<DominatorTreeWrapperPass>();

    AU.addRequired<DominanceFrontierWrapperPass>();


    AU.addRequired<TargetTransformInfoWrapperPass>();
    FunctionPass::getAnalysisUsage(AU);
  }
};

} // end anonymous namespace

static bool verifyBlockPhis(const BasicBlock *BB) {
  unsigned NumPreds = std::distance(pred_begin(BB), pred_end(BB));
  for (auto &Phi : BB->phis()) {

    for (const BasicBlock *Pred : predecessors(BB)) {
      if (Phi.getBasicBlockIndex(Pred) == -1) {
        dbgs() << "Missing predecessor: " << Pred->getName()
               << " from " << BB->getName() << '\n';
        return false;
      }
    }

    if (Phi.getNumIncomingValues() != NumPreds)
      return false;
  }

  return true;
}

static void verifyAllBlockPhis(const Function *F) {
  for (const BasicBlock &BB : *F) {
    assert(verifyBlockPhis(&BB));
  }
}


static bool hasMultipleSuccessors(const BasicBlock *BB) {
  //return !BB->getSingleSuccessor() && !succ_empty(BB);

  //return std::distance(succ_begin(BB), succ_end(BB)) > 1;
  return std::distance(succ_begin(BB), succ_end(BB)) > 1;
}

static bool hasMultiplePredecessors(const BasicBlock *BB) {
  return std::distance(pred_begin(BB), pred_end(BB)) > 1;
//  return !BB->getSinglePredecessor() && !pred_empty(BB);
}

static bool hasMultipleSuccessorsExcept(const BasicBlock *BB,
                                        const BasicBlock *Except) {
  //return !BB->getSingleSuccessor() && !succ_empty(BB);

  //return std::distance(succ_begin(BB), succ_end(BB)) > 1;
  //return std::distance(succ_begin(BB), succ_end(BB)) > 1;

  unsigned Count = 0;
  for (const BasicBlock *Pred : successors(BB)) {
    if (Pred != Except)
      ++Count;
  }

  return Count > 1;
}

static bool hasMultiplePredecessorsExcept(const BasicBlock *BB,
                                          const BasicBlock *Except) {
  unsigned Count = 0;
  for (const BasicBlock *Pred : predecessors(BB)) {
    if (Pred != Except)
      ++Count;
  }

  return Count > 1;


  //return std::distance(pred_begin(BB), pred_end(BB)) > 1;
//  return !BB->getSinglePredecessor() && !pred_empty(BB);
}


static bool dominatesOtherPred(const BasicBlock *BB,
                               const BasicBlock *IncomingPred,
                               const DominatorTree *DT,
                               const PostDominatorTree *PDT) {
  unsigned Count = 0;
  for (const BasicBlock *Pred : predecessors(BB)) {
    ++Count;
    if (Pred == IncomingPred) {
      continue;
    }

    if (DT->dominates(BB, Pred) || PDT->dominates(BB, Pred) ||
        DT->dominates(Pred, BB) || PDT->dominates(Pred, BB))
      return true;
  }

  return Count > 1;

  return false;
}

bool LinearizeCFG::isUnstructuredEdge(BasicBlockEdge Edge) const {
#if 0
  // An edge from block Bi to Bj is said to be unstructured if any of the
  // following three conditions is satisfied:
  DEBUG(dbgs() << "\nCheck edge: " << Edge.getStart()->getName() << " -> " << Edge.getEnd()->getName() << '\n');







  DEBUG(dbgs() << "Bi multiple successors: " << hasMultipleSuccessors(Edge.getStart()) << '\n');
  DEBUG(dbgs() << "bj multiple predecessors: " << hasMultiplePredecessors(Edge.getEnd()) << '\n');



  DEBUG(
    dbgs() << "Dom checks: i dom j:\n  "
    << Edge.getStart()->getName() << " dominates " << Edge.getEnd()->getName() << ": " << DT->dominates(Edge.getStart(), Edge.getEnd()) << '\n'
    << " j dom i: " << Edge.getEnd()->getName() << " dominates " << Edge.getStart()->getName() << ": " << DT->dominates(Edge.getEnd(), Edge.getStart()) << '\n'
    << "PostDom checks: i dom j:\n  "
    << Edge.getStart()->getName() << " postdominates " << Edge.getEnd()->getName() << ": " << PDT->dominates(Edge.getStart(), Edge.getEnd()) << '\n'
    << " j dom i: " << Edge.getEnd()->getName() << " postdominates " << Edge.getStart()->getName() << ": " << PDT->dominates(Edge.getEnd(), Edge.getStart()) << '\n';
  );

#if 0
  if ((hasMultipleSuccessors(Edge.getStart()) &&
       hasMultiplePredecessors(Edge.getEnd())))
    return true;
  return false;
#endif



  if (hasMultiplePredecessors(Edge.getEnd()) &&
      !PDT->dominates(Edge.getEnd(), Edge.getStart())) {

    return true;

  if (hasMultipleSuccessors(Edge.getStart()) &&
      !DT->dominates(Edge.getStart(), Edge.getEnd()))
    return true;
  }



  /*
  if (hasMultipleSuccessors(Edge.getStart()) &&
      !PDT->dominates(Edge.getEnd(), Edge.getStart()))
    return true;

  if (hasMultiplePredecessors(Edge.getEnd()) &&
      !DT->dominates(Edge.getStart(), Edge.getEnd()))
    return true;
  */

#if 0
  if (!DT->dominates(Edge.getStart(), Edge.getEnd()) &&
      !DT->dominates(Edge.getEnd(), Edge.getStart()) &&
      !PDT->dominates(Edge.getStart(), Edge.getEnd()) &&
      !PDT->dominates(Edge.getEnd(), Edge.getStart())) {
    return true;
  }
#endif
  return false;

  /*
  if (hasMultiplePredecessors(Edge.getEnd()) &&
      !PDT->dominates(Edge.getEnd(), Edge.getStart()))
    return true;

  if (hasMultipleSuccessors(Edge.getEnd()) &&
      !DT->dominates(Edge.getStart(), Edge.getEnd())) {
    return true;
  }

  return false;
  */
  //  Block Bi has multiple successors, block Bj has multiple predecessors, and
  //  neither of Bi or Bj dominates nor postdominates the other,
  /*
  if ((hasMultipleSuccessorsExcept(Edge.getStart(), Edge.getEnd()) &&
       hasMultiplePredecessorsExcept(Edge.getEnd(), Edge.getStart())) &&
  */

  /*
  if ((hasMultipleSuccessors(Edge.getStart()) &&
       hasMultiplePredecessors(Edge.getEnd())) &&
      !DT->dominates(Edge.getStart(), Edge.getEnd()) &&
      !PDT->dominates(Edge.getEnd(), Edge.getStart())) {
    return true;
  }

  return false;
  */


#endif
  if ((hasMultipleSuccessors(Edge.getStart()) &&
       hasMultiplePredecessors(Edge.getEnd())) &&

      (!DT->dominates(Edge.getStart(), Edge.getEnd()) &&
       !DT->dominates(Edge.getEnd(), Edge.getStart()) &&
       !PDT->dominates(Edge.getStart(), Edge.getEnd()) &&
       !PDT->dominates(Edge.getEnd(), Edge.getStart()))) {
    return true;
  }


// Block Bj is in a loop, block Bi is not in the same loop and Bj does not
// dominate all other blocks of the loop,

//  Block Bi is in a loop, block Bj is not in the same loop and Bi does not
//  postdominate all other blocks of the loop

  return false;
}

void LinearizeCFG::rebuildSSA() {
  Function &F = *Func;
  DT->verifyDomTree();

  SSAUpdater SSA;
  for (BasicBlock &BB : F) {
    for (Instruction &I : BB) {
      for (auto UI = I.use_begin(), UE = I.use_end(); UI != UE;) {
        Use &U = *UI;
        ++UI;
        SSA.Initialize(I.getType(), I.getName());
        SSA.AddAvailableValue(&BB, &I);
        Instruction *User = cast<Instruction>(U.getUser());
        if (User->getParent() == &BB)
          continue;

        if (PHINode *UserPN = dyn_cast<PHINode>(User))
          if (UserPN->getIncomingBlock(U) == &BB)
            continue;

        if (DT->dominates(&I, User))
          continue;

        DEBUG(dbgs() << "Rebuilding SSA value: " << *U.getUser() << '\n');
        SSA.RewriteUseAfterInsertions(U);
      }
    }
  }
}

void LinearizeCFG::findUnstructuredEdges() const {
  ReversePostOrderTraversal<Function *> RPOT(Func);

  unsigned UnstructuredCount = 0;

  for (BasicBlock *BB : RPOT) {
    for (BasicBlock *Succ : successors(BB)) {
      BasicBlockEdge Edge(BB, Succ);
      if (isUnstructuredEdge(Edge)) {
        ++UnstructuredCount;
        DEBUG(dbgs() << "Unstructured edge: "
                     << BB->getName()
                     << " -> "
                     << Succ->getName() << '\n');
      }
    }
  }

  DEBUG(dbgs() << "Found " << UnstructuredCount << " unstructured edges\n");
}


BasicBlock *LinearizeCFG::findCIDOM(ArrayRef<BasicBlock *> Set) const {
  NearestCommonDominator<> NCD(DT);
  for (BasicBlock *BB : Set)
    NCD.addAndRememberBlock(BB);
  return NCD.result();
}

BasicBlock *LinearizeCFG::findCIDOM(const DenseSet<BasicBlock *> &Set) const {
  NearestCommonDominator<> NCD(DT);
  for (BasicBlock *BB : Set)
    NCD.addAndRememberBlock(BB);
  return NCD.result();
}

BasicBlock *LinearizeCFG::findCIPDOM(ArrayRef<BasicBlock *> Set) const {
  BasicBlock *NCD = Set[0];
  for (BasicBlock *BB : Set.drop_front(1)) {
    NCD = PDT->findNearestCommonDominator(BB, NCD);
    if (!NCD)
      break;
  }

  return NCD;
}

BasicBlock *LinearizeCFG::findCIPDOM(const DenseSet<BasicBlock *> &Set) const {
  NearestCommonDominator<PostDominatorTree> NCD(PDT);
  for (BasicBlock *BB : Set)
    NCD.addAndRememberBlock(BB);
  return NCD.result();
}

char LinearizeCFG::ID = 0;

INITIALIZE_PASS_BEGIN(LinearizeCFG, "linearize-cfg",
                      "Structurize the CFG with linearization",
                      false, false)
INITIALIZE_PASS_DEPENDENCY(DivergenceAnalysis)
INITIALIZE_PASS_DEPENDENCY(LowerSwitch)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(PostDominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(DominanceFrontierWrapperPass)
INITIALIZE_PASS_END(LinearizeCFG, "linearize-cfg",
                    "Structurize the CFG with linearization",
                    false, false)

/// \brief Initialize the types and constants used in the pass
bool LinearizeCFG::doInitialization(Module &M) {
  LLVMContext &Context = M.getContext();

  BoolTrue = ConstantInt::getTrue(Context);
  BoolFalse = ConstantInt::getFalse(Context);

  return false;
}

/// \brief Invert the given condition
Value *LinearizeCFG::invert(Value *Condition) {
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

BasicBlock *LinearizeCFG::getUnreachableBlock() {
  if (!UnreachableBlock) {
    UnreachableBlock = BasicBlock::Create(Func->getContext(),
                                          "linearizecfg.unreachable", Func);
    new UnreachableInst(Func->getContext(), UnreachableBlock);
  }

  return UnreachableBlock;
}

BasicBlock *LinearizeCFG::cloneBlock(BasicBlock *BB) {
  /*

  ValueToValueMapTy VMap;
  BasicBlock *New = CloneBasicBlock(*BB, VMap, "." + Twine("structurize.split"));
  Header->getParent()->getBasicBlockList().push_back(New);


  //SmallVector<BasicBlock *, 4> Preds;
  //BasicBlock *NewBB = SplitBlockPredecessors(BB, Preds, "", DT);



  return NewBB;
  */

  return nullptr;
}

static bool isProperBackedge(const DominatorTree &DT,
                             const BasicBlock *BB,
                             const BasicBlock *SuccBB) {
  return DT.dominates(SuccBB, BB);
}

static void printSCCFunc(const Function &F) {
  dbgs() << "Function SCC order:\n";
  scc_iterator<const Function *> I = scc_begin(&F);
  for (; !I.isAtEnd(); ++I) {
    dbgs() << "\nSCC break\n";
    const std::vector<const BasicBlock *> &Nodes = *I;
    for (const BasicBlock *BB : Nodes) {
      dbgs() << "  BB " << BB->getName() << '\n';
    }
  }
}

static void printInverseSCCFunc(const Function &F,
                                const PostDominatorTree &PDT) {
  dbgs() << "Function Inverse SCC order:\n";

  for (const BasicBlock *Exit : PDT.getRoots()) {
    iscc_iterator<const BasicBlock *> I = iscc_begin(Exit);
    for (; !I.isAtEnd(); ++I) {
      dbgs() << "\nInverse SCC break\n";
      const std::vector<const BasicBlock *> &Nodes = *I;
      for (const BasicBlock *BB : Nodes) {
        dbgs() << "  BB " << BB->getName() << '\n';
      }
    }
  }
}

static bool sccHasLoop(ArrayRef<BasicBlock *> BBs) {
  assert(!BBs.empty());

  if (BBs.size() > 1)
    return true;

  for (BasicBlock *Succ : successors(BBs[0])) {
    if (Succ == BBs[0])
      return true;
  }

  return false;
}

static void printRPOFunc(const Function &F) {
  dbgs() << "Function RPO order:\n";
  for (const BasicBlock *BB : ReversePostOrderTraversal<const Function*>(&F))
    dbgs() << "  BB " << BB->getName() << '\n';
}

static ArrayRef<BasicBlock *> findContainedSCC(
  ArrayRef<std::vector<BasicBlock *>> SCCs,
  const BasicBlock *BB) {

  for (ArrayRef<BasicBlock *> SCC : SCCs) {
    if (is_contained(SCC, BB))
      return SCC;
  }

  llvm_unreachable("did not find scc");
}

template <class DomTreeType>
bool dominatesAllBlocksImpl(const DomTreeType *DT, ArrayRef<BasicBlock *> Blocks,
                            const BasicBlock *DomBB) {

  for (BasicBlock *BB : Blocks) {
    if (!DT->dominates(DomBB, BB)) {
      return false;
    }
  }

  return true;
}

static bool dominatesAllBlocks(const DominatorTree *DT,
                               ArrayRef<BasicBlock *> Blocks,
                               const BasicBlock *DomBB) {
  return dominatesAllBlocksImpl<const DominatorTree>(DT, Blocks, DomBB);
}

static bool postdominatesAllBlocks(const PostDominatorTree *PDT,
                                   ArrayRef<BasicBlock *> Blocks,
                                   const BasicBlock *DomBB) {
  return dominatesAllBlocksImpl<const PostDominatorTree>(PDT, Blocks, DomBB);
}

static bool hasUnstructuredEdge(ArrayRef<BasicBlockEdge> Edges,
                                const BasicBlock *BB) {
  for (const BasicBlock *Succ : successors(BB)) {
    BasicBlockEdge E(BB, Succ);
    for (auto X : Edges) { // FIXME: Why doesn't is_contained work here?
      if (E == X)
        return true;

    }
  }

  return false;
}

static bool isSuccessor(const BasicBlock *BB, const BasicBlock* TargetSucc) {
  for (const BasicBlock *Succ : successors(BB)) {
    if (Succ == TargetSucc)
      return true;
  }

  return false;
}

static bool isPredecessor(const BasicBlock *BB, const BasicBlock* TargetPred) {
  for (const BasicBlock *Pred : predecessors(BB)) {
    if (Pred == TargetPred)
      return true;
  }

  return false;
}

static BasicBlock *getOtherDest(BranchInst *BI, BasicBlock *BB) {
  BasicBlock *Succ0 = BI->getSuccessor(0);
  BasicBlock *Succ1 = BI->getSuccessor(1);

  assert((Succ0 == BB || Succ1 == BB) && "not really a successor");
  assert(Succ0 != Succ1 && "FIXME: Handle this case");
  return (Succ0 == BB) ? Succ1 : Succ0;
}

static unsigned getOtherDestIndex(BranchInst *BI, BasicBlock *BB) {
  BasicBlock *Succ0 = BI->getSuccessor(0);
  BasicBlock *Succ1 = BI->getSuccessor(1);

  assert(Succ0 != Succ1 && "FIXME: Handle this case");
  return (Succ0 == BB) ? 1 : 0;
}

static unsigned getDestIndex(BranchInst *BI, BasicBlock *BB) {
  BasicBlock *Succ0 = BI->getSuccessor(0);
  BasicBlock *Succ1 = BI->getSuccessor(1);

  assert(Succ0 != Succ1 && "FIXME: Handle this case");
  return (Succ0 == BB) ? 0 : 1;
}

void LinearizeCFG::addAndUpdatePhis(BasicBlock *PrevGuard,
                                    BasicBlock *Guard) {
  for (PHINode &P : Guard->phis()) {
    SSAUpdater SSA;

    SSA.Initialize(P.getType(), P.getName());

    DEBUG(dbgs() << "Updating phi: " << P << '\n');

    for (unsigned PhiIdx = 0; PhiIdx != P.getNumIncomingValues(); ++PhiIdx) {
      BasicBlock *PredBB = P.getIncomingBlock(PhiIdx);
      Value *PredVal = P.getIncomingValue(PhiIdx);

      SSA.AddAvailableValue(PredBB, PredVal);
    }

    Value *NewVal = SSA.GetValueInMiddleOfBlock(PrevGuard);




#if 1
    int Idx = P.getBasicBlockIndex(PrevGuard);
    if (Idx == -1)
      P.addIncoming(NewVal, PrevGuard);
    else {
      //assert(isa<UndefValue>(NewVal));

      if (!isa<UndefValue>(NewVal)) {
        Value *OldVal = P.getIncomingValue(Idx);
        dbgs() << "NOT UNDEF: " << *NewVal << '\n';
        dbgs() << "WOULD REPLACE: " << *OldVal << '\n';
      }


      //P.setIncomingValue(Idx, NewVal);
    }
#else
    int Idx = P.getBasicBlockIndex(PrevGuard);
    assert(Idx == -1);

    P.addIncoming(NewVal, PrevGuard);
#endif

    DEBUG(dbgs() << "  Add incoming value from " << PrevGuard->getName()
                 << ": " << *NewVal << '\n');


    //assert(P.getNumIncomingValues() == std::distance(pred_begin(PrevGuard), pred_end(PrevGuard)));


  }
}

unsigned LinearizeCFG::getBlockNumber(BasicBlock *BB) const {
  // FIXME: Kind of hacky
  auto I = BlockNumbers.find(BB);
  if (I != BlockNumbers.end()) {
    return I->second;
  }

  auto J = InvGuardMap.find(BB);
  if (J != InvGuardMap.end()) {
    auto K = BlockNumbers.find(J->second);
    assert(K != BlockNumbers.end());
    return K->second;
  }

  llvm_unreachable("block not numbered");
}

BasicBlock *LinearizeCFG::getBEGuardBlock(const BasicBlock *BB) const {
  auto I = BEGuardMap.find(BB);
  if (I != BEGuardMap.end())
    return I->second;
  return nullptr;
}

BasicBlock *LinearizeCFG::getOrInsertGuardBlock(BasicBlock *BB) {
  assert(BB);

  auto I = GuardMap.find(BB);
  if (I != GuardMap.end())
    return I->second;

  SmallVector<BasicBlock *, 2> Preds(pred_begin(BB), pred_end(BB));

  unsigned OldSize = Func->size();
  BasicBlock *Guard = SplitBlockPredecessors(BB, Preds, ".guard", DT);

  DT->verifyDomTree();

  unsigned NewSize = Func->size();

  assert(NewSize == OldSize + 1);
  assert(Guard && "failed to split block for guard");
  GuardMap[BB] = Guard;
  InvGuardMap[Guard] = BB;

  DT->verifyDomTree();
  return Guard;
}

BasicBlock *LinearizeCFG::getGuardBlock(const BasicBlock *BB) const {
  assert(BB);
  auto I = GuardMap.find(BB);
  return (I != GuardMap.end()) ? I->second : nullptr;
}

Value *LinearizeCFG::insertGuardVar(IRBuilder<> &Builder, BasicBlock *BB) {
  TerminatorInst *TI = BB->getTerminator();
  auto *BI = dyn_cast<BranchInst>(TI);
  if (!BI) {
    if (!isa<ReturnInst>(TI) && !isa<UnreachableInst>(TI))
      report_fatal_error("unsupported terminator type");

    assert(succ_empty(BB));
    return nullptr;
  }

  Value *GuardVal;
  if (BI->isConditional()) {
    Builder.SetInsertPoint(BI);
    GuardVal = Builder.CreateSelect(
      BI->getCondition(),
      Builder.getInt32(getBlockNumber(BI->getSuccessor(0))),
      Builder.getInt32(getBlockNumber(BI->getSuccessor(1))),
      Twine(BB->getName()) + ".succ.id");
  } else {
    GuardVal = Builder.getInt32(getBlockNumber(BI->getSuccessor(0)));
  }

  GuardVarInserter.AddAvailableValue(BB, GuardVal);

  DEBUG(dbgs() << "Setting guard var in " << BB->getName()
        << " = " << *GuardVal << '\n');
  return GuardVal;
}

// Accept the possiblity that a conditioanl branch may already exist.
void LinearizeCFG::addEdge(
  IRBuilder<> &Builder,
  BasicBlock *PrevGuard, BasicBlock *Guard,
  BasicBlock *GuardVarBlock,
  StringRef CmpSuffix) {
  auto *BI = cast<BranchInst>(PrevGuard->getTerminator());

  if (BI->isConditional()) {
    assert(Guard == BI->getSuccessor(0) || Guard == BI->getSuccessor(1));
    return;
  }

  addBrPrevGuardToGuard(Builder, PrevGuard, Guard, GuardVarBlock, CmpSuffix);
}

/// \P GuardVarBlock - The block with the incoming guard value that should be
/// checked. This is usually the same as \p PrevGuard.
void LinearizeCFG::addBrPrevGuardToGuard(
  IRBuilder<> &Builder,
  BasicBlock *PrevGuard, BasicBlock *Guard,
  BasicBlock *GuardVarBlock,
  StringRef CmpSuffix) {
  auto *BI = cast<BranchInst>(PrevGuard->getTerminator());

  DEBUG(dbgs() << "Adding br from " << PrevGuard->getName() << " to "
               << Guard->getName() << '\n');

  assert(BI->isUnconditional());

  Builder.SetInsertPoint(PrevGuard);

  BasicBlock *PrevGuardSucc = BI->getSuccessor(0);
  //assert(PrevGuardSucc != Guard &&
  //"creating conditional branch to same location");

  // The edge may already exist in patterns that look like jumps into one side
  // of a diamond.
  if (PrevGuardSucc == Guard)
    return;

  // The entry block is a special case since we couldn't set the initial guard
  // var val in the predecessors.
  Value *PrevGuardVar = GuardVarBlock == &Func->getEntryBlock() ?
    GuardVarInserter.GetValueAtEndOfBlock(GuardVarBlock) :
    GuardVarInserter.GetValueInMiddleOfBlock(GuardVarBlock);

  ConstantInt *SuccID
    = Builder.getInt32(getBlockNumber(PrevGuardSucc));
  Value *PrevGuardCond = Builder.CreateICmpEQ(PrevGuardVar,
                                              SuccID, CmpSuffix);
  if (PrevGuardCond == BoolTrue)
    return;

#if 0
  // TODO: Should we handle this? It can leave dead blocks around.
  if (PrevGuardCond == BoolFalse) {
    BI->replaceUsesOfWith(PrevGuardSucc, Guard);
    PrevGuard->replaceSuccessorsPhiUsesWith(Guard);

    DominatorTree::UpdateType Updates[2] = {
      { DominatorTree::Delete, PrevGuard, PrevGuardSucc },
      { DominatorTree::Insert, PrevGuard, Guard }
    };

    DT->applyUpdates(Updates);
    DT->verifyDomTree();
    return;
  }


  // XXX - For a canonical CFG this should never happen. Might be worth always
  // doing simplifyCFG so we are sure we never introduce these.
  assert(!isa<Constant>(PrevGuardCond) && "should not happen");
#endif

  BI->eraseFromParent();


  Builder.CreateCondBr(PrevGuardCond, PrevGuardSucc, Guard);
  DT->insertEdge(PrevGuard, Guard);

  addAndUpdatePhis(PrevGuard, Guard);

  DT->verifyDomTree();
}

void LinearizeCFG::removeBranchTo(
  IRBuilder<> &Builder, BasicBlock *BB, BasicBlock *Dest,
  BasicBlock *PhiReplacePred) {
  DEBUG(dbgs() << "Removing branch from: " << BB->getName()
               << " to " << Dest->getName() << '\n');

  assert(std::distance(pred_begin(Dest), pred_end(Dest)) > 1 &&
         "removing branch would make block unreachable");

  auto *BI = cast<BranchInst>(BB->getTerminator());
  assert(BI->isConditional());
  Dest->removePredecessor(BB);

  Builder.SetInsertPoint(BB);
  Builder.CreateBr(getOtherDest(BI, Dest));

  BI->eraseFromParent();

  DT->deleteEdge(BB, Dest);
  DT->verifyDomTree();
}

void LinearizeCFG::numberBlocks() {
  assert(BlockNumbers.empty());
  // FIXME: Do something better

  // TODO: Do in RPO order only for current region
  unsigned BlockNum = 0;
  //for (BasicBlock &BB : ReversePostOrderTraversal<Function *>(Func)) {
  for (BasicBlock &BB : *Func) {
    BlockNumbers[&BB] = BlockNum++;
  }
}

void LinearizeCFG::identifyUnstructuredEdges(
  SmallVectorImpl<BasicBlockEdge> &UnstructuredEdges) {

  std::vector<std::vector<BasicBlock *>> SCCOrdered;


  scc_iterator<Function *> I = scc_begin(Func);
  for (; !I.isAtEnd(); ++I) {
    const std::vector<BasicBlock *> &Nodes = *I;
    SCCOrdered.emplace_back(Nodes.rbegin(), Nodes.rend());
  }

  DEBUG(
    dbgs() << "\nSCC reordered:\n";
    for (const std::vector<BasicBlock *> &SCC : reverse(SCCOrdered)) {
      for (const BasicBlock *BB : SCC) {
        dbgs() << "  BB " << BB->getName() << '\n';
      }
    }
  );

  if (0) {
    DenseMap<BasicBlock *, unsigned> RPONumbers;

    unsigned RPONum = 0;
    for (BasicBlock *BB : ReversePostOrderTraversal<Function *>(Func)) {
      dbgs() << "RPO Num: " << BB->getName() << " = " << RPONum << '\n';
      RPONumbers[BB] = RPONum++;
    }

    for (BasicBlock *BB : ReversePostOrderTraversal<Function *>(Func)) {
      unsigned BBRPO = RPONumbers[BB];

      for (BasicBlock *Succ : successors(BB)) {
        unsigned SuccRPO = RPONumbers[Succ];
        if (SuccRPO > BBRPO) {
          if (!DT->isReachableFromEntry(Succ)) {
            dbgs() << "UNSTRUCTURED FORWARD EDGE: "
                   << BB->getName() << " -> " << Succ->getName() << '\n';
          }

        } else {
          dbgs() << "Back edge: " << BB->getName() << " -> " << Succ->getName() << '\n';
          if (
            !DT->dominates(Succ, BB)) {
            //!DT->dominates(BB, Succ)) {
            dbgs() << "UNSTRUCTURED EDGE: "
                   << BB->getName() << " -> " << Succ->getName() << '\n';

            UnstructuredEdges.push_back(BasicBlockEdge(BB, Succ));
          }
        }
      }
    }
  } else {
    DEBUG(dbgs() << "\n\n\nSCC unstructured detection:\n");
    for (const std::vector<BasicBlock *> &SCC : reverse(SCCOrdered)) {
      for (BasicBlock *BB : SCC) {
        for (BasicBlock *Succ : successors(BB)) {
          BasicBlockEdge Edge(BB, Succ);
          if (isUnstructuredEdge(Edge)) {
            DEBUG(dbgs() << "Type 1 Unstructured edge: "
                  << BB->getName()
                  << " -> "
                  << Succ->getName() << '\n');
            UnstructuredEdges.push_back(Edge);
            continue;
          }

          auto DestSCC = findContainedSCC(SCCOrdered, Edge.getEnd());
          if (!is_contained(SCC, Edge.getEnd()) && // not in same loop
              sccHasLoop(DestSCC) && // bj is in a loop
              !dominatesAllBlocks(DT, DestSCC, Edge.getEnd())) {// bj does not dominate other blocks in loop
            DEBUG(dbgs() << "Type 2 Unstructured edge: "
                  << BB->getName()
                  << " -> "
                  << Succ->getName() << '\n');
            UnstructuredEdges.push_back(Edge);
            continue;
          }

          if (sccHasLoop(SCC) && // Bi is in a loop block
              !is_contained(SCC, Edge.getEnd()) && // Bj not in same loop
              !postdominatesAllBlocks(PDT, SCC, Edge.getStart())) { // Bi does not post dominate other blocks in loop
            DEBUG(dbgs() << "Type 3 Unstructured edge: "
                  << BB->getName()
                  << " -> "
                  << Succ->getName() << '\n');
            UnstructuredEdges.push_back(Edge);
            continue;
          }

        }
      }
    }
  }
}

void LinearizeCFG::pickBlocksToGuard(
  SmallVectorImpl<BasicBlock *> &OrderedUnstructuredBlocks,
  ArrayRef<BasicBlockEdge> UnstructuredEdges) {
  SetVector<BasicBlock *> UnstructuredBlocks;

  // Find the minimum unstructured region.
  for (BasicBlockEdge Edge : UnstructuredEdges) {
    //UnstructuredBlocks.clear();

    // XXX - Remove cidom?
    UnstructuredBlocks.insert(const_cast<BasicBlock *>(Edge.getStart()));
    UnstructuredBlocks.insert(const_cast<BasicBlock *>(Edge.getEnd()));


    BasicBlock *CIDom = DT->findNearestCommonDominator(
      const_cast<BasicBlock *>(Edge.getStart()),
      const_cast<BasicBlock *>(Edge.getEnd()));

    BasicBlock *CIPDom = PDT->findNearestCommonDominator(
      const_cast<BasicBlock *>(Edge.getStart()),
      const_cast<BasicBlock *>(Edge.getEnd()));

#if 1
    if (!CIPDom)
      report_fatal_error("FIXME no CIPDOM");
#endif

    unsigned IterationCount = 0;
    bool Inserted = false;
    do {
      IterationCount++;
      Inserted = false;

      //BasicBlock *CIDom = findCIDOM(UnstructuredBlocks.getArrayRef());
      //BasicBlock *CIPDom = findCIPDOM(UnstructuredBlocks.getArrayRef());

      DEBUG(
        dbgs() << "Found CIDom: " << CIDom->getName() << '\n';
        dbgs() << "Found CIPDom: "
               << (CIPDom ? CIPDom->getName() : "<null>") << '\n';
      );

      //DomTreeNode *CIDomNode = DT->getNode(CIDom)->getIDom();

      /*
        if (UnstructuredBlocks.count(CIPDom)) {
        DomTreeNode *CIPDomNode = PDT->getNode(CIPDom)->getIDom();

        auto Tmp = CIPDomNode->getBlock();
        if (Tmp)
        CIPDom = Tmp;
        }
      */

      //assert(CIDomNode);
      //assert(CIPDomNode);


#if 1
      if (!CIPDom)
        report_fatal_error("FIXME no CIPDOM");
#endif

      SmallVector<BasicBlock *, 8> CIDomBlocks;
      SmallVector<BasicBlock *, 8> CIPDomBlocks;
      DT->getDescendants(CIDom, CIDomBlocks);
      PDT->getDescendants(CIPDom, CIPDomBlocks);

      // Blocks dominated by CIDom && can reach cipdom
      // union
      // blocks post dom by CIPDom && reachable from cidom

      DEBUG(
        dbgs() << "CIDomblocks:\n";
        for (BasicBlock *BB : CIDomBlocks) {
          dbgs() << "  " << BB->getName() << '\n';
        }

        dbgs() << "CIPDomBlocks\n";
        for (BasicBlock *BB : CIPDomBlocks) {
          dbgs() << "  " << BB->getName() << '\n';
        }
      );

      for (BasicBlock *BB : CIDomBlocks) {
        //if (BB == CIPDom || BB == CIDom)
        if (BB == CIDom)
          continue;

        bool IsReach0 = isPotentiallyReachable(BB, CIPDom, DT);
        DEBUG(dbgs() << "CIPDom Reachable: " << BB->getName() << " -> " << CIPDom->getName() << ": " << IsReach0 << '\n');

        if (IsReach0) {
          if (UnstructuredBlocks.insert(BB)) {
            Inserted = true;

            CIDom = DT->findNearestCommonDominator(CIDom, BB);
            CIPDom = PDT->findNearestCommonDominator(CIPDom, BB);
          }
        }
      }

      for (BasicBlock *BB : CIPDomBlocks) {
        //if (BB == CIPDom || BB == CIDom)
        if (BB == CIPDom)
          continue;

        bool IsReach1 = isPotentiallyReachable(CIDom, BB, DT);
        DEBUG(dbgs() << "CIDom Reaches: " << CIDom->getName() << " -> " << BB->getName() << ": " << IsReach1 << '\n');
        if (isPotentiallyReachable(CIDom, BB, DT)) {
          if (UnstructuredBlocks.insert(BB)) {
            Inserted = true;

            CIDom = DT->findNearestCommonDominator(CIDom, BB);
            CIPDom = PDT->findNearestCommonDominator(CIPDom, BB);
          }
        }
      }

    } while (Inserted);


    //UnstructuredBlocks.insert(CIPDom);
  }


  for (BasicBlock *BB : ReversePostOrderTraversal<Function *>(Func)) {
    if (UnstructuredBlocks.count(BB))
      OrderedUnstructuredBlocks.push_back(BB);
  }
}

void LinearizeCFG::pruneExtraEdge(IRBuilder<> &Builder,
                                  ArrayRef<BasicBlock *> OrderedUnstructuredBlocks,
                                  BasicBlock *Guard, BasicBlock *PrevBlock,
                                  BasicBlock *PrevGuard) {
  bool MadeChange = false;

  redo:
  MadeChange = false;

  for (BasicBlock *GuardPred : predecessors(Guard)) {
    if (GuardPred != PrevBlock && GuardPred != PrevGuard &&
        (is_contained(OrderedUnstructuredBlocks, GuardPred) ||
         isGuardBlock(GuardPred))) {
      DEBUG(dbgs() << "Prune extra edge: " << GuardPred->getName()
            << " -> " << Guard->getName() << '\n');

      auto *PredBI = cast<BranchInst>(GuardPred->getTerminator());
      if (PredBI->isConditional()) {
        removeBranchTo(Builder, GuardPred, Guard);
        MadeChange = true;
      } else {
        // In simple cases the guard branch condition was trivial, so the
        // extra edge was eliminated
      }

      break;
    }
  }

  if (MadeChange)
    goto redo;
}

void LinearizeCFG::linearizeBlocks(ArrayRef<BasicBlock *> OrderedUnstructuredBlocks) {
  assert(!OrderedUnstructuredBlocks.empty());
  numberBlocks();


  IRBuilder<> Builder(Func->getContext());

  // FIXME: For some reason this is dependent on the order and is
  // non-deterministic with set iteration.
  BasicBlock *CIDom = findCIDOM(OrderedUnstructuredBlocks);
  BasicBlock *CIPDom = findCIPDOM(OrderedUnstructuredBlocks);

  DEBUG(dbgs() <<  "CIDOM: " << CIDom->getName()
                << "  CIPDOM: " << CIPDom->getName() << '\n');

  DEBUG(
    dbgs() << "Before modify DT\n";
    DT->print(dbgs());
  );

  if (!CIPDom) {
    report_fatal_error("No CIPDOM");
  }


  /*
  if (UnstructuredBlocks.count(CIDom)) {
    // Get post dominator outside of the set.
    // XXX - Is this correct?
    if (auto C = DT->getNode(CIDom)->getIDom()) {
      CIDom = C->getBlock();
    } else {
#if 1
      BasicBlock *DummyIDom
        = BasicBlock::Create(Func->getContext(),
                             "dummy.idom",
                             Func, CIDom);

      // FIXME: Update predecessor phis
      BranchInst::Create(CIDom, DummyIDom);

      if (DT->getRoot() == CIDom) {
        DT->setNewRoot(DummyIDom);
      } else {
        DT->insertEdge(DummyIDom, CIDom);
      }

      // Make sure the right vale of the initial guard variable is still valid
      // after splitting.
      //GuardVarInserter.AddAvailableValue(DummyIDom, InitialBlockNumber);
      PDT->insertEdge(DummyIDom, CIDom);
#endif

      // XXX - PDT not updated
      //BasicBlock *OldCIDom = SplitBlock(CIDom, &*CIDom->begin(), DT);

      //PDT->insertEdge();
    }
  }
  DT->verifyDomTree();

  if (is_contained(OrderedUnstructuredBlocks, CIPDom)) {
    // Get post dominator outside of the set.
    // XXX - Is this correct?
    BasicBlock *IDom = PDT->getNode(CIPDom)->getIDom()->getBlock();
    if (IDom)
      CIPDom = IDom;
    else {
      unsigned BlockNum = getBlockNumber(CIPDom);
      CIPDom = SplitBlock(CIPDom, CIPDom->getTerminator(), DT);
      BlockNumbers[CIPDom] = BlockNum;
    }
  }

  */

  // TODO: Make this type target dependent.
  GuardVarInserter.Initialize(Builder.getInt32Ty(), "guard.var");

  // The incoming guard ID is ID of the first block in the region. The compare
  // against it will trivially fold away.
  ConstantInt *InitialBlockNumber =
    Builder.getInt32(getBlockNumber(OrderedUnstructuredBlocks.front()));


  BasicBlock *FirstBlock = OrderedUnstructuredBlocks.front();
  //for (BasicBlock *Pred : predecessors(FirstBlock)) {
  for (BasicBlock *Pred : predecessors(CIDom)) {
    GuardVarInserter.AddAvailableValue(Pred, InitialBlockNumber);
  }

  GuardVarInserter.AddAvailableValue(CIDom, InitialBlockNumber);



  DenseMap<BasicBlock *, unsigned> RPONumbers;


  {
    unsigned RPONum = 0;
    for (BasicBlock *BB : ReversePostOrderTraversal<Function *>(Func)) {
      RPONumbers[BB] = RPONum++;
    }
  }

  // FIXME: Hacky
  /*
  if (BasicBlock *Guard = getGuardBlock(CIDom)) {
    assert(DT->getNode(CIDom)->getIDom()->getBlock() == Guard);
    CIDom = Guard;
  }
  */

  //bool First = true;
  bool First = false;

  for (BasicBlock *BB : OrderedUnstructuredBlocks) {
    DT->verifyDomTree();

    unsigned BBRPONum = RPONumbers[BB];

    if (First) {
      // Don't bother inserting a guard block for the entry point. The guard
      // variable will trivially be the first block, and we'll just leave behind
      // a branch on a phi of the same value.
      First = false;
    } else {
      BasicBlock *Guard = getOrInsertGuardBlock(BB);
      assert(Guard && "failed to split block");
      GuardMap[BB] = Guard;
      InvGuardMap[Guard] = BB;
      RPONumbers[Guard] = BBRPONum; // XXX
    }


    for (BasicBlock *Succ : successors(BB)) {
      unsigned SuccRPO = RPONumbers[Succ];
      if (SuccRPO <= BBRPONum) {
        BasicBlock *BackEdgeDest = Succ;

        unsigned OldSize = Func->size();
        BasicBlock *BEGuard = SplitEdge(BB, BackEdgeDest, DT);
        assert(Func->size() == OldSize + 1);
        assert(BEGuard);

        BlockNumbers[BEGuard] = getBlockNumber(BB); // ???
        BEGuardMap[BB] = BEGuard;
        InvBEGuardMap[BEGuard] = BB;
      }
    }
  }

  // Deal with the inconvenience of entry blocks with no predecessors. In some
  // cases we will end up treating the entry block as a trivially guarded block.
  GuardVarInserter.AddAvailableValue(getGuardBlock(CIDom), InitialBlockNumber);


  //rebuildSSA(); // XXX Is this necessary here

  BasicBlock *PrevGuard = nullptr;
  BasicBlock *PrevBlock = nullptr;

  // FIXME: There's no real reason these need to be separate loops.
  for (auto I = OrderedUnstructuredBlocks.begin(), E = OrderedUnstructuredBlocks.end();
       I != E;) {
    DT->verifyDomTree();
    BasicBlock *BB = *I;

    // If we have a backedge guard, the successor ID is logically determined by
    // it so define the guard there.
    BasicBlock *BEGuard = getBEGuardBlock(BB);

    Value *GuardVar = insertGuardVar(Builder, BB);

    ++I;

    bool Last = I == E;
    BasicBlock *Guard = getGuardBlock(BB);

    DEBUG(dbgs() << "\n\nVisit block: " << BB->getName() << '\n');
    assert(verifyBlockPhis(Guard));


    // idom->guard already inserted by split
    if (PrevGuard) {
      addBrPrevGuardToGuard(Builder, PrevGuard, Guard, PrevGuard,
                            "prev.guard");
    }

    if (PrevBlock) {
      // prevBlock->guard usually already exists. It won't if an earlier block
      // branched to 2 other instructured blocks (e.g. both sides of a diamond
      // if there was a jump into it).
      auto *PrevBlockBI = dyn_cast<BranchInst>(PrevBlock->getTerminator());

      if (PrevBlockBI && PrevBlockBI->isUnconditional()) {
        BasicBlock *OldSucc = PrevBlockBI->getSuccessor(0);

        if (OldSucc != Guard && isGuardBlock(OldSucc)) {
          assert(verifyBlockPhis(Guard));

#if 1
          for (PHINode &P : OldSucc->phis()) {
            int Idx = P.getBasicBlockIndex(PrevBlock);
            P.setIncomingBlock(Idx, Guard);
          }
#endif
          //OldSucc->removePredecessor(PrevBlock);

          //DEBUG(dbgs() << "Remap phi update\n");
          //addAndUpdatePhis(PrevBlock, Guard);

          PrevBlockBI->replaceUsesOfWith(OldSucc, Guard);

          assert(!pred_empty(OldSucc));

          DominatorTree::UpdateType Updates[2] = {
            { DominatorTree::Delete, PrevBlock, OldSucc },
            { DominatorTree::Insert, PrevBlock, Guard }
          };

          DT->applyUpdates(Updates);
        }

        DT->verifyDomTree();
      }
    }

    BasicBlock *BEDest = nullptr;
    if (BEGuard) {
      BranchInst *BI = cast<BranchInst>(BEGuard->getTerminator());
      assert(BI->isUnconditional());
      BEDest = BI->getSuccessor(0);
    }

    if (Last) {
      // Compared to the pseudo-code in the paper, we pre-created all of the
      // guard blocks, so at this point logically BEGuard is part of the block.
      addEdge(Builder, BEGuard ? BEGuard : Guard, CIPDom,
              Guard, "last");
      DT->verifyDomTree();
    }

    //if (PrevBlock) {
      pruneExtraEdge(Builder, OrderedUnstructuredBlocks,
                     Guard, PrevBlock, PrevGuard);
      //}

    PrevGuard = Guard;
    PrevBlock = BB;

    if (BEGuard) {
      addBrPrevGuardToGuard(Builder, Guard, BEGuard, Guard,
                            "be.guard");

      PrevGuard = BEGuard;
      PrevBlock = nullptr;
    }
  }

  // Typically the first guard block ends up being trivial with the same
  // incoming guard variable phi from every successor. It may not if there is a
  // back edge. to the first block.
  BasicBlock *FirstGuarded = OrderedUnstructuredBlocks.front();
  BasicBlock *FirstGuard = getGuardBlock(FirstGuarded);
  for (auto &P : FirstGuard->phis()) {
    if (recursivelySimplifyInstruction(&P, nullptr, DT)) {
      DeferredDominance DDT(*DT);
      ConstantFoldTerminator(FirstGuard, true, nullptr, &DDT);
      DDT.flush();
      break;
    }
  }

  DT->verifyDomTree();

#if 0
  // Keep trying to clean up junk checks at region entry.
  // FIXME: It might be better to just try this on every block.
  if (BasicBlock *Succ = FirstGuarded->getSingleSuccessor())
    MergeBlockIntoPredecessor(Succ, DT);
#endif

  SmallString<16> OldName = FirstGuard->getName();
  FirstGuard->setName("");
  if (!MergeBlockIntoPredecessor(FirstGuarded, DT)) {
    FirstGuard->setName(OldName);
  }
}

// FIXME: Broken with backedges
// Check the invariant that every guarded block has exactly one guard block
// predecessor and successor.
bool LinearizeCFG::verifyGuardedBlockEdges(ArrayRef<BasicBlock *> Blocks) const {
  bool LeftoverEdge = false;
  const BasicBlock *PrevBlock = nullptr;
  for (const BasicBlock *BB : Blocks) {
    const BasicBlock *Guard = getGuardBlock(BB);
    if (!Guard || BB->getSinglePredecessor() != Guard) {
      DEBUG(dbgs() << "Incorrect predecessors for " << BB->getName() << '\n');
      LeftoverEdge = true;
      continue;
    }

    if (PrevBlock) {
      const BasicBlock *BEGuard = getBEGuardBlock(BB);


      if ((BEGuard && PrevBlock->getSingleSuccessor() != BEGuard) ||
          PrevBlock->getSingleSuccessor() != Guard) {
        DEBUG(dbgs() << "Incorrect successors for "
              << PrevBlock->getName() << '\n');
        LeftoverEdge = true;
        continue;
      }
    }

    PrevBlock = BB;
  }

  return !LeftoverEdge;
}

void LinearizeCFG::releaseMemory() {
  GuardMap.clear();
  InvGuardMap.clear();
  BEGuardMap.clear();
  InvBEGuardMap.clear();
  BlockNumbers.clear();
}

bool LinearizeCFG::runOnFunction(Function &F) {
  UnreachableBlock = nullptr;
  Func = &F;

  assert(GuardMap.empty());
  assert(BEGuardMap.empty());
  assert(InvGuardMap.empty());
  assert(InvBEGuardMap.empty());
  assert(BlockNumbers.empty());

  DT = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  PDT = &getAnalysis<PostDominatorTreeWrapperPass>().getPostDomTree();
  //LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
  TTI = &getAnalysis<TargetTransformInfoWrapperPass>().getTTI(F);

  auto DF = &getAnalysis<DominanceFrontierWrapperPass>().getDominanceFrontier();


  DEBUG(
    printSCCFunc(F);
    dbgs() << "\n\n\n\n";
    printInverseSCCFunc(F, *PDT);
    dbgs() << "\n\n\n\n";
    printRPOFunc(F);
    dbgs() << "\n\n";
  );


  for (BasicBlock &BB : *Func) {
    if (BB.isEHPad() || BB.hasAddressTaken()) {
      DEBUG(dbgs() << "Can't handle this function\n");
      return false;
    }


  }

#if 0
  if (true) {
    BasicBlock *CIDom = &Func->getEntryBlock();
    BasicBlock *DummyIDom
      = BasicBlock::Create(Func->getContext(),
                           "dummy.idom",
                           Func, CIDom);

    // FIXME: Update predecessor phis
    BranchInst::Create(CIDom, DummyIDom);

    if (DT->getRoot() == CIDom) {
      DT->setNewRoot(DummyIDom);
    } else {
      DT->insertEdge(DummyIDom, CIDom);
    }

    // Make sure the right vale of the initial guard variable is still valid
    // after splitting.
    //GuardVarInserter.AddAvailableValue(DummyIDom, InitialBlockNumber);
    PDT->insertEdge(DummyIDom, CIDom);
    CIDom = DummyIDom;
  }
#endif

  RegionInfo RI;
  RI.recalculate(F, DT, PDT, DF);

  Region &R = *RI.getTopLevelRegion();

#if 0
  ReversePostOrderTraversal<Region *> RPOT(&R);
  dbgs() << "Regions:\n";
  for (RegionNode *N : RPOT) {
    dbgs() << *N << '\n';
  }


  for (auto &X : R) {


  }
#endif

  /*
  SetVector<BasicBlock *> SV;

  dbgs() << "Region check\n";
  unsigned UnstructCount = 0;
  for (BasicBlock *BB : ReversePostOrderTraversal<Function *>(Func)) {
    Region *BR = RI.getRegionFor(BB);
    BasicBlock *Entry = BR->getEnteringBlock();
    if (Entry)
      dbgs() << "  " << Entry->getName() << '\n';
    else
      dbgs() << " null \n";



    SV.insert(Entry);
    if (BR == RI.getTopLevelRegion()) {
      ++UnstructCount;
      SV.insert(BB);
    }
    BR->dump();
  }
  dbgs() << "End region check: " << UnstructCount << '\n';
  */




  if (SkipUniformRegions)
    DA = &getAnalysis<DivergenceAnalysis>();

  if (SkipUniformRegions) {
#if 0
    // TODO: We could probably be smarter here with how we handle sub-regions.
    if (hasOnlyUniformBranches(R, *DA)) {
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

  SmallVector<BasicBlockEdge, 8> UnstructuredEdges;
  identifyUnstructuredEdges(UnstructuredEdges);


  DEBUG(dbgs() << "Found " << UnstructuredEdges.size()
               << " unstructured edges\n");


  DEBUG(
    for (BasicBlockEdge EE : UnstructuredEdges) {
      dbgs() << ": " << EE.getStart()->getName() << " -> " << EE.getEnd()->getName() << '\n';
    }
  );


  SmallVector<BasicBlock *, 8> OrderedUnstructuredBlocks;

  //DenseSet<BasicBlock *> UnstructuredBlocks;
  //SetVector<BasicBlock *> UnstructuredBlocks;
  if (LinearizeWholeFunction) {
    // Process the entire function.
    for (BasicBlock *BB : ReversePostOrderTraversal<Function *>(Func)) {
      OrderedUnstructuredBlocks.push_back(BB);
    }
  } else {
    pickBlocksToGuard(OrderedUnstructuredBlocks, UnstructuredEdges);
    DEBUG(
      dbgs() << "Unstructured blocks:\n";
      for (BasicBlock *BB : OrderedUnstructuredBlocks) {
        dbgs() << "  " << BB->getName() << '\n';
      }
      );
  }



  // TODO: Identify structured subregions
  /*
  DenseSet<BasicBlock *> SubStructured;
  for (BasicBlock *BB : UnstructuredBlocks) {
    bool IsStructuredRegion = false;
    BasicBlock *IPDom = PDT->getNode(BB)->getIDom()->getBlock();
    //BasicBlock *IDom = DT->getNode(BB)->getIDom()->getBlock();

    if (BB == DT->getNode(BB)->getIDom(IPDom)->getBlock()) {

    }


    if (hasUnstructuredEdge(UnstructuredEdges, BB)) {

    }
  }
  */

  //UnstructuredBlocks.insert(BB6);

  if (OrderedUnstructuredBlocks.empty()) {
    DEBUG(dbgs() << "No unstructured blocks\n");
    return false;
  }


  linearizeBlocks(OrderedUnstructuredBlocks);
  rebuildSSA();

  //assert(verifyGuardedBlockEdges(OrderedUnstructuredBlocks));

  return true;
}

namespace llvm {
Pass *createLinearizeCFGPass(bool SkipUniformRegions);
}

Pass *llvm::createLinearizeCFGPass(bool SkipUniformRegions) {
  return new LinearizeCFG(SkipUniformRegions);
}
