// component_test.cj — Component-level tests (no UInt8 type conversion needed)
package bincode4cj.test
import std.collection.*
import std.time.*
import std.fs.*
import std.unittest.*
import bincode4cj.{ standard, legacy, Config, Endianness, IntEncoding, IntegerType, is_varint, is_little_endian, read_u8, read_u16_le, read_u16_be, read_u32_le, read_u32_be, read_u64_le, read_u64_be, combine_u8_u16, combine_u8_u32, combine_u8_u64, varint_encode_u16, varint_encode_u32, varint_encode_u64, varint_encode_i16, varint_encode_i32, varint_encode_i64, varint_encode_usize, varint_encode_isize, zigzag_encode_i16, zigzag_encode_i32, zigzag_encode_i64, zigzag_decode_u16, zigzag_decode_u32, zigzag_decode_u64, encode_u8, encode_u16, encode_u32, encode_u64, encode_bool, encode_string, encode_char, encode_duration, encode_arraylist, encode_hashmap, encode_hashset, encode_option, encode_result, encode_path, encode_date_time, decode_u8, decode_u16, decode_u32, decode_u64, decode_bool, decode_string, decode_char, decode_duration, decode_arraylist, decode_hashmap, decode_hashset, decode_option, decode_result, VecWriter, MyResult, UInt128, varint_encode_u128, varint_decode_u128, varint_decode_u16, varint_decode_u32, varint_decode_u64, varint_decode_usize, varint_decode_isize, varint_decode_i16, varint_decode_i32, varint_decode_i64, u8_to_u16, u8_to_u32, u8_to_u64, i16_to_u16, i32_to_u32, u16_to_u32, u16_to_u64, u32_to_u64, f32_from_bits, f64_from_bits, i8_to_u8, i16_to_i64, i32_to_i64, bytes_to_string, Encode, Decode, DecodeError, decode_integer_type }

@Test
public class ComponentTests {
    // === Config ===
    @TestCase
    public func test_is_varint() {
        @Expect(is_varint(standard))
        @Expect(!is_varint(legacy))
    }

    @TestCase
    public func test_is_little_endian() {
        @Expect(is_little_endian(standard))
        @Expect(!is_little_endian(standard.with_big_endian()))
    }

    // === read_u8 ===
    @TestCase
    public func test_read_u8() {
        let data: Array<UInt8> = [42u8, 100u8]
        match (read_u8(data, 0)) {
            case MyResult.Ok((val, pos)) =>
                @Expect(val, 42u8)
                @Expect(pos, 1)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_read_u8_oob() {
        let data: Array<UInt8> = [42u8]
        match (read_u8(data, 5)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === read_u16_le / be ===
    @TestCase
    public func test_read_u16_le() {
        let data: Array<UInt8> = [0x34u8, 0x12u8]
        match (read_u16_le(data, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 0x1234u16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_read_u16_be() {
        let data: Array<UInt8> = [0x12u8, 0x34u8]
        match (read_u16_be(data, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 0x1234u16)
            case _ => @Expect(false)
        }
    }

    // === read_u32_le / be ===
    @TestCase
    public func test_read_u32_le() {
        let data: Array<UInt8> = [0x78u8, 0x56u8, 0x34u8, 0x12u8]
        match (read_u32_le(data, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 0x12345678u32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_read_u32_be() {
        let data: Array<UInt8> = [0x12u8, 0x34u8, 0x56u8, 0x78u8]
        match (read_u32_be(data, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 0x12345678u32)
            case _ => @Expect(false)
        }
    }

    // === read_u64_le / be ===
    @TestCase
    public func test_read_u64_le() {
        let data: Array<UInt8> = [0xEFu8, 0xCDu8, 0xABu8, 0x89u8, 0x67u8, 0x45u8, 0x23u8, 0x01u8]
        match (read_u64_le(data, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 0x0123456789ABCDEFu64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_read_u64_be() {
        let data: Array<UInt8> = [0x01u8, 0x23u8, 0x45u8, 0x67u8, 0x89u8, 0xABu8, 0xCDu8, 0xEFu8]
        match (read_u64_be(data, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 0x0123456789ABCDEFu64)
            case _ => @Expect(false)
        }
    }

    // === combine helpers ===
    @TestCase
    public func test_combine_u8_u16() {
        @Expect(combine_u8_u16(0x34u8, 0x12u8), 0x1234u16)
    }

    @TestCase
    public func test_combine_u8_u32() {
        @Expect(combine_u8_u32(0x78u8, 0x56u8, 0x34u8, 0x12u8), 0x12345678u32)
    }

    @TestCase
    public func test_combine_u8_u64() {
        @Expect(combine_u8_u64(0xEFu8, 0xCDu8, 0xABu8, 0x89u8, 0x67u8, 0x45u8, 0x23u8, 0x01u8), 0x0123456789ABCDEFu64)
    }

    // === varint encode (tests that encoding produces correct bytes) ===
    @TestCase
    public func test_varint_encode_u32_u16() {
        let buf = ArrayList<UInt8>()
        varint_encode_u32(1000u32, buf)
        @Expect(buf.size, 3)
        @Expect(buf[0], 251u8)
    }

    @TestCase
    public func test_varint_encode_u32_u32() {
        let buf = ArrayList<UInt8>()
        varint_encode_u32(100000u32, buf)
        @Expect(buf.size, 5)
        @Expect(buf[0], 252u8)
    }

    @TestCase
    public func test_varint_encode_u64_small() {
        let buf = ArrayList<UInt8>()
        varint_encode_u64(42u64, buf)
        @Expect(buf.size, 1)
    }

    @TestCase
    public func test_varint_encode_u64_large() {
        let buf = ArrayList<UInt8>()
        varint_encode_u64(10000000000u64, buf)
        @Expect(buf.size, 9)
        @Expect(buf[0], 253u8)
    }

    // === zigzag encode ===

    // === encode functions (write bytes, verify output structure) ===
    @TestCase
    public func test_encode_u8_output() {
        let buf = ArrayList<UInt8>()
        encode_u8(42u8, standard, buf)
        @Expect(buf.size, 1)
        @Expect(buf[0], 42u8)
    }

    @TestCase
    public func test_encode_bool_output() {
        let buf = ArrayList<UInt8>()
        encode_bool(true, standard, buf)
        @Expect(buf[0], 1u8)
    }

    @TestCase
    public func test_encode_u16_fixed_output() {
        let buf = ArrayList<UInt8>()
        let cfg = legacy  // fixed encoding
        encode_u16(0x1234u16, cfg, buf)
        @Expect(buf.size, 2)
    }

    @TestCase
    public func test_encode_string_output() {
        let buf = ArrayList<UInt8>()
        encode_string("a", standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_char_output() {
        let buf = ArrayList<UInt8>()
        encode_char(Rune(65), standard, buf)
        @Expect(buf.size, 1)  // ASCII = 1 UTF-8 byte
        @Expect(buf[0], 65u8)
    }

    @TestCase
    public func test_encode_duration_output() {
        let buf = ArrayList<UInt8>()
        encode_duration(Duration.second, standard, buf)
        @Expect(buf.size > 0)
    }

    // === VecWriter ===
    @TestCase
    public func test_vec_writer() {
        let w = VecWriter()
        w.write_byte(1u8)
        w.write_byte(2u8)
        let collected = w.collect()
        @Expect(collected.size, 2)
        @Expect(collected[0], 1u8)
        @Expect(collected[1], 2u8)
    }

    @TestCase
    public func test_vec_writer_bytes() {
        let w = VecWriter()
        w.write_bytes([1u8, 2u8, 3u8])
        @Expect(w.collect().size, 3)
    }

    // === UInt128 ===
    @TestCase
    public func test_uint128_create() {
        let u = UInt128(0, 0)
        @Expect(u.to_u64(), 0u64)
    }

    @TestCase
    public func test_uint128_varint_encode() {
        let buf = ArrayList<UInt8>()
        varint_encode_u128(UInt128(42, 0), buf)
        @Expect(buf.size, 1)
    }

    // === encode_arraylist ===
    @TestCase
    public func test_encode_arraylist() {
        let arr = ArrayList<UInt8>()
        arr.add(1u8); arr.add(2u8)
        let buf = ArrayList<UInt8>()
        encode_arraylist(arr, standard, buf)
        @Expect(buf.size > 0)
    }

    // === encode_option ===
    @TestCase
    public func test_encode_option_some() {
        let buf = ArrayList<UInt8>()
        encode_option(Option.Some(42u8), standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_option_none() {
        let buf = ArrayList<UInt8>()
        encode_option(Option<UInt8>.None, standard, buf)
        @Expect(buf.size, 1)
        @Expect(buf[0], 0u8)
    }

    // === encode_result ===
    @TestCase
    public func test_encode_result() {
        let buf = ArrayList<UInt8>()
        encode_result(MyResult.Ok(42u8), standard, buf)
        @Expect(buf.size > 0)
    }

    // === encode_path ===
    @TestCase
    public func test_encode_path() {
        let buf = ArrayList<UInt8>()
        encode_path(Path("/tmp/test"), standard, buf)
        @Expect(buf.size > 0)
    }

    // === encode_date_time ===
    @TestCase
    public func test_encode_date_time() {
        let buf = ArrayList<UInt8>()
        encode_date_time(DateTime.now(), standard, buf)
        @Expect(buf.size > 0)
    }

    // === encode_hashmap ===
    @TestCase
    public func test_encode_hashmap() {
        let m = HashMap<String, UInt8>()
        m.add("a", 1u8); m.add("b", 2u8)
        let buf = ArrayList<UInt8>()
        encode_hashmap(m, standard, buf)
        @Expect(buf.size > 0)
    }

    // === encode_hashset ===
    @TestCase
    public func test_encode_hashset() {
        let s = HashSet<UInt8>()
        s.add(1u8); s.add(2u8)
        let buf = ArrayList<UInt8>()
        encode_hashset(s, standard, buf)
        @Expect(buf.size > 0)
    }

    // === Varint decode roundtrip ===
    @TestCase
    public func test_varint_decode_u16() {
        let buf = ArrayList<UInt8>(); varint_encode_u16(42u16, buf)
        match (varint_decode_u16(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42u16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u32() {
        let buf = ArrayList<UInt8>(); varint_encode_u32(42u32, buf)
        match (varint_decode_u32(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42u32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u64() {
        let buf = ArrayList<UInt8>(); varint_encode_u64(42u64, buf)
        match (varint_decode_u64(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_usize() {
        let buf = ArrayList<UInt8>(); varint_encode_usize(42u64, buf)
        match (varint_decode_usize(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_isize() {
        let buf = ArrayList<UInt8>(); varint_encode_isize(42i64, buf)
        match (varint_decode_isize(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42i64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_i16() {
        let buf = ArrayList<UInt8>(); varint_encode_i16(42i16, buf)
        match (varint_decode_i16(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42i16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_i32() {
        let buf = ArrayList<UInt8>(); varint_encode_i32(42i32, buf)
        match (varint_decode_i32(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42i32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_i64() {
        let buf = ArrayList<UInt8>(); varint_encode_i64(42i64, buf)
        match (varint_decode_i64(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42i64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u128() {
        let buf = ArrayList<UInt8>(); varint_encode_u128(UInt128(42, 0), buf)
        match (varint_decode_u128(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v.to_u64(), 42u64)
            case _ => @Expect(false)
        }
    }

    // === Conversion function tests ===
    @TestCase
    public func test_u8_to_u16() { @Expect(u8_to_u16(42u8), 42u16) }
    @TestCase
    public func test_u8_to_u32() { @Expect(u8_to_u32(42u8), 42u32) }
    @TestCase
    public func test_u8_to_u64() { @Expect(u8_to_u64(42u8), 42u64) }
    @TestCase
    public func test_i16_to_u16() { @Expect(i16_to_u16(42i16), 42u16) }
    @TestCase
    public func test_i32_to_u32() { @Expect(i32_to_u32(42i32), 42u32) }
    @TestCase
    public func test_u16_to_u32() { @Expect(u16_to_u32(42u16), 42u32) }
    @TestCase
    public func test_u16_to_u64() { @Expect(u16_to_u64(42u16), 42u64) }
    @TestCase
    public func test_u32_to_u64() { @Expect(u32_to_u64(42u32), 42u64) }
    @TestCase
    public func test_f32_from_bits() { @Expect(f32_from_bits(0x3F800000u32), 1.0f32) }
    @TestCase
    public func test_f64_from_bits() { @Expect(f64_from_bits(0x400921FB54442D18u64), 3.141592653589793f64) }
    @TestCase
    public func test_i8_to_u8() { @Expect(i8_to_u8(42i8), 42u8) }
    @TestCase
    public func test_i16_to_i64() { @Expect(i16_to_i64(42i16), 42i64) }
    @TestCase
    public func test_i32_to_i64() { @Expect(i32_to_i64(42i32), 42i64) }
    @TestCase
    public func test_bytes_to_string() { @Expect(bytes_to_string([104u8, 101u8, 108u8, 108u8, 111u8]), "hello") }

    // === Decode roundtrip tests ===
    @TestCase
    public func test_decode_u8() {
        let buf = ArrayList<UInt8>(); encode_u8(42u8, standard, buf)
        match (decode_u8(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u16() {
        let buf = ArrayList<UInt8>(); encode_u16(1000u16, standard, buf)
        match (decode_u16(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v, 1000u16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u32() {
        let buf = ArrayList<UInt8>(); encode_u32(100000u32, standard, buf)
        match (decode_u32(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v, 100000u32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u64() {
        let buf = ArrayList<UInt8>(); encode_u64(10000000000u64, standard, buf)
        match (decode_u64(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v, 10000000000u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_bool() {
        let buf = ArrayList<UInt8>(); encode_bool(true, standard, buf)
        match (decode_bool(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_string() {
        let buf = ArrayList<UInt8>(); encode_string("hello", standard, buf)
        match (decode_string(buf.toArray(), 0, standard)) {
            case MyResult.Ok((s, _)) => @Expect(s, "hello")
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_char() {
        let buf = ArrayList<UInt8>(); encode_char(Rune(65), standard, buf)
        match (decode_char(buf.toArray(), 0, standard)) {
            case MyResult.Ok((r, _)) => @Expect(r, Rune(65))
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_duration() {
        let buf = ArrayList<UInt8>(); encode_duration(5 * Duration.second, standard, buf)
        match (decode_duration(buf.toArray(), 0, standard)) {
            case MyResult.Ok((d, _)) => @Expect(d.toSeconds(), 5)
            case _ => @Expect(false)
        }
    }

    // === Varint large value tests ===
    @TestCase
    public func test_varint_u32_large() {
        let buf = ArrayList<UInt8>()
        varint_encode_u32(100000u32, buf)
        match (varint_decode_u32(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 100000u32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_u64_large() {
        let buf = ArrayList<UInt8>()
        varint_encode_u64(10000000000u64, buf)
        match (varint_decode_u64(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 10000000000u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_u128_large() {
        let buf = ArrayList<UInt8>()
        varint_encode_u128(UInt128(100, 1), buf)
        match (varint_decode_u128(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v.hi, 1u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u32_u16_path() {
        // 252 = U16_BYTE, then 2 bytes LE = 300
        let data: Array<UInt8> = [251u8, 44u8, 1u8]
        match (varint_decode_u32(data, 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 300u32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u64_u32_path() {
        // 252 = U32_BYTE, then 4 bytes LE = 70000
        let data: Array<UInt8> = [252u8, 0x70, 0x11, 0x01, 0x00]
        match (varint_decode_u64(data, 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 70000u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u128_u16_path() {
        // 251 = U16_BYTE, then 2 bytes LE = 300
        let data: Array<UInt8> = [251u8, 44u8, 1u8]
        match (varint_decode_u128(data, 0)) {
            case MyResult.Ok((v, _)) => @Expect(v.lo, 300u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u128_u64_path() {
        // 253 = U64_BYTE, then 8 bytes LE = 5000000000
        let data: Array<UInt8> = [253u8, 0x00, 0xF2, 0x05, 0x2A, 0x01, 0x00, 0x00, 0x00]
        match (varint_decode_u128(data, 0)) {
            case MyResult.Ok((v, _)) => @Expect(v.hi, 0u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u128_u128_path() {
        // 254 = U128_BYTE, then 16 bytes LE = large value
        let data: Array<UInt8> = [254u8, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
        match (varint_decode_u128(data, 0)) {
            case MyResult.Ok((v, _)) => @Expect(v.lo, 0xFFFFFFFFFFFFFFFFu64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_integer_type() {
        @Expect(decode_integer_type(251u8), IntegerType.U16)
        @Expect(decode_integer_type(252u8), IntegerType.U32)
        @Expect(decode_integer_type(253u8), IntegerType.U64)
        @Expect(decode_integer_type(254u8), IntegerType.Reserved)
        @Expect(decode_integer_type(255u8), IntegerType.Reserved)
    }

    @TestCase
    public func test_varint_decode_u64_u16_path() {
        // 251 = U16_BYTE, then 2 bytes LE = 300
        let data: Array<UInt8> = [251u8, 44u8, 1u8]
        match (varint_decode_u64(data, 0)) {
            case MyResult.Ok((v, _)) => @Expect(v, 300u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u128_u32_path() {
        // 252 = U32_BYTE, then 4 bytes LE = 70000
        let data: Array<UInt8> = [252u8, 0x70, 0x11, 0x01, 0x00]
        match (varint_decode_u128(data, 0)) {
            case MyResult.Ok((v, _)) => @Expect(v.lo, 70000u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u128_invalid_tag() {
        // 255 = invalid tag for u128 decode
        let data: Array<UInt8> = [255u8]
        match (varint_decode_u128(data, 0)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }
}