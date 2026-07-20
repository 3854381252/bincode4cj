// encode.cj — Encode helper functions
package bincode4cj
import std.collection.*
import std.fs.*
import std.net.*
import std.time.*

public func encode_bool(val: Bool, _: Config, buf: ArrayList<UInt8>): Unit {
    buf.add(if (val) { 1u8 } else { 0u8 })
}
public func encode_u8(val: UInt8, _: Config, buf: ArrayList<UInt8>): Unit { buf.add(val) }

public func encode_u16(val: UInt16, config: Config, buf: ArrayList<UInt8>): Unit {
    if (is_varint(config)) { varint_encode_u16(val, buf) }
    else {
        if (is_little_endian(config)) {
            buf.add(u16_to_u8(val & 0xFF)); buf.add(u16_to_u8((val >> 8) & 0xFF))
        } else {
            buf.add(u16_to_u8((val >> 8) & 0xFF)); buf.add(u16_to_u8(val & 0xFF))
        }
    }
}

public func encode_u32(val: UInt32, config: Config, buf: ArrayList<UInt8>): Unit {
    if (is_varint(config)) { varint_encode_u32(val, buf) }
    else {
        if (is_little_endian(config)) {
            buf.add(u32_to_u8(val & 0xFF)); buf.add(u32_to_u8((val >> 8) & 0xFF))
            buf.add(u32_to_u8((val >> 16) & 0xFF)); buf.add(u32_to_u8((val >> 24) & 0xFF))
        } else {
            buf.add(u32_to_u8((val >> 24) & 0xFF)); buf.add(u32_to_u8((val >> 16) & 0xFF))
            buf.add(u32_to_u8((val >> 8) & 0xFF)); buf.add(u32_to_u8(val & 0xFF))
        }
    }
}

public func encode_u64(val: UInt64, config: Config, buf: ArrayList<UInt8>): Unit {
    if (is_varint(config)) { varint_encode_u64(val, buf) }
    else {
        if (is_little_endian(config)) {
            buf.add(u64_to_u8(val & 0xFF)); buf.add(u64_to_u8((val >> 8) & 0xFF))
            buf.add(u64_to_u8((val >> 16) & 0xFF)); buf.add(u64_to_u8((val >> 24) & 0xFF))
            buf.add(u64_to_u8((val >> 32) & 0xFF)); buf.add(u64_to_u8((val >> 40) & 0xFF))
            buf.add(u64_to_u8((val >> 48) & 0xFF)); buf.add(u64_to_u8((val >> 56) & 0xFF))
        } else {
            buf.add(u64_to_u8((val >> 56) & 0xFF)); buf.add(u64_to_u8((val >> 48) & 0xFF))
            buf.add(u64_to_u8((val >> 40) & 0xFF)); buf.add(u64_to_u8((val >> 32) & 0xFF))
            buf.add(u64_to_u8((val >> 24) & 0xFF)); buf.add(u64_to_u8((val >> 16) & 0xFF))
            buf.add(u64_to_u8((val >> 8) & 0xFF)); buf.add(u64_to_u8(val & 0xFF))
        }
    }
}

public func encode_i8(val: Int8, _: Config, buf: ArrayList<UInt8>): Unit { buf.add(i8_to_u8(val)) }

public func encode_i16(val: Int16, config: Config, buf: ArrayList<UInt8>): Unit {
    if (is_varint(config)) { varint_encode_i16(val, buf) }
    else {
        let v = i64_to_u64(i16_to_i64(val))
        if (is_little_endian(config)) {
            buf.add(u64_to_u8(v & 0xFF)); buf.add(u64_to_u8((v >> 8) & 0xFF))
        } else {
            buf.add(u64_to_u8((v >> 8) & 0xFF)); buf.add(u64_to_u8(v & 0xFF))
        }
    }
}

public func encode_i32(val: Int32, config: Config, buf: ArrayList<UInt8>): Unit {
    if (is_varint(config)) { varint_encode_i32(val, buf) }
    else {
        let v = i64_to_u64(i32_to_i64(val))
        if (is_little_endian(config)) {
            buf.add(u64_to_u8(v & 0xFF)); buf.add(u64_to_u8((v >> 8) & 0xFF))
            buf.add(u64_to_u8((v >> 16) & 0xFF)); buf.add(u64_to_u8((v >> 24) & 0xFF))
        } else {
            buf.add(u64_to_u8((v >> 24) & 0xFF)); buf.add(u64_to_u8((v >> 16) & 0xFF))
            buf.add(u64_to_u8((v >> 8) & 0xFF)); buf.add(u64_to_u8(v & 0xFF))
        }
    }
}

public func encode_i64(val: Int64, config: Config, buf: ArrayList<UInt8>): Unit {
    if (is_varint(config)) { varint_encode_i64(val, buf) }
    else {
        let v = i64_to_u64(val)
        if (is_little_endian(config)) {
            buf.add(u64_to_u8(v & 0xFF)); buf.add(u64_to_u8((v >> 8) & 0xFF))
            buf.add(u64_to_u8((v >> 16) & 0xFF)); buf.add(u64_to_u8((v >> 24) & 0xFF))
            buf.add(u64_to_u8((v >> 32) & 0xFF)); buf.add(u64_to_u8((v >> 40) & 0xFF))
            buf.add(u64_to_u8((v >> 48) & 0xFF)); buf.add(u64_to_u8((v >> 56) & 0xFF))
        } else {
            buf.add(u64_to_u8((v >> 56) & 0xFF)); buf.add(u64_to_u8((v >> 48) & 0xFF))
            buf.add(u64_to_u8((v >> 40) & 0xFF)); buf.add(u64_to_u8((v >> 32) & 0xFF))
            buf.add(u64_to_u8((v >> 24) & 0xFF)); buf.add(u64_to_u8((v >> 16) & 0xFF))
            buf.add(u64_to_u8((v >> 8) & 0xFF)); buf.add(u64_to_u8(v & 0xFF))
        }
    }
}

public func encode_f32(val: Float32, config: Config, buf: ArrayList<UInt8>): Unit {
    let bits = val.toBits()
    if (is_little_endian(config)) {
        buf.add(u32_to_u8(bits & 0xFF)); buf.add(u32_to_u8((bits >> 8) & 0xFF))
        buf.add(u32_to_u8((bits >> 16) & 0xFF)); buf.add(u32_to_u8((bits >> 24) & 0xFF))
    } else {
        buf.add(u32_to_u8((bits >> 24) & 0xFF)); buf.add(u32_to_u8((bits >> 16) & 0xFF))
        buf.add(u32_to_u8((bits >> 8) & 0xFF)); buf.add(u32_to_u8(bits & 0xFF))
    }
}

public func encode_f64(val: Float64, config: Config, buf: ArrayList<UInt8>): Unit {
    let bits = val.toBits()
    if (is_little_endian(config)) {
        buf.add(u64_to_u8(bits & 0xFF)); buf.add(u64_to_u8((bits >> 8) & 0xFF))
        buf.add(u64_to_u8((bits >> 16) & 0xFF)); buf.add(u64_to_u8((bits >> 24) & 0xFF))
        buf.add(u64_to_u8((bits >> 32) & 0xFF)); buf.add(u64_to_u8((bits >> 40) & 0xFF))
        buf.add(u64_to_u8((bits >> 48) & 0xFF)); buf.add(u64_to_u8((bits >> 56) & 0xFF))
    } else {
        buf.add(u64_to_u8((bits >> 56) & 0xFF)); buf.add(u64_to_u8((bits >> 48) & 0xFF))
        buf.add(u64_to_u8((bits >> 40) & 0xFF)); buf.add(u64_to_u8((bits >> 32) & 0xFF))
        buf.add(u64_to_u8((bits >> 24) & 0xFF)); buf.add(u64_to_u8((bits >> 16) & 0xFF))
        buf.add(u64_to_u8((bits >> 8) & 0xFF)); buf.add(u64_to_u8(bits & 0xFF))
    }
}

public func encode_string(val: String, config: Config, buf: ArrayList<UInt8>): Unit {
    let bytes = val.toArray()
    encode_u64(i64_to_u64(bytes.size), config, buf)
    var i: Int64 = 0
    while (i < bytes.size) { buf.add(bytes[i]); i += 1 }
}

public func encode_char(val: Rune, _: Config, buf: ArrayList<UInt8>): Unit {
    let cp = UInt32(val)
    if (cp < 0x80) { buf.add(UInt8(cp)) }
    else if (cp < 0x800) {
        buf.add(UInt8(0xC0 | (cp >> 6)))
        buf.add(UInt8(0x80 | (cp & 0x3F)))
    }
    else if (cp < 0x10000) {
        buf.add(UInt8(0xE0 | (cp >> 12)))
        buf.add(UInt8(0x80 | ((cp >> 6) & 0x3F)))
        buf.add(UInt8(0x80 | (cp & 0x3F)))
    }
    else {
        buf.add(UInt8(0xF0 | (cp >> 18)))
        buf.add(UInt8(0x80 | ((cp >> 12) & 0x3F)))
        buf.add(UInt8(0x80 | ((cp >> 6) & 0x3F)))
        buf.add(UInt8(0x80 | (cp & 0x3F)))
    }
}

public func encode_duration(val: Duration, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_u64(i64_to_u64(val.toSeconds()), config, buf)
    encode_u32(i64_to_u32(val.toNanoseconds()), config, buf)
}

public func encode_path(val: Path, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_string(val.toString(), config, buf)
}

// === 容器类型 ===

// VecWriter — 写入动态字节数组
public class VecWriter {
    var buf: ArrayList<UInt8>
    public init() { this.buf = ArrayList<UInt8>() }
    public func write_byte(b: UInt8): Unit { this.buf.add(b) }
    public func write_bytes(bytes: Array<UInt8>): Unit {
        var i: Int64 = 0
        while (i < bytes.size) { this.buf.add(bytes[i]); i += 1 }
    }
    public func collect(): ArrayList<UInt8> { this.buf }
}

public func encode_arraylist<T>(val: ArrayList<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode {
    encode_u64(i64_to_u64(val.size), config, buf)
    var i: Int64 = 0
    while (i < val.size) { val[i].encode(config, buf); i += 1 }
}

// 特化：Array<UInt8> 直接写入字节，无需逐个编码
public func encode_uint8_array(val: Array<UInt8>, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_u64(i64_to_u64(val.size), config, buf)
    var i: Int64 = 0
    while (i < val.size) { buf.add(val[i]); i += 1 }
}

// 通用：Array<T> 逐个编码每个元素
public func encode_array<T>(val: Array<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode {
    encode_u64(i64_to_u64(val.size), config, buf)
    var i: Int64 = 0
    while (i < val.size) { val[i].encode(config, buf); i += 1 }
}

public func encode_hashmap<K, V>(val: HashMap<K, V>, config: Config, buf: ArrayList<UInt8>): Unit where K <: Encode & Hashable & Equatable<K>, V <: Encode {
    encode_u64(i64_to_u64(val.size), config, buf)
    for (entry in val) {
        let k = entry[0]
        let v = entry[1]
        k.encode(config, buf)
        v.encode(config, buf)
    }
}

public func encode_hashset<T>(val: HashSet<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode & Hashable & Equatable<T> {
    encode_u64(i64_to_u64(val.size), config, buf)
    for (elem in val) {
        elem.encode(config, buf)
    }
}

public func encode_option<T>(val: Option<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode {
    match (val) {
        case Option.Some(v) => encode_some_value(v, config, buf)
        case Option.None => buf.add(0u8)
    }
}

public func encode_result<T, E>(val: MyResult<T, E>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode, E <: Encode {
    match (val) {
        case MyResult.Ok(v) => encode_result_ok(v, config, buf)
        case MyResult.Err(e) => encode_result_err(e, config, buf)
    }
}

public func encode_result_ok<T>(v: T, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode {
    buf.add(0u8)
    v.encode(config, buf)
}

public func encode_result_err<E>(e: E, config: Config, buf: ArrayList<UInt8>): Unit where E <: Encode {
    buf.add(1u8)
    e.encode(config, buf)
}

// 自定义 Range 编解码（Cangjie 的 Range<T> 需要 Countable 约束，此处使用自定义类型）
public func encode_range_custom<T>(start: T, end: T, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode {
    start.encode(config, buf)
    end.encode(config, buf)
}

// RangeInclusive 编解码（编码为 start + end，与 Rust bincode 兼容）
public func encode_range_inclusive<T>(start: T, end: T, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode {
    start.encode(config, buf)
    end.encode(config, buf)
}

// Bound 编解码
public func encode_bound<T>(val: BoundEnum<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode {
    match (val) {
        case BoundEnum.Unbounded => buf.add(0u8)
        case BoundEnum.Included(v) => encode_bound_included(v, config, buf)
        case BoundEnum.Excluded(v) => encode_bound_excluded(v, config, buf)
    }
}

public func encode_bound_included<T>(v: T, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode {
    buf.add(1u8)
    v.encode(config, buf)
}

public func encode_bound_excluded<T>(v: T, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode {
    buf.add(2u8)
    v.encode(config, buf)
}

public func encode_to_vec<E>(val: E, config: Config): ArrayList<UInt8> where E <: Encode {
    let buf = ArrayList<UInt8>()
    val.encode(config, buf)
    buf
}

// === 新增类型编码 ===

public func encode_ipv4_address(val: IPv4Address, config: Config, buf: ArrayList<UInt8>): Unit {
    let s = val.toString()
    encode_string(s, config, buf)
}

public func encode_ip_address(val: IPAddress, config: Config, buf: ArrayList<UInt8>): Unit {
    let s = val.toString()
    encode_string(s, config, buf)
}

public func encode_ip_socket_address(val: IPSocketAddress, config: Config, buf: ArrayList<UInt8>): Unit {
    let s = val.toString()
    encode_string(s, config, buf)
}

public func encode_ipv6_address(val: IPv6Address, config: Config, buf: ArrayList<UInt8>): Unit {
    let s = val.toString()
    encode_string(s, config, buf)
}

public func encode_date_time(val: DateTime, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_string(val.toString(), config, buf)
}

// === SocketAddrV4 / SocketAddrV6 编码 ===
// 与 Rust bincode 兼容：SocketAddrV4 = Ipv4Addr + u16 port
// SocketAddrV6 = Ipv6Addr + u16 port + u32 flow_info + u32 scope_id

public func encode_socket_addr_v4(val: SocketAddrV4, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_ipv4_address(val.get_ip(), config, buf)
    encode_u16(val.get_port(), config, buf)
}

public func encode_socket_addr_v6(val: SocketAddrV6, config: Config, buf: ArrayList<UInt8>): Unit {
    encode_ipv6_address(val.get_ip(), config, buf)
    encode_u16(val.get_port(), config, buf)
    encode_u32(val.get_flow_info(), config, buf)
    encode_u32(val.get_scope_id(), config, buf)
}

// === 元组编码 (2-16) ===

// 1 元组在 Cangjie 中无字面量语法，从 2 元组开始
// 1 元组在 Cangjie 中无字面量语法，使用 encode_tuple1 函数
public func encode_tuple1<A>(val: A, config: Config, buf: ArrayList<UInt8>): Unit where A <: Encode {
    val.encode(config, buf)
}
public func encode_tuple2<A, B>(val: (A, B), config: Config, buf: ArrayList<UInt8>): Unit where A <: Encode, B <: Encode {
    val[0].encode(config, buf); val[1].encode(config, buf)
}
public func encode_tuple3<A, B, C>(val: (A, B, C), config: Config, buf: ArrayList<UInt8>): Unit where A <: Encode, B <: Encode, C <: Encode {
    val[0].encode(config, buf); val[1].encode(config, buf); val[2].encode(config, buf)
}
public func encode_tuple4<A, B, C, D>(val: (A, B, C, D), config: Config, buf: ArrayList<UInt8>): Unit where A <: Encode, B <: Encode, C <: Encode, D <: Encode {
    val[0].encode(config, buf); val[1].encode(config, buf); val[2].encode(config, buf); val[3].encode(config, buf)
}
public func encode_tuple5<A, B, C, D, E>(val: (A, B, C, D, E), config: Config, buf: ArrayList<UInt8>): Unit where A <: Encode, B <: Encode, C <: Encode, D <: Encode, E <: Encode {
    val[0].encode(config, buf); val[1].encode(config, buf); val[2].encode(config, buf); val[3].encode(config, buf); val[4].encode(config, buf)
}
public func encode_tuple6<A, B, C, D, E, F>(val: (A, B, C, D, E, F), config: Config, buf: ArrayList<UInt8>): Unit where A <: Encode, B <: Encode, C <: Encode, D <: Encode, E <: Encode, F <: Encode {
    val[0].encode(config, buf); val[1].encode(config, buf); val[2].encode(config, buf); val[3].encode(config, buf); val[4].encode(config, buf); val[5].encode(config, buf)
}
public func encode_tuple7<A, B, C, D, E, F, G>(val: (A, B, C, D, E, F, G), config: Config, buf: ArrayList<UInt8>): Unit where A <: Encode, B <: Encode, C <: Encode, D <: Encode, E <: Encode, F <: Encode, G <: Encode {
    val[0].encode(config, buf); val[1].encode(config, buf); val[2].encode(config, buf); val[3].encode(config, buf); val[4].encode(config, buf); val[5].encode(config, buf); val[6].encode(config, buf)
}
public func encode_tuple8<A, B, C, D, E, F, G, H>(val: (A, B, C, D, E, F, G, H), config: Config, buf: ArrayList<UInt8>): Unit where A <: Encode, B <: Encode, C <: Encode, D <: Encode, E <: Encode, F <: Encode, G <: Encode, H <: Encode {
    val[0].encode(config, buf); val[1].encode(config, buf); val[2].encode(config, buf); val[3].encode(config, buf); val[4].encode(config, buf); val[5].encode(config, buf); val[6].encode(config, buf); val[7].encode(config, buf)
}
// 注意：Cangjie 不支持 9-16 元组字面量，因此 9-16 元组编解码未实现