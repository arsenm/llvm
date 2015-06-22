; RUN: llc -march=amdgcn -mcpu=bonaire -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s

; Make sure something bad doesn't happen if there are adjacent loads through an addrspacecast
; GCN-LABEL: {{^}}merge_global_flat_load_2_i32_offset_0:
; GCN: buffer_load_dword v
; GCN: flat_load_dword v
; GCN: buffer_store_dword
define void @merge_global_flat_load_2_i32_offset_0(i32 addrspace(1)* %out, i32 addrspace(1)* %in) #0 {
entry:
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2

  %in.cast = addrspacecast i32 addrspace(1)* %in to i32 addrspace(4)*
  %in.gep.3 = getelementptr i32, i32 addrspace(4)* %in.cast, i32 3

  %ld.2 = load i32, i32 addrspace(1)* %in.gep.2
  %ld.3 = load i32, i32 addrspace(4)* %in.gep.3

  %add = add i32 %ld.2, %ld.3
  store i32 %add, i32 addrspace(1)* %out
  ret void
}

; Make sure something bad doesn't happen if there are adjacent loads through an addrspacecast
; GCN-LABEL: {{^}}merge_global_flat_load_2_i32_offset_1:
; GCN: buffer_load_dword v
; GCN: flat_load_dword v
; GCN: buffer_store_dword
define void @merge_global_flat_load_2_i32_offset_1(i32 addrspace(1)* %out, i32 addrspace(1)* %in) #0 {
entry:
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %in.gep.3.cast = addrspacecast i32 addrspace(1)* %in to i32 addrspace(4)*

  %ld.2 = load i32, i32 addrspace(1)* %in.gep.2
  %ld.3 = load i32, i32 addrspace(4)* %in.gep.3.cast

  %add = add i32 %ld.2, %ld.3
  store i32 %add, i32 addrspace(1)* %out
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { nounwind noduplicate convergent }