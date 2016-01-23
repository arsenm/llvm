; RUN: llc -march=amdgcn -mcpu=verde -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck %s

; CHECK-LABEL: {{^}}main:
; CHECK: s_mov_b32 m0, 0
; CHECK-NOT: s_mov_b32 m0
; CHECK: s_sendmsg Gs(emit stream 0)
; CHECK: s_sendmsg Gs(cut stream 1)
; CHECK: s_sendmsg Gs(emit-cut stream 2)
; CHECK: s_sendmsg Gs_done(nop)

define void @main() {
main_body:
  call void @llvm.amdgcn.s.sendmsg(i32 34)
  call void @llvm.amdgcn.s.sendmsg(i32 274)
  call void @llvm.amdgcn.s.sendmsg(i32 562)
  call void @llvm.amdgcn.s.sendmsg(i32 3)
  ret void
}

; Function Attrs: nounwind
declare void @llvm.amdgcn.s.sendmsg(i32) #0

attributes #0 = { nounwind }
