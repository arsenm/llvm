; XFAIL: *
; RUN: llc -march=r600 -mcpu=SI < %s

; FIXME: Why aren't these stores being combined?
define void @extract_vector(i16 addrspace(1)* %out, <2 x i16> %foo) nounwind {
  %p0 = extractelement <2 x i16> %foo, i32 0
  %p1 = extractelement <2 x i16> %foo, i32 1
  %out1 = getelementptr i16 addrspace(1)* %out, i32 1
  store i16 %p1, i16 addrspace(1)* %out, align 2
  store i16 %p0, i16 addrspace(1)* %out1, align 2
  ret void
}

