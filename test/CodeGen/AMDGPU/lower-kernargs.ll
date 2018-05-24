; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -mtriple=amdgcn-amd-amdhsa -S -o - -amdgpu-lower-kernel-arguments %s | FileCheck -check-prefix=HSA %s
; RUN: opt -mtriple=amdgcn-- -S -o - -amdgpu-lower-kernel-arguments %s | FileCheck -check-prefix=MESA %s

define amdgpu_kernel void @kern_i8(i8 %arg) nounwind {
; HSA-LABEL: @kern_i8(
; HSA-NEXT:    [[KERN_I8_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(1) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; HSA-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(4)* [[KERN_I8_KERNARG_SEGMENT]] to [[KERN_I8:%.*]] addrspace(4)*
; HSA-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[KERN_I8]], [[KERN_I8]] addrspace(4)* [[TMP2]], i32 0, i32 0
; HSA-NEXT:    [[ARG:%.*]] = load i8, i8 addrspace(4)* [[TMP3]], align 256, !invariant.load !0
; HSA-NEXT:    store i8 [[ARG]], i8 addrspace(1)* undef, align 4
; HSA-NEXT:    ret void
;
; MESA-LABEL: @kern_i8(
; MESA-NEXT:    [[KERN_I8_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(1) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; MESA-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i8, i8 addrspace(4)* [[KERN_I8_KERNARG_SEGMENT]], i64 36
; MESA-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(4)* [[TMP2]] to [[KERN_I8:%.*]] addrspace(4)*
; MESA-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[KERN_I8]], [[KERN_I8]] addrspace(4)* [[TMP3]], i32 0, i32 0
; MESA-NEXT:    [[ARG:%.*]] = load i8, i8 addrspace(4)* [[TMP4]], align 4, !invariant.load !0
; MESA-NEXT:    store i8 [[ARG]], i8 addrspace(1)* undef, align 4
; MESA-NEXT:    ret void
;
  store i8 %arg, i8 addrspace(1)* undef, align 1
  ret void
}

define amdgpu_kernel void @kern_i16(i16 %arg) nounwind {
  store i16 %arg, i16 addrspace(1)* undef, align 1
  ret void
}

define amdgpu_kernel void @kern_f16(half %arg) nounwind {
  store half %arg, half addrspace(1)* undef, align 1
  ret void
}

define amdgpu_kernel void @kern_i8_i8(i8 %arg0, i8 %arg1) {
; HSA-LABEL: @kern_i8_i8(
; HSA-NEXT:    [[KERN_I8_I8_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(2) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; HSA-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(4)* [[KERN_I8_I8_KERNARG_SEGMENT]] to [[KERN_I8_I8:%.*]] addrspace(4)*
; HSA-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[KERN_I8_I8]], [[KERN_I8_I8]] addrspace(4)* [[TMP3]], i32 0, i32 0
; HSA-NEXT:    [[ARG0:%.*]] = load i8, i8 addrspace(4)* [[TMP4]], align 256, !invariant.load !0
; HSA-NEXT:    [[TMP5:%.*]] = getelementptr inbounds [[KERN_I8_I8]], [[KERN_I8_I8]] addrspace(4)* [[TMP3]], i32 0, i32 1
; HSA-NEXT:    [[ARG1:%.*]] = load i8, i8 addrspace(4)* [[TMP5]], align 1, !invariant.load !0
; HSA-NEXT:    store volatile i8 [[ARG0]], i8 addrspace(1)* undef, align 4
; HSA-NEXT:    store volatile i8 [[ARG1]], i8 addrspace(1)* undef, align 4
; HSA-NEXT:    ret void
;
; MESA-LABEL: @kern_i8_i8(
; MESA-NEXT:    [[KERN_I8_I8_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(2) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; MESA-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i8, i8 addrspace(4)* [[KERN_I8_I8_KERNARG_SEGMENT]], i64 36
; MESA-NEXT:    [[TMP4:%.*]] = bitcast i8 addrspace(4)* [[TMP3]] to [[KERN_I8_I8:%.*]] addrspace(4)*
; MESA-NEXT:    [[TMP5:%.*]] = getelementptr inbounds [[KERN_I8_I8]], [[KERN_I8_I8]] addrspace(4)* [[TMP4]], i32 0, i32 0
; MESA-NEXT:    [[ARG0:%.*]] = load i8, i8 addrspace(4)* [[TMP5]], align 4, !invariant.load !0
; MESA-NEXT:    [[TMP6:%.*]] = getelementptr inbounds [[KERN_I8_I8]], [[KERN_I8_I8]] addrspace(4)* [[TMP4]], i32 0, i32 1
; MESA-NEXT:    [[ARG1:%.*]] = load i8, i8 addrspace(4)* [[TMP6]], align 1, !invariant.load !0
; MESA-NEXT:    store volatile i8 [[ARG0]], i8 addrspace(1)* undef, align 4
; MESA-NEXT:    store volatile i8 [[ARG1]], i8 addrspace(1)* undef, align 4
; MESA-NEXT:    ret void
;
  store volatile i8 %arg0, i8 addrspace(1)* undef, align 1
  store volatile i8 %arg1, i8 addrspace(1)* undef, align 1
  ret void
}

define amdgpu_kernel void @kern_v3i8(<3 x i8> %arg) {
; HSA-LABEL: @kern_v3i8(
; HSA-NEXT:    [[KERN_V3I8_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(4) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; HSA-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(4)* [[KERN_V3I8_KERNARG_SEGMENT]] to [[KERN_V3I8:%.*]] addrspace(4)*
; HSA-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[KERN_V3I8]], [[KERN_V3I8]] addrspace(4)* [[TMP2]], i32 0, i32 0
; HSA-NEXT:    [[ARG:%.*]] = load <3 x i8>, <3 x i8> addrspace(4)* [[TMP3]], align 256, !invariant.load !0
; HSA-NEXT:    store <3 x i8> [[ARG]], <3 x i8> addrspace(1)* undef, align 4
; HSA-NEXT:    ret void
;
; MESA-LABEL: @kern_v3i8(
; MESA-NEXT:    [[KERN_V3I8_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(4) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; MESA-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i8, i8 addrspace(4)* [[KERN_V3I8_KERNARG_SEGMENT]], i64 36
; MESA-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(4)* [[TMP2]] to [[KERN_V3I8:%.*]] addrspace(4)*
; MESA-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[KERN_V3I8]], [[KERN_V3I8]] addrspace(4)* [[TMP3]], i32 0, i32 0
; MESA-NEXT:    [[ARG:%.*]] = load <3 x i8>, <3 x i8> addrspace(4)* [[TMP4]], align 4, !invariant.load !0
; MESA-NEXT:    store <3 x i8> [[ARG]], <3 x i8> addrspace(1)* undef, align 4
; MESA-NEXT:    ret void
;
  store <3 x i8> %arg, <3 x i8> addrspace(1)* undef, align 4
  ret void
}

define amdgpu_kernel void @kern_i24(i24 %arg0) {
; HSA-LABEL: @kern_i24(
; HSA-NEXT:    [[KERN_I24_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(4) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; HSA-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(4)* [[KERN_I24_KERNARG_SEGMENT]] to [[KERN_I24:%.*]] addrspace(4)*
; HSA-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[KERN_I24]], [[KERN_I24]] addrspace(4)* [[TMP2]], i32 0, i32 0
; HSA-NEXT:    [[ARG0:%.*]] = load i24, i24 addrspace(4)* [[TMP3]], align 256, !invariant.load !0
; HSA-NEXT:    store i24 [[ARG0]], i24 addrspace(1)* undef
; HSA-NEXT:    ret void
;
; MESA-LABEL: @kern_i24(
; MESA-NEXT:    [[KERN_I24_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(4) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; MESA-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i8, i8 addrspace(4)* [[KERN_I24_KERNARG_SEGMENT]], i64 36
; MESA-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(4)* [[TMP2]] to [[KERN_I24:%.*]] addrspace(4)*
; MESA-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[KERN_I24]], [[KERN_I24]] addrspace(4)* [[TMP3]], i32 0, i32 0
; MESA-NEXT:    [[ARG0:%.*]] = load i24, i24 addrspace(4)* [[TMP4]], align 4, !invariant.load !0
; MESA-NEXT:    store i24 [[ARG0]], i24 addrspace(1)* undef
; MESA-NEXT:    ret void
;
  store i24 %arg0, i24 addrspace(1)* undef
  ret void
}

define amdgpu_kernel void @kern_i32(i32 %arg0) {
  store i32 %arg0, i32 addrspace(1)* undef
  ret void
}

define amdgpu_kernel void @kern_f32(float %arg0) {
  store float %arg0, float addrspace(1)* undef
  ret void
}

define amdgpu_kernel void @kern_v3i32(<3 x i32> %arg0) {
; HSA-LABEL: @kern_v3i32(
; HSA-NEXT:    [[KERN_V3I32_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(16) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; HSA-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(4)* [[KERN_V3I32_KERNARG_SEGMENT]] to [[KERN_V3I32:%.*]] addrspace(4)*
; HSA-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[KERN_V3I32]], [[KERN_V3I32]] addrspace(4)* [[TMP2]], i32 0, i32 0
; HSA-NEXT:    [[ARG0:%.*]] = load <3 x i32>, <3 x i32> addrspace(4)* [[TMP3]], align 256, !invariant.load !0
; HSA-NEXT:    store <3 x i32> [[ARG0]], <3 x i32> addrspace(1)* undef, align 4
; HSA-NEXT:    ret void
;
; MESA-LABEL: @kern_v3i32(
; MESA-NEXT:    [[KERN_V3I32_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(16) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; MESA-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i8, i8 addrspace(4)* [[KERN_V3I32_KERNARG_SEGMENT]], i64 36
; MESA-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(4)* [[TMP2]] to [[KERN_V3I32:%.*]] addrspace(4)*
; MESA-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[KERN_V3I32]], [[KERN_V3I32]] addrspace(4)* [[TMP3]], i32 0, i32 0
; MESA-NEXT:    [[ARG0:%.*]] = load <3 x i32>, <3 x i32> addrspace(4)* [[TMP4]], align 4, !invariant.load !0
; MESA-NEXT:    store <3 x i32> [[ARG0]], <3 x i32> addrspace(1)* undef, align 4
; MESA-NEXT:    ret void
;
  store <3 x i32> %arg0, <3 x i32> addrspace(1)* undef, align 4
  ret void
}

define amdgpu_kernel void @kern_i32_v3i32(i32 %arg0, <3 x i32> %arg1) {
; HSA-LABEL: @kern_i32_v3i32(
; HSA-NEXT:    [[KERN_I32_V3I32_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(32) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; HSA-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(4)* [[KERN_I32_V3I32_KERNARG_SEGMENT]] to [[KERN_I32_V3I32:%.*]] addrspace(4)*
; HSA-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[KERN_I32_V3I32]], [[KERN_I32_V3I32]] addrspace(4)* [[TMP3]], i32 0, i32 0
; HSA-NEXT:    [[ARG0:%.*]] = load i32, i32 addrspace(4)* [[TMP4]], align 256, !invariant.load !0
; HSA-NEXT:    [[TMP5:%.*]] = getelementptr inbounds [[KERN_I32_V3I32]], [[KERN_I32_V3I32]] addrspace(4)* [[TMP3]], i32 0, i32 1
; HSA-NEXT:    [[ARG1:%.*]] = load <3 x i32>, <3 x i32> addrspace(4)* [[TMP5]], align 16, !invariant.load !0
; HSA-NEXT:    store i32 [[ARG0]], i32 addrspace(1)* undef
; HSA-NEXT:    store <3 x i32> [[ARG1]], <3 x i32> addrspace(1)* undef, align 4
; HSA-NEXT:    ret void
;
; MESA-LABEL: @kern_i32_v3i32(
; MESA-NEXT:    [[KERN_I32_V3I32_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(32) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; MESA-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i8, i8 addrspace(4)* [[KERN_I32_V3I32_KERNARG_SEGMENT]], i64 36
; MESA-NEXT:    [[TMP4:%.*]] = bitcast i8 addrspace(4)* [[TMP3]] to [[KERN_I32_V3I32:%.*]] addrspace(4)*
; MESA-NEXT:    [[TMP5:%.*]] = getelementptr inbounds [[KERN_I32_V3I32]], [[KERN_I32_V3I32]] addrspace(4)* [[TMP4]], i32 0, i32 0
; MESA-NEXT:    [[ARG0:%.*]] = load i32, i32 addrspace(4)* [[TMP5]], align 4, !invariant.load !0
; MESA-NEXT:    [[TMP6:%.*]] = getelementptr inbounds [[KERN_I32_V3I32]], [[KERN_I32_V3I32]] addrspace(4)* [[TMP4]], i32 0, i32 1
; MESA-NEXT:    [[ARG1:%.*]] = load <3 x i32>, <3 x i32> addrspace(4)* [[TMP6]], align 4, !invariant.load !0
; MESA-NEXT:    store i32 [[ARG0]], i32 addrspace(1)* undef
; MESA-NEXT:    store <3 x i32> [[ARG1]], <3 x i32> addrspace(1)* undef, align 4
; MESA-NEXT:    ret void
;
  store i32 %arg0, i32 addrspace(1)* undef
  store <3 x i32> %arg1, <3 x i32> addrspace(1)* undef, align 4
  ret void
}

%struct.a = type { i32, i8, [4 x i8] }
%struct.b.packed = type { i8, i32, [3 x i16], <2 x double> }

define amdgpu_kernel void @kern_struct_a(%struct.a %arg0) {
; HSA-LABEL: @kern_struct_a(
; HSA-NEXT:    [[KERN_STRUCT_A_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(12) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; HSA-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(4)* [[KERN_STRUCT_A_KERNARG_SEGMENT]] to [[KERN_STRUCT_A:%.*]] addrspace(4)*
; HSA-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[KERN_STRUCT_A]], [[KERN_STRUCT_A]] addrspace(4)* [[TMP2]], i32 0, i32 0
; HSA-NEXT:    [[ARG0:%.*]] = load [[STRUCT_A:%.*]], [[STRUCT_A]] addrspace(4)* [[TMP3]], align 256, !invariant.load !0
; HSA-NEXT:    store [[STRUCT_A]] %arg0, [[STRUCT_A]] addrspace(1)* undef
; HSA-NEXT:    ret void
;
; MESA-LABEL: @kern_struct_a(
; MESA-NEXT:    [[KERN_STRUCT_A_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(12) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; MESA-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i8, i8 addrspace(4)* [[KERN_STRUCT_A_KERNARG_SEGMENT]], i64 36
; MESA-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(4)* [[TMP2]] to [[KERN_STRUCT_A:%.*]] addrspace(4)*
; MESA-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[KERN_STRUCT_A]], [[KERN_STRUCT_A]] addrspace(4)* [[TMP3]], i32 0, i32 0
; MESA-NEXT:    [[ARG0:%.*]] = load [[STRUCT_A:%.*]], [[STRUCT_A]] addrspace(4)* [[TMP4]], align 4, !invariant.load !0
; MESA-NEXT:    store [[STRUCT_A]] %arg0, [[STRUCT_A]] addrspace(1)* undef
; MESA-NEXT:    ret void
;
  store %struct.a %arg0, %struct.a addrspace(1)* undef
  ret void
}

define amdgpu_kernel void @kern_struct_b_packed(%struct.b.packed %arg0) {
; HSA-LABEL: @kern_struct_b_packed(
; HSA-NEXT:    [[KERN_STRUCT_B_PACKED_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(32) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; HSA-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(4)* [[KERN_STRUCT_B_PACKED_KERNARG_SEGMENT]] to [[KERN_STRUCT_B_PACKED:%.*]] addrspace(4)*
; HSA-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[KERN_STRUCT_B_PACKED]], [[KERN_STRUCT_B_PACKED]] addrspace(4)* [[TMP2]], i32 0, i32 0
; HSA-NEXT:    [[ARG0:%.*]] = load [[STRUCT_B_PACKED:%.*]], [[STRUCT_B_PACKED]] addrspace(4)* [[TMP3]], align 256, !invariant.load !0
; HSA-NEXT:    store [[STRUCT_B_PACKED]] %arg0, [[STRUCT_B_PACKED]] addrspace(1)* undef
; HSA-NEXT:    ret void
;
; MESA-LABEL: @kern_struct_b_packed(
; MESA-NEXT:    [[KERN_STRUCT_B_PACKED_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(32) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; MESA-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i8, i8 addrspace(4)* [[KERN_STRUCT_B_PACKED_KERNARG_SEGMENT]], i64 36
; MESA-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(4)* [[TMP2]] to [[KERN_STRUCT_B_PACKED:%.*]] addrspace(4)*
; MESA-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[KERN_STRUCT_B_PACKED]], [[KERN_STRUCT_B_PACKED]] addrspace(4)* [[TMP3]], i32 0, i32 0
; MESA-NEXT:    [[ARG0:%.*]] = load [[STRUCT_B_PACKED:%.*]], [[STRUCT_B_PACKED]] addrspace(4)* [[TMP4]], align 4, !invariant.load !0
; MESA-NEXT:    store [[STRUCT_B_PACKED]] %arg0, [[STRUCT_B_PACKED]] addrspace(1)* undef
; MESA-NEXT:    ret void
;
  store %struct.b.packed %arg0, %struct.b.packed addrspace(1)* undef
  ret void
}

define amdgpu_kernel void @kern_implicit_arg_num_bytes(i32 %arg0) #0 {
; HSA-LABEL: @kern_implicit_arg_num_bytes(
; HSA-NEXT:    [[KERN_IMPLICIT_ARG_NUM_BYTES_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(48) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; HSA-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(4)* [[KERN_IMPLICIT_ARG_NUM_BYTES_KERNARG_SEGMENT]] to [[KERN_IMPLICIT_ARG_NUM_BYTES:%.*]] addrspace(4)*
; HSA-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[KERN_IMPLICIT_ARG_NUM_BYTES]], [[KERN_IMPLICIT_ARG_NUM_BYTES]] addrspace(4)* [[TMP2]], i32 0, i32 0
; HSA-NEXT:    [[ARG0:%.*]] = load i32, i32 addrspace(4)* [[TMP3]], align 256, !invariant.load !0
; HSA-NEXT:    store i32 [[ARG0]], i32 addrspace(1)* undef
; HSA-NEXT:    ret void
;
; MESA-LABEL: @kern_implicit_arg_num_bytes(
; MESA-NEXT:    [[KERN_IMPLICIT_ARG_NUM_BYTES_KERNARG_SEGMENT:%.*]] = call nonnull dereferenceable(44) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
; MESA-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i8, i8 addrspace(4)* [[KERN_IMPLICIT_ARG_NUM_BYTES_KERNARG_SEGMENT]], i64 36
; MESA-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(4)* [[TMP2]] to [[KERN_IMPLICIT_ARG_NUM_BYTES:%.*]] addrspace(4)*
; MESA-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[KERN_IMPLICIT_ARG_NUM_BYTES]], [[KERN_IMPLICIT_ARG_NUM_BYTES]] addrspace(4)* [[TMP3]], i32 0, i32 0
; MESA-NEXT:    [[ARG0:%.*]] = load i32, i32 addrspace(4)* [[TMP4]], align 4, !invariant.load !0
; MESA-NEXT:    store i32 [[ARG0]], i32 addrspace(1)* undef
; MESA-NEXT:    ret void
;
  store i32 %arg0, i32 addrspace(1)* undef
  ret void
}

attributes #0 = { "amdgpu-implicitarg-num-bytes"="40" }
