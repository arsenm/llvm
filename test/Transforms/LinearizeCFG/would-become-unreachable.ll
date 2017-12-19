; RUN: opt -S -linearize-cfg %s

define void @would_become_unreachable() {
bb:
  br label %bb1

bb1:
  br i1 undef, label %bb3, label %bb2

bb2:
  br i1 undef, label %bb5, label %bb6

bb3:
  br i1 undef, label %bb7, label %bb4

bb4:
  unreachable

bb5:
  br label %bb7

bb6:
  unreachable

bb7:
  unreachable
}
