// error_test.cj — Tests for error types
package bincode4cj.test
import bincode4cj.{ IntegerType, EncodeError, DecodeError, AllowedEnumVariants, integer_type_into_signed, MyResult }
import std.unittest.*

@Test
public class ErrorTests {
    @TestCase
    public func test_integer_type_into_signed() {
        @Expect(integer_type_into_signed(IntegerType.U8), IntegerType.I8)
        @Expect(integer_type_into_signed(IntegerType.U16), IntegerType.I16)
        @Expect(integer_type_into_signed(IntegerType.U32), IntegerType.I32)
        @Expect(integer_type_into_signed(IntegerType.U64), IntegerType.I64)
        @Expect(integer_type_into_signed(IntegerType.U128), IntegerType.I128)
        @Expect(integer_type_into_signed(IntegerType.Usize), IntegerType.Isize)
        @Expect(integer_type_into_signed(IntegerType.I8), IntegerType.I8)
        @Expect(integer_type_into_signed(IntegerType.Reserved), IntegerType.Reserved)
    }

    @TestCase
    public func test_invalid_integer_type() {
        let err = DecodeError.InvalidIntegerType(IntegerType.U32, IntegerType.U64)
        match (err) {
            case DecodeError.InvalidIntegerType(expected, found) =>
                @Expect(integer_type_into_signed(expected), IntegerType.I32)
                @Expect(integer_type_into_signed(found), IntegerType.I64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_limit_exceeded() {
        let err = DecodeError.LimitExceeded
        match (err) {
            case DecodeError.LimitExceeded => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_unexpected_end() {
        let err = DecodeError.UnexpectedEnd(5)
        match (err) {
            case DecodeError.UnexpectedEnd(n) => @Expect(n, 5)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_type_is_zero() {
        let err = DecodeError.NonZeroTypeIsZero(IntegerType.U8)
        match (err) {
            case DecodeError.NonZeroTypeIsZero(t) => @Expect(t, IntegerType.U8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_invalid_boolean_value() {
        let err = DecodeError.InvalidBooleanValue(99u8)
        match (err) {
            case DecodeError.InvalidBooleanValue(v) => @Expect(v, 99u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_cstring_nul_error() {
        let err = DecodeError.CStringNulError(3)
        match (err) {
            case DecodeError.CStringNulError(pos) => @Expect(pos, 3)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_other_error() {
        let err = DecodeError.Other("test error")
        match (err) {
            case DecodeError.Other(msg) => @Expect(msg, "test error")
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_encode_error() {
        let err = EncodeError.UnexpectedEnd
        match (err) {
            case EncodeError.UnexpectedEnd => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_encode_error_other() {
        let err = EncodeError.Other("encode error")
        match (err) {
            case EncodeError.Other(msg) => @Expect(msg, "encode error")
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_allowed_enum_variants_range() {
        let v = AllowedEnumVariants.Range(0u32, 10u32)
        match (v) {
            case AllowedEnumVariants.Range(min, max) => @Expect(min, 0u32); @Expect(max, 10u32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_allowed_enum_variants_allowed() {
        let v = AllowedEnumVariants.Allowed([1u32, 2u32, 3u32])
        match (v) {
            case AllowedEnumVariants.Allowed(arr) => @Expect(arr.size, 3)
            case _ => @Expect(false)
        }
    }

    // === Additional EncodeError variants ===
    @TestCase
    public func test_encode_error_refcell() {
        let err = EncodeError.RefCellAlreadyBorrowed("RefCell", "TestType")
        match (err) {
            case EncodeError.RefCellAlreadyBorrowed(t, n) => @Expect(n, "TestType")
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_encode_error_invalid_path() {
        let err = EncodeError.InvalidPathCharacters
        match (err) {
            case EncodeError.InvalidPathCharacters => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_encode_error_io() {
        let err = EncodeError.Io("IO error", 42)
        match (err) {
            case EncodeError.Io(msg, idx) => @Expect(idx, 42)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_encode_error_lock_failed() {
        let err = EncodeError.LockFailed("Mutex")
        match (err) {
            case EncodeError.LockFailed(t) => @Expect(t, "Mutex")
            case _ => @Expect(false)
        }
    }

    // === Additional DecodeError variants ===
    @TestCase
    public func test_decode_error_utf8() {
        let err = DecodeError.Utf8("invalid utf8")
        match (err) {
            case DecodeError.Utf8(s) => @Expect(s, "invalid utf8")
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_error_invalid_char() {
        let err = DecodeError.InvalidCharEncoding(0xFFu8, 0xFEu8, 0x00u8, 0x00u8)
        match (err) {
            case DecodeError.InvalidCharEncoding(a, b, c, d) => @Expect(a, 0xFFu8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_error_array_mismatch() {
        let err = DecodeError.ArrayLengthMismatch(5, 3)
        match (err) {
            case DecodeError.ArrayLengthMismatch(req, found) => @Expect(req, 5); @Expect(found, 3)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_error_outside_usize() {
        let err = DecodeError.OutsideUsizeRange(999u64)
        match (err) {
            case DecodeError.OutsideUsizeRange(v) => @Expect(v, 999u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_error_empty_enum() {
        let err = DecodeError.EmptyEnum("TestEnum")
        match (err) {
            case DecodeError.EmptyEnum(name) => @Expect(name, "TestEnum")
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_error_invalid_duration() {
        let err = DecodeError.InvalidDuration(100u64, 999u32)
        match (err) {
            case DecodeError.InvalidDuration(s, n) => @Expect(s, 100u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_error_invalid_system_time() {
        let err = DecodeError.InvalidSystemTime(5 * Duration.second)
        match (err) {
            case DecodeError.InvalidSystemTime(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_error_io() {
        let err = DecodeError.Io("IO error", 99)
        match (err) {
            case DecodeError.Io(msg, idx) => @Expect(idx, 99)
            case _ => @Expect(false)
        }
    }

    // === MyResult ===
    @TestCase
    public func test_my_result_ok() {
        let r = MyResult<Int64, String>.Ok(42)
        match (r) {
            case MyResult.Ok(v) => @Expect(v, 42)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_my_result_err() {
        let r = MyResult<Int64, String>.Err("error")
        match (r) {
            case MyResult.Err(e) => @Expect(e, "error")
            case _ => @Expect(false)
        }
    }
}