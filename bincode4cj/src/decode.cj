// decode.cj — Decode helper functions
package bincode4cj
import std.collection.*
import std.fs.*
import std.net.*
import std.time.*

public func is_varint(config: Config): Bool {
    match (config.int_encoding()) {
        case IntEncoding.Variable => true
        case _ => false
    }
}

public func is_little_endian(config: Config): Bool {
    match (config.endianness()) {
        case Endianness.Little => true
        case _ => false
    }
}

public func decode_u8(data: Array<UInt8>, pos: Int64): MyResult<(UInt8, Int64), DecodeError> { read_u8(data, pos) }

public func decode_bool(data: Array<UInt8>, pos: Int64): MyResult<(Bool, Int64), DecodeError> {
    match (decode_u8(data, pos)) {
        case MyResult.Ok((val, p)) =>
            if (val == 0) { MyResult.Ok((false, p)) }
            else if (val == 1) { MyResult.Ok((true, p)) }
            else { MyResult.Err(DecodeError.InvalidBooleanValue(val)) }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_u16(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(UInt16, Int64), DecodeError> {
    if (is_varint(config)) { varint_decode_u16(data, pos) }
    else {
        if (is_little_endian(config)) { read_u16_le(data, pos) }
        else { read_u16_be(data, pos) }
    }
}

@OverflowWrapping
public func decode_u32(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(UInt32, Int64), DecodeError> {
    if (is_varint(config)) { varint_decode_u32(data, pos) }
    else {
        if (is_little_endian(config)) { read_u32_le(data, pos) }
        else { read_u32_be(data, pos) }
    }
}

public func decode_u64(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(UInt64, Int64), DecodeError> {
    if (is_varint(config)) { varint_decode_u64(data, pos) }
    else {
        if (is_little_endian(config)) { read_u64_le(data, pos) }
        else { read_u64_be(data, pos) }
    }
}

public func decode_i8(data: Array<UInt8>, pos: Int64): MyResult<(Int8, Int64), DecodeError> {
    match (decode_u8(data, pos)) {
        case MyResult.Ok((v, p)) =>
            MyResult.Ok((Int8(Int64(v)), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_i16(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Int16, Int64), DecodeError> {
    if (is_varint(config)) {
        match (varint_decode_i16(data, pos)) {
            case MyResult.Ok(v) => MyResult.Ok(v)
            case MyResult.Err(e) => MyResult.Err(e)
        }
    } else {
        let r = if (is_little_endian(config)) { read_u16_le(data, pos) } else { read_u16_be(data, pos) }
        match (r) {
            case MyResult.Ok((v, p)) =>
                MyResult.Ok((Int16(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

public func decode_i32(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Int32, Int64), DecodeError> {
    if (is_varint(config)) {
        match (varint_decode_i32(data, pos)) {
            case MyResult.Ok(v) => MyResult.Ok(v)
            case MyResult.Err(e) => MyResult.Err(e)
        }
    } else {
        let r = if (is_little_endian(config)) { read_u32_le(data, pos) } else { read_u32_be(data, pos) }
        match (r) {
            case MyResult.Ok((v, p)) =>
                MyResult.Ok((Int32(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

public func decode_i64(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Int64, Int64), DecodeError> {
    if (is_varint(config)) {
        match (varint_decode_i64(data, pos)) {
            case MyResult.Ok(v) => MyResult.Ok(v)
            case MyResult.Err(e) => MyResult.Err(e)
        }
    } else {
        let r = if (is_little_endian(config)) { read_u64_le(data, pos) } else { read_u64_be(data, pos) }
        match (r) {
            case MyResult.Ok((v, p)) =>
                MyResult.Ok((Int64(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

public func decode_f32(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Float32, Int64), DecodeError> {
    let r = if (is_little_endian(config)) { read_u32_le(data, pos) } else { read_u32_be(data, pos) }
    match (r) {
        case MyResult.Ok((bits, p)) => MyResult.Ok((Float32.fromBits(bits), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_f64(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Float64, Int64), DecodeError> {
    let r = if (is_little_endian(config)) { read_u64_le(data, pos) } else { read_u64_be(data, pos) }
    match (r) {
        case MyResult.Ok((bits, p)) => MyResult.Ok((Float64.fromBits(bits), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

// Read bytes into ArrayList using a loop (no multi-statement match arms)
public func read_bytes_into(data: Array<UInt8>, pos: Int64, len: Int64): MyResult<(ArrayList<UInt8>, Int64), DecodeError> {
    var buf = ArrayList<UInt8>()
    var p = pos
    var i: Int64 = 0
    while (i < len) {
        let r = read_u8(data, p)
        match (r) {
            case MyResult.Ok((b, _)) => buf.add(b)
            case MyResult.Err(e) => return MyResult.Err(e)
        }
        p = p + 1
        i = i + 1
    }
    MyResult.Ok((buf, p))
}

public func decode_string(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(String, Int64), DecodeError> {
    match (decode_u64(data, pos, config)) {
        case MyResult.Ok((len, p)) =>
            match (read_bytes_into(data, p, u64_to_i64(len))) {
                case MyResult.Ok((buf, p2)) => MyResult.Ok((bytes_to_string(buf.toArray()), p2))
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_char(data: Array<UInt8>, pos: Int64, _: Config): MyResult<(Rune, Int64), DecodeError> {
    match (read_u8(data, pos)) {
        case MyResult.Ok((first, p1)) =>
            if (first < 0x80) { MyResult.Ok((Rune(UInt32(first)), p1)) }
            else if (first < 0xE0) {
                match (read_u8(data, p1)) {
                    case MyResult.Ok((second, p2)) =>
                        let cp = (UInt32(first & 0x1F) << 6) | UInt32(second & 0x3F)
                        MyResult.Ok((Rune(cp), p2))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else if (first < 0xF0) {
                match (read_u8(data, p1)) {
                    case MyResult.Ok((second, p2)) =>
                        match (read_u8(data, p2)) {
                            case MyResult.Ok((third, p3)) =>
                                let cp = (UInt32(first & 0x0F) << 12) | (UInt32(second & 0x3F) << 6) | UInt32(third & 0x3F)
                                MyResult.Ok((Rune(cp), p3))
                            case MyResult.Err(e) => MyResult.Err(e)
                        }
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else {
                match (read_u8(data, p1)) {
                    case MyResult.Ok((second, p2)) =>
                        match (read_u8(data, p2)) {
                            case MyResult.Ok((third, p3)) =>
                                match (read_u8(data, p3)) {
                                    case MyResult.Ok((fourth, p4)) =>
                                        let cp = (UInt32(first & 0x07) << 18) | (UInt32(second & 0x3F) << 12) | (UInt32(third & 0x3F) << 6) | UInt32(fourth & 0x3F)
                                        MyResult.Ok((Rune(cp), p4))
                                    case MyResult.Err(e) => MyResult.Err(e)
                                }
                            case MyResult.Err(e) => MyResult.Err(e)
                        }
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_duration(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Duration, Int64), DecodeError> {
    match (decode_u64(data, pos, config)) {
        case MyResult.Ok((secs, p1)) =>
            match (decode_u32(data, p1, config)) {
                case MyResult.Ok((nanos, p2)) => MyResult.Ok((Int64(secs) * Duration.second + Int64(nanos) * Duration.nanosecond, p2))
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_path(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Path, Int64), DecodeError> {
    match (decode_string(data, pos, config)) {
        case MyResult.Ok((s, p)) => MyResult.Ok((Path(s), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_ipv4_address(data: Array<UInt8>, pos: Int64, _: Config): MyResult<(IPv4Address, Int64), DecodeError> {
    match (read_u32_le(data, pos)) {
        case MyResult.Ok((bits, p)) => MyResult.Ok((IPv4Address(UInt8(bits & 0xFF), UInt8((bits >> 8) & 0xFF), UInt8((bits >> 16) & 0xFF), UInt8((bits >> 24) & 0xFF)), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_ip_address(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(IPAddress, Int64), DecodeError> {
    match (decode_string(data, pos, config)) {
        case MyResult.Ok((s, p)) => MyResult.Ok((IPAddress.parse(s), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_ip_socket_address(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(IPSocketAddress, Int64), DecodeError> {
    match (decode_string(data, pos, config)) {
        case MyResult.Ok((s, p)) => MyResult.Ok((IPSocketAddress.parse(s), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_ipv6_address(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(IPAddress, Int64), DecodeError> {
    match (decode_string(data, pos, config)) {
        case MyResult.Ok((s, p)) => MyResult.Ok((IPAddress.parse(s), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_date_time(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(DateTime, Int64), DecodeError> {
    match (decode_string(data, pos, config)) {
        case MyResult.Ok((s, p)) => MyResult.Ok((DateTime.parse(s, "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXX"), p))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

// === SocketAddrV4 / SocketAddrV6 解码 ===

public func decode_socket_addr_v4(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(SocketAddrV4, Int64), DecodeError> {
    match (decode_ipv4_address(data, pos, config)) {
        case MyResult.Ok((ip, p1)) =>
            match (decode_u16(data, p1, config)) {
                case MyResult.Ok((port, p2)) => MyResult.Ok((SocketAddrV4(ip, port), p2))
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_socket_addr_v6(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(SocketAddrV6, Int64), DecodeError> {
    match (decode_ipv6_address(data, pos, config)) {
        case MyResult.Ok((addr, p1)) =>
            match (addr as IPv6Address) {
                case Some(ipv6) =>
                    match (decode_u16(data, p1, config)) {
                        case MyResult.Ok((port, p2)) =>
                            match (decode_u32(data, p2, config)) {
                                case MyResult.Ok((flow_info, p3)) =>
                                    match (decode_u32(data, p3, config)) {
                                        case MyResult.Ok((scope_id, p4)) => MyResult.Ok((SocketAddrV6(ipv6, port, flow_info, scope_id), p4))
                                        case MyResult.Err(e) => MyResult.Err(e)
                                    }
                                case MyResult.Err(e) => MyResult.Err(e)
                            }
                        case MyResult.Err(e) => MyResult.Err(e)
                    }
                case None => MyResult.Err(DecodeError.Other("Expected IPv6Address"))
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

// === 容器类型 ===

public func decode_arraylist<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(ArrayList<T>, Int64), DecodeError> where T <: Decode<T> {
    match (decode_u64(data, pos, config)) {
        case MyResult.Ok((len, p)) =>
            var result = ArrayList<T>()
            var cp = p
            var i: Int64 = 0
            while (i < u64_to_i64(len)) {
                let r = T.decode(data, cp, config)
                match (r) {
                    case MyResult.Ok((val, np)) => cp = arraylist_add_and_return(result, val, np)
                    case MyResult.Err(e) => return MyResult.Err(e)
                }
                i += 1
            }
            MyResult.Ok((result, cp))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_array<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Array<T>, Int64), DecodeError> where T <: Decode<T> {
    match (decode_u64(data, pos, config)) {
        case MyResult.Ok((len, p)) =>
            var result = ArrayList<T>()
            var cp = p
            var i: Int64 = 0
            while (i < u64_to_i64(len)) {
                let r = T.decode(data, cp, config)
                match (r) {
                    case MyResult.Ok((val, np)) => cp = arraylist_add_and_return(result, val, np)
                    case MyResult.Err(e) => return MyResult.Err(e)
                }
                i += 1
            }
            MyResult.Ok((result.toArray(), cp))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_hashmap<K, V>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(HashMap<K, V>, Int64), DecodeError> where K <: Decode<K> & Hashable & Equatable<K>, V <: Decode<V> {
    match (decode_u64(data, pos, config)) {
        case MyResult.Ok((len, p)) =>
            var result = HashMap<K, V>()
            var cp = p
            var i: Int64 = 0
            while (i < u64_to_i64(len)) {
                let r = decode_hashmap_next(data, cp, config, result)
                match (r) {
                    case MyResult.Ok(np) => cp = np
                    case MyResult.Err(e) => return MyResult.Err(e)
                }
                i += 1
            }
            MyResult.Ok((result, cp))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_hashset<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(HashSet<T>, Int64), DecodeError> where T <: Decode<T> & Hashable & Equatable<T> {
    match (decode_u64(data, pos, config)) {
        case MyResult.Ok((len, p)) =>
            var result = HashSet<T>()
            var cp = p
            var i: Int64 = 0
            while (i < u64_to_i64(len)) {
                let r = T.decode(data, cp, config)
                match (r) {
                    case MyResult.Ok((val, np)) => cp = hashset_add_and_return(result, val, np)
                    case MyResult.Err(e) => return MyResult.Err(e)
                }
                i += 1
            }
            MyResult.Ok((result, cp))
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_option<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Option<T>, Int64), DecodeError> where T <: Decode<T> {
    match (decode_u8(data, pos)) {
        case MyResult.Ok((tag, p)) =>
            if (tag == 0) { MyResult.Ok((Option<T>.None, p)) }
            else if (tag == 1) {
                match (T.decode(data, p, config)) {
                    case MyResult.Ok((val, np)) => MyResult.Ok((Option<T>.Some(val), np))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else { MyResult.Err(DecodeError.Other("Invalid option tag")) }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

public func decode_result<T, E>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(MyResult<T, E>, Int64), DecodeError> where T <: Decode<T>, E <: Decode<E> {
    match (decode_u8(data, pos)) {
        case MyResult.Ok((tag, p)) =>
            if (tag == 0) {
                match (T.decode(data, p, config)) {
                    case MyResult.Ok((val, np)) => MyResult.Ok((MyResult.Ok(val), np))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else if (tag == 1) {
                match (E.decode(data, p, config)) {
                    case MyResult.Ok((err, np)) => MyResult.Ok((MyResult.Err(err), np))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else { MyResult.Err(DecodeError.Other("Invalid result tag")) }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

// 自定义 Range 解码
public func decode_range_custom<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((T, T), Int64), DecodeError> where T <: Decode<T> {
    match (T.decode(data, pos, config)) {
        case MyResult.Ok((start, p1)) =>
            match (T.decode(data, p1, config)) {
                case MyResult.Ok((end, p2)) => MyResult.Ok(((start, end), p2))
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

// RangeInclusive 解码（解码为 start + end）
public func decode_range_inclusive<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((T, T), Int64), DecodeError> where T <: Decode<T> {
    decode_range_custom(data, pos, config)
}

// Bound 解码
public func decode_bound<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(BoundEnum<T>, Int64), DecodeError> where T <: Decode<T> {
    match (decode_u8(data, pos)) {
        case MyResult.Ok((tag, p)) =>
            if (tag == 0) { MyResult.Ok((BoundEnum.Unbounded, p)) }
            else if (tag == 1) {
                match (T.decode(data, p, config)) {
                    case MyResult.Ok((v, np)) => MyResult.Ok((BoundEnum.Included(v), np))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else if (tag == 2) {
                match (T.decode(data, p, config)) {
                    case MyResult.Ok((v, np)) => MyResult.Ok((BoundEnum.Excluded(v), np))
                    case MyResult.Err(e) => MyResult.Err(e)
                }
            }
            else { MyResult.Err(DecodeError.Other("Invalid bound tag")) }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

// === 元组解码 (2-16) ===

// 1 元组在 Cangjie 中无字面量语法，从 2 元组开始
// 1 元组在 Cangjie 中无字面量语法，使用 decode_tuple1 函数
public func decode_tuple1<A>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(A, Int64), DecodeError> where A <: Decode<A> {
    A.decode(data, pos, config)
}
public func decode_tuple2<A, B>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B> {
    match (A.decode(data, pos, config)) {
        case MyResult.Ok((a, p1)) =>
            match (B.decode(data, p1, config)) {
                case MyResult.Ok((b, p2)) => MyResult.Ok(((a, b), p2))
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_tuple3<A, B, C>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B, C), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>, C <: Decode<C> {
    match (A.decode(data, pos, config)) {
        case MyResult.Ok((a, p1)) =>
            match (B.decode(data, p1, config)) {
                case MyResult.Ok((b, p2)) =>
                    match (C.decode(data, p2, config)) {
                        case MyResult.Ok((c, p3)) => MyResult.Ok(((a, b, c), p3))
                        case MyResult.Err(e) => MyResult.Err(e)
                    }
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_tuple4<A, B, C, D>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B, C, D), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>, C <: Decode<C>, D <: Decode<D> {
    match (A.decode(data, pos, config)) {
        case MyResult.Ok((a, p1)) =>
            match (B.decode(data, p1, config)) {
                case MyResult.Ok((b, p2)) =>
                    match (C.decode(data, p2, config)) {
                        case MyResult.Ok((c, p3)) =>
                            match (D.decode(data, p3, config)) {
                                case MyResult.Ok((d, p4)) => MyResult.Ok(((a, b, c, d), p4))
                                case MyResult.Err(e) => MyResult.Err(e)
                            }
                        case MyResult.Err(e) => MyResult.Err(e)
                    }
                case MyResult.Err(e) => MyResult.Err(e)
            }
        case MyResult.Err(e) => MyResult.Err(e)
    }
}
public func decode_tuple5<A, B, C, D, E>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B, C, D, E), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>, C <: Decode<C>, D <: Decode<D>, E <: Decode<E> {
    match (A.decode(data, pos, config)) {
        case MyResult.Ok((a, p1)) =>
            match (B.decode(data, p1, config)) {
                case MyResult.Ok((b, p2)) =>
                    match (C.decode(data, p2, config)) {
                        case MyResult.Ok((c, p3)) =>
                            match (D.decode(data, p3, config)) {
                                case MyResult.Ok((d, p4)) =>
                                    match (E.decode(data, p4, config)) {
                                        case MyResult.Ok((e, p5)) => MyResult.Ok(((a, b, c, d, e), p5))
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
public func decode_tuple6<A, B, C, D, E, F>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B, C, D, E, F), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>, C <: Decode<C>, D <: Decode<D>, E <: Decode<E>, F <: Decode<F> {
    match (A.decode(data, pos, config)) {
        case MyResult.Ok((a, p1)) =>
            match (B.decode(data, p1, config)) {
                case MyResult.Ok((b, p2)) =>
                    match (C.decode(data, p2, config)) {
                        case MyResult.Ok((c, p3)) =>
                            match (D.decode(data, p3, config)) {
                                case MyResult.Ok((d, p4)) =>
                                    match (E.decode(data, p4, config)) {
                                        case MyResult.Ok((e, p5)) =>
                                            match (F.decode(data, p5, config)) {
                                                case MyResult.Ok((f, p6)) => MyResult.Ok(((a, b, c, d, e, f), p6))
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
public func decode_tuple7<A, B, C, D, E, F, G>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B, C, D, E, F, G), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>, C <: Decode<C>, D <: Decode<D>, E <: Decode<E>, F <: Decode<F>, G <: Decode<G> {
    match (A.decode(data, pos, config)) {
        case MyResult.Ok((a, p1)) =>
            match (B.decode(data, p1, config)) {
                case MyResult.Ok((b, p2)) =>
                    match (C.decode(data, p2, config)) {
                        case MyResult.Ok((c, p3)) =>
                            match (D.decode(data, p3, config)) {
                                case MyResult.Ok((d, p4)) =>
                                    match (E.decode(data, p4, config)) {
                                        case MyResult.Ok((e, p5)) =>
                                            match (F.decode(data, p5, config)) {
                                                case MyResult.Ok((f, p6)) =>
                                                    match (G.decode(data, p6, config)) {
                                                        case MyResult.Ok((g, p7)) => MyResult.Ok(((a, b, c, d, e, f, g), p7))
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
public func decode_tuple8<A, B, C, D, E, F, G, H>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B, C, D, E, F, G, H), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>, C <: Decode<C>, D <: Decode<D>, E <: Decode<E>, F <: Decode<F>, G <: Decode<G>, H <: Decode<H> {
    match (A.decode(data, pos, config)) {
        case MyResult.Ok((a, p1)) =>
            match (B.decode(data, p1, config)) {
                case MyResult.Ok((b, p2)) =>
                    match (C.decode(data, p2, config)) {
                        case MyResult.Ok((c, p3)) =>
                            match (D.decode(data, p3, config)) {
                                case MyResult.Ok((d, p4)) =>
                                    match (E.decode(data, p4, config)) {
                                        case MyResult.Ok((e, p5)) =>
                                            match (F.decode(data, p5, config)) {
                                                case MyResult.Ok((f, p6)) =>
                                                    match (G.decode(data, p6, config)) {
                                                        case MyResult.Ok((g, p7)) =>
                                                            match (H.decode(data, p7, config)) {
                                                                case MyResult.Ok((h, p8)) => MyResult.Ok(((a, b, c, d, e, f, g, h), p8))
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