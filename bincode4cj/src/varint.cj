// varint.cj — Varint encoding/decoding
package bincode4cj
import std.collection.*

let U16_BYTE: UInt8 = 251
let U32_BYTE: UInt8 = 252
let U64_BYTE: UInt8 = 253
let U128_BYTE: UInt8 = 254

// ---- reader helpers ----
// 本地类型转换辅助函数（使用 @OverflowWrapping + T(e) 而非 as，确保跨整数类型转换正确）
public func u8_to_u16_local(x: UInt8): UInt16 { UInt16(x) }
public func u8_to_u32_local(x: UInt8): UInt32 { UInt32(x) }
public func u8_to_u64_local(x: UInt8): UInt64 { UInt64(x) }
// 组合函数：纯算术拼接替代位运算，避免位运算在不同整数类型间的兼容性问题
@OverflowWrapping
func combine_u8_u16_local(lo: UInt8, hi: UInt8): UInt16 {
    u8_to_u16_local(lo) + u8_to_u16_local(hi) * 256u16
}
@OverflowWrapping
func combine_u8_u32_local(b0: UInt8, b1: UInt8, b2: UInt8, b3: UInt8): UInt32 {
    u8_to_u32_local(b0) + u8_to_u32_local(b1) * 256u32 + u8_to_u32_local(b2) * 65536u32 + u8_to_u32_local(b3) * 16777216u32
}
@OverflowWrapping
func combine_u8_u64_local(b0: UInt8, b1: UInt8, b2: UInt8, b3: UInt8, b4: UInt8, b5: UInt8, b6: UInt8, b7: UInt8): UInt64 {
    u8_to_u64_local(b0) + u8_to_u64_local(b1) * 256u64 + u8_to_u64_local(b2) * 65536u64 + u8_to_u64_local(b3) * 16777216u64 +
    u8_to_u64_local(b4) * 4294967296u64 + u8_to_u64_local(b5) * 1099511627776u64 + u8_to_u64_local(b6) * 281474976710656u64 + u8_to_u64_local(b7) * 72057594037927936u64
}

public func read_u8(data: Array<UInt8>, pos: Int64): MyResult<(UInt8, Int64), DecodeError> {
    if (pos >= data.size) { MyResult.Err(DecodeError.UnexpectedEnd(1)) }
    else { MyResult.Ok((data[pos], pos + 1)) }
}

public func read_u16_le(data: Array<UInt8>, pos: Int64): MyResult<(UInt16, Int64), DecodeError> {
    match (read_u8(data, pos)) {
        case MyResult.Ok((lo, p1)) =>
            match (read_u8(data, p1)) {
                case MyResult.Ok((hi, p2)) => MyResult.Ok((combine_u8_u16_local(lo, hi), p2))
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func read_u16_be(data: Array<UInt8>, pos: Int64): MyResult<(UInt16, Int64), DecodeError> {
    match (read_u8(data, pos)) {
        case MyResult.Ok((hi, p1)) =>
            match (read_u8(data, p1)) {
                case MyResult.Ok((lo, p2)) => MyResult.Ok((combine_u8_u16_local(lo, hi), p2))
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func read_u32_le(data: Array<UInt8>, pos: Int64): MyResult<(UInt32, Int64), DecodeError> {
    match (read_u8(data, pos)) {
        case MyResult.Ok((b0, p1)) =>
            match (read_u8(data, p1)) {
                case MyResult.Ok((b1, p2)) =>
                    match (read_u8(data, p2)) {
                        case MyResult.Ok((b2, p3)) =>
                            match (read_u8(data, p3)) {
                                case MyResult.Ok((b3, p4)) => MyResult.Ok((combine_u8_u32_local(b0, b1, b2, b3), p4))
                                case MyResult.Err(e) => MyResult.Err(e)
                            }
                        case MyResult.Err(e) => MyResult.Err(e)
                    }
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func read_u32_be(data: Array<UInt8>, pos: Int64): MyResult<(UInt32, Int64), DecodeError> {
    match (read_u8(data, pos)) {
        case MyResult.Ok((b3, p1)) =>
            match (read_u8(data, p1)) {
                case MyResult.Ok((b2, p2)) =>
                    match (read_u8(data, p2)) {
                        case MyResult.Ok((b1, p3)) =>
                            match (read_u8(data, p3)) {
                                case MyResult.Ok((b0, p4)) => MyResult.Ok((combine_u8_u32_local(b0, b1, b2, b3), p4))
                                case MyResult.Err(e) => MyResult.Err(e)
                            }
                        case MyResult.Err(e) => MyResult.Err(e)
                    }
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func read_u64_le(data: Array<UInt8>, pos: Int64): MyResult<(UInt64, Int64), DecodeError> {
    match (read_u8(data, pos)) {
        case MyResult.Ok((b0, p1)) =>
            match (read_u8(data, p1)) {
                case MyResult.Ok((b1, p2)) =>
                    match (read_u8(data, p2)) {
                        case MyResult.Ok((b2, p3)) =>
                            match (read_u8(data, p3)) {
                                case MyResult.Ok((b3, p4)) =>
                                    match (read_u8(data, p4)) {
                                        case MyResult.Ok((b4, p5)) =>
                                            match (read_u8(data, p5)) {
                                                case MyResult.Ok((b5, p6)) =>
                                                    match (read_u8(data, p6)) {
                                                        case MyResult.Ok((b6, p7)) =>
                                                            match (read_u8(data, p7)) {
                                                                case MyResult.Ok((b7, p8)) => MyResult.Ok((
                                                                    combine_u8_u64_local(b0, b1, b2, b3, b4, b5, b6, b7)
                                                                    , p8))
                                                                case MyResult.Err(e) => MyResult.Err(e)
                                                            }
                                                        case MyResult.Err(e) => MyResult.Err(e)
                                                    }
                                                case MyResult.Err(e) => MyResult.Err(e)
                                            }
                                        case MyResult.Err(e) => MyResult.Err(e)
                                    }
                                case MyResult.Err(e) => MyResult.Err(e)
                            }
                        case MyResult.Err(e) => MyResult.Err(e)
                    }
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func read_u64_be(data: Array<UInt8>, pos: Int64): MyResult<(UInt64, Int64), DecodeError> {
    match (read_u8(data, pos)) {
        case MyResult.Ok((b7, p1)) =>
            match (read_u8(data, p1)) {
                case MyResult.Ok((b6, p2)) =>
                    match (read_u8(data, p2)) {
                        case MyResult.Ok((b5, p3)) =>
                            match (read_u8(data, p3)) {
                                case MyResult.Ok((b4, p4)) =>
                                    match (read_u8(data, p4)) {
                                        case MyResult.Ok((b3, p5)) =>
                                            match (read_u8(data, p5)) {
                                                case MyResult.Ok((b2, p6)) =>
                                                    match (read_u8(data, p6)) {
                                                        case MyResult.Ok((b1, p7)) =>
                                                            match (read_u8(data, p7)) {
                                                                case MyResult.Ok((b0, p8)) => MyResult.Ok((
                                                                    combine_u8_u64_local(b0, b1, b2, b3, b4, b5, b6, b7)
                                                                    , p8))
                                                                case MyResult.Err(e) => MyResult.Err(e)
                                                            }
                                                        case MyResult.Err(e) => MyResult.Err(e)
                                                    }
                                                case MyResult.Err(e) => MyResult.Err(e)
                                            }
                                        case MyResult.Err(e) => MyResult.Err(e)
                                    }
                                case MyResult.Err(e) => MyResult.Err(e)
                            }
                        case MyResult.Err(e) => MyResult.Err(e)
                    }
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

// ---- unsigned varint encode ----
public func varint_encode_u16(val: UInt16, buf: ArrayList<UInt8>): Unit {
    if (val < 251) { buf.add(u16_to_u8(val)) }
    else { buf.add(U16_BYTE); buf.add(u16_to_u8(val & 0xFF)); buf.add(u16_to_u8((val >> 8) & 0xFF)) }
}

public func varint_encode_u32(val: UInt32, buf: ArrayList<UInt8>): Unit {
    if (val < 251) { buf.add(u32_to_u8(val)) }
    else if (val < 65536) { buf.add(U16_BYTE); buf.add(u32_to_u8(val & 0xFF)); buf.add(u32_to_u8((val >> 8) & 0xFF)) }
    else { buf.add(U32_BYTE); buf.add(u32_to_u8(val & 0xFF)); buf.add(u32_to_u8((val >> 8) & 0xFF)); buf.add(u32_to_u8((val >> 16) & 0xFF)); buf.add(u32_to_u8((val >> 24) & 0xFF)) }
}

public func varint_encode_u64(val: UInt64, buf: ArrayList<UInt8>): Unit {
    if (val < 251) { buf.add(u64_to_u8(val)) }
    else if (val < 65536) { buf.add(U16_BYTE); buf.add(u64_to_u8(val & 0xFF)); buf.add(u64_to_u8((val >> 8) & 0xFF)) }
    else if (val < 4294967296) { buf.add(U32_BYTE); buf.add(u64_to_u8(val & 0xFF)); buf.add(u64_to_u8((val >> 8) & 0xFF)); buf.add(u64_to_u8((val >> 16) & 0xFF)); buf.add(u64_to_u8((val >> 24) & 0xFF)) }
    else { buf.add(U64_BYTE); buf.add(u64_to_u8(val & 0xFF)); buf.add(u64_to_u8((val >> 8) & 0xFF)); buf.add(u64_to_u8((val >> 16) & 0xFF)); buf.add(u64_to_u8((val >> 24) & 0xFF)); buf.add(u64_to_u8((val >> 32) & 0xFF)); buf.add(u64_to_u8((val >> 40) & 0xFF)); buf.add(u64_to_u8((val >> 48) & 0xFF)); buf.add(u64_to_u8((val >> 56) & 0xFF)) }
}

public func varint_encode_u128(val: UInt128, buf: ArrayList<UInt8>): Unit {
    if (val.hi == 0 && val.lo < 251) { buf.add(u64_to_u8(val.lo)) }
    else if (val.hi == 0 && val.lo < 65536) { buf.add(U16_BYTE); buf.add(u64_to_u8(val.lo & 0xFF)); buf.add(u64_to_u8((val.lo >> 8) & 0xFF)) }
    else if (val.hi == 0 && val.lo < 4294967296) { buf.add(U32_BYTE); buf.add(u64_to_u8(val.lo & 0xFF)); buf.add(u64_to_u8((val.lo >> 8) & 0xFF)); buf.add(u64_to_u8((val.lo >> 16) & 0xFF)); buf.add(u64_to_u8((val.lo >> 24) & 0xFF)) }
    else if (val.hi == 0) { buf.add(U64_BYTE); buf.add(u64_to_u8(val.lo & 0xFF)); buf.add(u64_to_u8((val.lo >> 8) & 0xFF)); buf.add(u64_to_u8((val.lo >> 16) & 0xFF)); buf.add(u64_to_u8((val.lo >> 24) & 0xFF)); buf.add(u64_to_u8((val.lo >> 32) & 0xFF)); buf.add(u64_to_u8((val.lo >> 40) & 0xFF)); buf.add(u64_to_u8((val.lo >> 48) & 0xFF)); buf.add(u64_to_u8((val.lo >> 56) & 0xFF)) }
    else { buf.add(U128_BYTE); buf.add(u64_to_u8(val.lo & 0xFF)); buf.add(u64_to_u8((val.lo >> 8) & 0xFF)); buf.add(u64_to_u8((val.lo >> 16) & 0xFF)); buf.add(u64_to_u8((val.lo >> 24) & 0xFF)); buf.add(u64_to_u8((val.lo >> 32) & 0xFF)); buf.add(u64_to_u8((val.lo >> 40) & 0xFF)); buf.add(u64_to_u8((val.lo >> 48) & 0xFF)); buf.add(u64_to_u8((val.lo >> 56) & 0xFF)); buf.add(u64_to_u8(val.hi & 0xFF)); buf.add(u64_to_u8((val.hi >> 8) & 0xFF)); buf.add(u64_to_u8((val.hi >> 16) & 0xFF)); buf.add(u64_to_u8((val.hi >> 24) & 0xFF)); buf.add(u64_to_u8((val.hi >> 32) & 0xFF)); buf.add(u64_to_u8((val.hi >> 40) & 0xFF)); buf.add(u64_to_u8((val.hi >> 48) & 0xFF)); buf.add(u64_to_u8((val.hi >> 56) & 0xFF)) }
}

// ---- signed varint encode (zigzag) ----
// 注意：使用 `i64_to_u64(-val)` 而非 `!i64_to_u64(val)`，因为 bitwise NOT 在 two's complement 中等于 `-val-1`，而非 `-val`
// 例如：`!(-42i64)` = 41, 但 `-(-42i64)` = 42；正确公式应为 `(-val) * 2 - 1` = 83
@OverflowWrapping
public func zigzag_encode_i16(val: Int16): UInt16 {
    if (val >= 0) { i16_to_u16(val) * 2 } else { i16_to_u16(-val) * 2 - 1 }
}
@OverflowWrapping
public func zigzag_encode_i32(val: Int32): UInt32 {
    if (val >= 0) { i32_to_u32(val) * 2 } else { i32_to_u32(-val) * 2 - 1 }
}
@OverflowWrapping
public func zigzag_encode_i64(val: Int64): UInt64 {
    if (val >= 0) { i64_to_u64(val) * 2 } else { i64_to_u64(-val) * 2 - 1 }
}

public func varint_encode_i16(val: Int16, buf: ArrayList<UInt8>): Unit { varint_encode_u16(zigzag_encode_i16(val), buf) }
public func varint_encode_i32(val: Int32, buf: ArrayList<UInt8>): Unit { varint_encode_u32(zigzag_encode_i32(val), buf) }
public func varint_encode_i64(val: Int64, buf: ArrayList<UInt8>): Unit { varint_encode_u64(zigzag_encode_i64(val), buf) }

// ---- usize/isize varint encode (delegates to u64/i64) ----
public func varint_encode_usize(val: Usize, buf: ArrayList<UInt8>): Unit { varint_encode_u64(val, buf) }
public func varint_encode_isize(val: Isize, buf: ArrayList<UInt8>): Unit { varint_encode_i64(val, buf) }

// ---- unsigned varint decode ----
public func decode_integer_type(tag: UInt8): IntegerType {
    if (tag == U16_BYTE) { IntegerType.U16 }
    else if (tag == U32_BYTE) { IntegerType.U32 }
    else if (tag == U64_BYTE) { IntegerType.U64 }
    else if (tag == U128_BYTE) { IntegerType.Reserved }
    else { IntegerType.Reserved }
}

public func varint_decode_u16(data: Array<UInt8>, pos: Int64): MyResult<(UInt16, Int64), DecodeError> {
    match (read_u8(data, pos)) {
        case MyResult.Ok((first, p1)) =>
            if (first < 251) { MyResult.Ok((u8_to_u16_local(first), p1)) }
            else if (first == U16_BYTE) {
                match (read_u16_le(data, p1)) {
                    case MyResult.Ok((val, p2)) => MyResult.Ok((val, p2))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else { MyResult.Err(DecodeError.InvalidIntegerType(IntegerType.U16, decode_integer_type(first))) }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func varint_decode_u32(data: Array<UInt8>, pos: Int64): MyResult<(UInt32, Int64), DecodeError> {
    match (read_u8(data, pos)) {
        case MyResult.Ok((first, p1)) =>
            if (first < 251) { MyResult.Ok((u8_to_u32_local(first), p1)) }
            else if (first == U16_BYTE) {
                match (read_u16_le(data, p1)) {
                    case MyResult.Ok((val, p2)) => MyResult.Ok((u16_to_u32(val), p2))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else if (first == U32_BYTE) {
                match (read_u32_le(data, p1)) {
                    case MyResult.Ok((val, p2)) => MyResult.Ok((val, p2))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else { MyResult.Err(DecodeError.InvalidIntegerType(IntegerType.U32, decode_integer_type(first))) }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func varint_decode_u64(data: Array<UInt8>, pos: Int64): MyResult<(UInt64, Int64), DecodeError> {
    match (read_u8(data, pos)) {
        case MyResult.Ok((first, p1)) =>
            if (first < 251) { MyResult.Ok((u8_to_u64_local(first), p1)) }
            else if (first == U16_BYTE) {
                match (read_u16_le(data, p1)) {
                    case MyResult.Ok((val, p2)) => MyResult.Ok((u16_to_u64(val), p2))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else if (first == U32_BYTE) {
                match (read_u32_le(data, p1)) {
                    case MyResult.Ok((val, p2)) => MyResult.Ok((u32_to_u64(val), p2))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else if (first == U64_BYTE) {
                match (read_u64_le(data, p1)) {
                    case MyResult.Ok((val, p2)) => MyResult.Ok((val, p2))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else { MyResult.Err(DecodeError.InvalidIntegerType(IntegerType.U64, decode_integer_type(first))) }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func varint_decode_u128(data: Array<UInt8>, pos: Int64): MyResult<(UInt128, Int64), DecodeError> {
    match (read_u8(data, pos)) {
        case MyResult.Ok((first, p1)) =>
            if (first < 251) { MyResult.Ok((UInt128(u8_to_u64(first), 0), p1)) }
            else if (first == U16_BYTE) {
                match (read_u16_le(data, p1)) {
                    case MyResult.Ok((val, p2)) => MyResult.Ok((UInt128(u16_to_u64(val), 0), p2))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else if (first == U32_BYTE) {
                match (read_u32_le(data, p1)) {
                    case MyResult.Ok((val, p2)) => MyResult.Ok((UInt128(u32_to_u64(val), 0), p2))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else if (first == U64_BYTE) {
                match (read_u64_le(data, p1)) {
                    case MyResult.Ok((val, p2)) => MyResult.Ok((UInt128(val, 0), p2))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else if (first == U128_BYTE) {
                match (read_u64_le(data, p1)) {
                    case MyResult.Ok((lo, p2)) =>
                        match (read_u64_le(data, p2)) {
                            case MyResult.Ok((hi, p3)) => MyResult.Ok((UInt128(lo, hi), p3))
                            case MyResult.Err(e) => MyResult.Err(e)
                        }
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else { MyResult.Err(DecodeError.InvalidIntegerType(IntegerType.Reserved, decode_integer_type(first))) }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

// ---- signed varint decode (zigzag) ----
public func zigzag_decode_u16(val: UInt16): Int16 { zigzag_decode_helper_u16(val) }
public func zigzag_decode_u32(val: UInt32): Int32 { zigzag_decode_helper_u32(val) }
public func zigzag_decode_u64(val: UInt64): Int64 { zigzag_decode_helper_u64(val) }

public func varint_decode_i16(data: Array<UInt8>, pos: Int64): MyResult<(Int16, Int64), DecodeError> {
    match (varint_decode_u16(data, pos)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((zigzag_decode_u16(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func varint_decode_i32(data: Array<UInt8>, pos: Int64): MyResult<(Int32, Int64), DecodeError> {
    match (varint_decode_u32(data, pos)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((zigzag_decode_u32(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func varint_decode_i64(data: Array<UInt8>, pos: Int64): MyResult<(Int64, Int64), DecodeError> {
    match (varint_decode_u64(data, pos)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((zigzag_decode_u64(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

// ---- usize/isize varint decode (delegates to u64/i64) ----
public func varint_decode_usize(data: Array<UInt8>, pos: Int64): MyResult<(Usize, Int64), DecodeError> {
    varint_decode_u64(data, pos)
}
public func varint_decode_isize(data: Array<UInt8>, pos: Int64): MyResult<(Isize, Int64), DecodeError> {
    varint_decode_i64(data, pos)
}