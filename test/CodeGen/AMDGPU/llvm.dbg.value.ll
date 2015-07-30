; RUN: llc -O0 -march=amdgcn -mtriple=amdgcn-unknown-amdhsa -verify-machineinstrs < %s | FileCheck %s

; CHECK-LABEL: {{^}}test_debug_value:
; CHECK: s_load_dwordx2
; CHECK: DEBUG_VALUE: test_debug_value:globalptr_arg <- SGPR0_SGPR1
; CHECK: .loc	1 4 0 prologue_end      ; /tmp/simple_debug.cl:4:0
; CHECK: buffer_store_dword
; CHECK: .loc	1 5 0                   ; /tmp/simple_debug.cl:5:0
; CHECK: s_endpgm
define void @test_debug_value(i32 addrspace(1)* %globalptr_arg) #0 {
entry:
  call void @llvm.dbg.value(metadata i32 addrspace(1)* %globalptr_arg, i64 0, metadata !19, metadata !20), !dbg !21
  store i32 123, i32 addrspace(1)* %globalptr_arg, align 4, !dbg !22
  ret void, !dbg !23
}

declare void @llvm.dbg.value(metadata, i64, metadata, metadata) #1

attributes #0 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }

!llvm.dbg.cu = !{!0}
!opencl.kernels = !{!10}
!llvm.module.flags = !{!16, !17}
!llvm.ident = !{!18}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.8.0  (llvm/trunk 243556)", isOptimized: false, runtimeVersion: 0, emissionKind: 1, enums: !2, subprograms: !3)
!1 = !DIFile(filename: "/tmp/<stdin>", directory: "/home/marsenau/src/llvm/build_debug")
!2 = !{}
!3 = !{!4}
!4 = !DISubprogram(name: "test_debug_value", scope: !5, file: !5, line: 2, type: !6, isLocal: false, isDefinition: true, scopeLine: 3, flags: DIFlagPrototyped, isOptimized: false, function: void (i32 addrspace(1)*)* @test_debug_value, variables: !2)
!5 = !DIFile(filename: "/tmp/simple_debug.cl", directory: "/home/marsenau/src/llvm/build_debug")
!6 = !DISubroutineType(types: !7)
!7 = !{null, !8}
!8 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !9, size: 64, align: 32, extraData: i32 1)
!9 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!10 = !{void (i32 addrspace(1)*)* @test_debug_value, !11, !12, !13, !14, !15}
!11 = !{!"kernel_arg_addr_space", i32 1}
!12 = !{!"kernel_arg_access_qual", !"none"}
!13 = !{!"kernel_arg_type", !"int*"}
!14 = !{!"kernel_arg_base_type", !"int*"}
!15 = !{!"kernel_arg_type_qual", !""}
!16 = !{i32 2, !"Dwarf Version", i32 4}
!17 = !{i32 2, !"Debug Info Version", i32 3}
!18 = !{!"clang version 3.8.0  (llvm/trunk 243556)"}
!19 = !DILocalVariable(tag: DW_TAG_arg_variable, name: "globalptr_arg", arg: 1, scope: !4, file: !5, line: 2, type: !8)
!20 = !DIExpression()
!21 = !DILocation(line: 2, scope: !4)
!22 = !DILocation(line: 4, scope: !4)
!23 = !DILocation(line: 5, scope: !4)
