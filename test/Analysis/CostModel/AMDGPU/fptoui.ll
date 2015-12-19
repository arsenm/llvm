; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-unknown -mcpu=tahiti -mattr=+half-rate-64-ops < %s | FileCheck -check-prefix=COMMON -check-prefix=SIFASTF64 -check-prefix=FASTF64 %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-unknown -mcpu=verde -mattr=-half-rate-64-ops < %s | FileCheck -check-prefix=COMMON -check-prefix=SISLOWF64 -check-prefix=SLOWF64 %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=kaveri < %s | FileCheck -check-prefix=COMMON -check-prefix=CI -check-prefix=CIVISLOWF64 -check-prefix=SLOWF64 %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=hawaii -mattr=+half-rate-64-ops < %s | FileCheck -check-prefix=COMMON -check-prefix=CI -check-prefix=CIVIFASTF64 -check-prefix=FASTF64 %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=fiji < %s | FileCheck -check-prefix=COMMON -check-prefix=VI -check-prefix=CIVISLOWF64 -check-prefix=SLOWF64 %s

; COMMON: 'fptoui_f32_to_i32'
; COMMON: estimated cost of 1 for {{.*}} fptoui float %val to i32
define void @fptoui_f32_to_i32(i32 addrspace(1)* %out, float %val) #0 {
  %cvt = fptoui float %val to i32
  store i32 %cvt, i32 addrspace(1)* %out
  ret void
}

; COMMON: 'fptoui_v32f32_to_v32i32'
; COMMON: estimated cost of 32 for {{.*}} fptoui <32 x float> %val to <32 x i32>
define void @fptoui_v32f32_to_v32i32(<32 x i32> addrspace(1)* %out, <32 x float> %val) #0 {
  %cvt = fptoui <32 x float> %val to <32 x i32>
  store <32 x i32> %cvt, <32 x i32> addrspace(1)* %out
  ret void
}

; COMMON: 'fptoui_f64_to_i32'
; FASTF64: estimated cost of 2 for {{.*}} fptoui double %val to i32
; SLOWF64: estimated cost of 3 for {{.*}} fptoui double %val to i32
define void @fptoui_f64_to_i32(i32 addrspace(1)* %out, double %val) #0 {
  %cvt = fptoui double %val to i32
  store i32 %cvt, i32 addrspace(1)* %out
  ret void
}

; COMMON: 'fptoui_f32_to_i64'
; FASTF64: estimated cost of 21 for {{.*}} fptoui float %val to i64
; SLOWF64: estimated cost of 23 for {{.*}} fptoui float %val to i64
define void @fptoui_f32_to_i64(i64 addrspace(1)* %out, float %val) #0 {
  %cvt = fptoui float %val to i64
  store i64 %cvt, i64 addrspace(1)* %out
  ret void
}

; COMMON: 'fptoui_f64_to_i64'
; SIFASTF64: estimated cost of 46 for {{.*}} fptoui double %val to i64
; SISLOWF64: estimated cost of 52 for {{.*}} fptoui double %val to i64

; CIVIFASTF64: estimated cost of 13 for {{.*}} fptoui double %val to i64
; CIVISLOWF64: estimated cost of 18 for {{.*}} fptoui double %val to i64
define void @fptoui_f64_to_i64(i64 addrspace(1)* %out, double %val) #0 {
  %cvt = fptoui double %val to i64
  store i64 %cvt, i64 addrspace(1)* %out
  ret void
}

; COMMON: 'fptoui_v3f64_to_v3i64'
; SIFASTF64: estimated cost of 138 for {{.*}} fptoui <3 x double> %val to <3 x i64>
; SICLOWF64: estimated cost of 138 for {{.*}} fptoui <3 x double> %val to <3 x i64>
; CIVIFASTF64: estimated cost of 39 for {{.*}} fptoui <3 x double> %val to <3 x i64>
; CIVISLOWF64: estimated cost of 54 for {{.*}} fptoui <3 x double> %val to <3 x i64>
define void @fptoui_v3f64_to_v3i64(<3 x i64> addrspace(1)* %out, <3 x double> %val) #0 {
  %cvt = fptoui <3 x double> %val to <3 x i64>
  store <3 x i64> %cvt, <3 x i64> addrspace(1)* %out
  ret void
}

; COMMON: 'fptoui_f16_to_i32'
; COMMON: estimated cost of 1 for {{.*}} fptoui half %val to i32
define void @fptoui_f16_to_i32(i32 addrspace(1)* %out, half %val) #0 {
  %cvt = fptoui half %val to i32
  store i32 %cvt, i32 addrspace(1)* %out
  ret void
}

; FIXME: through f32
; COMMON: 'fptoui_f16_to_i64'
; FASTF64: estimated cost of 21 for {{.*}} fptoui half %val to i64
; SLOWF64: estimated cost of 23 for {{.*}} fptoui half %val to i64
define void @fptoui_f16_to_i64(i64 addrspace(1)* %out, half %val) #0 {
  %cvt = fptoui half %val to i64
  store i64 %cvt, i64 addrspace(1)* %out
  ret void
}

attributes #0 = { nounwind }
