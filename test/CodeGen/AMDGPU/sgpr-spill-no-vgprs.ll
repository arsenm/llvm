; RUN: not llc -O0 -march=amdgcn -mcpu=hawaii -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s
; RUN: not llc -O0 -march=amdgcn -mcpu=hawaii -verify-machineinstrs < %s 2>&1 | FileCheck -check-prefix=ERROR %s

; ERROR: error: VGPRs for SGPR spilling limit exceeded (0) in partial_no_vgprs_last_sgpr_spill

; The first 64 SGPR spills can go to a VGPR, but there isn't a second
; so some spills must be to memory. The last 16 element spill runs out of lanes at the 15th element.

; GCN-LABEL: {{^}}partial_no_vgprs_last_sgpr_spill:

; GCN: v_writelane_b32 v23, s{{[0-9]+}}, 0
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 1
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 2
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 3
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 4
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 5
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 6
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 7
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 8
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 9
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 10
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 11
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 12
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 13
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 14
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 15

; GCN: v_writelane_b32 v23, s{{[0-9]+}}, 16
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 17
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 18
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 19
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 20
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 21
; GCN-NEXT: v_writelane_b32 v23, s{{[0-9]+}}, 22
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 23
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 24
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 25
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 26
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 27
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 28
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 29
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 30
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 31

; GCN: def s[4:19]
; GCN:      v_writelane_b32 v23, s4, 32
; GCN-NEXT: v_writelane_b32 v23, s5, 33
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 34
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 35
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 36
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 37
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 38
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 39
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 40
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 41
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 42
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 43
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 44
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 45
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 46
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 47

; GCN: def s[4:19]
; GCN: v_writelane_b32 v23, s{{[[0-9]+}}, 48
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 49
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 50
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 51
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 52
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 53
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 54
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 55
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 56
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 57
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 58
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 59
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 60
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 61
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 62
; GCN-NEXT: v_writelane_b32 v23, s{{[[0-9]+}}, 63

; GCN: def s[4:5]
; GCN: buffer_store_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, s{{[0-9]+}}
; GCN: buffer_store_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, s{{[0-9]+}}
; GCN: s_cbranch_scc1


; GCN: buffer_load_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, s{{[0-9]+}}
; GCN: buffer_load_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, s{{[0-9]+}}

; GCN: v_readlane_b32 s20, v23, 32
; GCN-NEXT: v_readlane_b32 s21, v23, 33
; GCN-NEXT: v_readlane_b32 s22, v23, 34
; GCN-NEXT: v_readlane_b32 s23, v23, 35
; GCN-NEXT: v_readlane_b32 s24, v23, 36
; GCN-NEXT: v_readlane_b32 s25, v23, 37
; GCN-NEXT: v_readlane_b32 s26, v23, 38
; GCN-NEXT: v_readlane_b32 s27, v23, 39
; GCN-NEXT: v_readlane_b32 s28, v23, 40
; GCN-NEXT: v_readlane_b32 s29, v23, 41
; GCN-NEXT: v_readlane_b32 s30, v23, 42
; GCN-NEXT: v_readlane_b32 s31, v23, 43
; GCN-NEXT: v_readlane_b32 s32, v23, 44
; GCN-NEXT: v_readlane_b32 s33, v23, 45
; GCN-NEXT: v_readlane_b32 s34, v23, 46
; GCN-NEXT: v_readlane_b32 s35, v23, 47

; GCN: v_readlane_b32 s[[USE_TMP_LO:[0-9]+]], v23, 0
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 1
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 2
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 3
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 4
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 5
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 6
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 7
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 8
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 9
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 10
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 11
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 12
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 13
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 14
; GCN-NEXT: v_readlane_b32 s[[USE_TMP_HI:[0-9]+]], v23, 15
; GCN: ; use s{{\[}}[[USE_TMP_LO]]:[[USE_TMP_HI]]{{\]}}

; GCN: v_readlane_b32 s[[USE_TMP_LO:[0-9]+]], v23, 16
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 17
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 18
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 19
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 20
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 21
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 22
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 23
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 24
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 25
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 26
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 27
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 28
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 29
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 30
; GCN-NEXT: v_readlane_b32 s[[USE_TMP_HI:[0-9]+]], v23, 31
; GCN: ; use s{{\[}}[[USE_TMP_LO]]:[[USE_TMP_HI]]{{\]}}

; GCN: v_readlane_b32 s[[USE_TMP_LO:[0-9]+]], v23, 48
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 49
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 50
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 51
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 52
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 53
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 54
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 55
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 56
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 57
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 58
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 59
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 60
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 61
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v23, 62
; GCN-NEXT: v_readlane_b32 s[[USE_TMP_HI:[0-9]+]], v23, 63
; GCN: ; use s{{\[}}[[USE_TMP_LO]]:[[USE_TMP_HI]]{{\]}}
; GCN: ; use s[0:1]
define amdgpu_kernel void @partial_no_vgprs_last_sgpr_spill(i32 addrspace(1)* %out, i32 %in) #1 {
  call void asm sideeffect "", "~{v[0:7]}" () #0
  call void asm sideeffect "", "~{v[8:15]}" () #0
  call void asm sideeffect "", "~{v[16:19]}"() #0
  call void asm sideeffect "", "~{v[20:21]}"() #0
  call void asm sideeffect "", "~{v22}"() #0

  %wide.sgpr0 = call <16 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr1 = call <16 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr2 = call <16 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr3 = call <16 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr4 = call <2 x i32> asm sideeffect "; def $0", "=s" () #0
  %cmp = icmp eq i32 %in, 0
  br i1 %cmp, label %bb0, label %ret

bb0:
  call void asm sideeffect "; use $0", "s"(<16 x i32> %wide.sgpr0) #0
  call void asm sideeffect "; use $0", "s"(<16 x i32> %wide.sgpr1) #0
  call void asm sideeffect "; use $0", "s"(<16 x i32> %wide.sgpr2) #0
  call void asm sideeffect "; use $0", "s"(<16 x i32> %wide.sgpr3) #0
  call void asm sideeffect "; use $0", "s"(<2 x i32> %wide.sgpr4) #0
  br label %ret

ret:
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { nounwind "amdgpu-waves-per-eu"="10,10" }
