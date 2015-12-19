; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mattr=+half-rate-64-ops < %s | FileCheck -check-prefix=ALL -check-prefix=FASTF64 %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mattr=-half-rate-64-ops < %s | FileCheck -check-prefix=ALL -check-prefix=SLOWF64 %s

; ALL: 'uitofp_i32_to_f32'
; ALL: estimated cost of 1 for {{.*}} uitofp i32 %val to float
define void @uitofp_i32_to_f32(float addrspace(1)* %out, i32 %val) #0 {
  %cvt = uitofp i32 %val to float
  store float %cvt, float addrspace(1)* %out
  ret void
}

; ALL: 'uitofp_v32i32_to_v32f32'
; ALL: estimated cost of 32 for {{.*}} uitofp <32 x i32> %val to <32 x float>
define void @uitofp_v32i32_to_v32f32(<32 x float> addrspace(1)* %out, <32 x i32> %val) #0 {
  %cvt = uitofp <32 x i32> %val to <32 x float>
  store <32 x float> %cvt, <32 x float> addrspace(1)* %out
  ret void
}

; ALL: 'uitofp_i64_to_f32'
; FASTF64: estimated cost of 22 for {{.*}} uitofp i64 %val to float
; SLOWF64: estimated cost of 25 for {{.*}} uitofp i64 %val to float
define void @uitofp_i64_to_f32(float addrspace(1)* %out, i64 %val) #0 {
  %cvt = uitofp i64 %val to float
  store float %cvt, float addrspace(1)* %out
  ret void
}

; ALL: 'uitofp_i32_to_f64'
; FASTF64: estimated cost of 2 for {{.*}} uitofp i32 %val to double
; SLOWF64: estimated cost of 3 for {{.*}} uitofp i32 %val to double
define void @uitofp_i32_to_f64(double addrspace(1)* %out, i32 %val) #0 {
  %cvt = uitofp i32 %val to double
  store double %cvt, double addrspace(1)* %out
  ret void
}

; ALL: 'uitofp_i64_to_f64'
; FASTF64: estimated cost of 8 for {{.*}} uitofp i64 %val to double
; SLOWF64: estimated cost of 12 for {{.*}} uitofp i64 %val to double
define void @uitofp_i64_to_f64(double addrspace(1)* %out, i64 %val) #0 {
  %cvt = uitofp i64 %val to double
  store double %cvt, double addrspace(1)* %out
  ret void
}

; ALL: 'uitofp_v3i64_to_v3f64'
; FASTF64: estimated cost of 24 for {{.*}} uitofp <3 x i64> %val to <3 x double>
; SLOWF64: estimated cost of 36 for {{.*}} uitofp <3 x i64> %val to <3 x double>
define void @uitofp_v3i64_to_v3f64(<3 x double> addrspace(1)* %out, <3 x i64> %val) #0 {
  %cvt = uitofp <3 x i64> %val to <3 x double>
  store <3 x double> %cvt, <3 x double> addrspace(1)* %out
  ret void
}

attributes #0 = { nounwind }
