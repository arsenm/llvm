; RUN: llc -march=amdgcn -mcpu=verde -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -march=amdgcn -mcpu=bonaire -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s

; FUNC-LABEL: {{^}}v_and_i64_br:
; SI: s_and_b64
define amdgpu_kernel void @v_and_i64_br(i64 addrspace(1)* %out, i64 addrspace(1)* %aptr, i64 addrspace(1)* %bptr) {
entry:
  %tid = call i32 @llvm.amdgcn.mbcnt.lo(i32 -1, i32 0) #0
  %tmp0 = icmp eq i32 %tid, 0
  br i1 %tmp0, label %if, label %endif

if:
  %a = load i64, i64 addrspace(1)* %aptr, align 8
  %b = load i64, i64 addrspace(1)* %bptr, align 8
  %and = and i64 %a, %b
  br label %endif

endif:
  %tmp1 = phi i64 [%and, %if], [0, %entry]
  store i64 %tmp1, i64 addrspace(1)* %out, align 8
  ret void
}

; FIXME: Should use SGPRs
; FUNC-LABEL: {{^}}s_and_v2i1:
; SI: v_and_b32_e32 [[AND0:v[0-9]+]],
; SI-DAG: v_and_b32_e32 [[AND1:v[0-9]+]],
; SI-DAG: v_and_b32_e32 v{{[0-9]+}}, 1, [[AND0]]
; SI-DAG: v_and_b32_e32 v{{[0-9]+}}, 1, [[AND1]]
define void @s_and_v2i1(<2 x i32> addrspace(1)* %out, <2 x i1> %a, <2 x i1> %b) {
  %and = and <2 x i1> %a, %b
  %ext = zext <2 x i1> %and to <2 x i32>
  store <2 x i32> %ext, <2 x i32> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}s_and_v3i1:
; SI: v_and_b32_e32 [[AND0:v[0-9]+]],
; SI-DAG: v_and_b32_e32 [[AND1:v[0-9]+]],
; SI-DAG: v_and_b32_e32 [[AND2:v[0-9]+]],
; SI-DAG: v_and_b32_e32 v{{[0-9]+}}, 1, [[AND0]]
; SI-DAG: v_and_b32_e32 v{{[0-9]+}}, 1, [[AND1]]
; SI-DAG: v_and_b32_e32 v{{[0-9]+}}, 1, [[AND2]]
define void @s_and_v3i1(<3 x i32> addrspace(1)* %out, <3 x i1> %a, <3 x i1> %b) {
  %and = and <3 x i1> %a, %b
  %ext = zext <3 x i1> %and to <3 x i32>
  store <3 x i32> %ext, <3 x i32> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}s_and_v4i1:
; SI: v_and_b32_e32 [[AND0:v[0-9]+]],
; SI-DAG: v_and_b32_e32 [[AND1:v[0-9]+]],
; SI-DAG: v_and_b32_e32 [[AND2:v[0-9]+]],
; SI-DAG: v_and_b32_e32 [[AND3:v[0-9]+]],
; SI-DAG: v_and_b32_e32 v{{[0-9]+}}, 1, [[AND0]]
; SI-DAG: v_and_b32_e32 v{{[0-9]+}}, 1, [[AND1]]
; SI-DAG: v_and_b32_e32 v{{[0-9]+}}, 1, [[AND2]]
; SI-DAG: v_and_b32_e32 v{{[0-9]+}}, 1, [[AND3]]
define void @s_and_v4i1(<4 x i32> addrspace(1)* %out, <4 x i1> %a, <4 x i1> %b) {
  %and = and <4 x i1> %a, %b
  %ext = zext <4 x i1> %and to <4 x i32>
  store <4 x i32> %ext, <4 x i32> addrspace(1)* %out
  ret void
}

declare i32 @llvm.amdgcn.mbcnt.lo(i32, i32) #0

attributes #0 = { nounwind readnone }
