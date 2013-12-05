; RUN: opt -S -functionattrs < %s | FileCheck %s

declare void @test_barrier_intrinsic_unknown_fence() #0
declare void @test_barrier_intrinsic_nofence_1() #1
declare void @test_barrier_intrinsic_nofence_2() #2
declare void @test_barrier_intrinsic_nofence_1_2() #3
declare i32 @test_nofences() #4

; CHECK-DAG: @call_unknown_fence(i32* nocapture %p) [[CALL_UNKNOWN_FENCE_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[CALL_UNKNOWN_FENCE_ATTRGRP]] = { nounwind }
define i32 @call_unknown_fence(i32* nocapture %p) #0 {
  store i32 42, i32* %p, align 4
  call void @test_barrier_intrinsic_unknown_fence() #0
  %result = load i32* %p, align 4
  ret i32 %result
}

; CHECK-DAG: @call_two_unknown_fence(i32* nocapture %p) [[CALL_TWO_UNKNOWN_FENCE_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[CALL_TWO_UNKNOWN_FENCE_ATTRGRP]] = { nounwind }
define i32 @call_two_unknown_fence(i32* nocapture %p) #0 {
  store i32 42, i32* %p, align 4
  call void @test_barrier_intrinsic_unknown_fence() #0
  call void @test_barrier_intrinsic_unknown_fence() #0
  %result = load i32* %p, align 4
  ret i32 %result
}

; CHECK-DAG: @call_nofence_1(i32* nocapture %p) [[CALL_NO_FENCE_1_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[CALL_NO_FENCE_1_ATTRGRP]] = { nounwind nomemfence=1 }
define i32 @call_nofence_1(i32* nocapture %p) #0 {
  store i32 42, i32* %p, align 4
  call void @test_barrier_intrinsic_nofence_1() #1
  %result = load i32* %p, align 4
  ret i32 %result
}

; CHECK-DAG: @call_nofence_1_unknown(i32* nocapture %p) [[CALL_NO_FENCE_1_UNKNOWN_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[CALL_NO_FENCE_1_UNKNOWN_ATTRGRP]] = { nounwind }
define i32 @call_nofence_1_unknown(i32* nocapture %p) #0 {
  store i32 42, i32* %p, align 4
  call void @test_barrier_intrinsic_nofence_1() #1
  call void @test_barrier_intrinsic_unknown_fence() #0
  %result = load i32* %p, align 4
  ret i32 %result
}

; CHECK-DAG: @call_fence_1_2(i32* nocapture %p) [[CALL_FENCE_1_2_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[CALL_FENCE_1_2_ATTRGRP]] = { nounwind nomemfence=1 nomemfence=2 }
define i32 @call_fence_1_2(i32* nocapture %p) #0 {
  store i32 42, i32* %p, align 4
  call void @test_barrier_intrinsic_nofence_1_2() #3
  %result = load i32* %p, align 4
  ret i32 %result
}

; CHECK-DAG: @use_fence_inst(i32* nocapture %p) [[USE_FENCE_INST_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[USE_FENCE_INST_ATTRGRP]] = { nounwind }
define i32 @use_fence_inst(i32* nocapture %p) #0 {
  store i32 42, i32* %p, align 4
  fence acquire
  %result = load i32* %p, align 4
  ret i32 %result
}

; CHECK-DAG: @call_two_same(i32 addrspace(1)* nocapture %p) [[CALL_TWO_SAME_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[CALL_TWO_SAME_ATTRGRP]] = { nounwind nomemfence=1 nomemfence=2 }
define i32 @call_two_same(i32 addrspace(1)* nocapture %p) #0 {
  store i32 42, i32 addrspace(1)* %p, align 4
  call void @test_barrier_intrinsic_nofence_1_2() #3
  %result = load i32 addrspace(1)* %p, align 4
  call void @test_barrier_intrinsic_nofence_1_2() #3
  ret i32 %result
}

; One of the calls has a nomemfence for two, but the second call only
; has a nomemfence for one. Only the common fence should remain.

; CHECK-DAG: @call_two_different_sub(i32 addrspace(1)* nocapture %p) [[CALL_TWO_DIFFERENT_SUB_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[CALL_TWO_DIFFERENT_SUB_ATTRGRP]] = { nounwind nomemfence=1 }
define i32 @call_two_different_sub(i32 addrspace(1)* nocapture %p) #0 {
  store i32 42, i32 addrspace(1)* %p, align 4
  call void @test_barrier_intrinsic_nofence_1_2() #3
  %result = load i32 addrspace(1)* %p, align 4
  call void @test_barrier_intrinsic_nofence_1() #1
  ret i32 %result
}

; disjoint sets of nomemfences
; CHECK-DAG: @call_two_different_none(i32 addrspace(1)* nocapture %p) [[CALL_TWO_DIFFERENT_NONE_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[CALL_TWO_DIFFERENT_NONE_ATTRGRP]] = { nounwind }
define i32 @call_two_different_none(i32 addrspace(1)* nocapture %p) #0 {
  store i32 42, i32 addrspace(1)* %p, align 4
  call void @test_barrier_intrinsic_nofence_2() #2
  %result = load i32 addrspace(1)* %p, align 4
  call void @test_barrier_intrinsic_nofence_1() #1
  ret i32 %result
}

; Don't add to pure functions since it's redundant
; CHECK-DAG: @pure_function(i32 %x, i32 addrspace(1)* nocapture readonly %p) [[CALL_PURE_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[CALL_PURE_ATTRGRP]] = { nounwind readonly }
define i32 @pure_function(i32 %x, i32 addrspace(1)* nocapture readonly %p) #5 {
  %load = load i32 addrspace(1)* %p
  %result = add i32 %x, %load
  ret i32 %result
}

; Don't add to const functions since it's redundant
; CHECK-DAG: @const_function(i32 %x) [[CALL_CONST_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[CALL_CONST_ATTRGRP]] = { nounwind readnone }
define i32 @const_function(i32 %x) #6 {
  %result = add i32 %x, 1
  ret i32 %result
}

; CHECK-DAG: @impure_nofences(i32 addrspace(1)* nocapture %p) [[CALL_IMPURE_NOFENCES_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[CALL_IMPURE_NOFENCES_ATTRGRP]] = { nounwind nomemfence }
define void @impure_nofences(i32 addrspace(1)* %p) #0 {
  store i32 999, i32 addrspace(1)* %p, align 4
  ret void
}

; CHECK-DAG: @call_nofences(i32 addrspace(1)* nocapture %p) [[CALL_NOFENCES_ATTRGRP:#[0-9]+]]
; CHECK-DAG: [[CALL_NOFENCES_ATTRGRP]] = { nounwind nomemfence }
define void @call_nofences(i32 addrspace(1)* %p) #0 {
  %x = call i32 @test_nofences() #4
  store i32 %x, i32 addrspace(1)* %p, align 4
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { nounwind nomemfence=1 }
attributes #2 = { nounwind nomemfence=2 }
attributes #3 = { nounwind nomemfence=1 nomemfence=2 }
attributes #4 = { nounwind nomemfence }
attributes #5 = { nounwind readonly }
attributes #6 = { nounwind readnone }
