; RUN: llc -march=amdgcn -mcpu=tahiti -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s

declare i32 @llvm.amdgcn.umed3(i32, i32, i32) #0

; GCN-LABEL: {{^}}test_umed3:
; GCN: v_med3_u32 v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
define void @test_umed3(i32 addrspace(1)* %out, i32 %src0, i32 %src1, i32 %src2) #1 {
  %med3 = call i32 @llvm.amdgcn.umed3(i32 %src0, i32 %src1, i32 %src2)
  store i32 %med3, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}test_umed3_known_bits_zext:
; GCN: v_med3_u32 [[RESULT:v[0-9]+]], s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
; GCN-NEXT: buffer_store_dword [[RESULT]]
define void @test_umed3_known_bits_zext(i32 addrspace(1)* %out, i16 zeroext %src0, i16 zeroext %src1, i16 zeroext %src2) #1 {
  %src0.ext = zext i16 %src0 to i32
  %src1.ext = zext i16 %src1 to i32
  %src2.ext = zext i16 %src2 to i32
  %med3 = call i32 @llvm.amdgcn.umed3(i32 %src0.ext, i32 %src1.ext, i32 %src2.ext)
  %trunc = and i32 %med3, 65535
  store i32 %trunc, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}test_umed3_known_sign_bits_sext_in_reg:
; GCN: v_med3_u32 [[RESULT:v[0-9]+]], s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
; GCN-NEXT: buffer_store_dword [[RESULT]]
define void @test_umed3_known_sign_bits_sext_in_reg(i32 addrspace(1)* %out, i16 signext %src0, i16 signext %src1, i16 signext %src2) #1 {
  %src0.ext = sext i16 %src0 to i32
  %src1.ext = sext i16 %src1 to i32
  %src2.ext = sext i16 %src2 to i32
  %med3 = call i32 @llvm.amdgcn.umed3(i32 %src0.ext, i32 %src1.ext, i32 %src2.ext)
  %shl = shl i32 %med3, 16
  %sext.in.reg = ashr i32 %shl, 16
  store i32 %sext.in.reg, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}test_umed3_known_2_bits:
; GCN: v_med3_u32 [[RESULT:v[0-9]+]], s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
; GCN-NEXT: buffer_store_dword [[RESULT]]
define void @test_umed3_known_2_bits(i32 addrspace(1)* %out, i32 %src0, i32 %src1, i32 zeroext %src2) #1 {

  %shl0 = shl i32 %src0, 30
  %src0.new = lshr i32 %shl0, 30

  %shl1 = shl i32 %src1, 30
  %src1.new = lshr i32 %shl1, 30

  %shl2 = shl i32 %src2, 30
  %src2.new = lshr i32 %shl2, 30

  %med3 = call i32 @llvm.amdgcn.umed3(i32 %src0.new, i32 %src1.new, i32 %src2.new)
  %trunc = and i32 %med3, 3
  store i32 %trunc, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}test_umed3_known_bits_zext_unknown_src0:
; GCN: v_med3_u32 [[MED3:v[0-9]+]], s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
; GCN: v_and_b32_e32 [[RESULT:v[0-9]+]], 0xffff, [[MED3]]
; GCN: buffer_store_dword [[RESULT]]
define void @test_umed3_known_bits_zext_unknown_src0(i32 addrspace(1)* %out, i32 %src0, i16 zeroext %src1, i16 zeroext %src2) #0 {
  %src1.ext = zext i16 %src1 to i32
  %src2.ext = zext i16 %src2 to i32
  %med3 = call i32 @llvm.amdgcn.umed3(i32 %src0, i32 %src1.ext, i32 %src2.ext)
  %trunc = and i32 %med3, 65535
  store i32 %trunc, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}test_umed3_known_bits_zext_unknown_src1:
; GCN: v_med3_u32 [[MED3:v[0-9]+]], s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
; GCN: v_and_b32_e32 [[RESULT:v[0-9]+]], 0xffff, [[MED3]]
; GCN: buffer_store_dword [[RESULT]]
define void @test_umed3_known_bits_zext_unknown_src1(i32 addrspace(1)* %out, i16 zeroext %src0, i32 %src1, i16 zeroext %src2) #1 {
  %src0.ext = zext i16 %src0 to i32
  %src2.ext = zext i16 %src2 to i32
  %med3 = call i32 @llvm.amdgcn.umed3(i32 %src0.ext, i32 %src1, i32 %src2.ext)
  %trunc = and i32 %med3, 65535
  store i32 %trunc, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}test_umed3_known_bits_zext_unknown_src2:
; GCN: v_med3_u32 [[MED3:v[0-9]+]], s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
; GCN: v_and_b32_e32 [[RESULT:v[0-9]+]], 0xffff, [[MED3]]
; GCN: buffer_store_dword [[RESULT]]
define void @test_umed3_known_bits_zext_unknown_src2(i32 addrspace(1)* %out, i16 zeroext %src0, i16 zeroext %src1, i32 %src2) #1 {
  %src0.ext = zext i16 %src0 to i32
  %src1.ext = zext i16 %src1 to i32
  %med3 = call i32 @llvm.amdgcn.umed3(i32 %src0.ext, i32 %src1.ext, i32 %src2)
  %trunc = and i32 %med3, 65535
  store i32 %trunc, i32 addrspace(1)* %out
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
