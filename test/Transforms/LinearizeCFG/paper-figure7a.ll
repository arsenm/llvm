; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -linearize-cfg %s | FileCheck %s


; Unstructured blocks: b2, b3, b4, b5, b6, b7

define void @figure7a() {
; CHECK-LABEL: @figure7a(
; CHECK-NEXT:  b1:
; CHECK-NEXT:    store volatile i32 0, i32 addrspace(1)* undef
; CHECK-NEXT:    [[COND0:%.*]] = load volatile i1, i1 addrspace(1)* undef
; CHECK-NEXT:    br i1 [[COND0]], label [[B5:%.*]], label [[B2:%.*]]
; CHECK:       b2:
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1 addrspace(1)* undef
; CHECK-NEXT:    br i1 [[COND1]], label [[B4:%.*]], label [[B3:%.*]]
; CHECK:       b3:
; CHECK-NEXT:    [[COND2:%.*]] = load volatile i1, i1 addrspace(1)* undef
; CHECK-NEXT:    br label [[BB8:%.*]]
; CHECK:       b4:
; CHECK-NEXT:    store volatile i32 4, i32 addrspace(1)* undef
; CHECK-NEXT:    br label [[BB8]]
; CHECK:       b5:
; CHECK-NEXT:    store volatile i32 5, i32 addrspace(1)* undef
; CHECK-NEXT:    [[COND3:%.*]] = load volatile i1, i1 addrspace(1)* undef
; CHECK-NEXT:    br i1 [[COND3]], label [[B7:%.*]], label [[B6:%.*]]
; CHECK:       b6:
; CHECK-NEXT:    store volatile i32 6, i32 addrspace(1)* undef
; CHECK-NEXT:    br label [[BB8]]
; CHECK:       b7:
; CHECK-NEXT:    store volatile i32 7, i32 addrspace(1)* undef
; CHECK-NEXT:    br label [[BB8]]
; CHECK:       bb8:
; CHECK-NEXT:    ret void
;
b1:
  store volatile i32 0, i32 addrspace(1)* undef
  %cond0 = load volatile i1, i1 addrspace(1)* undef
  br i1 %cond0, label %b5, label %b2

b2:
  %cond1 = load volatile i1, i1 addrspace(1)* undef
  br i1 %cond1, label %b4, label %b3

b3:
  %cond2 = load volatile i1, i1 addrspace(1)* undef
  br label %bb8

b4:
  store volatile i32 4, i32 addrspace(1)* undef
  br label %bb8

b5:
  store volatile i32 5, i32 addrspace(1)* undef
  %cond3 = load volatile i1, i1 addrspace(1)* undef
  br i1 %cond3, label %b7, label %b6

b6:
  store volatile i32 6, i32 addrspace(1)* undef
  br label %bb8

b7:
  store volatile i32 7, i32 addrspace(1)* undef
  br label %bb8

bb8:
  ret void
}

; Has structured outer branch
define void @nested_figure7a(i1 %cond.outer) {
; CHECK-LABEL: @nested_figure7a(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[COND_OUTER:%.*]], label [[B1:%.*]], label [[EXIT:%.*]]
; CHECK:       b1:
; CHECK-NEXT:    store volatile i32 0, i32 addrspace(1)* undef
; CHECK-NEXT:    [[COND0:%.*]] = load volatile i1, i1 addrspace(1)* undef
; CHECK-NEXT:    br i1 [[COND0]], label [[B5:%.*]], label [[B2:%.*]]
; CHECK:       b2:
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1 addrspace(1)* undef
; CHECK-NEXT:    br i1 [[COND1]], label [[B4:%.*]], label [[B3:%.*]]
; CHECK:       b3:
; CHECK-NEXT:    [[COND2:%.*]] = load volatile i1, i1 addrspace(1)* undef
; CHECK-NEXT:    br label [[BB8:%.*]]
; CHECK:       b4:
; CHECK-NEXT:    store volatile i32 4, i32 addrspace(1)* undef
; CHECK-NEXT:    br label [[BB8]]
; CHECK:       b5:
; CHECK-NEXT:    store volatile i32 5, i32 addrspace(1)* undef
; CHECK-NEXT:    [[COND3:%.*]] = load volatile i1, i1 addrspace(1)* undef
; CHECK-NEXT:    br i1 [[COND3]], label [[B7:%.*]], label [[B6:%.*]]
; CHECK:       b6:
; CHECK-NEXT:    store volatile i32 6, i32 addrspace(1)* undef
; CHECK-NEXT:    br label [[BB8]]
; CHECK:       b7:
; CHECK-NEXT:    store volatile i32 7, i32 addrspace(1)* undef
; CHECK-NEXT:    br label [[BB8]]
; CHECK:       bb8:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br i1 %cond.outer, label %b1, label %exit

b1:
  store volatile i32 0, i32 addrspace(1)* undef
  %cond0 = load volatile i1, i1 addrspace(1)* undef
  br i1 %cond0, label %b5, label %b2

b2:
  %cond1 = load volatile i1, i1 addrspace(1)* undef
  br i1 %cond1, label %b4, label %b3

b3:
  %cond2 = load volatile i1, i1 addrspace(1)* undef
  br label %bb8

b4:
  store volatile i32 4, i32 addrspace(1)* undef
  br label %bb8

b5:
  store volatile i32 5, i32 addrspace(1)* undef
  %cond3 = load volatile i1, i1 addrspace(1)* undef
  br i1 %cond3, label %b7, label %b6

b6:
  store volatile i32 6, i32 addrspace(1)* undef
  br label %bb8

b7:
  store volatile i32 7, i32 addrspace(1)* undef
  br label %bb8

bb8:
  br label %exit

exit:
  ret void
}
