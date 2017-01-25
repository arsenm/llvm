; RUN: llc -march=amdgcn -mcpu=verde -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck %s

; This used to raise an assertion due to how the choice between uniform and
; non-uniform branches was determined.
;
; CHECK-LABEL: {{^}}test:
; CHECK: s_cbranch_vccnz
define amdgpu_ps float @test(<4 x i32> inreg %rsrc) #0 {
main_body:
  %v = call float @llvm.amdgcn.buffer.load.f32(<4 x i32> %rsrc, i32 0, i32 0, i1 true, i1 false)
  %cc = fcmp une float %v, 1.000000e+00
  br i1 %cc, label %if, label %else

if:
  %u = fadd float %v, %v
  call void asm sideeffect "", ""() #0 ; Prevent ifconversion
  br label %else

else:
  %r = phi float [ %v, %main_body ], [ %u, %if ]
  ret float %r
}

; FIXME: This leaves behind a now unnecessary and with exec

; This version can be if converted
; CHECK-LABEL: {{^}}test_vcc_ifcvt:
; CHECK: buffer_load_dword [[VAL:v[0-9]+]]
; CHECK: v_cmp_eq_f32_e32 vcc, 1.0, [[VAL]]
; CHECK: v_add_f32_e32 [[ADD:v[0-9]+]], [[VAL]], [[VAL]]
; CHECK: v_cndmask_b32_e32 [[RESULT:v[0-9]+]], [[ADD]], [[VAL]], vcc
; CHECK: buffer_store_dword [[RESULT]]
define void @test_vcc_ifcvt(float addrspace(1)* %out, float addrspace(1)* %in) #0 {
main_body:
  %v = load float, float addrspace(1)* %in
  %cc = fcmp une float %v, 1.000000e+00
  br i1 %cc, label %if, label %else

if:
  %u = fadd float %v, %v
  br label %else

else:
  %r = phi float [ %v, %main_body ], [ %u, %if ]
  store float %r, float addrspace(1)* %out
  ret void
}

; Function Attrs: nounwind readonly
declare float @llvm.amdgcn.buffer.load.f32(<4 x i32>, i32, i32, i1, i1) #1

attributes #0 = { nounwind }
attributes #1 = { nounwind readonly }
