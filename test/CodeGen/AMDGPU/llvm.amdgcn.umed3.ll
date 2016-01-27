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

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
