// conv.cj — Type conversion helpers (Cangjie as returns Option<T>)
package bincode4cj
import std.collection.*

@OverflowWrapping
public func u32_to_u8(x: UInt32): UInt8 { UInt8(x) }
@OverflowWrapping
public func u64_to_u8(x: UInt64): UInt8 { UInt8(x) }
@OverflowWrapping
public func u16_to_u8(x: UInt16): UInt8 { UInt8(x) }
@OverflowWrapping
public func u64_to_u32(x: UInt64): UInt32 { UInt32(x) }
@OverflowWrapping
public func u64_to_u16(x: UInt64): UInt16 { UInt16(x) }
@OverflowWrapping
public func u32_to_u16(x: UInt32): UInt16 { UInt16(x) }
@OverflowWrapping
public func i64_to_u64(x: Int64): UInt64 { UInt64(x) }
@OverflowWrapping
public func i64_to_u32(x: Int64): UInt32 { UInt32(x) }
@OverflowWrapping
public func u8_to_i8(x: UInt8): Int8 { Int8(x) }
@OverflowWrapping
public func u16_to_i16(x: UInt16): Int16 { Int16(x) }
@OverflowWrapping
public func u32_to_i32(x: UInt32): Int32 { Int32(x) }
@OverflowWrapping
public func u64_to_i64(x: UInt64): Int64 { Int64(x) }
public func f32_from_bits(x: UInt32): Float32 { Float32.fromBits(x) }
public func f64_from_bits(x: UInt64): Float64 { Float64.fromBits(x) }
@OverflowWrapping
public func i8_to_u8(x: Int8): UInt8 { UInt8(x) }
@OverflowWrapping
public func i16_to_i64(x: Int16): Int64 { Int64(x) }
@OverflowWrapping
public func i32_to_i64(x: Int32): Int64 { Int64(x) }
@OverflowWrapping
public func bytes_to_string(b: Array<UInt8>): String {
    var runes = ArrayList<Rune>()
    var i: Int64 = 0
    while (i < b.size) {
        runes.add(Rune(UInt32(b[i])))
        i += 1
    }
    String(runes.toArray())
}

@OverflowWrapping
public func combine_u8_u16(lo: UInt8, hi: UInt8): UInt16 {
    let l = u8_to_u16(lo)
    let h = u8_to_u16(hi)
    l | (h << 8)
}
@OverflowWrapping
public func u8_to_u16(x: UInt8): UInt16 {
    UInt16(x)
}
@OverflowWrapping
public func u8_to_u32(x: UInt8): UInt32 {
    UInt32(x)
}
@OverflowWrapping
public func combine_u8_u32(b0: UInt8, b1: UInt8, b2: UInt8, b3: UInt8): UInt32 {
    let v0 = u8_to_u32(b0)
    let v1 = u8_to_u32(b1)
    let v2 = u8_to_u32(b2)
    let v3 = u8_to_u32(b3)
    v0 | (v1 << 8) | (v2 << 16) | (v3 << 24)
}
@OverflowWrapping
public func combine_u8_u64(b0: UInt8, b1: UInt8, b2: UInt8, b3: UInt8, b4: UInt8, b5: UInt8, b6: UInt8, b7: UInt8): UInt64 {
    let v0 = u8_to_u64(b0)
    let v1 = u8_to_u64(b1)
    let v2 = u8_to_u64(b2)
    let v3 = u8_to_u64(b3)
    let v4 = u8_to_u64(b4)
    let v5 = u8_to_u64(b5)
    let v6 = u8_to_u64(b6)
    let v7 = u8_to_u64(b7)
    v0 | (v1 << 8) | (v2 << 16) | (v3 << 24) | (v4 << 32) | (v5 << 40) | (v6 << 48) | (v7 << 56)
}
@OverflowWrapping
public func u8_to_u64(x: UInt8): UInt64 {
    UInt64(x)
}
@OverflowWrapping
public func i16_to_u16(x: Int16): UInt16 {
    let as_i64 = Int64(x)
    UInt16(as_i64 & 0xFFFF)
}
@OverflowWrapping
public func i32_to_u32(x: Int32): UInt32 {
    let as_i64 = Int64(x)
    UInt32(as_i64 & 0xFFFFFFFF)
}
@OverflowWrapping
public func u16_to_u32(x: UInt16): UInt32 { UInt32(x) }
@OverflowWrapping
public func u16_to_u64(x: UInt16): UInt64 { UInt64(x) }
@OverflowWrapping
public func u32_to_u64(x: UInt32): UInt64 { UInt64(x) }
@OverflowWrapping
public func zigzag_decode_helper_u16(val: UInt16): Int16 {
    let r = ((val >> 1) ^ (!(val & 1) + 1))
    Int16(r)
}
@OverflowWrapping
public func zigzag_decode_helper_u32(val: UInt32): Int32 {
    let r = ((val >> 1) ^ (!(val & 1) + 1))
    Int32(r)
}
@OverflowWrapping
public func zigzag_decode_helper_u64(val: UInt64): Int64 {
    let r = ((val >> 1) ^ (!(val & 1) + 1))
    Int64(r)
}

public func encode_kv_pair<K, V>(k: K, v: V, config: Config, buf: ArrayList<UInt8>): Unit where K <: Encode, V <: Encode {
    k.encode(config, buf)
    v.encode(config, buf)
}
public func encode_some_value<T>(v: T, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode {
    buf.add(1u8)
    v.encode(config, buf)
}

// Helper: add one element to result list, update position and counter
public func list_add_one<T>(result: ArrayList<T>, val: T, cp: Int64, i: Int64): (ArrayList<T>, Int64, Int64) {
    result.add(val)
    (result, cp, i + 1)
}
// Helper: add element to list and return updated position (for match arm single-expression)
public func arraylist_add_and_return<T>(result: ArrayList<T>, val: T, np: Int64): Int64 {
    result.add(val)
    np
}
// Helper: add element to set and return updated position (for match arm single-expression)
public func hashset_add_and_return<T>(result: HashSet<T>, val: T, np: Int64): Int64 where T <: Hashable & Equatable<T> {
    result.add(val)
    np
}
// Helper: put one kv pair into hashmap, update position and counter
public func map_put_one<K, V>(result: HashMap<K, V>, key: K, val: V, cp: Int64, i: Int64): (HashMap<K, V>, Int64, Int64) where K <: Hashable & Equatable<K> {
    result.add(key, val)
    (result, cp, i + 1)
}

public func decode_hashmap_next<K, V>(data: Array<UInt8>, pos: Int64, config: Config, result: HashMap<K, V>): MyResult<Int64, DecodeError> where K <: Decode<K> & Hashable & Equatable<K>, V <: Decode<V> {
    let rk = K.decode(data, pos, config)
    match (rk) {
        case MyResult.Ok((key, np)) => decode_hashmap_put_val(data, np, config, key, result)
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_hashmap_put_val<K, V>(data: Array<UInt8>, pos: Int64, config: Config, key: K, result: HashMap<K, V>): MyResult<Int64, DecodeError> where K <: Decode<K> & Hashable & Equatable<K>, V <: Decode<V> {
    let rv = V.decode(data, pos, config)
    match (rv) {
        case MyResult.Ok((val, np2)) => hashmap_put_and_return(result, key, val, np2)
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func hashmap_put_and_return<K, V>(result: HashMap<K, V>, key: K, val: V, np2: Int64): MyResult<Int64, DecodeError> where K <: Hashable & Equatable<K> {
    result.add(key, val)
    MyResult.Ok(np2)
}
