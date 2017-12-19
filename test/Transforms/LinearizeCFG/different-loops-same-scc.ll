; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -linearize-cfg %s | FileCheck %s

; nested loops such that loops in same scc but different proper loops
define void @different_loops_same_scc(i32 %n) {
; CHECK-LABEL: @different_loops_same_scc(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[B1:%.*]]
; CHECK:       b1:
; CHECK-NEXT:    [[B1_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* undef
; CHECK-NEXT:    br label [[B2:%.*]]
; CHECK:       b2:
; CHECK-NEXT:    [[I_INC15:%.*]] = phi i32 [ [[I_INC16:%.*]], [[B4_SPLIT:%.*]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[INNER_LOOP_SUCC_ID12:%.*]] = phi i32 [ [[INNER_LOOP_SUCC_ID14:%.*]], [[B4_SPLIT]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[I_PH:%.*]] = phi i32 [ [[I_INC16]], [[B4_SPLIT]] ], [ 0, [[B1]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I_PH]], [[N:%.*]]
; CHECK-NEXT:    [[B2_SUCC_ID:%.*]] = select i1 [[CMP]], i32 3, i32 6
; CHECK-NEXT:    br label [[B5_GUARD:%.*]]
; CHECK:       b3.guard:
; CHECK-NEXT:    [[GUARD_VAR3:%.*]] = phi i32 [ 7, [[B5:%.*]] ], [ [[B2_SUCC_ID]], [[B5_GUARD]] ]
; CHECK-NEXT:    [[PREV_GUARD4:%.*]] = icmp eq i32 [[GUARD_VAR3]], 3
; CHECK-NEXT:    br i1 [[PREV_GUARD4]], label [[B3:%.*]], label [[B6_GUARD:%.*]]
; CHECK:       b3:
; CHECK-NEXT:    store volatile i32 3, i32 addrspace(1)* undef
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1 addrspace(1)* undef
; CHECK-NEXT:    [[B3_SUCC_ID:%.*]] = select i1 [[COND1]], i32 4, i32 7
; CHECK-NEXT:    br label [[B6_GUARD]]
; CHECK:       inner.loop.guard:
; CHECK-NEXT:    [[INNER_LOOP_SUCC_ID13:%.*]] = phi i32 [ [[INNER_LOOP_SUCC_ID12]], [[B6_GUARD]] ], [ [[INNER_LOOP_SUCC_ID14]], [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE:%.*]] ]
; CHECK-NEXT:    [[GUARD_VAR7:%.*]] = phi i32 [ [[GUARD_VAR5:%.*]], [[B6_GUARD]] ], [ [[INNER_LOOP_SUCC_ID14]], [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE]] ]
; CHECK-NEXT:    [[BE_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR7]], 4
; CHECK-NEXT:    br i1 [[BE_GUARD]], label [[INNER_LOOP:%.*]], label [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE]]
; CHECK:       inner.loop:
; CHECK-NEXT:    [[INNER_COND:%.*]] = load i1, i1 addrspace(1)* undef
; CHECK-NEXT:    [[INNER_LOOP_SUCC_ID:%.*]] = select i1 [[INNER_COND]], i32 4, i32 5
; CHECK-NEXT:    br label [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE]]
; CHECK:       inner.loop.inner.loop.guard_crit_edge:
; CHECK-NEXT:    [[INNER_LOOP_SUCC_ID14]] = phi i32 [ [[INNER_LOOP_SUCC_ID13]], [[INNER_LOOP_GUARD:%.*]] ], [ [[INNER_LOOP_SUCC_ID]], [[INNER_LOOP]] ]
; CHECK-NEXT:    [[GUARD_VAR8:%.*]] = phi i32 [ [[GUARD_VAR7]], [[INNER_LOOP_GUARD]] ], [ [[INNER_LOOP_SUCC_ID]], [[INNER_LOOP]] ]
; CHECK-NEXT:    [[PREV_GUARD9:%.*]] = icmp eq i32 [[GUARD_VAR8]], 4
; CHECK-NEXT:    br i1 [[PREV_GUARD9]], label [[INNER_LOOP_GUARD]], label [[B4_GUARD:%.*]]
; CHECK:       b4.guard:
; CHECK-NEXT:    [[BE_GUARD11:%.*]] = icmp eq i32 [[GUARD_VAR8]], 5
; CHECK-NEXT:    br i1 [[BE_GUARD11]], label [[B4:%.*]], label [[B4_SPLIT]]
; CHECK:       b4:
; CHECK-NEXT:    store volatile i32 4, i32 addrspace(1)* undef
; CHECK-NEXT:    [[I_INC:%.*]] = add nsw i32 [[I_PH]], 1
; CHECK-NEXT:    br label [[B4_SPLIT]]
; CHECK:       b4.split:
; CHECK-NEXT:    [[I_INC16]] = phi i32 [ [[I_INC15]], [[B4_GUARD]] ], [ [[I_INC]], [[B4]] ]
; CHECK-NEXT:    [[LAST:%.*]] = icmp eq i32 [[GUARD_VAR8]], 2
; CHECK-NEXT:    br i1 [[LAST]], label [[B2]], label [[B6:%.*]]
; CHECK:       b5.guard:
; CHECK-NEXT:    [[PREV_GUARD2:%.*]] = icmp eq i32 [[B2_SUCC_ID]], 6
; CHECK-NEXT:    br i1 [[PREV_GUARD2]], label [[B5]], label [[B3_GUARD:%.*]]
; CHECK:       b5:
; CHECK-NEXT:    store volatile i32 5, i32 addrspace(1)* undef
; CHECK-NEXT:    br label [[B3_GUARD]]
; CHECK:       b6.guard:
; CHECK-NEXT:    [[GUARD_VAR5]] = phi i32 [ [[GUARD_VAR3]], [[B3_GUARD]] ], [ [[B3_SUCC_ID]], [[B3]] ]
; CHECK-NEXT:    [[PREV_GUARD6:%.*]] = icmp eq i32 [[GUARD_VAR5]], 7
; CHECK-NEXT:    br i1 [[PREV_GUARD6]], label [[B6]], label [[INNER_LOOP_GUARD]]
; CHECK:       b6:
; CHECK-NEXT:    store volatile i32 6, i32 addrspace(1)* undef
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %b1

b1:
  %b1.load = load volatile i32, i32 addrspace(1)* undef
  br label %b2

b2:
  %i = phi i32 [ 0, %b1 ], [ %i.inc, %b4 ]
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %b3, label %b5

b3:
  store volatile i32 3, i32 addrspace(1)* undef
  %cond1 = load volatile i1, i1 addrspace(1)* undef
  br i1 %cond1, label %inner.loop, label %b6

inner.loop:
  %inner.cond = load i1, i1 addrspace(1)* undef
  br i1 %inner.cond, label %inner.loop, label %b4

b4:
  store volatile i32 4, i32 addrspace(1)* undef
  %i.inc = add nsw i32 %i, 1
  br label %b2

b5:
  store volatile i32 5, i32 addrspace(1)* undef
  br label %b6

b6:
  store volatile i32 6, i32 addrspace(1)* undef
  br label %exit

exit:
  ret void
}

define void @different_loops_same_scc_ext(i32 %n) {
; CHECK-LABEL: @different_loops_same_scc_ext(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[B1:%.*]]
; CHECK:       b1:
; CHECK-NEXT:    [[B1_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* undef
; CHECK-NEXT:    br label [[B2:%.*]]
; CHECK:       b2:
; CHECK-NEXT:    [[I_INC14:%.*]] = phi i32 [ [[I_INC15:%.*]], [[B4_SPLIT:%.*]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[INNER_LOOP_SUCC_ID11:%.*]] = phi i32 [ [[INNER_LOOP_SUCC_ID13:%.*]], [[B4_SPLIT]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[I_PH:%.*]] = phi i32 [ [[I_INC15]], [[B4_SPLIT]] ], [ 0, [[B1]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I_PH]], [[N:%.*]]
; CHECK-NEXT:    [[B2_SUCC_ID:%.*]] = select i1 [[CMP]], i32 3, i32 6
; CHECK-NEXT:    br label [[B5_GUARD:%.*]]
; CHECK:       b3.guard:
; CHECK-NEXT:    [[PREV_GUARD3:%.*]] = icmp eq i32 [[B2_SUCC_ID]], 3
; CHECK-NEXT:    br i1 [[PREV_GUARD3]], label [[B3:%.*]], label [[B6_GUARD:%.*]]
; CHECK:       b3:
; CHECK-NEXT:    store volatile i32 3, i32 addrspace(1)* undef
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1 addrspace(1)* undef
; CHECK-NEXT:    [[B3_SUCC_ID:%.*]] = select i1 [[COND1]], i32 4, i32 7
; CHECK-NEXT:    br i1 [[COND1]], label [[INNER_LOOP_GUARD:%.*]], label [[B6_GUARD]]
; CHECK:       inner.loop.guard:
; CHECK-NEXT:    [[INNER_LOOP_SUCC_ID12:%.*]] = phi i32 [ [[INNER_LOOP_SUCC_ID11]], [[B6_GUARD]] ], [ [[INNER_LOOP_SUCC_ID11]], [[B5:%.*]] ], [ [[INNER_LOOP_SUCC_ID13]], [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE:%.*]] ], [ [[INNER_LOOP_SUCC_ID11]], [[B3]] ]
; CHECK-NEXT:    [[GUARD_VAR6:%.*]] = phi i32 [ [[GUARD_VAR4:%.*]], [[B6_GUARD]] ], [ [[B5_SUCC_ID:%.*]], [[B5]] ], [ [[INNER_LOOP_SUCC_ID13]], [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE]] ], [ [[B3_SUCC_ID]], [[B3]] ]
; CHECK-NEXT:    [[BE_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR6]], 4
; CHECK-NEXT:    br i1 [[BE_GUARD]], label [[INNER_LOOP:%.*]], label [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE]]
; CHECK:       inner.loop:
; CHECK-NEXT:    [[INNER_COND:%.*]] = load i1, i1 addrspace(1)* undef
; CHECK-NEXT:    [[INNER_LOOP_SUCC_ID:%.*]] = select i1 [[INNER_COND]], i32 4, i32 5
; CHECK-NEXT:    br label [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE]]
; CHECK:       inner.loop.inner.loop.guard_crit_edge:
; CHECK-NEXT:    [[INNER_LOOP_SUCC_ID13]] = phi i32 [ [[INNER_LOOP_SUCC_ID12]], [[INNER_LOOP_GUARD]] ], [ [[INNER_LOOP_SUCC_ID]], [[INNER_LOOP]] ]
; CHECK-NEXT:    [[GUARD_VAR7:%.*]] = phi i32 [ [[GUARD_VAR6]], [[INNER_LOOP_GUARD]] ], [ [[INNER_LOOP_SUCC_ID]], [[INNER_LOOP]] ]
; CHECK-NEXT:    [[PREV_GUARD8:%.*]] = icmp eq i32 [[GUARD_VAR7]], 4
; CHECK-NEXT:    br i1 [[PREV_GUARD8]], label [[INNER_LOOP_GUARD]], label [[B4_GUARD:%.*]]
; CHECK:       b4.guard:
; CHECK-NEXT:    [[BE_GUARD10:%.*]] = icmp eq i32 [[GUARD_VAR7]], 5
; CHECK-NEXT:    br i1 [[BE_GUARD10]], label [[B4:%.*]], label [[B4_SPLIT]]
; CHECK:       b4:
; CHECK-NEXT:    store volatile i32 4, i32 addrspace(1)* undef
; CHECK-NEXT:    [[I_INC:%.*]] = add nsw i32 [[I_PH]], 1
; CHECK-NEXT:    br label [[B4_SPLIT]]
; CHECK:       b4.split:
; CHECK-NEXT:    [[I_INC15]] = phi i32 [ [[I_INC14]], [[B4_GUARD]] ], [ [[I_INC]], [[B4]] ]
; CHECK-NEXT:    [[LAST:%.*]] = icmp eq i32 [[GUARD_VAR7]], 2
; CHECK-NEXT:    br i1 [[LAST]], label [[B2]], label [[B6:%.*]]
; CHECK:       b5.guard:
; CHECK-NEXT:    [[PREV_GUARD2:%.*]] = icmp eq i32 [[B2_SUCC_ID]], 6
; CHECK-NEXT:    br i1 [[PREV_GUARD2]], label [[B5]], label [[B3_GUARD:%.*]]
; CHECK:       b5:
; CHECK-NEXT:    store volatile i32 5, i32 addrspace(1)* undef
; CHECK-NEXT:    [[ARST:%.*]] = load i1, i1 addrspace(1)* undef
; CHECK-NEXT:    [[B5_SUCC_ID]] = select i1 [[ARST]], i32 4, i32 7
; CHECK-NEXT:    br label [[INNER_LOOP_GUARD]]
; CHECK:       b6.guard:
; CHECK-NEXT:    [[GUARD_VAR4]] = phi i32 [ [[B2_SUCC_ID]], [[B3_GUARD]] ], [ [[B3_SUCC_ID]], [[B3]] ]
; CHECK-NEXT:    [[PREV_GUARD5:%.*]] = icmp eq i32 [[GUARD_VAR4]], 7
; CHECK-NEXT:    br i1 [[PREV_GUARD5]], label [[B6]], label [[INNER_LOOP_GUARD]]
; CHECK:       b6:
; CHECK-NEXT:    store volatile i32 6, i32 addrspace(1)* undef
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %b1

b1:
  %b1.load = load volatile i32, i32 addrspace(1)* undef
  br label %b2

b2:
  %i = phi i32 [ 0, %b1 ], [ %i.inc, %b4 ]
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %b3, label %b5

b3:
  store volatile i32 3, i32 addrspace(1)* undef
  %cond1 = load volatile i1, i1 addrspace(1)* undef
  br i1 %cond1, label %inner.loop, label %b6

inner.loop:
  %inner.cond = load i1, i1 addrspace(1)* undef
  br i1 %inner.cond, label %inner.loop, label %b4

b4:
  store volatile i32 4, i32 addrspace(1)* undef
  %i.inc = add nsw i32 %i, 1
  br label %b2

b5:
  store volatile i32 5, i32 addrspace(1)* undef
  %arst = load i1, i1 addrspace(1)* undef
  br i1 %arst, label %inner.loop, label %b6

b6:
  store volatile i32 6, i32 addrspace(1)* undef
  br label %exit

exit:
  ret void
}
