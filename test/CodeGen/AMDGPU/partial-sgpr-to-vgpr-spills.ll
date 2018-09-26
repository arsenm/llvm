; RUN: llc -O0 -march=amdgcn -mcpu=hawaii -verify-machineinstrs < %s | FileCheck -check-prefix=ALL -check-prefix=VGPR -check-prefix=GCN %s

; FIXME: we should disable sdwa peephole because dead-code elimination, that
; runs after peephole, ruins this test (different register numbers)

; Spill all SGPRs so multiple VGPRs are required for spilling all of them.

; Ideally we only need 2 VGPRs for all spilling. The VGPRs are
; allocated per-frame index, so it's possible to get up with more.

; GCN-LABEL: {{^}}spill_sgprs_to_multiple_vgprs:

; GCN: ; implicit-def: $vgpr2
; GCN: ; implicit-def: $vgpr1
; GCN: ; implicit-def: $vgpr0


; GCN: def s[4:11]
; GCN: v_writelane_b32 v0, s4, 0
; GCN-NEXT: v_writelane_b32 v0, s5, 1
; GCN-NEXT: v_writelane_b32 v0, s6, 2
; GCN-NEXT: v_writelane_b32 v0, s7, 3
; GCN-NEXT: v_writelane_b32 v0, s8, 4
; GCN-NEXT: v_writelane_b32 v0, s9, 5
; GCN-NEXT: v_writelane_b32 v0, s10, 6
; GCN-NEXT: v_writelane_b32 v0, s11, 7

; GCN: def s{{\[}}[[TMP_LO:[0-9]+]]:[[TMP_HI:[0-9]+]]{{\]}}
; GCN: v_writelane_b32 v0, s[[TMP_LO]], 8
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 9
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 10
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 11
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 12
; GCN-NEXT: v_writelane_b32 v0, s9, 13
; GCN-NEXT: v_writelane_b32 v0, s10, 14
; GCN-NEXT: v_writelane_b32 v0, s[[TMP_HI]], 15

; GCN: def s{{\[}}[[TMP_LO]]:[[TMP_HI]]{{\]}}
; GCN: v_writelane_b32 v0, s[[TMP_LO]], 16
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 17
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 18
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 19
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 20
; GCN-NEXT: v_writelane_b32 v0, s9, 21
; GCN-NEXT: v_writelane_b32 v0, s10, 22
; GCN-NEXT: v_writelane_b32 v0, s[[TMP_HI]], 23

; GCN: def s{{\[}}[[TMP_LO]]:[[TMP_HI]]{{\]}}
; GCN: v_writelane_b32 v0, s[[TMP_LO]], 24
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 25
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 26
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 27
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 28
; GCN-NEXT: v_writelane_b32 v0, s9, 29
; GCN-NEXT: v_writelane_b32 v0, s10, 30
; GCN-NEXT: v_writelane_b32 v0, s[[TMP_HI]], 31

; GCN: def s{{\[}}[[TMP_LO]]:[[TMP_HI]]{{\]}}
; GCN: v_writelane_b32 v0, s[[TMP_LO]], 32
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 33
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 34
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 35
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 36
; GCN-NEXT: v_writelane_b32 v0, s9, 37
; GCN-NEXT: v_writelane_b32 v0, s10, 38
; GCN-NEXT: v_writelane_b32 v0, s[[TMP_HI]], 39

; GCN: def s{{\[}}[[TMP_LO]]:[[TMP_HI]]{{\]}}
; GCN: v_writelane_b32 v0, s[[TMP_LO]], 40
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 41
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 42
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 43
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 44
; GCN-NEXT: v_writelane_b32 v0, s9, 45
; GCN-NEXT: v_writelane_b32 v0, s10, 46
; GCN-NEXT: v_writelane_b32 v0, s[[TMP_HI]], 47

; GCN: def s{{\[}}[[TMP_LO]]:[[TMP_HI]]{{\]}}
; GCN: v_writelane_b32 v0, s[[TMP_LO]], 48
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 49
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 50
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 51
; GCN-NEXT: v_writelane_b32 v0, s{{[0-9]+}}, 52
; GCN-NEXT: v_writelane_b32 v0, s9, 53
; GCN-NEXT: v_writelane_b32 v0, s10, 54
; GCN-NEXT: v_writelane_b32 v0, s[[TMP_HI]], 55

; GCN: def s[4:11]
; GCN: v_writelane_b32 v0, s4, 56
; GCN-NEXT: v_writelane_b32 v0, s5, 57
; GCN-NEXT: v_writelane_b32 v0, s6, 58
; GCN-NEXT: v_writelane_b32 v0, s7, 59
; GCN-NEXT: v_writelane_b32 v0, s8, 60
; GCN-NEXT: v_writelane_b32 v0, s9, 61
; GCN-NEXT: v_writelane_b32 v0, s10, 62
; GCN-NEXT: v_writelane_b32 v0, s11, 63

; GCN: def s[4:11]
; GCN: v_writelane_b32 v1, s4, 0
; GCN-NEXT: v_writelane_b32 v1, s5, 1
; GCN-NEXT: v_writelane_b32 v1, s6, 2
; GCN-NEXT: v_writelane_b32 v1, s7, 3
; GCN-NEXT: v_writelane_b32 v1, s8, 4
; GCN-NEXT: v_writelane_b32 v1, s9, 5
; GCN-NEXT: v_writelane_b32 v1, s10, 6
; GCN-NEXT: v_writelane_b32 v1, s11, 7

; GCN: def s[4:11]
; GCN: v_writelane_b32 v1, s4, 8
; GCN-NEXT: v_writelane_b32 v1, s5, 9
; GCN-NEXT: v_writelane_b32 v1, s6, 10
; GCN-NEXT: v_writelane_b32 v1, s7, 11
; GCN-NEXT: v_writelane_b32 v1, s8, 12
; GCN-NEXT: v_writelane_b32 v1, s9, 13
; GCN-NEXT: v_writelane_b32 v1, s10, 14
; GCN-NEXT: v_writelane_b32 v1, s11, 15

; GCN: def s[4:11]
; GCN: v_writelane_b32 v1, s4, 16
; GCN-NEXT: v_writelane_b32 v1, s5, 17
; GCN-NEXT: v_writelane_b32 v1, s6, 18
; GCN-NEXT: v_writelane_b32 v1, s7, 19
; GCN-NEXT: v_writelane_b32 v1, s8, 20
; GCN-NEXT: v_writelane_b32 v1, s9, 21
; GCN-NEXT: v_writelane_b32 v1, s10, 22
; GCN-NEXT: v_writelane_b32 v1, s11, 23

; GCN: def s[4:11]
; GCN: v_writelane_b32 v1, s4, 24
; GCN-NEXT: v_writelane_b32 v1, s5, 25
; GCN-NEXT: v_writelane_b32 v1, s6, 26
; GCN-NEXT: v_writelane_b32 v1, s7, 27
; GCN-NEXT: v_writelane_b32 v1, s8, 28
; GCN-NEXT: v_writelane_b32 v1, s9, 29
; GCN-NEXT: v_writelane_b32 v1, s10, 30
; GCN-NEXT: v_writelane_b32 v1, s11, 31

; GCN: def s[4:11]
; GCN: v_writelane_b32 v1, s4, 32
; GCN-NEXT: v_writelane_b32 v1, s5, 33
; GCN-NEXT: v_writelane_b32 v1, s6, 34
; GCN-NEXT: v_writelane_b32 v1, s7, 35
; GCN-NEXT: v_writelane_b32 v1, s8, 36
; GCN-NEXT: v_writelane_b32 v1, s9, 37
; GCN-NEXT: v_writelane_b32 v1, s10, 38
; GCN-NEXT: v_writelane_b32 v1, s11, 39

; GCN: def s[4:11]
; GCN: v_writelane_b32 v1, s4, 40
; GCN-NEXT: v_writelane_b32 v1, s5, 41
; GCN-NEXT: v_writelane_b32 v1, s6, 42
; GCN-NEXT: v_writelane_b32 v1, s7, 43
; GCN-NEXT: v_writelane_b32 v1, s8, 44
; GCN-NEXT: v_writelane_b32 v1, s9, 45
; GCN-NEXT: v_writelane_b32 v1, s10, 46
; GCN-NEXT: v_writelane_b32 v1, s11, 47

; GCN: def s[4:11]
; GCN: v_writelane_b32 v1, s4, 48
; GCN-NEXT: v_writelane_b32 v1, s5, 49
; GCN-NEXT: v_writelane_b32 v1, s6, 50
; GCN-NEXT: v_writelane_b32 v1, s7, 51
; GCN-NEXT: v_writelane_b32 v1, s8, 52
; GCN-NEXT: v_writelane_b32 v1, s9, 53
; GCN-NEXT: v_writelane_b32 v1, s10, 54
; GCN-NEXT: v_writelane_b32 v1, s11, 55

; GCN: def s[4:11]
; GCN: v_writelane_b32 v1, s4, 56
; GCN-NEXT: v_writelane_b32 v1, s5, 57
; GCN-NEXT: v_writelane_b32 v1, s6, 58
; GCN-NEXT: v_writelane_b32 v1, s7, 59
; GCN-NEXT: v_writelane_b32 v1, s8, 60
; GCN-NEXT: v_writelane_b32 v1, s9, 61
; GCN-NEXT: v_writelane_b32 v1, s10, 62
; GCN-NEXT: v_writelane_b32 v1, s11, 63

; GCN: def s[4:11]
; GCN: v_writelane_b32 v2, s4, 0
; GCN-NEXT: v_writelane_b32 v2, s5, 1
; GCN-NEXT: v_writelane_b32 v2, s6, 2
; GCN-NEXT: v_writelane_b32 v2, s7, 3
; GCN-NEXT: v_writelane_b32 v2, s8, 4
; GCN-NEXT: v_writelane_b32 v2, s9, 5
; GCN-NEXT: v_writelane_b32 v2, s10, 6
; GCN-NEXT: v_writelane_b32 v2, s11, 7
; GCN: s_cbranch_scc1

; GCN: v_readlane_b32 s12, v1, 56
; GCN-NEXT: v_readlane_b32 s13, v1, 57
; GCN-NEXT: v_readlane_b32 s14, v1, 58
; GCN-NEXT: v_readlane_b32 s15, v1, 59
; GCN-NEXT: v_readlane_b32 s16, v1, 60
; GCN-NEXT: v_readlane_b32 s17, v1, 61
; GCN-NEXT: v_readlane_b32 s18, v1, 62
; GCN-NEXT: v_readlane_b32 s19, v1, 63
; GCN-NEXT: v_readlane_b32 s20, v1, 48
; GCN-NEXT: v_readlane_b32 s21, v1, 49
; GCN-NEXT: v_readlane_b32 s22, v1, 50
; GCN-NEXT: v_readlane_b32 s23, v1, 51
; GCN-NEXT: v_readlane_b32 s24, v1, 52
; GCN-NEXT: v_readlane_b32 s25, v1, 53
; GCN-NEXT: v_readlane_b32 s26, v1, 54
; GCN-NEXT: v_readlane_b32 s27, v1, 55
; GCN-NEXT: v_readlane_b32 s28, v1, 40
; GCN-NEXT: v_readlane_b32 s29, v1, 41
; GCN-NEXT: v_readlane_b32 s30, v1, 42
; GCN-NEXT: v_readlane_b32 s31, v1, 43
; GCN-NEXT: v_readlane_b32 s32, v1, 44
; GCN-NEXT: v_readlane_b32 s33, v1, 45
; GCN-NEXT: v_readlane_b32 s34, v1, 46
; GCN-NEXT: v_readlane_b32 s35, v1, 47
; GCN-NEXT: v_readlane_b32 s36, v1, 32
; GCN-NEXT: v_readlane_b32 s37, v1, 33
; GCN-NEXT: v_readlane_b32 s38, v1, 34
; GCN-NEXT: v_readlane_b32 s39, v1, 35
; GCN-NEXT: v_readlane_b32 s40, v1, 36
; GCN-NEXT: v_readlane_b32 s41, v1, 37
; GCN-NEXT: v_readlane_b32 s42, v1, 38
; GCN-NEXT: v_readlane_b32 s43, v1, 39
; GCN-NEXT: v_readlane_b32 s44, v1, 24
; GCN-NEXT: v_readlane_b32 s45, v1, 25
; GCN-NEXT: v_readlane_b32 s46, v1, 26
; GCN-NEXT: v_readlane_b32 s47, v1, 27
; GCN-NEXT: v_readlane_b32 s48, v1, 28
; GCN-NEXT: v_readlane_b32 s49, v1, 29
; GCN-NEXT: v_readlane_b32 s50, v1, 30
; GCN-NEXT: v_readlane_b32 s51, v1, 31
; GCN-NEXT: v_readlane_b32 s52, v1, 16
; GCN-NEXT: v_readlane_b32 s53, v1, 17
; GCN-NEXT: v_readlane_b32 s54, v1, 18
; GCN-NEXT: v_readlane_b32 s55, v1, 19
; GCN-NEXT: v_readlane_b32 s56, v1, 20
; GCN-NEXT: v_readlane_b32 s57, v1, 21
; GCN-NEXT: v_readlane_b32 s58, v1, 22
; GCN-NEXT: v_readlane_b32 s59, v1, 23
; GCN-NEXT: v_readlane_b32 s60, v1, 8
; GCN-NEXT: v_readlane_b32 s61, v1, 9
; GCN-NEXT: v_readlane_b32 s62, v1, 10
; GCN-NEXT: v_readlane_b32 s63, v1, 11
; GCN-NEXT: v_readlane_b32 s64, v1, 12
; GCN-NEXT: v_readlane_b32 s65, v1, 13
; GCN-NEXT: v_readlane_b32 s66, v1, 14
; GCN-NEXT: v_readlane_b32 s67, v1, 15
; GCN-NEXT: v_readlane_b32 s68, v1, 0
; GCN-NEXT: v_readlane_b32 s69, v1, 1
; GCN-NEXT: v_readlane_b32 s70, v1, 2
; GCN-NEXT: v_readlane_b32 s71, v1, 3
; GCN-NEXT: v_readlane_b32 s72, v1, 4
; GCN-NEXT: v_readlane_b32 s73, v1, 5
; GCN-NEXT: v_readlane_b32 s74, v1, 6
; GCN-NEXT: v_readlane_b32 s75, v1, 7
; GCN-NEXT: v_readlane_b32 s76, v0, 56
; GCN-NEXT: v_readlane_b32 s77, v0, 57
; GCN-NEXT: v_readlane_b32 s78, v0, 58
; GCN-NEXT: v_readlane_b32 s79, v0, 59
; GCN-NEXT: v_readlane_b32 s80, v0, 60
; GCN-NEXT: v_readlane_b32 s81, v0, 61
; GCN-NEXT: v_readlane_b32 s82, v0, 62
; GCN-NEXT: v_readlane_b32 s83, v0, 63
; GCN-NEXT: v_readlane_b32 s84, v0, 48
; GCN-NEXT: v_readlane_b32 s85, v0, 49
; GCN-NEXT: v_readlane_b32 s86, v0, 50
; GCN-NEXT: v_readlane_b32 s87, v0, 51
; GCN-NEXT: v_readlane_b32 s88, v0, 52
; GCN-NEXT: v_readlane_b32 s89, v0, 53
; GCN-NEXT: v_readlane_b32 s90, v0, 54
; GCN-NEXT: v_readlane_b32 s91, v0, 55
; GCN-NEXT: v_readlane_b32 s4, v0, 0
; GCN-NEXT: v_readlane_b32 s5, v0, 1
; GCN-NEXT: v_readlane_b32 s6, v0, 2
; GCN-NEXT: v_readlane_b32 s7, v0, 3
; GCN-NEXT: v_readlane_b32 s8, v0, 4
; GCN-NEXT: v_readlane_b32 s9, v0, 5
; GCN-NEXT: v_readlane_b32 s10, v0, 6
; GCN-NEXT: v_readlane_b32 s11, v0, 7
; GCN: ; use s{{\[}}[[USE_TMP_LO:[0-9]+]]:[[USE_TMP_HI:[0-9]+]]{{\]}}

; GCN: v_readlane_b32 s{{[0-9]+}}, v0, 8
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 9
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 10
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 11
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 12
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 13
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 14
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 15
; GCN: ; use s{{\[}}[[USE_TMP_LO]]:[[USE_TMP_HI]]{{\]}}

; GCN: v_readlane_b32 s{{[0-9]+}}, v0, 16
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 17
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 18
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 19
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 20
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 21
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 22
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 23
; GCN: ; use s{{\[}}[[USE_TMP_LO]]:[[USE_TMP_HI]]{{\]}}

; GCN: v_readlane_b32 s{{[0-9]+}}, v0, 24
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 25
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 26
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 27
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 28
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 29
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 30
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 31
; GCN: ; use s{{\[}}[[USE_TMP_LO]]:[[USE_TMP_HI]]{{\]}}

; GCN: v_readlane_b32 s{{[0-9]+}}, v0, 32
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 33
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 34
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 35
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 36
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 37
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 38
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 39
; GCN: ; use s{{\[}}[[USE_TMP_LO]]:[[USE_TMP_HI]]{{\]}}

; GCN: v_readlane_b32 s{{[0-9]+}}, v0, 40
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 41
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 42
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 43
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 44
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 45
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 46
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v0, 47
; GCN: ; use s{{\[}}[[USE_TMP_LO]]:[[USE_TMP_HI]]{{\]}}

; GCN: v_readlane_b32 s{{[0-9]+}}, v2, 0
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v2, 1
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v2, 2
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v2, 3
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v2, 4
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v2, 5
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v2, 6
; GCN-NEXT: v_readlane_b32 s{{[0-9]+}}, v2, 7
; GCN: use s[84:91]
; GCN: use s[76:83]
; GCN: use s[68:75]
; GCN: use s[60:67]
; GCN: use s[52:59]
; GCN: use s[44:51]
; GCN: use s[36:43]
; GCN: use s[28:35]
; GCN: use s[20:27]
; GCN: use s[12:19]
; GCN: use s[4:11]
define amdgpu_kernel void @spill_sgprs_to_multiple_vgprs(i32 addrspace(1)* %out, i32 %in) #0 {
  %wide.sgpr0 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr1 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr2 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr3 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr4 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr5 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr6 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr7 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr8 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr9 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr10 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr11 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr12 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr13 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr14 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr15 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr16 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %cmp = icmp eq i32 %in, 0
  br i1 %cmp, label %bb0, label %ret

bb0:
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr0) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr1) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr2) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr3) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr4) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr5) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr6) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr7) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr8) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr9) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr10) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr11) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr12) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr13) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr14) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr15) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr16) #0
  br label %ret

ret:
  ret void
}

; Some of the lanes of an SGPR spill are in one VGPR and some forced
; into the next available VGPR.

; GCN-LABEL: {{^}}split_sgpr_spill_2_vgprs:
; GCN: def s[4:19]
; GCN: def s[4:19]
; GCN: def s[4:19]
; GCN: def s[4:19]

; GCN: v_writelane_b32 v0, s6, 50
; GCN-NEXT: v_writelane_b32 v0, s7, 51
; GCN-NEXT: v_writelane_b32 v0, s8, 52
; GCN-NEXT: v_writelane_b32 v0, s9, 53
; GCN-NEXT: v_writelane_b32 v0, s10, 54
; GCN-NEXT: v_writelane_b32 v0, s11, 55
; GCN-NEXT: v_writelane_b32 v0, s12, 56
; GCN-NEXT: v_writelane_b32 v0, s13, 57
; GCN-NEXT: v_writelane_b32 v0, s14, 58
; GCN-NEXT: v_writelane_b32 v0, s15, 59
; GCN-NEXT: v_writelane_b32 v0, s16, 60
; GCN-NEXT: v_writelane_b32 v0, s17, 61
; GCN-NEXT: v_writelane_b32 v0, s18, 62
; GCN-NEXT: v_writelane_b32 v0, s19, 63

; GCN: def s[4:11]
; GCN: v_writelane_b32 v1, s4, 0
; GCN-NEXT: v_writelane_b32 v1, s5, 1

; GCN: v_readlane_b32 s6, v0, 50
; GCN-NEXT: v_readlane_b32 s7, v0, 51
; GCN-NEXT: v_readlane_b32 s8, v0, 52
; GCN-NEXT: v_readlane_b32 s9, v0, 53
; GCN-NEXT: v_readlane_b32 s10, v0, 54
; GCN-NEXT: v_readlane_b32 s11, v0, 55
; GCN-NEXT: v_readlane_b32 s12, v0, 56
; GCN-NEXT: v_readlane_b32 s13, v0, 57
; GCN-NEXT: v_readlane_b32 s14, v0, 58
; GCN-NEXT: v_readlane_b32 s15, v0, 59
; GCN-NEXT: v_readlane_b32 s16, v0, 60
; GCN-NEXT: v_readlane_b32 s17, v0, 61
; GCN-NEXT: v_readlane_b32 s18, v0, 62
; GCN-NEXT: v_readlane_b32 s19, v0, 63
; GCN: use s[20:27]
; GCN: use s[0:1]
; GCN: use s[4:19]
define amdgpu_kernel void @split_sgpr_spill_2_vgprs(i32 addrspace(1)* %out, i32 %in) #1 {
  %wide.sgpr0 = call <16 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr1 = call <16 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr2 = call <16 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr5 = call <16 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr3 = call <8 x i32> asm sideeffect "; def $0", "=s" () #0
  %wide.sgpr4 = call <2 x i32> asm sideeffect "; def $0", "=s" () #0

  %cmp = icmp eq i32 %in, 0
  br i1 %cmp, label %bb0, label %ret

bb0:
  call void asm sideeffect "; use $0", "s"(<16 x i32> %wide.sgpr0) #0
  call void asm sideeffect "; use $0", "s"(<16 x i32> %wide.sgpr1) #0
  call void asm sideeffect "; use $0", "s"(<16 x i32> %wide.sgpr2) #0
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr3) #0
  call void asm sideeffect "; use $0", "s"(<2 x i32> %wide.sgpr4) #0
  call void asm sideeffect "; use $0", "s"(<16 x i32> %wide.sgpr5) #0
  br label %ret

ret:
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { nounwind "amdgpu-waves-per-eu"="10,10" }
