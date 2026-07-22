// varint_be_test.cj - Tests for varint Big-Endian branches and network type binary formats
// 覆盖 varint.cj BE 分支（u16/u32/u64/u128/i16/i32/i64/i128）和 decode.cj 网络类型
package bincode4cj.test
import std.collection.*
import std.net.*
import std.unittest.*
import bincode4cj.{ standard, Endianness, MyResult, DecodeError, UInt128, Int128,
    varint_encode_u16, varint_encode_u32, varint_encode_u64, varint_encode_u128,
    varint_encode_i16, varint_encode_i32, varint_encode_i64, varint_encode_i128,
    varint_decode_u16, varint_decode_u32, varint_decode_u64, varint_decode_u128,
    varint_decode_i16, varint_decode_i32, varint_decode_i64, varint_decode_i128,
    encode_ipv6_address, decode_ipv6_address, encode_ip_address, decode_ip_address,
    encode_ip_socket_address, decode_ip_socket_address,
    encode_socket_addr_v4, decode_socket_addr_v4, encode_socket_addr_v6, decode_socket_addr_v6,
    SocketAddrV4, SocketAddrV6 }

// 辅助函数：验证 u16 BE 往返
func check_u16_be(v: UInt16): Bool {
    let buf = ArrayList<UInt8>()
    varint_encode_u16(v, Endianness.Big, buf)
    match (varint_decode_u16(buf.toArray(), 0, Endianness.Big)) {
        case MyResult.Ok((val, _)) => val == v
        case _ => false
    }
}

// 辅助函数：验证 u32 BE 往返
func check_u32_be(v: UInt32): Bool {
    let buf = ArrayList<UInt8>()
    varint_encode_u32(v, Endianness.Big, buf)
    match (varint_decode_u32(buf.toArray(), 0, Endianness.Big)) {
        case MyResult.Ok((val, _)) => val == v
        case _ => false
    }
}

// 辅助函数：验证 u64 BE 往返
func check_u64_be(v: UInt64): Bool {
    let buf = ArrayList<UInt8>()
    varint_encode_u64(v, Endianness.Big, buf)
    match (varint_decode_u64(buf.toArray(), 0, Endianness.Big)) {
        case MyResult.Ok((val, _)) => val == v
        case _ => false
    }
}

// 辅助函数：验证 i16 BE 往返
func check_i16_be(v: Int16): Bool {
    let buf = ArrayList<UInt8>()
    varint_encode_i16(v, Endianness.Big, buf)
    match (varint_decode_i16(buf.toArray(), 0, Endianness.Big)) {
        case MyResult.Ok((val, _)) => val == v
        case _ => false
    }
}

// 辅助函数：验证 i32 BE 往返
func check_i32_be(v: Int32): Bool {
    let buf = ArrayList<UInt8>()
    varint_encode_i32(v, Endianness.Big, buf)
    match (varint_decode_i32(buf.toArray(), 0, Endianness.Big)) {
        case MyResult.Ok((val, _)) => val == v
        case _ => false
    }
}

// 辅助函数：验证 i64 BE 往返
func check_i64_be(v: Int64): Bool {
    let buf = ArrayList<UInt8>()
    varint_encode_i64(v, Endianness.Big, buf)
    match (varint_decode_i64(buf.toArray(), 0, Endianness.Big)) {
        case MyResult.Ok((val, _)) => val == v
        case _ => false
    }
}

@Test
public class VarintBeTests {

    // === 1. varint BE u16（值 1000，触发 U16_BYTE 多字节 BE 分支）===
    @TestCase
    public func test_varint_be_u16() {
        let buf = ArrayList<UInt8>()
        varint_encode_u16(1000u16, Endianness.Big, buf)
        // 1000 = 0x03E8, BE 多字节: [251(U16_BYTE), 0x03(高字节), 0xE8(低字节)]
        @Expect(buf.size, 3)
        @Expect(buf[0], 251u8)
        @Expect(buf[1], 0x03u8)
        @Expect(buf[2], 0xE8u8)
        // 解码往返验证
        match (varint_decode_u16(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) => @Expect(val, 1000u16)
            case _ => @Expect(false)
        }
    }

    // === 2. varint BE u32（值 100000，触发 U32_BYTE 多字节 BE 分支）===
    @TestCase
    public func test_varint_be_u32() {
        let buf = ArrayList<UInt8>()
        varint_encode_u32(100000u32, Endianness.Big, buf)
        // 100000 = 0x000186A0, BE: [252(U32_BYTE), 0x00, 0x01, 0x86, 0xA0]
        @Expect(buf.size, 5)
        @Expect(buf[0], 252u8)
        @Expect(buf[1], 0x00u8)
        @Expect(buf[2], 0x01u8)
        @Expect(buf[3], 0x86u8)
        @Expect(buf[4], 0xA0u8)
        // 解码往返验证
        match (varint_decode_u32(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) => @Expect(val, 100000u32)
            case _ => @Expect(false)
        }
    }

    // === 3. varint BE u64（值 10000000000，触发 U64_BYTE 多字节 BE 分支）===
    @TestCase
    public func test_varint_be_u64() {
        let buf = ArrayList<UInt8>()
        varint_encode_u64(10000000000u64, Endianness.Big, buf)
        // 10000000000 = 0x00000002540BE400, BE: [253(U64_BYTE), 0x00, 0x00, 0x00, 0x02, 0x54, 0x0B, 0xE4, 0x00]
        @Expect(buf.size, 9)
        @Expect(buf[0], 253u8)
        @Expect(buf[1], 0x00u8)
        @Expect(buf[4], 0x02u8)
        @Expect(buf[5], 0x54u8)
        // 解码往返验证
        match (varint_decode_u64(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) => @Expect(val, 10000000000u64)
            case _ => @Expect(false)
        }
    }

    // === 4. varint BE i16（值 -42，触发 zigzag + u16 单字节路径）===
    @TestCase
    public func test_varint_be_i16_small() {
        let buf = ArrayList<UInt8>()
        varint_encode_i16(-42i16, Endianness.Big, buf)
        // zigzag(-42) = 83, 83 < 251, 单字节
        @Expect(buf.size, 1)
        @Expect(buf[0], 83u8)
        match (varint_decode_i16(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) => @Expect(val, -42i16)
            case _ => @Expect(false)
        }
    }

    // === 4b. varint BE i16（值 -1000，触发 zigzag + u16 多字节 BE 分支）===
    @TestCase
    public func test_varint_be_i16_large() {
        let buf = ArrayList<UInt8>()
        varint_encode_i16(-1000i16, Endianness.Big, buf)
        // zigzag(-1000) = 1999 = 0x07CF, BE: [251, 0x07, 0xCF]
        @Expect(buf.size, 3)
        @Expect(buf[0], 251u8)
        @Expect(buf[1], 0x07u8)
        @Expect(buf[2], 0xCFu8)
        match (varint_decode_i16(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) => @Expect(val, -1000i16)
            case _ => @Expect(false)
        }
    }

    // === 5. varint BE i32（值 -100000，触发 zigzag + u32 多字节 BE 分支）===
    @TestCase
    public func test_varint_be_i32() {
        let buf = ArrayList<UInt8>()
        varint_encode_i32(-100000i32, Endianness.Big, buf)
        // zigzag(-100000) = 199999 = 0x00030D3F, BE: [252, 0x00, 0x03, 0x0D, 0x3F]
        @Expect(buf.size, 5)
        @Expect(buf[0], 252u8)
        match (varint_decode_i32(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) => @Expect(val, -100000i32)
            case _ => @Expect(false)
        }
    }

    // === 6. varint BE i64（值 -10000000000，触发 zigzag + u64 多字节 BE 分支）===
    @TestCase
    public func test_varint_be_i64() {
        let buf = ArrayList<UInt8>()
        varint_encode_i64(-10000000000i64, Endianness.Big, buf)
        // zigzag(-10000000000) = 19999999999, BE: [253, ...]
        @Expect(buf.size, 9)
        @Expect(buf[0], 253u8)
        match (varint_decode_i64(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) => @Expect(val, -10000000000i64)
            case _ => @Expect(false)
        }
    }

    // === 7. varint BE 往返测试（多值覆盖各分支）===
    @TestCase
    public func test_varint_be_roundtrip() {
        // u16: 覆盖单字节、U16_BYTE 分支
        @Expect(check_u16_be(0u16))
        @Expect(check_u16_be(42u16))
        @Expect(check_u16_be(250u16))
        @Expect(check_u16_be(251u16))
        @Expect(check_u16_be(1000u16))
        @Expect(check_u16_be(65535u16))
        // u32: 覆盖单字节、U16_BYTE、U32_BYTE 分支
        @Expect(check_u32_be(0u32))
        @Expect(check_u32_be(250u32))
        @Expect(check_u32_be(65535u32))
        @Expect(check_u32_be(65536u32))
        @Expect(check_u32_be(100000u32))
        @Expect(check_u32_be(4294967295u32))
        // u64: 覆盖单字节、U16_BYTE、U32_BYTE、U64_BYTE 分支
        @Expect(check_u64_be(0u64))
        @Expect(check_u64_be(250u64))
        @Expect(check_u64_be(65535u64))
        @Expect(check_u64_be(100000u64))
        @Expect(check_u64_be(4294967295u64))
        @Expect(check_u64_be(4294967296u64))
        @Expect(check_u64_be(10000000000u64))
        // i16: 覆盖正负值
        @Expect(check_i16_be(0i16))
        @Expect(check_i16_be(42i16))
        @Expect(check_i16_be(-42i16))
        @Expect(check_i16_be(1000i16))
        @Expect(check_i16_be(-1000i16))
        @Expect(check_i16_be(32767i16))
        @Expect(check_i16_be(-32768i16))
        // i32: 覆盖正负值
        @Expect(check_i32_be(0i32))
        @Expect(check_i32_be(42i32))
        @Expect(check_i32_be(-100000i32))
        @Expect(check_i32_be(100000i32))
        // i64: 覆盖正负值
        @Expect(check_i64_be(0i64))
        @Expect(check_i64_be(42i64))
        @Expect(check_i64_be(-10000000000i64))
        @Expect(check_i64_be(10000000000i64))
    }

    // === 8. varint BE u128（UInt128(42, 0)，单字节路径）===
    @TestCase
    public func test_varint_be_u128_small() {
        let buf = ArrayList<UInt8>()
        varint_encode_u128(UInt128(42, 0), Endianness.Big, buf)
        // hi=0, lo=42 < 251, 单字节
        @Expect(buf.size, 1)
        @Expect(buf[0], 42u8)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) =>
                @Expect(val.lo, 42u64)
                @Expect(val.hi, 0u64)
            case _ => @Expect(false)
        }
    }

    // === 8b. varint BE u128（UInt128(1000, 0)，触发 U16_BYTE BE 分支）===
    @TestCase
    public func test_varint_be_u128_u16() {
        let buf = ArrayList<UInt8>()
        varint_encode_u128(UInt128(1000, 0), Endianness.Big, buf)
        // hi=0, lo=1000 >= 251, < 65536 → U16_BYTE BE
        @Expect(buf.size, 3)
        @Expect(buf[0], 251u8)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) =>
                @Expect(val.lo, 1000u64)
                @Expect(val.hi, 0u64)
            case _ => @Expect(false)
        }
    }

    // === 8c. varint BE u128（UInt128(100000, 0)，触发 U32_BYTE BE 分支）===
    @TestCase
    public func test_varint_be_u128_u32() {
        let buf = ArrayList<UInt8>()
        varint_encode_u128(UInt128(100000, 0), Endianness.Big, buf)
        // hi=0, lo=100000 >= 65536, < 4294967296 → U32_BYTE BE
        @Expect(buf.size, 5)
        @Expect(buf[0], 252u8)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) =>
                @Expect(val.lo, 100000u64)
                @Expect(val.hi, 0u64)
            case _ => @Expect(false)
        }
    }

    // === 8d. varint BE u128（UInt128(10000000000, 0)，触发 U64_BYTE BE 分支）===
    @TestCase
    public func test_varint_be_u128_u64() {
        let buf = ArrayList<UInt8>()
        varint_encode_u128(UInt128(10000000000u64, 0u64), Endianness.Big, buf)
        // hi=0, lo=10000000000 >= 4294967296 → U64_BYTE BE
        @Expect(buf.size, 9)
        @Expect(buf[0], 253u8)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) =>
                @Expect(val.lo, 10000000000u64)
                @Expect(val.hi, 0u64)
            case _ => @Expect(false)
        }
    }

    // === 8e. varint BE u128（UInt128(100, 1)，触发 U128_BYTE BE 分支）===
    @TestCase
    public func test_varint_be_u128_full() {
        let buf = ArrayList<UInt8>()
        varint_encode_u128(UInt128(100, 1), Endianness.Big, buf)
        // hi=1, lo=100 → U128_BYTE (254), BE: hi(8字节) + lo(8字节)
        @Expect(buf.size, 17)
        @Expect(buf[0], 254u8)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) =>
                @Expect(val.lo, 100u64)
                @Expect(val.hi, 1u64)
            case _ => @Expect(false)
        }
    }

    // === 8f. varint BE i128（Int128(1000, 0)，触发 zigzag + u128 U16_BYTE BE 分支）===
    @TestCase
    public func test_varint_be_i128() {
        let buf = ArrayList<UInt8>()
        varint_encode_i128(Int128(1000, 0), Endianness.Big, buf)
        // zigzag(1000) = 2000, 2000 >= 251 → U16_BYTE BE
        @Expect(buf.size, 3)
        @Expect(buf[0], 251u8)
        match (varint_decode_i128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) =>
                @Expect(val.lo, 1000u64)
                @Expect(val.hi, 0i64)
            case _ => @Expect(false)
        }
    }

    // === 9. IPv6Address 编码为 16 字节验证 + 往返 ===
    @TestCase
    public func test_ipv6_address_encode_decode() {
        let cfg = standard.with_big_endian()
        let orig = IPv6Address(0x2001, 0x0DB8, 0, 0, 0, 0, 0, 1)
        let buf = ArrayList<UInt8>()
        encode_ipv6_address(orig, cfg, buf)
        // IPv6Address 固定 16 字节
        @Expect(buf.size, 16)
        // 验证 BE 字节序：0x2001 的高字节 0x20 在前
        @Expect(buf[0], 0x20u8)
        @Expect(buf[1], 0x01u8)
        // 往返验证
        match (decode_ipv6_address(buf.toArray(), 0, cfg)) {
            case MyResult.Ok((ip, _)) =>
                match (ip as IPv6Address) {
                    case Some(dec) => @Expect(dec.toString(), orig.toString())
                    case None => @Expect(false)
                }
            case _ => @Expect(false)
        }
    }

    // === 10. IPAddress V4 标记验证 + 往返 ===
    @TestCase
    public func test_ip_address_v4() {
        let cfg = standard.with_big_endian()
        let orig = IPAddress.parse("192.168.1.1")
        let buf = ArrayList<UInt8>()
        encode_ip_address(orig, cfg, buf)
        // varint u32 tag(0) = 1 字节 + IPv4 4 字节 = 5 字节
        @Expect(buf.size, 5)
        @Expect(buf[0], 0u8)
        // 往返验证
        match (decode_ip_address(buf.toArray(), 0, cfg)) {
            case MyResult.Ok((ip, _)) => @Expect(ip.toString(), "192.168.1.1")
            case _ => @Expect(false)
        }
    }

    // === 10b. IPAddress V6 标记验证 + 往返 ===
    @TestCase
    public func test_ip_address_v6() {
        let cfg = standard.with_big_endian()
        let orig = IPAddress.parse("::1")
        let buf = ArrayList<UInt8>()
        encode_ip_address(orig, cfg, buf)
        // varint u32 tag(1) = 1 字节 + IPv6 16 字节 = 17 字节
        @Expect(buf.size, 17)
        @Expect(buf[0], 1u8)
        // 往返验证
        match (decode_ip_address(buf.toArray(), 0, cfg)) {
            case MyResult.Ok((ip, _)) => @Expect(ip.toString(), orig.toString())
            case _ => @Expect(false)
        }
    }

    // === 10c. IPAddress 无效标记错误路径 ===
    @TestCase
    public func test_ip_address_invalid_tag() {
        let cfg = standard.with_big_endian()
        // tag=2（无效），varint u32 单字节
        let data: Array<UInt8> = [2u8]
        match (decode_ip_address(data, 0, cfg)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === 10d. IPSocketAddress V4 往返 ===
    @TestCase
    public func test_ip_socket_address_v4() {
        let cfg = standard.with_big_endian()
        let orig = IPSocketAddress.parse("192.168.1.1:8080")
        let buf = ArrayList<UInt8>()
        encode_ip_socket_address(orig, cfg, buf)
        // varint u32 tag(0) + IPv4(4) + varint u16 port(8080, 3字节) = 1+4+3 = 8
        @Expect(buf.size, 8)
        match (decode_ip_socket_address(buf.toArray(), 0, cfg)) {
            case MyResult.Ok((sa, _)) =>
                @Expect(sa.port, 8080u16)
                @Expect(sa.address.toString(), "192.168.1.1")
            case _ => @Expect(false)
        }
    }

    // === 10e. IPSocketAddress V6 往返 ===
    @TestCase
    public func test_ip_socket_address_v6() {
        let cfg = standard.with_big_endian()
        let orig = IPSocketAddress(IPv6Address(0x2001, 0x0DB8, 0, 0, 0, 0, 0, 1), 8080u16)
        let buf = ArrayList<UInt8>()
        encode_ip_socket_address(orig, cfg, buf)
        // varint u32 tag(1) + IPv6(16) + varint u16 port(8080, 3字节) = 1+16+3 = 20
        @Expect(buf.size, 20)
        match (decode_ip_socket_address(buf.toArray(), 0, cfg)) {
            case MyResult.Ok((sa, _)) =>
                @Expect(sa.port, 8080u16)
            case _ => @Expect(false)
        }
    }

    // === 10f. IPSocketAddress 无效标记错误路径 ===
    @TestCase
    public func test_ip_socket_address_invalid_tag() {
        let cfg = standard.with_big_endian()
        // tag=2（无效）
        let data: Array<UInt8> = [2u8]
        match (decode_ip_socket_address(data, 0, cfg)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === 11. SocketAddrV6 仅 ip+port 验证 + 往返 ===
    @TestCase
    public func test_socket_addr_v6() {
        let cfg = standard.with_big_endian()
        let orig = SocketAddrV6(IPv6Address(0x2001, 0x0DB8, 0, 0, 0, 0, 0, 1), 8080u16, 0u32, 0u32)
        let buf = ArrayList<UInt8>()
        encode_socket_addr_v6(orig, cfg, buf)
        // IPv6(16) + varint u16 port(8080, 3字节) = 16+3 = 19
        @Expect(buf.size, 19)
        match (decode_socket_addr_v6(buf.toArray(), 0, cfg)) {
            case MyResult.Ok((sa, _)) =>
                @Expect(sa.get_port(), 8080u16)
                @Expect(sa.get_ip().toString(), orig.get_ip().toString())
            case _ => @Expect(false)
        }
    }

    // === 11b. SocketAddrV4 仅 ip+port 验证 + 往返 ===
    @TestCase
    public func test_socket_addr_v4() {
        let cfg = standard.with_big_endian()
        let orig = SocketAddrV4(IPv4Address(192, 168, 1, 1), 8080u16)
        let buf = ArrayList<UInt8>()
        encode_socket_addr_v4(orig, cfg, buf)
        // IPv4(4) + varint u16 port(8080, 3字节) = 4+3 = 7
        @Expect(buf.size, 7)
        match (decode_socket_addr_v4(buf.toArray(), 0, cfg)) {
            case MyResult.Ok((sa, _)) =>
                @Expect(sa.get_port(), 8080u16)
                @Expect(sa.get_ip().toString(), "192.168.1.1")
            case _ => @Expect(false)
        }
    }

    // === 11c. SocketAddrV6 小端口（< 251，单字节 varint）===
    @TestCase
    public func test_socket_addr_v6_small_port() {
        let cfg = standard.with_big_endian()
        let orig = SocketAddrV6(IPv6Address(0, 0, 0, 0, 0, 0, 0, 1), 80u16, 0u32, 0u32)
        let buf = ArrayList<UInt8>()
        encode_socket_addr_v6(orig, cfg, buf)
        // IPv6(16) + varint u16 port(80, 1字节) = 16+1 = 17
        @Expect(buf.size, 17)
        match (decode_socket_addr_v6(buf.toArray(), 0, cfg)) {
            case MyResult.Ok((sa, _)) =>
                @Expect(sa.get_port(), 80u16)
            case _ => @Expect(false)
        }
    }
}
