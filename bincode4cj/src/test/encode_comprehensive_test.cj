// encode_comprehensive_test.cj — Comprehensive tests for all encode functions
package bincode4cj.test
import std.collection.*
import std.time.*
import std.fs.*
import std.net.*
import std.unittest.*
import bincode4cj.{ standard, legacy, encode_bool, encode_u8, encode_u16, encode_u32, encode_u64, encode_i8, encode_i16, encode_i32, encode_i64, encode_f32, encode_f64, encode_string, encode_char, encode_duration, encode_path, encode_arraylist, encode_uint8_array, encode_array, encode_hashmap, encode_hashset, encode_option, encode_result, encode_to_vec, encode_ipv4_address, encode_ip_address, encode_ipv6_address, encode_ip_socket_address, encode_date_time, encode_tuple1, encode_tuple2, encode_tuple3, encode_tuple4, encode_bound, encode_range_custom, encode_into_slice, VecWriter, BoundEnum, MyResult, Encode }

@Test
public class EncodeComprehensiveTests {
    // === Basic types ===
    @TestCase
    public func test_encode_bool() {
        let buf = ArrayList<UInt8>(); encode_bool(true, standard, buf); @Expect(buf.size == 1)
    }

    @TestCase
    public func test_encode_u8() {
        let buf = ArrayList<UInt8>(); encode_u8(42u8, standard, buf); @Expect(buf.size == 1)
    }

    @TestCase
    public func test_encode_u16_varint() {
        let buf = ArrayList<UInt8>(); encode_u16(1000u16, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_u16_fixed() {
        let buf = ArrayList<UInt8>(); encode_u16(1000u16, legacy, buf); @Expect(buf.size == 2)
    }

    @TestCase
    public func test_encode_u32_varint() {
        let buf = ArrayList<UInt8>(); encode_u32(100000u32, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_u32_fixed() {
        let buf = ArrayList<UInt8>(); encode_u32(100000u32, legacy, buf); @Expect(buf.size == 4)
    }

    @TestCase
    public func test_encode_u64_varint() {
        let buf = ArrayList<UInt8>(); encode_u64(10000000000u64, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_u64_fixed() {
        let buf = ArrayList<UInt8>(); encode_u64(10000000000u64, legacy, buf); @Expect(buf.size == 8)
    }

    @TestCase
    public func test_encode_i8() {
        let buf = ArrayList<UInt8>(); encode_i8(42i8, standard, buf); @Expect(buf.size == 1)
    }

    @TestCase
    public func test_encode_i16_varint() {
        let buf = ArrayList<UInt8>(); encode_i16(-1000i16, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_i16_fixed() {
        let buf = ArrayList<UInt8>(); encode_i16(-1000i16, legacy, buf); @Expect(buf.size == 2)
    }

    @TestCase
    public func test_encode_i32_varint() {
        let buf = ArrayList<UInt8>(); encode_i32(-100000i32, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_i32_fixed() {
        let buf = ArrayList<UInt8>(); encode_i32(-100000i32, legacy, buf); @Expect(buf.size == 4)
    }

    @TestCase
    public func test_encode_i64_varint() {
        let buf = ArrayList<UInt8>(); encode_i64(-10000000000i64, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_i64_fixed() {
        let buf = ArrayList<UInt8>(); encode_i64(-10000000000i64, legacy, buf); @Expect(buf.size == 8)
    }

    @TestCase
    public func test_encode_f32_le() {
        let buf = ArrayList<UInt8>(); encode_f32(3.14f32, standard, buf); @Expect(buf.size == 4)
    }

    @TestCase
    public func test_encode_f32_be() {
        let buf = ArrayList<UInt8>(); encode_f32(3.14f32, standard.with_big_endian(), buf); @Expect(buf.size == 4)
    }

    @TestCase
    public func test_encode_f64_le() {
        let buf = ArrayList<UInt8>(); encode_f64(3.14159f64, standard, buf); @Expect(buf.size == 8)
    }

    @TestCase
    public func test_encode_f64_be() {
        let buf = ArrayList<UInt8>(); encode_f64(3.14159f64, standard.with_big_endian(), buf); @Expect(buf.size == 8)
    }

    @TestCase
    public func test_encode_string() {
        let buf = ArrayList<UInt8>(); encode_string("hello", standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_char_ascii() {
        let buf = ArrayList<UInt8>(); encode_char(Rune(65), standard, buf); @Expect(buf.size == 1)
    }

    @TestCase
    public func test_encode_char_unicode() {
        let buf = ArrayList<UInt8>(); encode_char(Rune(0x4E2D), standard, buf); @Expect(buf.size == 3)
    }

    @TestCase
    public func test_encode_duration() {
        let buf = ArrayList<UInt8>(); encode_duration(Duration.second, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_path() {
        let buf = ArrayList<UInt8>(); encode_path(Path("/tmp"), standard, buf); @Expect(buf.size > 0)
    }

    // === Containers ===
    @TestCase
    public func test_encode_arraylist() {
        let arr = ArrayList<UInt8>(); arr.add(1u8); arr.add(2u8)
        let buf = ArrayList<UInt8>(); encode_arraylist(arr, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_uint8_array() {
        let arr: Array<UInt8> = [1u8, 2u8, 3u8]
        let buf = ArrayList<UInt8>(); encode_uint8_array(arr, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_array() {
        let arr: Array<UInt8> = [1u8, 2u8]
        let buf = ArrayList<UInt8>(); encode_array(arr, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_hashmap() {
        let m = HashMap<String, UInt8>(); m.add("a", 1u8); m.add("b", 2u8)
        let buf = ArrayList<UInt8>(); encode_hashmap(m, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_hashset() {
        let s = HashSet<UInt8>(); s.add(1u8); s.add(2u8)
        let buf = ArrayList<UInt8>(); encode_hashset(s, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_option_some() {
        let buf = ArrayList<UInt8>(); encode_option(Option.Some(42u8), standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_option_none() {
        let buf = ArrayList<UInt8>(); encode_option(Option<UInt8>.None, standard, buf); @Expect(buf.size == 1)
    }

    @TestCase
    public func test_encode_result_ok() {
        let buf = ArrayList<UInt8>(); encode_result(MyResult.Ok(42u8), standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_result_err() {
        let buf = ArrayList<UInt8>(); encode_result(MyResult.Err(99u8), standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_to_vec() {
        match (encode_to_vec(42u8, standard)) {
            case MyResult.Ok(buf) => @Expect(buf.size > 0)
            case _ => @Expect(false)
        }
    }

    // === Tuples ===
    @TestCase
    public func test_encode_tuple1() {
        let buf = ArrayList<UInt8>(); encode_tuple1(42u8, standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_tuple2() {
        let buf = ArrayList<UInt8>(); encode_tuple2((1u8, 2u8), standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_tuple3() {
        let buf = ArrayList<UInt8>(); encode_tuple3((1u8, 2u8, 3u8), standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_tuple4() {
        let buf = ArrayList<UInt8>(); encode_tuple4((1u8, 2u8, 3u8, 4u8), standard, buf); @Expect(buf.size > 0)
    }

    // === Network addresses ===
    @TestCase
    public func test_encode_ipv4() {
        let buf = ArrayList<UInt8>(); encode_ipv4_address(IPv4Address(192, 168, 1, 1), standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_ip_address() {
        let buf = ArrayList<UInt8>(); encode_ip_address(IPAddress.parse("192.168.1.1"), standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_ipv6() {
        let buf = ArrayList<UInt8>(); encode_ipv6_address(IPv6Address(0, 0, 0, 0, 0, 0, 0, 1), standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_ip_socket() {
        let buf = ArrayList<UInt8>(); encode_ip_socket_address(IPSocketAddress.parse("192.168.1.1:8080"), standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_date_time() {
        let buf = ArrayList<UInt8>(); encode_date_time(DateTime.now(), standard, buf); @Expect(buf.size > 0)
    }

    // === Custom types ===
    @TestCase
    public func test_encode_bound_unbounded() {
        let buf = ArrayList<UInt8>(); encode_bound(BoundEnum<UInt8>.Unbounded, standard, buf); @Expect(buf.size == 1)
    }

    @TestCase
    public func test_encode_bound_included() {
        let buf = ArrayList<UInt8>(); encode_bound(BoundEnum<UInt8>.Included(42u8), standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_bound_excluded() {
        let buf = ArrayList<UInt8>(); encode_bound(BoundEnum<UInt8>.Excluded(99u8), standard, buf); @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_range_custom() {
        let buf = ArrayList<UInt8>(); encode_range_custom(1u8, 10u8, standard, buf); @Expect(buf.size > 0)
    }

    // === VecWriter ===
    @TestCase
    public func test_vec_writer() {
        let w = VecWriter(); w.write_byte(1u8); w.write_bytes([2u8, 3u8]); @Expect(w.collect().size == 3)
    }

    // === Big endian variants ===
    @TestCase
    public func test_encode_u16_big_endian() {
        let cfg = legacy.with_big_endian()
        let buf = ArrayList<UInt8>(); encode_u16(0x1234u16, cfg, buf); @Expect(buf.size == 2)
    }

    @TestCase
    public func test_encode_u32_big_endian() {
        let cfg = legacy.with_big_endian()
        let buf = ArrayList<UInt8>(); encode_u32(0x12345678u32, cfg, buf); @Expect(buf.size == 4)
    }

    @TestCase
    public func test_encode_u64_big_endian() {
        let cfg = legacy.with_big_endian()
        let buf = ArrayList<UInt8>(); encode_u64(0x123456789ABCDEF0u64, cfg, buf); @Expect(buf.size == 8)
    }
}