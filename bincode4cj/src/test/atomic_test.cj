// atomic_test.cj — Tests for atomic type encode functions
package bincode4cj.test
import std.collection.*
import std.sync.*
import std.unittest.*
import bincode4cj.{ standard, encode_atomic_bool, encode_atomic_uint8, encode_atomic_uint16, encode_atomic_uint32, encode_atomic_uint64, encode_atomic_int8, encode_atomic_int16, encode_atomic_int32, encode_atomic_int64, encode_atomic_usize, encode_atomic_isize, decode_atomic_bool, decode_atomic_uint8, decode_atomic_uint16, decode_atomic_uint32, decode_atomic_uint64, decode_atomic_int8, decode_atomic_int16, decode_atomic_int32, decode_atomic_int64, decode_atomic_usize, decode_atomic_isize, MyResult }

@Test
public class AtomicTests {
    @TestCase
    public func test_encode_atomic_bool() {
        let buf = ArrayList<UInt8>()
        encode_atomic_bool(AtomicBool(true), standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_atomic_uint8() {
        let buf = ArrayList<UInt8>()
        encode_atomic_uint8(AtomicUInt8(42u8), standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_atomic_uint16() {
        let buf = ArrayList<UInt8>()
        encode_atomic_uint16(AtomicUInt16(1000u16), standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_atomic_uint32() {
        let buf = ArrayList<UInt8>()
        encode_atomic_uint32(AtomicUInt32(100000u32), standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_atomic_uint64() {
        let buf = ArrayList<UInt8>()
        encode_atomic_uint64(AtomicUInt64(10000000000u64), standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_atomic_int8() {
        let buf = ArrayList<UInt8>()
        encode_atomic_int8(AtomicInt8(42i8), standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_atomic_int16() {
        let buf = ArrayList<UInt8>()
        encode_atomic_int16(AtomicInt16(-1000i16), standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_atomic_int32() {
        let buf = ArrayList<UInt8>()
        encode_atomic_int32(AtomicInt32(-100000i32), standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_atomic_int64() {
        let buf = ArrayList<UInt8>()
        encode_atomic_int64(AtomicInt64(-10000000000i64), standard, buf)
        @Expect(buf.size > 0)
    }

    // === Atomic encode/decode roundtrip ===
    @TestCase
    public func test_encode_decode_atomic_usize() {
        let buf = ArrayList<UInt8>()
        encode_atomic_usize(AtomicUInt64(42u64), standard, buf)
        match (decode_atomic_usize(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.load(), 42u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_uint8() {
        let buf = ArrayList<UInt8>(); encode_atomic_uint8(AtomicUInt8(42u8), standard, buf)
        match (decode_atomic_uint8(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.load(), 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_uint16() {
        let buf = ArrayList<UInt8>(); encode_atomic_uint16(AtomicUInt16(1000u16), standard, buf)
        match (decode_atomic_uint16(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.load(), 1000u16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_uint32() {
        let buf = ArrayList<UInt8>(); encode_atomic_uint32(AtomicUInt32(100000u32), standard, buf)
        match (decode_atomic_uint32(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.load(), 100000u32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_uint64() {
        let buf = ArrayList<UInt8>(); encode_atomic_uint64(AtomicUInt64(10000000000u64), standard, buf)
        match (decode_atomic_uint64(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.load(), 10000000000u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_int8() {
        let buf = ArrayList<UInt8>(); encode_atomic_int8(AtomicInt8(42i8), standard, buf)
        match (decode_atomic_int8(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v.load(), 42i8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_int16() {
        let buf = ArrayList<UInt8>(); encode_atomic_int16(AtomicInt16(99i16), standard, buf)
        match (decode_atomic_int16(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.load(), 99i16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_int32() {
        let buf = ArrayList<UInt8>(); encode_atomic_int32(AtomicInt32(99i32), standard, buf)
        match (decode_atomic_int32(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.load(), 99i32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_int64() {
        let buf = ArrayList<UInt8>(); encode_atomic_int64(AtomicInt64(99i64), standard, buf)
        match (decode_atomic_int64(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.load(), 99i64)
            case _ => @Expect(false)
        }
    }

    // === AtomicIsize encode/decode ===
    @TestCase
    public func test_encode_atomic_isize() {
        let buf = ArrayList<UInt8>()
        encode_atomic_isize(AtomicInt64(-42i64), standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_decode_atomic_isize() {
        let buf = ArrayList<UInt8>(); encode_atomic_isize(AtomicInt64(-42i64), standard, buf)
        match (decode_atomic_isize(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.load(), -42i64)
            case _ => @Expect(false)
        }
    }

    // === AtomicBool decode ===
    @TestCase
    public func test_decode_atomic_bool() {
        let buf = ArrayList<UInt8>(); encode_atomic_bool(AtomicBool(true), standard, buf)
        match (decode_atomic_bool(buf.toArray(), 0)) {
            case MyResult.Ok((v, _)) => @Expect(v.load(), true)
            case _ => @Expect(false)
        }
    }

    // === Error path tests ===
    @TestCase
    public func test_decode_atomic_uint8_error() {
        let data: Array<UInt8> = []
        match (decode_atomic_uint8(data, 0, standard)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_uint16_error() {
        let data: Array<UInt8> = []
        match (decode_atomic_uint16(data, 0, standard)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_uint32_error() {
        let data: Array<UInt8> = []
        match (decode_atomic_uint32(data, 0, standard)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_uint64_error() {
        let data: Array<UInt8> = []
        match (decode_atomic_uint64(data, 0, standard)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_int8_error() {
        let data: Array<UInt8> = []
        match (decode_atomic_int8(data, 0)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_int16_error() {
        let data: Array<UInt8> = []
        match (decode_atomic_int16(data, 0, standard)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_int32_error() {
        let data: Array<UInt8> = []
        match (decode_atomic_int32(data, 0, standard)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_int64_error() {
        let data: Array<UInt8> = []
        match (decode_atomic_int64(data, 0, standard)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_usize_error() {
        let data: Array<UInt8> = []
        match (decode_atomic_usize(data, 0, standard)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_atomic_isize_error() {
        let data: Array<UInt8> = []
        match (decode_atomic_isize(data, 0, standard)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }
}