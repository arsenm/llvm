; RUN: llc < %s -march=r600 -mcpu=redwood | FileCheck %s --check-prefix=EG --check-prefix=FUNC
; RUN: llc < %s -march=r600 -mcpu=cayman | FileCheck %s --check-prefix=CM --check-prefix=FUNC
; RUN: llc < %s -march=amdgcn -mcpu=SI -verify-machineinstrs | FileCheck %s --check-prefix=SI --check-prefix=FUNC
; RUN: llc < %s -march=amdgcn -mcpu=tonga -verify-machineinstrs | FileCheck %s --check-prefix=SI --check-prefix=FUNC

; FUNC-LABEL: {{^}}i32_mul24:
; Signed 24-bit multiply is not supported on pre-Cayman GPUs.
; EG: MULLO_INT
; Make sure we are not masking the inputs
; CM-NOT: AND
; CM: MUL_INT24
; SI-NOT: and
; SI: v_mul_i32_i24
; define void @i32_mul24(i32 addrspace(1)* %out, i32 %a, i32 %b) {
; entry:
;   %0 = shl i32 %a, 8
;   %a_24 = ashr i32 %0, 8
;   %1 = shl i32 %b, 8
;   %b_24 = ashr i32 %1, 8
;   %2 = mul i32 %a_24, %b_24
;   store i32 %2, i32 addrspace(1)* %out
;   ret void
; }


; define void @mulhs(i32 addrspace(1)* %out, i32 %a, i32 %b) nounwind {
; entry:
;   %tmp.1 = sext i32 %a to i64
;   %tmp.3 = sext i32 %b to i64
;   %tmp.4 = mul i64 %tmp.3, %tmp.1
;   %tmp.6 = lshr i64 %tmp.4, 32
;   %tmp.7 = trunc i64 %tmp.6 to i32
;   store i32 %tmp.7, i32 addrspace(1)* %out
;   ret void
; }


define void @mulhs_16(i16 addrspace(1)* %out, i16 signext %a, i16 signext %b) nounwind {
entry:
  %tmp.1 = sext i16 %a to i64
  %tmp.3 = sext i16 %b to i64
  %tmp.4 = mul i64 %tmp.3, %tmp.1
  %tmp.6 = lshr i64 %tmp.4, 32
  %tmp.7 = trunc i64 %tmp.6 to i16
  store i16 %tmp.7, i16 addrspace(1)* %out
  ret void
}
