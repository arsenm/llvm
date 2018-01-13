; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -linearize-cfg %s | FileCheck %s

define void @multi_else_break(i32 %limit0, i32 %limit1) {
; CHECK-LABEL: @multi_else_break(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP_OUTER:%.*]]
; CHECK:       loop.outer:
; CHECK-NEXT:    [[LOOP_OUTER_PHI:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_INC:%.*]], [[ENDIF:%.*]] ]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[LOOP_OUTER_PHI]], [[LOOP_OUTER]] ], [ [[I_INC]], [[ENDIF]] ]
; CHECK-NEXT:    [[I_INC]] = add i32 [[I]], 1
; CHECK-NEXT:    [[CMP0:%.*]] = icmp slt i32 [[I]], [[LIMIT0:%.*]]
; CHECK-NEXT:    br i1 [[CMP0]], label [[ENDIF]], label [[EXIT:%.*]]
; CHECK:       endif:
; CHECK-NEXT:    [[CMP1:%.*]] = icmp eq i32 [[I_INC]], [[LIMIT1:%.*]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[LOOP]], label [[LOOP_OUTER]]
; CHECK:       exit:
; CHECK-NEXT:    store volatile i32 9, i32 addrspace(1)* undef
; CHECK-NEXT:    ret void
;
entry:
  br label %loop.outer

loop.outer:
  %loop.outer.phi = phi i32 [ 0, %entry ], [ %i.inc, %endif ]
  br label %loop

loop:
  %i = phi i32 [ %loop.outer.phi, %loop.outer ], [ %i.inc, %endif ]
  %i.inc = add i32 %i, 1
  %cmp0 = icmp slt i32 %i, %limit0
  br i1 %cmp0, label %endif, label %exit

endif:
  %cmp1 = icmp eq i32 %i.inc, %limit1
  br i1 %cmp1, label %loop, label %loop.outer

exit:
  store volatile i32 9, i32 addrspace(1)* undef
  ret void
}

define void @multi_if_break_loop(i32 %id, i32 %arg) {
; CHECK-LABEL: @multi_if_break_loop(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TMP:%.*]] = sub i32 [[ID:%.*]], [[ARG:%.*]]
; CHECK-NEXT:    br label [[BB1_GUARD:%.*]]
; CHECK:       bb1.guard:
; CHECK-NEXT:    [[LOAD020:%.*]] = phi i32 [ [[LOAD021:%.*]], [[CASE1_BB1_GUARD_CRIT_EDGE:%.*]] ], [ [[LOAD021]], [[CASE0_BB1_GUARD_CRIT_EDGE:%.*]] ], [ undef, [[BB:%.*]] ]
; CHECK-NEXT:    [[LSR_IV_NEXT18:%.*]] = phi i32 [ [[LSR_IV_NEXT19:%.*]], [[CASE1_BB1_GUARD_CRIT_EDGE]] ], [ [[LSR_IV_NEXT19]], [[CASE0_BB1_GUARD_CRIT_EDGE]] ], [ undef, [[BB]] ]
; CHECK-NEXT:    [[GUARD_VAR:%.*]] = phi i32 [ 1, [[CASE1_BB1_GUARD_CRIT_EDGE]] ], [ 1, [[CASE0_BB1_GUARD_CRIT_EDGE]] ], [ 1, [[BB]] ]
; CHECK-NEXT:    [[LSR_IV_PH:%.*]] = phi i32 [ [[LSR_IV_NEXT19]], [[CASE1_BB1_GUARD_CRIT_EDGE]] ], [ [[LSR_IV_NEXT19]], [[CASE0_BB1_GUARD_CRIT_EDGE]] ], [ undef, [[BB]] ]
; CHECK-NEXT:    [[PREV_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR]], 1
; CHECK-NEXT:    br i1 [[PREV_GUARD]], label [[BB1:%.*]], label [[NODEBLOCK_GUARD:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[LSR_IV:%.*]] = phi i32 [ [[LSR_IV_PH]], [[BB1_GUARD]] ]
; CHECK-NEXT:    [[LSR_IV_NEXT:%.*]] = add i32 [[LSR_IV]], 1
; CHECK-NEXT:    [[CMP0:%.*]] = icmp slt i32 [[LSR_IV_NEXT]], 0
; CHECK-NEXT:    [[LOAD0:%.*]] = load volatile i32, i32 addrspace(1)* undef, align 4
; CHECK-NEXT:    br label [[NODEBLOCK_GUARD]]
; CHECK:       NodeBlock.guard:
; CHECK-NEXT:    [[LOAD021]] = phi i32 [ [[LOAD020]], [[BB1_GUARD]] ], [ [[LOAD0]], [[BB1]] ]
; CHECK-NEXT:    [[LSR_IV_NEXT19]] = phi i32 [ [[LSR_IV_NEXT18]], [[BB1_GUARD]] ], [ [[LSR_IV_NEXT]], [[BB1]] ]
; CHECK-NEXT:    [[GUARD_VAR3:%.*]] = phi i32 [ [[GUARD_VAR]], [[BB1_GUARD]] ], [ 2, [[BB1]] ]
; CHECK-NEXT:    [[PREV_GUARD4:%.*]] = icmp eq i32 [[GUARD_VAR3]], 2
; CHECK-NEXT:    br i1 [[PREV_GUARD4]], label [[NODEBLOCK:%.*]], label [[LEAFBLOCK1_GUARD:%.*]]
; CHECK:       NodeBlock:
; CHECK-NEXT:    [[PIVOT:%.*]] = icmp slt i32 [[LOAD021]], 1
; CHECK-NEXT:    [[TMP0:%.*]] = select i1 [[PIVOT]], i32 4, i32 3
; CHECK-NEXT:    br i1 [[PIVOT]], label [[LEAFBLOCK_GUARD:%.*]], label [[LEAFBLOCK1_GUARD]]
; CHECK:       LeafBlock1.guard:
; CHECK-NEXT:    [[GUARD_VAR5:%.*]] = phi i32 [ [[GUARD_VAR3]], [[NODEBLOCK_GUARD]] ], [ [[TMP0]], [[NODEBLOCK]] ]
; CHECK-NEXT:    [[PREV_GUARD6:%.*]] = icmp eq i32 [[GUARD_VAR5]], 3
; CHECK-NEXT:    br i1 [[PREV_GUARD6]], label [[LEAFBLOCK1:%.*]], label [[CASE1_GUARD:%.*]]
; CHECK:       LeafBlock1:
; CHECK-NEXT:    [[SWITCHLEAF2:%.*]] = icmp eq i32 [[LOAD021]], 1
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[SWITCHLEAF2]], i32 6, i32 7
; CHECK-NEXT:    br label [[CASE1_GUARD]]
; CHECK:       LeafBlock.guard:
; CHECK-NEXT:    [[GUARD_VAR10:%.*]] = phi i32 [ [[GUARD_VAR8:%.*]], [[CASE1_BB1_GUARD_CRIT_EDGE]] ], [ [[TMP0]], [[NODEBLOCK]] ]
; CHECK-NEXT:    [[PREV_GUARD11:%.*]] = icmp eq i32 [[GUARD_VAR10]], 4
; CHECK-NEXT:    br i1 [[PREV_GUARD11]], label [[LEAFBLOCK:%.*]], label [[NEWDEFAULT_GUARD:%.*]]
; CHECK:       LeafBlock:
; CHECK-NEXT:    [[SWITCHLEAF:%.*]] = icmp eq i32 [[LOAD021]], 0
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[SWITCHLEAF]], i32 5, i32 7
; CHECK-NEXT:    br label [[NEWDEFAULT_GUARD]]
; CHECK:       case0.guard:
; CHECK-NEXT:    [[GUARD_VAR14:%.*]] = phi i32 [ 8, [[NEWDEFAULT:%.*]] ], [ [[GUARD_VAR12:%.*]], [[NEWDEFAULT_GUARD]] ]
; CHECK-NEXT:    [[BE_GUARD15:%.*]] = icmp eq i32 [[GUARD_VAR14]], 5
; CHECK-NEXT:    br i1 [[BE_GUARD15]], label [[CASE0:%.*]], label [[CASE0_BB1_GUARD_CRIT_EDGE]]
; CHECK:       case0:
; CHECK-NEXT:    [[LOAD1:%.*]] = load volatile i32, i32 addrspace(1)* undef, align 4
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i32 [[TMP]], [[LOAD1]]
; CHECK-NEXT:    [[TMP3:%.*]] = select i1 [[CMP1]], i32 5, i32 8
; CHECK-NEXT:    br i1 [[CMP1]], label [[CASE0_BB1_GUARD_CRIT_EDGE]], label [[BB9_GUARD:%.*]]
; CHECK:       case0.bb1.guard_crit_edge:
; CHECK-NEXT:    [[GUARD_VAR16:%.*]] = phi i32 [ [[GUARD_VAR14]], [[CASE0_GUARD:%.*]] ], [ [[TMP3]], [[CASE0]] ]
; CHECK-NEXT:    [[PREV_GUARD17:%.*]] = icmp eq i32 [[GUARD_VAR16]], 1
; CHECK-NEXT:    br i1 [[PREV_GUARD17]], label [[BB1_GUARD]], label [[BB9_GUARD]]
; CHECK:       case1.guard:
; CHECK-NEXT:    [[GUARD_VAR7:%.*]] = phi i32 [ [[GUARD_VAR5]], [[LEAFBLOCK1_GUARD]] ], [ [[TMP1]], [[LEAFBLOCK1]] ]
; CHECK-NEXT:    [[BE_GUARD:%.*]] = icmp eq i32 [[GUARD_VAR7]], 6
; CHECK-NEXT:    br i1 [[BE_GUARD]], label [[CASE1:%.*]], label [[CASE1_BB1_GUARD_CRIT_EDGE]]
; CHECK:       case1:
; CHECK-NEXT:    [[LOAD2:%.*]] = load volatile i32, i32 addrspace(1)* undef, align 4
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i32 [[TMP]], [[LOAD2]]
; CHECK-NEXT:    [[TMP4:%.*]] = select i1 [[CMP2]], i32 6, i32 8
; CHECK-NEXT:    br i1 [[CMP2]], label [[CASE1_BB1_GUARD_CRIT_EDGE]], label [[BB9_GUARD]]
; CHECK:       case1.bb1.guard_crit_edge:
; CHECK-NEXT:    [[GUARD_VAR8]] = phi i32 [ [[GUARD_VAR7]], [[CASE1_GUARD]] ], [ [[TMP4]], [[CASE1]] ]
; CHECK-NEXT:    [[PREV_GUARD9:%.*]] = icmp eq i32 [[GUARD_VAR8]], 1
; CHECK-NEXT:    br i1 [[PREV_GUARD9]], label [[BB1_GUARD]], label [[LEAFBLOCK_GUARD]]
; CHECK:       NewDefault.guard:
; CHECK-NEXT:    [[GUARD_VAR12]] = phi i32 [ [[GUARD_VAR10]], [[LEAFBLOCK_GUARD]] ], [ [[TMP2]], [[LEAFBLOCK]] ]
; CHECK-NEXT:    [[PREV_GUARD13:%.*]] = icmp eq i32 [[GUARD_VAR12]], 7
; CHECK-NEXT:    br i1 [[PREV_GUARD13]], label [[NEWDEFAULT]], label [[CASE0_GUARD]]
; CHECK:       NewDefault:
; CHECK-NEXT:    br label [[CASE0_GUARD]]
; CHECK:       bb9.guard:
; CHECK-NEXT:    br label [[BB9:%.*]]
; CHECK:       bb9:
; CHECK-NEXT:    ret void
;
bb:
  %tmp = sub i32 %id, %arg
  br label %bb1

bb1:
  %lsr.iv = phi i32 [ undef, %bb ], [ %lsr.iv.next, %case0 ], [ %lsr.iv.next, %case1 ]
  %lsr.iv.next = add i32 %lsr.iv, 1
  %cmp0 = icmp slt i32 %lsr.iv.next, 0
  %load0 = load volatile i32, i32 addrspace(1)* undef, align 4
  switch i32 %load0, label %bb9 [
  i32 0, label %case0
  i32 1, label %case1
  ]

case0:
  %load1 = load volatile i32, i32 addrspace(1)* undef, align 4
  %cmp1 = icmp slt i32 %tmp, %load1
  br i1 %cmp1, label %bb1, label %bb9

case1:
  %load2 = load volatile i32, i32 addrspace(1)* undef, align 4
  %cmp2 = icmp slt i32 %tmp, %load2
  br i1 %cmp2, label %bb1, label %bb9

bb9:
  ret void
}

