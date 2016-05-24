; RUN: llc < %s -mtriple=amdgcn--amdhsa -mcpu=kaveri | FileCheck --check-prefix=GCN %s
; RUN: llc < %s -mtriple=amdgcn--amdhsa -mcpu=fiji | FileCheck --check-prefix=GCN %s

; If flat_store_dword and flat_load_dword use different registers for the data
; operand, this test is not broken.  It just means it is no longer testing
; for the original bug.

; GCN-LABEL: {{^}}global_test:
; GCN: flat_store_dword v[{{[0-9]+:[0-9]+}}],
; GCN: s_waitcnt vmcnt(0){{$}}
; GCN: flat_load_dword

; Test pointer problem
; XGCN: flat_store_dword v[{{[0-9]+:[0-9]+}}], [[DATA:v[0-9]+]]
; XGCN: s_waitcnt vmcnt(0) lgkmcnt(0)
; XGCN: flat_load_dword [[DATA]], v[{{[0-9]+:[0-9]+}}]
define void @global_test(i32 addrspace(1)* %out, i32 %in) {
  store volatile i32 0, i32 addrspace(1)* %out
  %val = load volatile i32, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}flat_test:
; GCN: flat_store_dword v[{{[0-9]+:[0-9]+}}],
; GCN: s_waitcnt vmcnt(0) lgkmcnt(0){{$}}
; GCN: flat_load_dword
define void @flat_test(i32 addrspace(4)* %out, i32 %in) {
  store volatile i32 0, i32 addrspace(4)* %out
  %val = load volatile i32, i32 addrspace(4)* %out
  ret void
}

; If the store is not through a generic pointer, the lgkmcnt is not
; needed.

; GCN-LABEL: {{^}}global_flat_test:
; GCN: flat_store_dword v[{{[0-9]+:[0-9]+}}],
; GCN: s_waitcnt vmcnt(0){{$}}
; GCN: flat_load_dword
define void @global_flat_test(i32 addrspace(1)* %out, i32 %in) {
  store volatile i32 0, i32 addrspace(1)* %out
  %out.cast = addrspacecast i32 addrspace(1)* %out to i32 addrspace(4)*
  %val = load volatile i32, i32 addrspace(4)* %out.cast
  ret void
}

; GCN-LABEL: {{^}}flat_global_test:
; GCN: flat_store_dword v[{{[0-9]+:[0-9]+}}],
; GCN: s_waitcnt vmcnt(0) lgkmcnt(0){{$}}
; GCN: flat_load_dword
define void @flat_global_test(i32 addrspace(1)* %out, i32 %in) {
  %out.cast = addrspacecast i32 addrspace(1)* %out to i32 addrspace(4)*
  store volatile i32 0, i32 addrspace(4)* %out.cast
  %val = load volatile i32, i32 addrspace(1)* %out
  ret void
}
