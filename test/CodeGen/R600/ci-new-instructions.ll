; RUN: llc -march=r600 -mcpu=bonaire < %s | FileCheck -check-prefix=CI -check-prefix=FUNC %s

; FUNC-LABEL @mad_u64_u32_zextmul
; CI-NOT: V_MAD_U64_U32
define void @mad_u64_u32_zextmul(i64 addrspace(1)* %out, i32 %a, i32 %b, i64 %c) {
  %tmp = mul i32 %a, %b
  %tmp1 = zext i32 %tmp to i64
  %tmp2 = add i64 %tmp1, %c
  store i64 %tmp2, i64 addrspace(1)* %out
  ret void
}

; FUNC-LABEL @mad_u64_u32_zextmul_nuw
; CI: V_MAD_U64_U32
define void @mad_u64_u32_extmul_nuw(i64 addrspace(1)* %out, i32 %a, i32 %b, i64 %c) {
  %tmp = mul nuw i32 %a, %b
  %tmp1 = zext i32 %tmp to i64
  %tmp2 = add i64 %tmp1, %c
  store i64 %tmp2, i64 addrspace(1)* %out
  ret void
}

; FUNC-LABEL @mad_i64_i32_extmul
; CI-NOT: V_MAD_I64_I32
define void @mad_i64_i32_extmul(i64 addrspace(1)* %out, i32 %a, i32 %b, i64 %c) {
  %mul = mul i32 %a, %b
  %sextmul = sext i32 %mul to i64
  %result = add i64 %sextmul, %c
  store i64 %result, i64 addrspace(1)* %out
  ret void
}

; FUNC-LABEL @mad_i64_i32_extmul_nsw
; CI: V_MAD_I64_I32
define void @mad_i64_i32_extmul_nsw(i64 addrspace(1)* %out, i32 %a, i32 %b, i64 %c) {
  %mul = mul nsw i32 %a, %b
  %sextmul = sext i32 %mul to i64
  %result = add i64 %sextmul, %c
  store i64 %result, i64 addrspace(1)* %out
  ret void
}

; FUNC-LABEL @mad_i64_i32_trunc
; CI: V_MAD_I64_I32
define void @mad_i64_i32_trunc(i64 addrspace(1)* %out, i64 %a, i64 %b, i64 %c) {
  %tmp = shl i64 %a, 32
  %a_24 = ashr i64 %tmp, 32
  %tmp1 = shl i64 %b, 32
  %b_24 = ashr i64 %tmp1, 32
  %tmp2 = mul i64 %a_24, %b_24
  %tmp3 = add i64 %tmp2, %c
  store i64 %tmp3, i64 addrspace(1)* %out
  ret void
}

; FUNC-LABEL @mad_u64_u32_trunc
; CI: V_MAD_U64_U32
define void @mad_u64_u32_trunc(i64 addrspace(1)* %out, i64 %a, i64 %b, i64 %c) {
  %tmp = shl i64 %a, 32
  %a_24 = lshr i64 %tmp, 32
  %tmp1 = shl i64 %b, 32
  %b_24 = lshr i64 %tmp1, 32
  %tmp2 = mul i64 %a_24, %b_24
  %tmp3 = add i64 %tmp2, %c
  store i64 %tmp3, i64 addrspace(1)* %out
  ret void
}

; FUNC-LABEL @mad_i64_i32_shl_trunc
; CI: V_MAD_I64_I32
define void @mad_i64_i32_shl_trunc(i64 addrspace(1)* %out, i64 %a, i64 %c) {
  %tmp = shl i64 %a, 32
  %a_24 = ashr i64 %tmp, 32
  %tmp2 = shl i64 %a_24, 7
  %tmp3 = add i64 %tmp2, %c
  store i64 %tmp3, i64 addrspace(1)* %out
  ret void
}


; FUNC-LABEL @mad_u64_u32_shl_trunc
; CI: V_MAD_U64_U32
define void @mad_u64_u32_shl_trunc(i64 addrspace(1)* %out, i64 %a, i64 %c) {
  %tmp = shl i64 %a, 32
  %a_24 = lshr i64 %tmp, 32
  %tmp2 = shl i64 %a_24, 7
  %tmp3 = add i64 %tmp2, %c
  store i64 %tmp3, i64 addrspace(1)* %out
  ret void
}

define void @mad_u64_u32_odd_gep([7 x i32] addrspace(1)* %out, i64 %a, i64 %b) {
  %gep = getelementptr [7 x i32] addrspace(1)* %out, i64 %a, i64 %b
  store i32 3, i32 addrspace(1)* %gep
  ret void
}

define void @mad_u64_u32_gep([1024 x i32] addrspace(1)* %out, i64 %a, i64 %b) {
  %gep = getelementptr [1024 x i32] addrspace(1)* %out, i64 %a, i64 %b
  store i32 3, i32 addrspace(1)* %gep
  ret void
}
