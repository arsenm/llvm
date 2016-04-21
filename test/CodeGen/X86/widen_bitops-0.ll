; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=X32-SSE --check-prefix=X32-SSE42
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=X64-SSE --check-prefix=X64-SSE42

;
; AND/XOR/OR i24 as v3i8
;

define i24 @and_i24_as_v3i8(i24 %a, i24 %b) nounwind {
; X32-SSE-LABEL: and_i24_as_v3i8:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    andl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    retl
;
; X64-SSE-LABEL: and_i24_as_v3i8:
; X64-SSE:       # BB#0:
; X64-SSE-NEXT:    andl %esi, %edi
; X64-SSE-NEXT:    movl %edi, %eax
; X64-SSE-NEXT:    retq
  %1 = bitcast i24 %a to <3 x i8>
  %2 = bitcast i24 %b to <3 x i8>
  %3 = and <3 x i8> %1, %2
  %4 = bitcast <3 x i8> %3 to i24
  ret i24 %4
}

define i24 @xor_i24_as_v3i8(i24 %a, i24 %b) nounwind {
; X32-SSE-LABEL: xor_i24_as_v3i8:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    xorl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    retl
;
; X64-SSE-LABEL: xor_i24_as_v3i8:
; X64-SSE:       # BB#0:
; X64-SSE-NEXT:    xorl %esi, %edi
; X64-SSE-NEXT:    movl %edi, %eax
; X64-SSE-NEXT:    retq
  %1 = bitcast i24 %a to <3 x i8>
  %2 = bitcast i24 %b to <3 x i8>
  %3 = xor <3 x i8> %1, %2
  %4 = bitcast <3 x i8> %3 to i24
  ret i24 %4
}

define i24 @or_i24_as_v3i8(i24 %a, i24 %b) nounwind {
; X32-SSE-LABEL: or_i24_as_v3i8:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    orl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    retl
;
; X64-SSE-LABEL: or_i24_as_v3i8:
; X64-SSE:       # BB#0:
; X64-SSE-NEXT:    orl %esi, %edi
; X64-SSE-NEXT:    movl %edi, %eax
; X64-SSE-NEXT:    retq
  %1 = bitcast i24 %a to <3 x i8>
  %2 = bitcast i24 %b to <3 x i8>
  %3 = or <3 x i8> %1, %2
  %4 = bitcast <3 x i8> %3 to i24
  ret i24 %4
}

;
; AND/XOR/OR i24 as v8i3
;

define i24 @and_i24_as_v8i3(i24 %a, i24 %b) nounwind {
; X32-SSE-LABEL: and_i24_as_v8i3:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    andl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    retl
;
; X64-SSE-LABEL: and_i24_as_v8i3:
; X64-SSE:       # BB#0:
; X64-SSE-NEXT:    andl %esi, %edi
; X64-SSE-NEXT:    movl %edi, %eax
; X64-SSE-NEXT:    retq
  %1 = bitcast i24 %a to <8 x i3>
  %2 = bitcast i24 %b to <8 x i3>
  %3 = and <8 x i3> %1, %2
  %4 = bitcast <8 x i3> %3 to i24
  ret i24 %4
}

define i24 @xor_i24_as_v8i3(i24 %a, i24 %b) nounwind {
; X32-SSE-LABEL: xor_i24_as_v8i3:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    xorl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    retl
;
; X64-SSE-LABEL: xor_i24_as_v8i3:
; X64-SSE:       # BB#0:
; X64-SSE-NEXT:    xorl %esi, %edi
; X64-SSE-NEXT:    movl %edi, %eax
; X64-SSE-NEXT:    retq
  %1 = bitcast i24 %a to <8 x i3>
  %2 = bitcast i24 %b to <8 x i3>
  %3 = xor <8 x i3> %1, %2
  %4 = bitcast <8 x i3> %3 to i24
  ret i24 %4
}

define i24 @or_i24_as_v8i3(i24 %a, i24 %b) nounwind {
; X32-SSE-LABEL: or_i24_as_v8i3:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    orl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    retl
;
; X64-SSE-LABEL: or_i24_as_v8i3:
; X64-SSE:       # BB#0:
; X64-SSE-NEXT:    orl %esi, %edi
; X64-SSE-NEXT:    movl %edi, %eax
; X64-SSE-NEXT:    retq
  %1 = bitcast i24 %a to <8 x i3>
  %2 = bitcast i24 %b to <8 x i3>
  %3 = or <8 x i3> %1, %2
  %4 = bitcast <8 x i3> %3 to i24
  ret i24 %4
}

;
; AND/XOR/OR v3i8 as i24
;

define <3 x i8> @and_v3i8_as_i24(<3 x i8> %a, <3 x i8> %b) nounwind {
; X32-SSE-LABEL: and_v3i8_as_i24:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT: andps %xmm1, %xmm0
; X32-SSE-NEXT: retl
;
; X64-SSE-LABEL: and_v3i8_as_i24:
; X64-SSE:       # BB#0:
; X64-SSE-NEXT: andps %xmm1, %xmm0
; X64-SSE-NEXT: retq
  %1 = bitcast <3 x i8> %a to i24
  %2 = bitcast <3 x i8> %b to i24
  %3 = and i24 %1, %2
  %4 = bitcast i24 %3 to <3 x i8>
  ret <3 x i8>  %4
}

define <3 x i8> @xor_v3i8_as_i24(<3 x i8> %a, <3 x i8> %b) nounwind {
; X32-SSE-LABEL: xor_v3i8_as_i24:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT: xorps %xmm1, %xmm0
; X32-SSE-NEXT: retl

; X64-SSE-LABEL: xor_v3i8_as_i24:
; X64-SSE:       # BB#0:
; X64-SSE-NEXT: xorps %xmm1, %xmm0
; X64-SSE-NEXT: retq
  %1 = bitcast <3 x i8> %a to i24
  %2 = bitcast <3 x i8> %b to i24
  %3 = xor i24 %1, %2
  %4 = bitcast i24 %3 to <3 x i8>
  ret <3 x i8>  %4
}

define <3 x i8> @or_v3i8_as_i24(<3 x i8> %a, <3 x i8> %b) nounwind {
; X32-SSE-LABEL: or_v3i8_as_i24:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT: orps %xmm1, %xmm0
; X32-SSE-NEXT: retl

; X64-SSE-LABEL: or_v3i8_as_i24:
; X64-SSE:       # BB#0:
; X64-SSE-NEXT: orps %xmm1, %xmm0
; X64-SSE-NEXT: retq
  %1 = bitcast <3 x i8> %a to i24
  %2 = bitcast <3 x i8> %b to i24
  %3 = or i24 %1, %2
  %4 = bitcast i24 %3 to <3 x i8>
  ret <3 x i8>  %4
}

;
; AND/XOR/OR v8i3 as i24
;

define <8 x i3> @and_v8i3_as_i24(<8 x i3> %a, <8 x i3> %b) nounwind {
; X32-SSE-LABEL: and_v8i3_as_i24:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    andps %xmm1, %xmm0
; X32-SSE-NEXT:    retl
;
; X64-SSE-LABEL: and_v8i3_as_i24:
; X64-SSE:       # BB#0:
; X64-SSE-NEXT:    andps %xmm1, %xmm0
; X64-SSE-NEXT:    retq
  %1 = bitcast <8 x i3> %a to i24
  %2 = bitcast <8 x i3> %b to i24
  %3 = and i24 %1, %2
  %4 = bitcast i24 %3 to <8 x i3>
  ret <8 x i3>  %4
}

define <8 x i3> @xor_v8i3_as_i24(<8 x i3> %a, <8 x i3> %b) nounwind {
; X32-SSE-LABEL: xor_v8i3_as_i24:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    xorps %xmm1, %xmm0
; X32-SSE-NEXT:    retl
;
; X64-SSE-LABEL: xor_v8i3_as_i24:
; X64-SSE:       # BB#0:
; X64-SSE-NEXT:    xorps %xmm1, %xmm0
; X64-SSE-NEXT:    retq
  %1 = bitcast <8 x i3> %a to i24
  %2 = bitcast <8 x i3> %b to i24
  %3 = xor i24 %1, %2
  %4 = bitcast i24 %3 to <8 x i3>
  ret <8 x i3>  %4
}

define <8 x i3> @or_v8i3_as_i24(<8 x i3> %a, <8 x i3> %b) nounwind {
; X32-SSE-LABEL: or_v8i3_as_i24:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    orps %xmm1, %xmm0
; X32-SSE-NEXT:    retl
;
; X64-SSE-LABEL: or_v8i3_as_i24:
; X64-SSE:       # BB#0:
; X64-SSE-NEXT:    orps %xmm1, %xmm0
; X64-SSE-NEXT:    retq
  %1 = bitcast <8 x i3> %a to i24
  %2 = bitcast <8 x i3> %b to i24
  %3 = or i24 %1, %2
  %4 = bitcast i24 %3 to <8 x i3>
  ret <8 x i3>  %4
}
