; RUN: llc -march=r600 -mcpu=SI -verify-machineinstrs < %s | FileCheck -check-prefix=SI %s

; SI-LABEL: {{^}}s_movk_i32_k0:
; SI-DAG: S_MOV_B32 [[LO_S_IMM:s[0-9]+]], 0xffff{{$}}
; SI-DAG: S_MOV_B32 [[HI_S_IMM:s[0-9]+]], 1{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k0(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 4295032831 ; ((1 << 16) - 1) | (1 << 32)
  store i64 %or, i64 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_movk_i32_k1:
; SI-DAG: S_MOVK_I32 [[LO_S_IMM:s[0-9]+]], 0x7fff{{$}}
; SI-DAG: S_MOV_B32 [[HI_S_IMM:s[0-9]+]], 1{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k1(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 4295000063 ; ((1 << 15) - 1) | (1 << 32)
  store i64 %or, i64 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_movk_i32_k2:
; SI-DAG: S_MOVK_I32 [[LO_S_IMM:s[0-9]+]], 0x7fff{{$}}
; SI-DAG: S_MOV_B32 [[HI_S_IMM:s[0-9]+]], 64{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k2(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 274877939711 ; ((1 << 15) - 1) | (64 << 32)
  store i64 %or, i64 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_movk_i32_k3:
; SI-DAG: S_MOV_B32 [[LO_S_IMM:s[0-9]+]], 0x8000{{$}}
; SI-DAG: S_MOV_B32 [[HI_S_IMM:s[0-9]+]], 1{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k3(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 4295000064 ; (1 << 15) | (1 << 32)
  store i64 %or, i64 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_movk_i32_k4:
; SI-DAG: S_MOV_B32 [[LO_S_IMM:s[0-9]+]], 0x20000{{$}}
; SI-DAG: S_MOV_B32 [[HI_S_IMM:s[0-9]+]], 1{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k4(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 4295098368 ; (1 << 17) | (1 << 32)
  store i64 %or, i64 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_movk_i32_k5:
; SI-DAG: S_MOVK_I32 [[LO_S_IMM:s[0-9]+]], 0xffef{{$}}
; SI-DAG: S_MOV_B32 [[HI_S_IMM:s[0-9]+]], 0xff00ffff{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k5(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 18374967954648334319 ; -17 & 0xff00ffffffffffff
  store i64 %or, i64 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_movk_i32_k6:
; SI-DAG: S_MOVK_I32 [[LO_S_IMM:s[0-9]+]], 0x41{{$}}
; SI-DAG: S_MOV_B32 [[HI_S_IMM:s[0-9]+]], 63{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k6(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 270582939713 ; 65 | (63 << 32)
  store i64 %or, i64 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_movk_i32_k7:
; SI-DAG: S_MOVK_I32 [[LO_S_IMM:s[0-9]+]], 0x2000{{$}}
; SI-DAG: S_MOVK_I32 [[HI_S_IMM:s[0-9]+]], 0x4000{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k7(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 70368744185856; ((1 << 13)) | ((1 << 14) << 32)
  store i64 %or, i64 addrspace(1)* %out
  ret void
}


; SI-LABEL: {{^}}s_movk_i32_k8:
; SI-DAG: S_MOVK_I32 [[LO_S_IMM:s[0-9]+]], 0x8000{{$}}
; SI-DAG: S_MOV_B32 [[HI_S_IMM:s[0-9]+]], 0x11111111{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k8(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 1229782942255906816 ; 0x11111111ffff8000
  store i64 %or, i64 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_movk_i32_k9:
; SI-DAG: S_MOVK_I32 [[LO_S_IMM:s[0-9]+]], 0x8001{{$}}
; SI-DAG: S_MOV_B32 [[HI_S_IMM:s[0-9]+]], 0x11111111{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k9(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 1229782942255906817 ; 0x11111111ffff8001
  store i64 %or, i64 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_movk_i32_k10:
; SI-DAG: S_MOVK_I32 [[LO_S_IMM:s[0-9]+]], 0x8888{{$}}
; SI-DAG: S_MOV_B32 [[HI_S_IMM:s[0-9]+]], 0x11111111{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k10(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 1229782942255909000 ; 0x11111111ffff8888
  store i64 %or, i64 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_movk_i32_k11:
; SI-DAG: S_MOVK_I32 [[LO_S_IMM:s[0-9]+]], 0x8fff{{$}}
; SI-DAG: S_MOV_B32 [[HI_S_IMM:s[0-9]+]], 0x11111111{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k11(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 1229782942255910911 ; 0x11111111ffff8fff
  store i64 %or, i64 addrspace(1)* %out
  ret void
}

; SI-LABEL: {{^}}s_movk_i32_k12:
; SI-DAG: S_MOV_B32 [[LO_S_IMM:s[0-9]+]], 0xffff7001{{$}}
; SI-DAG: S_MOV_B32 [[HI_S_IMM:s[0-9]+]], 0x11111111{{$}}
; SI-DAG: BUFFER_LOAD_DWORDX2 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}},
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[LO_S_IMM]], v[[LO_VREG]]
; SI-DAG: V_OR_B32_e32 {{v[0-9]+}}, [[HI_S_IMM]], v[[HI_VREG]]
; SI: S_ENDPGM
define void @s_movk_i32_k12(i64 addrspace(1)* %out, i64 addrspace(1)* %a, i64 addrspace(1)* %b) {
  %loada = load i64 addrspace(1)* %a, align 4
  %or = or i64 %loada, 1229782942255902721 ; 0x11111111ffff7001
  store i64 %or, i64 addrspace(1)* %out
  ret void
}
