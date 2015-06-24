; RUN: llc -march=amdgcn -mcpu=tahiti -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s

declare void @llvm.AMDGPU.barrier.global() #1

; GCN-LABEL: {{^}}merge_global_load_2_i32:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: v_add_i32_e32 [[ADD:v[0-9]+]], v[[X0]], v[[X1]]
; GCN: buffer_store_dword [[ADD]]
define void @merge_global_load_2_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in) #0 {
entry:
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %lo = load i32, i32 addrspace(1)* %in
  %hi = load i32, i32 addrspace(1)* %in.gep.1

  %add = add i32 %lo, %hi
  store i32 %add, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_2_f32:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: v_add_f32_e32 [[ADD:v[0-9]+]], v[[X1]], v[[X0]]
; GCN: buffer_store_dword [[ADD]]
define void @merge_global_load_2_f32(float addrspace(1)* %out, float addrspace(1)* %in) #0 {
entry:
  %out.gep.1 = getelementptr float, float addrspace(1)* %out, i32 1
  %in.gep.1 = getelementptr float, float addrspace(1)* %in, i32 1
  %lo = load float, float addrspace(1)* %in
  %hi = load float, float addrspace(1)* %in.gep.1

  %add = fadd float %lo, %hi
  store float %add, float addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_2_i32_f32:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: v_add_i32_e32 v[[IADD:[0-9]+]], 3, v[[X0]]
; GCN: v_add_f32_e32 [[ADD:v[0-9]+]], v[[X1]], v[[IADD]]
; GCN: buffer_store_dword [[ADD]]
define void @merge_global_load_2_i32_f32(float addrspace(1)* %out, float addrspace(1)* %in) #0 {
entry:
  %in.cast = bitcast float addrspace(1)* %in to i32 addrspace(1)*
  %out.gep.1 = getelementptr float, float addrspace(1)* %out, i32 1
  %in.gep.1 = getelementptr float, float addrspace(1)* %in, i32 1
  %lo = load i32, i32 addrspace(1)* %in.cast
  %hi = load float, float addrspace(1)* %in.gep.1
  %addi = add i32 %lo, 3
  %bc = bitcast i32 %addi to float
  %add = fadd float %bc, %hi
  store float %add, float addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_shuffle_2_i32:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: v_mov_b32_e32 v[[X0_SHUF:[0-9]+]], v[[X0]]

; GCN: buffer_store_dwordx2 v{{\[}}[[X1]]:[[X0_SHUF]]{{\]}}
define void @merge_global_load_shuffle_2_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %lo = load i32, i32 addrspace(1)* %in
  %hi = load i32, i32 addrspace(1)* %in.gep.1

  ; Shuffle order so we just get the merge
  store i32 %lo, i32 addrspace(1)* %out.gep.1
  store i32 %hi, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_shuffle_alias_2_i32:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN-DAG: buffer_store_dword v[[X1]], s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN-DAG: buffer_store_dword v[[X0]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:4{{$}}
; GCN: s_endpgm
define void @merge_global_load_shuffle_alias_2_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in) #0 {
entry:
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %lo = load i32, i32 addrspace(1)* %in
  %hi = load i32, i32 addrspace(1)* %in.gep.1

  ; Shuffle order so we just get the merge
  store i32 %lo, i32 addrspace(1)* %out.gep.1
  store i32 %hi, i32 addrspace(1)* %out
  ret void
}
; Merge adjacent loads where the base address has a non-zero offset.

; GCN-LABEL: {{^}}merge_global_load_2_i32_offset:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:8{{$}}
; GCN: v_add_i32_e32 [[ADD:v[0-9]+]], v[[X1]], v[[X0]]
; GCN: buffer_store_dword [[ADD]]
define void @merge_global_load_2_i32_offset(i32 addrspace(1)* %out, i32 addrspace(1)* %in) #0 {
entry:
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1

  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3

  %ld.2 = load i32, i32 addrspace(1)* %in.gep.2
  %ld.3 = load i32, i32 addrspace(1)* %in.gep.3

  %add = add i32 %ld.2, %ld.3
  store i32 %add, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_store_4_shuffle_i32:
; GCN: buffer_load_dwordx4 v{{\[}}[[X0:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN-DAG: v_mov_b32_e32 v{{[0-9]+}}, v{{[0-9]+}}
; GCN-DAG: v_mov_b32_e32 v{{[0-9]+}}, v{{[0-9]+}}
; GCN-DAG: v_mov_b32_e32 v[[X0_SHUF:[0-9]+]], v[[X0]]
; GCN: buffer_store_dwordx4 v{{\[}}[[X3]]:[[X0_SHUF]]{{\]}}
; GCN: s_endpgm
define void @merge_global_load_store_4_shuffle_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in) #0 {
entry:
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %out.gep.2 = getelementptr i32, i32 addrspace(1)* %out, i32 2
  %out.gep.3 = getelementptr i32, i32 addrspace(1)* %out, i32 3

  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3

  %ld.0 = load i32, i32 addrspace(1)* %in
  %ld.1 = load i32, i32 addrspace(1)* %in.gep.1
  %ld.2 = load i32, i32 addrspace(1)* %in.gep.2
  %ld.3 = load i32, i32 addrspace(1)* %in.gep.3

  store i32 %ld.3, i32 addrspace(1)* %out
  store i32 %ld.2, i32 addrspace(1)* %out.gep.1
  store i32 %ld.1, i32 addrspace(1)* %out.gep.2
  store i32 %ld.0, i32 addrspace(1)* %out.gep.3

  ret void
}

; GCN-LABEL: {{^}}merge_global_load_4_i32:
; GCN: buffer_load_dwordx4 v{{\[}}[[X0:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v{{[0-9]+}}
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v{{[0-9]+}}, [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD0]]
; GCN: buffer_store_dword [[ADD2]]
define void @merge_global_load_4_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_5_i32:
; GCN: buffer_load_dwordx4 v{{\[}}[[X0:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v[[X4:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:16{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v{{[0-9]+}}
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v{{[0-9]+}}, [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: v_add_i32_e32 [[ADD3:v[0-9]+]], v[[X4]], [[ADD2]]
; GCN: buffer_store_dword [[ADD3]]
define void @merge_global_load_5_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %in.gep.4 = getelementptr i32, i32 addrspace(1)* %in, i32 4
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3
  %x4 = load i32, i32 addrspace(1)* %in.gep.4

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  %add3 = add i32 %add2, %x4
  store i32 %add3, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_6_i32:
; GCN: buffer_load_dwordx4 v{{\[}}[[X0:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dwordx2 v{{\[}}[[X4:[0-9]+]]:[[X5:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:16{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v{{[0-9]+}}
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v{{[0-9]+}}, [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: v_add_i32_e32 [[ADD3:v[0-9]+]], v[[X4]], [[ADD2]]
; GCN: v_add_i32_e32 [[ADD4:v[0-9]+]], v[[X5]], [[ADD3]]
; GCN: buffer_store_dword [[ADD4]]
define void @merge_global_load_6_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %in.gep.4 = getelementptr i32, i32 addrspace(1)* %in, i32 4
  %in.gep.5 = getelementptr i32, i32 addrspace(1)* %in, i32 5
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3
  %x4 = load i32, i32 addrspace(1)* %in.gep.4
  %x5 = load i32, i32 addrspace(1)* %in.gep.5

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  %add3 = add i32 %add2, %x4
  %add4 = add i32 %add3, %x5
  store i32 %add4, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_7_i32:
; GCN: buffer_load_dwordx4 v{{\[}}[[X0:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dwordx2 v{{\[}}[[X4:[0-9]+]]:[[X5:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:16{{$}}
; GCN: buffer_load_dword v[[X6:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:24{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v{{[0-9]+}}
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v{{[0-9]+}}, [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: v_add_i32_e32 [[ADD3:v[0-9]+]], v[[X4]], [[ADD2]]
; GCN: v_add_i32_e32 [[ADD4:v[0-9]+]], v[[X5]], [[ADD3]]
; GCN: v_add_i32_e32 [[ADD5:v[0-9]+]], v[[X6]], [[ADD4]]
; GCN: buffer_store_dword [[ADD5]]
define void @merge_global_load_7_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %in.gep.4 = getelementptr i32, i32 addrspace(1)* %in, i32 4
  %in.gep.5 = getelementptr i32, i32 addrspace(1)* %in, i32 5
  %in.gep.6 = getelementptr i32, i32 addrspace(1)* %in, i32 6
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3
  %x4 = load i32, i32 addrspace(1)* %in.gep.4
  %x5 = load i32, i32 addrspace(1)* %in.gep.5
  %x6 = load i32, i32 addrspace(1)* %in.gep.6

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  %add3 = add i32 %add2, %x4
  %add4 = add i32 %add3, %x5
  %add5 = add i32 %add4, %x6
  store i32 %add5, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_8_i32:
; GCN: buffer_load_dwordx4 v{{\[}}[[X0:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dwordx4 v{{\[}}[[X4:[0-9]+]]:[[X7:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:16{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v{{[0-9]+}}
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v{{[0-9]+}}, [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: v_add_i32_e32 [[ADD3:v[0-9]+]], v[[X4]], [[ADD2]]
; GCN: v_add_i32_e32 [[ADD4:v[0-9]+]], v{{[0-9]+}}, [[ADD3]]
; GCN: v_add_i32_e32 [[ADD5:v[0-9]+]], v{{[0-9]+}}, [[ADD4]]
; GCN: v_add_i32_e32 [[ADD6:v[0-9]+]], v[[X7]], [[ADD5]]
; GCN: buffer_store_dword [[ADD5]]
define void @merge_global_load_8_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %in.gep.4 = getelementptr i32, i32 addrspace(1)* %in, i32 4
  %in.gep.5 = getelementptr i32, i32 addrspace(1)* %in, i32 5
  %in.gep.6 = getelementptr i32, i32 addrspace(1)* %in, i32 6
  %in.gep.7 = getelementptr i32, i32 addrspace(1)* %in, i32 7
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3
  %x4 = load i32, i32 addrspace(1)* %in.gep.4
  %x5 = load i32, i32 addrspace(1)* %in.gep.5
  %x6 = load i32, i32 addrspace(1)* %in.gep.6
  %x7 = load i32, i32 addrspace(1)* %in.gep.7

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  %add3 = add i32 %add2, %x4
  %add4 = add i32 %add3, %x5
  %add5 = add i32 %add4, %x6
  %add6 = add i32 %add5, %x7
  store i32 %add6, i32 addrspace(1)* %out
  ret void
}

; FIXME: Should look ahead to adjacent sequence
; GCN-LABEL: {{^}}merge_global_load_4_i32_gap_0_1:
; GCN: buffer_load_dword
; GCN: buffer_load_dword
; GCN: buffer_load_dword
; GCN: buffer_load_dword
; GCN: buffer_store_dword v
define void @merge_global_load_4_i32_gap_0_1(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %in.gep.4 = getelementptr i32, i32 addrspace(1)* %in, i32 4
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.2
  %x2 = load i32, i32 addrspace(1)* %in.gep.3
  %x3 = load i32, i32 addrspace(1)* %in.gep.4

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_4_i32_gap_1_2:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dwordx2 v{{\[}}[[X2:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:12{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v[[X1]]
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v[[X2]], [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: buffer_store_dword [[ADD2]]
define void @merge_global_load_4_i32_gap_1_2(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %in.gep.4 = getelementptr i32, i32 addrspace(1)* %in, i32 4
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.3
  %x3 = load i32, i32 addrspace(1)* %in.gep.4

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_4_i32_gap_2_3:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v[[X2:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:8{{$}}
; GCN: buffer_load_dword v[[X3:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:16{{$}}

; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v[[X1]]
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v[[X2]], [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: buffer_store_dword [[ADD2]]
define void @merge_global_load_4_i32_gap_2_3(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.4 = getelementptr i32, i32 addrspace(1)* %in, i32 4
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.4

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_4_barrier_i32:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: s_barrier
; GCN: buffer_load_dwordx2 v{{\[}}[[X2:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:8{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v[[X1]]
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v[[X2]], [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: buffer_store_dword [[ADD2]]
define void @merge_global_load_4_barrier_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  call void @llvm.AMDGPU.barrier.global()
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_4_volatile_0_i32:
; GCN: buffer_load_dword v[[X0:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dwordx2 v{{\[}}[[X1:[0-9]+]]:[[X2:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:4{{$}}
; GCN: buffer_load_dword v[[X3:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:12{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v[[X1]]
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v[[X2]], [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: buffer_store_dword [[ADD2]]
define void @merge_global_load_4_volatile_0_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %x0 = load volatile i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}

; FIXME: We could merge the last 2 loads
; GCN-LABEL: {{^}}merge_global_load_4_volatile_1_i32:
; GCN: buffer_load_dword v[[X0:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v[[X1:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:4{{$}}
; GCN: buffer_load_dword v[[X2:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:8{{$}}
; GCN: buffer_load_dword v[[X3:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:12{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X1]], v[[X0]]
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v[[X2]], [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: buffer_store_dword [[ADD2]]
define void @merge_global_load_4_volatile_1_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load volatile i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_4_volatile_2_i32:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v[[X2:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:8{{$}}
; GCN: buffer_load_dword v[[X3:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:12{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v[[X1]]
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v[[X2]], [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: buffer_store_dword [[ADD2]]
define void @merge_global_load_4_volatile_2_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load volatile i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_4_volatile_3_i32:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v[[X2:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:8{{$}}
; GCN: buffer_load_dword v[[X3:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:12{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v[[X1]]
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v[[X2]], [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: buffer_store_dword [[ADD2]]
define void @merge_global_load_4_volatile_3_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load volatile i32, i32 addrspace(1)* %in.gep.3

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_volatile_alias_load_2_i32:
; GCN: buffer_load_dword v{{[0-9]+}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v{{[0-9]+}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v{{[0-9]+}}, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:4{{$}}
; GCN: buffer_store_dword
define void @merge_global_volatile_alias_load_2_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in) #0 {
entry:
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %lo = load i32, i32 addrspace(1)* %in
  %lo.volatile = load volatile i32, i32 addrspace(1)* %in
  %hi = load i32, i32 addrspace(1)* %in.gep.1

  %add0 = add i32 %lo, %hi
  %add1 = add i32 %add0, %lo.volatile
  store i32 %add1, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_volatile_alias_load_2_before_i32:
; GCN: buffer_load_dword v{{[0-9]+}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_store_dword
define void @merge_global_volatile_alias_load_2_before_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in) #0 {
entry:
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %lo.volatile = load volatile i32, i32 addrspace(1)* %in
  %lo = load i32, i32 addrspace(1)* %in
  %hi = load i32, i32 addrspace(1)* %in.gep.1

  %add0 = add i32 %lo, %hi
  %add1 = add i32 %add0, %lo.volatile
  store i32 %add1, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_volatile_alias_load_2_after_i32:
; GCN: buffer_load_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v{{[0-9]+}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_store_dword
define void @merge_global_volatile_alias_load_2_after_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in) #0 {
entry:
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %lo = load i32, i32 addrspace(1)* %in
  %hi = load i32, i32 addrspace(1)* %in.gep.1
  %lo.volatile = load volatile i32, i32 addrspace(1)* %in

  %add0 = add i32 %lo, %hi
  %add1 = add i32 %add0, %lo.volatile
  store i32 %add1, i32 addrspace(1)* %out
  ret void
}

; Unrelated load in before
; GCN-LABEL: {{^}}merge_global_load_4_i32_independent_load_before:
; GCN: buffer_load_dwordx4 v{{\[}}[[X0:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v[[X4:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:60{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v{{[0-9]+}}
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v{{[0-9]+}}, [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: v_add_i32_e32 [[ADD3:v[0-9]+]], v[[X4]], [[ADD2]]
; GCN: buffer_store_dword [[ADD3]]
define void @merge_global_load_4_i32_independent_load_before(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in, i32 addrspace(1)* noalias %other) #0 {
entry:
  %other.gep = getelementptr i32, i32 addrspace(1)* %other, i32 15
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %y = load i32, i32 addrspace(1)* %other.gep
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  %add3 = add i32 %add2, %y
  store i32 %add3, i32 addrspace(1)* %out
  ret void
}

; Unrelated load between 1st and 2nd load.
; GCN-LABEL: {{^}}merge_global_load_4_i32_independent_load_0_1:
; GCN: buffer_load_dwordx4 v{{\[}}[[X0:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v[[X4:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:60{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v{{[0-9]+}}
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v{{[0-9]+}}, [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: v_add_i32_e32 [[ADD3:v[0-9]+]], v[[X4]], [[ADD2]]
; GCN: buffer_store_dword [[ADD3]]
define void @merge_global_load_4_i32_independent_load_0_1(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in, i32 addrspace(1)* noalias %other) #0 {
entry:
  %other.gep = getelementptr i32, i32 addrspace(1)* %other, i32 15
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %x0 = load i32, i32 addrspace(1)* %in
  %y = load i32, i32 addrspace(1)* %other.gep
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  %add3 = add i32 %add2, %y
  store i32 %add3, i32 addrspace(1)* %out
  ret void
}

; Unrelated load between 2nd and 3rd load.
; GCN-LABEL: {{^}}merge_global_load_4_i32_independent_load_1_2:
; GCN: buffer_load_dwordx4 v{{\[}}[[X0:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v[[X4:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:60{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v{{[0-9]+}}
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v{{[0-9]+}}, [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: v_add_i32_e32 [[ADD3:v[0-9]+]], v[[X4]], [[ADD2]]
; GCN: buffer_store_dword [[ADD3]]
define void @merge_global_load_4_i32_independent_load_1_2(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in, i32 addrspace(1)* noalias %other) #0 {
entry:
  %other.gep = getelementptr i32, i32 addrspace(1)* %other, i32 15
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %y = load i32, i32 addrspace(1)* %other.gep
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  %add3 = add i32 %add2, %y
  store i32 %add3, i32 addrspace(1)* %out
  ret void
}

; Unrelated load between 3rd and 4th load.
; GCN-LABEL: {{^}}merge_global_load_4_i32_independent_load_2_3:
; GCN: buffer_load_dwordx4 v{{\[}}[[X0:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v[[X4:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:60{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v{{[0-9]+}}
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v{{[0-9]+}}, [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: v_add_i32_e32 [[ADD3:v[0-9]+]], v[[X4]], [[ADD2]]
; GCN: buffer_store_dword [[ADD3]]
define void @merge_global_load_4_i32_independent_load_2_3(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in, i32 addrspace(1)* noalias %other) #0 {
entry:
  %other.gep = getelementptr i32, i32 addrspace(1)* %other, i32 15
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %y = load i32, i32 addrspace(1)* %other.gep
  %x3 = load i32, i32 addrspace(1)* %in.gep.3

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  %add3 = add i32 %add2, %y
  store i32 %add3, i32 addrspace(1)* %out
  ret void
}

; Unrelated after 4th load.
; GCN-LABEL: {{^}}merge_global_load_4_i32_independent_load_after:
; GCN: buffer_load_dwordx4 v{{\[}}[[X0:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v[[X4:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:60{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v{{[0-9]+}}
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v{{[0-9]+}}, [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: v_add_i32_e32 [[ADD3:v[0-9]+]], v[[X4]], [[ADD2]]
; GCN: buffer_store_dword [[ADD3]]
define void @merge_global_load_4_i32_independent_load_after(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in, i32 addrspace(1)* noalias %other) #0 {
entry:
  %other.gep = getelementptr i32, i32 addrspace(1)* %other, i32 15
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3
  %y = load i32, i32 addrspace(1)* %other.gep

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  %add3 = add i32 %add2, %y
  store i32 %add3, i32 addrspace(1)* %out
  ret void
}

; FIXME: Should really be able to merge all 4
; GCN-LABEL: {{^}}merge_global_load_4_i32_unrelated_store_1_2:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_load_dword v[[X2:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:8{{$}}
; GCN: buffer_load_dword v[[X3:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0 offset:12{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v[[X1]]
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v[[X2]], [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: buffer_store_dword [[ADD2]]
define void @merge_global_load_4_i32_unrelated_store_1_2(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in, i32 addrspace(1)* noalias %other) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(1)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(1)* %in, i32 3
  %x0 = load i32, i32 addrspace(1)* %in
  %x1 = load i32, i32 addrspace(1)* %in.gep.1
  store i32 1234, i32 addrspace(1)* %other
  %x2 = load i32, i32 addrspace(1)* %in.gep.2
  %x3 = load i32, i32 addrspace(1)* %in.gep.3

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_kernarg_load_2_i32:
; GCN: s_load_dwordx2 s{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0xb{{$}}
; GCN: s_add_i32 [[ADD:s[0-9]+]], s[[X0]], s[[X1]]
; GCN: v_mov_b32_e32 [[VADD:v[0-9]+]], [[ADD]]
; GCN: buffer_store_dword [[VADD]]
define void @merge_kernarg_load_2_i32(i32 addrspace(1)* %out, i32 %x0, i32 %x1) #0 {
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %add = add i32 %x0, %x1
  store i32 %add, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_kernarg_load_3_i32:
; GCN: s_load_dwordx2 s{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0xb{{$}}
; GCN: s_load_dword s[[X2:[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0xd{{$}}
; GCN: s_add_i32 [[ADD0:s[0-9]+]], s[[X0]], s[[X1]]
; GCN: s_add_i32 [[ADD1:s[0-9]+]], [[ADD0]], s[[X2]]
; GCN: v_mov_b32_e32 [[VADD1:v[0-9]+]], [[ADD1]]
; GCN: buffer_store_dword [[VADD1]]
define void @merge_kernarg_load_3_i32(i32 addrspace(1)* %out, i32 %x0, i32 %x1, i32 %x2) #0 {
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  store i32 %add1, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_kernarg_load_4_i32:
; GCN: s_load_dwordx4 s{{\[}}[[X0:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0xb{{$}}
; GCN: s_add_i32 [[ADD0:s[0-9]+]], s[[X0]], s{{[0-9]+}}
; GCN: s_add_i32 [[ADD1:s[0-9]+]], [[ADD0]], s{{[0-9]+}}
; GCN: s_add_i32 [[ADD2:s[0-9]+]], [[ADD1]], s[[X3]]
; GCN: v_mov_b32_e32 [[VADD2:v[0-9]+]], [[ADD2]]
; GCN: buffer_store_dword [[VADD2]]
define void @merge_kernarg_load_4_i32(i32 addrspace(1)* %out, i32 %x0, i32 %x1, i32 %x2, i32 %x3) #0 {
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_lds_load_2_i32:
; GCN: ds_read2_b32 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, {{v[0-9]+}} offset1:1{{$}}
; GCN: v_add_i32_e32 [[ADD:v[0-9]+]], v[[X0]], v[[X1]]
; GCN: buffer_store_dword [[ADD]]
define void @merge_lds_load_2_i32(i32 addrspace(1)* %out, i32 addrspace(3)* %in) #0 {
entry:
  %out.gep.1 = getelementptr i32, i32 addrspace(1)* %out, i32 1
  %in.gep.1 = getelementptr i32, i32 addrspace(3)* %in, i32 1
  %lo = load i32, i32 addrspace(3)* %in
  %hi = load i32, i32 addrspace(3)* %in.gep.1

  %add = add i32 %lo, %hi
  store i32 %add, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_lds_load_4_i32:
; GCN: ds_read2_b32 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, {{v[0-9]+}} offset1:1{{$}}
; GCN: ds_read2_b32 v{{\[}}[[X2:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, {{v[0-9]+}} offset0:2 offset1:3{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v{{[0-9]+}}
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v{{[0-9]+}}, [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: buffer_store_dword [[ADD2]]
define void @merge_lds_load_4_i32(i32 addrspace(1)* noalias %out, i32 addrspace(3)* noalias %in) #0 {
entry:
  %in.gep.1 = getelementptr i32, i32 addrspace(3)* %in, i32 1
  %in.gep.2 = getelementptr i32, i32 addrspace(3)* %in, i32 2
  %in.gep.3 = getelementptr i32, i32 addrspace(3)* %in, i32 3
  %x0 = load i32, i32 addrspace(3)* %in
  %x1 = load i32, i32 addrspace(3)* %in.gep.1
  %x2 = load i32, i32 addrspace(3)* %in.gep.2
  %x3 = load i32, i32 addrspace(3)* %in.gep.3

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}


; GCN-LABEL: {{^}}merge_global_load_2_lds_load_2_i32:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:8{{$}}
; GCN: ds_read2_b32 v{{\[}}[[X2:[0-9]+]]:[[X3:[0-9]+]]{{\]}}, {{v[0-9]+}} offset0:7 offset1:8{{$}}
; GCN: v_add_i32_e32 [[ADD0:v[0-9]+]], v[[X0]], v{{[0-9]+}}
; GCN: v_add_i32_e32 [[ADD1:v[0-9]+]], v{{[0-9]+}}, [[ADD0]]
; GCN: v_add_i32_e32 [[ADD2:v[0-9]+]], v[[X3]], [[ADD1]]
; GCN: buffer_store_dword [[ADD2]]
define void @merge_global_load_2_lds_load_2_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in.global, i32 addrspace(3)* %in.local) #0 {
entry:
  %in.global.gep.2 = getelementptr i32, i32 addrspace(1)* %in.global, i32 2
  %in.global.gep.3 = getelementptr i32, i32 addrspace(1)* %in.global, i32 3
  %in.local.gep.7 = getelementptr i32, i32 addrspace(3)* %in.local, i32 7
  %in.local.gep.8 = getelementptr i32, i32 addrspace(3)* %in.local, i32 8
  %x0 = load i32, i32 addrspace(1)* %in.global.gep.2
  %x2 = load i32, i32 addrspace(3)* %in.local.gep.7
  %x1 = load i32, i32 addrspace(1)* %in.global.gep.3
  %x3 = load i32, i32 addrspace(3)* %in.local.gep.8

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  store i32 %add2, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_global_load_4_lds_load_4_i32:
; GCN: buffer_load_dwordx4
; GCN: ds_read2_b32
; GCN: ds_read2_b32
define void @merge_global_load_4_lds_load_4_i32(i32 addrspace(1)* noalias %out, i32 addrspace(1)* noalias %in.global, i32 addrspace(3)* %in.local) #0 {
entry:
  %in.global.gep.2 = getelementptr i32, i32 addrspace(1)* %in.global, i32 2
  %in.global.gep.3 = getelementptr i32, i32 addrspace(1)* %in.global, i32 3
  %in.global.gep.4 = getelementptr i32, i32 addrspace(1)* %in.global, i32 4
  %in.global.gep.5 = getelementptr i32, i32 addrspace(1)* %in.global, i32 5
  %in.local.gep.7 = getelementptr i32, i32 addrspace(3)* %in.local, i32 7
  %in.local.gep.8 = getelementptr i32, i32 addrspace(3)* %in.local, i32 8
  %in.local.gep.9 = getelementptr i32, i32 addrspace(3)* %in.local, i32 9
  %in.local.gep.10 = getelementptr i32, i32 addrspace(3)* %in.local, i32 10
  %x0 = load i32, i32 addrspace(1)* %in.global.gep.2
  %x2 = load i32, i32 addrspace(3)* %in.local.gep.7
  %x1 = load i32, i32 addrspace(1)* %in.global.gep.3
  %x3 = load i32, i32 addrspace(3)* %in.local.gep.8
  %x4 = load i32, i32 addrspace(1)* %in.global.gep.4
  %x5 = load i32, i32 addrspace(1)* %in.global.gep.5
  %x6 = load i32, i32 addrspace(3)* %in.local.gep.9
  %x7 = load i32, i32 addrspace(3)* %in.local.gep.10

  %add0 = add i32 %x0, %x1
  %add1 = add i32 %add0, %x2
  %add2 = add i32 %add1, %x3
  %add3 = add i32 %add2, %x4
  %add4 = add i32 %add3, %x5
  %add5 = add i32 %add4, %x6
  %add6 = add i32 %add5, %x7
  store i32 %add6, i32 addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}merge_copy_global_to_lds_2_i32:
; GCN: buffer_load_dwordx2 v{{\[}}[[X0:[0-9]+]]:[[X1:[0-9]+]]{{\]}}, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:64{{$}}
; GCN: ds_write2_b32 v{{[0-9]+}}, v[[X0]], v[[X1]] offset0:12 offset1:13
define void @merge_copy_global_to_lds_2_i32(i32 addrspace(3)* noalias %out.lds, i32 addrspace(1)* noalias %in.global) #0 {
entry:
  %in.global.gep.2 = getelementptr i32, i32 addrspace(1)* %in.global, i32 16
  %in.global.gep.3 = getelementptr i32, i32 addrspace(1)* %in.global, i32 17

  %out.lds.gep.12 = getelementptr i32, i32 addrspace(3)* %out.lds, i32 12
  %out.lds.gep.13 = getelementptr i32, i32 addrspace(3)* %out.lds, i32 13

  %x0 = load i32, i32 addrspace(1)* %in.global.gep.2
  %x1 = load i32, i32 addrspace(1)* %in.global.gep.3

  store i32 %x0, i32 addrspace(3)* %out.lds.gep.12
  store i32 %x1, i32 addrspace(3)* %out.lds.gep.13
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { nounwind noduplicate convergent }
