; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=tahiti < %s | FileCheck -check-prefix=SI-FASTFP64 -check-prefix=ALL %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=verde < %s | FileCheck -check-prefix=SI-SLOWFP64 -check-prefix=ALL %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=hawaii < %s | FileCheck -check-prefix=CI-FASTFP64 -check-prefix=ALL %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=bonaire < %s | FileCheck -check-prefix=CI-SLOWFP64 -check-prefix=ALL %s

; ALL: 'trunc_f32'
; ALL: estimated cost of 1 for {{.*}} call float @llvm.trunc.f32
define void @trunc_f32(float addrspace(1)* %out, float addrspace(1)* %vaddr) #0 {
  %vec = load float, float addrspace(1)* %vaddr
  %trunc = call float @llvm.trunc.f32(float %vec) #1
  store float %trunc, float addrspace(1)* %out
  ret void
}

; ALL: 'trunc_v2f32'
; ALL: estimated cost of 2 for {{.*}} call <2 x float> @llvm.trunc.v2f32
define void @trunc_v2f32(<2 x float> addrspace(1)* %out, <2 x float> addrspace(1)* %vaddr) #0 {
  %vec = load <2 x float>, <2 x float> addrspace(1)* %vaddr
  %trunc = call <2 x float> @llvm.trunc.v2f32(<2 x float> %vec) #1
  store <2 x float> %trunc, <2 x float> addrspace(1)* %out
  ret void
}

; ALL: 'trunc_v3f32'
; ALL: estimated cost of 3 for {{.*}} call <3 x float> @llvm.trunc.v3f32
define void @trunc_v3f32(<3 x float> addrspace(1)* %out, <3 x float> addrspace(1)* %vaddr) #0 {
  %vec = load <3 x float>, <3 x float> addrspace(1)* %vaddr
  %trunc = call <3 x float> @llvm.trunc.v3f32(<3 x float> %vec) #1
  store <3 x float> %trunc, <3 x float> addrspace(1)* %out
  ret void
}

; ALL: 'trunc_f64'
; SI-FASTFP64: estimated cost of 15 for {{.*}} call double @llvm.trunc.f64
; SI-SLOWFP64: estimated cost of 16 for {{.*}} call double @llvm.trunc.f64

; CI-FASTFP64: estimated cost of 2 for {{.*}} call double @llvm.trunc.f64
; CI-SLOWFP64: estimated cost of 3 for {{.*}} call double @llvm.trunc.f64
define void @trunc_f64(double addrspace(1)* %out, double addrspace(1)* %vaddr) #0 {
  %vec = load double, double addrspace(1)* %vaddr
  %trunc = call double @llvm.trunc.f64(double %vec) #1
  store double %trunc, double addrspace(1)* %out
  ret void
}

; ALL: 'trunc_v2f64'
; SI-FASTFP64: estimated cost of 30 for {{.*}} call <2 x double> @llvm.trunc.v2f64
; SI-SLOWFP64: estimated cost of 32 for {{.*}} call <2 x double> @llvm.trunc.v2f64

; CI-FASTFP64: estimated cost of 4 for {{.*}} call <2 x double> @llvm.trunc.v2f64
; CI-SLOWFP64: estimated cost of 6 for {{.*}} call <2 x double> @llvm.trunc.v2f64
define void @trunc_v2f64(<2 x double> addrspace(1)* %out, <2 x double> addrspace(1)* %vaddr) #0 {
  %vec = load <2 x double>, <2 x double> addrspace(1)* %vaddr
  %trunc = call <2 x double> @llvm.trunc.v2f64(<2 x double> %vec) #1
  store <2 x double> %trunc, <2 x double> addrspace(1)* %out
  ret void
}

; ALL: 'trunc_v3f64'
; SI-FASTFP64: estimated cost of 45 for {{.*}} call <3 x double> @llvm.trunc.v3f64
; SI-SLOWFP64: estimated cost of 48 for {{.*}} call <3 x double> @llvm.trunc.v3f64

; CI-FASTFP64: estimated cost of 6 for {{.*}} call <3 x double> @llvm.trunc.v3f64
; CI-SLOWFP64: estimated cost of 9 for {{.*}} call <3 x double> @llvm.trunc.v3f64
define void @trunc_v3f64(<3 x double> addrspace(1)* %out, <3 x double> addrspace(1)* %vaddr) #0 {
  %vec = load <3 x double>, <3 x double> addrspace(1)* %vaddr
  %trunc = call <3 x double> @llvm.trunc.v3f64(<3 x double> %vec) #1
  store <3 x double> %trunc, <3 x double> addrspace(1)* %out
  ret void
}

; ALL: 'trunc_f16'
; ALL: estimated cost of 1 for {{.*}} call half @llvm.trunc.f16
define void @trunc_f16(half addrspace(1)* %out, half addrspace(1)* %vaddr) #0 {
  %vec = load half, half addrspace(1)* %vaddr
  %trunc = call half @llvm.trunc.f16(half %vec) #1
  store half %trunc, half addrspace(1)* %out
  ret void
}

; ALL: 'trunc_v2f16'
; ALL: estimated cost of 2 for {{.*}} call <2 x half> @llvm.trunc.v2f16
define void @trunc_v2f16(<2 x half> addrspace(1)* %out, <2 x half> addrspace(1)* %vaddr) #0 {
  %vec = load <2 x half>, <2 x half> addrspace(1)* %vaddr
  %trunc = call <2 x half> @llvm.trunc.v2f16(<2 x half> %vec) #1
  store <2 x half> %trunc, <2 x half> addrspace(1)* %out
  ret void
}

; FIXME: Should be 3
; ALL: 'trunc_v3f16'
; ALL: estimated cost of 8 for {{.*}} call <3 x half> @llvm.trunc.v3f16
define void @trunc_v3f16(<3 x half> addrspace(1)* %out, <3 x half> addrspace(1)* %vaddr) #0 {
  %vec = load <3 x half>, <3 x half> addrspace(1)* %vaddr
  %trunc = call <3 x half> @llvm.trunc.v3f16(<3 x half> %vec) #1
  store <3 x half> %trunc, <3 x half> addrspace(1)* %out
  ret void
}

declare float @llvm.trunc.f32(float) #1
declare <2 x float> @llvm.trunc.v2f32(<2 x float>) #1
declare <3 x float> @llvm.trunc.v3f32(<3 x float>) #1

declare double @llvm.trunc.f64(double) #1
declare <2 x double> @llvm.trunc.v2f64(<2 x double>) #1
declare <3 x double> @llvm.trunc.v3f64(<3 x double>) #1

declare half @llvm.trunc.f16(half) #1
declare <2 x half> @llvm.trunc.v2f16(<2 x half>) #1
declare <3 x half> @llvm.trunc.v3f16(<3 x half>) #1

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
