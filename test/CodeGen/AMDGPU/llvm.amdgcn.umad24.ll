; RUN: llc -march=amdgcn -mcpu=tahiti -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=SI %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=VI %s

declare i32 @llvm.amdgcn.umad24(i32, i32, i32) #0
declare i32 @llvm.r600.read.tidig.x() #0

; GCN-LABEL: {{^}}test_umad24:
; GCN: v_mad_u32_u24
define void @test_umad24(i32 addrspace(1)* %out, i32 %src0, i32 %src1, i32 %src2) #1 {
  %mad = call i32 @llvm.amdgcn.umad24(i32 %src0, i32 %src1, i32 %src2)
  store i32 %mad, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}commute_umad24:
; SI-DAG: buffer_load_dword [[SRC0:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64{{$}}
; SI-DAG: buffer_load_dword [[SRC2:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64 offset:4

; VI: flat_load_dword [[SRC0:v[0-9]+]]
; VI: flat_load_dword [[SRC2:v[0-9]+]]

; GCN: v_mad_u32_u24 [[RESULT:v[0-9]+]], 4, [[SRC0]], [[SRC2]]
; GCN: {{buffer|flat}}_store_dword [[RESULT]]
define void @commute_umad24(i32 addrspace(1)* %out, i32 addrspace(1)* %in) #1 {
  %tid = call i32 @llvm.r600.read.tidig.x() nounwind readnone
  %out.gep = getelementptr i32, i32 addrspace(1)* %out, i32 %tid
  %src0.gep = getelementptr i32, i32 addrspace(1)* %out, i32 %tid
  %src2.gep = getelementptr i32, i32 addrspace(1)* %src0.gep, i32 1

  %src0 = load i32, i32 addrspace(1)* %src0.gep
  %src2 = load i32, i32 addrspace(1)* %src2.gep
  %mad = call i32 @llvm.amdgcn.umad24(i32 %src0, i32 4, i32 %src2)
  store i32 %mad, i32 addrspace(1)* %out.gep
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
