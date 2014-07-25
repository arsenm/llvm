; RUN: llc -march=r600 -mcpu=SI -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s

; SI-LABEL: @sext_bool_icmp_eq_0
; SI: V_CMP_NE_I32
; SI-NEXT: V_CNDMASK_B32
; SI-NOT: CMP
; SI-NOT: CNDMASK
; SI: S_ENDPGM
define void @sext_bool_icmp_eq_0(i1 addrspace(1)* %out, i32 %a, i32 %b) nounwind {
  %icmp0 = icmp ne i32 %a, %b
  %ext = sext i1 %icmp0 to i32
  %icmp1 = icmp ne i32 %ext, 0
  store i1 %icmp1, i1 addrspace(1)* %out
  ret void
}

; SI-LABEL: @sext_bool_icmp_ne_0
; SI: V_CMP_NE_I32
; SI-NEXT: V_CNDMASK_B32
; SI-NOT: CMP
; SI-NOT: CNDMASK
; SI: S_ENDPGM
define void @sext_bool_icmp_ne_0(i1 addrspace(1)* %out, i32 %a, i32 %b) nounwind {
  %icmp0 = icmp ne i32 %a, %b
  %ext = sext i1 %icmp0 to i32
  %icmp1 = icmp ne i32 %ext, 0
  store i1 %icmp1, i1 addrspace(1)* %out
  ret void
}

; SI-LABEL: @sext_bool_icmp_eq_1
; SI: V_CMP_EQ_I32
; SI-NEXT: V_CNDMASK_B32
; SI-NOT: CMP
; SI-NOT: CNDMASK
; SI: S_ENDPGM
define void @sext_bool_icmp_eq_1(i1 addrspace(1)* %out, i32 %a, i32 %b) nounwind {
  %icmp0 = icmp eq i32 %a, %b
  %ext = sext i1 %icmp0 to i32
  %icmp1 = icmp eq i32 %ext, 1
  store i1 %icmp1, i1 addrspace(1)* %out
  ret void
}

; SI-LABEL: @sext_bool_icmp_ne_1
; SI: V_CMP_EQ_I32
; SI-NEXT: V_CNDMASK_B32
; SI-NOT: CMP
; SI-NOT: CNDMASK
; SI: S_ENDPGM
define void @sext_bool_icmp_ne_1(i1 addrspace(1)* %out, i32 %a, i32 %b) nounwind {
  %icmp0 = icmp ne i32 %a, %b
  %ext = sext i1 %icmp0 to i32
  %icmp1 = icmp ne i32 %ext, 1
  store i1 %icmp1, i1 addrspace(1)* %out
  ret void
}

; SI-LABEL: @zext_bool_icmp_eq_0
; SI: V_CMP_NE_I32
; SI-NEXT: V_CNDMASK_B32
; SI-NOT: CMP
; SI-NOT: CNDMASK
; SI: S_ENDPGM
define void @zext_bool_icmp_eq_0(i1 addrspace(1)* %out, i32 %a, i32 %b) nounwind {
  %icmp0 = icmp ne i32 %a, %b
  %ext = zext i1 %icmp0 to i32
  %icmp1 = icmp ne i32 %ext, 0
  store i1 %icmp1, i1 addrspace(1)* %out
  ret void
}

; SI-LABEL: @zext_bool_icmp_ne_0
; SI: V_CMP_NE_I32
; SI-NEXT: V_CNDMASK_B32
; SI-NOT: CMP
; SI-NOT: CNDMASK
; SI: S_ENDPGM
define void @zext_bool_icmp_ne_0(i1 addrspace(1)* %out, i32 %a, i32 %b) nounwind {
  %icmp0 = icmp ne i32 %a, %b
  %ext = zext i1 %icmp0 to i32
  %icmp1 = icmp ne i32 %ext, 0
  store i1 %icmp1, i1 addrspace(1)* %out
  ret void
}

; SI-LABEL: @zext_bool_icmp_eq_1
; SI: V_CMP_EQ_I32
; SI-NEXT: V_CNDMASK_B32
; SI-NOT: CMP
; SI-NOT: CNDMASK
; SI: S_ENDPGM
define void @zext_bool_icmp_eq_1(i1 addrspace(1)* %out, i32 %a, i32 %b) nounwind {
  %icmp0 = icmp eq i32 %a, %b
  %ext = zext i1 %icmp0 to i32
  %icmp1 = icmp eq i32 %ext, 1
  store i1 %icmp1, i1 addrspace(1)* %out
  ret void
}

; SI-LABEL: @zext_bool_icmp_ne_1
; SI: V_CMP_EQ_I32
; SI-NEXT: V_CNDMASK_B32
; SI-NOT: CMP
; SI-NOT: CNDMASK
; SI: S_ENDPGM
define void @zext_bool_icmp_ne_1(i1 addrspace(1)* %out, i32 %a, i32 %b) nounwind {
  %icmp0 = icmp ne i32 %a, %b
  %ext = zext i1 %icmp0 to i32
  %icmp1 = icmp ne i32 %ext, 1
  store i1 %icmp1, i1 addrspace(1)* %out
  ret void
}

; SI-LABEL: @sext_bool_icmp_ne_k
; SI: V_CMP_EQ_I32
; SI-NEXT: V_CNDMASK_B32
; SI-NOT: CMP
; SI-NOT: CNDMASK
; SI: S_ENDPGM
define void @sext_bool_icmp_ne_k(i1 addrspace(1)* %out, i32 %a, i32 %b) nounwind {
  %icmp0 = icmp ne i32 %a, %b
  %ext = sext i1 %icmp0 to i32
  %icmp1 = icmp ne i32 %ext, 2
  store i1 %icmp1, i1 addrspace(1)* %out
  ret void
}


define void @cmp_zext_k(i1 addrspace(1)* %out, i32 %a, i8 %b) nounwind {
  %b.ext = zext i8 %b to i32
  %icmp0 = icmp ne i32 %b.ext, 255
  store i1 %icmp0, i1 addrspace(1)* %out
  ret void
}

define void @cmp_sext_k(i1 addrspace(1)* %out, i32 %a, i8 %b) nounwind {
  %b.ext = sext i8 %b to i32
  %icmp0 = icmp ne i32 %b.ext, -1
  store i1 %icmp0, i1 addrspace(1)* %out
  ret void
}
