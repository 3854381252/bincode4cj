// coverage_test.cj - Coverage tests for error.cj toString() and decode.cj error paths
package bincode4cj.test
import std.collection.*
import std.time.*
import std.unittest.*
import bincode4cj.{ standard, legacy, MyResult, DecodeError, EncodeError, IntegerType, AllowedEnumVariants,
    decode_u8, decode_u16, decode_u32, decode_u64, decode_bool, decode_string, decode_char,
    decode_option, decode_result, decode_bound, decode_arraylist, decode_hashmap,
    varint_decode_u16, varint_decode_u32, varint_decode_u64,
    NonZeroU8, NonZeroU16, NonZeroU32, NonZeroU64,
    Encode, Decode, Endianness, Endianness, BoundEnum, Config }

@Test
public class ErrorToStringTests {
    // === EncodeError toString ===
    @TestCase
    public func test_encode_error_toString_unexpected_end() {
        let err = EncodeError.UnexpectedEnd
        @Expect(err.toString(), "UnexpectedEnd")
    }

    @TestCase
    public func test_encode_error_toString_refcell() {
        let err = EncodeError.RefCellAlreadyBorrowed("RefCell", "TestType")
        @Expect(err.toString(), "RefCellAlreadyBorrowed: TestType")
    }

    @TestCase
    public func test_encode_error_toString_other() {
        let err = EncodeError.Other("custom error")
        @Expect(err.toString(), "custom error")
    }

    @TestCase
    public func test_encode_error_toString_invalid_path() {
        let err = EncodeError.InvalidPathCharacters
        @Expect(err.toString(), "InvalidPathCharacters")
    }

    @TestCase
    public func test_encode_error_toString_io() {
        let err = EncodeError.Io("io error", 42)
        @Expect(err.toString(), "Io: io error at index 42")
    }

    @TestCase
    public func test_encode_error_toString_lock_failed() {
        let err = EncodeError.LockFailed("Mutex")
        @Expect(err.toString(), "LockFailed: Mutex")
    }

    @TestCase
    public func test_encode_error_toString_invalid_system_time() {
        let err = EncodeError.InvalidSystemTime("s1", "s2")
        @Expect(err.toString(), "InvalidSystemTime: s1, s2")
    }

    // === DecodeError toString ===
    @TestCase
    public func test_decode_error_toString_unexpected_end() {
        let err = DecodeError.UnexpectedEnd(5)
        @Expect(err.toString(), "UnexpectedEnd: expected 5 more bytes")
    }

    @TestCase
    public func test_decode_error_toString_limit_exceeded() {
        let err = DecodeError.LimitExceeded
        @Expect(err.toString(), "LimitExceeded")
    }

    @TestCase
    public func test_decode_error_toString_invalid_integer_type() {
        let err = DecodeError.InvalidIntegerType(IntegerType.U32, IntegerType.U64)
        @Expect(err.toString(), "InvalidIntegerType: expected U32, found U64")
    }

    @TestCase
    public func test_decode_error_toString_nonzero_type_is_zero() {
        let err = DecodeError.NonZeroTypeIsZero(IntegerType.U8)
        @Expect(err.toString(), "NonZeroTypeIsZero: U8")
    }

    @TestCase
    public func test_decode_error_toString_unexpected_variant_range() {
        let err = DecodeError.UnexpectedVariant("TestEnum", AllowedEnumVariants.Range(0u32, 10u32), 15u32)
        let s = err.toString()
        @Expect(s.contains("UnexpectedVariant"), true)
        @Expect(s.contains("TestEnum"), true)
        @Expect(s.contains("15"), true)
    }

    @TestCase
    public func test_decode_error_toString_unexpected_variant_allowed() {
        let err = DecodeError.UnexpectedVariant("MyEnum", AllowedEnumVariants.Allowed([1u32, 2u32, 3u32]), 9u32)
        let s = err.toString()
        @Expect(s.contains("UnexpectedVariant"), true)
        @Expect(s.contains("MyEnum"), true)
        @Expect(s.contains("9"), true)
    }

    @TestCase
    public func test_decode_error_toString_utf8() {
        let err = DecodeError.Utf8("invalid utf8")
        @Expect(err.toString(), "Utf8: invalid utf8")
    }

    @TestCase
    public func test_decode_error_toString_invalid_char_encoding() {
        let err = DecodeError.InvalidCharEncoding(0xFFu8, 0xFEu8, 0x00u8, 0x00u8)
        let s = err.toString()
        @Expect(s.contains("InvalidCharEncoding"), true)
        @Expect(s.contains("255"), true)
        @Expect(s.contains("254"), true)
    }

    @TestCase
    public func test_decode_error_toString_invalid_boolean_value() {
        let err = DecodeError.InvalidBooleanValue(2u8)
        @Expect(err.toString(), "InvalidBooleanValue: 2")
    }

    @TestCase
    public func test_decode_error_toString_array_length_mismatch() {
        let err = DecodeError.ArrayLengthMismatch(5, 3)
        @Expect(err.toString(), "ArrayLengthMismatch: expected 5, found 3")
    }

    @TestCase
    public func test_decode_error_toString_outside_usize_range() {
        let err = DecodeError.OutsideUsizeRange(999u64)
        @Expect(err.toString(), "OutsideUsizeRange: 999")
    }

    @TestCase
    public func test_decode_error_toString_empty_enum() {
        let err = DecodeError.EmptyEnum("TestEnum")
        @Expect(err.toString(), "EmptyEnum: TestEnum")
    }

    @TestCase
    public func test_decode_error_toString_invalid_duration() {
        let err = DecodeError.InvalidDuration(100u64, 999u32)
        @Expect(err.toString(), "InvalidDuration: 100s, 999ns")
    }

    @TestCase
    public func test_decode_error_toString_invalid_system_time() {
        let err = DecodeError.InvalidSystemTime(5 * Duration.second)
        let s = err.toString()
        @Expect(s.contains("InvalidSystemTime"), true)
    }

    @TestCase
    public func test_decode_error_toString_cstring_nul_error() {
        let err = DecodeError.CStringNulError(3)
        @Expect(err.toString(), "CStringNulError: nul byte at position 3")
    }

    @TestCase
    public func test_decode_error_toString_io() {
        let err = DecodeError.Io("IO error", 99)
        @Expect(err.toString(), "Io: IO error at index 99")
    }

    @TestCase
    public func test_decode_error_toString_other() {
        let err = DecodeError.Other("test error")
        @Expect(err.toString(), "test error")
    }

    // === IntegerType toString ===
    @TestCase
    public func test_integer_type_toString_all() {
        @Expect(IntegerType.U8.toString(), "U8")
        @Expect(IntegerType.U16.toString(), "U16")
        @Expect(IntegerType.U32.toString(), "U32")
        @Expect(IntegerType.U64.toString(), "U64")
        @Expect(IntegerType.U128.toString(), "U128")
        @Expect(IntegerType.Usize.toString(), "Usize")
        @Expect(IntegerType.I8.toString(), "I8")
        @Expect(IntegerType.I16.toString(), "I16")
        @Expect(IntegerType.I32.toString(), "I32")
        @Expect(IntegerType.I64.toString(), "I64")
        @Expect(IntegerType.I128.toString(), "I128")
        @Expect(IntegerType.Isize.toString(), "Isize")
        @Expect(IntegerType.Reserved.toString(), "Reserved")
    }

    // === AllowedEnumVariants toString ===
    @TestCase
    public func test_allowed_enum_variants_toString_range() {
        let v = AllowedEnumVariants.Range(0u32, 10u32)
        @Expect(v.toString(), "Range(0, 10)")
    }

    @TestCase
    public func test_allowed_enum_variants_toString_allowed() {
        let v = AllowedEnumVariants.Allowed([1u32, 2u32, 3u32])
        let s = v.toString()
        @Expect(s.contains("Allowed"), true)
        @Expect(s.contains("1"), true)
        @Expect(s.contains("3"), true)
    }
}

@Test
public class DecodeErrorPathTests {
    // === 截断数据：decode_u16 在数据不足时返回 UnexpectedEnd ===
    @TestCase
    public func test_decode_u16_truncated_legacy() {
        let data: Array<UInt8> = [0xFFu8]
        match (decode_u16(data, 0, legacy)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u32_truncated_legacy() {
        let data: Array<UInt8> = [0xFFu8, 0xFFu8]
        match (decode_u32(data, 0, legacy)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u64_truncated_legacy() {
        let data: Array<UInt8> = [0xFFu8, 0xFFu8, 0xFFu8]
        match (decode_u64(data, 0, legacy)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u8_empty_data() {
        let data: Array<UInt8> = []
        match (decode_u8(data, 0)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === 无效 bool：decode_bool 在 val 非 0/1 时返回 InvalidBooleanValue ===
    @TestCase
    public func test_decode_bool_invalid_value_2() {
        let data: Array<UInt8> = [2u8]
        match (decode_bool(data, 0)) {
            case MyResult.Err(DecodeError.InvalidBooleanValue(v)) => @Expect(v, 2u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_bool_invalid_value_255() {
        let data: Array<UInt8> = [255u8]
        match (decode_bool(data, 0)) {
            case MyResult.Err(DecodeError.InvalidBooleanValue(v)) => @Expect(v, 255u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_bool_valid_false() {
        let data: Array<UInt8> = [0u8]
        match (decode_bool(data, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, false)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_bool_valid_true() {
        let data: Array<UInt8> = [1u8]
        match (decode_bool(data, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, true)
            case _ => @Expect(false)
        }
    }

    // === 无效 varint 标记：varint_decode_u16 在 first=255 时返回 InvalidIntegerType ===
    @TestCase
    public func test_varint_decode_u16_invalid_tag_255() {
        let data: Array<UInt8> = [255u8]
        match (varint_decode_u16(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.InvalidIntegerType(expected, found)) =>
                @Expect(expected, IntegerType.U16)
                @Expect(found, IntegerType.Reserved)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u32_invalid_tag_255() {
        let data: Array<UInt8> = [255u8]
        match (varint_decode_u32(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.InvalidIntegerType(expected, _)) =>
                @Expect(expected, IntegerType.U32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u64_invalid_tag_255() {
        let data: Array<UInt8> = [255u8]
        match (varint_decode_u64(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.InvalidIntegerType(expected, _)) =>
                @Expect(expected, IntegerType.U64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u16_truncated() {
        let data: Array<UInt8> = [251u8]
        match (varint_decode_u16(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === 无效 option 标记：decode_option 在 tag 非 0/1 时返回 Other ===
    @TestCase
    public func test_decode_option_invalid_tag() {
        let data: Array<UInt8> = [2u8]
        match (decode_option<UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.Other(msg)) =>
                @Expect(msg, "Invalid option tag")
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_option_none() {
        let data: Array<UInt8> = [0u8]
        match (decode_option<UInt8>(data, 0, standard)) {
            case MyResult.Ok((opt, _)) =>
                match (opt) {
                    case Option.None => @Expect(true)
                    case _ => @Expect(false)
                }
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_option_some() {
        let data: Array<UInt8> = [1u8, 42u8]
        match (decode_option<UInt8>(data, 0, standard)) {
            case MyResult.Ok((opt, _)) =>
                match (opt) {
                    case Option.Some(v) => @Expect(v, 42u8)
                    case _ => @Expect(false)
                }
            case _ => @Expect(false)
        }
    }

    // === 无效 result 标记：decode_result 在 tag 非 0/1 时返回 Other ===
    @TestCase
    public func test_decode_result_invalid_tag() {
        let data: Array<UInt8> = [2u8]
        match (decode_result<UInt8, UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.Other(msg)) =>
                @Expect(msg, "Invalid result tag")
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_result_ok() {
        let data: Array<UInt8> = [0u8, 42u8]
        match (decode_result<UInt8, UInt8>(data, 0, standard)) {
            case MyResult.Ok((MyResult.Ok(v), _)) => @Expect(v, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_result_err() {
        let data: Array<UInt8> = [1u8, 99u8]
        match (decode_result<UInt8, UInt8>(data, 0, standard)) {
            case MyResult.Ok((MyResult.Err(e), _)) => @Expect(e, 99u8)
            case _ => @Expect(false)
        }
    }

    // === 无效 bound 标记：decode_bound 在 tag 非 0/1/2 时返回 Other ===
    @TestCase
    public func test_decode_bound_invalid_tag() {
        let data: Array<UInt8> = [3u8]
        match (decode_bound<UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.Other(msg)) =>
                @Expect(msg, "Invalid bound tag")
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_bound_unbounded() {
        let data: Array<UInt8> = [0u8]
        match (decode_bound<UInt8>(data, 0, standard)) {
            case MyResult.Ok((BoundEnum.Unbounded, _)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_bound_included() {
        let data: Array<UInt8> = [1u8, 42u8]
        match (decode_bound<UInt8>(data, 0, standard)) {
            case MyResult.Ok((BoundEnum.Included(v), _)) => @Expect(v, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_bound_excluded() {
        let data: Array<UInt8> = [2u8, 99u8]
        match (decode_bound<UInt8>(data, 0, standard)) {
            case MyResult.Ok((BoundEnum.Excluded(v), _)) => @Expect(v, 99u8)
            case _ => @Expect(false)
        }
    }

    // === NonZero 零值：decode NonZeroU8 在值为 0 时返回 NonZeroTypeIsZero ===
    @TestCase
    public func test_decode_nonzero_u8_zero() {
        let data: Array<UInt8> = [0u8]
        match (NonZeroU8.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(t)) =>
                @Expect(t, IntegerType.U8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_nonzero_u8_valid() {
        let data: Array<UInt8> = [42u8]
        match (NonZeroU8.decode(data, 0, standard)) {
            case MyResult.Ok((nz, _)) => @Expect(nz.get(), 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_nonzero_u8_truncated() {
        let data: Array<UInt8> = []
        match (NonZeroU8.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === 空数组解码：decode_arraylist 在 len=0 时返回空 ArrayList ===
    @TestCase
    public func test_decode_arraylist_empty() {
        let data: Array<UInt8> = [0u8]
        match (decode_arraylist<UInt8>(data, 0, standard)) {
            case MyResult.Ok((list, _)) => @Expect(list.size, 0)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_arraylist_non_empty() {
        let data: Array<UInt8> = [2u8, 10u8, 20u8]
        match (decode_arraylist<UInt8>(data, 0, standard)) {
            case MyResult.Ok((list, _)) => @Expect(list.size, 2)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_arraylist_truncated_len() {
        let data: Array<UInt8> = []
        match (decode_arraylist<UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === decode_string 截断数据 ===
    @TestCase
    public func test_decode_string_truncated() {
        let data: Array<UInt8> = [10u8]
        match (decode_string(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === decode_char 截断数据 ===
    @TestCase
    public func test_decode_char_truncated_two_byte() {
        let data: Array<UInt8> = [0xC0u8]
        match (decode_char(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_char_truncated_three_byte() {
        let data: Array<UInt8> = [0xE0u8, 0xA0u8]
        match (decode_char(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_char_truncated_four_byte() {
        let data: Array<UInt8> = [0xF0u8, 0x90u8, 0x80u8]
        match (decode_char(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_char_ascii() {
        let data: Array<UInt8> = [65u8]
        match (decode_char(data, 0, standard)) {
            case MyResult.Ok((r, _)) => @Expect(UInt32(r), 65u32)
            case _ => @Expect(false)
        }
    }

    // === varint_decode 正常路径 ===
    @TestCase
    public func test_varint_decode_u16_inline() {
        let data: Array<UInt8> = [42u8]
        match (varint_decode_u16(data, 0, Endianness.Little)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42u16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u32_inline() {
        let data: Array<UInt8> = [42u8]
        match (varint_decode_u32(data, 0, Endianness.Little)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42u32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u64_inline() {
        let data: Array<UInt8> = [42u8]
        match (varint_decode_u64(data, 0, Endianness.Little)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u16_empty_data() {
        let data: Array<UInt8> = []
        match (varint_decode_u16(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === decode_u16 标准 (varint) 模式 ===
    @TestCase
    public func test_decode_u16_standard_inline() {
        let data: Array<UInt8> = [42u8]
        match (decode_u16(data, 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v, 42u16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u16_standard_invalid_tag() {
        let data: Array<UInt8> = [255u8]
        match (decode_u16(data, 0, standard)) {
            case MyResult.Err(DecodeError.InvalidIntegerType(_, _)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === decode_u32/u64 标准 (varint) 模式无效标记 ===
    @TestCase
    public func test_decode_u32_standard_invalid_tag() {
        let data: Array<UInt8> = [255u8]
        match (decode_u32(data, 0, standard)) {
            case MyResult.Err(DecodeError.InvalidIntegerType(_, _)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u64_standard_invalid_tag() {
        let data: Array<UInt8> = [255u8]
        match (decode_u64(data, 0, standard)) {
            case MyResult.Err(DecodeError.InvalidIntegerType(_, _)) => @Expect(true)
            case _ => @Expect(false)
        }
    }
}
