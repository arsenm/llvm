; RUN: llc -march=amdgcn -verify-machineinstrs < %s

define void @store_volatile_repeat_vector(<8 x i32> addrspace(1)* %out, <8 x float> %vec) {
  %vec.bc = bitcast <8 x float> <float 1.0, float 2.0, float 3.0, float 4.0, float 5.0, float 6.0, float 7.0, float 8.0> to <8 x i32>
  store volatile <8 x i32> %vec.bc, <8 x i32> addrspace(1)* undef
  ret void
}

; When the vector store is split, the MachinePointerInfo offset is not
; considered, so the two stores are CSEd.
define void @store_volatile_repeat_upper_half_undef(<8 x i32> addrspace(1)* %out, <8 x float> %vec) {
  %vec.bc = bitcast <8 x float> <float 1.0, float 2.0, float 3.0, float 4.0, float 1.0, float 2.0, float 3.0, float 4.0> to <8 x i32>
  store volatile <8 x i32> %vec.bc, <8 x i32> addrspace(1)* undef
  ret void
}
