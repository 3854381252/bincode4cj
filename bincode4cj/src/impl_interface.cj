// impl_interface.cj — Encode/Decode interface implementations for basic types
package bincode4cj
import std.collection.*

// === Encode 接口实现 ===

extend UInt8 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_u8(this, config, buf) }
}
extend UInt16 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_u16(this, config, buf) }
}
extend UInt32 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_u32(this, config, buf) }
}
extend UInt64 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_u64(this, config, buf) }
}
extend Int8 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_i8(this, config, buf) }
}
extend Int16 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_i16(this, config, buf) }
}
extend Int32 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_i32(this, config, buf) }
}
extend Int64 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_i64(this, config, buf) }
}
extend Float32 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_f32(this, config, buf) }
}
extend Float64 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_f64(this, config, buf) }
}
extend Bool <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_bool(this, config, buf) }
}
extend String <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_string(this, config, buf) }
}
extend Rune <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_char(this, config, buf) }
}
extend Duration <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit { encode_duration(this, config, buf) }
}

// === Decode 接口实现（平替 Rust BorrowDecode） ===
// Cangjie 不支持生命周期，所有解码均为 owned 拷贝

extend UInt8 <: Decode<UInt8> {
    public static func decode(data: Array<UInt8>, pos: Int64, _: Config): MyResult<(UInt8, Int64), DecodeError> { decode_u8(data, pos) }
}
extend UInt16 <: Decode<UInt16> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(UInt16, Int64), DecodeError> { decode_u16(data, pos, config) }
}
extend UInt32 <: Decode<UInt32> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(UInt32, Int64), DecodeError> { decode_u32(data, pos, config) }
}
extend UInt64 <: Decode<UInt64> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(UInt64, Int64), DecodeError> { decode_u64(data, pos, config) }
}
extend Int8 <: Decode<Int8> {
    public static func decode(data: Array<UInt8>, pos: Int64, _: Config): MyResult<(Int8, Int64), DecodeError> { decode_i8(data, pos) }
}
extend Int16 <: Decode<Int16> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Int16, Int64), DecodeError> { decode_i16(data, pos, config) }
}
extend Int32 <: Decode<Int32> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Int32, Int64), DecodeError> { decode_i32(data, pos, config) }
}
extend Int64 <: Decode<Int64> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Int64, Int64), DecodeError> { decode_i64(data, pos, config) }
}
extend Float32 <: Decode<Float32> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Float32, Int64), DecodeError> { decode_f32(data, pos, config) }
}
extend Float64 <: Decode<Float64> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Float64, Int64), DecodeError> { decode_f64(data, pos, config) }
}
extend Bool <: Decode<Bool> {
    public static func decode(data: Array<UInt8>, pos: Int64, _: Config): MyResult<(Bool, Int64), DecodeError> { decode_bool(data, pos) }
}
extend String <: Decode<String> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(String, Int64), DecodeError> { decode_string(data, pos, config) }
}
extend Rune <: Decode<Rune> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Rune, Int64), DecodeError> { decode_char(data, pos, config) }
}
extend Duration <: Decode<Duration> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Duration, Int64), DecodeError> { decode_duration(data, pos, config) }
}

// === NonZero Encode/Decode ===

extend NonZeroU8 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_u8(this.get(), config, buf)
    }
}
extend NonZeroU8 <: Decode<NonZeroU8> {
    public static func decode(data: Array<UInt8>, pos: Int64, _config: Config): MyResult<(NonZeroU8, Int64), DecodeError> {
        match (decode_u8(data, pos)) {
            case MyResult.Ok((v, p)) =>
                if (v == 0) { MyResult.Err(DecodeError.NonZeroTypeIsZero(IntegerType.U8)) }
                else { MyResult.Ok((NonZeroU8(v), p)) }
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}
extend NonZeroU16 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_u16(this.get(), config, buf)
    }
}
extend NonZeroU16 <: Decode<NonZeroU16> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(NonZeroU16, Int64), DecodeError> {
        match (decode_u16(data, pos, config)) {
            case MyResult.Ok((v, p)) =>
                if (v == 0) { MyResult.Err(DecodeError.NonZeroTypeIsZero(IntegerType.U16)) }
                else { MyResult.Ok((NonZeroU16(v), p)) }
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}
extend NonZeroU32 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_u32(this.get(), config, buf)
    }
}
extend NonZeroU32 <: Decode<NonZeroU32> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(NonZeroU32, Int64), DecodeError> {
        match (decode_u32(data, pos, config)) {
            case MyResult.Ok((v, p)) =>
                if (v == 0) { MyResult.Err(DecodeError.NonZeroTypeIsZero(IntegerType.U32)) }
                else { MyResult.Ok((NonZeroU32(v), p)) }
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}
extend NonZeroU64 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_u64(this.get(), config, buf)
    }
}
extend NonZeroU64 <: Decode<NonZeroU64> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(NonZeroU64, Int64), DecodeError> {
        match (decode_u64(data, pos, config)) {
            case MyResult.Ok((v, p)) =>
                if (v == 0) { MyResult.Err(DecodeError.NonZeroTypeIsZero(IntegerType.U64)) }
                else { MyResult.Ok((NonZeroU64(v), p)) }
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}
extend NonZeroI8 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_i8(this.get(), config, buf)
    }
}
extend NonZeroI8 <: Decode<NonZeroI8> {
    public static func decode(data: Array<UInt8>, pos: Int64, _config: Config): MyResult<(NonZeroI8, Int64), DecodeError> {
        match (decode_i8(data, pos)) {
            case MyResult.Ok((v, p)) =>
                if (v == 0) { MyResult.Err(DecodeError.NonZeroTypeIsZero(IntegerType.I8)) }
                else { MyResult.Ok((NonZeroI8(v), p)) }
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}
extend NonZeroI16 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_i16(this.get(), config, buf)
    }
}
extend NonZeroI16 <: Decode<NonZeroI16> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(NonZeroI16, Int64), DecodeError> {
        match (decode_i16(data, pos, config)) {
            case MyResult.Ok((v, p)) =>
                if (v == 0) { MyResult.Err(DecodeError.NonZeroTypeIsZero(IntegerType.I16)) }
                else { MyResult.Ok((NonZeroI16(v), p)) }
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}
extend NonZeroI32 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_i32(this.get(), config, buf)
    }
}
extend NonZeroI32 <: Decode<NonZeroI32> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(NonZeroI32, Int64), DecodeError> {
        match (decode_i32(data, pos, config)) {
            case MyResult.Ok((v, p)) =>
                if (v == 0) { MyResult.Err(DecodeError.NonZeroTypeIsZero(IntegerType.I32)) }
                else { MyResult.Ok((NonZeroI32(v), p)) }
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}
extend NonZeroI64 <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_i64(this.get(), config, buf)
    }
}
extend NonZeroI64 <: Decode<NonZeroI64> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(NonZeroI64, Int64), DecodeError> {
        match (decode_i64(data, pos, config)) {
            case MyResult.Ok((v, p)) =>
                if (v == 0) { MyResult.Err(DecodeError.NonZeroTypeIsZero(IntegerType.I64)) }
                else { MyResult.Ok((NonZeroI64(v), p)) }
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === Wrapping<T> Encode/Decode ===
extend<T> Wrapping<T> <: Encode where T <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        this.get().encode(config, buf)
    }
}
extend<T> Wrapping<T> <: Decode<Wrapping<T>> where T <: Decode<T> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Wrapping<T>, Int64), DecodeError> {
        match (T.decode(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((Wrapping<T>(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === Reverse<T> Encode/Decode ===
extend<T> Reverse<T> <: Encode where T <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        this.get().encode(config, buf)
    }
}
extend<T> Reverse<T> <: Decode<Reverse<T>> where T <: Decode<T> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Reverse<T>, Int64), DecodeError> {
        match (T.decode(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((Reverse<T>(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === Cell<T> Encode/Decode ===
extend<T> Cell<T> <: Encode where T <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        this.get().encode(config, buf)
    }
}
extend<T> Cell<T> <: Decode<Cell<T>> where T <: Decode<T> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Cell<T>, Int64), DecodeError> {
        match (T.decode(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((Cell<T>(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === RefCell<T> Encode/Decode ===
// 注意：encode 使用 into_inner() 获取值，不检查借用状态（与 Rust 行为一致）
extend<T> RefCell<T> <: Encode where T <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        this.into_inner().encode(config, buf)
    }
}
extend<T> RefCell<T> <: Decode<RefCell<T>> where T <: Decode<T> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(RefCell<T>, Int64), DecodeError> {
        match (T.decode(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((RefCell<T>(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === CString Encode/Decode ===
extend CString <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_string(this.get(), config, buf)
    }
}
extend CString <: Decode<CString> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(CString, Int64), DecodeError> {
        match (decode_string(data, pos, config)) {
            case MyResult.Ok((s, p)) =>
                try {
                    MyResult.Ok((CString(s), p))
                } catch (e: Exception) {
                    MyResult.Err(DecodeError.CStringNulError(0))
                }
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === Boxed<T> Encode/Decode ===
extend<T> Boxed<T> <: Encode where T <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        this.get().encode(config, buf)
    }
}
extend<T> Boxed<T> <: Decode<Boxed<T>> where T <: Decode<T> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Boxed<T>, Int64), DecodeError> {
        match (T.decode(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((Boxed<T>(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === RefCounted<T> Encode/Decode ===
extend<T> RefCounted<T> <: Encode where T <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        this.get().encode(config, buf)
    }
}
extend<T> RefCounted<T> <: Decode<RefCounted<T>> where T <: Decode<T> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(RefCounted<T>, Int64), DecodeError> {
        match (T.decode(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((RefCounted<T>(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === AtomicRefCounted<T> Encode/Decode ===
extend<T> AtomicRefCounted<T> <: Encode where T <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        this.get().encode(config, buf)
    }
}
extend<T> AtomicRefCounted<T> <: Decode<AtomicRefCounted<T>> where T <: Decode<T> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(AtomicRefCounted<T>, Int64), DecodeError> {
        match (T.decode(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((AtomicRefCounted<T>(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === CowEnum<T> Encode/Decode ===
extend<T> CowEnum<T> <: Encode where T <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        match (this) {
            case CowEnum.Borrowed(v) => v.encode(config, buf)
            case CowEnum.Owned(v) => v.encode(config, buf)
        }
    }
}
extend<T> CowEnum<T> <: Decode<CowEnum<T>> where T <: Decode<T> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(CowEnum<T>, Int64), DecodeError> {
        match (T.decode(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((CowEnum<T>.Owned(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === SyncMutex<T> Encode/Decode ===
extend<T> SyncMutex<T> <: Encode where T <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        this.lock_and_get().encode(config, buf)
    }
}
extend<T> SyncMutex<T> <: Decode<SyncMutex<T>> where T <: Decode<T> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(SyncMutex<T>, Int64), DecodeError> {
        match (T.decode(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((SyncMutex<T>(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === RwLock_<T> Encode/Decode ===
extend<T> RwLock_<T> <: Encode where T <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        this.into_inner().encode(config, buf)
    }
}
extend<T> RwLock_<T> <: Decode<RwLock_<T>> where T <: Decode<T> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(RwLock_<T>, Int64), DecodeError> {
        match (T.decode(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((RwLock_<T>(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === NonZeroU128 Encode/Decode ===
extend NonZeroU128 <: Encode {
    public func encode(_config: Config, buf: ArrayList<UInt8>): Unit {
        varint_encode_u128(this.get(), buf)
    }
}
extend NonZeroU128 <: Decode<NonZeroU128> {
    public static func decode(data: Array<UInt8>, pos: Int64, _config: Config): MyResult<(NonZeroU128, Int64), DecodeError> {
        match (varint_decode_u128(data, pos)) {
            case MyResult.Ok((v, p)) =>
                if (v.lo == 0 && v.hi == 0) { MyResult.Err(DecodeError.NonZeroTypeIsZero(IntegerType.U128)) }
                else { MyResult.Ok((NonZeroU128(v), p)) }
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === NonZeroUsize Encode/Decode ===
extend NonZeroUsize <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_u64(this.get(), config, buf)
    }
}
extend NonZeroUsize <: Decode<NonZeroUsize> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(NonZeroUsize, Int64), DecodeError> {
        match (decode_u64(data, pos, config)) {
            case MyResult.Ok((v, p)) =>
                if (v == 0) { MyResult.Err(DecodeError.NonZeroTypeIsZero(IntegerType.Usize)) }
                else { MyResult.Ok((NonZeroUsize(v), p)) }
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === UInt128 Encode/Decode ===
extend UInt128 <: Encode {
    public func encode(_config: Config, buf: ArrayList<UInt8>): Unit {
        varint_encode_u128(this, buf)
    }
}
extend UInt128 <: Decode<UInt128> {
    public static func decode(data: Array<UInt8>, pos: Int64, _config: Config): MyResult<(UInt128, Int64), DecodeError> {
        varint_decode_u128(data, pos)
    }
}

// === BoxedStr Encode/Decode ===
extend BoxedStr <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_string(this.get(), config, buf)
    }
}
extend BoxedStr <: Decode<BoxedStr> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(BoxedStr, Int64), DecodeError> {
        match (decode_string(data, pos, config)) {
            case MyResult.Ok((s, p)) => MyResult.Ok((BoxedStr(s), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === BoxedSlice<T> Encode/Decode ===
// 注意：Decode 未实现，因仓颉泛型类型推断限制（decode_array 无法推断 T）
extend<T> BoxedSlice<T> <: Encode where T <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_array(this.get(), config, buf)
    }
}

// === RefCountedStr Encode/Decode ===
extend RefCountedStr <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_string(this.get(), config, buf)
    }
}
extend RefCountedStr <: Decode<RefCountedStr> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(RefCountedStr, Int64), DecodeError> {
        match (decode_string(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((RefCountedStr(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// === AtomicRefCountedStr Encode/Decode ===
extend AtomicRefCountedStr <: Encode {
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        encode_string(this.get(), config, buf)
    }
}
extend AtomicRefCountedStr <: Decode<AtomicRefCountedStr> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(AtomicRefCountedStr, Int64), DecodeError> {
        match (decode_string(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((AtomicRefCountedStr(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}