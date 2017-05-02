; RUN: opt -S -mtriple=amdgcn-unknown-amdhsa -mcpu=fiji -loop-vectorize < %s | FileCheck %s
;
; CHECK-LABEL: @small_loop_512(
; CHECK: load i32
; CHECK: load i32
; CHECK: load i32
; CHECK: load i32
; CHECK: load i32
; CHECK: load i32
; CHECK: load i32
; CHECK: load i32
; CHECK: add nsw i32
; CHECK: add nsw i32
; CHECK: add nsw i32
; CHECK: add nsw i32
; CHECK: add nsw i32
; CHECK: add nsw i32
; CHECK: add nsw i32
; CHECK: add nsw i32
; CHECK: store i32
; CHECK: store i32
; CHECK: store i32
; CHECK: store i32
; CHECK: store i32
; CHECK: store i32
; CHECK: store i32
; CHECK: store i32
define amdgpu_kernel void @small_loop_512(i32 addrspace(1)* nocapture %inArray, i32 %size) #0 {
entry:
  br label %loop

loop:                                          ; preds = %entry, %loop
  %iv = phi i32 [ %iv1, %loop ], [ 0, %entry ]
  %gep = getelementptr inbounds i32, i32 addrspace(1)* %inArray, i32 %iv
  %load = load i32, i32 addrspace(1)* %gep, align 4
  %add = add nsw i32 %load, 6
  store i32 %add, i32 addrspace(1)* %gep, align 4
  %iv1 = add i32 %iv, 1
  %cond = icmp eq i32 %iv1, 512
  br i1 %cond, label %exit, label %loop

exit:                                         ; preds = %loop, %entry
  ret void
}
