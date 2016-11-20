define void @restore_m0_lds(i32 %arg, i64 addrspace(1)* %out, i64 addrspace(2)* %in) {
  %m0 = call i32 asm sideeffect "s_mov_b32 m0, 0", "={M0}"() #0
  %sgpr0 = load volatile i32, i32 addrspace(2)* undef
  %sgpr1 = load volatile i32, i32 addrspace(2)* undef
  %sgpr2 = load volatile i32, i32 addrspace(2)* undef
  %sgpr3 = load volatile i32, i32 addrspace(2)* undef
  %sgpr4 = load volatile i32, i32 addrspace(2)* undef
  %sgpr5 = load volatile i32, i32 addrspace(2)* undef
  %sgpr6 = load volatile i32, i32 addrspace(2)* undef
  %sgpr7 = load volatile i32, i32 addrspace(2)* undef
  %sgpr8 = load volatile i32, i32 addrspace(2)* undef
  %sgpr9 = load volatile i32, i32 addrspace(2)* undef
  %sgpr10 = load volatile i32, i32 addrspace(2)* undef
  %sgpr11 = load volatile i32, i32 addrspace(2)* undef
  %sgpr12 = load volatile i32, i32 addrspace(2)* undef
  %sgpr13 = load volatile i32, i32 addrspace(2)* undef
  %sgpr14 = load volatile i32, i32 addrspace(2)* undef
  %sgpr15 = load volatile i32, i32 addrspace(2)* undef
  %sgpr16 = load volatile i32, i32 addrspace(2)* undef
  %sgpr17 = load volatile i32, i32 addrspace(2)* undef
  %sgpr18 = load volatile i32, i32 addrspace(2)* undef
  %sgpr19 = load volatile i32, i32 addrspace(2)* undef
  %sgpr20 = load volatile i32, i32 addrspace(2)* undef
  %sgpr21 = load volatile i32, i32 addrspace(2)* undef
  %sgpr22 = load volatile i32, i32 addrspace(2)* undef
  %sgpr23 = load volatile i32, i32 addrspace(2)* undef
  %sgpr24 = load volatile i32, i32 addrspace(2)* undef
  %sgpr25 = load volatile i32, i32 addrspace(2)* undef
  %sgpr26 = load volatile i32, i32 addrspace(2)* undef
  %sgpr27 = load volatile i32, i32 addrspace(2)* undef
  %sgpr28 = load volatile i32, i32 addrspace(2)* undef
  %sgpr29 = load volatile i32, i32 addrspace(2)* undef
  %sgpr30 = load volatile i32, i32 addrspace(2)* undef
  %sgpr31 = load volatile i32, i32 addrspace(2)* undef
  %sgpr32 = load volatile i32, i32 addrspace(2)* undef
  %sgpr33 = load volatile i32, i32 addrspace(2)* undef
  %sgpr34 = load volatile i32, i32 addrspace(2)* undef
  %sgpr35 = load volatile i32, i32 addrspace(2)* undef
  %sgpr36 = load volatile i32, i32 addrspace(2)* undef
  %sgpr37 = load volatile i32, i32 addrspace(2)* undef
  %sgpr38 = load volatile i32, i32 addrspace(2)* undef
  %sgpr39 = load volatile i32, i32 addrspace(2)* undef
  %sgpr40 = load volatile i32, i32 addrspace(2)* undef
  %sgpr41 = load volatile i32, i32 addrspace(2)* undef
  %sgpr42 = load volatile i32, i32 addrspace(2)* undef
  %sgpr43 = load volatile i32, i32 addrspace(2)* undef
  %sgpr44 = load volatile i32, i32 addrspace(2)* undef
  %sgpr45 = load volatile i32, i32 addrspace(2)* undef
  %sgpr46 = load volatile i32, i32 addrspace(2)* undef
  %sgpr47 = load volatile i32, i32 addrspace(2)* undef
  %sgpr48 = load volatile i32, i32 addrspace(2)* undef
  %sgpr49 = load volatile i32, i32 addrspace(2)* undef
  %sgpr50 = load volatile i32, i32 addrspace(2)* undef
  %sgpr51 = load volatile i32, i32 addrspace(2)* undef
  %sgpr52 = load volatile i32, i32 addrspace(2)* undef
  %sgpr53 = load volatile i32, i32 addrspace(2)* undef
  %sgpr54 = load volatile i32, i32 addrspace(2)* undef
  %sgpr55 = load volatile i32, i32 addrspace(2)* undef
  %sgpr56 = load volatile i32, i32 addrspace(2)* undef
  %sgpr57 = load volatile i32, i32 addrspace(2)* undef
  %sgpr58 = load volatile i32, i32 addrspace(2)* undef
  %sgpr59 = load volatile i32, i32 addrspace(2)* undef
  %sgpr60 = load volatile i32, i32 addrspace(2)* undef
  %sgpr61 = load volatile i32, i32 addrspace(2)* undef
  %sgpr62 = load volatile i32, i32 addrspace(2)* undef
  %sgpr63 = load volatile i32, i32 addrspace(2)* undef
  %sgpr64 = load volatile i32, i32 addrspace(2)* undef
  %sgpr65 = load volatile i32, i32 addrspace(2)* undef
  %sgpr66 = load volatile i32, i32 addrspace(2)* undef
  %sgpr67 = load volatile i32, i32 addrspace(2)* undef
  %sgpr68 = load volatile i32, i32 addrspace(2)* undef
  %sgpr69 = load volatile i32, i32 addrspace(2)* undef
  %sgpr70 = load volatile i32, i32 addrspace(2)* undef
  %sgpr71 = load volatile i32, i32 addrspace(2)* undef
  %sgpr72 = load volatile i32, i32 addrspace(2)* undef
  %sgpr73 = load volatile i32, i32 addrspace(2)* undef
  %sgpr74 = load volatile i32, i32 addrspace(2)* undef
  %sgpr75 = load volatile i32, i32 addrspace(2)* undef
  %sgpr76 = load volatile i32, i32 addrspace(2)* undef
  %sgpr77 = load volatile i32, i32 addrspace(2)* undef
  %sgpr78 = load volatile i32, i32 addrspace(2)* undef
  %sgpr79 = load volatile i32, i32 addrspace(2)* undef
  %sgpr80 = load volatile i32, i32 addrspace(2)* undef
  %sgpr81 = load volatile i32, i32 addrspace(2)* undef
  %sgpr82 = load volatile i32, i32 addrspace(2)* undef
  %sgpr83 = load volatile i32, i32 addrspace(2)* undef
  %sgpr84 = load volatile i32, i32 addrspace(2)* undef
  %sgpr85 = load volatile i32, i32 addrspace(2)* undef
  %sgpr86 = load volatile i32, i32 addrspace(2)* undef
  %sgpr87 = load volatile i32, i32 addrspace(2)* undef
  %sgpr88 = load volatile i32, i32 addrspace(2)* undef
  %sgpr89 = load volatile i32, i32 addrspace(2)* undef
  %sgpr90 = load volatile i32, i32 addrspace(2)* undef
  %sgpr91 = load volatile i32, i32 addrspace(2)* undef
  %sgpr92 = load volatile i32, i32 addrspace(2)* undef
  %sgpr93 = load volatile i32, i32 addrspace(2)* undef
  %sgpr94 = load volatile i32, i32 addrspace(2)* undef
  %sgpr95 = load volatile i32, i32 addrspace(2)* undef
  %sgpr96 = load volatile i32, i32 addrspace(2)* undef
  %sgpr97 = load volatile i32, i32 addrspace(2)* undef
  %sgpr98 = load volatile i32, i32 addrspace(2)* undef
  %sgpr99 = load volatile i32, i32 addrspace(2)* undef
  %sgpr100 = load volatile i32, i32 addrspace(2)* undef

  %vcc_lo = tail call i32 asm sideeffect "s_mov_b32 vcc_lo, 0", "={VCC_LO}"() #0
  %vcc_hi = tail call i32 asm sideeffect "s_mov_b32 vcc_hi, 0", "={VCC_HI}"() #0

  %sval = load volatile i64, i64 addrspace(2)* %in
  ; call void asm sideeffect "", "~{SGPR0_SGPR1_SGPR2_SGPR3_SGPR4_SGPR5_SGPR6_SGPR7}" ()
  ; call void asm sideeffect "", "~{SGPR8_SGPR9_SGPR10_SGPR11_SGPR12_SGPR13_SGPR14_SGPR15}" ()
  ; call void asm sideeffect "", "~{SGPR16_SGPR17_SGPR18_SGPR19_SGPR20_SGPR21_SGPR22_SGPR23}" ()
  ; call void asm sideeffect "", "~{SGPR24_SGPR25_SGPR26_SGPR27_SGPR28_SGPR29_SGPR30_SGPR31}" ()
  ; call void asm sideeffect "", "~{SGPR32_SGPR33_SGPR34_SGPR35_SGPR36_SGPR37_SGPR38_SGPR39}" ()
  ; call void asm sideeffect "", "~{SGPR40_SGPR41_SGPR42_SGPR43_SGPR44_SGPR45_SGPR46_SGPR47}" ()
  ; call void asm sideeffect "", "~{SGPR48_SGPR49_SGPR50_SGPR51_SGPR52_SGPR53_SGPR54_SGPR55}" ()
  ; call void asm sideeffect "", "~{SGPR56_SGPR57_SGPR58_SGPR59_SGPR60_SGPR61_SGPR62_SGPR63}" ()
  ; call void asm sideeffect "", "~{SGPR64_SGPR65_SGPR66_SGPR67_SGPR68_SGPR69_SGPR70_SGPR71}" ()
  ; call void asm sideeffect "", "~{SGPR72_SGPR73_SGPR74_SGPR75_SGPR76_SGPR77_SGPR78_SGPR79}" ()
  ; call void asm sideeffect "", "~{SGPR80_SGPR81_SGPR82_SGPR83_SGPR84_SGPR85_SGPR86_SGPR87}" ()
  ; call void asm sideeffect "", "~{SGPR88_SGPR89_SGPR90_SGPR91_SGPR92_SGPR93_SGPR94_SGPR95}" ()
  ; call void asm sideeffect "", "~{SGPR95_SGPR96_SGPR97_SGPR98}" ()
  ; call void asm sideeffect "", "~{VCC}" ()


  tail call void asm sideeffect "; reg use $0", "{SGPR0}"(i32 %sgpr0) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR1}"(i32 %sgpr1) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR2}"(i32 %sgpr2) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR3}"(i32 %sgpr3) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR4}"(i32 %sgpr4) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR5}"(i32 %sgpr5) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR6}"(i32 %sgpr6) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR7}"(i32 %sgpr7) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR8}"(i32 %sgpr8) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR9}"(i32 %sgpr9) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR10}"(i32 %sgpr10) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR11}"(i32 %sgpr11) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR12}"(i32 %sgpr12) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR13}"(i32 %sgpr13) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR14}"(i32 %sgpr14) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR15}"(i32 %sgpr15) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR16}"(i32 %sgpr16) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR17}"(i32 %sgpr17) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR18}"(i32 %sgpr18) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR19}"(i32 %sgpr19) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR20}"(i32 %sgpr20) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR21}"(i32 %sgpr21) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR22}"(i32 %sgpr22) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR23}"(i32 %sgpr23) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR24}"(i32 %sgpr24) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR25}"(i32 %sgpr25) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR26}"(i32 %sgpr26) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR27}"(i32 %sgpr27) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR28}"(i32 %sgpr28) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR29}"(i32 %sgpr29) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR30}"(i32 %sgpr30) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR31}"(i32 %sgpr31) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR32}"(i32 %sgpr32) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR33}"(i32 %sgpr33) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR34}"(i32 %sgpr34) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR35}"(i32 %sgpr35) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR36}"(i32 %sgpr36) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR37}"(i32 %sgpr37) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR38}"(i32 %sgpr38) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR39}"(i32 %sgpr39) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR40}"(i32 %sgpr40) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR41}"(i32 %sgpr41) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR42}"(i32 %sgpr42) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR43}"(i32 %sgpr43) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR44}"(i32 %sgpr44) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR45}"(i32 %sgpr45) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR46}"(i32 %sgpr46) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR47}"(i32 %sgpr47) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR48}"(i32 %sgpr48) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR49}"(i32 %sgpr49) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR50}"(i32 %sgpr50) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR51}"(i32 %sgpr51) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR52}"(i32 %sgpr52) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR53}"(i32 %sgpr53) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR54}"(i32 %sgpr54) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR55}"(i32 %sgpr55) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR56}"(i32 %sgpr56) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR57}"(i32 %sgpr57) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR58}"(i32 %sgpr58) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR59}"(i32 %sgpr59) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR60}"(i32 %sgpr60) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR61}"(i32 %sgpr61) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR62}"(i32 %sgpr62) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR63}"(i32 %sgpr63) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR64}"(i32 %sgpr64) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR65}"(i32 %sgpr65) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR66}"(i32 %sgpr66) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR67}"(i32 %sgpr67) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR68}"(i32 %sgpr68) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR69}"(i32 %sgpr69) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR70}"(i32 %sgpr70) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR71}"(i32 %sgpr71) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR72}"(i32 %sgpr72) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR73}"(i32 %sgpr73) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR74}"(i32 %sgpr74) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR75}"(i32 %sgpr75) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR76}"(i32 %sgpr76) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR77}"(i32 %sgpr77) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR78}"(i32 %sgpr78) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR79}"(i32 %sgpr79) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR80}"(i32 %sgpr80) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR81}"(i32 %sgpr81) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR82}"(i32 %sgpr82) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR83}"(i32 %sgpr83) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR84}"(i32 %sgpr84) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR85}"(i32 %sgpr85) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR86}"(i32 %sgpr86) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR87}"(i32 %sgpr87) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR88}"(i32 %sgpr88) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR89}"(i32 %sgpr89) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR90}"(i32 %sgpr90) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR91}"(i32 %sgpr91) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR92}"(i32 %sgpr92) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR93}"(i32 %sgpr93) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR94}"(i32 %sgpr94) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR95}"(i32 %sgpr95) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR96}"(i32 %sgpr96) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR97}"(i32 %sgpr97) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR98}"(i32 %sgpr98) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR99}"(i32 %sgpr99) #0
  tail call void asm sideeffect "; reg use $0", "{VCC_LO}"(i32 %vcc_lo) #0
  tail call void asm sideeffect "; reg use $0", "{VCC_HI}"(i32 %vcc_hi) #0

  store volatile i64 %sval, i64 addrspace(1)* %out

  tail call void asm sideeffect "; reg use $0", "{SGPR0}"(i32 %sgpr0) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR1}"(i32 %sgpr1) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR2}"(i32 %sgpr2) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR3}"(i32 %sgpr3) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR4}"(i32 %sgpr4) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR5}"(i32 %sgpr5) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR6}"(i32 %sgpr6) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR7}"(i32 %sgpr7) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR8}"(i32 %sgpr8) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR9}"(i32 %sgpr9) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR10}"(i32 %sgpr10) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR11}"(i32 %sgpr11) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR12}"(i32 %sgpr12) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR13}"(i32 %sgpr13) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR14}"(i32 %sgpr14) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR15}"(i32 %sgpr15) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR16}"(i32 %sgpr16) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR17}"(i32 %sgpr17) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR18}"(i32 %sgpr18) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR19}"(i32 %sgpr19) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR20}"(i32 %sgpr20) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR21}"(i32 %sgpr21) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR22}"(i32 %sgpr22) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR23}"(i32 %sgpr23) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR24}"(i32 %sgpr24) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR25}"(i32 %sgpr25) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR26}"(i32 %sgpr26) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR27}"(i32 %sgpr27) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR28}"(i32 %sgpr28) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR29}"(i32 %sgpr29) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR30}"(i32 %sgpr30) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR31}"(i32 %sgpr31) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR32}"(i32 %sgpr32) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR33}"(i32 %sgpr33) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR34}"(i32 %sgpr34) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR35}"(i32 %sgpr35) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR36}"(i32 %sgpr36) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR37}"(i32 %sgpr37) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR38}"(i32 %sgpr38) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR39}"(i32 %sgpr39) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR40}"(i32 %sgpr40) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR41}"(i32 %sgpr41) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR42}"(i32 %sgpr42) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR43}"(i32 %sgpr43) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR44}"(i32 %sgpr44) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR45}"(i32 %sgpr45) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR46}"(i32 %sgpr46) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR47}"(i32 %sgpr47) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR48}"(i32 %sgpr48) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR49}"(i32 %sgpr49) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR50}"(i32 %sgpr50) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR51}"(i32 %sgpr51) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR52}"(i32 %sgpr52) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR53}"(i32 %sgpr53) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR54}"(i32 %sgpr54) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR55}"(i32 %sgpr55) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR56}"(i32 %sgpr56) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR57}"(i32 %sgpr57) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR58}"(i32 %sgpr58) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR59}"(i32 %sgpr59) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR60}"(i32 %sgpr60) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR61}"(i32 %sgpr61) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR62}"(i32 %sgpr62) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR63}"(i32 %sgpr63) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR64}"(i32 %sgpr64) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR65}"(i32 %sgpr65) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR66}"(i32 %sgpr66) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR67}"(i32 %sgpr67) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR68}"(i32 %sgpr68) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR69}"(i32 %sgpr69) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR70}"(i32 %sgpr70) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR71}"(i32 %sgpr71) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR72}"(i32 %sgpr72) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR73}"(i32 %sgpr73) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR74}"(i32 %sgpr74) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR75}"(i32 %sgpr75) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR76}"(i32 %sgpr76) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR77}"(i32 %sgpr77) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR78}"(i32 %sgpr78) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR79}"(i32 %sgpr79) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR80}"(i32 %sgpr80) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR81}"(i32 %sgpr81) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR82}"(i32 %sgpr82) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR83}"(i32 %sgpr83) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR84}"(i32 %sgpr84) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR85}"(i32 %sgpr85) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR86}"(i32 %sgpr86) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR87}"(i32 %sgpr87) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR88}"(i32 %sgpr88) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR89}"(i32 %sgpr89) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR90}"(i32 %sgpr90) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR91}"(i32 %sgpr91) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR92}"(i32 %sgpr92) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR93}"(i32 %sgpr93) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR94}"(i32 %sgpr94) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR95}"(i32 %sgpr95) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR96}"(i32 %sgpr96) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR97}"(i32 %sgpr97) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR98}"(i32 %sgpr98) #0
  tail call void asm sideeffect "; reg use $0", "{SGPR99}"(i32 %sgpr99) #0

  tail call void asm sideeffect "; reg use $0", "{VCC_LO}"(i32 %vcc_lo) #0
  tail call void asm sideeffect "; reg use $0", "{VCC_HI}"(i32 %vcc_hi) #0
  call void asm sideeffect "; use $0", "{M0}"(i32 %m0) #0
  store volatile i64 %sval, i64 addrspace(1)* %out
  %cmp = icmp eq i32 %arg, 0
  br i1 %cmp, label %ret, label %bb

bb:


  call void asm sideeffect "; use $0", "{M0}"(i32 %m0) #0
  br label %ret

ret:
  ret void
}
