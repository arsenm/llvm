; RUN: llc -march=amdgcn -mcpu=tahiti -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s

declare i32 @llvm.amdgcn.umulhi24(i32, i32) #0

; GCN-LABEL: {{^}}test_umulhi24:
; GCN: v_mul_hi_u32_u24
define void @test_umulhi24(i32 addrspace(1)* %out, i32 %src0, i32 %src1) #1 {
  %mul = call i32 @llvm.amdgcn.umulhi24(i32 %src0, i32 %src1)
  store i32 %mul, i32 addrspace(1)* %out, align 4
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
