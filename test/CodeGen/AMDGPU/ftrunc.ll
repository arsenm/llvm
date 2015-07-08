; RUN: llc -march=amdgcn -mcpu=SI < %s | FileCheck -check-prefix=SI -check-prefix=GCN -check-prefix=FUNC %s
; RUN: llc -march=amdgcn -mcpu=tonga < %s | FileCheck -check-prefix=VI -check-prefix=GCN -check-prefix=FUNC %s
; RUN: llc -march=r600 -mcpu=redwood < %s | FileCheck -check-prefix=EG --check-prefix=FUNC %s

declare float @llvm.trunc.f32(float) nounwind readnone
declare <2 x float> @llvm.trunc.v2f32(<2 x float>) nounwind readnone
declare <3 x float> @llvm.trunc.v3f32(<3 x float>) nounwind readnone
declare <4 x float> @llvm.trunc.v4f32(<4 x float>) nounwind readnone
declare <8 x float> @llvm.trunc.v8f32(<8 x float>) nounwind readnone
declare <16 x float> @llvm.trunc.v16f32(<16 x float>) nounwind readnone

declare half @llvm.trunc.f16(half) nounwind readnone
declare <2 x half> @llvm.trunc.v2f16(<2 x half>) nounwind readnone
declare <3 x half> @llvm.trunc.v3f16(<3 x half>) nounwind readnone
declare <4 x half> @llvm.trunc.v4f16(<4 x half>) nounwind readnone
declare <8 x half> @llvm.trunc.v8f16(<8 x half>) nounwind readnone
declare <16 x half> @llvm.trunc.v16f16(<16 x half>) nounwind readnone


; FUNC-LABEL: {{^}}ftrunc_f32:
; EG: TRUNC
; GCN: v_trunc_f32_e32
define void @ftrunc_f32(float addrspace(1)* %out, float %x) {
  %y = call float @llvm.trunc.f32(float %x) nounwind readnone
  store float %y, float addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}ftrunc_v2f32:
; EG: TRUNC
; EG: TRUNC
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
define void @ftrunc_v2f32(<2 x float> addrspace(1)* %out, <2 x float> %x) {
  %y = call <2 x float> @llvm.trunc.v2f32(<2 x float> %x) nounwind readnone
  store <2 x float> %y, <2 x float> addrspace(1)* %out
  ret void
}

; FIXME-FUNC-LABEL: {{^}}ftrunc_v3f32:
; FIXME-EG: TRUNC
; FIXME-EG: TRUNC
; FIXME-EG: TRUNC
; FIXME-GCN: v_trunc_f32_e32
; FIXME-GCN: v_trunc_f32_e32
; FIXME-GCN: v_trunc_f32_e32
; define void @ftrunc_v3f32(<3 x float> addrspace(1)* %out, <3 x float> %x) {
;   %y = call <3 x float> @llvm.trunc.v3f32(<3 x float> %x) nounwind readnone
;   store <3 x float> %y, <3 x float> addrspace(1)* %out
;   ret void
; }

; FUNC-LABEL: {{^}}ftrunc_v4f32:
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
define void @ftrunc_v4f32(<4 x float> addrspace(1)* %out, <4 x float> %x) {
  %y = call <4 x float> @llvm.trunc.v4f32(<4 x float> %x) nounwind readnone
  store <4 x float> %y, <4 x float> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}ftrunc_v8f32:
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
define void @ftrunc_v8f32(<8 x float> addrspace(1)* %out, <8 x float> %x) {
  %y = call <8 x float> @llvm.trunc.v8f32(<8 x float> %x) nounwind readnone
  store <8 x float> %y, <8 x float> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}ftrunc_v16f32:
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
; GCN: v_trunc_f32_e32
define void @ftrunc_v16f32(<16 x float> addrspace(1)* %out, <16 x float> %x) {
  %y = call <16 x float> @llvm.trunc.v16f32(<16 x float> %x) nounwind readnone
  store <16 x float> %y, <16 x float> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}ftrunc_f16:
; SI: v_trunc_f32_e32

; VI: v_trunc_f16_e32

; EG: TRUNC
define void @ftrunc_f16(half addrspace(1)* %out, half %x) {
  %y = call half @llvm.trunc.f16(half %x) nounwind readnone
  store half %y, half addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}ftrunc_v2f16:
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32

; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32

; EG: TRUNC
; EG: TRUNC
define void @ftrunc_v2f16(<2 x half> addrspace(1)* %out, <2 x half> %x) {
  %y = call <2 x half> @llvm.trunc.v2f16(<2 x half> %x) nounwind readnone
  store <2 x half> %y, <2 x half> addrspace(1)* %out
  ret void
}

; FIXME-FUNC-LABEL: {{^}}ftrunc_v3f16:
; FIXME-SI: v_trunc_f32_e32
; FIXME-SI: v_trunc_f32_e32
; FIXME-SI: v_trunc_f32_e32

; FIXME-VI: v_trunc_f16_e32
; FIXME-VI: v_trunc_f16_e32
; FIXME-VI: v_trunc_f16_e32

; FIXME-EG: TRUNC
; FIXME-EG: TRUNC
; FIXME-EG: TRUNC

; define void @ftrunc_v3f16(<3 x half> addrspace(1)* %out, <3 x half> %x) {
;   %y = call <3 x half> @llvm.trunc.v3f16(<3 x half> %x) nounwind readnone
;   store <3 x half> %y, <3 x half> addrspace(1)* %out
;   ret void
; }

; FUNC-LABEL: {{^}}ftrunc_v4f16:
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32

; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32

; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
define void @ftrunc_v4f16(<4 x half> addrspace(1)* %out, <4 x half> %x) {
  %y = call <4 x half> @llvm.trunc.v4f16(<4 x half> %x) nounwind readnone
  store <4 x half> %y, <4 x half> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}ftrunc_v8f16:
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32

; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
define void @ftrunc_v8f16(<8 x half> addrspace(1)* %out, <8 x half> %x) {
  %y = call <8 x half> @llvm.trunc.v8f16(<8 x half> %x) nounwind readnone
  store <8 x half> %y, <8 x half> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}ftrunc_v16f16:
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32
; SI: v_trunc_f32_e32

; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32
; VI: v_trunc_f16_e32

; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
; EG: TRUNC
define void @ftrunc_v16f16(<16 x half> addrspace(1)* %out, <16 x half> %x) {
  %y = call <16 x half> @llvm.trunc.v16f16(<16 x half> %x) nounwind readnone
  store <16 x half> %y, <16 x half> addrspace(1)* %out
  ret void
}
