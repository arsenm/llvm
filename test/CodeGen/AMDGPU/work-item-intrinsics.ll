; RUN: llc -march=amdgcn -mcpu=SI -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=GCN -check-prefix=SI-NOHSA -check-prefix=GCN-NOHSA -check-prefix=FUNC %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=VI  -check-prefix=VI-NOHSA -check-prefix=GCN -check-prefix=GCN-NOHSA -check-prefix=FUNC %s
; RUN: llc -mtriple=amdgcn--amdhsa -mcpu=kaveri -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=GCN -check-prefix=HSA -check-prefix=CI-HSA -check-prefix=FUNC %s
; RUN: llc -mtriple=amdgcn--amdhsa -mcpu=carrizo -verify-machineinstrs < %s | FileCheck -check-prefix=VI -check-prefix=GCN -check-prefix=HSA -check-prefix=VI-HSA -check-prefix=FUNC %s
; RUN: llc -march=r600 -mcpu=redwood < %s | FileCheck -check-prefix=EG -check-prefix=FUNC %s


; FUNC-LABEL: {{^}}ngroups_x:
; EG: MEM_RAT_CACHELESS STORE_RAW [[VAL:T[0-9]+\.X]]
; EG: MOV [[VAL]], KC0[0].X

; GCN-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0
; GCN-NOHSA: v_mov_b32_e32 [[VVAL:v[0-9]+]], [[VAL]]
; GCN-NOHSA: buffer_store_dword [[VVAL]]
define void @ngroups_x (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.ngroups.x() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}ngroups_y:
; EG: MEM_RAT_CACHELESS STORE_RAW [[VAL:T[0-9]+\.X]]
; EG: MOV [[VAL]], KC0[0].Y

; SI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x1
; VI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x4
; GCN-NOHSA: v_mov_b32_e32 [[VVAL:v[0-9]+]], [[VAL]]
; GCN-NOHSA: buffer_store_dword [[VVAL]]
define void @ngroups_y (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.ngroups.y() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}ngroups_z:
; EG: MEM_RAT_CACHELESS STORE_RAW [[VAL:T[0-9]+\.X]]
; EG: MOV [[VAL]], KC0[0].Z

; SI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x2
; VI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x8
; GCN-NOHSA: v_mov_b32_e32 [[VVAL:v[0-9]+]], [[VAL]]
; GCN-NOHSA: buffer_store_dword [[VVAL]]
define void @ngroups_z (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.ngroups.z() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}global_size_x:
; EG: MEM_RAT_CACHELESS STORE_RAW [[VAL:T[0-9]+\.X]]
; EG: MOV [[VAL]], KC0[0].W

; SI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x3
; VI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0xc
; GCN-NOHSA: v_mov_b32_e32 [[VVAL:v[0-9]+]], [[VAL]]
; GCN-NOHSA: buffer_store_dword [[VVAL]]
define void @global_size_x (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.global.size.x() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}global_size_y:
; EG: MEM_RAT_CACHELESS STORE_RAW [[VAL:T[0-9]+\.X]]
; EG: MOV [[VAL]], KC0[1].X

; SI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x4
; VI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x10
; GCN-NOHSA: v_mov_b32_e32 [[VVAL:v[0-9]+]], [[VAL]]
; GCN-NOHSA: buffer_store_dword [[VVAL]]
define void @global_size_y (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.global.size.y() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}global_size_z:
; EG: MEM_RAT_CACHELESS STORE_RAW [[VAL:T[0-9]+\.X]]
; EG: MOV [[VAL]], KC0[1].Y

; SI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x5
; VI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x14
; GCN-NOHSA: v_mov_b32_e32 [[VVAL:v[0-9]+]], [[VAL]]
; GCN-NOHSA: buffer_store_dword [[VVAL]]
define void @global_size_z (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.global.size.z() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}local_size_x:
; EG: MEM_RAT_CACHELESS STORE_RAW [[VAL:T[0-9]+\.X]]
; EG: MOV [[VAL]], KC0[1].Z

; SI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x6
; VI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x18
; CI-HSA: s_load_dword [[XY:s[0-9]+]], s[0:1], 0x1
; VI-HSA: s_load_dword [[XY:s[0-9]+]], s[0:1], 0x4
; HSA: s_and_b32 [[VAL:s[0-9]+]], [[XY]], 0xffff
; GCN: v_mov_b32_e32 [[VVAL:v[0-9]+]], [[VAL]]
; GCN: buffer_store_dword [[VVAL]]
define void @local_size_x (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.local.size.x() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}local_size_y:
; EG: MEM_RAT_CACHELESS STORE_RAW [[VAL:T[0-9]+\.X]]
; EG: MOV [[VAL]], KC0[1].W

; SI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x7
; VI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x1c
; CI-HSA: s_load_dword [[XY_VAL:s[0-9]+]], s[0:1], 0x1
; VI-HSA: s_load_dword [[XY_VAL:s[0-9]+]], s[0:1], 0x4
; HSA: s_lshr_b32 [[VAL:s[0-9]+]], [[XY_VAL]], 16
; GCN: v_mov_b32_e32 [[VVAL:v[0-9]+]], [[VAL]]
; GCN: buffer_store_dword [[VVAL]]
define void @local_size_y (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.local.size.y() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}local_size_z:
; EG: MEM_RAT_CACHELESS STORE_RAW [[VAL:T[0-9]+\.X]]
; EG: MOV [[VAL]], KC0[2].X

; SI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x8
; VI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x20
; CI-HSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x2
; VI-HSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x8
; GCN: v_mov_b32_e32 [[VVAL:v[0-9]+]], [[VAL]]
; GCN: buffer_store_dword [[VVAL]]
define void @local_size_z (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.local.size.z() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}local_size_xy:
; SI-NOHSA-DAG: s_load_dword [[X:s[0-9]+]], s[0:1], 0x6
; SI-NOHSA-DAG: s_load_dword [[Y:s[0-9]+]], s[0:1], 0x7
; VI-NOHSA-DAG: s_load_dword [[X:s[0-9]+]], s[0:1], 0x18
; VI-NOHSA-DAG: s_load_dword [[Y:s[0-9]+]], s[0:1], 0x1c
; CI-HSA: s_load_dword [[XY:s[0-9]+]], s[0:1], 0x1
; VI-HSA; s_load_dword [[XY:s[0-9]+]], s[0:1], 0x4
; HSA-DAG: s_and_b32 [[X:s[0-9]+]], [[XY]], 0xffff
; HSA-DAG: s_lshr_b32 [[Y:s[0-9]+]], [[XY]], 16
; GCN-DAG: v_mov_b32_e32 [[VY:v[0-9]+]], [[Y]]
; GCN: v_mul_u32_u24_e32 [[VAL:v[0-9]+]], [[X]], [[VY]]
; GCN: buffer_store_dword [[VAL]]
define void @local_size_xy (i32 addrspace(1)* %out) {
entry:
  %x = call i32 @llvm.r600.read.local.size.x() #0
  %y = call i32 @llvm.r600.read.local.size.y() #0
  %val = mul i32 %x, %y
  store i32 %val, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}local_size_xz:
; SI-NOHSA-DAG: s_load_dword [[X:s[0-9]+]], s[0:1], 0x6
; SI-NOHSA-DAG: s_load_dword [[Z:s[0-9]+]], s[0:1], 0x8
; VI-NOHSA-DAG: s_load_dword [[X:s[0-9]+]], s[0:1], 0x18
; VI-NOHSA-DAG: s_load_dword [[Z:s[0-9]+]], s[0:1], 0x20
; CI-HSA: s_load_dword [[XY:s[0-9]+]], s[0:1], 0x1
; CI-HSA: s_load_dword [[Z:s[0-9]+]], s[0:1], 0x2
; VI-HSA: s_load_dword [[XY:s[0-9]+]], s[0:1], 0x4
; VI-HSA: s_load_dword [[Z:s[0-9]+]], s[0:1], 0x8
; HSA-DAG: s_and_b32 [[X:s[0-9]+]], [[XY]], 0xffff
; GCN-DAG: v_mov_b32_e32 [[VZ:v[0-9]+]], [[Z]]
; GCN: v_mul_u32_u24_e32 [[VAL:v[0-9]+]], [[X]], [[VZ]]
; GCN: buffer_store_dword [[VAL]]
define void @local_size_xz (i32 addrspace(1)* %out) {
entry:
  %x = call i32 @llvm.r600.read.local.size.x() #0
  %z = call i32 @llvm.r600.read.local.size.z() #0
  %val = mul i32 %x, %z
  store i32 %val, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}local_size_yz:
; SI-NOHSA-DAG: s_load_dword [[Y:s[0-9]+]], s[0:1], 0x7
; SI-NOHSA-DAG: s_load_dword [[Z:s[0-9]+]], s[0:1], 0x8
; VI-NOHSA-DAG: s_load_dword [[Y:s[0-9]+]], s[0:1], 0x1c
; VI-NOHSA-DAG: s_load_dword [[Z:s[0-9]+]], s[0:1], 0x20
; CI-HSA: s_load_dword [[XY:s[0-9]+]], s[0:1], 0x1
; CI-HSA: s_load_dword [[Z:s[0-9]+]], s[0:1], 0x2
; VI-HSA: s_load_dword [[XY:s[0-9]+]], s[0:1], 0x4
; VI-HSA: s_load_dword [[Z:s[0-9]+]], s[0:1], 0x8
; HSA-DAG: s_lshr_b32 [[Y:s[0-9]+]], [[XY]], 16
; GCN-DAG: v_mov_b32_e32 [[VZ:v[0-9]+]], [[Z]]
; GCN: v_mul_u32_u24_e32 [[VAL:v[0-9]+]], [[Y]], [[VZ]]
; GCN: buffer_store_dword [[VAL]]
define void @local_size_yz (i32 addrspace(1)* %out) {
entry:
  %y = call i32 @llvm.r600.read.local.size.y() #0
  %z = call i32 @llvm.r600.read.local.size.z() #0
  %val = mul i32 %y, %z
  store i32 %val, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}local_size_xyz:
; SI-NOHSA-DAG: s_load_dword [[X:s[0-9]+]], s[0:1], 0x6
; SI-NOHSA-DAG: s_load_dword [[Y:s[0-9]+]], s[0:1], 0x7
; SI-NOHSA-DAG: s_load_dword [[Z:s[0-9]+]], s[0:1], 0x8
; VI-NOHSA-DAG: s_load_dword [[X:s[0-9]+]], s[0:1], 0x18
; VI-NOHSA-DAG: s_load_dword [[Y:s[0-9]+]], s[0:1], 0x1c
; VI-NOHSA-DAG: s_load_dword [[Z:s[0-9]+]], s[0:1], 0x20
; CI-HSA: s_load_dword [[XY:s[0-9]+]], s[0:1], 0x1
; CI-HSA: s_load_dword [[Z:s[0-9]+]], s[0:1], 0x2
; VI-HSA: s_load_dword [[XY:s[0-9]+]], s[0:1], 0x4
; VI-HSA: s_load_dword [[Z:s[0-9]+]], s[0:1], 0x8
; HSA-DAG: s_and_b32 [[X:s[0-9]+]], [[XY]], 0xffff
; HSA-DAG: s_lshr_b32 [[Y:s[0-9]+]], [[XY]], 16
; GCN-DAG: v_mov_b32_e32 [[VY:v[0-9]+]], [[Y]]
; GCN-DAG: v_mov_b32_e32 [[VZ:v[0-9]+]], [[Z]]
; GCN: v_mad_u32_u24 [[VAL:v[0-9]+]], [[X]], [[VY]], [[VZ]]
; GCN: buffer_store_dword [[VAL]]
define void @local_size_xyz (i32 addrspace(1)* %out) {
entry:
  %x = call i32 @llvm.r600.read.local.size.x() #0
  %y = call i32 @llvm.r600.read.local.size.y() #0
  %z = call i32 @llvm.r600.read.local.size.z() #0
  %xy = mul i32 %x, %y
  %xyz = add i32 %xy, %z
  store i32 %xyz, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}get_work_dim:
; EG: MEM_RAT_CACHELESS STORE_RAW [[VAL:T[0-9]+\.X]]
; EG: MOV [[VAL]], KC0[2].Z

; SI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0xb
; VI-NOHSA: s_load_dword [[VAL:s[0-9]+]], s[0:1], 0x2c
; GCN-NOHSA: v_mov_b32_e32 [[VVAL:v[0-9]+]], [[VAL]]
; GCN-NOHSA: buffer_store_dword [[VVAL]]
define void @get_work_dim (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.AMDGPU.read.workdim() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; The tgid values are stored in sgprs offset by the number of user sgprs.
; Currently we always use exactly 2 user sgprs for the pointer to the
; kernel arguments, but this may change in the future.

; FUNC-LABEL: {{^}}tgid_x:
; GCN-NOHSA: v_mov_b32_e32 [[VVAL:v[0-9]+]], s4
; GCN-NOHSA: buffer_store_dword [[VVAL]]
define void @tgid_x (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.tgid.x() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}tgid_y:
; GCN: v_mov_b32_e32 [[VVAL:v[0-9]+]], s5
; GCN: buffer_store_dword [[VVAL]]
define void @tgid_y (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.tgid.y() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}tgid_z:
; GCN: v_mov_b32_e32 [[VVAL:v[0-9]+]], s6
; GCN: buffer_store_dword [[VVAL]]
define void @tgid_z (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.tgid.z() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}tidig_x:
; GCN: buffer_store_dword v0
define void @tidig_x (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.tidig.x() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}tidig_y:
; GCN: buffer_store_dword v1
define void @tidig_y (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.tidig.y() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}tidig_z:
; GCN: buffer_store_dword v2
define void @tidig_z (i32 addrspace(1)* %out) {
entry:
  %0 = call i32 @llvm.r600.read.tidig.z() #0
  store i32 %0, i32 addrspace(1)* %out
  ret void
}

declare i32 @llvm.r600.read.ngroups.x() #0
declare i32 @llvm.r600.read.ngroups.y() #0
declare i32 @llvm.r600.read.ngroups.z() #0

declare i32 @llvm.r600.read.global.size.x() #0
declare i32 @llvm.r600.read.global.size.y() #0
declare i32 @llvm.r600.read.global.size.z() #0

declare i32 @llvm.r600.read.local.size.x() #0
declare i32 @llvm.r600.read.local.size.y() #0
declare i32 @llvm.r600.read.local.size.z() #0

declare i32 @llvm.r600.read.tgid.x() #0
declare i32 @llvm.r600.read.tgid.y() #0
declare i32 @llvm.r600.read.tgid.z() #0

declare i32 @llvm.r600.read.tidig.x() #0
declare i32 @llvm.r600.read.tidig.y() #0
declare i32 @llvm.r600.read.tidig.z() #0

declare i32 @llvm.AMDGPU.read.workdim() #0

attributes #0 = { readnone }
