; RUN: opt -always-inline -instcombine -S < %s | FileCheck %s

declare float @llvm.amdgcn.rcp.f32(float) #0
declare double @llvm.amdgcn.rcp.f64(double) #0

; CHECK-LABEL: @test_constant_fold_rcp_f32_1
; CHECK-NEXT: ret float 1.000000e+00
define float @test_constant_fold_rcp_f32_1() #0 {
  %val = call float @llvm.amdgcn.rcp.f32(float 1.0)
  ret float %val
}

; CHECK-LABEL: @test_constant_fold_rcp_f64_1
; CHECK-NEXT:  ret double 1.000000e+00
define double @test_constant_fold_rcp_f64_1() #0 {
  %val = call double @llvm.amdgcn.rcp.f64(double 1.0)
  ret double %val
}

; CHECK-LABEL: @test_constant_fold_rcp_f32_half
; CHECK-NEXT: ret float 2.000000e+00
define float @test_constant_fold_rcp_f32_half() #0 {
  %val = call float @llvm.amdgcn.rcp.f32(float 0.5)
  ret float %val
}

; CHECK-LABEL: @test_constant_fold_rcp_f64_half
; CHECK-NEXT:  ret double 2.000000e+00
define double @test_constant_fold_rcp_f64_half() #0 {
  %val = call double @llvm.amdgcn.rcp.f64(double 0.5)
  ret double %val
}

; CHECK-LABEL: @test_constant_fold_rcp_f32_43
; CHECK-NEXT: call float @llvm.amdgcn.rcp.f32(float 4.300000e+01)
define float @test_constant_fold_rcp_f32_43() #0 {
 %val = call float @llvm.amdgcn.rcp.f32(float 4.300000e+01)
 ret float %val
}

; CHECK-LABEL: @test_constant_fold_rcp_f64_43
; CHECK-NEXT: call double @llvm.amdgcn.rcp.f64(double 4.300000e+01)
define double @test_constant_fold_rcp_f64_43() #0 {
  %val = call double @llvm.amdgcn.rcp.f64(double 4.300000e+01)
  ret double %val
}

define internal i32 @reference_smul24(i32 %x, i32 %y) #1 {
  %1 = shl i32 %x, 8
  %2 = ashr exact i32 %1, 8
  %3 = shl i32 %y, 8
  %4 = ashr exact i32 %3, 8
  %5 = mul nsw i32 %4, %2
  ret i32 %5
}

define internal i32 @reference_umul24(i32 %x, i32 %y) #1 {
  %1 = and i32 %x, 16777215
  %2 = and i32 %y, 16777215
  %3 = mul i32 %2, %1
  ret i32 %3
}

declare i32 @llvm.amdgcn.smul24(i32, i32) #0

; CHECK-LABEL: @test_constant_fold_smul24_0_0(
; CHECK-NEXT: ret i1 true
define i1 @test_constant_fold_smul24_0_0() #0 {
  %val0 = call i32 @llvm.amdgcn.smul24(i32 0, i32 0)
  %val1 = call i32 @reference_smul24(i32 0, i32 0)
  %eq = icmp eq i32 %val0, %val1
  ret i1 %eq
}

; CHECK-LABEL: @test_constant_fold_smul24_1s24_1(
; CHECK-NEXT: ret i1 true
define i1 @test_constant_fold_smul24_1s24_1() #0 {
  %val0 = call i32 @llvm.amdgcn.smul24(i32 16777216, i32 1)
  %val1 = call i32 @reference_smul24(i32 16777216, i32 1)
  %eq = icmp eq i32 %val0, %val1
  ret i1 %eq
}

; CHECK-LABEL: @test_constant_fold_smul24_1s24m1_1s24m1(
; CHECK-NEXT: ret i1 true
define i1 @test_constant_fold_smul24_1s24m1_1s24m1() #0 {
  %val0 = call i32 @llvm.amdgcn.smul24(i32 16777215, i32 16777215)
  %val1 = call i32 @reference_smul24(i32 16777215, i32 16777215)
  %eq = icmp eq i32 %val0, %val1
  ret i1 %eq
}

; CHECK-LABEL: @test_constant_fold_smul24_n1_n1(
; CHECK-NEXT: ret i1 true
define i1 @test_constant_fold_smul24_n1_n1() #0 {
  %val0 = call i32 @llvm.amdgcn.smul24(i32 -1, i32 -1)
  %val1 = call i32 @reference_smul24(i32 -1, i32 -1)
  %eq = icmp eq i32 %val0, %val1
  ret i1 %eq
}

; CHECK-LABEL: @test_constant_fold_smul24_n1s24m1_n1s24m1(
; CHECK-NEXT: ret i1 true
define i1 @test_constant_fold_smul24_n1s24m1_n1s24m1() #0 {
  %val0 = call i32 @llvm.amdgcn.smul24(i32 -16777215, i32 -16777215)
  %val1 = call i32 @reference_smul24(i32 -16777215, i32 -16777215)
  %eq = icmp eq i32 %val0, %val1
  ret i1 %eq
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind readnone alwaysinline }
