; RUN: llc -march=r600 -mcpu=SI < %s | FileCheck -check-prefix=SI %s

; FIXME: Fails with -verify-machineinstrs

; SI-LABEL: @test_loop
; SI: [[LABEL:BB[0-9+]_[0-9]+]]:
; SI: DS_READ_B32
; SI: DS_WRITE_B32
; SI: S_BRANCH [[LABEL]]
; SI: S_ENDPGM
define void @test_loop(float addrspace(3)* %ptr, i32 %n) nounwind {
entry:
  %cmp = icmp eq i32 %n, -1
  br i1 %cmp, label %for.exit, label %for.body

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
  br label %for.body
}

; XXX - This needs to be tested at -O0, but that hits a different problem.
; XXX - Does this need an S_ENDPGM?

; SI-LABEL: @loop_const_true
; SI: [[LABEL:BB[0-9+]_[0-9]+]]:
; SI: DS_READ_B32
; SI: DS_WRITE_B32
; SI: S_BRANCH [[LABEL]]
define void @loop_const_true(float addrspace(3)* %ptr, i32 %n) nounwind {
entry:
  br label %for.body

for.exit:
  ret void

; XXX - Should there be an S_ENDPGM?
for.body:
  %indvar = phi i32 [ %inc, %for.body ], [ 0, %entry ]
  %tmp = add i32 %indvar, 32
  %arrayidx = getelementptr float addrspace(3)* %ptr, i32 %tmp
  %vecload = load float addrspace(3)* %arrayidx, align 4
  %add = fadd float %vecload, 1.0
  store float %add, float addrspace(3)* %arrayidx, align 8
  %inc = add i32 %indvar, 1
  br i1 true, label %for.body, label %for.exit
}

; SI-LABEL: @loop_const_false
; SI-NOT: S_BRANCH
; SI: S_ENDPGM
define void @loop_const_false(float addrspace(3)* %ptr, i32 %n) nounwind {
entry:
  br label %for.body

for.exit:
  ret void

; XXX - Should there be an S_ENDPGM?
for.body:
  %indvar = phi i32 [ %inc, %for.body ], [ 0, %entry ]
  %tmp = add i32 %indvar, 32
  %arrayidx = getelementptr float addrspace(3)* %ptr, i32 %tmp
  %vecload = load float addrspace(3)* %arrayidx, align 4
  %add = fadd float %vecload, 1.0
  store float %add, float addrspace(3)* %arrayidx, align 8
  %inc = add i32 %indvar, 1
  br i1 false, label %for.body, label %for.exit
}

; SI-LABEL: @loop_const_undef
; SI-NOT: S_BRANCH
; SI: S_ENDPGM
define void @loop_const_undef(float addrspace(3)* %ptr, i32 %n) nounwind {
entry:
  br label %for.body

for.exit:
  ret void

; XXX - Should there be an S_ENDPGM?
for.body:
  %indvar = phi i32 [ %inc, %for.body ], [ 0, %entry ]
  %tmp = add i32 %indvar, 32
  %arrayidx = getelementptr float addrspace(3)* %ptr, i32 %tmp
  %vecload = load float addrspace(3)* %arrayidx, align 4
  %add = fadd float %vecload, 1.0
  store float %add, float addrspace(3)* %arrayidx, align 8
  %inc = add i32 %indvar, 1
  br i1 undef, label %for.body, label %for.exit
}

; SI-LABEL: @loop_arg_0
; SI: S_CBRANCH_EXECNZ
define void @loop_arg_0(float addrspace(3)* %ptr, i32 %n, i1 %cond) nounwind {
entry:
  br label %for.body

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
  br i1 %cond, label %for.body, label %for.exit
}

