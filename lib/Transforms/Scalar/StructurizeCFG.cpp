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
#include "llvm/Analysis/DivergenceAnalysis.h"
#include "llvm/Analysis/DominanceFrontier.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/RegionIterator.h"
#include "llvm/ADT/SCCIterator.h"
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
#include <queue>

using namespace llvm;
using namespace llvm::PatternMatch;

#define DEBUG_TYPE "structurizecfg"

#define USEFUL_NAMES 0

// The name for newly created blocks.
static const char *const FlowBlockName = "Flow";

namespace {

// Definition of the complex types used in this pass.

using BBValuePair = std::pair<BasicBlock *, Value *>;

using RNVector = SmallVector<RegionNode *, 8>;
using BBVector = SmallVector<BasicBlock *, 8>;
using BranchVector = SmallVector<BranchInst *, 8>;
using BBValueVector = SmallVector<BBValuePair, 2>;

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
class NearestCommonDominator {
  DominatorTree *DT;
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
  explicit NearestCommonDominator(DominatorTree *DomTree) : DT(DomTree) {}

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
class StructurizeCFG : public FunctionPass {
  RegionInfo *RI;
  bool SkipUniformRegions;

  Type *Boolean;
  ConstantInt *BoolTrue;
  ConstantInt *BoolFalse;
  UndefValue *BoolUndef;

  Function *Func;
  Region *ParentRegion;

  DominatorTree *DT;
  LoopInfo *LI;

  SmallVector<RegionNode *, 8> Order;
  BBSet Visited;

  BBPhiMap DeletedPhis;
  BB2BBVecMap AddedPhis;

  PredMap Predicates;
  BranchVector Conditions;

  BB2BBMap Loops;
  PredMap LoopPreds;
  BranchVector LoopConds;

  RegionNode *PrevNode;

  void detectBackedges(Function &F);
  void orderNodes(Region *R);

  void analyzeLoops(RegionNode *N);

  Value *invert(Value *Condition);

  Value *buildCondition(BranchInst *Term, unsigned Idx, bool Invert);

  void gatherPredicates(RegionNode *N);

  void collectInfos();

  void insertConditions(bool Loops);

  void delPhiValues(BasicBlock *From, BasicBlock *To);

  void addPhiValues(BasicBlock *From, BasicBlock *To);

  void setPhiValues();

  void killTerminator(BasicBlock *BB);

  void changeExit(RegionNode *Node, BasicBlock *NewExit,
                  bool IncludeDominator);

  BasicBlock *getNextFlow(BasicBlock *Dominator);

  BasicBlock *needPrefix(bool NeedEmpty);

  BasicBlock *needPostfix(BasicBlock *Flow, bool ExitUseAllowed);

  void setPrevNode(BasicBlock *BB);

  bool dominatesPredicates(BasicBlock *BB, RegionNode *Node);

  bool isPredictableTrue(RegionNode *Node);

  void wireFlow(bool ExitUseAllowed, BasicBlock *LoopEnd);

  void handleLoops(bool ExitUseAllowed, BasicBlock *LoopEnd);

  void createFlow(BasicBlock *RegionEntry, BasicBlock *RegionExit);

  void rebuildSSA();

public:
  static char ID;

  explicit StructurizeCFG(bool SkipUniformRegions = false)
      : FunctionPass(ID), SkipUniformRegions(SkipUniformRegions) {
    initializeStructurizeCFGPass(*PassRegistry::getPassRegistry());
  }

  bool doInitialization(Module &M) override;

  bool skipUniformRegion(Region &R, bool &Changed) const;
  bool addRegionIntoQueue(Region &R, std::deque<Region *> &RQ) const;
  bool runOnRegion(Region *R);

  bool runOnFunction(Function &F) override;

  StringRef getPassName() const override { return "Structurize control flow"; }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    if (SkipUniformRegions)
      AU.addRequired<DivergenceAnalysis>();

    AU.addRequiredID(LowerSwitchID);
    AU.addRequired<LoopInfoWrapperPass>();
    AU.addRequired<DominatorTreeWrapperPass>();
    AU.addRequired<PostDominatorTreeWrapperPass>();
    AU.addRequired<DominanceFrontierWrapperPass>();

    AU.addPreserved<DominatorTreeWrapperPass>();
    FunctionPass::getAnalysisUsage(AU);
  }
};

} // end anonymous namespace

char StructurizeCFG::ID = 0;

INITIALIZE_PASS_BEGIN(StructurizeCFG, "structurizecfg", "Structurize the CFG",
                      false, false)
INITIALIZE_PASS_DEPENDENCY(LowerSwitch)
INITIALIZE_PASS_DEPENDENCY(DivergenceAnalysis)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(PostDominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(DominanceFrontierWrapperPass)
INITIALIZE_PASS_END(StructurizeCFG, "structurizecfg", "Structurize the CFG",
                    false, false)

/// \brief Initialize the types and constants used in the pass
bool StructurizeCFG::doInitialization(Module &M) {
  LLVMContext &Context = M.getContext();

  Boolean = Type::getInt1Ty(Context);
  BoolTrue = ConstantInt::getTrue(Context);
  BoolFalse = ConstantInt::getFalse(Context);
  BoolUndef = UndefValue::get(Boolean);

  return false;
}

static void printRegionNode(const RegionNode *N) {
  if (!N) {
    dbgs() << " NULL REGION NODE\n";
    return;
  }

  if (N->isSubRegion()) {
    BasicBlock *Enter = N->getNodeAs<Region>()->getEnteringBlock();
    BasicBlock *Exit = N->getNodeAs<Region>()->getExit();

    dbgs() << "  subregion: " << Enter->getName() << " -> " << Exit->getName() << '\n';
  } else {
    BasicBlock *BB = N->getNodeAs<BasicBlock>();
    dbgs() << " BB " << BB->getName() << '\n';
  }

}


static void printSCCRegion(Region *R) {
  dbgs() << "Region SCC order:\n";
  scc_iterator<Region *> I = scc_begin(R);
  for (; !I.isAtEnd(); ++I) {
    dbgs() << "\nSCC break\n";
    const std::vector<RegionNode *> &Nodes = *I;
    for (RegionNode *N : Nodes) {
      printRegionNode(N);
    }
  }
}

static void printRPORegion(Region *R) {
  dbgs() << "Region RPO order:\n";
  ReversePostOrderTraversal<Region*> RPOT(R);
  for (RegionNode *RN : RPOT)
    printRegionNode(RN);
}

static void printSCCFunc(Function *F) {
  dbgs() << "Function SCC order:\n";
  scc_iterator<Function *> I = scc_begin(F);
  for (; !I.isAtEnd(); ++I) {
    dbgs() << "\nSCC break\n";
    const std::vector<BasicBlock *> &Nodes = *I;
    for (BasicBlock *BB : Nodes) {
      dbgs() << "BB " << BB->getName() << '\n';
    }
  }
}

void StructurizeCFG::detectBackedges(Function &F) {
  SmallVector<BasicBlock *, 16> Order;


  dbgs() << "***DETECT BACKEDGES***\n";
  SmallPtrSet<BasicBlock *, 8> Visited;

#if 0
  scc_iterator<Function *> I = scc_begin(&F);
  for (; !I.isAtEnd(); ++I) {
    const std::vector<BasicBlock *> &Nodes = *I;
    for (BasicBlock *BB : Nodes) {
      Order.append(Nodes.begin(), Nodes.end());
    }
  }

  std::reverse(Order.begin(), Order.end());
#endif

#if 1
  ReversePostOrderTraversal<Function*> RPOT(&F);
  for (BasicBlock *BB : RPOT)
    Order.push_back(BB);

#endif

  for (BasicBlock *BB : Order) {
    Visited.insert(BB);

    for (BasicBlock *Succ : successors(BB)) {
      if (Visited.count(Succ)) {
        dbgs() << "Backedge found: " << BB->getName() << " -> "
               << Succ->getName() << '\n';
        }
    }
  }

  dbgs() << "***END DETECT BACKEDGES***\n\n\n";
}

/// \brief Build up the general order of nodes
void StructurizeCFG::orderNodes(Region *ParentRegion) {
  DEBUG(
    printSCCRegion(ParentRegion);
    dbgs() << "\n\n\n\n";
    printSCCFunc(Func);
    dbgs() << "\n\n\n\n";
    printRPORegion(ParentRegion);
    dbgs() << "\n\n\n\n";
  );

#if 0
  Order.clear();

  scc_iterator<Function *> I = scc_begin(Func);
  for (; !I.isAtEnd(); ++I) {
    const std::vector<BasicBlock *> &Nodes = *I;
    for (BasicBlock *BB : Nodes) {
      Region *R = RI->getRegionFor(BB);
      if (R->isTopLevelRegion())
        continue;
      if (R != ParentRegion) {
        dbgs() << "Different regions\n";
        printRegionNode(R->getNode());
        printRegionNode(ParentRegion->getNode());
        continue;
      }
      if (!is_contained(Order, R->getNode())) {
        Order.push_back(R->getNode());
      } else {
        dbgs() << "Already contained: ";
        printRegionNode(R->getNode());
      }
    }
  }

  ReversePostOrderTraversal<Region*> RPOT(ParentRegion);
  DEBUG(dbgs() << "Size of nodes: " << std::distance(RPOT.begin(), RPOT.end()) << '\n');
  DEBUG(dbgs() << "Size of order: " << Order.size() << '\n');

  assert(std::distance(RPOT.begin(), RPOT.end()) ==
         Order.size());

  return;
#endif

#if 1
  scc_iterator<Region *> I = scc_begin(ParentRegion);
  for (Order.clear(); !I.isAtEnd(); ++I) {
    const std::vector<RegionNode *> &Nodes = *I;
    Order.append(Nodes.begin(), Nodes.end());
  }

  return;
#endif


#if 0
  ReversePostOrderTraversal<Region*> RPOT(ParentRegion);
  SmallDenseMap<Loop*, unsigned, 8> LoopBlocks;


  // The reverse post-order traversal of the list gives us an ordering close
  // to what we want.  The only problem with it is that sometimes backedges
  // for outer loops will be visited before backedges for inner loops.
  for (RegionNode *RN : RPOT) {
    BasicBlock *BB = RN->getEntry();
    Loop *Loop = LI->getLoopFor(BB);

    DEBUG(
      dbgs() << "Loop for " << BB->getName()
      << " depth " << (Loop ? Loop->getLoopDepth() : -1)
      << ":\n  ";
      if (Loop)
        Loop->dump();
      else
        dbgs() << "<null>\n";
    );


    ++LoopBlocks[Loop];
  }

  DEBUG(dbgs() << "Size of nodes: " << std::distance(RPOT.begin(), RPOT.end()) << '\n');

  DEBUG(
    dbgs() << "Loop depths:\n";
    for (auto I = RPOT.begin(), E = RPOT.end(); I != E; ++I) {
      BasicBlock *BB = (*I)->getEntry();
      auto *L = LI->getLoopFor(BB);
      unsigned LoopDepth = LI->getLoopDepth(BB);
      dbgs() << "  " << (L != nullptr) << " depth = " << LoopDepth <<  " " << BB->getName()
             << " loop name " << (L ? L->getName() : "<no loop>")
             << '\n';
    }

    dbgs() << "\n\n\n";
  );


  unsigned CurrentLoopDepth = 0;
  Loop *CurrentLoop = nullptr;
  for (auto I = RPOT.begin(), E = RPOT.end(); I != E; ++I) {
    BasicBlock *BB = (*I)->getEntry();
    unsigned LoopDepth = LI->getLoopDepth(BB);

    if (is_contained(Order, *I)) {
      DEBUG(dbgs() << "is_contained continue: " << BB->getName() << '\n');
      continue;
    }

    DEBUG(dbgs() << "Check unvisited region: " << BB->getName() << '\n');

    if (LoopDepth < CurrentLoopDepth) {
      DEBUG(dbgs() << "LoopDepth < CurrentLoopDepth: "
            << LoopDepth <<
            " < " << CurrentLoopDepth << '\n');


      // Make sure we have visited all blocks in this loop before moving back to
      // the outer loop.

      auto LoopI = I;
      while (unsigned &BlockCount = LoopBlocks[CurrentLoop]) {
        assert(BlockCount >= 0);
        LoopI++;
        BasicBlock *LoopBB = (*LoopI)->getEntry();
        if (LI->getLoopFor(LoopBB) == CurrentLoop) {
          assert(BlockCount >= 0);
          --BlockCount;
          Order.push_back(*LoopI);
        }
      }
    } else {
      DEBUG(dbgs() << "XX LoopDepth >= CurrentLoopDepth: "
            << LoopDepth <<
            " < " << CurrentLoopDepth << '\n');
    }

    CurrentLoop = LI->getLoopFor(BB);
    if (CurrentLoop) {
      DEBUG(dbgs() << "--LoopBlocks[CurrentLoop]: loop for "
            << BB->getName() << '\n');
      assert(LoopBlocks[CurrentLoop] >= 0);
      LoopBlocks[CurrentLoop]--;
    } else {
      DEBUG(dbgs() << "No loop for " << BB->getName() << '\n');
    }

    CurrentLoopDepth = LoopDepth;
    Order.push_back(*I);
  }

  // This pass originally used a post-order traversal and then operated on
  // the list in reverse. Now that we are using a reverse post-order traversal
  // rather than re-working the whole pass to operate on the list in order,
  // we just reverse the list and continue to operate on it in reverse.
  std::reverse(Order.begin(), Order.end());
#endif
}

/// \brief Determine the end of the loops
void StructurizeCFG::analyzeLoops(RegionNode *N) {
  if (N->isSubRegion()) {
    // Test for exit as back edge
    BasicBlock *Exit = N->getNodeAs<Region>()->getExit();
    if (Visited.count(Exit)) {
      auto &X = Loops[Exit];
      assert(X == nullptr);
      X = N->getEntry();

      DEBUG(
        dbgs() << "Subregion back edge found: "
        << " exit: " << (Exit ? Exit->getName() : " <null>") << ' ';
      );
      printRegionNode(N);
    }

  } else {
    // Test for successors as back edge
    BasicBlock *BB = N->getNodeAs<BasicBlock>();
    BranchInst *Term = cast<BranchInst>(BB->getTerminator());

    DEBUG(dbgs() << "analyze successors: " << *Term << '\n');
    for (BasicBlock *Succ : Term->successors()) {

      // FIXME: This is broken in testcases with effective multiple exits
      if (Visited.count(Succ) != DT->dominates(Succ, BB)) {

        DEBUG(
          dbgs() << "Succ: " << Succ->getName()
          << " visited: " << Visited.count(Succ)
          << " dominates: " << DT->dominates(Succ, BB)
          << " BB: " << BB->getName() << '\n';
          );


        //llvm_unreachable("succ != dominates");
      }


#if 1
      if (Visited.count(Succ)) {
#else
      if (DT->dominates(Succ, BB)) {
#endif
        auto &X = Loops[Succ];


        DEBUG(
          if (X != nullptr) {
            dbgs() << "OVERWRITING LOOPS BLOCK "
                   << X->getName()
                   << " with "
                   << BB->getName()
                   << '\n';
            //llvm_unreachable("overwrote block");
          } else {
            dbgs() << "SETTING LOOPS BLOCK "
                   << BB->getName()
                   << '\n';
          }
        );

        //assert(X == nullptr);
        X = BB;
        //Loops[Succ] = BB;
      }
    }
  }

  DEBUG(
    dbgs() << "\n\n\nBLOCKS IN LOOPS:\n";
    for (auto &X : Loops) {
      dbgs() << "  "
             << X.first->getName()
             << " -> "
             << X.second->getName()
             << '\n';
    }
  );
}

/// \brief Invert the given condition
Value *StructurizeCFG::invert(Value *Condition) {
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

/// \brief Build the condition for one edge
Value *StructurizeCFG::buildCondition(BranchInst *Term, unsigned Idx,
                                      bool Invert) {
  Value *Cond = Invert ? BoolFalse : BoolTrue;
  if (Term->isConditional()) {
    Cond = Term->getCondition();

    if (Idx != (unsigned)Invert)
      Cond = invert(Cond);
  }
  return Cond;
}

/// \brief Analyze the predecessors of each block and build up predicates
void StructurizeCFG::gatherPredicates(RegionNode *N) {
  BasicBlock *BB = N->getEntry();
  Region *ParentRegion = N->getParent();
  BBPredicates &Pred = Predicates[BB];
  BBPredicates &LPred = LoopPreds[BB];

  for (BasicBlock *P : predecessors(BB)) {
    // Ignore it if it's a branch from outside into our region entry
    if (!N->getParent()->contains(P))
      continue;

    Region *R = RI->getRegionFor(P);
    if (R == ParentRegion) {
      // It's a top level block in our region
      BranchInst *Term = cast<BranchInst>(P->getTerminator());
      for (unsigned i = 0, e = Term->getNumSuccessors(); i != e; ++i) {
        BasicBlock *Succ = Term->getSuccessor(i);
        if (Succ != BB)
          continue;

        bool ForwardEdge = Visited.count(P);

        DEBUG(
          dbgs() << (ForwardEdge ? "Forward" : "Back")
          << " edge: "
          << P->getName()
          << " -> "
          << Succ->getName()
          << '\n'
        );

        if (ForwardEdge) {
          // Normal forward edge.
          if (Term->isConditional()) {
            // Try to treat it like an ELSE block
            BasicBlock *Other = Term->getSuccessor(!i);
            if (Visited.count(Other) && !Loops.count(Other) &&
                !Pred.count(Other) && !Pred.count(P)) {

              Pred[Other] = BoolFalse;
              Pred[P] = BoolTrue;
              continue;
            }
          }
          Pred[P] = buildCondition(Term, i, false);
        } else {
          // Back edge
          LPred[P] = buildCondition(Term, i, true);
        }
      }
    } else {
      // It's an exit from a sub region
      while (R->getParent() != ParentRegion)
        R = R->getParent();

      // Edge from inside a subregion to its entry, ignore it
      if (*R == *N)
        continue;

      BasicBlock *Entry = R->getEntry();
      bool ForwardEdge = Visited.count(Entry);
      if (ForwardEdge)
        Pred[Entry] = BoolTrue;
      else
        LPred[Entry] = BoolFalse;

      DEBUG(
          dbgs() << "Region exit "
          << (ForwardEdge ? "forward" : "back")
          << " edge: "
          << Entry->getName()
          << " -> "
          << P->getName()
          << '\n'
        );
    }
  }
}

/// \brief Collect various loop and predicate infos
void StructurizeCFG::collectInfos() {
  // Reset predicate
  Predicates.clear();

  // and loop infos
  Loops.clear();
  LoopPreds.clear();

  // Reset the visited nodes
  Visited.clear();

  DEBUG(
    dbgs() << "\n\n\nREVERSED ORDER:\n";
    for (RegionNode *RN : reverse(Order))
      printRegionNode(RN);
    dbgs() << "\n\n\n\n";
  );

  for (RegionNode *RN : reverse(Order)) {
    DEBUG(dbgs() << "Visiting: "
                 << (RN->isSubRegion() ? "SubRegion with entry: " : "")
                 << RN->getEntry()->getName() << " Loop Depth: "
                 << LI->getLoopDepth(RN->getEntry()) << '\n');


    // Analyze all the conditions leading to a node
    gatherPredicates(RN);

    // Remember that we've seen this node
    DEBUG(dbgs() << "ENTRY VISIT: " << RN->getEntry()->getName() << '\n');

    Visited.insert(RN->getEntry());

    // Find the last back edges
    analyzeLoops(RN);
  }

#if 0
    SmallVector<std::pair<const BasicBlock *, const BasicBlock *>, 8> Edges;
  FindFunctionBackedges(*Func, Edges);

  for (auto X : Edges) {
    Loops[const_cast<BasicBlock *>(X.second)] = const_cast<BasicBlock *>(X.first);
  }

  return;
#endif


  DEBUG(
    dbgs() << "\n\n\nBLOCKS IN LOOPS:\n";
    for (auto &X : Loops) {
      dbgs() << "  "
             << X.first->getName()
             << " -> "
             << X.second->getName()
             << '\n';
    }

    dbgs() << "END BLOCKS IN LOOPS\n";
  );
}

/// \brief Insert the missing branch conditions
void StructurizeCFG::insertConditions(bool Loops) {
  BranchVector &Conds = Loops ? LoopConds : Conditions;
  Value *Default = Loops ? BoolTrue : BoolFalse;
  SSAUpdater PhiInserter;

  for (BranchInst *Term : Conds) {
    assert(Term->isConditional());

    BasicBlock *Parent = Term->getParent();
    BasicBlock *SuccTrue = Term->getSuccessor(0);
    BasicBlock *SuccFalse = Term->getSuccessor(1);

    PhiInserter.Initialize(Boolean, "");
    PhiInserter.AddAvailableValue(&Func->getEntryBlock(), Default);
    PhiInserter.AddAvailableValue(Loops ? SuccFalse : Parent, Default);

    BBPredicates &Preds = Loops ? LoopPreds[SuccFalse] : Predicates[SuccTrue];

    NearestCommonDominator Dominator(DT);
    Dominator.addBlock(Parent);

    Value *ParentValue = nullptr;
    for (std::pair<BasicBlock *, Value *> BBAndPred : Preds) {
      BasicBlock *BB = BBAndPred.first;
      Value *Pred = BBAndPred.second;

      if (BB == Parent) {
        ParentValue = Pred;
        break;
      }
      PhiInserter.AddAvailableValue(BB, Pred);
      Dominator.addAndRememberBlock(BB);
    }

    if (ParentValue) {
      Term->setCondition(ParentValue);
    } else {
      if (!Dominator.resultIsRememberedBlock())
        PhiInserter.AddAvailableValue(Dominator.result(), Default);

      auto *NewPhi = PhiInserter.GetValueInMiddleOfBlock(Parent);
#if USEFUL_NAMES
      NewPhi->setName("cond.phi");
#endif
      Term->setCondition(NewPhi);
    }
  }
}

/// \brief Remove all PHI values coming from "From" into "To" and remember
/// them in DeletedPhis
void StructurizeCFG::delPhiValues(BasicBlock *From, BasicBlock *To) {
  PhiMap &Map = DeletedPhis[To];
  for (PHINode &Phi : To->phis()) {
    while (Phi.getBasicBlockIndex(From) != -1) {
      Value *Deleted = Phi.removeIncomingValue(From, false);
      Map[&Phi].push_back(std::make_pair(From, Deleted));
    }
  }
}

/// \brief Add a dummy PHI value as soon as we knew the new predecessor
void StructurizeCFG::addPhiValues(BasicBlock *From, BasicBlock *To) {
  for (PHINode &Phi : To->phis()) {
    Value *Undef = UndefValue::get(Phi.getType());
    Phi.addIncoming(Undef, From);
  }
  AddedPhis[To].push_back(From);
}

/// \brief Add the real PHI value as soon as everything is set up
void StructurizeCFG::setPhiValues() {
  SSAUpdater Updater;
  for (const auto &AddedPhi : AddedPhis) {
    BasicBlock *To = AddedPhi.first;
    const BBVector &From = AddedPhi.second;

    if (!DeletedPhis.count(To))
      continue;

    PhiMap &Map = DeletedPhis[To];
    for (const auto &PI : Map) {
      PHINode *Phi = PI.first;
      Value *Undef = UndefValue::get(Phi->getType());
      Updater.Initialize(Phi->getType(), "");
      Updater.AddAvailableValue(&Func->getEntryBlock(), Undef);
      Updater.AddAvailableValue(To, Undef);

      NearestCommonDominator Dominator(DT);
      Dominator.addBlock(To);
      for (const auto &VI : PI.second) {
        Updater.AddAvailableValue(VI.first, VI.second);
        Dominator.addAndRememberBlock(VI.first);
      }

      if (!Dominator.resultIsRememberedBlock())
        Updater.AddAvailableValue(Dominator.result(), Undef);

      for (BasicBlock *FI : From) {
        int Idx = Phi->getBasicBlockIndex(FI);
        assert(Idx != -1);
        Phi->setIncomingValue(Idx, Updater.GetValueAtEndOfBlock(FI));
      }
    }

    DeletedPhis.erase(To);
  }
  assert(DeletedPhis.empty());
}

/// \brief Remove phi values from all successors and then remove the terminator.
void StructurizeCFG::killTerminator(BasicBlock *BB) {
  TerminatorInst *Term = BB->getTerminator();
  if (!Term)
    return;

  for (succ_iterator SI = succ_begin(BB), SE = succ_end(BB);
       SI != SE; ++SI)
    delPhiValues(BB, *SI);

  Term->eraseFromParent();
}

/// \brief Let node exit(s) point to NewExit
void StructurizeCFG::changeExit(RegionNode *Node, BasicBlock *NewExit,
                                bool IncludeDominator) {
  if (Node->isSubRegion()) {
    Region *SubRegion = Node->getNodeAs<Region>();
    BasicBlock *OldExit = SubRegion->getExit();
    BasicBlock *Dominator = nullptr;

    // Find all the edges from the sub region to the exit
    for (auto BBI = pred_begin(OldExit), E = pred_end(OldExit); BBI != E;) {
      // Incrememt BBI before mucking with BB's terminator.
      BasicBlock *BB = *BBI++;

      if (!SubRegion->contains(BB))
        continue;

      // Modify the edges to point to the new exit
      delPhiValues(BB, OldExit);
      BB->getTerminator()->replaceUsesOfWith(OldExit, NewExit);
      addPhiValues(BB, NewExit);

      // Find the new dominator (if requested)
      if (IncludeDominator) {
        if (!Dominator)
          Dominator = BB;
        else
          Dominator = DT->findNearestCommonDominator(Dominator, BB);
      }
    }

    // Change the dominator (if requested)
    if (Dominator) {
      DEBUG(dbgs() << "Subregion Change dominator of " << NewExit->getName() << " to " << Dominator->getName() << '\n');
      DT->changeImmediateDominator(NewExit, Dominator);
    }

    // Update the region info
    SubRegion->replaceExit(NewExit);

    DEBUG(dbgs() << "Replacing subregion exit with " << NewExit->getName() << '\n');

  } else {
    BasicBlock *BB = Node->getNodeAs<BasicBlock>();
    killTerminator(BB);
    BranchInst::Create(NewExit, BB);
    addPhiValues(BB, NewExit);

    DEBUG(dbgs() << "Changing exit from " << BB->getName() << " to " << NewExit->getName() << '\n');


    if (IncludeDominator) {
      DT->changeImmediateDominator(NewExit, BB);
      DEBUG(dbgs() << "Block Change dominator of " << NewExit->getName() << " to " << BB->getName() << '\n');
    }

  }

  //DT->verifyDomTree();
}

/// \brief Create a new flow node and update dominator tree and region info
BasicBlock *StructurizeCFG::getNextFlow(BasicBlock *Dominator) {
  LLVMContext &Context = Func->getContext();
  BasicBlock *Insert = Order.empty() ? ParentRegion->getExit() :
                       Order.back()->getEntry();
  BasicBlock *Flow = BasicBlock::Create(Context,
                                        #if USEFUL_NAMES
                                        Twine("flow.") + Dominator->getName(),
                                        #else
                                        FlowBlockName,
                                        #endif

                                        Func, Insert);
  DT->addNewBlock(Flow, Dominator);
  RI->setRegionFor(Flow, ParentRegion);

  DEBUG(dbgs() << "Created new flow: " << Flow->getName() << '\n');
  return Flow;
}

/// \brief Create a new or reuse the previous node as flow node
BasicBlock *StructurizeCFG::needPrefix(bool NeedEmpty) {
  BasicBlock *Entry = PrevNode->getEntry();

  if (!PrevNode->isSubRegion()) {
    DEBUG(
      dbgs() << "Prev node not a subregion: "
      << PrevNode->getNodeAs<BasicBlock>()->getName() << '\n';
    );

    killTerminator(Entry);
    if (!NeedEmpty || Entry->getFirstInsertionPt() == Entry->end()) {
      DEBUG(dbgs() << "return Entry\n");
      return Entry;
    }
  }

  // create a new flow node
  BasicBlock *Flow = getNextFlow(Entry);

  // and wire it up
  DEBUG(dbgs() << "Change exit need prefix\n");
  changeExit(PrevNode, Flow, true);
  PrevNode = ParentRegion->getBBNode(Flow);
  return Flow;
}

/// \brief Returns the region exit if possible, otherwise just a new flow node
BasicBlock *StructurizeCFG::needPostfix(BasicBlock *Flow,
                                        bool ExitUseAllowed) {
  if (!Order.empty() || !ExitUseAllowed) {
    DEBUG(dbgs() << "needPostfix getNextFlow\n");
    return getNextFlow(Flow);
  }

  BasicBlock *Exit = ParentRegion->getExit();
  DT->changeImmediateDominator(Exit, Flow);
  //DT->verifyDomTree();
  addPhiValues(Flow, Exit);
  return Exit;
}

/// \brief Set the previous node
void StructurizeCFG::setPrevNode(BasicBlock *BB) {
  DEBUG(dbgs() << "Set prevNode to " << BB->getName() << '\n');

  PrevNode = ParentRegion->contains(BB) ? ParentRegion->getBBNode(BB)
                                        : nullptr;

  DEBUG(
    dbgs() << "Prev node set: ";
    if (PrevNode)
      dbgs() << "<null PrevNode>\n";
    else
      dbgs() << "yes" << '\n';
  );
}

/// \brief Does BB dominate all the predicates of Node?
bool StructurizeCFG::dominatesPredicates(BasicBlock *BB, RegionNode *Node) {
  BBPredicates &Preds = Predicates[Node->getEntry()];
  return llvm::all_of(Preds, [&](std::pair<BasicBlock *, Value *> Pred) {
    return DT->dominates(BB, Pred.first);
  });
}

/// \brief Can we predict that this node will always be called?
bool StructurizeCFG::isPredictableTrue(RegionNode *Node) {
  BBPredicates &Preds = Predicates[Node->getEntry()];
  bool Dominated = false;

  // Regionentry is always true
  if (!PrevNode)
    return true;

  for (std::pair<BasicBlock*, Value*> Pred : Preds) {
    BasicBlock *BB = Pred.first;
    Value *V = Pred.second;

    if (V != BoolTrue)
      return false;

    if (!Dominated && DT->dominates(BB, PrevNode->getEntry())) {
      //assert(DT->properlyDominates(BB, PrevNode->getEntry()));
      Dominated = true;
    }
  }

  // TODO: The dominator check is too strict
  return Dominated;
}

/// Take one node from the order vector and wire it up
void StructurizeCFG::wireFlow(bool ExitUseAllowed,
                              BasicBlock *LoopEnd) {
  RegionNode *Node = Order.pop_back_val();
  Visited.insert(Node->getEntry());

  if (isPredictableTrue(Node)) {
    DEBUG(dbgs() << "isPredictable true\n");
    // Just a linear flow
    if (PrevNode) {
      DEBUG(dbgs() << "Just a linear flow, change exit\n");
      changeExit(PrevNode, Node->getEntry(), true);
    }
    PrevNode = Node;
  } else {
    DEBUG(dbgs() << "Not predictable true\n");
    // Insert extra prefix node (or reuse last one)
    BasicBlock *Flow = needPrefix(false);

    // Insert extra postfix node (or use exit instead)
    BasicBlock *Entry = Node->getEntry();
    BasicBlock *Next = needPostfix(Flow, ExitUseAllowed);

    // let it point to entry and next block
    Conditions.push_back(BranchInst::Create(Entry, Next, BoolUndef, Flow));
    addPhiValues(Flow, Entry);

    DEBUG(dbgs() << "Change idom of " << Entry->getName() << " to " << Flow->getName() << '\n');

    DT->changeImmediateDominator(Entry, Flow);
    //DT->verifyDomTree();

    PrevNode = Node;
    while (!Order.empty() && !Visited.count(LoopEnd) &&
           dominatesPredicates(Entry, Order.back())) {
      handleLoops(false, LoopEnd);
    }

    changeExit(PrevNode, Next, false);
    setPrevNode(Next);
  }
}

void StructurizeCFG::handleLoops(bool ExitUseAllowed,
                                 BasicBlock *LoopEnd) {
  DEBUG(
    dbgs() << "\nHANDLE LOOPS: LoopEnd = ";
    if (LoopEnd) {
      dbgs() << LoopEnd->getName() << '\n';
    } else {
      dbgs() << "<null LoopEnd>\n";
    }
  );

  RegionNode *Node = Order.back();
  BasicBlock *LoopStart = Node->getEntry();

  if (!Loops.count(LoopStart)) {
    DEBUG(dbgs() << "Loops does not contain: " << LoopStart->getName() << '\n');
    wireFlow(ExitUseAllowed, LoopEnd);
    return;
  } else {
    DEBUG(dbgs() << "Loops DOES contain: " << LoopStart->getName() << '\n');
  }

  if (!isPredictableTrue(Node)) {
    LoopStart = needPrefix(true);

    DEBUG(dbgs() << "Looked for loop start prefix: " << LoopStart->getName() << '\n');
  }

  LoopEnd = Loops[Node->getEntry()];
  wireFlow(false, LoopEnd);
  while (!Visited.count(LoopEnd)) {
    handleLoops(false, LoopEnd);
  }

  // If the start of the loop is the entry block, we can't branch to it so
  // insert a new dummy entry block.
  Function *LoopFunc = LoopStart->getParent();
  if (LoopStart == &LoopFunc->getEntryBlock()) {
    LoopStart->setName("entry.orig");

    BasicBlock *NewEntry =
      BasicBlock::Create(LoopStart->getContext(),
                         "entry",
                         LoopFunc,
                         LoopStart);
    BranchInst::Create(LoopStart, NewEntry);
    DT->setNewRoot(NewEntry);
    //DT->verifyDomTree();
  }

  // Create an extra loop end node
  LoopEnd = needPrefix(false);
  BasicBlock *Next = needPostfix(LoopEnd, ExitUseAllowed);
  LoopConds.push_back(BranchInst::Create(Next, LoopStart,
                                         BoolUndef, LoopEnd));
  addPhiValues(LoopEnd, LoopStart);
  setPrevNode(Next);

  DEBUG(dbgs() << "Creating extra loop end node: " << LoopEnd->getName() << '\n');
}

/// After this function control flow looks like it should be, but
/// branches and PHI nodes only have undefined conditions.
void StructurizeCFG::createFlow(BasicBlock *RegionEntry,
                                BasicBlock *RegionExit) {
  bool EntryDominatesExit = DT->dominates(RegionEntry, RegionExit);

  DeletedPhis.clear();
  AddedPhis.clear();
  Conditions.clear();
  LoopConds.clear();

  PrevNode = nullptr;
  Visited.clear();

  while (!Order.empty()) {
    handleLoops(EntryDominatesExit, nullptr);
  }

  if (PrevNode) {
    DEBUG(
      dbgs() << "Changing exit of PrevNode ";
      printRegionNode(PrevNode);
    );

    changeExit(PrevNode, RegionExit, EntryDominatesExit);
  } else {
    DEBUG(dbgs() << "No prev node\n");
    assert(EntryDominatesExit);
  }
}

/// Handle a rare case where the disintegrated nodes instructions
/// no longer dominate all their uses. Not sure if this is really nessasary
void StructurizeCFG::rebuildSSA() {
  SSAUpdater Updater;
  for (BasicBlock *BB : ParentRegion->blocks())
    for (Instruction &I : *BB) {
      bool Initialized = false;
      // We may modify the use list as we iterate over it, so be careful to
      // compute the next element in the use list at the top of the loop.
      for (auto UI = I.use_begin(), E = I.use_end(); UI != E;) {
        Use &U = *UI++;
        Instruction *User = cast<Instruction>(U.getUser());
        if (User->getParent() == BB) {
          continue;
        } else if (PHINode *UserPN = dyn_cast<PHINode>(User)) {
          if (UserPN->getIncomingBlock(U) == BB)
            continue;
        }

        if (DT->dominates(&I, User))
          continue;

        if (!Initialized) {
          Value *Undef = UndefValue::get(I.getType());
          Updater.Initialize(I.getType(), "");
          Updater.AddAvailableValue(&Func->getEntryBlock(), Undef);
          Updater.AddAvailableValue(BB, &I);
          Initialized = true;
        }
        Updater.RewriteUseAfterInsertions(U);
      }
    }
}

static bool hasOnlyUniformBranches(const Region &R,
                                   const DivergenceAnalysis &DA) {
  for (const BasicBlock *BB : R.blocks()) {
    const BranchInst *Br = dyn_cast<BranchInst>(BB->getTerminator());
    if (!Br || !Br->isConditional())
      continue;

    if (!DA.isUniform(Br->getCondition()))
      return false;
    DEBUG(dbgs() << "BB: " << BB->getName() << " has uniform terminator\n");
  }
  return true;
}

bool StructurizeCFG::skipUniformRegion(Region &R, bool &Changed) const {
  if (!SkipUniformRegions)
    return false;
  // TODO: We could probably be smarter here with how we handle sub-regions.
  auto &DA = getAnalysis<DivergenceAnalysis>();
  if (hasOnlyUniformBranches(R, DA)) {
    DEBUG(dbgs() << "Skipping region with uniform control flow: " << R << '\n');

    // Mark all direct child block terminators as having been treated as
    // uniform. To account for a possible future in which non-uniform
    // sub-regions are treated more cleverly, indirect children are not
    // marked as uniform.
    MDNode *MD = MDNode::get(Func->getParent()->getContext(), {});
    for (RegionNode *E : R.elements()) {
      if (E->isSubRegion())
        continue;

      if (Instruction *Term = E->getEntry()->getTerminator()) {
        Term->setMetadata("structurizecfg.uniform", MD);
        Changed = true;
      }
    }

    return true;
  }

  return false;
}

/// \brief Run the transformation for each region found
bool StructurizeCFG::runOnRegion(Region *R) {
  if (R->isTopLevelRegion())
    return false;

  ParentRegion = R;

  DT = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();

  orderNodes(R);
  collectInfos();
  createFlow(R->getEntry(), R->getExit());
  insertConditions(false);
  insertConditions(true);
  setPhiValues();
  rebuildSSA();

  DT->verifyDomTree();
  //LI->verifyLoop();
  getAnalysis<LoopInfoWrapperPass>().verifyAnalysis();

  // Cleanup
  Order.clear();
  Visited.clear();
  assert(DeletedPhis.empty());
  AddedPhis.clear();
  Predicates.clear();
  Conditions.clear();
  Loops.clear();
  LoopPreds.clear();
  LoopConds.clear();

  return true;
}

// Recurse through all subregions and all regions  into RQ.
// The IR may still be modified even though all branches are uniform since
// metadata is added.
bool StructurizeCFG::addRegionIntoQueue(Region &R, std::deque<Region *> &RQ) const {
  bool Changed;

  if (!skipUniformRegion(R, Changed))
    RQ.push_back(&R);


  for (auto &E : R) {
    if (!skipUniformRegion(*E, Changed))
      addRegionIntoQueue(*E, RQ);
  }

  return Changed;
}

bool StructurizeCFG::runOnFunction(Function &F) {
 Func = &F;

  auto DT = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();
  auto PDT = &getAnalysis<PostDominatorTreeWrapperPass>().getPostDomTree();
  auto DF = &getAnalysis<DominanceFrontierWrapperPass>().getDominanceFrontier();

  bool Changed = false;

  RegionInfo RI;
  RI.recalculate(F, DT, PDT, DF);
  this->RI = &RI;

  std::deque<Region *> RQ;
  if (addRegionIntoQueue(*RI.getTopLevelRegion(), RQ))
    Changed = true;

  while (!RQ.empty()) {
    Region *CurrentRegion = RQ.back();

    if (runOnRegion(CurrentRegion)) {
      Changed = true;

#ifndef NDEBUG
      DT->verifyDomTree();
#endif
    }

    RQ.pop_back();
  }

  return Changed;
}

Pass *llvm::createStructurizeCFGPass(bool SkipUniformRegions) {
  return new StructurizeCFG(SkipUniformRegions);
}
