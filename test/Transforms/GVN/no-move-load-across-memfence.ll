; RUN: opt -S -basicaa -gvn < %s | FileCheck %s
target datalayout = "e-p:32:32:32"

declare void @__amdil_barrier_local() #0
declare <4 x i32> @__amdil_get_local_id_int() #1
declare void @__amdil_barrier_global() #3

; CHECK-LABEL: @__OpenCL_execFFT_reduced_kernel(
; CHECK: load <2 x float> addrspace(1)*
; CHECK: store <2 x float> %{{.*}}, <2 x float> addrspace(3)*
; CHECK: call void @__amdil_barrier_local()
; CHECK: br
; CHECK: if.end:
; CHECK: call void @__amdil_barrier_local()
; CHECK: load <2 x float> addrspace(3)*
; CHECK: store <2 x float> %{{.*}}, <2 x float> addrspace(1)*
define void @__OpenCL_execFFT_reduced_kernel(<2 x float> addrspace(1)* noalias nocapture %in, <2 x float> addrspace(1)* noalias nocapture %out, <2 x float> addrspace(3)* noalias nocapture %data0) #2 {
entry:
  %0 = tail call <4 x i32> @__amdil_get_local_id_int() #2
  %1 = extractelement <4 x i32> %0, i32 0
  %arrayidx = getelementptr <2 x float> addrspace(3)* %data0, i32 %1
  %arrayidx3 = getelementptr <2 x float> addrspace(1)* %in, i32 %1
  %tmp4 = load <2 x float> addrspace(1)* %arrayidx3, align 8
  store <2 x float> %tmp4, <2 x float> addrspace(3)* %arrayidx, align 8
  call void @__amdil_barrier_local() #0
  %cmp = icmp ult i32 %1, 5
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %tmp10 = load <2 x float> addrspace(3)* %arrayidx, align 8
  %tmp16 = mul i32 %1, 2
  %arrayidx17 = getelementptr <2 x float> addrspace(3)* %data0, i32 %tmp16
  store <2 x float> %tmp10, <2 x float> addrspace(3)* %arrayidx17, align 8
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  call void @__amdil_barrier_local() #0
  %arrayidx21 = getelementptr <2 x float> addrspace(1)* %out, i32 %1
  %tmp25 = load <2 x float> addrspace(3)* %arrayidx, align 8
  store <2 x float> %tmp25, <2 x float> addrspace(1)* %arrayidx21, align 8
  ret void
}


; The loaded address space isn't fenced, so allow the transform
; XCHECK-LABEL: @different_address_space(
; XCHECK: phi <2 x float> [ %tmp25.pre, %if.then ], [ %tmp4, %entry ]
; XCHECK: call void @__amdil_barrier_global()
; define void @different_address_space(<2 x float> addrspace(1)* noalias nocapture %in, <2 x float> addrspace(1)* noalias nocapture %out, <2 x float> addrspace(3)* noalias nocapture %data0) #2 {
; entry:
;   %0 = tail call <4 x i32> @__amdil_get_local_id_int() #2
;   %1 = extractelement <4 x i32> %0, i32 0
;   %arrayidx = getelementptr <2 x float> addrspace(3)* %data0, i32 %1
;   %arrayidx3 = getelementptr <2 x float> addrspace(1)* %in, i32 %1
;   %tmp4 = load <2 x float> addrspace(1)* %arrayidx3, align 8
;   store <2 x float> %tmp4, <2 x float> addrspace(3)* %arrayidx, align 8
;   call void @__amdil_barrier_global() #3
;   %cmp = icmp ult i32 %1, 5
;   br i1 %cmp, label %if.then, label %if.end

; if.then:                                          ; preds = %entry
;   %tmp10 = load <2 x float> addrspace(3)* %arrayidx, align 8
;   %tmp16 = mul i32 %1, 2
;   %arrayidx17 = getelementptr <2 x float> addrspace(3)* %data0, i32 %tmp16
;   store <2 x float> %tmp10, <2 x float> addrspace(3)* %arrayidx17, align 8
;   br label %if.end

; if.end:                                           ; preds = %if.then, %entry
;   call void @__amdil_barrier_global() #3
;   %arrayidx21 = getelementptr <2 x float> addrspace(1)* %out, i32 %1
;   %tmp25 = load <2 x float> addrspace(3)* %arrayidx, align 8
;   store <2 x float> %tmp25, <2 x float> addrspace(1)* %arrayidx21, align 8
;   ret void
; }

attributes #0 = { noduplicate nounwind nomemfence=0 nomemfence=1 nomemfence=2 }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }
attributes #3 = { noduplicate nounwind nomemfence=0 nomemfence=2 nomemfence=3 }
