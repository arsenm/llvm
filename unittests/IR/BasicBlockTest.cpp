//===- llvm/unittest/IR/BasicBlockTest.cpp - BasicBlock unit tests --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/IR/BasicBlock.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/NoFolder.h"
#include "llvm/Support/SourceMgr.h"
#include "gmock/gmock-matchers.h"
#include "gtest/gtest.h"
#include <memory>

namespace llvm {
namespace {

TEST(BasicBlockTest, PhiRange) {
  LLVMContext Context;

  // Create the main block.
  std::unique_ptr<BasicBlock> BB(BasicBlock::Create(Context));

  // Create some predecessors of it.
  std::unique_ptr<BasicBlock> BB1(BasicBlock::Create(Context));
  BranchInst::Create(BB.get(), BB1.get());
  std::unique_ptr<BasicBlock> BB2(BasicBlock::Create(Context));
  BranchInst::Create(BB.get(), BB2.get());

  // Make sure this doesn't crash if there are no phis.
  for (auto &PN : BB->phis()) {
    (void)PN;
    EXPECT_TRUE(false) << "empty block should have no phis";
  }

  // Make it a cycle.
  auto *BI = BranchInst::Create(BB.get(), BB.get());

  // Now insert some PHI nodes.
  auto *Int32Ty = Type::getInt32Ty(Context);
  auto *P1 = PHINode::Create(Int32Ty, /*NumReservedValues*/ 3, "phi.1", BI);
  auto *P2 = PHINode::Create(Int32Ty, /*NumReservedValues*/ 3, "phi.2", BI);
  auto *P3 = PHINode::Create(Int32Ty, /*NumReservedValues*/ 3, "phi.3", BI);

  // Some non-PHI nodes.
  auto *Sum = BinaryOperator::CreateAdd(P1, P2, "sum", BI);

  // Now wire up the incoming values that are interesting.
  P1->addIncoming(P2, BB.get());
  P2->addIncoming(P1, BB.get());
  P3->addIncoming(Sum, BB.get());

  // Finally, let's iterate them, which is the thing we're trying to test.
  // We'll use this to wire up the rest of the incoming values.
  for (auto &PN : BB->phis()) {
    PN.addIncoming(UndefValue::get(Int32Ty), BB1.get());
    PN.addIncoming(UndefValue::get(Int32Ty), BB2.get());
  }

  // Test that we can use const iterators and generally that the iterators
  // behave like iterators.
  BasicBlock::const_phi_iterator CI;
  CI = BB->phis().begin();
  EXPECT_NE(CI, BB->phis().end());

  // And iterate a const range.
  for (const auto &PN : const_cast<const BasicBlock *>(BB.get())->phis()) {
    EXPECT_EQ(BB.get(), PN.getIncomingBlock(0));
    EXPECT_EQ(BB1.get(), PN.getIncomingBlock(1));
    EXPECT_EQ(BB2.get(), PN.getIncomingBlock(2));
  }
}

class BasicBlockPhiTest : public ::testing::Test
{
protected:
  LLVMContext C;

  // Create a somewhat complex function with a couple of basic blocks and a
  // single phi node.
  const char *ModuleString = "define i32 @f(i32 %x) {\n"
                             "bb0:\n"
                             "  switch i32 %x, label %bb1 [\n"
                             "         i32 2,  label %bb2\n"
                             "         i32 3,  label %bb3\n"
                             "         i32 4,  label %bb4]\n"
                             "bb1:\n"
                             "  br label %bb5\n"
                             "bb2:\n"
                             "  br label %bb5\n"
                             "bb3:\n"
                             "  br label %bb5\n"
                             "bb4:\n"
                             "  br label %bb5\n"
                             "bb5:\n"
                             "  %r = phi i32 [ 0, %bb1 ],\n"
                             "               [ 1, %bb2 ],\n"
                             "               [ 2, %bb3 ],\n"
                             "               [ 3, %bb4 ]\n"
                             "  ret i32 %r\n"
                             "}\n";

  std::unique_ptr<Module> M;
  Function *F;

  BasicBlock* BB0;
  BasicBlock* BB1;
  BasicBlock* BB2;
  BasicBlock* BB3;
  BasicBlock* BB4;
  BasicBlock* BB5;

  virtual void SetUp()
  {
    SMDiagnostic Err;

    M = parseAssemblyString(ModuleString, Err, C);
    F = M->getFunction("f");

    auto It = F->begin();

    BB0 = &*It++;
    BB1 = &*It++;
    BB2 = &*It++;
    BB3 = &*It++;
    BB4 = &*It++;
    BB5 = &*It++;

    EXPECT_TRUE(It == F->end());
  }
};

TEST_F(BasicBlockPhiTest, SwitchReplaceFixPHI) {

  SwitchInst* SI = dyn_cast<SwitchInst>(&BB0->front());
  PHINode*    PN = dyn_cast<PHINode>(&BB5->front());

  EXPECT_TRUE(SI != nullptr);
  EXPECT_TRUE(PN != nullptr);

  // Insert new label bb6.
  IRBuilder<> Builder(C);
  BasicBlock* BB6 = BasicBlock::Create(C, "bb6", F);

  // Make bb1 jump to bb5.
  BranchInst* BB1_Br = dyn_cast<BranchInst>(&BB1->front());
  BB1_Br->setSuccessor(0, BB6);

  // Add immediate branch to bb1.
  Builder.SetInsertPoint(BB6);
  Builder.CreateBr(BB5);

  BB5->fixPHIEdges(BB1, BB6);

  outs() << *PN << "\n";
  EXPECT_TRUE(PN->getIncomingBlock(0) == BB6);
}

TEST_F(BasicBlockPhiTest, SwitchDefaultFixPHI) {

  SwitchInst* SI = dyn_cast<SwitchInst>(&BB0->front());
  PHINode*    PN = dyn_cast<PHINode>(&BB5->front());

  EXPECT_TRUE(SI != nullptr);
  EXPECT_TRUE(PN != nullptr);

  // Make the switch directly branch to BB5 on default.
  SI->setDefaultDest(BB5);
  BB1->eraseFromParent();

  BB5->fixPHIEdges(BB1, BB0);

  outs() << *PN << "\n";
  EXPECT_TRUE(PN->getIncomingBlock(0) == BB0);
}

} // End anonymous namespace.
} // End llvm namespace.
