; RUN: llc -march=amdgcn -mcpu=SI -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s

declare float @llvm.amdgcn.fmed3(float, float, float) #0

; GCN-LABEL: {{^}}test_fmed3:
; GCN: v_med3_f32 v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
define void @test_fmed3(float addrspace(1)* %out, float %src0, float %src1, float %src2) #1 {
  %mad = call float @llvm.amdgcn.fmed3(float %src0, float %src1, float %src2)
  store float %mad, float addrspace(1)* %out
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
