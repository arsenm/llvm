; RUN: llvm-link %S/Inputs/opencl.ocl.version.a.ll %S/Inputs/opencl.ocl.version.b.ll % -S | FileCheck %s

; Verify that multiple input opencl.ocl.version metadata are linked together, but uniqued.

