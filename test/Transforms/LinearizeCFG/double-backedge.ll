; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -linearize-cfg %s | FileCheck %s

; Attempt to see multiple backedges from the same loop block.

define void @backedge2() {
; CHECK-LABEL: @backedge2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store volatile i32 1, i32 addrspace(1)* null
; CHECK-NEXT:    [[COND0:%.*]] = load volatile i1, i1 addrspace(1)* null
; CHECK-NEXT:    br i1 [[COND0]], label [[HEADER0_GUARD:%.*]], label [[HEADER1_GUARD:%.*]]
; CHECK:       header0.guard:
; CHECK-NEXT:    [[LOOP_SUCC_ID17:%.*]] = phi i32 [ [[LOOP_SUCC_ID18:%.*]], [[LOOP_HEADER0_GUARD_CRIT_EDGE:%.*]] ], [ undef, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[HEADER1_LOAD12:%.*]] = phi i32 [ [[HEADER1_LOAD13:%.*]], [[LOOP_HEADER0_GUARD_CRIT_EDGE]] ], [ undef, [[ENTRY]] ]
; CHECK-NEXT:    [[GUARD_VAR37:%.*]] = phi i32 [ [[GUARD_VAR38:%.*]], [[LOOP_HEADER0_GUARD_CRIT_EDGE]] ], [ 1, [[ENTRY]] ]
; CHECK-NEXT:    [[PHI_PH1:%.*]] = phi i32 [ [[PHI_PH:%.*]], [[LOOP_HEADER0_GUARD_CRIT_EDGE]] ], [ undef, [[ENTRY]] ]
; CHECK-NEXT:    [[GUARD_VAR:%.*]] = phi i32 [ [[LOOP_SUCC_ID18]], [[LOOP_HEADER0_GUARD_CRIT_EDGE]] ], [ 1, [[ENTRY]] ]
; CHECK-NEXT:    [[PREV_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR]], 1
; CHECK-NEXT:    br i1 [[PREV_GUARD]], label [[HEADER0:%.*]], label [[LOOP_GUARD:%.*]]
; CHECK:       header0:
; CHECK-NEXT:    [[HEADER0_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[LOOP_GUARD]]
; CHECK:       header1.guard:
; CHECK-NEXT:    [[LOOP_SUCC_ID16:%.*]] = phi i32 [ undef, [[ENTRY]] ], [ [[LOOP_SUCC_ID18]], [[LOOP_HEADER0_GUARD_CRIT_EDGE]] ]
; CHECK-NEXT:    [[HEADER1_LOAD11:%.*]] = phi i32 [ undef, [[ENTRY]] ], [ [[HEADER1_LOAD13]], [[LOOP_HEADER0_GUARD_CRIT_EDGE]] ]
; CHECK-NEXT:    [[GUARD_VAR9:%.*]] = phi i32 [ 1, [[ENTRY]] ], [ [[GUARD_VAR4:%.*]], [[LOOP_HEADER0_GUARD_CRIT_EDGE]] ]
; CHECK-NEXT:    [[GUARD_VAR3:%.*]] = phi i32 [ 1, [[ENTRY]] ], [ [[GUARD_VAR38]], [[LOOP_HEADER0_GUARD_CRIT_EDGE]] ]
; CHECK-NEXT:    [[BE_GUARD10:%.*]] = icmp eq i32 [[GUARD_VAR9]], 2
; CHECK-NEXT:    br i1 [[BE_GUARD10]], label [[HEADER1:%.*]], label [[HEADER1_SPLIT:%.*]]
; CHECK:       header1:
; CHECK-NEXT:    [[HEADER1_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[HEADER1_SPLIT]]
; CHECK:       header1.split:
; CHECK-NEXT:    [[HEADER1_LOAD14:%.*]] = phi i32 [ [[HEADER1_LOAD11]], [[HEADER1_GUARD]] ], [ [[HEADER1_LOAD]], [[HEADER1]] ]
; CHECK-NEXT:    [[LAST:%.*]] = icmp eq i32 [[GUARD_VAR9]], 3
; CHECK-NEXT:    br i1 [[LAST]], label [[LOOP_GUARD]], label [[HEADER1]]
; CHECK:       loop.guard:
; CHECK-NEXT:    [[LOOP_SUCC_ID15:%.*]] = phi i32 [ [[LOOP_SUCC_ID16]], [[HEADER1_SPLIT]] ], [ [[LOOP_SUCC_ID17]], [[HEADER0]] ], [ [[LOOP_SUCC_ID17]], [[HEADER0_GUARD]] ]
; CHECK-NEXT:    [[HEADER1_LOAD13]] = phi i32 [ [[HEADER1_LOAD14]], [[HEADER1_SPLIT]] ], [ [[HEADER1_LOAD12]], [[HEADER0]] ], [ [[HEADER1_LOAD12]], [[HEADER0_GUARD]] ]
; CHECK-NEXT:    [[GUARD_VAR36:%.*]] = phi i32 [ [[GUARD_VAR3]], [[HEADER1_SPLIT]] ], [ [[GUARD_VAR37]], [[HEADER0]] ], [ [[GUARD_VAR37]], [[HEADER0_GUARD]] ]
; CHECK-NEXT:    [[GUARD_VAR2:%.*]] = phi i32 [ [[GUARD_VAR3]], [[HEADER1_SPLIT]] ], [ 3, [[HEADER0]] ], [ [[GUARD_VAR]], [[HEADER0_GUARD]] ]
; CHECK-NEXT:    [[PHI_PH]] = phi i32 [ [[HEADER1_LOAD14]], [[HEADER1_SPLIT]] ], [ [[HEADER0_LOAD]], [[HEADER0]] ], [ [[PHI_PH1]], [[HEADER0_GUARD]] ]
; CHECK-NEXT:    [[BE_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR2]], 3
; CHECK-NEXT:    br i1 [[BE_GUARD]], label [[LOOP:%.*]], label [[LOOP_HEADER0_GUARD_CRIT_EDGE]]
; CHECK:       loop:
; CHECK-NEXT:    [[PHI:%.*]] = phi i32 [ [[PHI_PH]], [[LOOP_GUARD]] ]
; CHECK-NEXT:    store volatile i32 [[PHI]], i32 addrspace(1)* null
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1 addrspace(1)* null
; CHECK-NEXT:    [[LOOP_SUCC_ID:%.*]] = select i1 [[COND1]], i32 3, i32 2
; CHECK-NEXT:    br label [[LOOP_HEADER0_GUARD_CRIT_EDGE]]
; CHECK:       loop.header0.guard_crit_edge:
; CHECK-NEXT:    [[LOOP_SUCC_ID18]] = phi i32 [ [[LOOP_SUCC_ID15]], [[LOOP_GUARD]] ], [ [[LOOP_SUCC_ID]], [[LOOP]] ]
; CHECK-NEXT:    [[GUARD_VAR38]] = phi i32 [ [[GUARD_VAR36]], [[LOOP_GUARD]] ], [ [[LOOP_SUCC_ID]], [[LOOP]] ]
; CHECK-NEXT:    [[GUARD_VAR4]] = phi i32 [ [[GUARD_VAR2]], [[LOOP_GUARD]] ], [ [[LOOP_SUCC_ID]], [[LOOP]] ]
; CHECK-NEXT:    [[PREV_GUARD5:%.*]] = icmp eq i32 [[GUARD_VAR4]], 1
; CHECK-NEXT:    br i1 [[PREV_GUARD5]], label [[HEADER0_GUARD]], label [[HEADER1_GUARD]]
;
entry:
  store volatile i32 1, i32 addrspace(1)* null
  %cond0 = load volatile i1, i1 addrspace(1)* null
  br i1 %cond0, label %header0, label %header1

header0:
  %header0.load = load volatile i32, i32 addrspace(1)* null
  br label %loop

header1:
  %header1.load = load volatile i32, i32 addrspace(1)* null
  br label %loop

loop:
  %phi = phi i32 [ %header0.load, %header0 ], [ %header1.load, %header1 ]
  store volatile i32 %phi, i32 addrspace(1)* null
  %cond1 = load volatile i1, i1 addrspace(1)* null
  br i1 %cond1, label %header0, label %header1
}

define void @self_loop_2x() {
; CHECK-LABEL: @self_loop_2x(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store volatile i32 1, i32 addrspace(1)* null
; CHECK-NEXT:    [[COND0:%.*]] = load volatile i1, i1 addrspace(1)* null
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[PHI:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ 1, [[LOOP]] ], [ 1, [[LOOP]] ]
; CHECK-NEXT:    store volatile i32 [[PHI]], i32 addrspace(1)* null
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1 addrspace(1)* null
; CHECK-NEXT:    br i1 [[COND1]], label [[LOOP]], label [[LOOP]]
;
entry:
  store volatile i32 1, i32 addrspace(1)* null
  %cond0 = load volatile i1, i1 addrspace(1)* null
  br label %loop

loop:
  %phi = phi i32 [ 0, %entry ], [ 1, %loop ], [ 1, %loop ]
  store volatile i32 %phi, i32 addrspace(1)* null
  %cond1 = load volatile i1, i1 addrspace(1)* null
  br i1 %cond1, label %loop, label %loop
}
