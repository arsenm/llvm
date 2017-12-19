; RUN: not opt -S -linearize-cfg -linearize-whole-function %s 2>&1 | FileCheck %s
; CHECK: LLVM ERROR: unsupported terminator type

declare void @bar()

define i32 @uses_invoke() personality i32 (...)* @__gxx_personality_v0 {
entry:
  br label %bb

bb:
  invoke void @bar()
          to label %bb1 unwind label %Rethrow

bb1:
  ret i32 0

Rethrow:
  %exn = landingpad { i8*, i32 }
          catch i8* null
  resume { i8*, i32 } %exn
}

declare i32 @__gxx_personality_v0(...)
