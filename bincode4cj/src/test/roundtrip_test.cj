// roundtrip_test.cj — Comprehensive roundtrip tests for all basic types
package bincode4cj.test
import std.collection.*
import std.time.*
import std.unittest.*
import bincode4cj.{ standard, encode_u8, encode_u16, encode_u32, encode_u64, encode_i8, encode_i16, encode_i32, encode_i64, encode_f32, encode_f64, encode_bool, encode_string, encode_char, encode_duration, decode_u8, decode_u16, decode_u32, decode_u64, decode_i8, decode_i16, decode_i32, decode_i64, decode_f32, decode_f64, decode_bool, decode_string, decode_char, decode_duration, MyResult }

@Test
public class RoundtripTests {
    @TestCase
    public func test_u8_roundtrip() {
        let buf = ArrayList<UInt8>(); encode_u8(42u8, standard, buf)
        match (decode_u8(buf.toArray(), 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_u16_roundtrip() {
        let buf = ArrayList<UInt8>(); encode_u16(1000u16, standard, buf)
        match (decode_u16(buf.toArray(), 0, standard)) {
            case MyResult.Ok((val, _)) => @Expect(val, 1000u16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_u32_roundtrip() {
        let buf = ArrayList<UInt8>(); encode_u32(100000u32, standard, buf)
        match (decode_u32(buf.toArray(), 0, standard)) {
            case MyResult.Ok((val, _)) => @Expect(val, 100000u32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_u64_roundtrip() {
        let buf = ArrayList<UInt8>(); encode_u64(10000000000u64, standard, buf)
        match (decode_u64(buf.toArray(), 0, standard)) {
            case MyResult.Ok((val, _)) => @Expect(val, 10000000000u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_bool_roundtrip() {
        let buf = ArrayList<UInt8>(); encode_bool(true, standard, buf)
        match (decode_bool(buf.toArray(), 0)) {
            case MyResult.Ok((val, _)) => @Expect(val)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_char_roundtrip() {
        let buf = ArrayList<UInt8>(); encode_char(Rune(65), standard, buf)
        match (decode_char(buf.toArray(), 0, standard)) {
            case MyResult.Ok((r, _)) => @Expect(r, Rune(65))
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_string_roundtrip() {
        let buf = ArrayList<UInt8>(); encode_string("hello", standard, buf)
        match (decode_string(buf.toArray(), 0, standard)) {
            case MyResult.Ok((s, _)) => @Expect(s, "hello")
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_duration_roundtrip() {
        let d = 5 * Duration.second
        let buf = ArrayList<UInt8>(); encode_duration(d, standard, buf)
        match (decode_duration(buf.toArray(), 0, standard)) {
            case MyResult.Ok((result, _)) => @Expect(result.toSeconds(), 5)
            case _ => @Expect(false)
        }
    }
}