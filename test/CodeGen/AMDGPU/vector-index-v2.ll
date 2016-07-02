; CHECK-LABEL: {{^}}extract_w_offset_v2f32:
; CHECK-DAG: v_mov_b32_e32 v{{[0-9]+}}, 4.0
; CHECK-DAG: v_mov_b32_e32 v{{[0-9]+}}, 0x40400000
; CHECK: s_mov_b32 m0
; CHECK-NEXT: v_movrels_b32_e32
define void @extract_w_offset_v2f32(float addrspace(1)* %out, <2 x float> addrspace(1)* %vec.in, i32 %in) {
entry:
  %id = call i32 @llvm.amdgcn.workitem.id.x()
  %id.ext = sext i32 %id to i64
  %out.gep = getelementptr inbounds float, float addrspace(1)* %out, i64 %id.ext
  %vec.gep = getelementptr inbounds <2 x float>, <2 x float> addrspace(1)* %vec.in, i64 %id.ext
  %vec = load volatile <2 x float>, <2 x float> addrspace(1)* %vec.gep
  %idx = add i32 %in, 1
  %elt = extractelement <2 x float> %vec, i32 %idx
  store float %elt, float addrspace(1)* %out.gep
  ret void
}

; CHECK-LABEL: {{^}}extract_wo_offset_v2f32:
; CHECK-DAG: v_mov_b32_e32 v{{[0-9]+}}, 4.0
; CHECK-DAG: v_mov_b32_e32 v{{[0-9]+}}, 0x40400000
; CHECK: s_mov_b32 m0
; CHECK-NEXT: v_movrels_b32_e32
define void @extract_wo_offset_v4f32(float addrspace(1)* %out, <2 x float> addrspace(1)* %vec.in, i32 %in) {
entry:
  %id = call i32 @llvm.amdgcn.workitem.id.x()
  %id.ext = sext i32 %id to i64
  %out.gep = getelementptr inbounds float, float addrspace(1)* %out, i64 %id.ext
  %vec.gep = getelementptr inbounds <2 x float>, <2 x float> addrspace(1)* %vec.in, i64 %id.ext
  %vec = load volatile <2 x float>, <2 x float> addrspace(1)* %vec.gep

  %elt = extractelement <2 x float> %vec, i32 %in
  store float %elt, float addrspace(1)* %out.gep
  ret void
}


define void @extract_neg_offset_vgpr_v2i32(i32 addrspace(1)* %out, <2 x i32> addrspace(1)* %vec.in) {
entry:
  %id = call i32 @llvm.amdgcn.workitem.id.x()
  %id.ext = sext i32 %id to i64
  %out.gep = getelementptr inbounds i32, i32 addrspace(1)* %out, i64 %id.ext
  %vec.gep = getelementptr inbounds <2 x i32>, <2 x i32> addrspace(1)* %vec.in, i64 %id.ext
  %vec = load volatile <2 x i32>, <2 x i32> addrspace(1)* %vec.gep
  %index = add i32 %id, -512
  %value = extractelement <2 x i32> %vec, i32 %index
  store i32 %value, i32 addrspace(1)* %out.gep
  ret void
}



define void @insert_w_offset_v2f32(<2 x float> addrspace(1)* %out, i32 %in, <2 x float> addrspace(1)* %vec.in) {
entry:
  %id = call i32 @llvm.amdgcn.workitem.id.x()
  %id.ext = sext i32 %id to i64
  %out.gep = getelementptr inbounds <2 x float>, <2 x float> addrspace(1)* %out, i64 %id.ext
  %vec.gep = getelementptr inbounds <2 x float>, <2 x float> addrspace(1)* %vec.in, i64 %id.ext
  %vec = load volatile <2 x float>, <2 x float> addrspace(1)* %vec.gep
  %idx = add i32 %in, 1
  %ins = insertelement <2 x float> %vec, float 5.0, i32 %idx
  store <2 x float> %ins, <2 x float> addrspace(1)* %out.gep
  ret void
}

define void @insert_wo_offset_v2f32(<2 x float> addrspace(1)* %out, <2 x float> addrspace(1)* %vec.in, i32 %in) {
entry:
  %id = call i32 @llvm.amdgcn.workitem.id.x()
  %id.ext = sext i32 %id to i64
  %out.gep = getelementptr inbounds <2 x float>, <2 x float> addrspace(1)* %out, i64 %id.ext
  %vec.gep = getelementptr inbounds <2 x float>, <2 x float> addrspace(1)* %vec.in, i64 %id.ext
  %vec = load volatile <2 x float>, <2 x float> addrspace(1)* %vec.gep
  %ins = insertelement <2 x float> %vec, float 5.0, i32 %in
  store <2 x float> %ins, <2 x float> addrspace(1)* %out.gep
  ret void
}



declare i32 @llvm.amdgcn.workitem.id.x() #1

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
