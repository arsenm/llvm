; RUN: llc -O0 -march=amdgcn -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=MOVREL  %s
; RUN: llc -O0 -march=amdgcn -mcpu=tonga -mattr=-flat-for-global -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=MOVREL %s
; RUN: llc -O0 -march=amdgcn -mcpu=tonga -mattr=-flat-for-global -amdgpu-vgpr-index-mode -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=IDXMODE %s

; FIXME: Merge into indirect-addressing-si.ll

; Make sure that TwoAddressInstructions keeps src0 as subregister sub0
; of the tied implicit use and def of the super register.

; GCN-LABEL: {{^}}insert_wo_offset:
; GCN: s_mov_b32 m0, -1
; GCN-DAG: s_mov_b32 [[NEG1:s[0-9]+]], -1
; GCN-DAG: s_load_dword [[IN:s[0-9]+]]

; MOVREL: s_mov_b32 m0, [[IN]]
; MOVREL-NEXT: v_movreld_b32_e32 v[[ELT0:[0-9]+]]

; IDXMODE: s_set_gpr_idx_on [[IN]], dst
; IDXMODE-NEXT: v_mov_b32_e32 v[[ELT0:[0-9]+]], v
; IDXMODE-NEXT: s_set_gpr_idx_off

; GCN-NEXT: s_mov_b32 m0, [[NEG1]]
; GCN-NEXT: buffer_store_dwordx4 v{{\[}}[[ELT0]]:
define void @insert_wo_offset(<4 x float> addrspace(1)* %out, i32 %in) #0 {
entry:
  %ins = insertelement <4 x float> <float 1.0, float 2.0, float 3.0, float 4.0>, float 5.0, i32 %in
  store <4 x float> %ins, <4 x float> addrspace(1)* %out
  ret void
}

attributes #0 = { nounwind }
