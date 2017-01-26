; RUN: opt -S -instcombine %s | FileCheck %s

target datalayout = "p:64:64:32-i64:64:32-a0:32-n32:64"

%unsized = type {}

; CHECK: @lds_align8 = internal unnamed_addr addrspace(3) global [256 x i64] undef, align 8
; CHECK: @lds_align4 = internal unnamed_addr addrspace(3) global [256 x i64] undef, align 4
; CHECK: @lds_align1 = internal unnamed_addr addrspace(3) global [256 x i64] undef, align 4
; CHECK: @lds_noalign = internal unnamed_addr addrspace(3) global [256 x i64] undef
; CHECK: @extern_lds_align8 = unnamed_addr addrspace(3) global [256 x i64] undef, align 8
; CHECK: @extern_lds_align4 = unnamed_addr addrspace(3) global [256 x i64] undef, align 4
; CHECK: @extern_lds_align1 = unnamed_addr addrspace(3) global [256 x i64] undef, align 1
; CHECK: @extern_lds_noalign = unnamed_addr addrspace(3) global [256 x i64] undef
; CHECK: @const_array_i64 = addrspace(2) constant [12 x i64] [i64 2, i64 9, i64 4, i64 22, i64 2, i64 9, i64 4, i64 22, i64 2, i64 9, i64 4, i64 22]

declare void @use.i64(i64)
declare void @use.p0i64(i64* align 1)
declare void @use.p0.ptr(%unsized* align 1)
declare void @use.p3i64(i64 addrspace(3)* align 1)
declare void @llvm.memcpy.p0i8.p2i8.i64(i8*, i8 addrspace(2)* %s, i64, i32, i1)

; The alloca must have at least the ABI alignment in case it is passed to a call
; CHECK-LABEL: @adjust_alloca_align_i64(
; CHECK: %alloca = alloca i64, align 8
define void @adjust_alloca_align_i64() {
  %alloca = alloca i64
  call void @use.p0i64(i64* %alloca)
  ret void
}

; CHECK-LABEL: @adjust_alloca_align_size0(
; CHECK: %alloca = alloca %unsized, align 4
define void @adjust_alloca_align_size0() {
  %alloca = alloca %unsized
  call void @use.p0.ptr(%unsized* %alloca)
  ret void
}
; CHECK-LABEL @store_alloca_i64(
; CHECK: %alloca0 = alloca i64, align 8
; CHECK: %alloca1 = alloca i64, align 4
; CHECK: %alloca4 = alloca i64, align 4
; CHECK: %alloca8 = alloca i64, align 8

; CHECK: store i64 123, i64* %alloca0, align 8
; CHECK: store i64 123, i64* %alloca1, align 4
; CHECK: store i64 123, i64* %alloca4, align 4
; CHECK: store i64 123, i64* %alloca8, align 8
define void @store_alloca_i64() {
  %alloca0 = alloca i64
  %alloca1 = alloca i64, align 1
  %alloca4 = alloca i64, align 4
  %alloca8 = alloca i64, align 8

  store i64 123, i64* %alloca0
  call void @use.p0i64(i64* %alloca0)

  store i64 123, i64* %alloca1, align 1
  call void @use.p0i64(i64* %alloca1)

  store i64 123, i64* %alloca4
  call void @use.p0i64(i64* %alloca4)

  store i64 123, i64* %alloca8
  call void @use.p0i64(i64* %alloca8)

  ret void
}

@lds_align8 = internal unnamed_addr addrspace(3) global [256 x i64] undef, align 8
@lds_align4 = internal unnamed_addr addrspace(3) global [256 x i64] undef, align 4
@lds_align1 = internal unnamed_addr addrspace(3) global [256 x i64] undef, align 1
@lds_noalign = internal unnamed_addr addrspace(3) global [256 x i64] undef

@extern_lds_align8 = unnamed_addr addrspace(3) global [256 x i64] undef, align 8
@extern_lds_align4 = unnamed_addr addrspace(3) global [256 x i64] undef, align 4
@extern_lds_align1 = unnamed_addr addrspace(3) global [256 x i64] undef, align 1
@extern_lds_noalign = unnamed_addr addrspace(3) global [256 x i64] undef

; CHECK-LABEL: @store_global_i64(
; CHECK: store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align8, i64 0, i64 0), align 8
; CHECK: store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align4, i64 0, i64 0), align 4
; CHECK: store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align1, i64 0, i64 0), align 4
; CHECK: store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_noalign, i64 0, i64 0), align 16

; CHECK: store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align8, i64 0, i64 0), align 8
; CHECK: store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align4, i64 0, i64 0), align 4
; CHECK: store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align1, i64 0, i64 0), align 1
; CHECK: store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_noalign, i64 0, i64 0), align 16

define void @store_global_i64() {
  store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align8, i64 0, i64 0)
  call void @use.p3i64(i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align8, i64 0, i64 0))

  store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align4, i64 0, i64 0), align 4
  call void @use.p3i64(i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align4, i64 0, i64 0))

  store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align1, i64 0, i64 0), align 1
  call void @use.p3i64(i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align1, i64 0, i64 0))

  store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_noalign, i64 0, i64 0)
  call void @use.p3i64(i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_noalign, i64 0, i64 0))

  store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align8, i64 0, i64 0)
  call void @use.p3i64(i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align8, i64 0, i64 0))

  store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align4, i64 0, i64 0), align 4
  call void @use.p3i64(i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align4, i64 0, i64 0))

  store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align1, i64 0, i64 0), align 1
  call void @use.p3i64(i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align1, i64 0, i64 0))

  store i64 123, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_noalign, i64 0, i64 0)
  call void @use.p3i64(i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_noalign, i64 0, i64 0))

  ret void
}

; CHECK-LABEL: @load_global_i64(
; CHECK: load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align8, i64 0, i64 0), align 8
; CHECK: load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align4, i64 0, i64 0), align 4
; CHECK: load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align1, i64 0, i64 0), align 4
; CHECK: load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_noalign, i64 0, i64 0), align 16

; CHECK: load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align8, i64 0, i64 0), align 8
; CHECK: load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align4, i64 0, i64 0), align 4
; CHECK: load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align1, i64 0, i64 0), align 1
; CHECK: load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_noalign, i64 0, i64 0), align 16
define void @load_global_i64() {
  %val0 = load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align8, i64 0, i64 0)
  call void @use.i64(i64 %val0)

  %val1 = load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align4, i64 0, i64 0), align 4
  call void @use.i64(i64 %val1)

  %val2 = load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_align1, i64 0, i64 0), align 1
  call void @use.i64(i64 %val2)

  %val3 = load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @lds_noalign, i64 0, i64 0)
  call void @use.i64(i64 %val3)

  %val4 = load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align8, i64 0, i64 0)
  call void @use.i64(i64 %val4)

  %val5 = load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align4, i64 0, i64 0), align 4
  call void @use.i64(i64 %val5)

  %val6 = load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_align1, i64 0, i64 0), align 1
  call void @use.i64(i64 %val6)

  %val7 = load i64, i64 addrspace(3)* getelementptr inbounds ([256 x i64], [256 x i64] addrspace(3)* @extern_lds_noalign, i64 0, i64 0)
  call void @use.i64(i64 %val7)

  ret void
}

@const_array_i64 = addrspace(2) constant [12 x i64] [i64 2, i64 9, i64 4, i64 22, i64 2, i64 9, i64 4, i64 22, i64 2, i64 9, i64 4, i64 22]

; Must use ABI alignment, may increase to 8
; CHECK-LABEL: @memcpy_from_global_align_i64(
; CHECK: %alloca = alloca [12 x i64], align 8
; CHECK: call void @llvm.memcpy.p0i8.p2i8.i64(i8* %cast.alloca, i8 addrspace(2)* bitcast ([12 x i64] addrspace(2)* @const_array_i64 to i8 addrspace(2)*), i64 96, i32 8, i1 false)
define void @memcpy_from_global_align_i64() {
  %alloca = alloca [12 x i64]
  %cast.alloca = bitcast [12 x i64]* %alloca to i8*
  %cast.const = bitcast [12 x i64] addrspace(2)* @const_array_i64 to i8 addrspace(2)*
  call void @llvm.memcpy.p0i8.p2i8.i64(i8* %cast.alloca, i8 addrspace(2)* %cast.const, i64 96, i32 1, i1 false)
  %cast.alloca.1 = bitcast [12 x i64]* %alloca to i64*
  call void @use.p0i64(i64* %cast.alloca.1)
  ret void
}

declare i32 @memcmp(i8*, i8*, i32)

; CHECK-LABEL: @test_simplify_memcpy_lowalign(
; CHECK: %cmp = icmp eq i64 %x, %y
; CHECK-NEXT: ret i1 %cmp
define i1 @test_simplify_memcpy_lowalign(i64 %x, i64 %y) {
  %x.addr = alloca i64, align 4
  %y.addr = alloca i64, align 4
  store i64 %x, i64* %x.addr, align 4
  store i64 %y, i64* %y.addr, align 4
  %xptr = bitcast i64* %x.addr to i8*
  %yptr = bitcast i64* %y.addr to i8*
  %call = call i32 @memcmp(i8* %xptr, i8* %yptr, i32 8)
  %cmp = icmp eq i32 %call, 0
  ret i1 %cmp
}
