; See AttributeSet AttributeSet::get(LLVMContext &C, unsigned Index, AttrBuilder &B) {
; The second fence isn't added, so the check doesn' work.
; We could also just try accepting this as the full nomemfence.

; RUN: not llvm-as -disable-output %s 2>&1 | FileCheck %s

; CHECK: 'nomemfence' is incompatible with nomemfence(N)!


define void @use_both_nomemfence_forms() nomemfence nomemfence(1) {
  ret void
}