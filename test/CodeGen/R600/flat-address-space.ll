; RUN: llc -O0 -march=r600 -mcpu=bonaire < %s | FileCheck %s

; Disable optimizations in case there are optimizations added that
; specialize away generic pointer accesses.


; CHECK-LABEL: @branch_use_flat_i32:
; CHECK: ; BB#3:                                 ; %global

; CHECK: V_MOV_B32_e32 v[[LO_VREG:[0-1]+]], {{s[0-9]+}}
; CHECK: V_MOV_B32_e32 v[[HI_VREG:[0-1]+]], {{s[0-9]+}}

; CHECK: ; BB#2:                                 ; %local

; CHECK: V_MOV_B32_e32 v[[LO_VREG]], {{s[0-9]+}}
; CHECK: V_MOV_B32_e32 v[[HI_VREG]], {{s[0-9]+}}

; CHECK: FLAT_STORE_DWORD {{v[0-9]+}}, v{{\[}}[[LO_VREG]]:[[HI_VREG]]{{\]}}
define void @branch_use_flat_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* %gptr, i32 addrspace(3)* %lptr, i32 %x, i32 %c) #0 {
entry:
  %cmp = icmp ne i32 %c, 0
  br i1 %cmp, label %local, label %global

local:
  %flat_local = addrspacecast i32 addrspace(3)* %lptr to i32 addrspace(4)*
  br label %end

global:
  %flat_global = addrspacecast i32 addrspace(1)* %gptr to i32 addrspace(4)*
  br label %end

end:
  %fptr = phi i32 addrspace(4)* [ %flat_local, %local ], [ %flat_global, %global ]
  store i32 %x, i32 addrspace(4)* %fptr, align 4
;  %val = load i32 addrspace(4)* %fptr, align 4
;  store i32 %val, i32 addrspace(1)* %out, align 4
  ret void
}



; These testcases might become useless when there are optimizations to
; remove generic pointers.

; CHECK-LABEL: @store_flat_i32:
; CHECK: V_MOV_B32_e32 v[[DATA:[0-9]+]], {{s[0-9]+}}
; CHECK: V_MOV_B32_e32 v[[LO_VREG:[0-9]+]], {{s[0-9]+}}
; CHECK: V_MOV_B32_e32 v[[HI_VREG:[0-9]+]], {{s[0-9]+}}
; CHECK: FLAT_STORE_DWORD v[[DATA]], v{{\[}}[[LO_VREG]]:[[HI_VREG]]{{\]}}
define void @store_flat_i32(i32 addrspace(1)* %gptr, i32 %x) #0 {
  %fptr = addrspacecast i32 addrspace(1)* %gptr to i32 addrspace(4)*
  store i32 %x, i32 addrspace(4)* %fptr, align 4
  ret void
}

; CHECK-LABEL: @store_flat_i64:
; CHECK: FLAT_STORE_DWORDX2
define void @store_flat_i64(i64 addrspace(1)* %gptr, i64 %x) #0 {
  %fptr = addrspacecast i64 addrspace(1)* %gptr to i64 addrspace(4)*
  store i64 %x, i64 addrspace(4)* %fptr, align 8
  ret void
}

; CHECK-LABEL: @store_flat_v4i32:
; CHECK: FLAT_STORE_DWORDX4
define void @store_flat_v4i32(<4 x i32> addrspace(1)* %gptr, <4 x i32> %x) #0 {
  %fptr = addrspacecast <4 x i32> addrspace(1)* %gptr to <4 x i32> addrspace(4)*
  store <4 x i32> %x, <4 x i32> addrspace(4)* %fptr, align 16
  ret void
}

; CHECK-LABEL: @store_flat_trunc_i16:
; CHECK: FLAT_STORE_SHORT
define void @store_flat_trunc_i16(i16 addrspace(1)* %gptr, i32 %x) #0 {
  %fptr = addrspacecast i16 addrspace(1)* %gptr to i16 addrspace(4)*
  %y = trunc i32 %x to i16
  store i16 %y, i16 addrspace(4)* %fptr, align 2
  ret void
}

; CHECK-LABEL: @store_flat_trunc_i8:
; CHECK: FLAT_STORE_BYTE
define void @store_flat_trunc_i8(i8 addrspace(1)* %gptr, i32 %x) #0 {
  %fptr = addrspacecast i8 addrspace(1)* %gptr to i8 addrspace(4)*
  %y = trunc i32 %x to i8
  store i8 %y, i8 addrspace(4)* %fptr, align 2
  ret void
}



; CHECK-LABEL @load_flat_i32:
; CHECK: FLAT_LOAD_DWORD
define void @load_flat_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %gptr) #0 {
  %fptr = addrspacecast i32 addrspace(1)* %gptr to i32 addrspace(4)*
  %fload = load i32 addrspace(4)* %fptr, align 4
  store i32 %fload, i32 addrspace(1)* %out, align 4
  ret void
}

; CHECK-LABEL @load_flat_i64:
; CHECK: FLAT_LOAD_DWORDX2
define void @load_flat_i64(i64 addrspace(1)* noalias %out, i64 addrspace(1)* noalias %gptr) #0 {
  %fptr = addrspacecast i64 addrspace(1)* %gptr to i64 addrspace(4)*
  %fload = load i64 addrspace(4)* %fptr, align 4
  store i64 %fload, i64 addrspace(1)* %out, align 8
  ret void
}

; CHECK-LABEL @load_flat_v4i32:
; CHECK: FLAT_LOAD_DWORDX4
define void @load_flat_v4i32(<4 x i32> addrspace(1)* noalias %out, <4 x i32> addrspace(1)* noalias %gptr) #0 {
  %fptr = addrspacecast <4 x i32> addrspace(1)* %gptr to <4 x i32> addrspace(4)*
  %fload = load <4 x i32> addrspace(4)* %fptr, align 4
  store <4 x i32> %fload, <4 x i32> addrspace(1)* %out, align 8
  ret void
}

; CHECK-LABEL @sextload_flat_i8:
; CHECK: FLAT_LOAD_SBYTE
define void @sextload_flat_i8(i32 addrspace(1)* noalias %out, i8 addrspace(1)* noalias %gptr) #0 {
  %fptr = addrspacecast i8 addrspace(1)* %gptr to i8 addrspace(4)*
  %fload = load i8 addrspace(4)* %fptr, align 4
  %ext = sext i8 %fload to i32
  store i32 %ext, i32 addrspace(1)* %out, align 4
  ret void
}

; CHECK-LABEL @zextload_flat_i8:
; CHECK: FLAT_LOAD_UBYTE
define void @zextload_flat_i8(i32 addrspace(1)* noalias %out, i8 addrspace(1)* noalias %gptr) #0 {
  %fptr = addrspacecast i8 addrspace(1)* %gptr to i8 addrspace(4)*
  %fload = load i8 addrspace(4)* %fptr, align 4
  %ext = zext i8 %fload to i32
  store i32 %ext, i32 addrspace(1)* %out, align 4
  ret void
}

; CHECK-LABEL @sextload_flat_i16:
; CHECK: FLAT_LOAD_SSHORT
define void @sextload_flat_i16(i32 addrspace(1)* noalias %out, i16 addrspace(1)* noalias %gptr) #0 {
  %fptr = addrspacecast i16 addrspace(1)* %gptr to i16 addrspace(4)*
  %fload = load i16 addrspace(4)* %fptr, align 4
  %ext = sext i16 %fload to i32
  store i32 %ext, i32 addrspace(1)* %out, align 4
  ret void
}

; CHECK-LABEL @zextload_flat_i16:
; CHECK: FLAT_LOAD_USHORT
define void @zextload_flat_i16(i32 addrspace(1)* noalias %out, i16 addrspace(1)* noalias %gptr) #0 {
  %fptr = addrspacecast i16 addrspace(1)* %gptr to i16 addrspace(4)*
  %fload = load i16 addrspace(4)* %fptr, align 4
  %ext = zext i16 %fload to i32
  store i32 %ext, i32 addrspace(1)* %out, align 4
  ret void
}

declare void @llvm.AMDGPU.barrier.local() #1


; Check for prologue initializing special SGPRs pointing to scratch.
; CHECK-LABEL: @store_flat_scratch:
; CHECK: S_MOVK_I32 FLAT_SCRATCH_SIZE, 40
; CHECK: S_MOVK_I32 FLAT_SCRATCH_OFFSET,
; CHECK: FLAT_STORE_DWORD
; CHECK: S_BARRIER
; CHECK: FLAT_LOAD_DWORD
define void @store_flat_scratch(i32 addrspace(1)* noalias %out, i32 %x) #0 {
  %alloca = alloca i32, i32 9, align 4
  %pptr = getelementptr i32* %alloca, i32 %x
  %fptr = addrspacecast i32* %pptr to i32 addrspace(4)*
  store i32 %x, i32 addrspace(4)* %fptr
  ; Dummy call
  call void @llvm.AMDGPU.barrier.local() #1
  %reload = load i32 addrspace(4)* %fptr, align 4
  store i32 %reload, i32 addrspace(1)* %out, align 4
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { nounwind noduplicate }
