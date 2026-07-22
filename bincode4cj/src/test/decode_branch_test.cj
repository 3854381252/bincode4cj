// decode_branch_test.cj - Branch coverage tests for decode.cj non-tuple error paths
package bincode4cj.test
import std.collection.*
import std.time.*
import std.net.*
import std.fs.*
import std.unittest.*
import bincode4cj.{ standard, legacy, MyResult, DecodeError, IntegerType, Endianness,
    decode_u8, decode_u16, decode_u32, decode_u64, decode_bool, decode_string, decode_char,
    decode_duration, decode_f32, decode_f64, decode_arraylist, decode_hashmap, decode_hashset,
    decode_option, decode_result, decode_bound, decode_path,
    decode_ipv4_address, decode_ipv6_address, decode_ip_address,
    decode_ip_socket_address, decode_socket_addr_v4, decode_socket_addr_v6,
    varint_decode_u16, varint_decode_u32, varint_decode_u64,
    Decode, BoundEnum, Config }

@Test
public class DecodeBranchTests {

    // === 1. 基本类型解码错误路径 ===

    // --- decode_u16/u32/u64 varint LE 截断 (U16_BYTE=251, U32_BYTE=252, U64_BYTE=253) ---

    @TestCase
    public func test_decode_u16_varint_truncated_u16_byte_0() {
        let data: Array<UInt8> = [251u8]
        match (decode_u16(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u16_varint_truncated_u16_byte_1() {
        let data: Array<UInt8> = [251u8, 0u8]
        match (decode_u16(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u32_varint_truncated_u32_byte_0() {
        let data: Array<UInt8> = [252u8]
        match (decode_u32(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u32_varint_truncated_u32_byte_3() {
        let data: Array<UInt8> = [252u8, 0u8, 0u8, 0u8]
        match (decode_u32(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u64_varint_truncated_u64_byte_0() {
        let data: Array<UInt8> = [253u8]
        match (decode_u64(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u64_varint_truncated_u64_byte_7() {
        let data: Array<UInt8> = [253u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8]
        match (decode_u64(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_u16/u32/u64 fixint BE 截断 ---

    @TestCase
    public func test_decode_u16_fixint_be_truncated_1() {
        let data: Array<UInt8> = [0xFFu8]
        match (decode_u16(data, 0, legacy.with_big_endian())) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u32_fixint_be_truncated_3() {
        let data: Array<UInt8> = [0u8, 0u8, 0u8]
        match (decode_u32(data, 0, legacy.with_big_endian())) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_u64_fixint_be_truncated_7() {
        let data: Array<UInt8> = [0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8]
        match (decode_u64(data, 0, legacy.with_big_endian())) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_f32/f64 截断 ---

    @TestCase
    public func test_decode_f32_le_truncated_2() {
        let data: Array<UInt8> = [0u8, 0u8]
        match (decode_f32(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_f64_le_truncated_4() {
        let data: Array<UInt8> = [0u8, 0u8, 0u8, 0u8]
        match (decode_f64(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_f32_be_truncated_2() {
        let data: Array<UInt8> = [0u8, 0u8]
        match (decode_f32(data, 0, standard.with_big_endian())) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_f64_be_truncated_4() {
        let data: Array<UInt8> = [0u8, 0u8, 0u8, 0u8]
        match (decode_f64(data, 0, standard.with_big_endian())) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_string 截断 ---

    @TestCase
    public func test_decode_string_length_prefix_truncated() {
        let data: Array<UInt8> = []
        match (decode_string(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_string_byte_data_truncated_partial() {
        let data: Array<UInt8> = [5u8, 0u8, 0u8]
        match (decode_string(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_char UTF-8 多字节序列截断 ---

    @TestCase
    public func test_decode_char_2byte_truncated_1() {
        let data: Array<UInt8> = [0xC3u8]
        match (decode_char(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_char_3byte_truncated_1() {
        let data: Array<UInt8> = [0xE0u8]
        match (decode_char(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_char_3byte_truncated_2() {
        let data: Array<UInt8> = [0xE0u8, 0xA0u8]
        match (decode_char(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_char_4byte_truncated_1() {
        let data: Array<UInt8> = [0xF0u8]
        match (decode_char(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_char_4byte_truncated_2() {
        let data: Array<UInt8> = [0xF0u8, 0x90u8]
        match (decode_char(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_char_4byte_truncated_3() {
        let data: Array<UInt8> = [0xF0u8, 0x90u8, 0x80u8]
        match (decode_char(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_duration 截断 ---

    @TestCase
    public func test_decode_duration_secs_truncated() {
        let data: Array<UInt8> = []
        match (decode_duration(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_duration_nanos_truncated() {
        let data: Array<UInt8> = [0u8]
        match (decode_duration(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === 2. 容器解码错误路径 ===

    // --- decode_arraylist ---

    @TestCase
    public func test_decode_arraylist_len3_but_1_element() {
        let data: Array<UInt8> = [3u8, 1u8]
        match (decode_arraylist<UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_hashmap ---

    @TestCase
    public func test_decode_hashmap_len2_but_1_kv() {
        let data: Array<UInt8> = [2u8, 1u8, 10u8]
        match (decode_hashmap<UInt8, UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_hashmap_length_truncated() {
        let data: Array<UInt8> = []
        match (decode_hashmap<UInt8, UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_hashmap_key_truncated() {
        let data: Array<UInt8> = [2u8]
        match (decode_hashmap<UInt8, UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_hashset ---

    @TestCase
    public func test_decode_hashset_len2_but_1_element() {
        let data: Array<UInt8> = [2u8, 1u8]
        match (decode_hashset<UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_hashset_length_truncated() {
        let data: Array<UInt8> = []
        match (decode_hashset<UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_option ---

    @TestCase
    public func test_decode_option_tag_truncated() {
        let data: Array<UInt8> = []
        match (decode_option<UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_option_tag1_value_truncated() {
        let data: Array<UInt8> = [1u8]
        match (decode_option<UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_result ---

    @TestCase
    public func test_decode_result_tag_truncated() {
        let data: Array<UInt8> = []
        match (decode_result<UInt8, UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_result_tag0_value_truncated() {
        let data: Array<UInt8> = [0u8]
        match (decode_result<UInt8, UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_result_tag1_value_truncated() {
        let data: Array<UInt8> = [1u8]
        match (decode_result<UInt8, UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_bound ---

    @TestCase
    public func test_decode_bound_tag_truncated() {
        let data: Array<UInt8> = []
        match (decode_bound<UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_bound_tag1_value_truncated() {
        let data: Array<UInt8> = [1u8]
        match (decode_bound<UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_bound_tag2_value_truncated() {
        let data: Array<UInt8> = [2u8]
        match (decode_bound<UInt8>(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === 3. 网络类型解码错误路径 ===

    // --- decode_ipv4_address ---

    @TestCase
    public func test_decode_ipv4_address_truncated_2() {
        let data: Array<UInt8> = [1u8, 2u8]
        match (decode_ipv4_address(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_ipv6_address ---

    @TestCase
    public func test_decode_ipv6_address_truncated_8() {
        let data: Array<UInt8> = [0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8]
        match (decode_ipv6_address(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_ip_address ---

    @TestCase
    public func test_decode_ip_address_tag_truncated() {
        let data: Array<UInt8> = []
        match (decode_ip_address(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_ip_address_v4_truncated() {
        let data: Array<UInt8> = [0u8, 1u8, 2u8]
        match (decode_ip_address(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_ip_address_v6_truncated() {
        let data: Array<UInt8> = [1u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8]
        match (decode_ip_address(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_ip_address_invalid_tag() {
        let data: Array<UInt8> = [2u8]
        match (decode_ip_address(data, 0, standard)) {
            case MyResult.Err(DecodeError.Other(msg)) => @Expect(msg, "Invalid IP address tag")
            case _ => @Expect(false)
        }
    }

    // --- decode_ip_socket_address ---

    @TestCase
    public func test_decode_ip_socket_address_tag_truncated() {
        let data: Array<UInt8> = []
        match (decode_ip_socket_address(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_ip_socket_address_v4_addr_truncated() {
        let data: Array<UInt8> = [0u8, 1u8, 2u8]
        match (decode_ip_socket_address(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_ip_socket_address_v4_port_truncated() {
        let data: Array<UInt8> = [0u8, 1u8, 2u8, 3u8, 4u8]
        match (decode_ip_socket_address(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_ip_socket_address_v6_addr_truncated() {
        let data: Array<UInt8> = [1u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8]
        match (decode_ip_socket_address(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_ip_socket_address_v6_port_truncated() {
        let data: Array<UInt8> = [1u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8]
        match (decode_ip_socket_address(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_ip_socket_address_invalid_tag() {
        let data: Array<UInt8> = [2u8]
        match (decode_ip_socket_address(data, 0, standard)) {
            case MyResult.Err(DecodeError.Other(msg)) => @Expect(msg, "Invalid socket address tag")
            case _ => @Expect(false)
        }
    }

    // --- decode_socket_addr_v4 ---

    @TestCase
    public func test_decode_socket_addr_v4_ip_truncated() {
        let data: Array<UInt8> = [1u8, 2u8]
        match (decode_socket_addr_v4(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_socket_addr_v4_port_truncated() {
        let data: Array<UInt8> = [1u8, 2u8, 3u8, 4u8]
        match (decode_socket_addr_v4(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_socket_addr_v6 ---

    @TestCase
    public func test_decode_socket_addr_v6_ip_truncated() {
        let data: Array<UInt8> = [0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8]
        match (decode_socket_addr_v6(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_socket_addr_v6_port_truncated() {
        let data: Array<UInt8> = [0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8]
        match (decode_socket_addr_v6(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === 4. varint 解码错误路径 ===

    // --- varint_decode_u16 错误 tag ---

    @TestCase
    public func test_varint_decode_u16_u32_tag() {
        let data: Array<UInt8> = [252u8]
        match (varint_decode_u16(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.InvalidIntegerType(expected, found)) =>
                @Expect(expected, IntegerType.U16)
                @Expect(found, IntegerType.U32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u16_u64_tag() {
        let data: Array<UInt8> = [253u8]
        match (varint_decode_u16(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.InvalidIntegerType(expected, found)) =>
                @Expect(expected, IntegerType.U16)
                @Expect(found, IntegerType.U64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u16_u128_tag() {
        let data: Array<UInt8> = [254u8]
        match (varint_decode_u16(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.InvalidIntegerType(expected, found)) =>
                @Expect(expected, IntegerType.U16)
                @Expect(found, IntegerType.U128)
            case _ => @Expect(false)
        }
    }

    // --- varint_decode_u32 错误 tag ---

    @TestCase
    public func test_varint_decode_u32_u64_tag() {
        let data: Array<UInt8> = [253u8]
        match (varint_decode_u32(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.InvalidIntegerType(expected, found)) =>
                @Expect(expected, IntegerType.U32)
                @Expect(found, IntegerType.U64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u32_u128_tag() {
        let data: Array<UInt8> = [254u8]
        match (varint_decode_u32(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.InvalidIntegerType(expected, found)) =>
                @Expect(expected, IntegerType.U32)
                @Expect(found, IntegerType.U128)
            case _ => @Expect(false)
        }
    }

    // --- varint_decode_u64 错误 tag ---

    @TestCase
    public func test_varint_decode_u64_u128_tag() {
        let data: Array<UInt8> = [254u8]
        match (varint_decode_u64(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.InvalidIntegerType(expected, found)) =>
                @Expect(expected, IntegerType.U64)
                @Expect(found, IntegerType.U128)
            case _ => @Expect(false)
        }
    }

    // --- varint_decode LE 截断 ---

    @TestCase
    public func test_varint_decode_u32_le_truncated() {
        let data: Array<UInt8> = [252u8]
        match (varint_decode_u32(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u64_le_truncated() {
        let data: Array<UInt8> = [253u8]
        match (varint_decode_u64(data, 0, Endianness.Little)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- varint_decode BE 截断 ---

    @TestCase
    public func test_varint_decode_u16_be_truncated() {
        let data: Array<UInt8> = [251u8]
        match (varint_decode_u16(data, 0, Endianness.Big)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u32_be_truncated() {
        let data: Array<UInt8> = [252u8]
        match (varint_decode_u32(data, 0, Endianness.Big)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_varint_decode_u64_be_truncated() {
        let data: Array<UInt8> = [253u8]
        match (varint_decode_u64(data, 0, Endianness.Big)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // === 5. 路径解码错误 ===

    @TestCase
    public func test_decode_path_truncated() {
        let data: Array<UInt8> = []
        match (decode_path(data, 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Expect(true)
            case _ => @Expect(false)
        }
    }
}
