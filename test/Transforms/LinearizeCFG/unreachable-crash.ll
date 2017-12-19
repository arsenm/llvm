; RUN: opt -S -linearize-cfg %s | FileCheck %s

define void @no_cipdom_unreachable(i1 %cond0, <4 x float> addrspace(1)* noalias nocapture readonly %arg) {
bb:
  %tmp = load volatile i32, i32 addrspace(1)* undef
  br label %bb1

bb1:
  %bb1.load = load volatile i32, i32 addrspace(1)* undef
  %tmp2 = sext i32 %tmp to i64
  %tmp3 = getelementptr inbounds <4 x float>, <4 x float> addrspace(1)* %arg, i64 %tmp2
  %tmp4 = load <4 x float>, <4 x float> addrspace(1)* %tmp3, align 16
  br i1 %cond0, label %bb3, label %bb5

bb3:
  %bb3.load0 = load volatile i32, i32 addrspace(1)* undef
  %bb3.load1 = load volatile i32, i32 addrspace(1)* undef
  %tmp6 = extractelement <4 x float> %tmp4, i32 2
  %tmp7 = fcmp olt float %tmp6, 0.000000e+00
  br i1 %tmp7, label %bb4, label %bb5

bb4:
  %bb4.load = load volatile i32, i32 addrspace(1)* undef
  store volatile i32 %bb3.load0, i32 addrspace(1)* undef
  unreachable

bb5:
  %bb5.phi = phi i32 [ %bb3.load1, %bb3 ], [ %bb1.load, %bb1 ]
  store volatile i32 %bb5.phi, i32 addrspace(1)* undef
  unreachable
}

; Due to a bug in calculating the CIPDOM, this case did not work
; correctly without the single successor branch to bb1.
define i32 @no_cipdom_unreachable_no_extra_branch(i1 %cond0, <4 x float> addrspace(1)* noalias nocapture readonly %arg) {
bb:
  %tmp = load volatile i32, i32 addrspace(1)* undef
  %bb1.load = load volatile i32, i32 addrspace(1)* undef
  %tmp2 = sext i32 %tmp to i64
  %tmp3 = getelementptr inbounds <4 x float>, <4 x float> addrspace(1)* %arg, i64 %tmp2
  %tmp4 = load <4 x float>, <4 x float> addrspace(1)* %tmp3, align 16
  br i1 %cond0, label %bb3, label %bb5

bb3:
  %bb3.load0 = load volatile i32, i32 addrspace(1)* undef
  %bb3.load1 = load volatile i32, i32 addrspace(1)* undef
  %tmp6 = extractelement <4 x float> %tmp4, i32 2
  %tmp7 = fcmp olt float %tmp6, 0.000000e+00
  br i1 %tmp7, label %bb4, label %bb5

bb4:
  %bb4.load = load volatile i32, i32 addrspace(1)* undef
  store volatile i32 %bb3.load0, i32 addrspace(1)* undef
  ret i32 %bb4.load

bb5:
  %bb5.phi = phi i32 [ %bb3.load1, %bb3 ], [ %bb1.load, %bb ]
  store volatile i32 %bb5.phi, i32 addrspace(1)* undef
  ret i32 %bb5.phi
}
