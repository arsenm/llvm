
; nested loops such that loops in same scc but different proper loops
define void @different_loops_same_scc(i32 %n) {
entry:
  br label %b1

b1:
  %b1.load = load volatile i32, i32 addrspace(1)* undef
  br label %b2

b2:
  %i = phi i32 [ 0, %b1 ], [ %i.inc, %b4 ]
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %b3, label %b5

b3:
  store volatile i32 3, i32 addrspace(1)* undef
  %cond1 = load volatile i1, i1 addrspace(1)* undef
  br i1 %cond1, label %inner.loop, label %b6

inner.loop:
  %inner.cond = load i1, i1 addrspace(1)* undef
  br i1 %inner.cond, label %inner.loop, label %b4

b4:
  store volatile i32 4, i32 addrspace(1)* undef
  %i.inc = add nsw i32 %i, 1
  br label %b2

b5:
  store volatile i32 5, i32 addrspace(1)* undef
  br label %b6

b6:
  store volatile i32 6, i32 addrspace(1)* undef
  br label %exit

exit:
  ret void
}

