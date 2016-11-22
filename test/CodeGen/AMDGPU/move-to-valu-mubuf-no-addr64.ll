


define void @move_to_valu_buffer_ptr(double addrspace(1)* addrspace(1)* %arg) #0 {
bb:
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %ptr = getelementptr inbounds double addrspace(1)*, double addrspace(1)* addrspace(1)* %arg, i32 %tid
  %tmp.ptr = load double addrspace(1)*, double addrspace(1)* addrspace(1)* %ptr
  store volatile double 0.0, double addrspace(1)* %tmp.ptr, align 8
  ret void
}

define void @move_to_valu_buffer_ptr_offset(double addrspace(1)* addrspace(1)* %arg) #0 {
bb:
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %ptr = getelementptr inbounds double addrspace(1)*, double addrspace(1)* addrspace(1)* %arg, i32 %tid
  %tmp.ptr = load double addrspace(1)*, double addrspace(1)* addrspace(1)* %ptr
  %tmp.ptr.off = getelementptr inbounds double, double addrspace(1)* %tmp.ptr, i64 42
  store volatile double 0.0, double addrspace(1)* %tmp.ptr.off, align 8
  ret void
}

define void @move_to_valu_buffer_ptr_soffset_offset(double addrspace(1)* addrspace(1)* %arg) #0 {
bb:
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %ptr = getelementptr inbounds double addrspace(1)*, double addrspace(1)* addrspace(1)* %arg, i32 %tid
  %tmp.ptr = load double addrspace(1)*, double addrspace(1)* addrspace(1)* %ptr
  %tmp.ptr.off = getelementptr inbounds double, double addrspace(1)* %tmp.ptr, i64 574
  store volatile double 0.0, double addrspace(1)* %tmp.ptr.off, align 8
  ret void
}

declare i32 @llvm.amdgcn.workitem.id.x()

attributes #0 = { nounwind "target-cpu"="fiji" }
