; RUN: opt < %s -basicaa -gvn -S | FileCheck %s

%t = type { i32 }
declare void @test1f(i8*)
declare void @test1f_nofence(i8*) nomemfence

; CHECK-LABEL: @test1
; CHECK: load
; CHECK: call
; CHECK: load
; CHECK: ret void
define void @test1(%t* noalias %stuff) {
  %p = getelementptr inbounds %t* %stuff, i32 0, i32 0
  %before = load i32* %p

  call void @test1f(i8* null)

  %after = load i32* %p ; <--- This should be a dead load
  %sum = add i32 %before, %after

  store i32 %sum, i32* %p
  ret void
}

; CHECK-LABEL: @test1_nofence
; CHECK: load
; CHECK-NOT: load
; CHECK: ret void
define void @test1_nofence(%t* noalias %stuff) {
  %p = getelementptr inbounds %t* %stuff, i32 0, i32 0
  %before = load i32* %p

  call void @test1f_nofence(i8* null)

  %after = load i32* %p ; <--- This should be a dead load
  %sum = add i32 %before, %after

  store i32 %sum, i32* %p
  ret void
}
