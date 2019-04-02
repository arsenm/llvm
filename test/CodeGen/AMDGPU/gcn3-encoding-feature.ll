; RUN: llc -mtriple=amdgcn-amd-amdhsa -show-mc-encoding < %s | FileCheck %s

; CHECK-LABEL: func_vi:
; CHECK: v_add_f32_e32 v0, 1.0, v0 ; encoding: [0xf2,0x00,0x00,0x02]
define float @func_vi(float %arg0) #1 {
  %fadd = fadd float %arg0, 1.0
  ret float %fadd
}

; CHECK-LABEL: func_si:
; CHECK: v_add_f32_e32 v0, 1.0, v0 ; encoding: [0xf2,0x00,0x00,0x06]
define float @func_si(float %arg0) #0 {
  %fadd = fadd float %arg0, 1.0
  ret float %fadd
}

; Defaults to SI encoding
; CHECK-LABEL: func_unknown:
; CHECK: v_add_f32_e32 v0, 1.0, v0 ; encoding: [0xf2,0x00,0x00,0x06]
define float @func_unknown(float %arg0) {
  %fadd = fadd float %arg0, 1.0
  ret float %fadd
}

attributes #0 = { "target-features"="-gcn3-encoding" }
attributes #1 = { "target-features"="+gcn3-encoding" }
