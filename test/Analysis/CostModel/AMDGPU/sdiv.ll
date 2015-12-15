; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa < %s | FileCheck %s

; CHECK: 'sdiv_i32'
; CHECK: estimated cost of 0 for {{.*}} extractelement i32
define void @sdiv_i32(i32 addrspace(1)* %out, i32 %x, i32 %y) {
  %div = sdiv i32 %x, %y
  store i32 %div, i32 addrspace(1)* %out
  ret void
}
