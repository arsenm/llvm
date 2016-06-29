; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

define i1 @t1(float %x, float %y) {
; CHECK-LABEL: @t1(
; CHECK-NEXT:    [[TMP1:%.*]] = fcmp ueq float %x, %y
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %a = fcmp ueq float %x, %y
  %b = fcmp uno float %x, %y
  %c = or i1 %a, %b
  ret i1 %c
}

define i1 @t2(float %x, float %y) {
; CHECK-LABEL: @t2(
; CHECK-NEXT:    [[TMP1:%.*]] = fcmp ole float %x, %y
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %a = fcmp olt float %x, %y
  %b = fcmp oeq float %x, %y
  %c = or i1 %a, %b
  ret i1 %c
}

define i1 @t3(float %x, float %y) {
; CHECK-LABEL: @t3(
; CHECK-NEXT:    ret i1 true
;
  %a = fcmp ult float %x, %y
  %b = fcmp uge float %x, %y
  %c = or i1 %a, %b
  ret i1 %c
}

define i1 @t4(float %x, float %y) {
; CHECK-LABEL: @t4(
; CHECK-NEXT:    [[TMP1:%.*]] = fcmp une float %x, %y
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %a = fcmp ult float %x, %y
  %b = fcmp ugt float %x, %y
  %c = or i1 %a, %b
  ret i1 %c
}

define i1 @t5(float %x, float %y) {
; CHECK-LABEL: @t5(
; CHECK-NEXT:    [[TMP1:%.*]] = fcmp ord float %x, %y
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %a = fcmp olt float %x, %y
  %b = fcmp oge float %x, %y
  %c = or i1 %a, %b
  ret i1 %c
}
