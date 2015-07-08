; RUN: llc -march=amdgcn -mcpu=SI -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=GCN -check-prefix=FUNC %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=GCN -check-prefix=FUNC %s
; RUN: llc -march=r600 -mcpu=redwood < %s | FileCheck -check-prefix=R600 -check-prefix=FUNC %s

; FUNC-LABEL: {{^}}floor_f32:
; GCN: v_floor_f32_e32
; R600: FLOOR
define void @floor_f32(float addrspace(1)* %out, float %in) {
  %tmp = call float @llvm.floor.f32(float %in) #0
  store float %tmp, float addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}floor_v2f32:
; GCN: v_floor_f32_e32
; GCN: v_floor_f32_e32

; R600: FLOOR
; R600: FLOOR
define void @floor_v2f32(<2 x float> addrspace(1)* %out, <2 x float> %in) {
  %tmp = call <2 x float> @llvm.floor.v2f32(<2 x float> %in) #0
  store <2 x float> %tmp, <2 x float> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}floor_v3f32:
; GCN: v_floor_f32_e32
; GCN: v_floor_f32_e32
; GCN: v_floor_f32_e32
; XGCN-NOT: v_floor_f32_e32

; R600: FLOOR
; R600: FLOOR
; R600: FLOOR

; GCN: s_endpgm
define void @floor_v3f32(<3 x float> addrspace(1)* %out, <3 x float> %in) {
  %tmp = call <3 x float> @llvm.floor.v3f32(<3 x float> %in) #0
  store <3 x float> %tmp, <3 x float> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}floor_v4f32:
; GCN: v_floor_f32_e32
; GCN: v_floor_f32_e32
; GCN: v_floor_f32_e32
; GCN: v_floor_f32_e32

; R600: FLOOR
; R600: FLOOR
; R600: FLOOR
; R600: FLOOR
define void @floor_v4f32(<4 x float> addrspace(1)* %out, <4 x float> %in) {
  %tmp = call <4 x float> @llvm.floor.v4f32(<4 x float> %in) #0
  store <4 x float> %tmp, <4 x float> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}floor_f16:
; SI: v_floor_f32_e32

; VI: v_floor_f16_e32

; R600: FLOOR
define void @floor_f16(half addrspace(1)* %out, half %in) {
  %tmp = call half @llvm.floor.f16(half %in) #0
  store half %tmp, half addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}floor_v2f16:
; SI: v_floor_f32_e32
; SI: v_floor_f32_e32

; VI: v_floor_f16_e32
; VI: v_floor_f16_e32

; R600: FLOOR
; R600: FLOOR
define void @floor_v2f16(<2 x half> addrspace(1)* %out, <2 x half> %in) {
  %tmp = call <2 x half> @llvm.floor.v2f16(<2 x half> %in) #0
  store <2 x half> %tmp, <2 x half> addrspace(1)* %out
  ret void
}

; XFUNC-LABEL: {{^}}floor_v3f16:
; XSI: v_floor_f32_e32
; XSI: v_floor_f32_e32
; XSI: v_floor_f32_e32
; XSI-NOT: v_floor_f32_e32

; XVI: v_floor_f16_e32
; XVI: v_floor_f16_e32
; XVI: v_floor_f16_e32
; XVI-NOT: v_floor_f16_e32


; XR600: FLOOR
; XR600: FLOOR
; XR600: FLOOR
; define void @floor_v3f16(<3 x half> addrspace(1)* %out, <3 x half> %in) {
;   %tmp = call <3 x half> @llvm.floor.v3f16(<3 x half> %in) #0
;   store <3 x half> %tmp, <3 x half> addrspace(1)* %out
;   ret void
; }

; FUNC-LABEL: {{^}}floor_v4f16:
; SI: v_floor_f32_e32
; SI: v_floor_f32_e32
; SI: v_floor_f32_e32
; SI: v_floor_f32_e32

; VI: v_floor_f16_e32
; VI: v_floor_f16_e32
; VI: v_floor_f16_e32
; VI: v_floor_f16_e32

; R600: FLOOR
; R600: FLOOR
; R600: FLOOR
; R600: FLOOR
define void @floor_v4f16(<4 x half> addrspace(1)* %out, <4 x half> %in) {
  %tmp = call <4 x half> @llvm.floor.v4f16(<4 x half> %in) #0
  store <4 x half> %tmp, <4 x half> addrspace(1)* %out
  ret void
}

declare float @llvm.floor.f32(float) #0
declare <2 x float> @llvm.floor.v2f32(<2 x float>) #0
declare <3 x float> @llvm.floor.v3f32(<3 x float>) #0
declare <4 x float> @llvm.floor.v4f32(<4 x float>) #0

declare half @llvm.floor.f16(half) #0
declare <2 x half> @llvm.floor.v2f16(<2 x half>) #0
declare <3 x half> @llvm.floor.v3f16(<3 x half>) #0
declare <4 x half> @llvm.floor.v4f16(<4 x half>) #0

attributes #0 = { nounwind readnone }
