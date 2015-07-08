; RUN: llc -march=amdgcn -mcpu=SI -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -march=r600 -mcpu=cypress < %s | FileCheck -check-prefix=EG -check-prefix=FUNC %s

declare float @llvm.ceil.f32(float) nounwind readnone
declare <2 x float> @llvm.ceil.v2f32(<2 x float>) nounwind readnone
declare <3 x float> @llvm.ceil.v3f32(<3 x float>) nounwind readnone
declare <4 x float> @llvm.ceil.v4f32(<4 x float>) nounwind readnone
declare <8 x float> @llvm.ceil.v8f32(<8 x float>) nounwind readnone
declare <16 x float> @llvm.ceil.v16f32(<16 x float>) nounwind readnone

declare half @llvm.ceil.f16(half) nounwind readnone
declare <2 x half> @llvm.ceil.v2f16(<2 x half>) nounwind readnone
declare <3 x half> @llvm.ceil.v3f16(<3 x half>) nounwind readnone
declare <4 x half> @llvm.ceil.v4f16(<4 x half>) nounwind readnone
declare <8 x half> @llvm.ceil.v8f16(<8 x half>) nounwind readnone
declare <16 x half> @llvm.ceil.v16f16(<16 x half>) nounwind readnone

; FUNC-LABEL: {{^}}fceil_f32:
; SI: v_ceil_f32_e32
; EG: MEM_RAT_CACHELESS STORE_RAW [[RESULT:T[0-9]+\.[XYZW]]]
; EG: CEIL {{\*? *}}[[RESULT]]
define void @fceil_f32(float addrspace(1)* %out, float %x) {
  %y = call float @llvm.ceil.f32(float %x) nounwind readnone
  store float %y, float addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}fceil_v2f32:
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; EG: MEM_RAT_CACHELESS STORE_RAW [[RESULT:T[0-9]+]]{{\.[XYZW]}}
; EG: CEIL {{\*? *}}[[RESULT]]
; EG: CEIL {{\*? *}}[[RESULT]]
define void @fceil_v2f32(<2 x float> addrspace(1)* %out, <2 x float> %x) {
  %y = call <2 x float> @llvm.ceil.v2f32(<2 x float> %x) nounwind readnone
  store <2 x float> %y, <2 x float> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}fceil_v3f32:
; FIXME-SI: v_ceil_f32_e32
; FIXME-SI: v_ceil_f32_e32
; FIXME-SI: v_ceil_f32_e32
; FIXME-EG: v3 is treated as v2 and v1, hence 2 stores
; EG: MEM_RAT_CACHELESS STORE_RAW [[RESULT1:T[0-9]+]]{{\.[XYZW]}}
; EG: MEM_RAT_CACHELESS STORE_RAW [[RESULT2:T[0-9]+]]{{\.[XYZW]}}
; EG-DAG: CEIL {{\*? *}}[[RESULT1]]
; EG-DAG: CEIL {{\*? *}}[[RESULT2]]
; EG-DAG: CEIL {{\*? *}}[[RESULT2]]
define void @fceil_v3f32(<3 x float> addrspace(1)* %out, <3 x float> %x) {
  %y = call <3 x float> @llvm.ceil.v3f32(<3 x float> %x) nounwind readnone
  store <3 x float> %y, <3 x float> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}fceil_v4f32:
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; EG: MEM_RAT_CACHELESS STORE_RAW [[RESULT:T[0-9]+]]{{\.[XYZW]}}
; EG: CEIL {{\*? *}}[[RESULT]]
; EG: CEIL {{\*? *}}[[RESULT]]
; EG: CEIL {{\*? *}}[[RESULT]]
; EG: CEIL {{\*? *}}[[RESULT]]
define void @fceil_v4f32(<4 x float> addrspace(1)* %out, <4 x float> %x) {
  %y = call <4 x float> @llvm.ceil.v4f32(<4 x float> %x) nounwind readnone
  store <4 x float> %y, <4 x float> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}fceil_v8f32:
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; EG: MEM_RAT_CACHELESS STORE_RAW [[RESULT1:T[0-9]+]]{{\.[XYZW]}}
; EG: MEM_RAT_CACHELESS STORE_RAW [[RESULT2:T[0-9]+]]{{\.[XYZW]}}
; EG-DAG: CEIL {{\*? *}}[[RESULT1]]
; EG-DAG: CEIL {{\*? *}}[[RESULT1]]
; EG-DAG: CEIL {{\*? *}}[[RESULT1]]
; EG-DAG: CEIL {{\*? *}}[[RESULT1]]
; EG-DAG: CEIL {{\*? *}}[[RESULT2]]
; EG-DAG: CEIL {{\*? *}}[[RESULT2]]
; EG-DAG: CEIL {{\*? *}}[[RESULT2]]
; EG-DAG: CEIL {{\*? *}}[[RESULT2]]
define void @fceil_v8f32(<8 x float> addrspace(1)* %out, <8 x float> %x) {
  %y = call <8 x float> @llvm.ceil.v8f32(<8 x float> %x) nounwind readnone
  store <8 x float> %y, <8 x float> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}fceil_v16f32:
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; EG: MEM_RAT_CACHELESS STORE_RAW [[RESULT1:T[0-9]+]]{{\.[XYZW]}}
; EG: MEM_RAT_CACHELESS STORE_RAW [[RESULT2:T[0-9]+]]{{\.[XYZW]}}
; EG: MEM_RAT_CACHELESS STORE_RAW [[RESULT3:T[0-9]+]]{{\.[XYZW]}}
; EG: MEM_RAT_CACHELESS STORE_RAW [[RESULT4:T[0-9]+]]{{\.[XYZW]}}
; EG-DAG: CEIL {{\*? *}}[[RESULT1]]
; EG-DAG: CEIL {{\*? *}}[[RESULT1]]
; EG-DAG: CEIL {{\*? *}}[[RESULT1]]
; EG-DAG: CEIL {{\*? *}}[[RESULT1]]
; EG-DAG: CEIL {{\*? *}}[[RESULT2]]
; EG-DAG: CEIL {{\*? *}}[[RESULT2]]
; EG-DAG: CEIL {{\*? *}}[[RESULT2]]
; EG-DAG: CEIL {{\*? *}}[[RESULT2]]
; EG-DAG: CEIL {{\*? *}}[[RESULT3]]
; EG-DAG: CEIL {{\*? *}}[[RESULT3]]
; EG-DAG: CEIL {{\*? *}}[[RESULT3]]
; EG-DAG: CEIL {{\*? *}}[[RESULT3]]
; EG-DAG: CEIL {{\*? *}}[[RESULT4]]
; EG-DAG: CEIL {{\*? *}}[[RESULT4]]
; EG-DAG: CEIL {{\*? *}}[[RESULT4]]
; EG-DAG: CEIL {{\*? *}}[[RESULT4]]
define void @fceil_v16f32(<16 x float> addrspace(1)* %out, <16 x float> %x) {
  %y = call <16 x float> @llvm.ceil.v16f32(<16 x float> %x) nounwind readnone
  store <16 x float> %y, <16 x float> addrspace(1)* %out
  ret void
}









; FUNC-LABEL: {{^}}fceil_f16:
; SI: v_ceil_f32_e32

; VI: v_ceil_f16_e32

; EG: CEIL
define void @fceil_f16(half addrspace(1)* %out, half %x) {
  %y = call half @llvm.ceil.f16(half %x) nounwind readnone
  store half %y, half addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}fceil_v2f16:
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32

; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32

; EG: CEIL
; EG: CEIL
define void @fceil_v2f16(<2 x half> addrspace(1)* %out, <2 x half> %x) {
  %y = call <2 x half> @llvm.ceil.v2f16(<2 x half> %x) nounwind readnone
  store <2 x half> %y, <2 x half> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}fceil_v3f16:
; FIXME-SI: v_ceil_f32_e32
; FIXME-SI: v_ceil_f32_e32
; FIXME-SI: v_ceil_f32_e32

; FIXME-VI: v_ceil_f16_e32
; FIXME-VI: v_ceil_f16_e32
; FIXME-VI: v_ceil_f16_e32

; FIXME-EG: v3 is treated as v2 and v1, hence 2 stores
; EG: CEIL
; EG: CEIL
; EG: CEIL
define void @fceil_v3f16(<3 x half> addrspace(1)* %out, <3 x half> %x) {
  %y = call <3 x half> @llvm.ceil.v3f16(<3 x half> %x) nounwind readnone
  store <3 x half> %y, <3 x half> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}fceil_v4f16:
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32

; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32


; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
define void @fceil_v4f16(<4 x half> addrspace(1)* %out, <4 x half> %x) {
  %y = call <4 x half> @llvm.ceil.v4f16(<4 x half> %x) nounwind readnone
  store <4 x half> %y, <4 x half> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}fceil_v8f16:
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32

; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32

; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
define void @fceil_v8f16(<8 x half> addrspace(1)* %out, <8 x half> %x) {
  %y = call <8 x half> @llvm.ceil.v8f16(<8 x half> %x) nounwind readnone
  store <8 x half> %y, <8 x half> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}fceil_v16f16:
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32
; SI: v_ceil_f32_e32

; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32
; VI: v_ceil_f16_e32

; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
; EG: CEIL
define void @fceil_v16f16(<16 x half> addrspace(1)* %out, <16 x half> %x) {
  %y = call <16 x half> @llvm.ceil.v16f16(<16 x half> %x) nounwind readnone
  store <16 x half> %y, <16 x half> addrspace(1)* %out
  ret void
}
