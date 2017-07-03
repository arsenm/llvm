; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=fiji -amdgpu-function-calls -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=GCN,VI,HSA %s
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx900 -amdgpu-function-calls -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=GCN,GFX9,HSA %s

define void @large_frame([1056 x i32] %arg) #0 {
  %last = extractvalue [1056 x i32] %arg, 1054
  store volatile i32 %last, i32 addrspace(1)* undef
  ret void
}

define void @smaller_frame([1000 x i32] %arg) #0 {
  %last = extractvalue [1000 x i32] %arg, 999
  store volatile i32 %last, i32 addrspace(1)* undef
  ret void
}

define void @small_frame([256 x i32] %arg) #0 {
  %last = extractvalue [256 x i32] %arg, 255
  store volatile i32 %last, i32 addrspace(1)* undef
  ret void
}

define void @func_call_large_frame([1056 x i32] %arg) #0 {
  call void @large_frame([1056 x i32] zeroinitializer)
  ret void
}

define void @func_call_smaller_frame([1000 x i32] %arg) #0 {
  call void @smaller_frame([1000 x i32] zeroinitializer)
  ret void
}

define void @func_call_multi_size_frame([1000 x i32] %arg) #0 {
  call void @smaller_frame([1000 x i32] zeroinitializer)
  call void @large_frame([1056 x i32] zeroinitializer)
  ret void
}

define void @func_call_multi_size_small_frame([1000 x i32] %arg) #0 {
  %foo = insertvalue [256 x i32] undef, i32, 255
  call void @small_frame([256 x i32] %foo)
  %bar = insertvalue [1000 x i32] undef, i32, 255
  call void @smaller_frame([1000 x i32] %bar)
  ret void
}

; define amdgpu_kernel void @kern_call_large_frame([1056 x i32] %arg) #0 {
;   call void @large_frame([1056 x i32] zeroinitializer)
;   ret void
; }

; define amdgpu_kernel void @kern_call_smaller_frame([1000 x i32] %arg) #0 {
;   call void @smaller_frame([1000 x i32] zeroinitializer)
;   ret void
; }

attributes #0 = { nounwind noinline }
