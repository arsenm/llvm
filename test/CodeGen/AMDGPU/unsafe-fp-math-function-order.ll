; RUN: llc -march=amdgcn < %s | FileCheck %s

; fadd x, 0 is folded away only if unsafe-fp-math is enabled.

; The unsafe-fp-math attribute is applied to the second function.  It
; is not applied to the third, but is still folded away.


; CHECK-LABEL: {{^}}first_safe:
; CHECK: v_add_f32
; CHECK: buffer_store_dword
define void @first_safe(float addrspace(1)* %out, float %a) #0 {
  %add = fadd float %a, 0.0
  store float %add, float addrspace(1)* %out
  ret void
}

; CHECK-LABEL: {{^}}second_unsafe:
; CHECK-NOT: v_add_f32
; CHECK: buffer_store_dword
define void @second_unsafe(float addrspace(1)* %out, float %a) #1 {
  %add = fadd float %a, 0.0
  store float %add, float addrspace(1)* %out
  ret void
}

; CHECK-LABEL: {{^}}third_safe:
; CHECK: v_add_f32
; CHECK: buffer_store_dword
define void @third_safe(float addrspace(1)* %out, float %a) #0 {
  %add = fadd float %a, 0.0
  store float %add, float addrspace(1)* %out
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { nounwind "unsafe-fp-math"="true" }
