; RUN: opt -S -instcombine < %s | FileCheck %s
; (fadd (fma x, y, (fmul u, v), z) -> (fma x, y (fma u, v, z))

; CHECK-LABEL: @fast_add_fma_fmul(
; CHECK: %1 = call fast float @llvm.fma.f32(float %u, float %v, float %z)
; CHECK-NEXT: %2 = call fast float @llvm.fma.f32(float %x, float %y, float %1)
; CHECK-NEXT: ret float %2
define float @fast_add_fma_fmul(float %x, float %y, float %z, float %u, float %v) {
  %mul.u.v = fmul fast float %u, %v
  %fma = call fast float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
  %add = fadd fast float %fma, %z
  ret float %add
}

; CHECK-LABEL: @fast_sub_fma_fmul(
; CHECK: %mul.u.v = fmul fast float %u, %v
; CHECK-NEXT: %fma = call fast float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
; CHECK-NEXT: %add = fsub fast float %fma, %z
; CHECK-NEXT: ret float %add
define float @fast_sub_fma_fmul(float %x, float %y, float %z, float %u, float %v) {
  %mul.u.v = fmul fast float %u, %v
  %fma = call fast float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
  %add = fsub fast float %fma, %z
  ret float %add
}

; CHECK-LABEL: @fast_add_fma_fmul_multi_use_mul(
; CHECK: fmul fast
; CHECK: call fast float @llvm.fma.f32(
; CHECK: fadd fast
define float @fast_add_fma_fmul_multi_use_mul(float %x, float %y, float %z, float %u, float %v) {
  %mul.u.v = fmul fast float %u, %v
  store volatile float %mul.u.v, float* undef
  %fma = call fast float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
  %add = fadd fast float %fma, %z
  ret float %add
}

; CHECK-LABEL: @fast_add_fma_fmul_multi_use_fma(
; CHECK: fmul fast
; CHECK: call fast float @llvm.fma.f32(
; CHECK: fadd fast
define float @fast_add_fma_fmul_multi_use_fma(float %x, float %y, float %z, float %u, float %v) {
  %mul.u.v = fmul fast float %u, %v
  %fma = call fast float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
  store volatile float %fma, float* undef
  %add = fadd fast float %fma, %z
  ret float %add
}

; CHECK-LABEL: @fast_add_fma_fmul_constant_x(
; CHECK: %1 = call fast float @llvm.fma.f32(float %u, float %v, float %z)
; CHECK-NEXT: %2 = call fast float @llvm.fma.f32(float %y, float 8.000000e+00, float %1)
; CHECK-NEXT: ret float %2
define float @fast_add_fma_fmul_constant_x(float %y, float %z, float %u, float %v) {
  %mul.u.v = fmul fast float %u, %v
  %fma = call fast float @llvm.fma.f32(float 8.0, float %y, float %mul.u.v)
  %add = fadd fast float %fma, %z
  ret float %add
}

; CHECK-LABEL: @fast_add_fma_fmul_constant_y(
; CHECK: %1 = call fast float @llvm.fma.f32(float %u, float %v, float %z)
; CHECK-NEXT: %2 = call fast float @llvm.fma.f32(float %x, float 4.000000e+00, float %1)
; CHECK-NEXT: ret float %2
define float @fast_add_fma_fmul_constant_y(float %x, float %z, float %u, float %v) {
  %mul.u.v = fmul fast float %u, %v
  %fma = call fast float @llvm.fma.f32(float %x, float 4.0, float %mul.u.v)
  %add = fadd fast float %fma, %z
  ret float %add
}

; CHECK-LABEL: @fast_add_fma_fmul_constant_v(
; CHECK: %1 = call fast float @llvm.fma.f32(float %u, float 4.000000e+00, float %z)
; CHECK-NEXT: %2 = call fast float @llvm.fma.f32(float %x, float %y, float %1)
; CHECK-NEXT: ret float %2
define float @fast_add_fma_fmul_constant_v(float %x, float %y, float %z, float %u) {
  %mul.u.v = fmul fast float %u, 4.0
  %fma = call fast float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
  %add = fadd fast float %fma, %z
  ret float %add
}

; CHECK-LABEL: @fast_add_fma_fmul_constant_z(
; CHECK: %1 = call fast float @llvm.fma.f32(float %u, float %v, float 4.000000e+00)
; CHECK-NEXT: %2 = call fast float @llvm.fma.f32(float %x, float %y, float %1)
; CHECK-NEXT: ret float %2
define float @fast_add_fma_fmul_constant_z(float %x, float %y, float %u, float %v) {
  %mul.u.v = fmul fast float %u, %v
  %fma = call fast float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
  %add = fadd fast float %fma, 4.0
  ret float %add
}

; CHECK-LABEL: @missing_fast_add_fma_fmul_0(
; CHECK: fmul float %u, %v
; CHECK-NEXT: %fma = call fast float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
; CHECK-NEXT: %add = fadd fast float %fma, %z
; CHECK-NEXT: ret float %add
define float @missing_fast_add_fma_fmul_0(float %x, float %y, float %z, float %u, float %v) {
  %mul.u.v = fmul float %u, %v
  %fma = call fast float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
  %add = fadd fast float %fma, %z
  ret float %add
}

; CHECK-LABEL: @missing_fast_add_fma_fmul_1(
; CHECK: %mul.u.v = fmul fast float %u, %v
; CHECK-NEXT: %fma = call float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
; CHECK-NEXT: %add = fadd fast float %fma, %z
; CHECK-NEXT: ret float %add
define float @missing_fast_add_fma_fmul_1(float %x, float %y, float %z, float %u, float %v) {
  %mul.u.v = fmul fast float %u, %v
  %fma = call float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
  %add = fadd fast float %fma, %z
  ret float %add
}

; CHECK-LABEL: @missing_fast_add_fma_fmul_2(
; CHECK: %mul.u.v = fmul fast float %u, %v
; CHECK-NEXT: %fma = call fast float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
; CHECK-NEXT: %add = fadd float %fma, %z
; CHECK-NEXT: ret float %add
define float @missing_fast_add_fma_fmul_2(float %x, float %y, float %z, float %u, float %v) {
  %mul.u.v = fmul fast float %u, %v
  %fma = call fast float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
  %add = fadd float %fma, %z
  ret float %add
}

; CHECK-LABEL: @safe_add_fma_fmul(
; CHECK: %mul.u.v = fmul float %u, %v
; CHECK-NEXT: %fma = call float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
; CHECK-NEXT: %add = fadd float %fma, %z
define float @safe_add_fma_fmul(float %x, float %y, float %z, float %u, float %v) {
  %mul.u.v = fmul float %u, %v
  %fma = call float @llvm.fma.f32(float %x, float %y, float %mul.u.v)
  %add = fadd float %fma, %z
  ret float %add
}

; CHECK-LABEL: @fast_add_fmuladd_fmul(
; CHECK: %1 = call fast float @llvm.fmuladd.f32(float %u, float %v, float %z)
; CHECK-NEXT: %2 = call fast float @llvm.fmuladd.f32(float %x, float %y, float %1)
; CHECK-NEXT: ret float %2
define float @fast_add_fmuladd_fmul(float %x, float %y, float %z, float %u, float %v) {
  %mul.u.v = fmul fast float %u, %v
  %fmuladd = call fast float @llvm.fmuladd.f32(float %x, float %y, float %mul.u.v)
  %add = fadd fast float %fmuladd, %z
  ret float %add
}

declare float @llvm.fma.f32(float, float, float) #0
declare float @llvm.fmuladd.f32(float, float, float) #0

attributes #0 = { nounwind readnone }
