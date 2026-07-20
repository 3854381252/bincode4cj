// conv_test.cj — Tests for conv.cj functions that work with Cangjie 1.0.5
package bincode4cj.test
import std.collection.*
import std.unittest.*
import bincode4cj.{ combine_u8_u16, combine_u8_u32, combine_u8_u64, zigzag_decode_helper_u16, zigzag_decode_helper_u32, zigzag_decode_helper_u64, encode_kv_pair, encode_some_value, arraylist_add_and_return, hashset_add_and_return, standard, u32_to_u8, u64_to_u8, u16_to_u8, u64_to_u32, u64_to_u16, u32_to_u16, i64_to_u64, i64_to_u32, u8_to_i8, u16_to_i16, u32_to_i32, u64_to_i64, f32_from_bits, f64_from_bits, i8_to_u8, i16_to_i64, i32_to_i64, bytes_to_string, u8_to_u16, u8_to_u32, u8_to_u64, list_add_one, map_put_one, i16_to_u16, i32_to_u32, u16_to_u32, u16_to_u64, u32_to_u64, hashmap_put_and_return, decode_hashmap_next, decode_hashmap_put_val, MyResult, DecodeError }

@Test
public class ConvComprehensiveTests {
    // === combine helpers (with @OverflowWrapping) ===
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

    // === zigzag_decode helpers ===
    @TestCase
    public func test_zigzag_decode_u16() { @Expect(zigzag_decode_helper_u16(0u16), 0i16) }

    @TestCase
    public func test_zigzag_decode_u32() { @Expect(zigzag_decode_helper_u32(0u32), 0i32) }

    @TestCase
    public func test_zigzag_decode_u64() { @Expect(zigzag_decode_helper_u64(0u64), 0i64) }

    // === Helper functions ===
    @TestCase
    public func test_encode_kv_pair() {
        let buf = ArrayList<UInt8>()
        encode_kv_pair(1u8, 2u8, standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_some_value() {
        let buf = ArrayList<UInt8>()
        encode_some_value(42u8, standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_arraylist_add_and_return() {
        let list = ArrayList<UInt8>()
        let np = arraylist_add_and_return(list, 42u8, 5)
        @Expect(list.size, 1)
        @Expect(np, 5)
    }

    @TestCase
    public func test_hashset_add_and_return() {
        let set = HashSet<UInt8>()
        let np = hashset_add_and_return(set, 42u8, 5)
        @Expect(set.size, 1)
        @Expect(np, 5)
    }

    // === Type conversion functions ===
    @TestCase
    public func test_u32_to_u8() { @Expect(u32_to_u8(255u32), 255u8) }
    @TestCase
    public func test_u64_to_u8() { @Expect(u64_to_u8(255u64), 255u8) }
    @TestCase
    public func test_u16_to_u8() { @Expect(u16_to_u8(255u16), 255u8) }
    @TestCase
    public func test_u64_to_u32() { @Expect(u64_to_u32(100u64), 100u32) }
    @TestCase
    public func test_u64_to_u16() { @Expect(u64_to_u16(100u64), 100u16) }
    @TestCase
    public func test_u32_to_u16() { @Expect(u32_to_u16(100u32), 100u16) }
    @TestCase
    public func test_i64_to_u64() { @Expect(i64_to_u64(42i64), 42u64) }
    @TestCase
    public func test_i64_to_u32() { @Expect(i64_to_u32(42i64), 42u32) }
    @TestCase
    public func test_u8_to_i8() { @Expect(u8_to_i8(42u8), 42i8) }
    @TestCase
    public func test_u16_to_i16() { @Expect(u16_to_i16(42u16), 42i16) }
    @TestCase
    public func test_u32_to_i32() { @Expect(u32_to_i32(42u32), 42i32) }
    @TestCase
    public func test_u64_to_i64() { @Expect(u64_to_i64(42u64), 42i64) }
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
    public func test_u8_to_u16() { @Expect(u8_to_u16(42u8), 42u16) }
    @TestCase
    public func test_u8_to_u32() { @Expect(u8_to_u32(42u8), 42u32) }
    @TestCase
    public func test_u8_to_u64() { @Expect(u8_to_u64(42u8), 42u64) }
    @TestCase
    public func test_bytes_to_string() { @Expect(bytes_to_string([104u8, 101u8, 108u8, 108u8, 111u8]), "hello") }

    // === Helper functions ===
    @TestCase
    public func test_list_add_one() {
        let list = ArrayList<UInt8>()
        let (result, cp, i) = list_add_one(list, 42u8, 5, 0)
        @Expect(result.size, 1)
        @Expect(cp, 5)
        @Expect(i, 1)
    }

    @TestCase
    public func test_map_put_one() {
        let m = HashMap<String, UInt8>()
        let (result, cp, i) = map_put_one(m, "a", 1u8, 5, 0)
        @Expect(result.size, 1)
    }

    // === Additional conversion functions ===
    @TestCase
    public func test_i16_to_u16() { let v = i16_to_u16(42i16); @Expect(v, 42u16) }
    @TestCase
    public func test_i32_to_u32() { let v = i32_to_u32(42i32); @Expect(v, 42u32) }
    @TestCase
    public func test_u16_to_u32() { let v = u16_to_u32(42u16); @Expect(v, 42u32) }
    @TestCase
    public func test_u16_to_u64() { let v = u16_to_u64(42u16); @Expect(v, 42u64) }
    @TestCase
    public func test_u32_to_u64() { let v = u32_to_u64(42u32); @Expect(v, 42u64) }
    @TestCase
    public func test_zigzag_decode_u16_nonzero() { @Expect(zigzag_decode_helper_u16(2u16), 1i16) }
    @TestCase
    public func test_zigzag_decode_u32_nonzero() { @Expect(zigzag_decode_helper_u32(2u32), 1i32) }
    @TestCase
    public func test_zigzag_decode_u64_nonzero() { @Expect(zigzag_decode_helper_u64(2u64), 1i64) }

    // === HashMap decode helpers ===
    @TestCase
    public func test_hashmap_put_and_return() {
        let m = HashMap<String, UInt8>()
        let r = hashmap_put_and_return(m, "key", 42u8, 5)
        match (r) {
            case MyResult.Ok(np) => @Expect(np, 5)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_hashmap_next_err() {
        let data: Array<UInt8> = []
        let m = HashMap<UInt8, UInt8>()
        let r = decode_hashmap_next(data, 0, standard, m)
        match (r) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_hashmap_put_val_err() {
        let data: Array<UInt8> = []
        let m = HashMap<UInt8, UInt8>()
        let r = decode_hashmap_put_val(data, 0, standard, 1u8, m)
        match (r) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_hashmap_next_ok() {
        // Key = 1u8 (1 byte), then value = 42u8 (1 byte)
        let data: Array<UInt8> = [1u8, 42u8]
        let m = HashMap<UInt8, UInt8>()
        let r = decode_hashmap_next(data, 0, standard, m)
        match (r) {
            case MyResult.Ok(np) => @Expect(np, 2)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_hashmap_put_val_ok() {
        // Key = 1u8 already decoded, then value = 42u8 (1 byte)
        let data: Array<UInt8> = [42u8]
        let m = HashMap<UInt8, UInt8>()
        let r = decode_hashmap_put_val(data, 0, standard, 1u8, m)
        match (r) {
            case MyResult.Ok(np) => @Expect(np, 1)
            case _ => @Expect(false)
        }
    }
}