; RUN: llvm-as < %s | llvm-dis | FileCheck %s
target datalayout = "i64:64:16"
; CHECK: target datalayout = "i64:64:16"
