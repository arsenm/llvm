; RUN: llc -march=amdgcn -mcpu=verde -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=SI %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=VI %s

; GCN-LABEL: {{^}}anyext_i1_i32:
; GCN: v_cndmask_b32_e64
define void @anyext_i1_i32(i32 addrspace(1)* %out, i32 %cond) {
entry:
  %tmp = icmp eq i32 %cond, 0
  %tmp1 = zext i1 %tmp to i8
  %tmp2 = xor i8 %tmp1, -1
  %tmp3 = and i8 %tmp2, 1
  %tmp4 = zext i8 %tmp3 to i32
  store i32 %tmp4, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}s_anyext_i16_i32:
; VI: v_add_u16_e32 [[ADD:v[0-9]+]],
; VI: v_not_b32_e32 [[NOT:v[0-9]+]], [[ADD]]
; VI: v_and_b32_e32 [[AND:v[0-9]+]], 1, [[NOT]]
; VI: buffer_store_dword [[AND]]
define void @s_anyext_i16_i32(i32 addrspace(1)* %out, i16 %a, i16 %b) {
entry:
  %tmp = add i16 %a, %b
  %tmp1 = trunc i16 %tmp to i8
  %tmp2 = xor i8 %tmp1, -1
  %tmp3 = and i8 %tmp2, 1
  %tmp4 = zext i8 %tmp3 to i32
  store i32 %tmp4, i32 addrspace(1)* %out
  ret void
}
