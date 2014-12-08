; RUN: llc -march=amdgcn -mcpu=hawaii -verify-machineinstrs < %s | FileCheck -check-prefix=CI %s

declare i32 @llvm.r600.read.tidig.x() nounwind readnone
declare void @llvm.AMDGPU.barrier.global() nounwind noduplicate
declare float @llvm.AMDGPU.div.fmas.f32(float, float, float, i1) nounwind readnone
declare double @llvm.AMDGPU.div.fmas.f64(double, double, double, i1) nounwind readnone
declare { float, i1 } @llvm.AMDGPU.div.scale.f32(float, float, i1) nounwind readnone

; CI-LABEL: {{^}}test_div_scale_div_fmas_f32_1:
; CI: v_div_scale_f32 {{v[0-9]+}}, vcc, {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}
; CI-NEXT: s_nop 3{{$}}
; CI-NEXT: v_div_fmas_f32 {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}, {{v[0-9]+}}
; CI-NEXT: buffer_store_dword
; CI-NEXT: s_endpgm
define void @test_div_scale_div_fmas_f32_1(float addrspace(1)* %out, float addrspace(1)* %in) nounwind {
  %tid = call i32 @llvm.r600.read.tidig.x() nounwind readnone
  %gep.0 = getelementptr float addrspace(1)* %in, i32 %tid
  %gep.1 = getelementptr float addrspace(1)* %gep.0, i32 1
  %gep.2 = getelementptr float addrspace(1)* %gep.1, i32 2

  %a = load float addrspace(1)* %gep.0, align 4
  %b = load float addrspace(1)* %gep.1, align 4
  %c = load float addrspace(1)* %gep.2, align 4

  %scale = call { float, i1 } @llvm.AMDGPU.div.scale.f32(float %a, float %b, i1 false) nounwind readnone
  %scale.vcc = extractvalue { float, i1 } %scale, 1
  %fmas = call float @llvm.AMDGPU.div.fmas.f32(float %a, float %b, float %c, i1 %scale.vcc) nounwind readnone
  store float %fmas, float addrspace(1)* %out, align 4
  ret void
}

; CI-LABEL: {{^}}test_div_fmas_f32:
; CI-DAG: s_load_dword [[SA:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0xb
; CI-DAG: s_load_dword [[SC:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0xd
; CI-DAG: s_load_dword [[SB:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0xc
; CI-DAG: v_mov_b32_e32 [[VC:v[0-9]+]], [[SC]]
; CI-DAG: v_mov_b32_e32 [[VB:v[0-9]+]], [[SB]]
; CI-DAG: v_mov_b32_e32 [[VA:v[0-9]+]], [[SA]]
; CI: v_div_fmas_f32 [[RESULT:v[0-9]+]], [[VA]], [[VB]], [[VC]]
; CI: buffer_store_dword [[RESULT]],
; CI: s_endpgm
define void @test_div_fmas_f32(float addrspace(1)* %out, float %a, float %b, float %c, i1 %d) nounwind {
  %result = call float @llvm.AMDGPU.div.fmas.f32(float %a, float %b, float %c, i1 %d) nounwind readnone
  store float %result, float addrspace(1)* %out, align 4
  ret void
}
