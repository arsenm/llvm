; RUN: llc -march=amdgcn -mcpu=tahiti -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s

declare i32 @llvm.amdgcn.umul24(i32, i32) #0

; GCN-LABEL: {{^}}test_umul24:
; GCN: v_mul_u32_u24
define void @test_umul24(i32 addrspace(1)* %out, i32 %src0, i32 %src1) #1 {
  %mul = call i32 @llvm.amdgcn.umul24(i32 %src0, i32 %src1)
  store i32 %mul, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}test_umul24_to_umad24_combine:
; GCN: v_mad_u32_u24
define void @test_umul24_to_umad24_combine(i32 addrspace(1)* %out, i32 %src0, i32 %src1, i32 %src2) nounwind {
  %mul = call i32 @llvm.amdgcn.umul24(i32 %src0, i32 %src1)
  %add = add i32 %mul, %src2
  store i32 %add, i32 addrspace(1)* %out
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
