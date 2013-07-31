; RUN: llc -O1 -march=thumb -mcpu=cortex-a9 -o /dev/null %s

; Derived from ivchain-ARM.ll. Simplified and added address space
; bitcasts. The address spaces are the same size, so the actual code
; should be unaffected, but this checks that we don't hit an assertion
; from the address space bitcast

; This is just enough to hit the CreatePointerCast when dealing with
; the bitcast
define void @extrastride_simplified(i8* nocapture %main, i32 %main_stride) #0 {
entry:
  br i1 undef, label %for.end, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %entry
  %add.ptr.sum = shl i32 %main_stride, 1
  %add.ptr1.sum = add i32 %add.ptr.sum, %main_stride
  %add.ptr4.sum = shl i32 %main_stride, 2
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.lr.ph
  %main.addr.011 = phi i8* [ %main, %for.body.lr.ph ], [ %add.ptr6, %for.body ]
  %0 = bitcast i8* %main.addr.011 to i32 addrspace(1)*
  %1 = load i32 addrspace(1)* %0, align 4
  %add.ptr = getelementptr inbounds i8* %main.addr.011, i32 %main_stride
  %2 = bitcast i8* %add.ptr to i32 addrspace(1)*
  %3 = load i32 addrspace(1)* %2, align 4
  %add.ptr1 = getelementptr inbounds i8* %main.addr.011, i32 %add.ptr.sum
  %4 = bitcast i8* %add.ptr1 to i32 addrspace(1)*
  %5 = load i32 addrspace(1)* %4, align 4
  %add.ptr2 = getelementptr inbounds i8* %main.addr.011, i32 %add.ptr1.sum
  %6 = bitcast i8* %add.ptr2 to i32 addrspace(1)*
  %7 = load i32 addrspace(1)* %6, align 4
  %add.ptr3 = getelementptr inbounds i8* %main.addr.011, i32 %add.ptr4.sum
  %8 = bitcast i8* %add.ptr3 to i32 addrspace(1)*
  %9 = load i32 addrspace(1)* %8, align 4
  %add.ptr6 = getelementptr inbounds i8* %main.addr.011, i32 undef
  br i1 undef, label %for.end, label %for.body

for.end:                                          ; preds = %for.body, %entry
  ret void
}

attributes #0 = { nounwind }

