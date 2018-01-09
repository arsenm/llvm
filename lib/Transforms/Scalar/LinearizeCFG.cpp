//===- StructurizeCFG.cpp -------------------------------------------------===//
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
// next block's guard.
//
// Each guard block checks the incoming successor ID, and enters the guarded
// block if the ID matches.
//
// An additional guard is introduced for back edges.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/MapVector.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/Analysis/CFG.h"
#include "llvm/Analysis/DivergenceAnalysis.h"
#include "llvm/Analysis/DominanceFrontier.h"
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
class LinearizeCFG : public FunctionPass {
  const TargetTransformInfo *TTI = nullptr;
  DivergenceAnalysis *DA = nullptr;
  bool SkipUniformRegions;

  Type *Boolean;
  ConstantInt *BoolTrue;
  ConstantInt *BoolFalse;
  UndefValue *BoolUndef;

  Function *Func;
  BasicBlock *UnreachableBlock;

  DominatorTree *DT;
  PostDominatorTree *PDT;
  SSAUpdater GuardVarInserter;

  DenseMap<BasicBlock *, BasicBlock *> GuardMap;
  DenseMap<BasicBlock *, BasicBlock *> InvGuardMap;
  DenseMap<BasicBlock *, BasicBlock *> BEGuardMap;
  DenseMap<BasicBlock *, unsigned> BlockNumbers;

  BasicBlock *getBEGuardBlock(BasicBlock *BB) const;
  BasicBlock *getGuardBlock(BasicBlock *BB);
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

  void addBrPrevGuardToGuard(
    IRBuilder<> &Builder,
    BasicBlock *PrevGuard, BasicBlock *Guard,
    StringRef CmpSuffix = "prevbb.cmp");
  void removeBranchTo(
    IRBuilder<> &Builder, BasicBlock *BB, BasicBlock *Dest,
    BasicBlock *PhiReplacePred = nullptr);

  void numberBlocks();

  bool isEffectivelyUnconditional(const BranchInst *BI) const;

  void linearizeBlocks(ArrayRef<BasicBlock *> OrderedUnstructuredBlocks,
                       BasicBlock *CIPDom);

  void releaseMemory() override;
  bool runOnFunction(Function &F) override;

  StringRef getPassName() const override {
    return "Structurize control flow";
  }

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
    if (Phi.getNumIncomingValues() != NumPreds)
      return false;
  }

  return true;
}

static bool hasMultipleSuccessors(const BasicBlock *BB) {
  return !BB->getSingleSuccessor() && !succ_empty(BB);
}

static bool hasMultiplePredecessors(const BasicBlock *BB) {
  return !BB->getSinglePredecessor() && !pred_empty(BB);
}

bool LinearizeCFG::isUnstructuredEdge(BasicBlockEdge Edge) const {
  // An edge from block Bi to Bj is said to be unstructured if any of the
  // following three conditions is satisfied:

  //  Block Bi has multiple successors, block Bj has multiple predecessors, and
  //  neither of Bi or Bj dominates nor postdominates the other,
  if (hasMultipleSuccessors(Edge.getStart()) &&
      hasMultiplePredecessors(Edge.getEnd()) &&
      !DT->dominates(Edge.getStart(), Edge.getEnd()) &&
      !DT->dominates(Edge.getEnd(), Edge.getStart()) &&
      !PDT->dominates(Edge.getStart(), Edge.getEnd()) &&
      !PDT->dominates(Edge.getEnd(), Edge.getStart())) {
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
  NearestCommonDominator<PostDominatorTree> NCD(PDT);
  for (BasicBlock *BB : Set)
    NCD.addAndRememberBlock(BB);
  return NCD.result();
}

BasicBlock *LinearizeCFG::findCIPDOM(const DenseSet<BasicBlock *> &Set) const {
  NearestCommonDominator<PostDominatorTree> NCD(PDT);
  for (BasicBlock *BB : Set)
    NCD.addAndRememberBlock(BB);
  return NCD.result();
}

char LinearizeCFG::ID = 0;

INITIALIZE_PASS_BEGIN(LinearizeCFG, "linearize-cfg", "Structurize the CFG with linearization",
                      false, false)
INITIALIZE_PASS_DEPENDENCY(DivergenceAnalysis)
INITIALIZE_PASS_DEPENDENCY(LowerSwitch)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(PostDominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(DominanceFrontierWrapperPass)
INITIALIZE_PASS_END(LinearizeCFG, "linearize-cfg", "Structurize the CFG with linearization",
                    false, false)

/// \brief Initialize the types and constants used in the pass
bool LinearizeCFG::doInitialization(Module &M) {
  LLVMContext &Context = M.getContext();

  Boolean = Type::getInt1Ty(Context);
  BoolTrue = ConstantInt::getTrue(Context);
  BoolFalse = ConstantInt::getFalse(Context);
  BoolUndef = UndefValue::get(Boolean);

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
  if (UnreachableBlock) {
    UnreachableBlock = BasicBlock::Create(Func->getContext(),
                                          "structurizecfg.unreachable", Func);
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

  assert(Succ0 != Succ1 && "FIXME: Handle this case");
  return (Succ0 == BB) ? Succ1 : Succ0;
}

static unsigned getOtherDestIndex(BranchInst *BI, BasicBlock *BB) {
  BasicBlock *Succ0 = BI->getSuccessor(0);
  BasicBlock *Succ1 = BI->getSuccessor(1);

  assert(Succ0 != Succ1 && "FIXME: Handle this case");
  return (Succ0 == BB) ? 1 : 0;
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
    P.addIncoming(NewVal, PrevGuard);

    DEBUG(dbgs() << "  Add incoming value from " << PrevGuard->getName()
                 << ": " << *NewVal << '\n');
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

BasicBlock *LinearizeCFG::getBEGuardBlock(BasicBlock *BB) const {
  auto I = BEGuardMap.find(BB);
  if (I != BEGuardMap.end())
    return I->second;
  return nullptr;
}

BasicBlock *LinearizeCFG::getGuardBlock(BasicBlock *BB) {
  assert(BB);

  auto I = GuardMap.find(BB);
  if (I != GuardMap.end())
    return I->second;

  SmallVector<BasicBlock *, 2> Preds(pred_begin(BB), pred_end(BB));
  BasicBlock *Guard = SplitBlockPredecessors(BB, Preds, ".guard", DT);
  assert(Guard && "failed to split block for guard");
  GuardMap[BB] = Guard;
  InvGuardMap[Guard] = BB;
  return Guard;
}

Value *LinearizeCFG::insertGuardVar(IRBuilder<> &Builder, BasicBlock *BB) {
  auto *BI = dyn_cast<BranchInst>(BB->getTerminator());
  if (!BI) {
    assert(succ_empty(BB));
    return nullptr;
  }

  Value *GuardVal;
  if (BI->isConditional()) {
    Builder.SetInsertPoint(BI);
    GuardVal = Builder.CreateSelect(
      BI->getCondition(),
      Builder.getInt32(getBlockNumber(BI->getSuccessor(0))),
      Builder.getInt32(getBlockNumber(BI->getSuccessor(1))));
  } else {
    GuardVal = Builder.getInt32(getBlockNumber(BI->getSuccessor(0)));
  }

  GuardVarInserter.AddAvailableValue(BB, GuardVal);

  DEBUG(dbgs() << "Setting guard var in " << BB->getName()
        << " = " << *GuardVal << '\n');
  return GuardVal;
}

void LinearizeCFG::addBrPrevGuardToGuard(
  IRBuilder<> &Builder,
  BasicBlock *PrevGuard, BasicBlock *Guard,
  StringRef CmpSuffix) {
  auto *BI = cast<BranchInst>(PrevGuard->getTerminator());

  DEBUG(dbgs() << "Adding br from " << PrevGuard->getName() << " to "
               << Guard->getName() << '\n');

  if (BI->isConditional()) {
    assert(Guard == BI->getSuccessor(0) || Guard == BI->getSuccessor(1));
    return;
  }

  assert(BI->isUnconditional());

  Builder.SetInsertPoint(PrevGuard);

  BasicBlock *PrevGuardSucc = BI->getSuccessor(0);
  //assert(PrevGuardSucc != Guard &&
  //"creating conditional branch to same location");

  // The edge may already exist in patterns that look like jumps into one side
  // of a diamond.
  if (PrevGuardSucc == Guard)
    return;

  Value *PrevGuardVar = GuardVarInserter.GetValueInMiddleOfBlock(PrevGuard);
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
  // FIXME: Do something better

  // TODO: Do in RPO order only for current region
  unsigned BlockNum = 0;
  //for (BasicBlock &BB : ReversePostOrderTraversal<Function *>(Func)) {
  for (BasicBlock &BB : *Func) {
    BlockNumbers[&BB] = BlockNum++;
  }
}

bool LinearizeCFG::isEffectivelyUnconditional(const BranchInst *BI) const {
  //return BI->isUnconditional() || BI->getCondition() == BoolTrue;
  return BI->isUnconditional();
}

void LinearizeCFG::linearizeBlocks(ArrayRef<BasicBlock *> OrderedUnstructuredBlocks,
                                   BasicBlock *CIPDom) {
  IRBuilder<> Builder(Func->getContext());
  // TODO: Make this type target dependent.
  GuardVarInserter.Initialize(Builder.getInt32Ty(), "guard.var");

  DenseSet<BasicBlock *> Visited;

  struct ExtraEdge {
    BasicBlock *BB;
    unsigned SuccNum;
  };

  SmallVector<ExtraEdge, 8> ExtraEdges;

  // The incoming guard ID is ID of the first block in the region. The compare
  // against it will trivially fold away.
  ConstantInt *InitialBlockNumber =
    Builder.getInt32(getBlockNumber(OrderedUnstructuredBlocks.front()));

  for (BasicBlock *Pred : predecessors(OrderedUnstructuredBlocks.front()))
    GuardVarInserter.AddAvailableValue(Pred, InitialBlockNumber);

  for (BasicBlock *BB : OrderedUnstructuredBlocks) {
    SmallVector<BasicBlock *, 2> Preds(pred_begin(BB), pred_end(BB));
    BasicBlock *Guard = SplitBlockPredecessors(BB, Preds, ".guard", DT);
    assert(Guard && "failed to split block");
    GuardMap[BB] = Guard;
    InvGuardMap[Guard] = BB;

    Visited.insert(BB);
    Visited.insert(Guard);

    for (BasicBlock *Succ : successors(BB)) {
      if (Visited.count(Succ)) {
        BasicBlock *BackEdgeDest = Succ;

        BasicBlock *BEGuard = SplitEdge(BB, BackEdgeDest, DT);
        assert(BEGuard);

        BlockNumbers[BEGuard] = getBlockNumber(BB); // ???
        BEGuardMap[BB] = BEGuard;
        Visited.insert(BEGuard); // ???
      }
    }
  }

  Visited.clear();
  rebuildSSA(); // XXX Is this necessary here

  BasicBlock *PrevGuard = nullptr;
  BasicBlock *PrevBlock = nullptr;

  auto hasTwoGuardedSuccessors = [this](const BasicBlock *BB) -> bool {
    unsigned SuccCount = 0;
    for (const BasicBlock *Succ : successors(BB)) {
      //if (!UnstructuredBlocks.count(Succ))
      //return false;
      if (!InvGuardMap.count(Succ))
        return false;
      ++SuccCount;
    }

    return SuccCount == 2;
  };

  // FIXME: There's no real reason these need to be separate loops.
  for (auto I = OrderedUnstructuredBlocks.begin(), E = OrderedUnstructuredBlocks.end();
       I != E;) {
    DT->verifyDomTree();
    BasicBlock *BB = *I;
    insertGuardVar(Builder, BB);

    ++I;

    bool Last = I == E;

    BasicBlock *Guard = getGuardBlock(BB);

    // idom->guard already inserted by split
    if (PrevGuard) {
      addBrPrevGuardToGuard(Builder, PrevGuard, Guard, "prev.guard");
    }

    if (PrevBlock) {
      // prevBlock->guard usually already exists. It won't if an earlier block
      // branched to 2 other instructured blocks (e.g. both sides of a diamond
      // if there was a jump into it).
      auto *PrevBlockBI = dyn_cast<BranchInst>(PrevBlock->getTerminator());

      if (PrevBlockBI && PrevBlockBI->isUnconditional()) {
        BasicBlock *OldSucc = PrevBlockBI->getSuccessor(0);

        if (OldSucc != Guard) {
          assert(verifyBlockPhis(Guard));

          OldSucc->removePredecessor(PrevBlock);

          PrevBlockBI->replaceUsesOfWith(OldSucc, Guard);

          DEBUG(dbgs() << "Remap phi update\n");
          addAndUpdatePhis(PrevBlock, Guard);

          DominatorTree::UpdateType Updates[2] = {
            { DominatorTree::Delete, PrevBlock, OldSucc },
            { DominatorTree::Insert, PrevBlock, Guard }
          };

          DT->applyUpdates(Updates);
        }
      }
    }

    if (hasTwoGuardedSuccessors(BB)) {
      BasicBlock *NextBlock = Last ? nullptr : *I;
      BasicBlock *NextGuard = getGuardBlock(NextBlock);

      BranchInst *BI = cast<BranchInst>(BB->getTerminator());

      ExtraEdge EE;

      EE.BB = BB;
      EE.SuccNum = getOtherDestIndex(BI, NextGuard);

      ExtraEdges.push_back(EE);
    }


    BasicBlock *BEGuard = getBEGuardBlock(BB);

    if (Last) {
      addBrPrevGuardToGuard(Builder, Guard, CIPDom, "last");
    }

    PrevGuard = Guard;
    PrevBlock = BB;

    if (BEGuard) {
      BranchInst *BI = cast<BranchInst>(BEGuard->getTerminator());
      assert(BI->isUnconditional());
      BasicBlock *BEDest = BI->getSuccessor(0);

      BasicBlock *ExtraSplit = nullptr;
      if (std::distance(succ_begin(Guard), succ_end(Guard)) == 2) {
        ExtraSplit = SplitEdge(Guard, BB, DT);
        assert(ExtraSplit);
        BlockNumbers[ExtraSplit] = getBlockNumber(BB);

        // FIXME: Can eliminate the second compare in the split block.
        addBrPrevGuardToGuard(Builder, BB, BEGuard, "be.guard");
      } else {
        addBrPrevGuardToGuard(Builder, Guard, BEGuard, "be.guard");
      }

      PrevGuard = BEGuard;
      PrevBlock = nullptr;
    }
  }

  DEBUG(
    dbgs() << "Recorded extra edges:\n";
    for (ExtraEdge EE : ExtraEdges) {
      dbgs() << "  " << EE.BB->getName() << " succ " << EE.SuccNum << '\n';
    }
  );

  // FIXME: Should be able to prune these edges during the main loop.
  if (1) {
    // Cleanup extra edges. A guarded block should only ever end in an
    // unconditional branch to the next guard block.

    for (ExtraEdge EE : ExtraEdges) {
      BranchInst *BI = cast<BranchInst>(EE.BB->getTerminator());
      removeBranchTo(Builder, EE.BB, BI->getSuccessor(EE.SuccNum));
    };
  }

  DT->verifyDomTree();

}

void LinearizeCFG::releaseMemory() {
  GuardMap.clear();
  InvGuardMap.clear();
  BEGuardMap.clear();
}

bool LinearizeCFG::runOnFunction(Function &F) {
  UnreachableBlock = nullptr;
  Func = &F;

  assert(GuardMap.empty());
  assert(BEGuardMap.empty());
  assert(InvGuardMap.empty());

  DT = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  PDT = &getAnalysis<PostDominatorTreeWrapperPass>().getPostDomTree();
  //LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
  TTI = &getAnalysis<TargetTransformInfoWrapperPass>().getTTI(F);

  auto DF = &getAnalysis<DominanceFrontierWrapperPass>().getDominanceFrontier();


  findUnstructuredEdges();

  DEBUG(
    printSCCFunc(F);
    dbgs() << "\n\n\n\n";
    printInverseSCCFunc(F, *PDT);
    dbgs() << "\n\n\n\n";
    printRPOFunc(F);
    dbgs() << "\n\n";
  );

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

  numberBlocks();

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

  SmallVector<BasicBlockEdge, 8> UnstructuredEdges;
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

  DEBUG(dbgs() << "Found " << UnstructuredEdges.size()
               << " unstructured edges\n");

  DenseSet<BasicBlock *> UnstructuredBlocks;
  if (LinearizeWholeFunction) {
    // Process the entire function.
    for (BasicBlock &BB : *Func)
      UnstructuredBlocks.insert(&BB);
  } else {

    // Find the minimum unstructured region.
    for (BasicBlockEdge Edge : UnstructuredEdges) {
      UnstructuredBlocks.insert(const_cast<BasicBlock *>(Edge.getStart()));
      UnstructuredBlocks.insert(const_cast<BasicBlock *>(Edge.getEnd()));

      bool Inserted = false;

      do {
        Inserted = false;
        BasicBlock *CIDom = findCIDOM(UnstructuredBlocks);
        BasicBlock *CIPDom = findCIPDOM(UnstructuredBlocks);

        if (!CIPDom)
          report_fatal_error("FIXME no CIPDOM");

        SmallVector<BasicBlock *, 8> CIDomBlocks;
        SmallVector<BasicBlock *, 8> CIPDomBlocks;
        DT->getDescendants(CIDom, CIDomBlocks);
        PDT->getDescendants(CIPDom, CIPDomBlocks);

        // Blocks dominated by CIDom && can reach cipdom
        // union
        // blocks post dom by CIPDom && reachable from cidom



        for (BasicBlock *BB : CIDomBlocks) {
          if (isPotentiallyReachable(BB, CIPDom, DT)) {
            if (UnstructuredBlocks.insert(BB).second)
              Inserted = true;
          }
        }

        for (BasicBlock *BB : CIPDomBlocks) {
          if (isPotentiallyReachable(CIPDom, BB, DT)) {
            if (UnstructuredBlocks.insert(BB).second)
              Inserted = true;
          }
        }
      } while (Inserted);
    }
  }

  DEBUG(
    dbgs() << "Unstructured blocks:\n";
    for (BasicBlock *BB : UnstructuredBlocks) {
      dbgs() << "  " << BB->getName() << '\n';
    }
  );



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

  if (UnstructuredBlocks.empty()) {
    DEBUG(dbgs() << "No unstructured blocks\n");
    return false;
  }

  SmallVector<BasicBlock *, 8> OrderedUnstructuredBlocks;

  for (BasicBlock *BB : ReversePostOrderTraversal<Function *>(Func)) {
    if (UnstructuredBlocks.count(BB))
      OrderedUnstructuredBlocks.push_back(BB);
  }




  // FIXME: For some reason this is dependent on the order and is
  // non-deterministic with set iteration.
  BasicBlock *CIDom = findCIDOM(OrderedUnstructuredBlocks);
  BasicBlock *CIPDom = findCIPDOM(OrderedUnstructuredBlocks);

  DT->verifyDomTree();

  DEBUG(dbgs() <<  "CIDOM: " << CIDom->getName()
                << "  CIPDOM: " << CIPDom->getName() << '\n');

  DEBUG(
    dbgs() << "Before modify DT\n";
    DT->print(dbgs());
  );

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

  if (UnstructuredBlocks.count(CIPDom)) {
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

  DT->verifyDomTree();



  DEBUG(
    dbgs() << "Ordered unstructured:\n";
    for (BasicBlock *BB : OrderedUnstructuredBlocks) {
      dbgs() << "  " << BB->getName() << '\n';
    }

    DT->print(dbgs());
  );

  linearizeBlocks(OrderedUnstructuredBlocks, CIPDom);

  rebuildSSA();

  DT->verifyDomTree();


  // We probably didn't really need a dummy CIDom block, but added it just in
  // case. Eliminate a pointless branch.
  //MergeBasicBlockIntoOnlyPred(OrderedUnstructuredBlocks.front(), DT);
  //if (BasicBlock *IDomSucc = CIDom->getSingleSuccessor())
  //MergeBasicBlockIntoOnlyPred(IDomSucc, DT);

  DT->verifyDomTree();

  return true;
}

namespace llvm {
Pass *createLinearizeCFGPass(bool SkipUniformRegions);
}

Pass *llvm::createLinearizeCFGPass(bool SkipUniformRegions) {
  return new LinearizeCFG(SkipUniformRegions);
}
