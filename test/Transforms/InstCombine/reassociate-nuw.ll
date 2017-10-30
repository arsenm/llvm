; RUN: opt -instcombine -S %s | FileCheck %s

; CHECK-LABEL: @reassoc_add_nuw(
; CHECK-NEXT: add nuw i32 %x, 68
define i32 @reassoc_add_nuw(i32 %x) {
  %add0 = add nuw i32 %x, 4
  %add1 = add nuw i32 %add0, 64
  ret i32 %add1
}

; This does the wrong thing because the sub is turned into an add of a
; negative constant first which drops the nuw.

; CHECK-LABEL: @reassoc_sub_nuw(
; CHECK-NEXT: add i32 %x, -68
define i32 @reassoc_sub_nuw(i32 %x) {
  %sub0 = sub nuw i32 %x, 4
  %sub1 = sub nuw i32 %sub0, 64
  ret i32 %sub1
}

; CHECK-LABEL: @reassoc_mul_nuw(
; CHECK-NEXT: mul nuw i32 %x, 260
define i32 @reassoc_mul_nuw(i32 %x) {
  %mul0 = mul nuw i32 %x, 4
  %mul1 = mul nuw i32 %mul0, 65
  ret i32 %mul1
}

; CHECK-LABEL: @no_reassoc_add_nuw_none(
; CHECK-NEXT: add i32 %x, 68
define i32 @no_reassoc_add_nuw_none(i32 %x) {
  %add0 = add i32 %x, 4
  %add1 = add nuw i32 %add0, 64
  ret i32 %add1
}

; CHECK-LABEL: @no_reassoc_add_none_nuw(
; CHECK-NEXT: add i32 %x, 68
define i32 @no_reassoc_add_none_nuw(i32 %x) {
  %add0 = add nuw i32 %x, 4
  %add1 = add i32 %add0, 64
  ret i32 %add1
}

; CHECK-LABEL: @reassoc_x2_add_nuw(
; CHECK-NEXT: add nuw i32 %x, %y
; CHECK-NEXT: add nuw i32 %add1, 12
define i32 @reassoc_x2_add_nuw(i32 %x, i32 %y) {
  %add0 = add nuw i32 %x, 4
  %add1 = add nuw i32 %y, 8
  %add2 = add nuw i32 %add0, %add1
  ret i32 %add2
}

; CHECK-LABEL: @reassoc_x2_mul_nuw(
; CHECK-NEXT: %mul1 = mul i32 %x, %y
; CHECK-NEXT: %mul2 = mul nuw i32 %mul1, 45
define i32 @reassoc_x2_mul_nuw(i32 %x, i32 %y) {
  %mul0 = mul nuw i32 %x, 5
  %mul1 = mul nuw i32 %y, 9
  %mul2 = mul nuw i32 %mul0, %mul1
  ret i32 %mul2
}

; CHECK-LABEL: @reassoc_x2_sub_nuw(
; CHECK-NEXT: %sub0 = add i32 %x, -4
; CHECK-NEXT: %sub1 = add i32 %y, -8
; CHECK-NEXT: %sub2 = sub nuw i32 %sub0, %sub1
define i32 @reassoc_x2_sub_nuw(i32 %x, i32 %y) {
  %sub0 = sub nuw i32 %x, 4
  %sub1 = sub nuw i32 %y, 8
  %sub2 = sub nuw i32 %sub0, %sub1
  ret i32 %sub2
}
