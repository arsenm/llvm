; RUN: opt -mtriple=amdgcn-unknown-amdhsa -mcpu=hawaii -loop-unroll -S < %s | FileCheck %s

; define void @unroll_opt_for_size() nounwind optsize {
; entry:
;   br label %loop

; loop:
;   %iv = phi i32 [ 0, %entry ], [ %inc, %loop ]
;   %inc = add i32 %iv, 1
;   %exitcnd = icmp uge i32 %inc, 1024
;   br i1 %exitcnd, label %exit, label %loop

; exit:
;   ret void
; }

define i64 @test_sdiv64(i64 addrspace(1)* nocapture %a, i32 %n) nounwind readonly {
entry:
  %cmp1 = icmp eq i32 %n, 0
  br i1 %cmp1, label %for.end, label %for.body

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body ], [ 0, %entry ]
  %sum.02 = phi i64 [ %add, %for.body ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds i64, i64 addrspace(1)* %a, i64 %indvars.iv
  %load = load i64, i64 addrspace(1)* %arrayidx
  %add = sdiv i64 %load, %sum.02
;  %add = add i64 %load, %sum.02
  %indvars.iv.next = add i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
;  %exitcond = icmp eq i32 %lftr.wideiv, %n
  %exitcond = icmp eq i32 %lftr.wideiv, 4
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body, %entry
  %sum.0.lcssa = phi i64 [ 0, %entry ], [ %add, %for.body ]
  ret i64 %sum.0.lcssa
}

