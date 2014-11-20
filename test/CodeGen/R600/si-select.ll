; RUN: llc -verify-machineinstrs -march=r600 -mcpu=SI < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s

declare i32 @llvm.r600.read.tidig.x() nounwind readnone

; XXX - Eventually the final SALU instruction should be moved to the
; VALU, and then another SALU instruction should be added so the
; select is still scalar.

; FUNC-LABEL: @s_select_i32
; SI-DAG: s_load_dword [[A:s[0-9]+]], {{s\[[0-9]+:[0-9]+\]}}, 0xb
; SI-DAG: s_load_dword [[B:s[0-9]+]], {{s\[[0-9]+:[0-9]+\]}}, 0xc
; SI-DAG: s_load_dword [[C:s[0-9]+]], {{s\[[0-9]+:[0-9]+\]}}, 0xd
; SI: s_cmp_eq_i32 scc, [[C]], 0
; SI-NEXT: s_cselect_b32 [[SRESULT:s[0-9]+]], [[B]], [[A]] [scc]
; SI: v_mov_b32_e32 [[VRESULT:v[0-9]+]], [[SRESULT]]
; SI: buffer_store_dword [[VRESULT]]
; SI: s_endpgm
define void @s_select_i32(i32 addrspace(1)* %out, i32 %a, i32 %b, i32 %c) nounwind {
  %cmp = icmp eq i32 %c, 0
  %select = select i1 %cmp, i32 %a, i32 %b
  store i32 %select, i32 addrspace(1)* %out, align 4
  ret void
}

; Vector condition select on vector values
; FUNC-LABEL: @v_select_i32
; SI-DAG: buffer_load_dword [[A:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64{{$}}
; SI-DAG: buffer_load_dword [[B:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64 offset:0x4
; SI-DAG: buffer_load_dword [[C:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64 offset:0x8
; SI: v_cmp_eq_i32_e64 [[CMP:s\[[0-9]+:[0-9]+\]]], [[C]], 0
; SI: v_cndmask_b32_e64 [[RESULT:v[0-9]+]], [[B]], [[A]], [[CMP]]
; SI: buffer_store_dword [[RESULT]]
; SI: s_endpgm
define void @v_select_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in) nounwind {
  %tid = call i32 @llvm.r600.read.tidig.x() nounwind readnone
  %gep.0 = getelementptr i32 addrspace(1)* %in, i32 %tid
  %gep.1 = getelementptr i32 addrspace(1)* %gep.0, i32 1
  %gep.2 = getelementptr i32 addrspace(1)* %gep.0, i32 2

  %a = load i32 addrspace(1)* %gep.0
  %b = load i32 addrspace(1)* %gep.1
  %c = load i32 addrspace(1)* %gep.2

  %cmp = icmp eq i32 %c, 0
  %select = select i1 %cmp, i32 %a, i32 %b

  store i32 %select, i32 addrspace(1)* %out, align 4
  ret void
}

; Scalar condition select on vector values
; FUNC-LABEL: @v_s_cond_select_i32
; SI-DAG: s_load_dword [[C:s[0-9]+]], {{s\[[0-9]+:[0-9]+\]}}, 0xd
; SI-DAG: buffer_load_dword [[A:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64{{$}}
; SI-DAG: buffer_load_dword [[B:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64 offset:0x4
; SI: v_cmp_eq_i32_e64 [[CMP:s\[[0-9]+:[0-9]+\]]], [[C]], 0
; SI: v_cndmask_b32_e64 [[RESULT:v[0-9]+]], [[B]], [[A]], [[CMP]]
; SI: buffer_store_dword [[RESULT]]
; SI: s_endpgm
define void @v_s_cond_select_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in, i32 %c) nounwind {
  %tid = call i32 @llvm.r600.read.tidig.x() nounwind readnone
  %gep.0 = getelementptr i32 addrspace(1)* %in, i32 %tid
  %gep.1 = getelementptr i32 addrspace(1)* %gep.0, i32 1

  %a = load i32 addrspace(1)* %gep.0
  %b = load i32 addrspace(1)* %gep.1

  %cmp = icmp eq i32 %c, 0
  %select = select i1 %cmp, i32 %a, i32 %b

  store i32 %select, i32 addrspace(1)* %out, align 4
  ret void
}
