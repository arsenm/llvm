; RUN: llc -amdgpu-function-calls -mtriple=amdgcn-amd-amdhsa -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s

; Make sure private pointer passed in is accessed relative to the base
; scratch wave offset register.

; GCN-LABEL: {{^}}func_use_stack_object:
; GCN: s_waitcnt
; GCN-NEXT: buffer_load_dword v0, v0, s[0:3], s4 offen offset:12
; GCN-NEXT: s_waitcnt vmcnt(0)
; GCN-NEXT: v_add_i32_e32 v0, vcc, 5, v0
; GCN-NEXT: s_setpc_b64
define i32 @func_use_stack_object(i32* %ptr) #1 {
  %gep = getelementptr inbounds i32, i32* %ptr, i32 3
  %ld = load volatile i32, i32* %gep, align 4
  %add = add i32 %ld, 5
  ret i32 %add
}

; Make sure the stack pointer passed is relative to the scratch wave
; offset. The offset isn't really 0 because of the reserved emergency
; scavenging index.

; GCN-LABEL: {{^}}func_with_stack_object_0_offset
; GCN: s_waitcnt

; Increment SP
; GCN: s_mov_b32 s5, s32
; GCN: s_add_u32 s32, s32, 0xb00{{$}}
; GCN: s_getpc_b64


; Compute offset relative to scratch wave offset.
; GCN: s_sub_u32 vcc_hi, s5, s4
; GCN: s_lshr_b32 vcc_hi, vcc_hi, 6
; GCN: v_add_i32_e64 v0, vcc, vcc_hi, 4
; GCN: s_swappc_b64
; GCN: flat_store_dword v{{\[[0-9]+:[0-9]+\]}}, v0
; GCN: s_waitcnt
; GCN: s_setpc_b64
define void @func_with_stack_object_0_offset() #0 {
  %alloca = alloca [10 x i32], align 4
  %gep = getelementptr inbounds [10 x i32], [10 x i32]* %alloca, i32 0, i32 0
  %bar = call i32 @func_use_stack_object(i32* %gep)
  store volatile i32 %bar, i32 addrspace(1)* undef
  ret void
}

; GCN-LABEL: {{^}}func_with_stack_object_offset:
; GCN: s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GCN: s_mov_b32 s5, s32
; GCN: s_add_u32 s32, s32, 0xb00
; GCN: s_sub_u32 s8, s5, s4
; GCN: s_lshr_b32 s8, s8, 6
; GCN: v_add_i32_e64 v0, {{s\[[0-9]+:[0-9]+\]}}, s8, 4
; GCN: v_add_i32_e32 v0, vcc, 12, v0
; GCN: s_swappc_b64

; GCN: s_waitcnt
; GCN-NEXT: s_setpc_b64
define void @func_with_stack_object_offset() #0 {
  %alloca = alloca [10 x i32], align 4
  %gep = getelementptr inbounds [10 x i32], [10 x i32]* %alloca, i32 0, i32 3
  %bar = call i32 @func_use_stack_object(i32* %gep)
  store volatile i32 %bar, i32 addrspace(1)* undef
  ret void
}

; The allocated object is already relative to the scratch wave offset
; since it's in the kernel, so no offset conversion should be done and
; no epilog is necessary.

; GCN-LABEL: {{^}}kernel_with_stack_object:
; GCN: v_mov_b32_e32 v0, 4
; GCN: v_add_i32_e32 v0, vcc, 12, v0
; GCN: s_getpc_b64
; GCN: s_mov_b32 s4, s9
; GCN: s_swappc_b64
; GCN-NEXT: flat_store_dword v{{\[[0-9]+:[0-9]+\]}}, v0
; GCN-NEXT: s_endpgm
define amdgpu_kernel void @kernel_with_stack_object() #0 {
  %alloca = alloca [10 x i32], align 4
  %gep = getelementptr inbounds [10 x i32], [10 x i32]* %alloca, i32 0, i32 3
  %bar = call i32 @func_use_stack_object(i32* %gep)
  store volatile i32 %bar, i32 addrspace(1)* undef
  ret void
}

; GCN-LABEL: {{^}}func_store_private_pointer_to_mem:
; GCN: s_waitcnt
; GCN: s_mov_b32 s5, s32
; GCN: s_sub_u32 s6, s5, s4
; GCN: s_lshr_b32 s6, s6, 6
; GCN: v_add_i32_e64 v0, {{s\[[0-9]+:[0-9]+\]}}, s6, 4
; GCN: v_add_i32_e32 v0, vcc, 12, v0
; GCN-NEXT: buffer_store_dword v0, off, s[0:3], s5 offset:44{{$}}
; GCN-NEXT: s_waitcnt
; GCN-NEXT: s_setpc_b64
define void @func_store_private_pointer_to_mem() #0 {
  %alloca = alloca [10 x i32], align 4
  %ptr.slot = alloca i32*, align 4
  %gep = getelementptr inbounds [10 x i32], [10 x i32]* %alloca, i32 0, i32 3
  store volatile i32* %gep, i32** %ptr.slot
  ret void
}


attributes #0 = { nounwind }
attributes #1 = { nounwind noinline }
