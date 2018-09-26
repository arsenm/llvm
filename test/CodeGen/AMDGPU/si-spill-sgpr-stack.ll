; RUN: not llc -march=amdgcn -mcpu=fiji -mattr=-flat-for-global -amdgpu-spill-sgpr-to-smem=0 -verify-machineinstrs < %s 2>&1 | FileCheck -check-prefix=ERROR %s
; RUN: llc -march=amdgcn -mcpu=fiji -mattr=-flat-for-global -amdgpu-spill-sgpr-to-smem=1 -verify-machineinstrs < %s | FileCheck -check-prefix=ALL -check-prefix=SMEM %s

; Previously, SGPR spilling to VGPRs was handled in a single register
; allocation run. It was possible to not have any free VGPRs for SGPR
; spilling, requiring writing out to memory which didn't work
; well. Test situations where this used to be necessary.

; ERROR: error: VGPRs for SGPR spilling limit exceeded (0) in test

; Make sure this doesn't crash.
; ALL-LABEL: {{^}}test:

; Initialize VGPR for spilling
; SGPR: ; implicit-def: $vgpr[[SPILL_VGPR:[0-9]+]]

; ALL-DAG: s_mov_b32 s[[LO:[0-9]+]], SCRATCH_RSRC_DWORD0
; ALL-DAG: s_mov_b32 s[[OFF:[0-9]+]], s3
; ALL-DAG: s_mov_b32 s[[HI:[0-9]+]], 0xe80000

; SGPR-DAG: v_writelane_b32 v[[SPILL_VGPR]], s{{[0-9]+}}, 0
; SGPR-DAG: v_writelane_b32 v[[SPILL_VGPR]], s{{[0-9]+}}, 1
; SGPR-DAG: v_writelane_b32 v[[SPILL_VGPR]], s{{[0-9]+}}, 2
; SGPR-DAG: v_writelane_b32 v[[SPILL_VGPR]], s{{[0-9]+}}, 3

; Treating the VGPR as a normal value has the disadvantage of
; increasing the amount of spill code with fast regalloc
; SGPR: buffer_store_dword v[[SPILL_VGPR]], off, s{{\[[0-9]+:[0-9]+\]}}, s{{[0-9]+}} offset:4 ; 4-byte Folded Spill

; SGPR: ;;#ASMSTART
; SGPR: buffer_load_dword v[[VGPR_RESTORE:[0-9]+]], off, s{{\[[0-9]+:[0-9]+\]}}, s{{[0-9]+}} offset:4 ; 4-byte Folded Reload
; SGPR: v_readlane_b32 s{{[0-9]+}}, v[[VGPR_RESTORE]], 0
; SGPR: v_readlane_b32 s{{[0-9]+}}, v[[VGPR_RESTORE]], 1
; SGPR: v_readlane_b32 s{{[0-9]+}}, v[[VGPR_RESTORE]], 2
; SGPR: v_readlane_b32 s{{[0-9]+}}, v[[VGPR_RESTORE]], 3


; Make sure scratch wave offset register is correctly incremented and
; then restored.
; SMEM: s_add_u32 m0, s[[OFF]], 0x100{{$}}
; SMEM: s_buffer_store_dwordx4 s{{\[[0-9]+:[0-9]+\]}}, s{{\[}}[[LO]]:[[HI]]], m0 ; 16-byte Folded Spill

; SMEM: s_add_u32 m0, s[[OFF]], 0x100{{$}}
; SMEM: s_buffer_load_dwordx4 s{{\[[0-9]+:[0-9]+\]}}, s{{\[}}[[LO]]:[[HI]]], m0 ; 16-byte Folded Reload

; SMEM: s_dcache_wb
; ALL: s_endpgm
define amdgpu_kernel void @test(i32 addrspace(1)* %out, i32 %in) {
  call void asm sideeffect "", "~{s[0:7]}" ()
  call void asm sideeffect "", "~{s[8:15]}" ()
  call void asm sideeffect "", "~{s[16:23]}" ()
  call void asm sideeffect "", "~{s[24:31]}" ()
  call void asm sideeffect "", "~{s[32:39]}" ()
  call void asm sideeffect "", "~{s[40:47]}" ()
  call void asm sideeffect "", "~{s[48:55]}" ()
  call void asm sideeffect "", "~{s[56:63]}" ()
  call void asm sideeffect "", "~{s[64:71]}" ()
  call void asm sideeffect "", "~{s[72:79]}" ()
  call void asm sideeffect "", "~{s[80:87]}" ()
  call void asm sideeffect "", "~{s[88:95]}" ()
  call void asm sideeffect "", "~{v[0:7]}" ()
  call void asm sideeffect "", "~{v[8:15]}" ()
  call void asm sideeffect "", "~{v[16:23]}" ()
  call void asm sideeffect "", "~{v[24:31]}" ()
  call void asm sideeffect "", "~{v[32:39]}" ()
  call void asm sideeffect "", "~{v[40:47]}" ()
  call void asm sideeffect "", "~{v[48:55]}" ()
  call void asm sideeffect "", "~{v[56:63]}" ()
  call void asm sideeffect "", "~{v[64:71]}" ()
  call void asm sideeffect "", "~{v[72:79]}" ()
  call void asm sideeffect "", "~{v[80:87]}" ()
  call void asm sideeffect "", "~{v[88:95]}" ()
  call void asm sideeffect "", "~{v[96:103]}" ()
  call void asm sideeffect "", "~{v[104:111]}" ()
  call void asm sideeffect "", "~{v[112:119]}" ()
  call void asm sideeffect "", "~{v[120:127]}" ()
  call void asm sideeffect "", "~{v[128:135]}" ()
  call void asm sideeffect "", "~{v[136:143]}" ()
  call void asm sideeffect "", "~{v[144:151]}" ()
  call void asm sideeffect "", "~{v[152:159]}" ()
  call void asm sideeffect "", "~{v[160:167]}" ()
  call void asm sideeffect "", "~{v[168:175]}" ()
  call void asm sideeffect "", "~{v[176:183]}" ()
  call void asm sideeffect "", "~{v[184:191]}" ()
  call void asm sideeffect "", "~{v[192:199]}" ()
  call void asm sideeffect "", "~{v[200:207]}" ()
  call void asm sideeffect "", "~{v[208:215]}" ()
  call void asm sideeffect "", "~{v[216:223]}" ()
  call void asm sideeffect "", "~{v[224:231]}" ()
  call void asm sideeffect "", "~{v[232:239]}" ()
  call void asm sideeffect "", "~{v[240:247]}" ()
  call void asm sideeffect "", "~{v[248:255]}" ()

  store i32 %in, i32 addrspace(1)* %out
  ret void
}
