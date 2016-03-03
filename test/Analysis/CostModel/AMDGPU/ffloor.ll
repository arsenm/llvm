; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=tahiti < %s | FileCheck -check-prefix=SI-FASTFP64 -check-prefix=ALL %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=verde < %s | FileCheck -check-prefix=SI-SLOWFP64 -check-prefix=ALL %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=hawaii < %s | FileCheck -check-prefix=CI-FASTFP64 -check-prefix=ALL %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=bonaire < %s | FileCheck -check-prefix=CI-SLOWFP64 -check-prefix=ALL %s

; ALL: 'floor_f32'
; ALL: estimated cost of 1 for {{.*}} call float @llvm.floor.f32
define void @floor_f32(float addrspace(1)* %out, float addrspace(1)* %vaddr) #0 {
  %vec = load float, float addrspace(1)* %vaddr
  %floor = call float @llvm.floor.f32(float %vec) #1
  store float %floor, float addrspace(1)* %out
  ret void
}

; ALL: 'floor_v2f32'
; ALL: estimated cost of 2 for {{.*}} call <2 x float> @llvm.floor.v2f32
define void @floor_v2f32(<2 x float> addrspace(1)* %out, <2 x float> addrspace(1)* %vaddr) #0 {
  %vec = load <2 x float>, <2 x float> addrspace(1)* %vaddr
  %floor = call <2 x float> @llvm.floor.v2f32(<2 x float> %vec) #1
  store <2 x float> %floor, <2 x float> addrspace(1)* %out
  ret void
}

; ALL: 'floor_v3f32'
; ALL: estimated cost of 3 for {{.*}} call <3 x float> @llvm.floor.v3f32
define void @floor_v3f32(<3 x float> addrspace(1)* %out, <3 x float> addrspace(1)* %vaddr) #0 {
  %vec = load <3 x float>, <3 x float> addrspace(1)* %vaddr
  %floor = call <3 x float> @llvm.floor.v3f32(<3 x float> %vec) #1
  store <3 x float> %floor, <3 x float> addrspace(1)* %out
  ret void
}

; ALL: 'floor_f64'
; SI-FASTFP64: estimated cost of 22 for {{.*}} call double @llvm.floor.f64
; SI-SLOWFP64: estimated cost of 24 for {{.*}} call double @llvm.floor.f64

; CI-FASTFP64: estimated cost of 2 for {{.*}} call double @llvm.floor.f64
; CI-SLOWFP64: estimated cost of 3 for {{.*}} call double @llvm.floor.f64
define void @floor_f64(double addrspace(1)* %out, double addrspace(1)* %vaddr) #0 {
  %vec = load double, double addrspace(1)* %vaddr
  %floor = call double @llvm.floor.f64(double %vec) #1
  store double %floor, double addrspace(1)* %out
  ret void
}

; ALL: 'floor_v2f64'
; SI-FASTFP64: estimated cost of 44 for {{.*}} call <2 x double> @llvm.floor.v2f64
; SI-SLOWFP64: estimated cost of 48 for {{.*}} call <2 x double> @llvm.floor.v2f64

; CI-FASTFP64: estimated cost of 4 for {{.*}} call <2 x double> @llvm.floor.v2f64
; CI-SLOWFP64: estimated cost of 6 for {{.*}} call <2 x double> @llvm.floor.v2f64
define void @floor_v2f64(<2 x double> addrspace(1)* %out, <2 x double> addrspace(1)* %vaddr) #0 {
  %vec = load <2 x double>, <2 x double> addrspace(1)* %vaddr
  %floor = call <2 x double> @llvm.floor.v2f64(<2 x double> %vec) #1
  store <2 x double> %floor, <2 x double> addrspace(1)* %out
  ret void
}

; ALL: 'floor_v3f64'
; SI-FASTFP64: estimated cost of 66 for {{.*}} call <3 x double> @llvm.floor.v3f64
; SI-SLOWFP64: estimated cost of 72 for {{.*}} call <3 x double> @llvm.floor.v3f64

; CI-FASTFP64: estimated cost of 6 for {{.*}} call <3 x double> @llvm.floor.v3f64
; CI-SLOWFP64: estimated cost of 9 for {{.*}} call <3 x double> @llvm.floor.v3f64
define void @floor_v3f64(<3 x double> addrspace(1)* %out, <3 x double> addrspace(1)* %vaddr) #0 {
  %vec = load <3 x double>, <3 x double> addrspace(1)* %vaddr
  %floor = call <3 x double> @llvm.floor.v3f64(<3 x double> %vec) #1
  store <3 x double> %floor, <3 x double> addrspace(1)* %out
  ret void
}

; ALL: 'floor_f16'
; ALL: estimated cost of 1 for {{.*}} call half @llvm.floor.f16
define void @floor_f16(half addrspace(1)* %out, half addrspace(1)* %vaddr) #0 {
  %vec = load half, half addrspace(1)* %vaddr
  %floor = call half @llvm.floor.f16(half %vec) #1
  store half %floor, half addrspace(1)* %out
  ret void
}

; ALL: 'floor_v2f16'
; ALL: estimated cost of 2 for {{.*}} call <2 x half> @llvm.floor.v2f16
define void @floor_v2f16(<2 x half> addrspace(1)* %out, <2 x half> addrspace(1)* %vaddr) #0 {
  %vec = load <2 x half>, <2 x half> addrspace(1)* %vaddr
  %floor = call <2 x half> @llvm.floor.v2f16(<2 x half> %vec) #1
  store <2 x half> %floor, <2 x half> addrspace(1)* %out
  ret void
}

; FIXME: Should be 3
; ALL: 'floor_v3f16'
; ALL: estimated cost of 8 for {{.*}} call <3 x half> @llvm.floor.v3f16
define void @floor_v3f16(<3 x half> addrspace(1)* %out, <3 x half> addrspace(1)* %vaddr) #0 {
  %vec = load <3 x half>, <3 x half> addrspace(1)* %vaddr
  %floor = call <3 x half> @llvm.floor.v3f16(<3 x half> %vec) #1
  store <3 x half> %floor, <3 x half> addrspace(1)* %out
  ret void
}

declare float @llvm.floor.f32(float) #1
declare <2 x float> @llvm.floor.v2f32(<2 x float>) #1
declare <3 x float> @llvm.floor.v3f32(<3 x float>) #1

declare double @llvm.floor.f64(double) #1
declare <2 x double> @llvm.floor.v2f64(<2 x double>) #1
declare <3 x double> @llvm.floor.v3f64(<3 x double>) #1

declare half @llvm.floor.f16(half) #1
declare <2 x half> @llvm.floor.v2f16(<2 x half>) #1
declare <3 x half> @llvm.floor.v3f16(<3 x half>) #1

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
