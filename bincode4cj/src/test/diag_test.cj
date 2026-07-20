// diag_test.cj — Diagnostic test for UInt8→UInt32 conversion failure in varint.cj
package bincode4cj.test
import std.collection.*
import std.unittest.*
import bincode4cj.{ MyResult, DecodeError, read_u8, varint_decode_u32, varint_decode_u16, varint_decode_u64, varint_encode_u16, varint_encode_u32, varint_encode_u64, standard, encode_u16, encode_u32, encode_u64, decode_u16, decode_u32, decode_u64, u16_to_u8, i64_to_u64, encode_string, decode_string, bytes_to_string }

// 直接复制的测试用函数，用于隔离问题
@OverflowWrapping
func u8_to_u32_diag(x: UInt8): UInt32 { UInt32(x) }

@Test
public class DiagTests {
    // 测试1: 直接调用 UInt32(UInt8) - 基础测试
    @TestCase
    public func test_direct_conv() {
        @Expect(UInt32(42u8), 42u32)
    }

    // 测试2: 通过简单函数调用
    @TestCase
    public func test_simple_func() {
        @Expect(u8_to_u32_diag(42u8), 42u32)
    }

    // 测试3: 在 match 表达式中调用
    @TestCase
    public func test_in_match() {
        let data: Array<UInt8> = [42u8]
        match (read_u8(data, 0)) {
            case MyResult.Ok((first, p1)) =>
                @Expect(u8_to_u32_diag(first), 42u32)
            case _ => @Expect(false)
        }
    }

    // 测试4: 在 match 中直接 UInt32()
    @TestCase
    public func test_in_match_direct() {
        let data: Array<UInt8> = [42u8]
        match (read_u8(data, 0)) {
            case MyResult.Ok((first, p1)) =>
                @Expect(UInt32(first), 42u32)
            case _ => @Expect(false)
        }
    }

    // 测试5: 通过 varint_decode_u32
    @TestCase
    public func test_via_varint_decode() {
        let data: Array<UInt8> = [42u8]
        match (varint_decode_u32(data, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 42u32)
            case _ => @Expect(false)
        }
    }

    // 测试6: 在 match 中用变量绑定而非解构
    @TestCase
    public func test_match_with_var() {
        let data: Array<UInt8> = [42u8]
        match (read_u8(data, 0)) {
            case MyResult.Ok(pair) =>
                let first = pair[0]
                @Expect(UInt32(first), 42u32)
            case _ => @Expect(false)
        }
    }

    // === 诊断：varint 编解码中间值 ===

    // 检查 u16_to_u8 函数
    @TestCase
    public func test_u16_to_u8_diag() {
        @Expect(u16_to_u8(232u16), 232u8)
        @Expect(u16_to_u8(3u16), 3u8)
    }

    // 检查 UInt8(Int64(x)) 是否可行
    @OverflowWrapping
    @TestCase
    public func test_uint8_from_int64_diag() {
        @Expect(UInt8(Int64(232)), 232u8)
    }

    // 检查 UInt8(UInt16(x)) 是否可行
    @OverflowWrapping
    @TestCase
    public func test_uint8_from_uint16_diag() {
        @Expect(UInt8(UInt16(232)), 232u8)
    }

    // 检查 UInt8(UInt32(x)) 是否可行
    @OverflowWrapping
    @TestCase
    public func test_uint8_from_uint32_diag() {
        @Expect(UInt8(UInt32(232)), 232u8)
    }

    // 检查 UInt8(UInt64(x)) 是否可行
    @OverflowWrapping
    @TestCase
    public func test_uint8_from_uint64_diag() {
        @Expect(UInt8(UInt64(232)), 232u8)
    }

    // 检查 String.toArray()
    @TestCase
    public func test_string_to_array_diag() {
        let bytes = "hello".toArray()
        @Expect(bytes.size, 5)
        @Expect(bytes[0], 104u8)
    }

    // 检查 encode_string 输出
    @TestCase
    public func test_encode_string_diag() {
        let buf = ArrayList<UInt8>()
        encode_string("hello", standard, buf)
        @Expect(buf.size, 6)
        @Expect(buf[0], 5u8)
        @Expect(buf[1], 104u8)
    }

    // 检查 bytes_to_string
    @TestCase
    public func test_bytes_to_string_diag() {
        let s = bytes_to_string([104u8, 101u8, 108u8, 108u8, 111u8])
        @Expect(s, "hello")
    }

    // 检查 String(Rune[]) 构造
    @TestCase
    public func test_string_from_runes_diag() {
        let runes = [Rune(104), Rune(101), Rune(108), Rune(108), Rune(111)]
        let s = String(runes)
        @Expect(s, "hello")
    }

    // 检查位运算
    @TestCase
    public func test_bitwise_diag() {
        @Expect(1000u16 & 0xFFu16, 232u16)
        @Expect((1000u16 >> 8) & 0xFFu16, 3u16)
    }

    // 直接测试 varint_encode_u16 输出
    @TestCase
    public func test_varint_encode_u16_diag() {
        let buf = ArrayList<UInt8>()
        varint_encode_u16(1000u16, buf)
        @Expect(buf.size, 3)
        @Expect(buf[0], 251u8)
        @Expect(buf[1], 232u8)
        @Expect(buf[2], 3u8)
    }

    // 直接测试 varint_decode_u16
    @TestCase
    public func test_varint_decode_u16_diag() {
        let data: Array<UInt8> = [251u8, 232u8, 3u8]
        match (varint_decode_u16(data, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 1000u16)
            case _ => @Expect(false)
        }
    }

    // 直接测试 combine_u8_u16_local — 通过 varint_decode_u16 间接测试
    @TestCase
    public func test_varint_decode_u16_small_diag() {
        let data: Array<UInt8> = [42u8]
        match (varint_decode_u16(data, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 42u16)
            case _ => @Expect(false)
        }
    }

    // 直接测试 read_u16_le + combine_u8_u16_local
    @TestCase
    public func test_varint_decode_u16_two_bytes_diag() {
        let data: Array<UInt8> = [251u8, 0x34u8, 0x12u8]
        match (varint_decode_u16(data, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 0x1234u16)
            case _ => @Expect(false)
        }
    }

    // 测试 encode_u16 + decode_u16 完整路径
    @TestCase
    public func test_encode_decode_u16_roundtrip_diag() {
        let buf = ArrayList<UInt8>()
        encode_u16(1000u16, standard, buf)
        @Expect(buf.size, 3)
        match (decode_u16(buf.toArray(), 0, standard)) {
            case MyResult.Ok((val, _)) => @Expect(val, 1000u16)
            case _ => @Expect(false)
        }
    }

    // 测试 encode_u32 + decode_u32 完整路径
    @TestCase
    public func test_encode_decode_u32_roundtrip_diag() {
        let buf = ArrayList<UInt8>()
        encode_u32(100000u32, standard, buf)
        @Expect(buf.size, 5)
        match (decode_u32(buf.toArray(), 0, standard)) {
            case MyResult.Ok((val, _)) => @Expect(val, 100000u32)
            case _ => @Expect(false)
        }
    }

    // 测试 encode_u64 + decode_u64 完整路径
    @TestCase
    public func test_encode_decode_u64_roundtrip_diag() {
        let buf = ArrayList<UInt8>()
        encode_u64(10000000000u64, standard, buf)
        @Expect(buf.size, 9)
        match (decode_u64(buf.toArray(), 0, standard)) {
            case MyResult.Ok((val, _)) => @Expect(val, 10000000000u64)
            case _ => @Expect(false)
        }
    }
}