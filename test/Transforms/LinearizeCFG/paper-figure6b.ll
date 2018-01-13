; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -linearize-cfg %s | FileCheck %s

; unstructured: b1->b5, b2->b3

define void @figure6b(i1 %cond0, i1 %cond1, i1 %cond2) {
; CHECK-LABEL: @figure6b(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[B1:%.*]]
; CHECK:       b1:
; CHECK-NEXT:    [[LOAD_B1:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    [[TMP0:%.*]] = select i1 [[COND0:%.*]], i32 2, i32 5
; CHECK-NEXT:    br label [[B2_GUARD:%.*]]
; CHECK:       b2.guard:
; CHECK-NEXT:    [[PREV_GUARD:%.*]] = icmp eq i32 [[TMP0]], 2
; CHECK-NEXT:    br i1 [[PREV_GUARD]], label [[B2:%.*]], label [[B3_GUARD:%.*]]
; CHECK:       b2:
; CHECK-NEXT:    [[LOAD_B2:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B3_GUARD]]
; CHECK:       b3.guard:
; CHECK-NEXT:    [[PHI_B5_PH6:%.*]] = phi i32 [ [[PHI_B5_PH:%.*]], [[B5_SPLIT:%.*]] ], [ [[LOAD_B1]], [[B2]] ], [ [[LOAD_B1]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[GUARD_VAR15:%.*]] = phi i32 [ [[GUARD_VAR1:%.*]], [[B5_SPLIT]] ], [ [[TMP0]], [[B2]] ], [ [[TMP0]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[GUARD_VAR:%.*]] = phi i32 [ [[GUARD_VAR1]], [[B5_SPLIT]] ], [ 3, [[B2]] ], [ [[TMP0]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[PHI_B3_PH:%.*]] = phi i32 [ [[LOAD_B5:%.*]], [[B5_SPLIT]] ], [ [[LOAD_B2]], [[B2]] ], [ undef, [[B2_GUARD]] ]
; CHECK-NEXT:    [[PREV_GUARD2:%.*]] = icmp eq i32 [[GUARD_VAR]], 3
; CHECK-NEXT:    br i1 [[PREV_GUARD2]], label [[B3:%.*]], label [[B4_GUARD:%.*]]
; CHECK:       b3:
; CHECK-NEXT:    [[PHI_B3:%.*]] = phi i32 [ [[PHI_B3_PH]], [[B3_GUARD]] ], [ [[PHI_B3_PH]], [[B5_GUARD:%.*]] ]
; CHECK-NEXT:    [[LOAD_B3:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[COND1:%.*]], i32 4, i32 6
; CHECK-NEXT:    br i1 [[COND1]], label [[B4_GUARD]], label [[B6:%.*]]
; CHECK:       b4.guard:
; CHECK-NEXT:    [[GUARD_VAR3:%.*]] = phi i32 [ [[GUARD_VAR]], [[B3_GUARD]] ], [ [[TMP1]], [[B3]] ]
; CHECK-NEXT:    [[PREV_GUARD4:%.*]] = icmp eq i32 [[GUARD_VAR3]], 4
; CHECK-NEXT:    br i1 [[PREV_GUARD4]], label [[B4:%.*]], label [[B5_GUARD]]
; CHECK:       b4:
; CHECK-NEXT:    [[LOAD_B4:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B5_GUARD]]
; CHECK:       b5.guard:
; CHECK-NEXT:    [[GUARD_VAR7:%.*]] = phi i32 [ 5, [[B4]] ], [ [[GUARD_VAR3]], [[B4_GUARD]] ]
; CHECK-NEXT:    [[GUARD_VAR1]] = phi i32 [ 5, [[B4]] ], [ [[GUARD_VAR15]], [[B4_GUARD]] ]
; CHECK-NEXT:    [[PHI_B5_PH]] = phi i32 [ [[LOAD_B4]], [[B4]] ], [ [[PHI_B5_PH6]], [[B4_GUARD]] ]
; CHECK-NEXT:    [[LAST:%.*]] = icmp eq i32 [[GUARD_VAR7]], 5
; CHECK-NEXT:    br i1 [[LAST]], label [[B5:%.*]], label [[B3]]
; CHECK:       b5:
; CHECK-NEXT:    [[PHI_B5:%.*]] = phi i32 [ [[PHI_B5_PH]], [[B5_GUARD]] ]
; CHECK-NEXT:    store volatile i32 [[PHI_B5]], i32 addrspace(1)* null
; CHECK-NEXT:    [[LOAD_B5]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B5_SPLIT]]
; CHECK:       b5.split:
; CHECK-NEXT:    br label [[B3_GUARD]]
; CHECK:       b6:
; CHECK-NEXT:    store volatile i32 [[LOAD_B3]], i32 addrspace(1)* null
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %b1

b1:
  %load.b1 = load volatile i32, i32 addrspace(1)* null
  br i1 %cond0, label %b2, label %b5

b2:
  %load.b2 = load volatile i32, i32 addrspace(1)* null
  br label %b3

b3:
  %phi.b3 = phi i32 [%load.b2, %b2], [%load.b5, %b5]
  %load.b3 = load volatile i32, i32 addrspace(1)* null
  br i1 %cond1, label %b4, label %b6

b4:
  %load.b4 = load volatile i32, i32 addrspace(1)* null
  br label %b5

b5:
  %phi.b5 = phi i32 [%load.b1, %b1], [%load.b4, %b4]
  store volatile i32 %phi.b5, i32 addrspace(1)* null
  %load.b5 = load volatile i32, i32 addrspace(1)* null
  br label %b3

b6:
  store volatile i32 %load.b3, i32 addrspace(1)* null
  br label %exit

exit:
  ret void
}

define void @figure6b_swap_br_b3(i1 %cond0, i1 %cond1, i1 %cond2) {
; CHECK-LABEL: @figure6b_swap_br_b3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[B1:%.*]]
; CHECK:       b1:
; CHECK-NEXT:    [[LOAD_B1:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    [[TMP0:%.*]] = select i1 [[COND0:%.*]], i32 2, i32 5
; CHECK-NEXT:    br label [[B2_GUARD:%.*]]
; CHECK:       b2.guard:
; CHECK-NEXT:    [[PREV_GUARD:%.*]] = icmp eq i32 [[TMP0]], 2
; CHECK-NEXT:    br i1 [[PREV_GUARD]], label [[B2:%.*]], label [[B3_GUARD:%.*]]
; CHECK:       b2:
; CHECK-NEXT:    [[LOAD_B2:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B3_GUARD]]
; CHECK:       b3.guard:
; CHECK-NEXT:    [[PHI_B5_PH6:%.*]] = phi i32 [ [[PHI_B5_PH:%.*]], [[B5_SPLIT:%.*]] ], [ [[LOAD_B1]], [[B2]] ], [ [[LOAD_B1]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[GUARD_VAR15:%.*]] = phi i32 [ [[GUARD_VAR1:%.*]], [[B5_SPLIT]] ], [ [[TMP0]], [[B2]] ], [ [[TMP0]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[GUARD_VAR:%.*]] = phi i32 [ [[GUARD_VAR1]], [[B5_SPLIT]] ], [ 3, [[B2]] ], [ [[TMP0]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[PHI_B3_PH:%.*]] = phi i32 [ [[LOAD_B5:%.*]], [[B5_SPLIT]] ], [ [[LOAD_B2]], [[B2]] ], [ undef, [[B2_GUARD]] ]
; CHECK-NEXT:    [[PREV_GUARD2:%.*]] = icmp eq i32 [[GUARD_VAR]], 3
; CHECK-NEXT:    br i1 [[PREV_GUARD2]], label [[B3:%.*]], label [[B4_GUARD:%.*]]
; CHECK:       b3:
; CHECK-NEXT:    [[PHI_B3:%.*]] = phi i32 [ [[PHI_B3_PH]], [[B3_GUARD]] ], [ [[PHI_B3_PH]], [[B5_GUARD:%.*]] ]
; CHECK-NEXT:    [[LOAD_B3:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[COND1:%.*]], i32 6, i32 4
; CHECK-NEXT:    br i1 [[COND1]], label [[B6:%.*]], label [[B4_GUARD]]
; CHECK:       b4.guard:
; CHECK-NEXT:    [[GUARD_VAR3:%.*]] = phi i32 [ [[GUARD_VAR]], [[B3_GUARD]] ], [ [[TMP1]], [[B3]] ]
; CHECK-NEXT:    [[PREV_GUARD4:%.*]] = icmp eq i32 [[GUARD_VAR3]], 4
; CHECK-NEXT:    br i1 [[PREV_GUARD4]], label [[B4:%.*]], label [[B5_GUARD]]
; CHECK:       b4:
; CHECK-NEXT:    [[LOAD_B4:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B5_GUARD]]
; CHECK:       b5.guard:
; CHECK-NEXT:    [[GUARD_VAR7:%.*]] = phi i32 [ 5, [[B4]] ], [ [[GUARD_VAR3]], [[B4_GUARD]] ]
; CHECK-NEXT:    [[GUARD_VAR1]] = phi i32 [ 5, [[B4]] ], [ [[GUARD_VAR15]], [[B4_GUARD]] ]
; CHECK-NEXT:    [[PHI_B5_PH]] = phi i32 [ [[LOAD_B4]], [[B4]] ], [ [[PHI_B5_PH6]], [[B4_GUARD]] ]
; CHECK-NEXT:    [[LAST:%.*]] = icmp eq i32 [[GUARD_VAR7]], 5
; CHECK-NEXT:    br i1 [[LAST]], label [[B5:%.*]], label [[B3]]
; CHECK:       b5:
; CHECK-NEXT:    [[PHI_B5:%.*]] = phi i32 [ [[PHI_B5_PH]], [[B5_GUARD]] ]
; CHECK-NEXT:    store volatile i32 [[PHI_B5]], i32 addrspace(1)* null
; CHECK-NEXT:    [[LOAD_B5]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B5_SPLIT]]
; CHECK:       b5.split:
; CHECK-NEXT:    br label [[B3_GUARD]]
; CHECK:       b6:
; CHECK-NEXT:    store volatile i32 [[LOAD_B3]], i32 addrspace(1)* null
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %b1

b1:
  %load.b1 = load volatile i32, i32 addrspace(1)* null
  br i1 %cond0, label %b2, label %b5

b2:
  %load.b2 = load volatile i32, i32 addrspace(1)* null
  br label %b3

b3:
  %phi.b3 = phi i32 [%load.b2, %b2], [%load.b5, %b5]
  %load.b3 = load volatile i32, i32 addrspace(1)* null
  br i1 %cond1, label %b6, label %b4

b4:
  %load.b4 = load volatile i32, i32 addrspace(1)* null
  br label %b5

b5:
  %phi.b5 = phi i32 [%load.b1, %b1], [%load.b4, %b4]
  store volatile i32 %phi.b5, i32 addrspace(1)* null
  %load.b5 = load volatile i32, i32 addrspace(1)* null
  br label %b3

b6:
  store volatile i32 %load.b3, i32 addrspace(1)* null
  br label %exit

exit:
  ret void
}

define void @figure6b_phis(i1 %cond0, i1 %cond1, i1 %cond2) {
; CHECK-LABEL: @figure6b_phis(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[B1:%.*]]
; CHECK:       b1:
; CHECK-NEXT:    [[LOAD_B1:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    [[TMP0:%.*]] = select i1 [[COND0:%.*]], i32 2, i32 5
; CHECK-NEXT:    br label [[B2_GUARD:%.*]]
; CHECK:       b2.guard:
; CHECK-NEXT:    [[PREV_GUARD:%.*]] = icmp eq i32 [[TMP0]], 2
; CHECK-NEXT:    br i1 [[PREV_GUARD]], label [[B2:%.*]], label [[B3_GUARD:%.*]]
; CHECK:       b2:
; CHECK-NEXT:    [[LOAD_B2:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B3_GUARD]]
; CHECK:       b3.guard:
; CHECK-NEXT:    [[PHI_B5_PH6:%.*]] = phi i32 [ [[PHI_B5_PH:%.*]], [[B5_SPLIT:%.*]] ], [ [[LOAD_B1]], [[B2]] ], [ [[LOAD_B1]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[GUARD_VAR15:%.*]] = phi i32 [ [[GUARD_VAR1:%.*]], [[B5_SPLIT]] ], [ [[TMP0]], [[B2]] ], [ [[TMP0]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[GUARD_VAR:%.*]] = phi i32 [ [[GUARD_VAR1]], [[B5_SPLIT]] ], [ 3, [[B2]] ], [ [[TMP0]], [[B2_GUARD]] ]
; CHECK-NEXT:    [[PHI_B3_PH:%.*]] = phi i32 [ [[LOAD_B5:%.*]], [[B5_SPLIT]] ], [ [[LOAD_B2]], [[B2]] ], [ undef, [[B2_GUARD]] ]
; CHECK-NEXT:    [[PREV_GUARD2:%.*]] = icmp eq i32 [[GUARD_VAR]], 3
; CHECK-NEXT:    br i1 [[PREV_GUARD2]], label [[B3:%.*]], label [[B4_GUARD:%.*]]
; CHECK:       b3:
; CHECK-NEXT:    [[PHI_B3:%.*]] = phi i32 [ [[PHI_B3_PH]], [[B3_GUARD]] ], [ [[PHI_B3_PH]], [[B5_GUARD:%.*]] ]
; CHECK-NEXT:    [[LOAD_B3:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[COND1:%.*]], i32 4, i32 6
; CHECK-NEXT:    br i1 [[COND1]], label [[B4_GUARD]], label [[B6:%.*]]
; CHECK:       b4.guard:
; CHECK-NEXT:    [[GUARD_VAR3:%.*]] = phi i32 [ [[GUARD_VAR]], [[B3_GUARD]] ], [ [[TMP1]], [[B3]] ]
; CHECK-NEXT:    [[PREV_GUARD4:%.*]] = icmp eq i32 [[GUARD_VAR3]], 4
; CHECK-NEXT:    br i1 [[PREV_GUARD4]], label [[B4:%.*]], label [[B5_GUARD]]
; CHECK:       b4:
; CHECK-NEXT:    [[LOAD_B4:%.*]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B5_GUARD]]
; CHECK:       b5.guard:
; CHECK-NEXT:    [[GUARD_VAR7:%.*]] = phi i32 [ 5, [[B4]] ], [ [[GUARD_VAR3]], [[B4_GUARD]] ]
; CHECK-NEXT:    [[GUARD_VAR1]] = phi i32 [ 5, [[B4]] ], [ [[GUARD_VAR15]], [[B4_GUARD]] ]
; CHECK-NEXT:    [[PHI_B5_PH]] = phi i32 [ [[LOAD_B4]], [[B4]] ], [ [[PHI_B5_PH6]], [[B4_GUARD]] ]
; CHECK-NEXT:    [[LAST:%.*]] = icmp eq i32 [[GUARD_VAR7]], 5
; CHECK-NEXT:    br i1 [[LAST]], label [[B5:%.*]], label [[B3]]
; CHECK:       b5:
; CHECK-NEXT:    [[PHI_B5:%.*]] = phi i32 [ [[PHI_B5_PH]], [[B5_GUARD]] ]
; CHECK-NEXT:    store volatile i32 [[PHI_B5]], i32 addrspace(1)* null
; CHECK-NEXT:    [[LOAD_B5]] = load volatile i32, i32 addrspace(1)* null
; CHECK-NEXT:    br label [[B5_SPLIT]]
; CHECK:       b5.split:
; CHECK-NEXT:    br label [[B3_GUARD]]
; CHECK:       b6:
; CHECK-NEXT:    store volatile i32 [[LOAD_B3]], i32 addrspace(1)* null
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %b1

b1:
  %load.b1 = load volatile i32, i32 addrspace(1)* null
  br i1 %cond0, label %b2, label %b5

b2:
  %load.b2 = load volatile i32, i32 addrspace(1)* null
  br label %b3

b3:
  %phi.b3 = phi i32 [%load.b2, %b2], [%load.b5, %b5]
  %load.b3 = load volatile i32, i32 addrspace(1)* null
  br i1 %cond1, label %b4, label %b6

b4:
  %load.b4 = load volatile i32, i32 addrspace(1)* null
  br label %b5

b5:
  %phi.b5 = phi i32 [%load.b1, %b1], [%load.b4, %b4]
  store volatile i32 %phi.b5, i32 addrspace(1)* null
  %load.b5 = load volatile i32, i32 addrspace(1)* null
  br label %b3

b6:
  store volatile i32 %load.b3, i32 addrspace(1)* null
  br label %exit

exit:
  ret void
}
