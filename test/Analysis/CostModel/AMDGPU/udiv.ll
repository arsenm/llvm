; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa < %s | FileCheck %s

; CHECK: 'udiv_i32'
; CHECK: estimated cost of 0 for {{.*}} extractelement i32
define void @udiv_i32(i32 addrspace(1)* %out, i32 %x, i32 %y) {
  %div = udiv i32 %x, %y
  store i32 %div, i32 addrspace(1)* %out
  ret void
}

; CHECK: 'udiv_v2i32'
; CHECK: estimated cost of 0 for {{.*}} extractelement i32
define void @udiv_v2i32(<2 x i32> addrspace(1)* %out, <2 x i32> %x, <2 x i32> %y) {
  %div = udiv <2 x i32> %x, %y
  store <2 x i32> %div, <2 x i32> addrspace(1)* %out
  ret void
}
; CHECK: 'udiv_i32_k_power_of_2'
; CHECK: estimated cost of 0 for {{.*}} extractelement i32
define void @udiv_i32_k_power_of_2(i32 addrspace(1)* %out, i32 %x, i32 %y) {
  %div = udiv i32 %x, 16
  store i32 %div, i32 addrspace(1)* %out
  ret void
}

; CHECK: 'udiv_i32_k'
; CHECK: estimated cost of 0 for {{.*}} extractelement i32
define void @udiv_i32_k(i32 addrspace(1)* %out, i32 %x, i32 %y) {
  %div = udiv i32 %x, 239582035
  store i32 %div, i32 addrspace(1)* %out
  ret void
}

; CHECK: 'udiv_i64'
; CHECK: estimated cost of 0 for {{.*}} extractelement i64
define void @udiv_i64(i64 addrspace(1)* %out, i64 %x, i64 %y) {
  %div = udiv i64 %x, %y
  store i64 %div, i64 addrspace(1)* %out
  ret void
}

; CHECK: 'udiv_v2i64'
; CHECK: estimated cost of 0 for {{.*}} extractelement i64
define void @udiv_v2i64(<2 x i64> addrspace(1)* %out, <2 x i64> %x, <2 x i64> %y) {
  %div = udiv <2 x i64> %x, %y
  store <2 x i64> %div, <2 x i64> addrspace(1)* %out
  ret void
}
; CHECK: 'udiv_i64_k_power_of_2'
; CHECK: estimated cost of 0 for {{.*}} extractelement i64
define void @udiv_i64_k_power_of_2(i64 addrspace(1)* %out, i64 %x, i64 %y) {
  %div = udiv i64 %x, 16
  store i64 %div, i64 addrspace(1)* %out
  ret void
}

; CHECK: 'udiv_i64_k'
; CHECK: estimated cost of 0 for {{.*}} extractelement i64
define void @udiv_i64_k(i64 addrspace(1)* %out, i64 %x, i64 %y) {
  %div = udiv i64 %x, 239582035
  store i64 %div, i64 addrspace(1)* %out
  ret void
}
