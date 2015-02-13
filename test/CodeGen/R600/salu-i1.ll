; RUN: llc -march=amdgcn -verify-machineinstrs < %s | FileCheck -check-prefix=SI %s

declare i32 @llvm.r600.read.tidig.x() #0
declare void @llvm.AMDGPU.barrier.global() #2

; SI-LABEL: {{^}}s_select:
; SI: s_load_dword [[P:s[0-9]+]],
; SI: s_cmp_eq_i32 [[P]], 8
; SI-NEXT: s_cselect_b32 [[SRESULT:s[0-9]+]], 2, 1
; SI: v_mov_b32_e32 [[VRESULT:v[0-9]+]], [[SRESULT]]
; SI: buffer_store_dword [[VRESULT]]
; SI: s_endpgm
define void @s_select(i32 addrspace(1)* %out, i32 %p) #1 {
  %cmp = icmp eq i32 %p, 8
  %a = select i1 %cmp, i32 1, i32 2
  store i32 %a, i32 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_select_2use:
; SI: s_load_dword [[P:s[0-9]+]],
; SI: s_cmp_eq_i32 [[P]], 8
; SI-NEXT: s_cselect_b32 [[SRESULT0:s[0-9]+]], 2, 1
; SI-NEXT: s_cselect_b32 [[SRESULT1:s[0-9]+]], 32, 21
; SI-DAG: v_mov_b32_e32 [[VRESULT0:v[0-9]+]], [[SRESULT0]]
; SI-DAG: v_mov_b32_e32 [[VRESULT1:v[0-9]+]], [[SRESULT1]]
; SI-DAG: buffer_store_dword [[VRESULT0]]
; SI-DAG: buffer_store_dword [[VRESULT1]]
; SI: s_endpgm
define void @s_select_2use(i32 addrspace(1)* %out0, i32 addrspace(1)* %out1, i32 %p) #1 {
  %cmp = icmp eq i32 %p, 8
  %a = select i1 %cmp, i32 1, i32 2
  %b = select i1 %cmp, i32 21, i32 32
  store i32 %a, i32 addrspace(1)* %out0
  store i32 %b, i32 addrspace(1)* %out1
  ret void
}

; SI-LABEL: {{^}}s_select_and:
; SI: v_cmp_eq_i32
; SI: v_cmp_eq_i32
; SI: s_and_b64
; SI: s_endpgm
define void @s_select_and(i32 addrspace(1)* %out, i32 %p, i32 %q) #1 {
  %cmp0 = icmp eq i32 %p, 8
  %cmp1 = icmp eq i32 %q, 8
  %and = and i1 %cmp0, %cmp1
  %a = select i1 %and, i32 1, i32 2
  store i32 %a, i32 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_select_and_2use:
; SI: v_cmp_eq_i32
; SI: v_cmp_eq_i32
; SI: s_and_b64
; SI: s_endpgm
define void @s_select_and_2use(i32 addrspace(1)* %out0, i32 addrspace(1)* %out1, i32 %p, i32 %q) #1 {
  %cmp0 = icmp eq i32 %p, 8
  %cmp1 = icmp eq i32 %q, 8
  %and = and i1 %cmp0, %cmp1
  %a = select i1 %and, i32 1, i32 2
  %b = select i1 %and, i32 91, i32 -1
  store i32 %a, i32 addrspace(1)* %out0
  store i32 %b, i32 addrspace(1)* %out1
  ret void
}

; SI-LABEL: {{^}}s_select_many_use:
; SI: s_endpgm
define void @s_select_many_use(i32 addrspace(1)* %out0,
                               i32 addrspace(1)* %out1,
                               i32 addrspace(1)* %out2,
                               i32 addrspace(1)* %out3,
                               i32 addrspace(1)* %out4,
                               i32 addrspace(1)* %out5,
                               i32 addrspace(1)* %out6,
                               i32 addrspace(1)* %out7,
                               i32 addrspace(1)* %out8,
                               i32 addrspace(1)* %out9,
                               i32 addrspace(1)* %out10,
                               i32 addrspace(1)* %out11,
                               i32 addrspace(1)* %out12,
                               i32 addrspace(1)* %out13,
                               i32 addrspace(1)* %out14,
                               i32 addrspace(1)* %out15,
                               i32 addrspace(1)* %out.extra,
                               i32 %p,
                               i32 %q,
                               i64 %offset0) #1 {
  %tid = call i32 @llvm.r600.read.tidig.x() #0
  %tid.ext = zext i32 %tid to i64
  %offset0.add1 = add i64 %offset0, 1
  %add.offset0 = add i64 %tid.ext, %offset0.add1
  %gep.0 = getelementptr i32 addrspace(1)* %out0, i64 %add.offset0

  %cmp = icmp eq i32 %p, 8
  %sel.0 = select i1 %cmp, i32 1, i32 2
  %sel.1 = select i1 %cmp, i32 21, i32 32
  %sel.2 = select i1 %cmp, i32 1, i32 9
  %sel.3 = select i1 %cmp, i32 23, i32 44
  %sel.4 = select i1 %cmp, i32 -16, i32 64
  %sel.5 = select i1 %cmp, i32 -16, i32 63
  %sel.6 = select i1 %cmp, i32 -3, i32 27
  %sel.7 = select i1 %cmp, i32 -11, i32 16
  %sel.8 = select i1 %cmp, i32 -13, i32 18
  %sel.9 = select i1 %cmp, i32 -14, i32 16
  %sel.10 = select i1 %cmp, i32 -15, i32 18
  %sel.11 = select i1 %cmp, i32 -7, i32 19
  %sel.12 = select i1 %cmp, i32 -8, i32 -16
  %sel.13 = select i1 %cmp, i32 -12, i32 -3
  %sel.14 = select i1 %cmp, i32 -3, i32 -9
  %sel.15 = select i1 %cmp, i32 -3, i32 62

  %q.shl = shl i32 %q, 2
  %q.shl.ext = zext i32 %q.shl to i64
  %gep.extra = getelementptr i32 addrspace(1)* %out.extra, i64 %q.shl.ext


  store i32 %sel.0, i32 addrspace(1)* %out0
  store i32 %sel.1, i32 addrspace(1)* %out1
  store i32 %sel.2, i32 addrspace(1)* %out2
  store i32 %sel.3, i32 addrspace(1)* %out3
  store i32 %sel.4, i32 addrspace(1)* %out4
  store i32 %sel.5, i32 addrspace(1)* %out5
  store i32 %sel.6, i32 addrspace(1)* %out6
  store i32 %sel.7, i32 addrspace(1)* %out7

  call void @llvm.AMDGPU.barrier.global() #2
  store i32 %q.shl, i32 addrspace(1)* %gep.extra

  store i32 %sel.8, i32 addrspace(1)* %out8
  store i32 %sel.9, i32 addrspace(1)* %out9
  store i32 %sel.10, i32 addrspace(1)* %out10
  store i32 %sel.11, i32 addrspace(1)* %out11
  store i32 %sel.12, i32 addrspace(1)* %out12
  store i32 %sel.13, i32 addrspace(1)* %out13
  store i32 %sel.14, i32 addrspace(1)* %out14
  store i32 %sel.15, i32 addrspace(1)* %out15

  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
attributes #2 = { nounwind noduplicate }
