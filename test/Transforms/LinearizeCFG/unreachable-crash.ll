; RUN: opt -S -linearize-cfg %s | FileCheck %s

define void @no_cipdom_unreachable(<4 x float> addrspace(1)* noalias nocapture readonly %arg) {
bb:
  %tmp = load volatile i32, i32 addrspace(1)* undef
  br label %bb1

bb1:                                              ; preds = %bb
  %tmp2 = sext i32 %tmp to i64
  %tmp3 = getelementptr inbounds <4 x float>, <4 x float> addrspace(1)* %arg, i64 %tmp2
  %tmp4 = load <4 x float>, <4 x float> addrspace(1)* %tmp3, align 16
  br i1 undef, label %bb3, label %bb5  ; label order reversed

bb3:                                              ; preds = %bb1
  %tmp6 = extractelement <4 x float> %tmp4, i32 2
  %tmp7 = fcmp olt float %tmp6, 0.000000e+00
  br i1 %tmp7, label %bb4, label %bb5

bb4:                                              ; preds = %bb3
  unreachable

bb5:                                              ; preds = %bb3, %bb1
  unreachable
}

