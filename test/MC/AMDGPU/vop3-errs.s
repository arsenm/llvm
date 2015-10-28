// RUN: not llvm-mc -arch=amdgcn -show-encoding %s 2>&1 | FileCheck %s
// RUN: not llvm-mc -arch=amdgcn -mcpu=SI -show-encoding %s 2>&1 | FileCheck %s

v_add_f32_e64 v0, v1
// CHECK: error: too few operands for instruction

v_add_f32_e64 v0, v1, abs(v2
// CHECK: error: failed parsing operand.

v_add_f32_e64 v0, v1, |v2|
// CHECK: error: not a valid operand.
// CHECK: error: unexpected token at start of statement

v_add_f32_e64 v0, v1, absv2
// CHECK: error: invalid operand for instruction
