//===- llvm/unittest/ADT/SmallSetTest.cpp ---------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// SmallSet unit tests.
//
//===----------------------------------------------------------------------===//

#include "gtest/gtest.h"
#include "llvm/ADT/SmallSet.h"

using namespace llvm;

TEST(SmallSetTest, Assignment) {
  int buf[8] = { 0 };

  SmallSet<int *, 4> s1;
  s1.insert(&buf[0]);
  s1.insert(&buf[1]);

  SmallSet<int *, 4> s2;
  (s2 = s1).insert(&buf[2]);

  // Self assign as well.
  (s2 = s2).insert(&buf[3]);

  s1 = s2;
  EXPECT_EQ(4U, s1.size());
  for (int i = 0; i < 8; ++i)
    if (i < 4)
      EXPECT_TRUE(s1.count(&buf[i]));
    else
      EXPECT_FALSE(s1.count(&buf[i]));
}

TEST(SmallSetTest, GrowthTest) {
  int i;
  int buf[8] = { 0 };

  SmallSet<int *, 4> s;
  typedef SmallSet<int *, 4>::iterator iter;

  s.insert(&buf[0]);
  s.insert(&buf[1]);
  s.insert(&buf[2]);
  s.insert(&buf[3]);
  EXPECT_EQ(4U, s.size());

  i = 0;
  for (iter I = s.begin(), E = s.end(); I != E; ++I, ++i)
    (**I)++;
  EXPECT_EQ(4, i);
  for (i = 0; i < 8; ++i)
    EXPECT_EQ(i < 4 ? 1 : 0, buf[i]);

  s.insert(&buf[4]);
  s.insert(&buf[5]);
  s.insert(&buf[6]);
  s.insert(&buf[7]);

  i = 0;
  for (iter I = s.begin(), E = s.end(); I != E; ++I, ++i)
    (**I)++;
  EXPECT_EQ(8, i);
  s.erase(&buf[4]);
  s.erase(&buf[5]);
  s.erase(&buf[6]);
  s.erase(&buf[7]);
  EXPECT_EQ(4U, s.size());

  i = 0;
  for (iter I = s.begin(), E = s.end(); I != E; ++I, ++i)
    (**I)++;
  EXPECT_EQ(4, i);
  for (i = 0; i < 8; ++i)
    EXPECT_EQ(i < 4 ? 3 : 1, buf[i]);

  s.clear();
  for (i = 0; i < 8; ++i)
    buf[i] = 0;
  for (i = 0; i < 128; ++i)
    s.insert(&buf[i % 8]); // test repeated entires
  EXPECT_EQ(8U, s.size());
  for (iter I = s.begin(), E = s.end(); I != E; ++I, ++i)
    (**I)++;
  for (i = 0; i < 8; ++i)
    EXPECT_EQ(1, buf[i]);
}

TEST(SmallSetTest, CopyAndMoveTest) {
  int buf[8] = { 0 };

  SmallSet<int *, 4> s1;
  s1.insert(&buf[0]);
  s1.insert(&buf[1]);
  s1.insert(&buf[2]);
  s1.insert(&buf[3]);
  EXPECT_EQ(4U, s1.size());
  for (int i = 0; i < 8; ++i)
    if (i < 4)
      EXPECT_TRUE(s1.count(&buf[i]));
    else
      EXPECT_FALSE(s1.count(&buf[i]));

  SmallSet<int *, 4> s2(s1);
  EXPECT_EQ(4U, s2.size());
  for (int i = 0; i < 8; ++i)
    if (i < 4)
      EXPECT_TRUE(s2.count(&buf[i]));
    else
      EXPECT_FALSE(s2.count(&buf[i]));

  s1 = s2;
  EXPECT_EQ(4U, s1.size());
  EXPECT_EQ(4U, s2.size());
  for (int i = 0; i < 8; ++i)
    if (i < 4)
      EXPECT_TRUE(s1.count(&buf[i]));
    else
      EXPECT_FALSE(s1.count(&buf[i]));

  SmallSet<int *, 4> s3(std::move(s1));
  EXPECT_EQ(4U, s3.size());
  EXPECT_TRUE(s1.empty());
  for (int i = 0; i < 8; ++i) {
    if (i < 4)
      EXPECT_TRUE(s3.count(&buf[i]));
    else
      EXPECT_FALSE(s3.count(&buf[i]));
  }

  // Move assign into the moved-from object. Also test move of a non-small
  // container.
  s3.insert(&buf[4]);
  s3.insert(&buf[5]);
  s3.insert(&buf[6]);
  s3.insert(&buf[7]);
  s1 = std::move(s3);
  EXPECT_EQ(8U, s1.size());
  EXPECT_TRUE(s3.empty());
  for (int i = 0; i < 8; ++i)
    EXPECT_TRUE(s1.count(&buf[i]));

  // Copy assign into a moved-from object.
  s3 = s1;
  EXPECT_EQ(8U, s3.size());
  EXPECT_EQ(8U, s1.size());
  for (int i = 0; i < 8; ++i)
    EXPECT_TRUE(s3.count(&buf[i]));
}

TEST(SmallSetTest, SwapTest) {
  int buf[10];

  SmallSet<int *, 2> a;
  SmallSet<int *, 2> b;

  a.insert(&buf[0]);
  a.insert(&buf[1]);
  b.insert(&buf[2]);

  std::swap(a, b);

  EXPECT_EQ(1U, a.size());
  EXPECT_EQ(2U, b.size());
  EXPECT_TRUE(a.count(&buf[2]));
  EXPECT_TRUE(b.count(&buf[0]));
  EXPECT_TRUE(b.count(&buf[1]));

  b.insert(&buf[3]);
  std::swap(a, b);

  EXPECT_EQ(3U, a.size());
  EXPECT_EQ(1U, b.size());
  EXPECT_TRUE(a.count(&buf[0]));
  EXPECT_TRUE(a.count(&buf[1]));
  EXPECT_TRUE(a.count(&buf[3]));
  EXPECT_TRUE(b.count(&buf[2]));

  std::swap(a, b);

  EXPECT_EQ(1U, a.size());
  EXPECT_EQ(3U, b.size());
  EXPECT_TRUE(a.count(&buf[2]));
  EXPECT_TRUE(b.count(&buf[0]));
  EXPECT_TRUE(b.count(&buf[1]));
  EXPECT_TRUE(b.count(&buf[3]));

  a.insert(&buf[4]);
  a.insert(&buf[5]);
  a.insert(&buf[6]);

  std::swap(b, a);

  EXPECT_EQ(3U, a.size());
  EXPECT_EQ(4U, b.size());
  EXPECT_TRUE(b.count(&buf[2]));
  EXPECT_TRUE(b.count(&buf[4]));
  EXPECT_TRUE(b.count(&buf[5]));
  EXPECT_TRUE(b.count(&buf[6]));
  EXPECT_TRUE(a.count(&buf[0]));
  EXPECT_TRUE(a.count(&buf[1]));
  EXPECT_TRUE(a.count(&buf[3]));
}

TEST(SmallSetTest, IterationTest) {
  SmallSet<unsigned, 4> a;

  EXPECT_EQ(a.begin(), a.end());
  a.insert(1);
  a.insert(2);
  a.insert(3);
  a.insert(4);

  EXPECT_FALSE(a.empty());

  SmallSet<unsigned, 4>::iterator X = a.begin();
  EXPECT_EQ(1U, *X++);
  EXPECT_EQ(2U, *X++);
  EXPECT_EQ(3U, *X++);
  EXPECT_EQ(4U, *X++);
  EXPECT_EQ(a.end(), X);

  // Increase to large size.
  a.insert(5);

  unsigned Total = 0;
  for (SmallSet<unsigned, 4>::iterator I = a.begin(), E = a.end(); I != E; ++I)
    Total += *I;

  EXPECT_EQ(15u, Total);

  a.clear();
  EXPECT_EQ(a.begin(), a.end());
  EXPECT_TRUE(a.empty());
}
