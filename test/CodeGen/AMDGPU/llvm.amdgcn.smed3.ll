; RUN: llc -march=amdgcn -mcpu=tahiti -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s

declare i32 @llvm.amdgcn.smed3(i32, i32, i32) #0

; GCN-LABEL: {{^}}test_smed3:
; GCN: v_med3_i32 v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
define void @test_smed3(i32 addrspace(1)* %out, i32 %src0, i32 %src1, i32 %src2) #1 {
  %med3 = call i32 @llvm.amdgcn.smed3(i32 %src0, i32 %src1, i32 %src2)
  store i32 %med3, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}test_smed3_num_sign_bits:
; GCN: v_med3_i32 [[RESULT:v[0-9]+]], s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
; GCN-NEXT: buffer_store_dword [[RESULT]]
define void @test_smed3_num_sign_bits(i32 addrspace(1)* %out, i32 %src0, i32 %src1, i32 zeroext %src2) #1 {

  %shl0 = shl i32 %src0, 16
  %src0.new = ashr i32 %shl0, 16

  %shl1 = shl i32 %src1, 17
  %src1.new = ashr i32 %shl1, 17

  %shl2 = shl i32 %src2, 18
  %src2.new = ashr i32 %shl2, 18

  %med3 = call i32 @llvm.amdgcn.smed3(i32 %src0.new, i32 %src1.new, i32 %src2.new)

  %shl = shl i32 %med3, 16
  %sra = ashr i32 %shl, 16
  store i32 %sra, i32 addrspace(1)* %out
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
