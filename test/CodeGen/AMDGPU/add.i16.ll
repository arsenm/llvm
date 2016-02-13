; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=VI -check-prefix=GCN %s

; GCN-LABEL: {{^}}v_test_add_i16:
; VI: flat_load_ushort [[A:v[0-9]+]]
; VI: flat_load_ushort [[B:v[0-9]+]]
; VI: v_add_u16_e32 [[ADD:v[0-9]+]], [[A]], [[B]]
; VI-NEXT: buffer_store_short [[ADD]]
define void @v_test_add_i16(i16 addrspace(1)* %out, i16 addrspace(1)* %in0, i16 addrspace(1)* %in1) #1 {
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %gep.out = getelementptr inbounds i16, i16 addrspace(1)* %out, i32 %tid
  %gep.in0 = getelementptr inbounds i16, i16 addrspace(1)* %in0, i32 %tid
  %gep.in1 = getelementptr inbounds i16, i16 addrspace(1)* %in1, i32 %tid
  %a = load volatile i16, i16 addrspace(1)* %gep.in0
  %b = load volatile i16, i16 addrspace(1)* %gep.in1
  %add = add i16 %a, %b
  store i16 %add, i16 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}v_test_add_i16_constant:
; VI: flat_load_ushort [[A:v[0-9]+]]
; VI: v_add_u16_e32 [[ADD:v[0-9]+]], 0x7b, [[A]]
; VI-NEXT: buffer_store_short [[ADD]]
define void @v_test_add_i16_constant(i16 addrspace(1)* %out, i16 addrspace(1)* %in0) #1 {
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %gep.out = getelementptr inbounds i16, i16 addrspace(1)* %out, i32 %tid
  %gep.in0 = getelementptr inbounds i16, i16 addrspace(1)* %in0, i32 %tid
  %a = load volatile i16, i16 addrspace(1)* %gep.in0
  %add = add i16 %a, 123
  store i16 %add, i16 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}v_test_add_i16_neg_constant:
; VI: flat_load_ushort [[A:v[0-9]+]]
; VI: v_add_u16_e32 [[ADD:v[0-9]+]], 0xfffffcb3, [[A]]
; VI-NEXT: buffer_store_short [[ADD]]
define void @v_test_add_i16_neg_constant(i16 addrspace(1)* %out, i16 addrspace(1)* %in0) #1 {
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %gep.out = getelementptr inbounds i16, i16 addrspace(1)* %out, i32 %tid
  %gep.in0 = getelementptr inbounds i16, i16 addrspace(1)* %in0, i32 %tid
  %a = load volatile i16, i16 addrspace(1)* %gep.in0
  %add = add i16 %a, -845
  store i16 %add, i16 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}v_test_add_i16_inline_neg1:
; VI: flat_load_ushort [[A:v[0-9]+]]
; VI: v_add_u16_e32 [[ADD:v[0-9]+]], -1, [[A]]
; VI-NEXT: buffer_store_short [[ADD]]
define void @v_test_add_i16_inline_neg1(i16 addrspace(1)* %out, i16 addrspace(1)* %in0) #1 {
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %gep.out = getelementptr inbounds i16, i16 addrspace(1)* %out, i32 %tid
  %gep.in0 = getelementptr inbounds i16, i16 addrspace(1)* %in0, i32 %tid
  %a = load volatile i16, i16 addrspace(1)* %gep.in0
  %add = add i16 %a, -1
  store i16 %add, i16 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}v_test_add_i16_zext_to_i32:
; VI: flat_load_ushort [[A:v[0-9]+]]
; VI: flat_load_ushort [[B:v[0-9]+]]
; VI: v_add_u16_e32 [[ADD:v[0-9]+]], [[A]], [[B]]
; VI-NEXT: buffer_store_dword [[ADD]]
define void @v_test_add_i16_zext_to_i32(i32 addrspace(1)* %out, i16 addrspace(1)* %in0, i16 addrspace(1)* %in1) #1 {
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %gep.out = getelementptr inbounds i32, i32 addrspace(1)* %out, i32 %tid
  %gep.in0 = getelementptr inbounds i16, i16 addrspace(1)* %in0, i32 %tid
  %gep.in1 = getelementptr inbounds i16, i16 addrspace(1)* %in1, i32 %tid
  %a = load volatile i16, i16 addrspace(1)* %gep.in0
  %b = load volatile i16, i16 addrspace(1)* %gep.in1
  %add = add i16 %a, %b
  %ext = zext i16 %add to i32
  store i32 %ext, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}v_test_add_i16_zext_to_i64:
; VI: flat_load_ushort [[A:v[0-9]+]]
; VI: flat_load_ushort [[B:v[0-9]+]]
; VI-DAG: v_add_u16_e32 v[[ADD:[0-9]+]], [[A]], [[B]]
; VI-DAG: v_mov_b32_e32 v[[VZERO:[0-9]+]], 0{{$}}
; VI: buffer_store_dwordx2 v{{\[}}[[ADD]]:[[VZERO]]{{\]}}
define void @v_test_add_i16_zext_to_i64(i64 addrspace(1)* %out, i16 addrspace(1)* %in0, i16 addrspace(1)* %in1) #1 {
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %gep.out = getelementptr inbounds i64, i64 addrspace(1)* %out, i32 %tid
  %gep.in0 = getelementptr inbounds i16, i16 addrspace(1)* %in0, i32 %tid
  %gep.in1 = getelementptr inbounds i16, i16 addrspace(1)* %in1, i32 %tid
  %a = load volatile i16, i16 addrspace(1)* %gep.in0
  %b = load volatile i16, i16 addrspace(1)* %gep.in1
  %add = add i16 %a, %b
  %ext = zext i16 %add to i64
  store i64 %ext, i64 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}v_test_add_i16_sext_to_i32:
; VI: flat_load_ushort [[A:v[0-9]+]]
; VI: flat_load_ushort [[B:v[0-9]+]]
; VI: v_add_u16_e32 [[ADD:v[0-9]+]], [[A]], [[B]]
; VI-NEXT: v_bfe_i32 [[SEXT:v[0-9]+]], [[ADD]], 0, 16
; VI-NEXT: buffer_store_dword [[SEXT]]
define void @v_test_add_i16_sext_to_i32(i32 addrspace(1)* %out, i16 addrspace(1)* %in0, i16 addrspace(1)* %in1) #1 {
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %gep.out = getelementptr inbounds i32, i32 addrspace(1)* %out, i32 %tid
  %gep.in0 = getelementptr inbounds i16, i16 addrspace(1)* %in0, i32 %tid
  %gep.in1 = getelementptr inbounds i16, i16 addrspace(1)* %in1, i32 %tid
  %a = load i16, i16 addrspace(1)* %gep.in0
  %b = load i16, i16 addrspace(1)* %gep.in1
  %add = add i16 %a, %b
  %ext = sext i16 %add to i32
  store i32 %ext, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}v_test_add_i16_sext_to_i64:
; VI: flat_load_ushort [[A:v[0-9]+]]
; VI: flat_load_ushort [[B:v[0-9]+]]
; VI: v_add_u16_e32 [[ADD:v[0-9]+]], [[A]], [[B]]
; VI-NEXT: v_bfe_i32 v[[LO:[0-9]+]], [[ADD]], 0, 16
; VI-NEXT: v_ashrrev_i32_e32 v[[HI:[0-9]+]], 31, v[[LO]]
; VI-NEXT: buffer_store_dwordx2 v{{\[}}[[LO]]:[[HI]]{{\]}}
define void @v_test_add_i16_sext_to_i64(i64 addrspace(1)* %out, i16 addrspace(1)* %in0, i16 addrspace(1)* %in1) #1 {
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %gep.out = getelementptr inbounds i64, i64 addrspace(1)* %out, i32 %tid
  %gep.in0 = getelementptr inbounds i16, i16 addrspace(1)* %in0, i32 %tid
  %gep.in1 = getelementptr inbounds i16, i16 addrspace(1)* %in1, i32 %tid
  %a = load i16, i16 addrspace(1)* %gep.in0
  %b = load i16, i16 addrspace(1)* %gep.in1
  %add = add i16 %a, %b
  %ext = sext i16 %add to i64
  store i64 %ext, i64 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}s_test_add_i16:
; VI-DAG: s_load_dword [[A:s[0-9]+]], s[0:1], 0x2c
; VI-DAG: s_load_dword [[B:s[0-9]+]], s[0:1], 0x30
; VI-DAG: v_mov_b32_e32 [[VA:v[0-9]+]], [[A]]
; VI: v_add_u16_e32 [[RESULT:v[0-9]+]], [[B]], [[VA]]
; VI-NEXT: buffer_store_short [[RESULT]]
define void @s_test_add_i16(i16 addrspace(1)* %out, i16 %a, i16 %b) #1 {
  %add = add i16 %a, %b
  store i16 %add, i16 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}s_test_add_i16_zeroext_args:
; VI-DAG: s_load_dword [[A:s[0-9]+]], s[0:1], 0x2c
; VI-DAG: s_load_dword [[B:s[0-9]+]], s[0:1], 0x30
; VI-DAG: v_mov_b32_e32 [[VA:v[0-9]+]], [[A]]
; VI: v_add_u16_e32 [[RESULT:v[0-9]+]], [[B]], [[VA]]
; VI-NEXT: buffer_store_short [[RESULT]]
define void @s_test_add_i16_zeroext_args(i16 addrspace(1)* %out, i16 zeroext %a, i16 zeroext %b) #1 {
  %add = add i16 %a, %b
  store i16 %add, i16 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}s_test_add_i16_signext_args:
; VI-DAG: s_load_dword [[A:s[0-9]+]], s[0:1], 0x2c
; VI-DAG: s_load_dword [[B:s[0-9]+]], s[0:1], 0x30
; VI-DAG: v_mov_b32_e32 [[VA:v[0-9]+]], [[A]]
; VI: v_add_u16_e32 [[RESULT:v[0-9]+]], [[B]], [[VA]]
; VI-NEXT: buffer_store_short [[RESULT]]
define void @s_test_add_i16_signext_args(i16 addrspace(1)* %out, i16 signext %a, i16 signext %b) #1 {
  %add = add i16 %a, %b
  store i16 %add, i16 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}s_test_add_i16_zext_to_i32:
; VI-DAG: s_load_dword [[A:s[0-9]+]], s[0:1], 0x2c
; VI-DAG: s_load_dword [[B:s[0-9]+]], s[0:1], 0x30
; VI-DAG: v_mov_b32_e32 [[VA:v[0-9]+]], [[A]]
; VI: v_add_u16_e32 [[ADD:v[0-9]+]], [[B]], [[VA]]
; VI-NEXT: buffer_store_dword [[RESULT]]
define void @s_test_add_i16_zext_to_i32(i32 addrspace(1)* %out, i16 zeroext %a, i16 zeroext %b) #1 {
  %add = add i16 %a, %b
  %ext = zext i16 %add to i32
  store i32 %ext, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}s_test_add_i16_zext_to_i64:
; VI-DAG: s_load_dword [[A:s[0-9]+]], s[0:1], 0x2c
; VI-DAG: s_load_dword [[B:s[0-9]+]], s[0:1], 0x30
; VI-DAG: v_mov_b32_e32 [[VA:v[0-9]+]], [[A]]
; VI-DAG: v_add_u16_e32 v[[LO:[0-9]+]], [[B]], [[VA]]
; VI-DAG: v_mov_b32_e32 v[[HI:[0-9]+]], 0{{$}}
; VI-NEXT: buffer_store_dwordx2 v{{\[}}[[LO]]:[[HI]]{{\]}}
define void @s_test_add_i16_zext_to_i64(i64 addrspace(1)* %out, i16 zeroext %a, i16 zeroext %b) #1 {
  %add = add i16 %a, %b
  %ext = zext i16 %add to i64
  store i64 %ext, i64 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}s_test_add_i16_sext_to_i32:
; VI-DAG: s_load_dword [[A:s[0-9]+]], s[0:1], 0x2c
; VI-DAG: s_load_dword [[B:s[0-9]+]], s[0:1], 0x30
; VI-DAG: v_mov_b32_e32 [[VA:v[0-9]+]], [[A]]
; VI: v_add_u16_e32 [[ADD:v[0-9]+]], [[B]], [[VA]]
; VI-NEXT: v_bfe_i32 [[RESULT:v[0-9]+]], [[ADD]], 0, 16
; VI-NEXT: buffer_store_dword [[RESULT]]
define void @s_test_add_i16_sext_to_i32(i32 addrspace(1)* %out, i16 signext %a, i16 signext %b) #1 {
  %add = add i16 %a, %b
  %ext = sext i16 %add to i32
  store i32 %ext, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}s_test_add_i16_sext_to_i64:
; VI-DAG: s_load_dword [[A:s[0-9]+]], s[0:1], 0x2c
; VI-DAG: s_load_dword [[B:s[0-9]+]], s[0:1], 0x30
; VI-DAG: v_mov_b32_e32 [[VA:v[0-9]+]], [[A]]
; VI: v_add_u16_e32 v[[LO:[0-9]+]], [[B]], [[VA]]
; VI-NEXT: v_bfe_i32 v[[LO:[0-9]+]], [[ADD]], 0, 16
; VI-NEXT: v_ashrrev_i32_e32 v[[HI:[0-9]+]], 31, v[[LO]]
; VI-NEXT: buffer_store_dwordx2 v{{\[}}[[LO]]:[[HI]]{{\]}}
define void @s_test_add_i16_sext_to_i64(i64 addrspace(1)* %out, i16 signext %a, i16 signext %b) #1 {
  %add = add i16 %a, %b
  %ext = sext i16 %add to i64
  store i64 %ext, i64 addrspace(1)* %out
  ret void
}

declare i32 @llvm.amdgcn.workitem.id.x() #0

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
