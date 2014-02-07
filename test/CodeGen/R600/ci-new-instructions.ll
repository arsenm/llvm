; RUN: llc -march=r600 -mcpu=bonaire < %s | FileCheck -check-prefix=CI %s


define void @i32_mad64(i64 addrspace(1)* %out, i32 %a, i32 %b, i64 %c) {
entry:
  %0 = mul i32 %a, %b
  %1 = zext i32 %0 to i64
  %2 = add i64 %1, %c
  store i64 %2, i64 addrspace(1)* %out
  ret void
}

; define void @i64_mad32(i64 addrspace(1)* %out, i64 %a, i64 %b, i64 %c) {
; entry:
;   %0 = shl i64 %a, 32
;   %a_24 = ashr i64 %0, 32
;   %1 = shl i64 %b, 32
;   %b_24 = ashr i64 %1, 32
;   %2 = mul i64 %a_24, %b_24
;   %3 = add i64 %2, %c
;   store i64 %3, i64 addrspace(1)* %out
;   ret void
; }


define void @mad_i64_i32(i64 addrspace(1)* %out, i32 %a, i32 %b, i64 %c) {
  %mul = mul i32 %a, %b
  %sextmul = sext i32 %mul to i64
  %result = add i64 %sextmul, %c
  store i64 %result, i64 addrspace(1)* %out
  ret void
}

