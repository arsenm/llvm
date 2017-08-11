; RUN: llc -march=amdgcn -mcpu=fiji -mattr=-flat-for-global -tailcallopt -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=GCN,VI,MESA %s
; RUN: llc -march=amdgcn -mcpu=hawaii -tailcallopt -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=GCN,CI,MESA %s
; RUN: llc -march=amdgcn -mcpu=gfx900 -mattr=-flat-for-global -tailcallopt -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=GCN,GFX9,VI,MESA %s


define fastcc i32 @i32_fastcc_i32_i32_a32i32(i32 %arg0, i32 %arg1, [32 x i32] %large) #1 {
  %val_firststack = extractvalue [32 x i32] %large, 30
  %val_laststack = extractvalue [32 x i32] %large, 31
  %add0 = add i32 %arg0, %arg1
  %add1 = add i32 %add0, %val_firststack
  %add2 = add i32 %add1, %val_laststack
  ret i32 %add2
}

; GCN-LABEL: {{^}}tail_call_i32_fastcc_i32_i32_a32i32:
; GCN: s_mov_b32 s5, s32

; GCN-DAG: buffer_store_dword v32, off, s[0:3], s5 offset:16 ; 4-byte Folded Spill
; GCN-DAG: buffer_store_dword v33, off, s[0:3], s5 offset:12 ; 4-byte Folded Spill

; GCN-DAG: buffer_load_dword [[LOAD_0:v[0-9]+]], off, s[0:3], s5 offset:4
; GCN-DAG: buffer_load_dword [[LOAD_1:v[0-9]+]], off, s[0:3], s5 offset:8

; GCN-NOT: s32

; GCN-DAG: buffer_store_dword [[LOAD_0]], off, s[0:3], s5 offset:4
; GCN-DAG: buffer_store_dword [[LOAD_1]], off, s[0:3], s5 offset:8

; GCN-DAG: buffer_load_dword v32, off, s[0:3], s5 offset:16 ; 4-byte Folded Reload
; GCN-DAG: buffer_load_dword v33, off, s[0:3], s5 offset:12 ; 4-byte Folded Reload

; GCN-NOT: s32
; GCN: s_setpc_b64
define fastcc i32 @tail_call_i32_fastcc_i32_i32_a32i32_fpdiff(i32 %a, i32 %b, [36 x i32] %c) #1 {
entry:
  %ret = tail call fastcc i32 @i32_fastcc_i32_i32_a32i32(i32 %a, i32 %b, [32 x i32] zeroinitializer)
  ret i32 %ret
}

attributes #0 = { nounwind }
attributes #1 = { nounwind noinline }
