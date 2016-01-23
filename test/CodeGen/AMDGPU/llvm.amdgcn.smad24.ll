; RUN: llc -march=amdgcn -mcpu=tahiti -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=GCN  %s

declare i32 @llvm.amdgcn.smad24(i32, i32, i32) #0

; GCN-LABEL: {{^}}test_smad24:
; GCN: v_mad_i32_i24
define void @test_smad24(i32 addrspace(1)* %out, i32 %src0, i32 %src1, i32 %src2) #1 {
  %mad = call i32 @llvm.amdgcn.smad24(i32 %src0, i32 %src1, i32 %src2)
  store i32 %mad, i32 addrspace(1)* %out
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
