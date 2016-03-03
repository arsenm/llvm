; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=tahiti < %s | FileCheck -check-prefixes=GCN,FASTFMA32,SICI,SICI-FASTFMA %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=verde < %s | FileCheck -check-prefixes=GCN,SLOWFMA32,SICI,SICI-SLOWFMA %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=hawaii < %s | FileCheck -check-prefixes=GCN,FASTFMA32,SICI,SICI-FASTMFA %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=bonaire < %s | FileCheck -check-prefixes=GCN,SLOWFMA32,SICI,SICI-SLOWFMA %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=fiji < %s | FileCheck -check-prefixes=GCN,SLOWFMA32,VI %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=gfx900 < %s | FileCheck -check-prefixes=GCN,FASTFMA32,GFX9 %s

; FASTFMA32: Found an estimated cost of 1 for instruction: %fma = call float @llvm.fma.f32(
; SLOWFMA32: Found an estimated cost of 3 for instruction: %fma = call float @llvm.fma.f32(
define float @fma_f32(float %a, float %b, float %c) #0 {
  %fma = call float @llvm.fma.f32(float %a, float %b, float %c)
  ret float %fma
}

; FASTFMA32: Found an estimated cost of 2 for instruction: %fma = call <2 x float> @llvm.fma.v2f32(
; SLOWFMA32: Found an estimated cost of 6 for instruction: %fma = call <2 x float> @llvm.fma.v2f32(
define <2 x float> @fma_v2f32(<2 x float> %a, <2 x float> %b, <2 x float> %c) #0 {
  %fma = call <2 x float> @llvm.fma.v2f32(<2 x float> %a, <2 x float> %b, <2 x float> %c)
  ret <2 x float> %fma
}

; GCN: Cost Model: Found an estimated cost of 3 for instruction: %fma = call double @llvm.fma.f64(
define double @fma_f64(double %a, double %b, double %c) #0 {
  %fma = call double @llvm.fma.f64(double %a, double %b, double %c)
  ret double %fma
}

; GCN: Found an estimated cost of 6 for instruction: %fma = call <2 x double> @llvm.fma.v2f64(
define <2 x double> @fma_v2f64(<2 x double> %a, <2 x double> %b, <2 x double> %c) #0 {
  %fma = call <2 x double> @llvm.fma.v2f64(<2 x double> %a, <2 x double> %b, <2 x double> %c)
  ret <2 x double> %fma
}

; FIXME: Should be expensive for SI because of conversions
; SICI-FASTFMA: Found an estimated cost of 1 for instruction: %fma = call half @llvm.fma.f16(
; SICI-SLOWFMA: Found an estimated cost of 3 for instruction: %fma = call half @llvm.fma.f16(
; VI: Found an estimated cost of 1 for instruction: %fma = call half @llvm.fma.f16(
; GFX9: Found an estimated cost of 1 for instruction: %fma = call half @llvm.fma.f16(
define half @fma_f16(half %a, half %b, half %c) #0 {
  %fma = call half @llvm.fma.f16(half %a, half %b, half %c)
  ret half %fma
}

; SICI-FASTFMA: Cost Model: Found an estimated cost of 2 for instruction: %fma = call <2 x half> @llvm.fma.v2f16(
; SICI-SLOWFMA: Cost Model: Found an estimated cost of 6 for instruction: %fma = call <2 x half> @llvm.fma.v2f16(
; VI: Cost Model: Found an estimated cost of 2 for instruction: %fma = call <2 x half> @llvm.fma.v2f16(
; GFX9: Cost Model: Found an estimated cost of 1 for instruction: %fma = call <2 x half> @llvm.fma.v2f16(
define <2 x half> @fma_v2f16(<2 x half> %a, <2 x half> %b, <2 x half> %c) #0 {
  %fma = call <2 x half> @llvm.fma.v2f16(<2 x half> %a, <2 x half> %b, <2 x half> %c)
  ret <2 x half> %fma
}

; FIXME: gfx9 should be 2
; SICI: Cost Model: Found an estimated cost of 8 for instruction: %fma = call <3 x half> @llvm.fma.v3f16(
; VI: Cost Model: Found an estimated cost of 8 for instruction: %fma = call <3 x half> @llvm.fma.v3f16(
; GFX9: Cost Model: Found an estimated cost of 4 for instruction: %fma = call <3 x half> @llvm.fma.v3f16(
define <3 x half> @fma_v3f16(<3 x half> %a, <3 x half> %b, <3 x half> %c) #0 {
  %fma = call <3 x half> @llvm.fma.v3f16(<3 x half> %a, <3 x half> %b, <3 x half> %c)
  ret <3 x half> %fma
}

; SICI-FASTFMA: Cost Model: Found an estimated cost of 4 for instruction: %fma = call <4 x half> @llvm.fma.v4f16(
; SICI-SLOWFMA: Cost Model: Found an estimated cost of 12 for instruction: %fma = call <4 x half> @llvm.fma.v4f16(
; VI: Cost Model: Found an estimated cost of 4 for instruction: %fma = call <4 x half> @llvm.fma.v4f16(
; GFX9: Cost Model: Found an estimated cost of 2 for instruction: %fma = call <4 x half> @llvm.fma.v4f16(
define <4 x half> @fma_v4f16(<4 x half> %a, <4 x half> %b, <4 x half> %c) #0 {
  %fma = call <4 x half> @llvm.fma.v4f16(<4 x half> %a, <4 x half> %b, <4 x half> %c)
  ret <4 x half> %fma
}

declare float @llvm.fma.f32(float, float, float) #1
declare <2 x float> @llvm.fma.v2f32(<2 x float>, <2 x float>, <2 x float>) #1

declare half @llvm.fma.f16(half, half, half) #1
declare <2 x half> @llvm.fma.v2f16(<2 x half>, <2 x half>, <2 x half>) #1
declare <3 x half> @llvm.fma.v3f16(<3 x half>, <3 x half>, <3 x half>) #1
declare <4 x half> @llvm.fma.v4f16(<4 x half>, <4 x half>, <4 x half>) #1

declare double @llvm.fma.f64(double, double, double) #1
declare <2 x double> @llvm.fma.v2f64(<2 x double>, <2 x double>, <2 x double>) #1

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
