; REQUIRES: asserts
; XFAIL: *
; RUN: llc -verify-machineinstrs -march=r600 -mcpu=SI < %s | FileCheck -check-prefix=SI %s

; SI-LABEL: @loop_arg_1
define void @loop_arg_1(float addrspace(3)* %ptr, i32 %n, i1 %cond) nounwind {
entry:
  %cmp0 = icmp ne i32 %n, -1
;  br i1 %cond, label %for.body, label %for.exit
  br i1 %cmp0, label %for.body, label %for.exit

for.exit:
  ret void

for.body:
  %indvar = phi i32 [ %inc, %for.body ], [ 0, %entry ]
  %tmp = add i32 %indvar, 32
  %arrayidx = getelementptr float addrspace(3)* %ptr, i32 %tmp
  %vecload = load float addrspace(3)* %arrayidx, align 4
  %add = fadd float %vecload, 1.0
  store float %add, float addrspace(3)* %arrayidx, align 8
  %inc = add i32 %indvar, 1
  %cmp = icmp eq i32 %inc, 10000
  br i1 %cmp, label %for.body, label %for.exit
}


; The exit block is not dominated by the loop.