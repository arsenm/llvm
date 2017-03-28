; RUN: llc -march=amdgcn -mcpu=fiji -mattr=-flat-for-global -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefix=GCN -check-prefix=VI %s
; RUN: llc -march=amdgcn -mcpu=hawaii -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefix=GCN -check-prefix=CI %s
; RUN: llc -march=amdgcn -mcpu=gfx900 -mattr=-flat-for-global -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefix=GCN -check-prefix=GFX9 -check-prefix=VI %s

; GCN-LABEL: {{^}}requires_32_vgprs:
; GCN-NOT: s[0:3]
; GCN-NOT: s5
; GCN: NumVgprs: 32
define void @requires_32_vgprs() #0 {
  %val0 = load volatile i32, i32 addrspace(1)* undef
  %val1 = load volatile i32, i32 addrspace(1)* undef
  %val2 = load volatile i32, i32 addrspace(1)* undef
  %val3 = load volatile i32, i32 addrspace(1)* undef
  %val4 = load volatile i32, i32 addrspace(1)* undef
  %val5 = load volatile i32, i32 addrspace(1)* undef
  %val6 = load volatile i32, i32 addrspace(1)* undef
  %val7 = load volatile i32, i32 addrspace(1)* undef
  %val8 = load volatile i32, i32 addrspace(1)* undef
  %val9 = load volatile i32, i32 addrspace(1)* undef
  %val10 = load volatile i32, i32 addrspace(1)* undef
  %val11 = load volatile i32, i32 addrspace(1)* undef
  %val12 = load volatile i32, i32 addrspace(1)* undef
  %val13 = load volatile i32, i32 addrspace(1)* undef
  %val14 = load volatile i32, i32 addrspace(1)* undef
  %val15 = load volatile i32, i32 addrspace(1)* undef
  %val16 = load volatile i32, i32 addrspace(1)* undef
  %val17 = load volatile i32, i32 addrspace(1)* undef
  %val18 = load volatile i32, i32 addrspace(1)* undef
  %val19 = load volatile i32, i32 addrspace(1)* undef
  %val20 = load volatile i32, i32 addrspace(1)* undef
  %val21 = load volatile i32, i32 addrspace(1)* undef
  %val22 = load volatile i32, i32 addrspace(1)* undef
  %val23 = load volatile i32, i32 addrspace(1)* undef
  %val24 = load volatile i32, i32 addrspace(1)* undef
  %val25 = load volatile i32, i32 addrspace(1)* undef
  %val26 = load volatile i32, i32 addrspace(1)* undef
  %val27 = load volatile i32, i32 addrspace(1)* undef
  %val28 = load volatile i32, i32 addrspace(1)* undef
  %val29 = load volatile i32, i32 addrspace(1)* undef
  %val30 = load volatile i32, i32 addrspace(1)* undef
  %val31 = load volatile i32, i32 addrspace(1)* undef
  %val32 = load volatile i32, i32 addrspace(1)* undef

  store volatile i32 %val0, i32 addrspace(1)* undef
  store volatile i32 %val1, i32 addrspace(1)* undef
  store volatile i32 %val2, i32 addrspace(1)* undef
  store volatile i32 %val3, i32 addrspace(1)* undef
  store volatile i32 %val4, i32 addrspace(1)* undef
  store volatile i32 %val5, i32 addrspace(1)* undef
  store volatile i32 %val6, i32 addrspace(1)* undef
  store volatile i32 %val7, i32 addrspace(1)* undef
  store volatile i32 %val8, i32 addrspace(1)* undef
  store volatile i32 %val9, i32 addrspace(1)* undef
  store volatile i32 %val10, i32 addrspace(1)* undef
  store volatile i32 %val11, i32 addrspace(1)* undef
  store volatile i32 %val12, i32 addrspace(1)* undef
  store volatile i32 %val13, i32 addrspace(1)* undef
  store volatile i32 %val14, i32 addrspace(1)* undef
  store volatile i32 %val15, i32 addrspace(1)* undef
  store volatile i32 %val16, i32 addrspace(1)* undef
  store volatile i32 %val17, i32 addrspace(1)* undef
  store volatile i32 %val18, i32 addrspace(1)* undef
  store volatile i32 %val19, i32 addrspace(1)* undef
  store volatile i32 %val20, i32 addrspace(1)* undef
  store volatile i32 %val21, i32 addrspace(1)* undef
  store volatile i32 %val22, i32 addrspace(1)* undef
  store volatile i32 %val23, i32 addrspace(1)* undef
  store volatile i32 %val25, i32 addrspace(1)* undef
  store volatile i32 %val26, i32 addrspace(1)* undef
  store volatile i32 %val27, i32 addrspace(1)* undef
  store volatile i32 %val28, i32 addrspace(1)* undef
  store volatile i32 %val29, i32 addrspace(1)* undef
  store volatile i32 %val30, i32 addrspace(1)* undef
  store volatile i32 %val31, i32 addrspace(1)* undef
  store volatile i32 %val32, i32 addrspace(1)* undef
  ret void
}

; GCN-LABEL: {{^}}requires_33_vgprs:
; GCN: buffer_load_dword v{{[0-9]+}}, off, s[0:3], s5 offset:4 ; 4-byte Folded Reload
; GCN: NumVgprs: 32
define void @requires_33_vgprs() #0 {
  %val0 = load volatile i32, i32 addrspace(1)* undef
  %val1 = load volatile i32, i32 addrspace(1)* undef
  %val2 = load volatile i32, i32 addrspace(1)* undef
  %val3 = load volatile i32, i32 addrspace(1)* undef
  %val4 = load volatile i32, i32 addrspace(1)* undef
  %val5 = load volatile i32, i32 addrspace(1)* undef
  %val6 = load volatile i32, i32 addrspace(1)* undef
  %val7 = load volatile i32, i32 addrspace(1)* undef
  %val8 = load volatile i32, i32 addrspace(1)* undef
  %val9 = load volatile i32, i32 addrspace(1)* undef
  %val10 = load volatile i32, i32 addrspace(1)* undef
  %val11 = load volatile i32, i32 addrspace(1)* undef
  %val12 = load volatile i32, i32 addrspace(1)* undef
  %val13 = load volatile i32, i32 addrspace(1)* undef
  %val14 = load volatile i32, i32 addrspace(1)* undef
  %val15 = load volatile i32, i32 addrspace(1)* undef
  %val16 = load volatile i32, i32 addrspace(1)* undef
  %val17 = load volatile i32, i32 addrspace(1)* undef
  %val18 = load volatile i32, i32 addrspace(1)* undef
  %val19 = load volatile i32, i32 addrspace(1)* undef
  %val20 = load volatile i32, i32 addrspace(1)* undef
  %val21 = load volatile i32, i32 addrspace(1)* undef
  %val22 = load volatile i32, i32 addrspace(1)* undef
  %val23 = load volatile i32, i32 addrspace(1)* undef
  %val24 = load volatile i32, i32 addrspace(1)* undef
  %val25 = load volatile i32, i32 addrspace(1)* undef
  %val26 = load volatile i32, i32 addrspace(1)* undef
  %val27 = load volatile i32, i32 addrspace(1)* undef
  %val28 = load volatile i32, i32 addrspace(1)* undef
  %val29 = load volatile i32, i32 addrspace(1)* undef
  %val30 = load volatile i32, i32 addrspace(1)* undef
  %val31 = load volatile i32, i32 addrspace(1)* undef
  %val32 = load volatile i32, i32 addrspace(1)* undef

  store volatile i32 %val0, i32 addrspace(1)* undef
  store volatile i32 %val1, i32 addrspace(1)* undef
  store volatile i32 %val2, i32 addrspace(1)* undef
  store volatile i32 %val3, i32 addrspace(1)* undef
  store volatile i32 %val4, i32 addrspace(1)* undef
  store volatile i32 %val5, i32 addrspace(1)* undef
  store volatile i32 %val6, i32 addrspace(1)* undef
  store volatile i32 %val7, i32 addrspace(1)* undef
  store volatile i32 %val8, i32 addrspace(1)* undef
  store volatile i32 %val9, i32 addrspace(1)* undef
  store volatile i32 %val10, i32 addrspace(1)* undef
  store volatile i32 %val11, i32 addrspace(1)* undef
  store volatile i32 %val12, i32 addrspace(1)* undef
  store volatile i32 %val13, i32 addrspace(1)* undef
  store volatile i32 %val14, i32 addrspace(1)* undef
  store volatile i32 %val15, i32 addrspace(1)* undef
  store volatile i32 %val16, i32 addrspace(1)* undef
  store volatile i32 %val17, i32 addrspace(1)* undef
  store volatile i32 %val18, i32 addrspace(1)* undef
  store volatile i32 %val19, i32 addrspace(1)* undef
  store volatile i32 %val20, i32 addrspace(1)* undef
  store volatile i32 %val21, i32 addrspace(1)* undef
  store volatile i32 %val22, i32 addrspace(1)* undef
  store volatile i32 %val23, i32 addrspace(1)* undef
  store volatile i32 %val24, i32 addrspace(1)* undef
  store volatile i32 %val25, i32 addrspace(1)* undef
  store volatile i32 %val26, i32 addrspace(1)* undef
  store volatile i32 %val27, i32 addrspace(1)* undef
  store volatile i32 %val28, i32 addrspace(1)* undef
  store volatile i32 %val29, i32 addrspace(1)* undef
  store volatile i32 %val30, i32 addrspace(1)* undef
  store volatile i32 %val31, i32 addrspace(1)* undef
  store volatile i32 %val32, i32 addrspace(1)* undef
  ret void
}

; first 5 are reserved for scratch + 1 for SP, +1 for FP, +2 for
; return address + 23 values

; GCN-LABEL: {{^}}requires_32_sgprs:
; GCN-NOT: writelane
; GCN-NOT: readlane
; GCN-NOT: s_store
; GCN: NumSgprs: 32
; GCN: NumVgprs: 0
define void @requires_32_sgprs() #0 {
  %ptr = load i32 addrspace(2)*, i32 addrspace(2)* addrspace(2)* undef
  %val0 = load volatile i32, i32 addrspace(2)* %ptr
  %val1 = load volatile i32, i32 addrspace(2)* %ptr
  %val2 = load volatile i32, i32 addrspace(2)* %ptr
  %val3 = load volatile i32, i32 addrspace(2)* %ptr
  %val4 = load volatile i32, i32 addrspace(2)* %ptr
  %val5 = load volatile i32, i32 addrspace(2)* %ptr
  %val6 = load volatile i32, i32 addrspace(2)* %ptr
  %val7 = load volatile i32, i32 addrspace(2)* %ptr
  %val8 = load volatile i32, i32 addrspace(2)* %ptr
  %val9 = load volatile i32, i32 addrspace(2)* %ptr
  %val10 = load volatile i32, i32 addrspace(2)* %ptr
  %val11 = load volatile i32, i32 addrspace(2)* %ptr
  %val12 = load volatile i32, i32 addrspace(2)* %ptr
  %val13 = load volatile i32, i32 addrspace(2)* %ptr
  %val14 = load volatile i32, i32 addrspace(2)* %ptr
  %val15 = load volatile i32, i32 addrspace(2)* %ptr
  %val16 = load volatile i32, i32 addrspace(2)* %ptr
  %val17 = load volatile i32, i32 addrspace(2)* %ptr
  %val18 = load volatile i32, i32 addrspace(2)* %ptr
  %val19 = load volatile i32, i32 addrspace(2)* %ptr
  %val20 = load volatile i32, i32 addrspace(2)* %ptr
  %val21 = load volatile i32, i32 addrspace(2)* %ptr
  %val22 = load volatile i32, i32 addrspace(2)* %ptr

  call void asm sideeffect "; use $0", "s"(i32 %val0)
  call void asm sideeffect "; use $0", "s"(i32 %val1)
  call void asm sideeffect "; use $0", "s"(i32 %val2)
  call void asm sideeffect "; use $0", "s"(i32 %val3)
  call void asm sideeffect "; use $0", "s"(i32 %val4)
  call void asm sideeffect "; use $0", "s"(i32 %val5)
  call void asm sideeffect "; use $0", "s"(i32 %val6)
  call void asm sideeffect "; use $0", "s"(i32 %val7)
  call void asm sideeffect "; use $0", "s"(i32 %val8)
  call void asm sideeffect "; use $0", "s"(i32 %val9)
  call void asm sideeffect "; use $0", "s"(i32 %val10)
  call void asm sideeffect "; use $0", "s"(i32 %val11)
  call void asm sideeffect "; use $0", "s"(i32 %val12)
  call void asm sideeffect "; use $0", "s"(i32 %val13)
  call void asm sideeffect "; use $0", "s"(i32 %val14)
  call void asm sideeffect "; use $0", "s"(i32 %val15)
  call void asm sideeffect "; use $0", "s"(i32 %val16)
  call void asm sideeffect "; use $0", "s"(i32 %val17)
  call void asm sideeffect "; use $0", "s"(i32 %val18)
  call void asm sideeffect "; use $0", "s"(i32 %val19)
  call void asm sideeffect "; use $0", "s"(i32 %val20)
  call void asm sideeffect "; use $0", "s"(i32 %val21)
  call void asm sideeffect "; use $0", "s"(i32 %val22)
  ret void
}

; GCN-LABEL: {{^}}requires_33_sgprs_no_sp:
; GCN: v_writelane_b32 v0, s33, 0
; GCN: v_readlane_b32 s33, v0, 0
; GCN-NEXT: s_setpc_b64
; GCN: NumSgprs: 36
; GCN: NumVgprs: 1
define void @requires_33_sgprs_no_sp() #0 {
  %ptr = load i32 addrspace(2)*, i32 addrspace(2)* addrspace(2)* undef
  %val0 = load volatile i32, i32 addrspace(2)* %ptr
  %val1 = load volatile i32, i32 addrspace(2)* %ptr
  %val2 = load volatile i32, i32 addrspace(2)* %ptr
  %val3 = load volatile i32, i32 addrspace(2)* %ptr
  %val4 = load volatile i32, i32 addrspace(2)* %ptr
  %val5 = load volatile i32, i32 addrspace(2)* %ptr
  %val6 = load volatile i32, i32 addrspace(2)* %ptr
  %val7 = load volatile i32, i32 addrspace(2)* %ptr
  %val8 = load volatile i32, i32 addrspace(2)* %ptr
  %val9 = load volatile i32, i32 addrspace(2)* %ptr
  %val10 = load volatile i32, i32 addrspace(2)* %ptr
  %val11 = load volatile i32, i32 addrspace(2)* %ptr
  %val12 = load volatile i32, i32 addrspace(2)* %ptr
  %val13 = load volatile i32, i32 addrspace(2)* %ptr
  %val14 = load volatile i32, i32 addrspace(2)* %ptr
  %val15 = load volatile i32, i32 addrspace(2)* %ptr
  %val16 = load volatile i32, i32 addrspace(2)* %ptr
  %val17 = load volatile i32, i32 addrspace(2)* %ptr
  %val18 = load volatile i32, i32 addrspace(2)* %ptr
  %val19 = load volatile i32, i32 addrspace(2)* %ptr
  %val20 = load volatile i32, i32 addrspace(2)* %ptr
  %val21 = load volatile i32, i32 addrspace(2)* %ptr
  %val22 = load volatile i32, i32 addrspace(2)* %ptr
  %val23 = load volatile i32, i32 addrspace(2)* %ptr
  %val24 = load volatile i32, i32 addrspace(2)* %ptr
  %val25 = load volatile i32, i32 addrspace(2)* %ptr

  call void asm sideeffect "; use $0", "s"(i32 %val0)
  call void asm sideeffect "; use $0", "s"(i32 %val1)
  call void asm sideeffect "; use $0", "s"(i32 %val2)
  call void asm sideeffect "; use $0", "s"(i32 %val3)
  call void asm sideeffect "; use $0", "s"(i32 %val4)
  call void asm sideeffect "; use $0", "s"(i32 %val5)
  call void asm sideeffect "; use $0", "s"(i32 %val6)
  call void asm sideeffect "; use $0", "s"(i32 %val7)
  call void asm sideeffect "; use $0", "s"(i32 %val8)
  call void asm sideeffect "; use $0", "s"(i32 %val9)
  call void asm sideeffect "; use $0", "s"(i32 %val10)
  call void asm sideeffect "; use $0", "s"(i32 %val11)
  call void asm sideeffect "; use $0", "s"(i32 %val12)
  call void asm sideeffect "; use $0", "s"(i32 %val13)
  call void asm sideeffect "; use $0", "s"(i32 %val14)
  call void asm sideeffect "; use $0", "s"(i32 %val15)
  call void asm sideeffect "; use $0", "s"(i32 %val16)
  call void asm sideeffect "; use $0", "s"(i32 %val17)
  call void asm sideeffect "; use $0", "s"(i32 %val18)
  call void asm sideeffect "; use $0", "s"(i32 %val19)
  call void asm sideeffect "; use $0", "s"(i32 %val20)
  call void asm sideeffect "; use $0", "s"(i32 %val21)
  call void asm sideeffect "; use $0", "s"(i32 %val22)
  call void asm sideeffect "; use $0", "s"(i32 %val23)
  call void asm sideeffect "; use $0", "s"(i32 %val24)
  call void asm sideeffect "; use $0", "s"(i32 %val25)
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { nounwind noinline }
