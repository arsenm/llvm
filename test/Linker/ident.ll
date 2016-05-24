; RUN: llvm-link %S/Inputs/ident.a.ll %S/Inputs/ident.b.ll %S/Inputs/ident.c.ll %S/Inputs/ident.a.ll -S | FileCheck %s

; Verify that multiple input llvm.ident metadata are linked together, but uniqued.

; CHECK-DAG: !llvm.ident = !{!0, !1, !2}
; CHECK-DAG: "Compiler V1"
; CHECK-DAG: "Compiler V2"
; CHECK-DAG: "Compiler V3"

