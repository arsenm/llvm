; RUN: llc -march=amdgcn -mcpu=tahiti -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=SI %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=VI %s

declare i32 @llvm.amdgcn.smul24(i32, i32) #0

; GCN-LABEL: {{^}}test_smul24:
; GCN: v_mul_i32_i24
define void @test_smul24(i32 addrspace(1)* %out, i32 %src0, i32 %src1) #1 {
  %mul = call i32 @llvm.amdgcn.smul24(i32 %src0, i32 %src1)
  store i32 %mul, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}test_smul24_to_smad24_combine:
; GCN: v_mad_i32_i24
define void @test_smul24_to_smad24_combine(i32 addrspace(1)* %out, i32 %src0, i32 %src1, i32 %src2) nounwind {
  %mul = call i32 @llvm.amdgcn.smul24(i32 %src0, i32 %src1)
  %add = add i32 %mul, %src2
  store i32 %add, i32 addrspace(1)* %out
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
