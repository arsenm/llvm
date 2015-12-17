; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa < %s | FileCheck -check-prefix=GCN %s

; GCN: 'store_global_i32'
; GCN: estimated cost of 5 for {{.*}} store i32
define void @store_global_i32(i32 addrspace(1)* %out) #0 {
  store i32 0, i32 addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v2i32'
; GCN: estimated cost of 5 for {{.*}} store <2 x i32>
define void @store_global_v2i32(<2 x i32> addrspace(1)* %out) #0 {
  store <2 x i32> zeroinitializer, <2 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v3i32'
; GCN: estimated cost of 5 for {{.*}} store <3 x i32>
define void @store_global_v3i32(<3 x i32> addrspace(1)* %out) #0 {
  store <3 x i32> zeroinitializer, <3 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v4i32'
; GCN: estimated cost of 5 for {{.*}} store <4 x i32>
define void @store_global_v4i32(<4 x i32> addrspace(1)* %out) #0 {
  store <4 x i32> zeroinitializer, <4 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v8i32'
; GCN: estimated cost of 10 for {{.*}} store <8 x i32>
define void @store_global_v8i32(<8 x i32> addrspace(1)* %out) #0 {
  store <8 x i32> zeroinitializer, <8 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v16i32'
; GCN: estimated cost of 20 for {{.*}} store <16 x i32>
define void @store_global_v16i32(<16 x i32> addrspace(1)* %out) #0 {
  store <16 x i32> zeroinitializer, <16 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v32i32'
; GCN: estimated cost of 40 for {{.*}} store <32 x i32>
define void @store_global_v32i32(<32 x i32> addrspace(1)* %out) #0 {
  store <32 x i32> zeroinitializer, <32 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v64i32'
; GCN: estimated cost of 80 for {{.*}} store <64 x i32>
define void @store_global_v64i32(<64 x i32> addrspace(1)* %out) #0 {
  store <64 x i32> zeroinitializer, <64 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_i8'
; GCN: estimated cost of 5 for {{.*}} store i8
define void @store_global_i8(i8 addrspace(1)* %out) #0 {
  store i8 0, i8 addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v4i8'
; GCN: estimated cost of 20 for {{.*}} store <4 x i8>
define void @store_global_v4i8(<4 x i8> addrspace(1)* %out) #0 {
  store <4 x i8> zeroinitializer, <4 x i8> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_i16'
; GCN: estimated cost of 5 for {{.*}} store i16
define void @store_global_i16(i16 addrspace(1)* %out) #0 {
  store i16 0, i16 addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v4i16'
; GCN: estimated cost of 20 for {{.*}} store <4 x i16>
define void @store_global_v4i16(<4 x i16> addrspace(1)* %out) #0 {
  store <4 x i16> zeroinitializer, <4 x i16> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v8i16'
; GCN: estimated cost of 40 for {{.*}} store <8 x i16>
define void @store_global_v8i16(<8 x i16> addrspace(1)* %out) #0 {
  store <8 x i16> zeroinitializer, <8 x i16> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_i64'
; GCN: estimated cost of 5 for {{.*}} store i64
define void @store_global_i64(i64 addrspace(1)* %out) #0 {
  store i64 0, i64 addrspace(1)* %out
  ret void
}

; GCN: 'store_global_i64_align_1'
; GCN: estimated cost of 5 for {{.*}} store i64
define void @store_global_i64_align_1(i64 addrspace(1)* %out) #0 {
  store i64 0, i64 addrspace(1)* %out, align 1
  ret void
}

; GCN: 'store_global_v2i64'
; GCN: estimated cost of 5 for {{.*}} store <2 x i64>
define void @store_global_v2i64(<2 x i64> addrspace(1)* %out) #0 {
  store <2 x i64> zeroinitializer, <2 x i64> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v2i64_align_1'
; GCN: estimated cost of 5 for {{.*}} store <2 x i64>
define void @store_global_v2i64_align_1(<2 x i64> addrspace(1)* %out) #0 {
  store <2 x i64> zeroinitializer, <2 x i64> addrspace(1)* %out, align 1
  ret void
}

; GCN: 'store_global_v3i64'
; GCN: estimated cost of 10 for {{.*}} store <3 x i64>
define void @store_global_v3i64(<3 x i64> addrspace(1)* %out) #0 {
  store <3 x i64> zeroinitializer, <3 x i64> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v4i64'
; GCN: estimated cost of 10 for {{.*}} store <4 x i64>
define void @store_global_v4i64(<4 x i64> addrspace(1)* %out) #0 {
  store <4 x i64> zeroinitializer, <4 x i64> addrspace(1)* %out
  ret void
}

; GCN: 'store_global_v8i64'
; GCN: estimated cost of 20 for {{.*}} store <8 x i64>
define void @store_global_v8i64(<8 x i64> addrspace(1)* %out) #0 {
  store <8 x i64> zeroinitializer, <8 x i64> addrspace(1)* %out
  ret void
}

; GCN: 'store_local_i32'
; GCN: estimated cost of 3 for {{.*}} store i32
define void @store_local_i32(i32 addrspace(3)* %out) #0 {
  store i32 0, i32 addrspace(3)* %out
  ret void
}

; GCN: 'store_local_i32_align_1'
; GCN: estimated cost of 12 for {{.*}} store i32
define void @store_local_i32_align_1(i32 addrspace(3)* %out) #0 {
  store i32 0, i32 addrspace(3)* %out, align 1
  ret void
}

; GCN: 'store_local_i32_align_2'
; GCN: estimated cost of 6 for {{.*}} store i32
define void @store_local_i32_align_2(i32 addrspace(3)* %out) #0 {
  store i32 0, i32 addrspace(3)* %out, align 2
  ret void
}

; GCN: 'store_local_v2i32'
; GCN: estimated cost of 3 for {{.*}} store <2 x i32>
define void @store_local_v2i32(<2 x i32> addrspace(3)* %out) #0 {
  store <2 x i32> zeroinitializer, <2 x i32> addrspace(3)* %out
  ret void
}

; GCN: 'store_local_v3i32'
; GCN: estimated cost of 6 for {{.*}} store <3 x i32>
define void @store_local_v3i32(<3 x i32> addrspace(3)* %out) #0 {
  store <3 x i32> zeroinitializer, <3 x i32> addrspace(3)* %out
  ret void
}

; GCN: 'store_local_v4i32'
; GCN: estimated cost of 6 for {{.*}} store <4 x i32>
define void @store_local_v4i32(<4 x i32> addrspace(3)* %out) #0 {
  store <4 x i32> zeroinitializer, <4 x i32> addrspace(3)* %out
  ret void
}

; GCN: 'store_local_v8i32'
; GCN: estimated cost of 12 for {{.*}} store <8 x i32>
define void @store_local_v8i32(<8 x i32> addrspace(3)* %out) #0 {
  store <8 x i32> zeroinitializer, <8 x i32> addrspace(3)* %out
  ret void
}

; GCN: 'store_local_v16i32'
; GCN: estimated cost of 24 for {{.*}} store <16 x i32>
define void @store_local_v16i32(<16 x i32> addrspace(3)* %out) #0 {
  store <16 x i32> zeroinitializer, <16 x i32> addrspace(3)* %out
  ret void
}

; GCN: 'store_local_v32i32'
; GCN: estimated cost of 48 for {{.*}} store <32 x i32>
define void @store_local_v32i32(<32 x i32> addrspace(3)* %out) #0 {
  store <32 x i32> zeroinitializer, <32 x i32> addrspace(3)* %out
  ret void
}

; GCN: 'store_local_i8'
; GCN: estimated cost of 3 for {{.*}} store i8
define void @store_local_i8(i8 addrspace(3)* %out) #0 {
  store i8 0, i8 addrspace(3)* %out
  ret void
}

; GCN: 'store_local_v4i8'
; GCN: estimated cost of 12 for {{.*}} store <4 x i8>
define void @store_local_v4i8(<4 x i8> addrspace(3)* %out) #0 {
  store <4 x i8> zeroinitializer, <4 x i8> addrspace(3)* %out
  ret void
}

; GCN: 'store_local_v4i8_align_1'
; GCN: estimated cost of 12 for {{.*}} store <4 x i8>
define void @store_local_v4i8_align_1(<4 x i8> addrspace(3)* %out) #0 {
  store <4 x i8> zeroinitializer, <4 x i8> addrspace(3)* %out, align 1
  ret void
}

; GCN: 'store_local_v4i8_align_2'
; GCN: estimated cost of 12 for {{.*}} store <4 x i8>
define void @store_local_v4i8_align_2(<4 x i8> addrspace(3)* %out) #0 {
  store <4 x i8> zeroinitializer, <4 x i8> addrspace(3)* %out, align 2
  ret void
}

; GCN: 'store_local_i16'
; GCN: estimated cost of 3 for {{.*}} store i16
define void @store_local_i16(i16 addrspace(3)* %out) #0 {
  store i16 0, i16 addrspace(3)* %out
  ret void
}

; GCN: 'store_local_i16_align_4'
; GCN: estimated cost of 3 for {{.*}} store i16
define void @store_local_i16_align_4(i16 addrspace(3)* %out) #0 {
  store i16 0, i16 addrspace(3)* %out, align 4
  ret void
}

; GCN: 'store_local_v4i16'
; GCN: estimated cost of 12 for {{.*}} store <4 x i16>
define void @store_local_v4i16(<4 x i16> addrspace(3)* %out) #0 {
  store <4 x i16> zeroinitializer, <4 x i16> addrspace(3)* %out
  ret void
}

; GCN: 'store_local_v8i16'
; GCN: estimated cost of 24 for {{.*}} store <8 x i16>
define void @store_local_v8i16(<8 x i16> addrspace(3)* %out) #0 {
  store <8 x i16> zeroinitializer, <8 x i16> addrspace(3)* %out
  ret void
}

; GCN: 'store_local_i64'
; GCN: estimated cost of 3 for {{.*}} store i64
define void @store_local_i64(i64 addrspace(3)* %out) #0 {
  store i64 0, i64 addrspace(3)* %out
  ret void
}

; GCN: 'store_local_i64_align_1'
; GCN: estimated cost of 24 for {{.*}} store i64
define void @store_local_i64_align_1(i64 addrspace(3)* %out) #0 {
  store i64 0, i64 addrspace(3)* %out, align 1
  ret void
}

; GCN: 'store_local_i64_align_2'
; GCN: estimated cost of 12 for {{.*}} store i64
define void @store_local_i64_align_2(i64 addrspace(3)* %out) #0 {
  store i64 0, i64 addrspace(3)* %out, align 2
  ret void
}

; GCN: 'store_local_v2i64'
; GCN: estimated cost of 6 for {{.*}} store <2 x i64>
define void @store_local_v2i64(<2 x i64> addrspace(3)* %out) #0 {
  store <2 x i64> zeroinitializer, <2 x i64> addrspace(3)* %out
  ret void
}

; GCN: 'store_local_v2i64_align_1'
; GCN: estimated cost of 48 for {{.*}} store <2 x i64>
define void @store_local_v2i64_align_1(<2 x i64> addrspace(3)* %out) #0 {
  store <2 x i64> zeroinitializer, <2 x i64> addrspace(3)* %out, align 1
  ret void
}

; GCN: 'store_local_v2i64_align_2'
; GCN: estimated cost of 24 for {{.*}} store <2 x i64>
define void @store_local_v2i64_align_2(<2 x i64> addrspace(3)* %out) #0 {
  store <2 x i64> zeroinitializer, <2 x i64> addrspace(3)* %out, align 2
  ret void
}

; GCN: 'store_local_v3i64'
; GCN: estimated cost of 9 for {{.*}} store <3 x i64>
define void @store_local_v3i64(<3 x i64> addrspace(3)* %out) #0 {
  store <3 x i64> zeroinitializer, <3 x i64> addrspace(3)* %out
  ret void
}

; GCN: 'store_local_v4i64'
; GCN: estimated cost of 12 for {{.*}} store <4 x i64>
define void @store_local_v4i64(<4 x i64> addrspace(3)* %out) #0 {
  store <4 x i64> zeroinitializer, <4 x i64> addrspace(3)* %out
  ret void
}

; GCN: 'store_local_v8i64'
; GCN: estimated cost of 24 for {{.*}} store <8 x i64>
define void @store_local_v8i64(<8 x i64> addrspace(3)* %out) #0 {
  store <8 x i64> zeroinitializer, <8 x i64> addrspace(3)* %out
  ret void
}


; GCN: 'load_constant_i32'
; GCN: estimated cost of 2 for {{.*}} load i32
define void @load_constant_i32(i32 addrspace(1)* %out, i32 addrspace(2)* %in) #0 {
  %val = load i32, i32 addrspace(2)* %in
  store i32 %val, i32 addrspace(1)* %out
  ret void
}

; GCN: 'load_constant_i32_align_2'
; GCN: estimated cost of 5 for {{.*}} load i32
define void @load_constant_i32_align_2(i32 addrspace(1)* %out, i32 addrspace(2)* %in) #0 {
  %val = load i32, i32 addrspace(2)* %in, align 2
  store i32 %val, i32 addrspace(1)* %out
  ret void
}

; GCN: 'load_constant_i32_align_1'
; GCN: estimated cost of 5 for {{.*}} load i32
define void @load_constant_i32_align_1(i32 addrspace(1)* %out, i32 addrspace(2)* %in) #0 {
  %val = load i32, i32 addrspace(2)* %in, align 1
  store i32 %val, i32 addrspace(1)* %out
  ret void
}

; GCN: 'load_constant_i8'
; GCN: estimated cost of 5 for {{.*}} load i8
define void @load_constant_i8(i8 addrspace(1)* %out, i8 addrspace(2)* %in) #0 {
  %val = load i8, i8 addrspace(2)* %in
  store i8 %val, i8 addrspace(1)* %out
  ret void
}

; GCN: 'load_constant_i8_align_4'
; GCN: estimated cost of 5 for {{.*}} load i8
define void @load_constant_i8_align_4(i8 addrspace(1)* %out, i8 addrspace(2)* %in) #0 {
  %val = load i8, i8 addrspace(2)* %in, align 4
  store i8 %val, i8 addrspace(1)* %out
  ret void
}

; FIXME: This currently is actually using buffer instructions on the scalarized vector.

; GCN: 'load_constant_v4i8'
; GCN: estimated cost of 8 for {{.*}} load <4 x i8>
define void @load_constant_v4i8(<4 x i8> addrspace(1)* %out, <4 x i8> addrspace(2)* %in) #0 {
  %val = load <4 x i8>, <4 x i8> addrspace(2)* %in
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out
  ret void
}

; GCN: 'load_constant_v4i32'
; GCN: estimated cost of 2 for {{.*}} load <4 x i32>
define void @load_constant_v4i32(<4 x i32> addrspace(1)* %out, <4 x i32> addrspace(2)* %in) #0 {
  %val = load <4 x i32>, <4 x i32> addrspace(2)* %in
  store <4 x i32> %val, <4 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'load_constant_v4i32_align_4'
; GCN: estimated cost of 2 for {{.*}} load <4 x i32>
define void @load_constant_v4i32_align_4(<4 x i32> addrspace(1)* %out, <4 x i32> addrspace(2)* %in) #0 {
  %val = load <4 x i32>, <4 x i32> addrspace(2)* %in, align 4
  store <4 x i32> %val, <4 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'load_constant_v4i32_align_1'
; GCN: estimated cost of 5 for {{.*}} load <4 x i32>
define void @load_constant_v4i32_align_1(<4 x i32> addrspace(1)* %out, <4 x i32> addrspace(2)* %in) #0 {
  %val = load <4 x i32>, <4 x i32> addrspace(2)* %in, align 1
  store <4 x i32> %val, <4 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'load_constant_v8i32'
; GCN: estimated cost of 2 for {{.*}} load <8 x i32>
define void @load_constant_v8i32(<8 x i32> addrspace(1)* %out, <8 x i32> addrspace(2)* %in) #0 {
  %val = load <8 x i32>, <8 x i32> addrspace(2)* %in
  store <8 x i32> %val, <8 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'load_constant_v16i32'
; GCN: estimated cost of 2 for {{.*}} load <16 x i32>
define void @load_constant_v16i32(<16 x i32> addrspace(1)* %out, <16 x i32> addrspace(2)* %in) #0 {
  %val = load <16 x i32>, <16 x i32> addrspace(2)* %in
  store <16 x i32> %val, <16 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'load_constant_v32i32'
; GCN: estimated cost of 4 for {{.*}} load <32 x i32>
define void @load_constant_v32i32(<32 x i32> addrspace(1)* %out, <32 x i32> addrspace(2)* %in) #0 {
  %val = load <32 x i32>, <32 x i32> addrspace(2)* %in
  store <32 x i32> %val, <32 x i32> addrspace(1)* %out
  ret void
}

; GCN: 'store_private_i8'
; GCN: estimated cost of 5 for {{.*}} store i8
define void @store_private_i8(i8* %out) #0 {
  store i8 0, i8* %out
  ret void
}

; GCN: 'store_private_i16'
; GCN: estimated cost of 5 for {{.*}} store i16
define void @store_private_i16(i16* %out) #0 {
  store i16 0, i16* %out
  ret void
}

; GCN: 'store_private_i32'
; GCN: estimated cost of 5 for {{.*}} store i32
define void @store_private_i32(i32* %out) #0 {
  store i32 0, i32* %out
  ret void
}

; GCN: 'store_private_v2i32'
; GCN: estimated cost of 10 for {{.*}} store <2 x i32>
define void @store_private_v2i32(<2 x i32>* %out) #0 {
  store <2 x i32> zeroinitializer, <2 x i32>* %out
  ret void
}

; GCN: 'store_private_v3i32'
; GCN: estimated cost of 15 for {{.*}} store <3 x i32>
define void @store_private_v3i32(<3 x i32>* %out) #0 {
  store <3 x i32> zeroinitializer, <3 x i32>* %out
  ret void
}

; GCN: 'store_private_v4i32'
; GCN: estimated cost of 20 for {{.*}} store <4 x i32>
define void @store_private_v4i32(<4 x i32>* %out) #0 {
  store <4 x i32> zeroinitializer, <4 x i32>* %out
  ret void
}

; GCN: 'store_private_v8i32'
; GCN: estimated cost of 40 for {{.*}} store <8 x i32>
define void @store_private_v8i32(<8 x i32>* %out) #0 {
  store <8 x i32> zeroinitializer, <8 x i32>* %out
  ret void
}

; GCN: 'store_private_v16i32'
; GCN: estimated cost of 80 for {{.*}} store <16 x i32>
define void @store_private_v16i32(<16 x i32>* %out) #0 {
  store <16 x i32> zeroinitializer, <16 x i32>* %out
  ret void
}

; GCN: 'store_private_v4i8'
; GCN: estimated cost of 5 for {{.*}} store <4 x i8>
define void @store_private_v4i8(<4 x i8>* %out) #0 {
  store <4 x i8> zeroinitializer, <4 x i8>* %out
  ret void
}

; GCN: 'store_private_v3i8'
; GCN: estimated cost of 5 for {{.*}} store <3 x i8>
define void @store_private_v3i8(<3 x i8>* %out) #0 {
  store <3 x i8> zeroinitializer, <3 x i8>* %out
  ret void
}

attributes #0 = { nounwind }
