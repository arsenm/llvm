; RUN: llvm-as < %s | llvm-dis | FileCheck %s
target datalayout = "p:32:32:16"
; CHECK: target datalayout = "p:32:32:16"
