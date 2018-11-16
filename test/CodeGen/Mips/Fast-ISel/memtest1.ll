; RUN: llc < %s -march=mipsel -mcpu=mips32 -O0 -relocation-model=pic \
; RUN:     -fast-isel-abort=3 -verify-machineinstrs | FileCheck %s \
; RUN:     -check-prefix=ALL -check-prefix=32R1
; RUN: llc < %s -march=mipsel -mcpu=mips32r2 -O0 -relocation-model=pic \
; RUN:     -fast-isel-abort=3 -verify-machineinstrs | FileCheck %s \
; RUN:     -check-prefix=ALL -check-prefix=32R2

@str = private unnamed_addr constant [12 x i8] c"hello there\00", align 1
@src = global i8* getelementptr inbounds ([12 x i8], [12 x i8]* @str, i32 0, i32 0), align 4
@i = global i32 12, align 4
@dest = common global [50 x i8] zeroinitializer, align 1

declare void @llvm.memcpy.p0i8.p0i8.i32(i8* nocapture, i8* nocapture readonly, i32, i1)
declare void @llvm.memmove.p0i8.p0i8.i32(i8* nocapture, i8* nocapture readonly, i32, i1)
declare void @llvm.memset.p0i8.i32(i8* nocapture, i8, i32, i1)

define void @cpy(i8* %src, i32 %i) {
  ; ALL-LABEL:  cpy:

  ; ALL-DAG:        move  $6, $5
  ; ALL-DAG:        move  $5, $4
  ; ALL-DAG:        lw    $4, %got(dest)(${{[0-9]+}})
  ; ALL-DAG:        lw    $[[T0:[0-9]+]], %got(memcpy)($1)
  ; ALL:            jalr  $[[T0]]
  ; ALL-NEXT:       nop
  ; ALL-NOT:        {{.*}}$2{{.*}}
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* getelementptr inbounds ([50 x i8], [50 x i8]* @dest, i32 0, i32 0), i8* %src, i32 %i, i1 false)
  ret void
}

define void @mov(i8* %src, i32 %i) {
  ; ALL-LABEL:  mov:


  ; ALL-DAG:        move  $6, $5
  ; ALL-DAG:        move  $5, $4
  ; ALL-DAG:        lw    $4, %got(dest)(${{[0-9]+}})
  ; ALL-DAG:        lw    $[[T0:[0-9]+]], %got(memmove)(${{[0-9]+}})
  ; ALL:            jalr  $[[T0]]
  ; ALL-NEXT:       nop
  ; ALL-NOT:        {{.*}}$2{{.*}}
  call void @llvm.memmove.p0i8.p0i8.i32(i8* getelementptr inbounds ([50 x i8], [50 x i8]* @dest, i32 0, i32 0), i8* %src, i32 %i, i1 false)
  ret void
}

define void @clear(i32 %i) {
  ; ALL-LABEL:  clear:

  ; ALL-DAG:        lw    $4, %got(dest)(${{[0-9]+}})
  ; ALL-DAG:        move  $6, $4
  ; ALL-DAG:        addiu $[[T1:[0-9]+]], $zero, 42
  ; 32R1-DAG:       sll   $[[T2:[0-9]+]], $[[T1]], 24
  ; 32R1-DAG:       sra   $5, $[[T2]], 24
  ; 32R2-DAG:       seb   $5, $[[T1]]
  ; ALL-DAG:        lw    $[[T2:[0-9]+]], %got(memset)(${{[0-9]+}})
  ; ALL:            jalr  $[[T2]]
  ; ALL-NEXT:       nop
  ; ALL-NOT:        {{.*}}$2{{.*}}
  call void @llvm.memset.p0i8.i32(i8* getelementptr inbounds ([50 x i8], [50 x i8]* @dest, i32 0, i32 0), i8 42, i32 %i, i1 false)
  ret void
}
