; RUN: opt -cost-model -analyze -mtriple=amdgcn-unknown-amdhsa -mcpu=kaveri < %s | FileCheck %s

; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %workitem.id.x = call i32 @llvm.amdgcn.workitem.id.x()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %workitem.id.y = call i32 @llvm.amdgcn.workitem.id.y()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %workitem.id.z = call i32 @llvm.amdgcn.workitem.id.z()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %workgroup.id.x = call i32 @llvm.amdgcn.workgroup.id.x()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %workgroup.id.y = call i32 @llvm.amdgcn.workgroup.id.y()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %workgroup.id.z = call i32 @llvm.amdgcn.workgroup.id.z()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %kernarg.segment.ptr = call i8 addrspace(2)* @llvm.amdgcn.kernarg.segment.ptr()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %implicitarg.ptr = call i8 addrspace(2)* @llvm.amdgcn.implicitarg.ptr()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %implicit.buffer.ptr = call i8 addrspace(2)* @llvm.amdgcn.implicit.buffer.ptr()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %queue_ptr = call i8 addrspace(2)* @llvm.amdgcn.queue.ptr()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %dispatch_ptr = call i8 addrspace(2)* @llvm.amdgcn.dispatch.ptr()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %dispatch.id = call i64 @llvm.amdgcn.dispatch.id()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   %static_lds_size = call i32 @llvm.amdgcn.groupstaticsize()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   call void @llvm.amdgcn.unreachable()
; CHECK: Cost Model: Found an estimated cost of 0 for instruction:   call void @llvm.amdgcn.wave.barrier()

define void @test() #0 {
  %workitem.id.x = call i32 @llvm.amdgcn.workitem.id.x()
  %workitem.id.y = call i32 @llvm.amdgcn.workitem.id.y()
  %workitem.id.z = call i32 @llvm.amdgcn.workitem.id.z()
  %workgroup.id.x = call i32 @llvm.amdgcn.workgroup.id.x()
  %workgroup.id.y = call i32 @llvm.amdgcn.workgroup.id.y()
  %workgroup.id.z = call i32 @llvm.amdgcn.workgroup.id.z()

  %kernarg.segment.ptr = call i8 addrspace(2)* @llvm.amdgcn.kernarg.segment.ptr()
  %implicitarg.ptr = call i8 addrspace(2)* @llvm.amdgcn.implicitarg.ptr()
  %implicit.buffer.ptr = call i8 addrspace(2)* @llvm.amdgcn.implicit.buffer.ptr()
  %queue_ptr = call i8 addrspace(2)* @llvm.amdgcn.queue.ptr()
  %dispatch_ptr = call i8 addrspace(2)* @llvm.amdgcn.dispatch.ptr()

  %dispatch.id = call i64 @llvm.amdgcn.dispatch.id()
  %static_lds_size = call i32 @llvm.amdgcn.groupstaticsize()

  call void @llvm.amdgcn.unreachable()
  call void @llvm.amdgcn.wave.barrier()

  ret void
}

declare i32 @llvm.amdgcn.workitem.id.x() #1
declare i32 @llvm.amdgcn.workitem.id.y() #1
declare i32 @llvm.amdgcn.workitem.id.z() #1
declare i32 @llvm.amdgcn.workgroup.id.x() #1
declare i32 @llvm.amdgcn.workgroup.id.y() #1
declare i32 @llvm.amdgcn.workgroup.id.z() #1
declare i64 @llvm.amdgcn.dispatch.id() #1
declare i8 addrspace(2)* @llvm.amdgcn.kernarg.segment.ptr() #1
declare i8 addrspace(2)* @llvm.amdgcn.implicitarg.ptr() #1
declare i8 addrspace(2)* @llvm.amdgcn.implicit.buffer.ptr() #1
declare i8 addrspace(2)* @llvm.amdgcn.queue.ptr() #1
declare i8 addrspace(2)* @llvm.amdgcn.dispatch.ptr() #0
declare void @llvm.amdgcn.unreachable() #0
declare i32 @llvm.amdgcn.groupstaticsize() #1
declare void @llvm.amdgcn.wave.barrier() #2

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
attributes #2 = { convergent nounwind }
