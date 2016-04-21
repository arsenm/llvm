//===- ValueTypes.td - ValueType definitions ---------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Value types - These values correspond to the register types defined in the
// ValueTypes.h file.  If you update anything here, you must update it there as
// well!
//
//===----------------------------------------------------------------------===//

class ValueType<int size, int value> {
  string Namespace = "MVT";
  int Size = size;
  int Value = value;
}

def OtherVT: ValueType<0  ,  0>;   // "Other" value
def i1     : ValueType<1  ,  1>;   // One bit boolean value
def i8     : ValueType<8  ,  2>;   // 8-bit integer value
def i16    : ValueType<16 ,  3>;   // 16-bit integer value
def i32    : ValueType<32 ,  4>;   // 32-bit integer value
def i64    : ValueType<64 ,  5>;   // 64-bit integer value
def i128   : ValueType<128,  6>;   // 128-bit integer value
def f16    : ValueType<16 ,  7>;   // 16-bit floating point value
def f32    : ValueType<32 ,  8>;   // 32-bit floating point value
def f64    : ValueType<64 ,  9>;   // 64-bit floating point value
def f80    : ValueType<80 , 10>;   // 80-bit floating point value
def f128   : ValueType<128, 11>;   // 128-bit floating point value
def ppcf128: ValueType<128, 12>;   // PPC 128-bit floating point value

def v2i1   : ValueType<2 ,  13>;   //   2 x i1 vector value
def v3i1   : ValueType<3 ,  14>;   //   3 x i1 vector value
def v4i1   : ValueType<4 ,  15>;   //   4 x i1 vector value
def v8i1   : ValueType<8 ,  16>;   //   8 x i1 vector value
def v16i1  : ValueType<16,  17>;   //  16 x i1 vector value
def v32i1  : ValueType<32 , 18>;   //  32 x i1 vector value
def v64i1  : ValueType<64 , 19>;   //  64 x i1 vector value
def v512i1 : ValueType<512, 20>;   // 512 x i1 vector value
def v1024i1: ValueType<1024,21>;   //1024 x i1 vector value

def v1i8   : ValueType<16,  22>;   //  1 x i8  vector value
def v2i8   : ValueType<16 , 23>;   //  2 x i8  vector value
def v3i8   : ValueType<24 , 24>;   //  3 x i8  vector value
def v4i8   : ValueType<32 , 25>;   //  4 x i8  vector value
def v8i8   : ValueType<64 , 26>;   //  8 x i8  vector value
def v16i8  : ValueType<128, 27>;   // 16 x i8  vector value
def v32i8  : ValueType<256, 28>;   // 32 x i8  vector value
def v64i8  : ValueType<512, 29>;   // 64 x i8  vector value
def v128i8 : ValueType<1024,30>;   //128 x i8  vector value
def v256i8 : ValueType<2048,31>;   //256 x i8  vector value

def v1i16  : ValueType<16 , 32>;   //  1 x i16 vector value
def v2i16  : ValueType<32 , 33>;   //  2 x i16 vector value
def v3i16  : ValueType<38 , 34>;   //  3 x i16 vector value
def v4i16  : ValueType<64 , 35>;   //  4 x i16 vector value
def v8i16  : ValueType<128, 36>;   //  8 x i16 vector value
def v16i16 : ValueType<256, 37>;   // 16 x i16 vector value
def v32i16 : ValueType<512, 38>;   // 32 x i16 vector value
def v64i16 : ValueType<1024,39>;   // 64 x i16 vector value
def v128i16: ValueType<2048,40>;   //128 x i16 vector value

def v1i32  : ValueType<32 , 41>;   //  1 x i32 vector value
def v2i32  : ValueType<64 , 42>;   //  2 x i32 vector value
def v3i32  : ValueType<96,  43>;   //  3 x i32 vector value
def v4i32  : ValueType<128, 44>;   //  4 x i32 vector value
def v8i32  : ValueType<256, 45>;   //  8 x i32 vector value
def v16i32 : ValueType<512, 46>;   // 16 x i32 vector value
def v32i32 : ValueType<1024,47>;   // 32 x i32 vector value
def v64i32 : ValueType<2048,48>;   // 32 x i32 vector value

def v1i64  : ValueType<64 , 49>;   //  1 x i64 vector value
def v2i64  : ValueType<128, 50>;   //  2 x i64 vector value
def v3i64  : ValueType<192, 51>;   //  3 x i64 vector value
def v4i64  : ValueType<256, 52>;   //  4 x i64 vector value
def v8i64  : ValueType<512, 53>;   //  8 x i64 vector value
def v16i64 : ValueType<1024,54>;   // 16 x i64 vector value
def v32i64 : ValueType<2048,55>;   // 32 x i64 vector value

def v1i128 : ValueType<128, 56>;   //  1 x i128 vector value

def v2f16  : ValueType<32 , 57>;   //  2 x f16 vector value
def v3f16  : ValueType<48 , 58>;   //  3 x f16 vector value
def v4f16  : ValueType<64 , 59>;   //  4 x f16 vector value
def v8f16  : ValueType<128, 60>;   //  8 x f16 vector value
def v1f32  : ValueType<32 , 61>;   //  1 x f32 vector value
def v2f32  : ValueType<64 , 62>;   //  2 x f32 vector value
def v3f32  : ValueType<96 , 63>;   //  2 x f32 vector value
def v4f32  : ValueType<128, 64>;   //  4 x f32 vector value
def v8f32  : ValueType<256, 65>;   //  8 x f32 vector value
def v16f32 : ValueType<512, 66>;   // 16 x f32 vector value
def v1f64  : ValueType<64,  67>;   //  1 x f64 vector value
def v2f64  : ValueType<128, 68>;   //  2 x f64 vector value
def v3f64  : ValueType<192, 69>;   //  2 x f64 vector value
def v4f64  : ValueType<256, 70>;   //  4 x f64 vector value
def v8f64  : ValueType<512, 71>;   //  8 x f64 vector value


def x86mmx : ValueType<64 , 72>;   // X86 MMX value
def FlagVT : ValueType<0  , 73>;   // Pre-RA sched glue
def isVoid : ValueType<0  , 74>;   // Produces no value
def untyped: ValueType<8  , 75>;   // Produces an untyped value
def token  : ValueType<0  , 120>;  // TokenTy
def MetadataVT: ValueType<0, 121>; // Metadata

// Pseudo valuetype mapped to the current pointer size to any address space.
// Should only be used in TableGen.
def iPTRAny   : ValueType<0, 122>;

// Pseudo valuetype to represent "vector of any size"
def vAny   : ValueType<0  , 123>;

// Pseudo valuetype to represent "float of any format"
def fAny   : ValueType<0  , 124>;

// Pseudo valuetype to represent "integer of any bit width"
def iAny   : ValueType<0  , 125>;

// Pseudo valuetype mapped to the current pointer size.
def iPTR   : ValueType<0  , 126>;

// Pseudo valuetype to represent "any type of any size".
def Any    : ValueType<0  , 127>;
