; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=hawaii < %s | FileCheck -check-prefixes=GCN,CI %s
; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=fiji < %s | FileCheck -check-prefixes=GCN,VI %s

declare i8 @llvm.cttz.i8(i8, i1) #0
declare i16 @llvm.cttz.i16(i16, i1) #0
declare i32 @llvm.cttz.i32(i32, i1) #0
declare i64 @llvm.cttz.i64(i64, i1) #0

; GCN-LABEL: 'cttz_i32'
; GCN: estimated cost of 1 for {{.*}} call i32 @llvm.cttz.i32
define void @cttz_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %vaddr) #1 {
  %vec = load i32, i32 addrspace(1)* %vaddr
  %trunc = call i32 @llvm.cttz.i32(i32 %vec, i1 false)
  store i32 %trunc, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: 'cttz_zero_undef_i32'
; GCN: estimated cost of 1 for {{.*}} call i32 @llvm.cttz.i32
define void @cttz_zero_undef_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %vaddr) #1 {
  %vec = load i32, i32 addrspace(1)* %vaddr
  %trunc = call i32 @llvm.cttz.i32(i32 %vec, i1 true)
  store i32 %trunc, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: 'cttz_i64'
; GCN: estimated cost of 2 for {{.*}} call i64 @llvm.cttz.i64
define void @cttz_i64(i64 addrspace(1)* %out, i64 addrspace(1)* %vaddr) #1 {
  %vec = load i64, i64 addrspace(1)* %vaddr
  %trunc = call i64 @llvm.cttz.i64(i64 %vec, i1 false)
  store i64 %trunc, i64 addrspace(1)* %out
  ret void
}

; GCN-LABEL: 'cttz_zero_undef_i64'
; GCN: estimated cost of 2 for {{.*}} call i64 @llvm.cttz.i64
define void @cttz_zero_undef_i64(i64 addrspace(1)* %out, i64 addrspace(1)* %vaddr) #1 {
  %vec = load i64, i64 addrspace(1)* %vaddr
  %trunc = call i64 @llvm.cttz.i64(i64 %vec, i1 true)
  store i64 %trunc, i64 addrspace(1)* %out
  ret void
}

; GCN-LABEL: 'cttz_i8'
; CI: estimated cost of 1 for {{.*}} call i8 @llvm.cttz.i8
; VI: estimated cost of 2 for {{.*}} call i8 @llvm.cttz.i8
define void @cttz_i8(i8 addrspace(1)* %out, i8 addrspace(1)* %vaddr) #1 {
  %vec = load i8, i8 addrspace(1)* %vaddr
  %trunc = call i8 @llvm.cttz.i8(i8 %vec, i1 false)
  store i8 %trunc, i8 addrspace(1)* %out
  ret void
}

; GCN-LABEL: 'cttz_zero_undef_i8'
; CI: estimated cost of 1 for {{.*}} call i8 @llvm.cttz.i8
; VI: estimated cost of 2 for {{.*}} call i8 @llvm.cttz.i8
define void @cttz_zero_undef_i8(i8 addrspace(1)* %out, i8 addrspace(1)* %vaddr) #1 {
  %vec = load i8, i8 addrspace(1)* %vaddr
  %trunc = call i8 @llvm.cttz.i8(i8 %vec, i1 true)
  store i8 %trunc, i8 addrspace(1)* %out
  ret void
}

; GCN-LABEL: 'cttz_i16'
; CI: estimated cost of 1 for {{.*}} call i16 @llvm.cttz.i16
; VI: estimated cost of 2 for {{.*}} call i16 @llvm.cttz.i16
define void @cttz_i16(i16 addrspace(1)* %out, i16 addrspace(1)* %vaddr) #1 {
  %vec = load i16, i16 addrspace(1)* %vaddr
  %trunc = call i16 @llvm.cttz.i16(i16 %vec, i1 false)
  store i16 %trunc, i16 addrspace(1)* %out
  ret void
}

; GCN-LABEL: 'cttz_zero_undef_i16'
; CI: estimated cost of 1 for {{.*}} call i16 @llvm.cttz.i16
; VI: estimated cost of 2 for {{.*}} call i16 @llvm.cttz.i16
define void @cttz_zero_undef_i16(i16 addrspace(1)* %out, i16 addrspace(1)* %vaddr) #1 {
  %vec = load i16, i16 addrspace(1)* %vaddr
  %trunc = call i16 @llvm.cttz.i16(i16 %vec, i1 true)
  store i16 %trunc, i16 addrspace(1)* %out
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
