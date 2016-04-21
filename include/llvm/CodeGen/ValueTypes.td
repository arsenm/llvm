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

def OtherVT: ValueType<0  ,  1>;   // "Other" value
def i1     : ValueType<1  ,  2>;   // One bit boolean value
def i8     : ValueType<8  ,  3>;   // 8-bit integer value
def i16    : ValueType<16 ,  4>;   // 16-bit integer value
def i32    : ValueType<32 ,  5>;   // 32-bit integer value
def i64    : ValueType<64 ,  6>;   // 64-bit integer value
def i128   : ValueType<128,  7>;   // 128-bit integer value
def f16    : ValueType<16 ,  8>;   // 16-bit floating point value
def f32    : ValueType<32 ,  9>;   // 32-bit floating point value
def f64    : ValueType<64 , 10>;   // 64-bit floating point value
def f80    : ValueType<80 , 11>;   // 80-bit floating point value
def f128   : ValueType<128, 12>;   // 128-bit floating point value
def ppcf128: ValueType<128, 13>;   // PPC 128-bit floating point value

def v1i1   : ValueType<1 ,  14>;   //   1 x i1 vector value
def v2i1   : ValueType<2 ,  15>;   //   2 x i1 vector value
def v3i1   : ValueType<3 ,  16>;   //   3 x i1 vector value
def v4i1   : ValueType<4 ,  17>;   //   4 x i1 vector value
def v8i1   : ValueType<8 ,  18>;   //   8 x i1 vector value
def v16i1  : ValueType<16,  19>;   //  16 x i1 vector value
def v32i1  : ValueType<32 , 20>;   //  32 x i1 vector value
def v64i1  : ValueType<64 , 21>;   //  64 x i1 vector value
def v512i1 : ValueType<512, 22>;   // 512 x i1 vector value
def v1024i1: ValueType<1024,23>;   //1024 x i1 vector value

def v1i8   : ValueType<8,  24>;    //  1 x i8  vector value
def v2i8   : ValueType<16, 25>;   //  2 x i8  vector value
def v3i8   : ValueType<24, 26>;   //  3 x i8  vector value
def v4i8   : ValueType<32, 27>;   //  4 x i8  vector value
def v8i8   : ValueType<64, 28>;   //  8 x i8  vector value
def v16i8  : ValueType<128, 29>;   // 16 x i8  vector value
def v32i8  : ValueType<256, 30>;   // 32 x i8  vector value
def v64i8  : ValueType<512, 31>;   // 64 x i8  vector value
def v128i8 : ValueType<1024,32>;   //128 x i8  vector value
def v256i8 : ValueType<2048,33>;   //256 x i8  vector value

def v1i16  : ValueType<16 , 34>;   //  1 x i16 vector value
def v2i16  : ValueType<32 , 35>;   //  2 x i16 vector value
def v3i16  : ValueType<48 , 36>;   //  3 x i16 vector value
def v4i16  : ValueType<64 , 37>;   //  4 x i16 vector value
def v8i16  : ValueType<128, 38>;   //  8 x i16 vector value
def v16i16 : ValueType<256, 39>;   // 16 x i16 vector value
def v32i16 : ValueType<512, 40>;   // 32 x i16 vector value
def v64i16 : ValueType<1024,41>;   // 64 x i16 vector value
def v128i16: ValueType<2048,42>;   //128 x i16 vector value

def v1i32  : ValueType<32 , 43>;   //  1 x i32 vector value
def v2i32  : ValueType<64 , 44>;   //  2 x i32 vector value
def v3i32  : ValueType<96 , 45>;   //  3 x i32 vector value
def v4i32  : ValueType<128, 46>;   //  4 x i32 vector value
def v8i32  : ValueType<256, 47>;   //  8 x i32 vector value
def v16i32 : ValueType<512, 48>;   // 16 x i32 vector value
def v32i32 : ValueType<1024,49>;   // 32 x i32 vector value
def v64i32 : ValueType<2048,50>;   // 32 x i32 vector value

def v1i64  : ValueType<64 , 51>;   //  1 x i64 vector value
def v2i64  : ValueType<128, 52>;   //  2 x i64 vector value
def v3i64  : ValueType<192, 53>;   //  3 x i64 vector value
def v4i64  : ValueType<256, 54>;   //  4 x i64 vector value
def v8i64  : ValueType<512, 55>;   //  8 x i64 vector value
def v16i64 : ValueType<1024,56>;   // 16 x i64 vector value
def v32i64 : ValueType<2048,57>;   // 32 x i64 vector value

def v1i128 : ValueType<128, 58>;   //  1 x i128 vector value

def nxv1i1  : ValueType<1,   59>;  // n x  1 x i1  vector value
def nxv2i1  : ValueType<2,   60>;  // n x  2 x i1  vector value
def nxv3i1  : ValueType<3,   61>;  // n x  3 x i1  vector value
def nxv4i1  : ValueType<4,   62>;  // n x  4 x i1  vector value
def nxv8i1  : ValueType<8,   63>;  // n x  8 x i1  vector value
def nxv16i1 : ValueType<16,  64>;  // n x 16 x i1  vector value
def nxv32i1 : ValueType<32,  65>;  // n x 32 x i1  vector value

def nxv1i8  : ValueType<8,   66>;  // n x  1 x i8  vector value
def nxv2i8  : ValueType<16,  67>;  // n x  2 x i8  vector value
def nxv3i8  : ValueType<24,  68>;  // n x  3 x i8  vector value
def nxv4i8  : ValueType<32,  69>;  // n x  4 x i8  vector value
def nxv8i8  : ValueType<64,  70>;  // n x  8 x i8  vector value
def nxv16i8 : ValueType<128, 71>;  // n x 16 x i8  vector value
def nxv32i8 : ValueType<256, 72>;  // n x 32 x i8  vector value

def nxv1i16 : ValueType<16,  73>;  // n x  1 x i16 vector value
def nxv2i16 : ValueType<32,  74>;  // n x  2 x i16 vector value
def nxv3i16 : ValueType<48,  75>;  // n x  3 x i16 vector value
def nxv4i16 : ValueType<64,  76>;  // n x  4 x i16 vector value
def nxv8i16 : ValueType<128, 77>;  // n x  8 x i16 vector value
def nxv16i16: ValueType<256, 78>;  // n x 16 x i16 vector value
def nxv32i16: ValueType<512, 79>;  // n x 32 x i16 vector value

def nxv1i32 : ValueType<32,  80>;  // n x  1 x i32 vector value
def nxv2i32 : ValueType<64,  81>;  // n x  2 x i32 vector value
def nxv3i32 : ValueType<96,  82>;  // n x  3 x i32 vector value
def nxv4i32 : ValueType<128, 83>;  // n x  4 x i32 vector value
def nxv8i32 : ValueType<256, 84>;  // n x  8 x i32 vector value
def nxv16i32: ValueType<512, 85>;  // n x 16 x i32 vector value
def nxv32i32: ValueType<1024,86>;  // n x 32 x i32 vector value

def nxv1i64 : ValueType<64,  87>;  // n x  1 x i64 vector value
def nxv2i64 : ValueType<128, 88>;  // n x  2 x i64 vector value
def nxv3i64 : ValueType<192, 89>;  // n x  3 x i64 vector value
def nxv4i64 : ValueType<256, 90>;  // n x  4 x i64 vector value
def nxv8i64 : ValueType<512, 91>;  // n x  8 x i64 vector value
def nxv16i64: ValueType<1024,92>;  // n x 16 x i64 vector value
def nxv32i64: ValueType<2048,93>;  // n x 32 x i64 vector value

def v2f16  : ValueType<32 , 94>;   //  2 x f16 vector value
def v3f16  : ValueType<48 , 95>;   //  3 x f16 vector value
def v4f16  : ValueType<64 , 96>;   //  4 x f16 vector value
def v8f16  : ValueType<128, 97>;   //  8 x f16 vector value
def v1f32  : ValueType<32 , 98>;   //  1 x f32 vector value
def v2f32  : ValueType<64 , 99>;   //  2 x f32 vector value
def v3f32  : ValueType<96 , 100>;  //  3 x f32 vector value
def v4f32  : ValueType<128, 101>;  //  4 x f32 vector value
def v8f32  : ValueType<256, 102>;  //  8 x f32 vector value
def v16f32 : ValueType<512, 103>;  // 16 x f32 vector value
def v1f64  : ValueType<64,  104>;  //  1 x f64 vector value
def v2f64  : ValueType<128, 105>;  //  2 x f64 vector value
def v3f64  : ValueType<192, 106>;  //  3 x f64 vector value
def v4f64  : ValueType<256, 107>;  //  4 x f64 vector value
def v8f64  : ValueType<512, 108>;  //  8 x f64 vector value

def nxv2f16  : ValueType<32 , 109>; // n x  2 x f16 vector value
def nxv3f16  : ValueType<48 , 110>; // n x  3 x f16 vector value
def nxv4f16  : ValueType<64 , 111>; // n x  4 x f16 vector value
def nxv8f16  : ValueType<128, 112>; // n x  8 x f16 vector value
def nxv1f32  : ValueType<32 , 113>; // n x  1 x f32 vector value
def nxv2f32  : ValueType<64 , 114>; // n x  2 x f32 vector value
def nxv3f32  : ValueType<96 , 115>; // n x  2 x f32 vector value
def nxv4f32  : ValueType<128, 116>; // n x  4 x f32 vector value
def nxv8f32  : ValueType<256, 117>; // n x  8 x f32 vector value
def nxv16f32 : ValueType<512, 118>; // n x 16 x f32 vector value
def nxv1f64  : ValueType<64,  119>; // n x  1 x f64 vector value
def nxv2f64  : ValueType<128, 120>; // n x  2 x f64 vector value
def nxv3f64  : ValueType<192, 121>; // n x  3 x f64 vector value
def nxv4f64  : ValueType<256, 122>; // n x  4 x f64 vector value
def nxv8f64  : ValueType<512, 123>; // n x  8 x f64 vector value

def x86mmx : ValueType<64 , 124>;   // X86 MMX value
def FlagVT : ValueType<0  , 125>;   // Pre-RA sched glue
def isVoid : ValueType<0  , 126>;   // Produces no value
def untyped: ValueType<8  , 127>;   // Produces an untyped value
def token  : ValueType<0  , 248>;   // TokenTy
def MetadataVT: ValueType<0, 249>;  // Metadata

// Pseudo valuetype mapped to the current pointer size to any address space.
// Should only be used in TableGen.
def iPTRAny   : ValueType<0, 250>;

// Pseudo valuetype to represent "vector of any size"
def vAny   : ValueType<0  , 251>;

// Pseudo valuetype to represent "float of any format"
def fAny   : ValueType<0  , 252>;

// Pseudo valuetype to represent "integer of any bit width"
def iAny   : ValueType<0  , 253>;

// Pseudo valuetype mapped to the current pointer size.
def iPTR   : ValueType<0  , 254>;

// Pseudo valuetype to represent "any type of any size".
def Any    : ValueType<0  , 255>;
