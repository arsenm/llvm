; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -linearize-cfg %s | FileCheck %s

; unstructured: b3->b6, b2->b5
define void @figure5b(i32 %n) {
; CHECK-LABEL: @figure5b(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[B1:%.*]]
; CHECK:       b1:
; CHECK-NEXT:    [[B1_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B2_GUARD:%.*]]
; CHECK:       b2.guard:
; CHECK-NEXT:    [[I_INC10:%.*]] = phi i32 [ [[I_INC11:%.*]], [[B4_SPLIT:%.*]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[I8:%.*]] = phi i32 [ [[I9:%.*]], [[B4_SPLIT]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[GUARD_VAR:%.*]] = phi i32 [ 2, [[B4_SPLIT]] ], [ 2, [[B1]] ]
; CHECK-NEXT:    [[I_PH:%.*]] = phi i32 [ [[I_INC11]], [[B4_SPLIT]] ], [ 0, [[B1]] ]
; CHECK-NEXT:    [[PREV_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR]], 2
; CHECK-NEXT:    br i1 [[PREV_GUARD]], label [[B2:%.*]], label [[B3_GUARD:%.*]]
; CHECK:       b2:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[I_PH]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; CHECK-NEXT:    [[TMP0:%.*]] = select i1 [[CMP]], i32 5, i32 3
; CHECK-NEXT:    br i1 [[CMP]], label [[B5_GUARD:%.*]], label [[B3_GUARD]]
; CHECK:       b3.guard:
; CHECK-NEXT:    [[I9]] = phi i32 [ [[I8]], [[B2_GUARD]] ], [ [[I]], [[B2]] ]
; CHECK-NEXT:    [[GUARD_VAR1:%.*]] = phi i32 [ [[GUARD_VAR]], [[B2_GUARD]] ], [ [[TMP0]], [[B2]] ]
; CHECK-NEXT:    [[PREV_GUARD2:%.*]] = icmp eq i32 [[GUARD_VAR1]], 3
; CHECK-NEXT:    br i1 [[PREV_GUARD2]], label [[B3:%.*]], label [[B4_GUARD:%.*]]
; CHECK:       b3:
; CHECK-NEXT:    store volatile i32 3, i32 addrspace(1)* null
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1 addrspace(1)* null
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[COND1]], i32 4, i32 6
; CHECK-NEXT:    br label [[B4_GUARD]]
; CHECK:       b4.guard:
; CHECK-NEXT:    [[GUARD_VAR3:%.*]] = phi i32 [ [[GUARD_VAR1]], [[B3_GUARD]] ], [ [[TMP1]], [[B3]] ]
; CHECK-NEXT:    [[BE_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR3]], 4
; CHECK-NEXT:    br i1 [[BE_GUARD]], label [[B4:%.*]], label [[B4_SPLIT]]
; CHECK:       b4:
; CHECK-NEXT:    store volatile i32 4, i32 addrspace(1)* null
; CHECK-NEXT:    [[I_INC:%.*]] = add nsw i32 [[I9]], 1
; CHECK-NEXT:    br label [[B4_SPLIT]]
; CHECK:       b4.split:
; CHECK-NEXT:    [[I_INC11]] = phi i32 [ [[I_INC10]], [[B4_GUARD]] ], [ [[I_INC]], [[B4]] ]
; CHECK-NEXT:    [[GUARD_VAR4:%.*]] = phi i32 [ [[GUARD_VAR3]], [[B4_GUARD]] ], [ 4, [[B4]] ]
; CHECK-NEXT:    [[PREV_GUARD5:%.*]] = icmp eq i32 [[GUARD_VAR4]], 2
; CHECK-NEXT:    br i1 [[PREV_GUARD5]], label [[B2_GUARD]], label [[B5_GUARD]]
; CHECK:       b5.guard:
; CHECK-NEXT:    [[GUARD_VAR6:%.*]] = phi i32 [ [[GUARD_VAR4]], [[B4_SPLIT]] ], [ [[TMP0]], [[B2]] ]
; CHECK-NEXT:    [[PREV_GUARD7:%.*]] = icmp eq i32 [[GUARD_VAR6]], 5
; CHECK-NEXT:    br i1 [[PREV_GUARD7]], label [[B5:%.*]], label [[B6_GUARD:%.*]]
; CHECK:       b5:
; CHECK-NEXT:    store volatile i32 5, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B6_GUARD]]
; CHECK:       b6.guard:
; CHECK-NEXT:    br label [[B6:%.*]]
; CHECK:       b6:
; CHECK-NEXT:    store volatile i32 6, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %b1

b1:
  %b1.load = load volatile i32, i32 addrspace(1)* null
  br label %b2

b2:
  %i = phi i32 [ 0, %b1 ], [ %i.inc, %b4 ]
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %b5, label %b3

b3:
  store volatile i32 3, i32 addrspace(1)* null
  %cond1 = load volatile i1, i1 addrspace(1)* null
  br i1 %cond1, label %b4, label %b6

b4:
  store volatile i32 4, i32 addrspace(1)* null
  %i.inc = add nsw i32 %i, 1
  br label %b2

b5:
  store volatile i32 5, i32 addrspace(1)* null
  br label %b6

b6:
  store volatile i32 6, i32 addrspace(1)* null
  br label %exit

exit:
  ret void
}

define void @figure5b_add_b5_to_b3(i32 %n) {
; CHECK-LABEL: @figure5b_add_b5_to_b3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[B1:%.*]]
; CHECK:       b1:
; CHECK-NEXT:    [[B1_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B2_GUARD:%.*]]
; CHECK:       b2.guard:
; CHECK-NEXT:    [[I8:%.*]] = phi i32 [ [[I9:%.*]], [[B4_SPLIT:%.*]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[GUARD_VAR:%.*]] = phi i32 [ 2, [[B4_SPLIT]] ], [ 2, [[B1]] ]
; CHECK-NEXT:    [[I_PH:%.*]] = phi i32 [ [[I_INC:%.*]], [[B4_SPLIT]] ], [ 0, [[B1]] ]
; CHECK-NEXT:    [[PREV_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR]], 2
; CHECK-NEXT:    br i1 [[PREV_GUARD]], label [[B2:%.*]], label [[B5_GUARD:%.*]]
; CHECK:       b2:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[I_PH]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; CHECK-NEXT:    [[TMP0:%.*]] = select i1 [[CMP]], i32 3, i32 5
; CHECK-NEXT:    br label [[B5_GUARD]]
; CHECK:       b3.guard:
; CHECK-NEXT:    [[GUARD_VAR3:%.*]] = phi i32 [ [[GUARD_VAR1:%.*]], [[B5_GUARD]] ], [ [[TMP2:%.*]], [[B5:%.*]] ]
; CHECK-NEXT:    [[PREV_GUARD4:%.*]] = icmp eq i32 [[GUARD_VAR3]], 3
; CHECK-NEXT:    br i1 [[PREV_GUARD4]], label [[B3:%.*]], label [[B6_GUARD:%.*]]
; CHECK:       b3:
; CHECK-NEXT:    store volatile i32 3, i32 addrspace(1)* null
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1 addrspace(1)* null
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[COND1]], i32 4, i32 6
; CHECK-NEXT:    br label [[B6_GUARD]]
; CHECK:       b4.guard:
; CHECK-NEXT:    [[LAST:%.*]] = icmp eq i32 [[GUARD_VAR5:%.*]], 4
; CHECK-NEXT:    br i1 [[LAST]], label [[B4:%.*]], label [[B6:%.*]]
; CHECK:       b4:
; CHECK-NEXT:    store volatile i32 4, i32 addrspace(1)* null
; CHECK-NEXT:    [[I_INC]] = add nsw i32 [[I9]], 1
; CHECK-NEXT:    br label [[B4_SPLIT]]
; CHECK:       b4.split:
; CHECK-NEXT:    br label [[B2_GUARD]]
; CHECK:       b5.guard:
; CHECK-NEXT:    [[I9]] = phi i32 [ [[I8]], [[B2_GUARD]] ], [ [[I]], [[B2]] ]
; CHECK-NEXT:    [[GUARD_VAR1]] = phi i32 [ [[GUARD_VAR]], [[B2_GUARD]] ], [ [[TMP0]], [[B2]] ]
; CHECK-NEXT:    [[PREV_GUARD2:%.*]] = icmp eq i32 [[GUARD_VAR1]], 5
; CHECK-NEXT:    br i1 [[PREV_GUARD2]], label [[B5]], label [[B3_GUARD:%.*]]
; CHECK:       b5:
; CHECK-NEXT:    store volatile i32 5, i32 addrspace(1)* null
; CHECK-NEXT:    [[COND2:%.*]] = load volatile i1, i1 addrspace(1)* null
; CHECK-NEXT:    [[TMP2]] = select i1 [[COND2]], i32 6, i32 3
; CHECK-NEXT:    br label [[B3_GUARD]]
; CHECK:       b6.guard:
; CHECK-NEXT:    [[GUARD_VAR5]] = phi i32 [ [[GUARD_VAR3]], [[B3_GUARD]] ], [ [[TMP1]], [[B3]] ]
; CHECK-NEXT:    [[PREV_GUARD6:%.*]] = icmp eq i32 [[GUARD_VAR5]], 6
; CHECK-NEXT:    br i1 [[PREV_GUARD6]], label [[B6]], label [[B4_GUARD:%.*]]
; CHECK:       b6:
; CHECK-NEXT:    store volatile i32 6, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %b1

b1:
  %b1.load = load volatile i32, i32 addrspace(1)* null
  br label %b2

b2:
  %i = phi i32 [ 0, %b1 ], [ %i.inc, %b4 ]
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %b3, label %b5

b3:
  store volatile i32 3, i32 addrspace(1)* null
  %cond1 = load volatile i1, i1 addrspace(1)* null
  br i1 %cond1, label %b4, label %b6

b4:
  store volatile i32 4, i32 addrspace(1)* null
  %i.inc = add nsw i32 %i, 1
  br label %b2

b5:
  store volatile i32 5, i32 addrspace(1)* null
  %cond2 = load volatile i1, i1 addrspace(1)* null
  br i1 %cond2, label %b6, label %b3

b6:
  store volatile i32 6, i32 addrspace(1)* null
  br label %exit

exit:
  ret void
}

; ; b5 is in a different loop
define void @figure5b_branch_other_loop(i32 %n) {
; CHECK-LABEL: @figure5b_branch_other_loop(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[B1:%.*]]
; CHECK:       b1:
; CHECK-NEXT:    [[B1_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B2_GUARD:%.*]]
; CHECK:       b2.guard:
; CHECK-NEXT:    [[TMP0:%.*]] = phi i32 [ [[TMP3:%.*]], [[B4_SPLIT:%.*]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[TMP1:%.*]] = phi i32 [ [[TMP8:%.*]], [[B4_SPLIT]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[I16:%.*]] = phi i32 [ [[I17:%.*]], [[B4_SPLIT]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[GUARD_VAR:%.*]] = phi i32 [ 2, [[B4_SPLIT]] ], [ 2, [[B1]] ]
; CHECK-NEXT:    [[I_PH:%.*]] = phi i32 [ [[I_INC:%.*]], [[B4_SPLIT]] ], [ 0, [[B1]] ]
; CHECK-NEXT:    [[PREV_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR]], 2
; CHECK-NEXT:    br i1 [[PREV_GUARD]], label [[B2:%.*]], label [[B5_GUARD:%.*]]
; CHECK:       b2:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[I_PH]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[CMP]], i32 3, i32 6
; CHECK-NEXT:    br i1 [[CMP]], label [[B3_GUARD:%.*]], label [[B5_GUARD]]
; CHECK:       b3.guard:
; CHECK-NEXT:    [[TMP3]] = phi i32 [ [[TMP12:%.*]], [[LOOP2_BODY_B5_GUARD_CRIT_EDGE:%.*]] ], [ [[TMP0]], [[B2]] ]
; CHECK-NEXT:    [[I17]] = phi i32 [ [[I15:%.*]], [[LOOP2_BODY_B5_GUARD_CRIT_EDGE]] ], [ [[I]], [[B2]] ]
; CHECK-NEXT:    [[GUARD_VAR6:%.*]] = phi i32 [ [[GUARD_VAR4:%.*]], [[LOOP2_BODY_B5_GUARD_CRIT_EDGE]] ], [ [[TMP2]], [[B2]] ]
; CHECK-NEXT:    [[PREV_GUARD7:%.*]] = icmp eq i32 [[GUARD_VAR6]], 3
; CHECK-NEXT:    br i1 [[PREV_GUARD7]], label [[B3:%.*]], label [[B6_GUARD:%.*]]
; CHECK:       b3:
; CHECK-NEXT:    store volatile i32 3, i32 addrspace(1)* null
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1 addrspace(1)* null
; CHECK-NEXT:    [[TMP4:%.*]] = select i1 [[COND1]], i32 4, i32 8
; CHECK-NEXT:    br label [[B6_GUARD]]
; CHECK:       inner.loop.guard:
; CHECK-NEXT:    [[TMP5:%.*]] = phi i32 [ [[TMP1]], [[B6_GUARD]] ], [ [[TMP7:%.*]], [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE:%.*]] ]
; CHECK-NEXT:    [[GUARD_VAR10:%.*]] = phi i32 [ [[GUARD_VAR8:%.*]], [[B6_GUARD]] ], [ [[TMP7]], [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE]] ]
; CHECK-NEXT:    [[BE_GUARD11:%.*]] = icmp eq i32 [[GUARD_VAR10]], 4
; CHECK-NEXT:    br i1 [[BE_GUARD11]], label [[INNER_LOOP:%.*]], label [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE]]
; CHECK:       inner.loop:
; CHECK-NEXT:    [[INNER_COND:%.*]] = load i1, i1 addrspace(1)* null
; CHECK-NEXT:    [[TMP6:%.*]] = select i1 [[INNER_COND]], i32 4, i32 5
; CHECK-NEXT:    br i1 [[INNER_COND]], label [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE]], label [[B4_GUARD:%.*]]
; CHECK:       inner.loop.inner.loop.guard_crit_edge:
; CHECK-NEXT:    [[TMP7]] = phi i32 [ [[TMP5]], [[INNER_LOOP_GUARD:%.*]] ], [ [[TMP6]], [[INNER_LOOP]] ]
; CHECK-NEXT:    [[GUARD_VAR12:%.*]] = phi i32 [ [[GUARD_VAR10]], [[INNER_LOOP_GUARD]] ], [ [[TMP6]], [[INNER_LOOP]] ]
; CHECK-NEXT:    [[PREV_GUARD13:%.*]] = icmp eq i32 [[GUARD_VAR12]], 4
; CHECK-NEXT:    br i1 [[PREV_GUARD13]], label [[INNER_LOOP_GUARD]], label [[B4_GUARD]]
; CHECK:       b4.guard:
; CHECK-NEXT:    [[TMP8]] = phi i32 [ [[TMP7]], [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE]] ], [ [[TMP6]], [[INNER_LOOP]] ]
; CHECK-NEXT:    [[GUARD_VAR14:%.*]] = phi i32 [ [[GUARD_VAR12]], [[INNER_LOOP_INNER_LOOP_GUARD_CRIT_EDGE]] ], [ [[TMP6]], [[INNER_LOOP]] ]
; CHECK-NEXT:    [[LAST:%.*]] = icmp eq i32 [[GUARD_VAR14]], 5
; CHECK-NEXT:    br i1 [[LAST]], label [[B4:%.*]], label [[B6:%.*]]
; CHECK:       b4:
; CHECK-NEXT:    store volatile i32 4, i32 addrspace(1)* null
; CHECK-NEXT:    [[I_INC]] = add nsw i32 [[I17]], 1
; CHECK-NEXT:    br label [[B4_SPLIT]]
; CHECK:       b4.split:
; CHECK-NEXT:    br label [[B2_GUARD]]
; CHECK:       b5.guard:
; CHECK-NEXT:    [[TMP9:%.*]] = phi i32 [ [[TMP0]], [[B2_GUARD]] ], [ [[TMP12]], [[LOOP2_BODY_B5_GUARD_CRIT_EDGE]] ], [ [[TMP0]], [[B2]] ]
; CHECK-NEXT:    [[I15]] = phi i32 [ [[I16]], [[B2_GUARD]] ], [ [[I15]], [[LOOP2_BODY_B5_GUARD_CRIT_EDGE]] ], [ [[I]], [[B2]] ]
; CHECK-NEXT:    [[GUARD_VAR1:%.*]] = phi i32 [ [[GUARD_VAR]], [[B2_GUARD]] ], [ [[TMP12]], [[LOOP2_BODY_B5_GUARD_CRIT_EDGE]] ], [ [[TMP2]], [[B2]] ]
; CHECK-NEXT:    [[PREV_GUARD2:%.*]] = icmp eq i32 [[GUARD_VAR1]], 6
; CHECK-NEXT:    br i1 [[PREV_GUARD2]], label [[B5:%.*]], label [[LOOP2_BODY_GUARD:%.*]]
; CHECK:       b5:
; CHECK-NEXT:    store volatile i32 5, i32 addrspace(1)* null
; CHECK-NEXT:    [[COND2:%.*]] = load volatile i1, i1 addrspace(1)* null
; CHECK-NEXT:    [[TMP10:%.*]] = select i1 [[COND2]], i32 7, i32 8
; CHECK-NEXT:    br label [[LOOP2_BODY_GUARD]]
; CHECK:       loop2.body.guard:
; CHECK-NEXT:    [[GUARD_VAR3:%.*]] = phi i32 [ [[GUARD_VAR1]], [[B5_GUARD]] ], [ [[TMP10]], [[B5]] ]
; CHECK-NEXT:    [[BE_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR3]], 7
; CHECK-NEXT:    br i1 [[BE_GUARD]], label [[LOOP2_BODY:%.*]], label [[LOOP2_BODY_B5_GUARD_CRIT_EDGE]]
; CHECK:       loop2.body:
; CHECK-NEXT:    [[COND3:%.*]] = load volatile i1, i1 addrspace(1)* null
; CHECK-NEXT:    [[TMP11:%.*]] = select i1 [[COND3]], i32 7, i32 8
; CHECK-NEXT:    br label [[LOOP2_BODY_B5_GUARD_CRIT_EDGE]]
; CHECK:       loop2.body.b5.guard_crit_edge:
; CHECK-NEXT:    [[TMP12]] = phi i32 [ [[TMP9]], [[LOOP2_BODY_GUARD]] ], [ [[TMP11]], [[LOOP2_BODY]] ]
; CHECK-NEXT:    [[GUARD_VAR4]] = phi i32 [ [[GUARD_VAR3]], [[LOOP2_BODY_GUARD]] ], [ [[TMP11]], [[LOOP2_BODY]] ]
; CHECK-NEXT:    [[PREV_GUARD5:%.*]] = icmp eq i32 [[GUARD_VAR4]], 6
; CHECK-NEXT:    br i1 [[PREV_GUARD5]], label [[B5_GUARD]], label [[B3_GUARD]]
; CHECK:       b6.guard:
; CHECK-NEXT:    [[GUARD_VAR8]] = phi i32 [ [[GUARD_VAR6]], [[B3_GUARD]] ], [ [[TMP4]], [[B3]] ]
; CHECK-NEXT:    [[PREV_GUARD9:%.*]] = icmp eq i32 [[GUARD_VAR8]], 8
; CHECK-NEXT:    br i1 [[PREV_GUARD9]], label [[B6]], label [[INNER_LOOP_GUARD]]
; CHECK:       b6:
; CHECK-NEXT:    store volatile i32 6, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %b1

b1:
  %b1.load = load volatile i32, i32 addrspace(1)* null
  br label %b2

b2:
  %i = phi i32 [ 0, %b1 ], [ %i.inc, %b4 ]
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %b3, label %b5

b3:
  store volatile i32 3, i32 addrspace(1)* null
  %cond1 = load volatile i1, i1 addrspace(1)* null
  br i1 %cond1, label %inner.loop, label %b6

inner.loop:
  %inner.cond = load i1, i1 addrspace(1)* null
  br i1 %inner.cond, label %inner.loop, label %b4

b4:
  store volatile i32 4, i32 addrspace(1)* null
  %i.inc = add nsw i32 %i, 1
  br label %b2

b5:
  store volatile i32 5, i32 addrspace(1)* null
  %cond2 = load volatile i1, i1 addrspace(1)* null
  br i1 %cond2, label %loop2.body, label %b6

loop2.body:
  %cond3 = load volatile i1, i1 addrspace(1)* null
  br i1 %cond3, label %b5, label %b6

b6:
  store volatile i32 6, i32 addrspace(1)* null
  br label %exit

exit:
  ret void
}

define void @figure5b_phis(i32 %n) {
; CHECK-LABEL: @figure5b_phis(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ENTRY_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B1:%.*]]
; CHECK:       b1:
; CHECK-NEXT:    [[B1_PHI:%.*]] = phi i32 [ [[ENTRY_LOAD]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    store volatile i32 [[B1_PHI]], i32 addrspace(1)* null
; CHECK-NEXT:    [[B1_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B2_GUARD:%.*]]
; CHECK:       b2.guard:
; CHECK-NEXT:    [[I_INC18:%.*]] = phi i32 [ [[I_INC19:%.*]], [[B4_SPLIT:%.*]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[B4_LOAD16:%.*]] = phi i32 [ [[B4_LOAD17:%.*]], [[B4_SPLIT]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[B2_LOAD13:%.*]] = phi i32 [ [[B2_LOAD14:%.*]], [[B4_SPLIT]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[I11:%.*]] = phi i32 [ [[I12:%.*]], [[B4_SPLIT]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[B6_PHI_PH9:%.*]] = phi i32 [ [[B6_PHI_PH10:%.*]], [[B4_SPLIT]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[GUARD_VAR:%.*]] = phi i32 [ 2, [[B4_SPLIT]] ], [ 2, [[B1]] ]
; CHECK-NEXT:    [[I_PH:%.*]] = phi i32 [ [[I_INC19]], [[B4_SPLIT]] ], [ 0, [[B1]] ]
; CHECK-NEXT:    [[B2_PHI_PH:%.*]] = phi i32 [ [[B4_LOAD17]], [[B4_SPLIT]] ], [ [[B1_LOAD]], [[B1]] ]
; CHECK-NEXT:    [[PREV_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR]], 2
; CHECK-NEXT:    br i1 [[PREV_GUARD]], label [[B2:%.*]], label [[B3_GUARD:%.*]]
; CHECK:       b2:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[I_PH]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[B2_PHI:%.*]] = phi i32 [ [[B2_PHI_PH]], [[B2_GUARD]] ]
; CHECK-NEXT:    store volatile i32 [[B2_PHI]], i32 addrspace(1)* null
; CHECK-NEXT:    [[B2_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; CHECK-NEXT:    [[TMP0:%.*]] = select i1 [[CMP]], i32 5, i32 3
; CHECK-NEXT:    br i1 [[CMP]], label [[B5_GUARD:%.*]], label [[B3_GUARD]]
; CHECK:       b3.guard:
; CHECK-NEXT:    [[B2_LOAD14]] = phi i32 [ [[B2_LOAD13]], [[B2_GUARD]] ], [ [[B2_LOAD]], [[B2]] ]
; CHECK-NEXT:    [[I12]] = phi i32 [ [[I11]], [[B2_GUARD]] ], [ [[I]], [[B2]] ]
; CHECK-NEXT:    [[GUARD_VAR1:%.*]] = phi i32 [ [[GUARD_VAR]], [[B2_GUARD]] ], [ [[TMP0]], [[B2]] ]
; CHECK-NEXT:    [[PREV_GUARD2:%.*]] = icmp eq i32 [[GUARD_VAR1]], 3
; CHECK-NEXT:    br i1 [[PREV_GUARD2]], label [[B3:%.*]], label [[B4_GUARD:%.*]]
; CHECK:       b3:
; CHECK-NEXT:    [[B3_PHI:%.*]] = phi i32 [ [[B2_LOAD14]], [[B3_GUARD]] ]
; CHECK-NEXT:    store volatile i32 3, i32 addrspace(1)* null
; CHECK-NEXT:    [[B3_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1 addrspace(1)* null
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[COND1]], i32 4, i32 6
; CHECK-NEXT:    br label [[B4_GUARD]]
; CHECK:       b4.guard:
; CHECK-NEXT:    [[B6_PHI_PH10]] = phi i32 [ [[B6_PHI_PH9]], [[B3_GUARD]] ], [ [[B3_LOAD]], [[B3]] ]
; CHECK-NEXT:    [[GUARD_VAR3:%.*]] = phi i32 [ [[GUARD_VAR1]], [[B3_GUARD]] ], [ [[TMP1]], [[B3]] ]
; CHECK-NEXT:    [[BE_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR3]], 4
; CHECK-NEXT:    br i1 [[BE_GUARD]], label [[B4:%.*]], label [[B4_SPLIT]]
; CHECK:       b4:
; CHECK-NEXT:    [[B4_PHI:%.*]] = phi i32 [ [[B6_PHI_PH10]], [[B4_GUARD]] ]
; CHECK-NEXT:    [[B4_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    store volatile i32 [[B4_PHI]], i32 addrspace(1)* null
; CHECK-NEXT:    [[I_INC:%.*]] = add nsw i32 [[I12]], 1
; CHECK-NEXT:    br label [[B4_SPLIT]]
; CHECK:       b4.split:
; CHECK-NEXT:    [[I_INC19]] = phi i32 [ [[I_INC18]], [[B4_GUARD]] ], [ [[I_INC]], [[B4]] ]
; CHECK-NEXT:    [[B4_LOAD17]] = phi i32 [ [[B4_LOAD16]], [[B4_GUARD]] ], [ [[B4_LOAD]], [[B4]] ]
; CHECK-NEXT:    [[GUARD_VAR4:%.*]] = phi i32 [ [[GUARD_VAR3]], [[B4_GUARD]] ], [ 4, [[B4]] ]
; CHECK-NEXT:    [[PREV_GUARD5:%.*]] = icmp eq i32 [[GUARD_VAR4]], 2
; CHECK-NEXT:    br i1 [[PREV_GUARD5]], label [[B2_GUARD]], label [[B5_GUARD]]
; CHECK:       b5.guard:
; CHECK-NEXT:    [[B2_LOAD15:%.*]] = phi i32 [ [[B2_LOAD14]], [[B4_SPLIT]] ], [ [[B2_LOAD]], [[B2]] ]
; CHECK-NEXT:    [[B6_PHI_PH8:%.*]] = phi i32 [ [[B6_PHI_PH10]], [[B4_SPLIT]] ], [ [[B6_PHI_PH9]], [[B2]] ]
; CHECK-NEXT:    [[GUARD_VAR6:%.*]] = phi i32 [ [[GUARD_VAR4]], [[B4_SPLIT]] ], [ [[TMP0]], [[B2]] ]
; CHECK-NEXT:    [[PREV_GUARD7:%.*]] = icmp eq i32 [[GUARD_VAR6]], 5
; CHECK-NEXT:    br i1 [[PREV_GUARD7]], label [[B5:%.*]], label [[B6_GUARD:%.*]]
; CHECK:       b5:
; CHECK-NEXT:    [[B5_PHI:%.*]] = phi i32 [ [[B2_LOAD15]], [[B5_GUARD]] ]
; CHECK-NEXT:    [[B5_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    store volatile i32 [[B5_PHI]], i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B6_GUARD]]
; CHECK:       b6.guard:
; CHECK-NEXT:    [[B6_PHI_PH:%.*]] = phi i32 [ [[B5_LOAD]], [[B5]] ], [ [[B6_PHI_PH8]], [[B5_GUARD]] ]
; CHECK-NEXT:    br label [[B6:%.*]]
; CHECK:       b6:
; CHECK-NEXT:    [[B6_PHI:%.*]] = phi i32 [ [[B6_PHI_PH]], [[B6_GUARD]] ]
; CHECK-NEXT:    store volatile i32 [[B6_PHI]], i32 addrspace(1)* null
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %entry.load = load volatile i32, i32 addrspace(1)* null
  br label %b1

b1:
  %b1.phi = phi i32 [ %entry.load, %entry ]
  store volatile i32 %b1.phi, i32 addrspace(1)* null
  %b1.load = load volatile i32, i32 addrspace(1)* null
  br label %b2

b2:
  %i = phi i32 [ 0, %b1 ], [ %i.inc, %b4 ]
  %b2.phi = phi i32 [ %b1.load, %b1 ], [ %b4.load, %b4 ]
  store volatile i32 %b2.phi, i32 addrspace(1)* null
  %b2.load = load volatile i32, i32 addrspace(1)* null
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %b5, label %b3

b3:
  %b3.phi = phi i32 [ %b2.load, %b2 ]
  store volatile i32 3, i32 addrspace(1)* null
  %b3.load = load volatile i32, i32 addrspace(1)* null
  %cond1 = load volatile i1, i1 addrspace(1)* null
  br i1 %cond1, label %b4, label %b6

b4:
  %b4.phi = phi i32 [ %b3.load, %b3 ]
  %b4.load = load volatile i32, i32 addrspace(1)* null
  store volatile i32 %b4.phi, i32 addrspace(1)* null
  %i.inc = add nsw i32 %i, 1
  br label %b2

b5:
  %b5.phi = phi i32 [ %b2.load, %b2 ]
  %b5.load = load volatile i32, i32 addrspace(1)* null
  store volatile i32 %b5.phi, i32 addrspace(1)* null
  br label %b6

b6:
  %b6.phi = phi i32 [ %b3.load, %b3 ], [ %b5.load, %b5 ]
  store volatile i32 %b6.phi, i32 addrspace(1)* null
  br label %exit

exit:
  ret void
}









; swap order of branch in b2
define void @figure5b_phis_swap_br2(i32 %n) {
; CHECK-LABEL: @figure5b_phis_swap_br2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ENTRY_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B1:%.*]]
; CHECK:       b1:
; CHECK-NEXT:    [[B1_PHI:%.*]] = phi i32 [ [[ENTRY_LOAD]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    store volatile i32 [[B1_PHI]], i32 addrspace(1)* null
; CHECK-NEXT:    [[B1_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B2_GUARD:%.*]]
; CHECK:       b2.guard:
; CHECK-NEXT:    [[B3_LOAD14:%.*]] = phi i32 [ [[B3_LOAD15:%.*]], [[B4_SPLIT:%.*]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[B2_LOAD12:%.*]] = phi i32 [ [[B2_LOAD13:%.*]], [[B4_SPLIT]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[I10:%.*]] = phi i32 [ [[I11:%.*]], [[B4_SPLIT]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[B6_PHI8:%.*]] = phi i32 [ [[B3_LOAD15]], [[B4_SPLIT]] ], [ undef, [[B1]] ]
; CHECK-NEXT:    [[GUARD_VAR:%.*]] = phi i32 [ 2, [[B4_SPLIT]] ], [ 2, [[B1]] ]
; CHECK-NEXT:    [[I_PH:%.*]] = phi i32 [ [[I_INC:%.*]], [[B4_SPLIT]] ], [ 0, [[B1]] ]
; CHECK-NEXT:    [[B2_PHI_PH:%.*]] = phi i32 [ [[B4_LOAD:%.*]], [[B4_SPLIT]] ], [ [[B1_LOAD]], [[B1]] ]
; CHECK-NEXT:    [[PREV_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR]], 2
; CHECK-NEXT:    br i1 [[PREV_GUARD]], label [[B2:%.*]], label [[B5_GUARD:%.*]]
; CHECK:       b2:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[I_PH]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[B2_PHI:%.*]] = phi i32 [ [[B2_PHI_PH]], [[B2_GUARD]] ]
; CHECK-NEXT:    store volatile i32 [[B2_PHI]], i32 addrspace(1)* null
; CHECK-NEXT:    [[B2_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; CHECK-NEXT:    [[TMP0:%.*]] = select i1 [[CMP]], i32 3, i32 5
; CHECK-NEXT:    br label [[B5_GUARD]]
; CHECK:       b3.guard:
; CHECK-NEXT:    [[GUARD_VAR3:%.*]] = phi i32 [ 6, [[B5:%.*]] ], [ [[GUARD_VAR1:%.*]], [[B5_GUARD]] ]
; CHECK-NEXT:    [[PREV_GUARD4:%.*]] = icmp eq i32 [[GUARD_VAR3]], 3
; CHECK-NEXT:    br i1 [[PREV_GUARD4]], label [[B3:%.*]], label [[B6_GUARD:%.*]]
; CHECK:       b3:
; CHECK-NEXT:    [[B3_PHI:%.*]] = phi i32 [ [[B2_LOAD13]], [[B3_GUARD:%.*]] ]
; CHECK-NEXT:    store volatile i32 3, i32 addrspace(1)* null
; CHECK-NEXT:    [[B3_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1 addrspace(1)* null
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[COND1]], i32 4, i32 6
; CHECK-NEXT:    br label [[B6_GUARD]]
; CHECK:       b4.guard:
; CHECK-NEXT:    [[LAST:%.*]] = icmp eq i32 [[GUARD_VAR5:%.*]], 4
; CHECK-NEXT:    br i1 [[LAST]], label [[B4:%.*]], label [[B6:%.*]]
; CHECK:       b4:
; CHECK-NEXT:    [[B4_PHI:%.*]] = phi i32 [ [[B3_LOAD15]], [[B4_GUARD:%.*]] ]
; CHECK-NEXT:    [[B4_LOAD]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    store volatile i32 [[B4_PHI]], i32 addrspace(1)* null
; CHECK-NEXT:    [[I_INC]] = add nsw i32 [[I11]], 1
; CHECK-NEXT:    br label [[B4_SPLIT]]
; CHECK:       b4.split:
; CHECK-NEXT:    br label [[B2_GUARD]]
; CHECK:       b5.guard:
; CHECK-NEXT:    [[B2_LOAD13]] = phi i32 [ [[B2_LOAD12]], [[B2_GUARD]] ], [ [[B2_LOAD]], [[B2]] ]
; CHECK-NEXT:    [[I11]] = phi i32 [ [[I10]], [[B2_GUARD]] ], [ [[I]], [[B2]] ]
; CHECK-NEXT:    [[GUARD_VAR1]] = phi i32 [ [[GUARD_VAR]], [[B2_GUARD]] ], [ [[TMP0]], [[B2]] ]
; CHECK-NEXT:    [[PREV_GUARD2:%.*]] = icmp eq i32 [[GUARD_VAR1]], 5
; CHECK-NEXT:    br i1 [[PREV_GUARD2]], label [[B5]], label [[B3_GUARD]]
; CHECK:       b5:
; CHECK-NEXT:    [[B5_PHI:%.*]] = phi i32 [ [[B2_LOAD13]], [[B5_GUARD]] ]
; CHECK-NEXT:    [[B5_LOAD:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    store volatile i32 [[B5_PHI]], i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B3_GUARD]]
; CHECK:       b6.guard:
; CHECK-NEXT:    [[B3_LOAD15]] = phi i32 [ [[B3_LOAD14]], [[B3_GUARD]] ], [ [[B3_LOAD]], [[B3]] ]
; CHECK-NEXT:    [[GUARD_VAR5]] = phi i32 [ [[GUARD_VAR3]], [[B3_GUARD]] ], [ [[TMP1]], [[B3]] ]
; CHECK-NEXT:    [[PREV_GUARD6:%.*]] = icmp eq i32 [[GUARD_VAR5]], 6
; CHECK-NEXT:    br i1 [[PREV_GUARD6]], label [[B6]], label [[B4_GUARD]]
; CHECK:       b6:
; CHECK-NEXT:    [[B6_PHI:%.*]] = phi i32 [ [[B3_LOAD15]], [[B6_GUARD]] ], [ [[B3_LOAD15]], [[B4_GUARD]] ]
; CHECK-NEXT:    store volatile i32 [[B6_PHI]], i32 addrspace(1)* null
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %entry.load = load volatile i32, i32 addrspace(1)* null
  br label %b1

b1:
  %b1.phi = phi i32 [ %entry.load, %entry ]
  store volatile i32 %b1.phi, i32 addrspace(1)* null
  %b1.load = load volatile i32, i32 addrspace(1)* null
  br label %b2

b2:
  %i = phi i32 [ 0, %b1 ], [ %i.inc, %b4 ]
  %b2.phi = phi i32 [ %b1.load, %b1 ], [ %b4.load, %b4 ]
  store volatile i32 %b2.phi, i32 addrspace(1)* null
  %b2.load = load volatile i32, i32 addrspace(1)* null
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %b3, label %b5

b3:
  %b3.phi = phi i32 [ %b2.load, %b2 ]
  store volatile i32 3, i32 addrspace(1)* null
  %b3.load = load volatile i32, i32 addrspace(1)* null
  %cond1 = load volatile i1, i1 addrspace(1)* null
  br i1 %cond1, label %b4, label %b6

b4:
  %b4.phi = phi i32 [ %b3.load, %b3 ]
  %b4.load = load volatile i32, i32 addrspace(1)* null
  store volatile i32 %b4.phi, i32 addrspace(1)* null
  %i.inc = add nsw i32 %i, 1
  br label %b2

b5:
  %b5.phi = phi i32 [ %b2.load, %b2 ]
  %b5.load = load volatile i32, i32 addrspace(1)* null
  store volatile i32 %b5.phi, i32 addrspace(1)* null
  br label %b6

b6:
  %b6.phi = phi i32 [ %b3.load, %b3 ], [ %b5.load, %b5 ]
  store volatile i32 %b6.phi, i32 addrspace(1)* null
  br label %exit

exit:
  ret void
}
