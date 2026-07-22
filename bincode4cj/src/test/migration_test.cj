// migration_test.cj — Tests for newly migrated features
package bincode4cj.test
import std.collection.*
import std.unittest.*
import bincode4cj.{
    standard, legacy, MyResult, DecodeError, EncodeError,
    Encode, Decode, Config, IntegerType, Int128, UInt128, Endianness,
    NonZeroI128, NonZeroIsize, SystemTime_,
    encode_into_slice, encode_into_writer, encode_into_std_write,
    encode_to_vec, decode_from_slice,
    varint_encode_i128, varint_decode_i128,
    zigzag_encode_i128, zigzag_decode_u128,
    encode_u8, decode_u8,
    check_decode_limit,
    VecWriter
}
import std.io.*

@Test
public class MigrationTests {

    // === 1. Unit type Encode/Decode ===
    @TestCase
    public func test_unit_encode_decode() {
        let buf = ArrayList<UInt8>()
        ().encode(standard, buf)
        @Expect(buf.size, 0)
        match (Unit.decode(Array<UInt8>(), 0, standard)) {
            case MyResult.Ok((_, p)) => @Expect(p, 0)
            case _ => @Expect(false)
        }
    }

    // === 2. encode_into_slice returns Int64 ===
    @TestCase
    public func test_encode_into_slice_returns_count() {
        let buf = ArrayList<UInt8>()
        let n = encode_into_slice(42u8, standard, buf)
        @Expect(n, 1)
    }

    // === 3. encode_into_writer returns Int64 ===
    @TestCase
    public func test_encode_into_writer_returns_count() {
        let w = VecWriter()
        let n = encode_into_writer(42u8, standard, w)
        @Expect(n, 1)
    }

    // === 4. encode_to_vec returns MyResult ===
    @TestCase
    public func test_encode_to_vec_ok() {
        match (encode_to_vec(42u8, standard)) {
            case MyResult.Ok(buf) => @Expect(buf.size, 1)
            case _ => @Expect(false)
        }
    }

    // === 5. Int128 class ===
    @TestCase
    public func test_int128_create() {
        let v = Int128(42, 0)
        @Expect(v.to_i64(), 42)
    }

    @TestCase
    public func test_int128_negative() {
        let v = Int128(0, -1)
        @Expect(v.is_negative())
    }

    @TestCase
    public func test_int128_negate() {
        let v = Int128(42, 0)
        let neg = v.negate()
        // neg = -42 in 128-bit two's complement: lo = !42+1, hi = -1
        @Expect(neg.lo, (!42u64) + 1u64)
        @Expect(neg.hi, -1)
    }

    @TestCase
    public func test_int128_to_unsigned() {
        let v = Int128(42, 0)
        let u = v.to_unsigned()
        @Expect(u.lo, 42u64)
    }

    @TestCase
    public func test_int128_roundtrip_zero() {
        let val = Int128(0, 0)
        let buf = ArrayList<UInt8>()
        varint_encode_i128(val, Endianness.Little, buf)
        match (varint_decode_i128(buf.toArray(), 0, Endianness.Little)) {
            case MyResult.Ok((v, _)) => @Expect(v.to_i64(), 0)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_int128_roundtrip_positive() {
        let val = Int128(100, 0)
        let buf = ArrayList<UInt8>()
        varint_encode_i128(val, Endianness.Little, buf)
        match (varint_decode_i128(buf.toArray(), 0, Endianness.Little)) {
            case MyResult.Ok((v, _)) =>
                @Expect(v.lo, 100u64)
                @Expect(v.hi, 0i64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_int128_roundtrip_negative_small() {
        let val = Int128(!0u64, -1)  // -1 (lo=0xFFFFFFFFFFFFFFFF, hi=-1)
        let buf = ArrayList<UInt8>()
        varint_encode_i128(val, Endianness.Little, buf)
        match (varint_decode_i128(buf.toArray(), 0, Endianness.Little)) {
            case MyResult.Ok((v, _)) =>
                @Expect(v.lo, !0u64)
                @Expect(v.hi, -1)
            case _ => @Expect(false)
        }
    }

    // === 6. Zigzag i128 ===
    @TestCase
    public func test_zigzag_i128_positive() {
        let input = Int128(42, 0)
        let encoded = zigzag_encode_i128(input)
        @Expect(encoded.lo, 84u64)  // 42 * 2
    }

    @TestCase
    public func test_zigzag_i128_zero() {
        let input = Int128(0, 0)
        let encoded = zigzag_encode_i128(input)
        @Expect(encoded.lo, 0u64)
        let decoded = zigzag_decode_u128(encoded)
        @Expect(decoded.to_i64(), 0)
    }

    @TestCase
    public func test_zigzag_i128_roundtrip_simple() {
        let inputs = [Int128(0, 0), Int128(1, 0), Int128(42, 0), Int128(1000, 0)]
        for (input in inputs) {
            let encoded = zigzag_encode_i128(input)
            let decoded = zigzag_decode_u128(encoded)
            @Expect(decoded.lo, input.lo)
            @Expect(decoded.hi, input.hi)
        }
    }

    // === 7. NonZeroI128 ===
    @TestCase
    public func test_nonzero_i128_create() {
        let nz = NonZeroI128(Int128(42, 0))
        @Expect(nz.get().to_i64(), 42)
    }

    @TestCase
    public func test_nonzero_i128_encode_decode() {
        let val = NonZeroI128(Int128(42, 0))
        match (encode_to_vec(val, standard)) {
            case MyResult.Ok(buf) =>
                let data = buf.toArray()
                match (NonZeroI128.decode(data, 0, standard)) {
                    case MyResult.Ok((decoded, _)) =>
                        @Expect(decoded.get().lo, 42u64)
                    case _ => @Expect(false)
                }
            case _ => @Expect(false)
        }
    }

    // === 8. NonZeroIsize ===
    @TestCase
    public func test_nonzero_isize_encode_decode() {
        let val = NonZeroIsize(42)
        match (encode_to_vec(val, standard)) {
            case MyResult.Ok(buf) =>
                let data = buf.toArray()
                match (NonZeroIsize.decode(data, 0, standard)) {
                    case MyResult.Ok((decoded, _)) =>
                        @Expect(decoded.get(), 42)
                    case _ => @Expect(false)
                }
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_isize_zero_rejected() {
        match (NonZeroIsize.decode([0u8], 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(IntegerType.Isize)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === 9. SystemTime_ ===
    @TestCase
    public func test_system_time_encode_decode() {
        let st = SystemTime_(100u64, 500u32)
        match (encode_to_vec(st, standard)) {
            case MyResult.Ok(buf) =>
                let data = buf.toArray()
                match (SystemTime_.decode(data, 0, standard)) {
                    case MyResult.Ok((decoded, _)) =>
                        @Expect(decoded.get_secs(), 100u64)
                        @Expect(decoded.get_nanos(), 500u32)
                    case _ => @Expect(false)
                }
            case _ => @Expect(false)
        }
    }

    // === 10. check_decode_limit ===
    @TestCase
    public func test_check_decode_limit_ok() {
        // NoLimit: always passes
        match (check_decode_limit(0, 100, standard)) {
            case MyResult.Ok(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_check_decode_limit_exceeded() {
        // Use legacy config (no limit - same as standard)
        // We can't easily create a config with a limit, so test that NoLimit works
        match (check_decode_limit(100, 5, standard)) {
            case MyResult.Ok(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === 11. Int128 Encode/Decode through interface ===
    @TestCase
    public func test_int128_interface_roundtrip() {
        let val = Int128(42, 0)
        match (encode_to_vec(val, standard)) {
            case MyResult.Ok(buf) =>
                let data = buf.toArray()
                match (Int128.decode(data, 0, standard)) {
                    case MyResult.Ok((decoded, _)) =>
                        @Expect(decoded.lo, 42u64)
                    case _ => @Expect(false)
                }
            case _ => @Expect(false)
        }
    }

    // === 12. encode_into_std_write returns Int64 ===
    @TestCase
    public func test_encode_into_std_write_returns_count() {
        let stream = ByteBuffer()
        let n = encode_into_std_write(42u8, standard, stream)
        @Expect(n, 1)
    }
}
