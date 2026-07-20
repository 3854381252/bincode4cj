// atomic.cj — Atomic type encode/decode implementations
package bincode4cj
import std.collection.*
import std.sync.*

// === AtomicBool ===
public func encode_atomic_bool(val: AtomicBool, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_bool(val.load(), config, buf)
}

// === AtomicUInt8 ===
public func encode_atomic_uint8(val: AtomicUInt8, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_u8(val.load(), config, buf)
}

// === AtomicUInt16 ===
public func encode_atomic_uint16(val: AtomicUInt16, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_u16(val.load(), config, buf)
}

// === AtomicUInt32 ===
public func encode_atomic_uint32(val: AtomicUInt32, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_u32(val.load(), config, buf)
}

// === AtomicUInt64 ===
public func encode_atomic_uint64(val: AtomicUInt64, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_u64(val.load(), config, buf)
}

// === AtomicInt8 ===
public func encode_atomic_int8(val: AtomicInt8, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_i8(val.load(), config, buf)
}

// === AtomicInt16 ===
public func encode_atomic_int16(val: AtomicInt16, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_i16(val.load(), config, buf)
}

// === AtomicInt32 ===
public func encode_atomic_int32(val: AtomicInt32, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_i32(val.load(), config, buf)
}

// === AtomicInt64 ===
public func encode_atomic_int64(val: AtomicInt64, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_i64(val.load(), config, buf)
}

// === AtomicUsize（使用 AtomicUInt64 作为底层类型） ===
public func encode_atomic_usize(val: AtomicUInt64, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_u64(val.load(), config, buf)
}

// === AtomicIsize（使用 AtomicInt64 作为底层类型） ===
public func encode_atomic_isize(val: AtomicInt64, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_i64(val.load(), config, buf)
}

// === Atomic decode functions ===

public func decode_atomic_bool(data: Array<UInt8>, pos: Int64): MyResult<(AtomicBool, Int64), DecodeError> {
    match (decode_bool(data, pos)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((AtomicBool(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_atomic_uint8(data: Array<UInt8>, pos: Int64, _config: Config): MyResult<(AtomicUInt8, Int64), DecodeError> {
    match (decode_u8(data, pos)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((AtomicUInt8(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_atomic_uint16(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(AtomicUInt16, Int64), DecodeError> {
    match (decode_u16(data, pos, config)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((AtomicUInt16(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_atomic_uint32(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(AtomicUInt32, Int64), DecodeError> {
    match (decode_u32(data, pos, config)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((AtomicUInt32(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_atomic_uint64(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(AtomicUInt64, Int64), DecodeError> {
    match (decode_u64(data, pos, config)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((AtomicUInt64(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_atomic_int8(data: Array<UInt8>, pos: Int64): MyResult<(AtomicInt8, Int64), DecodeError> {
    match (decode_i8(data, pos)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((AtomicInt8(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_atomic_int16(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(AtomicInt16, Int64), DecodeError> {
    match (decode_i16(data, pos, config)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((AtomicInt16(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_atomic_int32(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(AtomicInt32, Int64), DecodeError> {
    match (decode_i32(data, pos, config)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((AtomicInt32(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_atomic_int64(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(AtomicInt64, Int64), DecodeError> {
    match (decode_i64(data, pos, config)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((AtomicInt64(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_atomic_usize(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(AtomicUInt64, Int64), DecodeError> {
    match (decode_u64(data, pos, config)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((AtomicUInt64(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_atomic_isize(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(AtomicInt64, Int64), DecodeError> {
    match (decode_i64(data, pos, config)) {
        case MyResult.Ok((v, p)) => MyResult.Ok((AtomicInt64(v), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}