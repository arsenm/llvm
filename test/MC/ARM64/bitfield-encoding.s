; RUN: llvm-mc -triple arm64-apple-darwin -show-encoding < %s | FileCheck %s

foo:
;==---------------------------------------------------------------------------==
; 5.4.4 Bitfield Operations
;==---------------------------------------------------------------------------==

  bfm  w1, w2, #1, #15
  bfm  x1, x2, #1, #15
  sbfm w1, w2, #1, #15
  sbfm x1, x2, #1, #15
  ubfm w1, w2, #1, #15
  ubfm x1, x2, #1, #15
  sbfiz wzr, w0, #31, #1
  sbfiz xzr, x0, #31, #1
  ubfiz wzr, w0, #31, #1
  ubfiz xzr, x0, #31, #1

; CHECK: bfm  w1, w2, #1, #15        ; encoding: [0x41,0x3c,0x01,0x33]
; CHECK: bfm  x1, x2, #1, #15        ; encoding: [0x41,0x3c,0x41,0xb3]
; CHECK: sbfm w1, w2, #1, #15        ; encoding: [0x41,0x3c,0x01,0x13]
; CHECK: sbfm x1, x2, #1, #15        ; encoding: [0x41,0x3c,0x41,0x93]
; CHECK: ubfm w1, w2, #1, #15        ; encoding: [0x41,0x3c,0x01,0x53]
; CHECK: ubfm x1, x2, #1, #15        ; encoding: [0x41,0x3c,0x41,0xd3]
; CHECK: sbfm wzr, w0, #1, #0        ; encoding: [0x1f,0x00,0x01,0x13]
; CHECK: sbfm xzr, x0, #33, #0       ; encoding: [0x1f,0x00,0x61,0x93]
; CHECK: lsl  wzr, w0, #31           ; encoding: [0x1f,0x00,0x01,0x53]
; CHECK: ubfm xzr, x0, #33, #0       ; encoding: [0x1f,0x00,0x61,0xd3]

;==---------------------------------------------------------------------------==
; 5.4.5 Extract (immediate)
;==---------------------------------------------------------------------------==

  extr w1, w2, w3, #15
  extr x2, x3, x4, #1

; CHECK: extr w1, w2, w3, #15        ; encoding: [0x41,0x3c,0x83,0x13]
; CHECK: extr x2, x3, x4, #1         ; encoding: [0x62,0x04,0xc4,0x93]
