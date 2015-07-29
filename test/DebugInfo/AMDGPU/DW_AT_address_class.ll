; ModuleID = '/home/marsenau/src/llvm/tools/clang/test/CodeGenOpenCL/addrspace-debug-info.cl'
target datalayout = "e-p:32:32-p1:64:64-p2:64:64-p3:32:32-p4:64:64-p5:32:32-p24:64:64-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64"
target triple = "amdgcn-unknown-amdhsa"

%struct.Foo = type { i32 addrspace(2)* }

@gconstint = addrspace(2) constant i32 2, align 4
@globalstruct = addrspace(2) constant %struct.Foo { i32 addrspace(2)* @gconstint }, align 4

; Function Attrs: nounwind
define void @ptr_types_debuginfo(i32 addrspace(1)* %globalptr_arg, i32 addrspace(2)* %constantptr_arg, i32 addrspace(3)* %localptr_arg) #0 {
entry:
  %globalptr_arg.addr = alloca i32 addrspace(1)*, align 4
  %constantptr_arg.addr = alloca i32 addrspace(2)*, align 4
  %localptr_arg.addr = alloca i32 addrspace(3)*, align 4
  %privateptr = alloca i32*, align 4
  %genericptr = alloca i32*, align 4
  store i32 addrspace(1)* %globalptr_arg, i32 addrspace(1)** %globalptr_arg.addr, align 4
  call void @llvm.dbg.declare(metadata i32 addrspace(1)** %globalptr_arg.addr, metadata !27, metadata !28), !dbg !29
  store i32 addrspace(2)* %constantptr_arg, i32 addrspace(2)** %constantptr_arg.addr, align 4
  call void @llvm.dbg.declare(metadata i32 addrspace(2)** %constantptr_arg.addr, metadata !30, metadata !28), !dbg !31
  store i32 addrspace(3)* %localptr_arg, i32 addrspace(3)** %localptr_arg.addr, align 4
  call void @llvm.dbg.declare(metadata i32 addrspace(3)** %localptr_arg.addr, metadata !32, metadata !28), !dbg !33
  call void @llvm.dbg.declare(metadata i32** %privateptr, metadata !34, metadata !28), !dbg !36
  store i32* null, i32** %privateptr, align 4, !dbg !36
  call void @llvm.dbg.declare(metadata i32** %genericptr, metadata !37, metadata !28), !dbg !38
  store i32* null, i32** %genericptr, align 4, !dbg !38
  %0 = load i32 addrspace(2)*, i32 addrspace(2)** %constantptr_arg.addr, align 4, !dbg !39
  %1 = load i32, i32 addrspace(2)* %0, align 4, !dbg !39
  %2 = load i32 addrspace(1)*, i32 addrspace(1)** %globalptr_arg.addr, align 4, !dbg !39
  store i32 %1, i32 addrspace(1)* %2, align 4, !dbg !39
  %3 = load i32 addrspace(3)*, i32 addrspace(3)** %localptr_arg.addr, align 4, !dbg !40
  store i32 3, i32 addrspace(3)* %3, align 4, !dbg !40
  ret void, !dbg !41
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

attributes #0 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }

!llvm.dbg.cu = !{!0}
!opencl.kernels = !{!18}
!llvm.module.flags = !{!24, !25}
!llvm.ident = !{!26}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.8.0  (llvm/trunk 243556)", isOptimized: false, runtimeVersion: 0, emissionKind: 1, enums: !2, subprograms: !3, globals: !12)
!1 = !DIFile(filename: "/home/marsenau/src/llvm/tools/clang/test/CodeGenOpenCL/<stdin>", directory: "/home/marsenau/src/llvm/build_debug")
!2 = !{}
!3 = !{!4}
!4 = !DISubprogram(name: "ptr_types_debuginfo", scope: !5, file: !5, line: 22, type: !6, isLocal: false, isDefinition: true, scopeLine: 25, flags: DIFlagPrototyped, isOptimized: false, function: void (i32 addrspace(1)*, i32 addrspace(2)*, i32 addrspace(3)*)* @ptr_types_debuginfo, variables: !2)
!5 = !DIFile(filename: "/home/marsenau/src/llvm/tools/clang/test/CodeGenOpenCL/addrspace-debug-info.cl", directory: "/home/marsenau/src/llvm/build_debug")
!6 = !DISubroutineType(types: !7)
!7 = !{null, !8, !10, !11}
!8 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !9, size: 64, align: 32, extraData: i32 1)
!9 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!10 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !9, size: 64, align: 32, extraData: i32 2)
!11 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !9, size: 32, align: 32, extraData: i32 3)
!12 = !{!13, !14}
!13 = !DIGlobalVariable(name: "gconstint", scope: !0, file: !5, line: 38, type: !9, isLocal: false, isDefinition: true, variable: i32 addrspace(2)* @gconstint)
!14 = !DIGlobalVariable(name: "globalstruct", scope: !0, file: !5, line: 39, type: !15, isLocal: false, isDefinition: true, variable: %struct.Foo addrspace(2)* @globalstruct)
!15 = !DICompositeType(tag: DW_TAG_structure_type, name: "Foo", file: !5, line: 33, size: 64, align: 32, elements: !16)
!16 = !{!17}
!17 = !DIDerivedType(tag: DW_TAG_member, name: "memberptr", scope: !15, file: !5, line: 34, baseType: !10, size: 64, align: 32)
!18 = !{void (i32 addrspace(1)*, i32 addrspace(2)*, i32 addrspace(3)*)* @ptr_types_debuginfo, !19, !20, !21, !22, !23}
!19 = !{!"kernel_arg_addr_space", i32 1, i32 2, i32 3}
!20 = !{!"kernel_arg_access_qual", !"none", !"none", !"none"}
!21 = !{!"kernel_arg_type", !"int*", !"int*", !"int*"}
!22 = !{!"kernel_arg_base_type", !"int*", !"int*", !"int*"}
!23 = !{!"kernel_arg_type_qual", !"", !"const", !""}
!24 = !{i32 2, !"Dwarf Version", i32 4}
!25 = !{i32 2, !"Debug Info Version", i32 3}
!26 = !{!"clang version 3.8.0  (llvm/trunk 243556)"}
!27 = !DILocalVariable(tag: DW_TAG_arg_variable, name: "globalptr_arg", arg: 1, scope: !4, file: !5, line: 22, type: !8)
!28 = !DIExpression()
!29 = !DILocation(line: 22, scope: !4)
!30 = !DILocalVariable(tag: DW_TAG_arg_variable, name: "constantptr_arg", arg: 2, scope: !4, file: !5, line: 23, type: !10)
!31 = !DILocation(line: 23, scope: !4)
!32 = !DILocalVariable(tag: DW_TAG_arg_variable, name: "localptr_arg", arg: 3, scope: !4, file: !5, line: 24, type: !11)
!33 = !DILocation(line: 24, scope: !4)
!34 = !DILocalVariable(tag: DW_TAG_auto_variable, name: "privateptr", scope: !4, file: !5, line: 26, type: !35)
!35 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !9, size: 32, align: 32)
!36 = !DILocation(line: 26, scope: !4)
!37 = !DILocalVariable(tag: DW_TAG_auto_variable, name: "genericptr", scope: !4, file: !5, line: 27, type: !35)
!38 = !DILocation(line: 27, scope: !4)
!39 = !DILocation(line: 29, scope: !4)
!40 = !DILocation(line: 30, scope: !4)
!41 = !DILocation(line: 31, scope: !4)
