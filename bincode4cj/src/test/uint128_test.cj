// uint128_test.cj — Comprehensive tests for UInt128 class
package bincode4cj.test
import std.collection.*
import std.unittest.*
import bincode4cj.{ UInt128 }

@Test
public class UInt128Tests {
    @TestCase
    public func test_create() {
        let u = UInt128(0, 0)
        @Expect(u.to_u64(), 0u64)
    }

    @TestCase
    public func test_create_with_values() {
        let u = UInt128(100, 200)
        @Expect(u.to_u64(), 100u64)
    }

    @TestCase
    public func test_add_no_carry() {
        let a = UInt128(1, 0)
        let b = UInt128(2, 0)
        let r = a.op_add(b)
        @Expect(r.to_u64(), 3u64)
    }

    @TestCase
    public func test_add_with_carry() {
        let a = UInt128(0xFFFFFFFFFFFFFFFE, 0)
        let b = UInt128(1, 0)
        let r = a.op_add(b)
        @Expect(r.to_u64(), 0xFFFFFFFFFFFFFFFF)
    }

    @TestCase
    public func test_sub_no_borrow() {
        let a = UInt128(5, 0)
        let b = UInt128(3, 0)
        let r = a.op_sub(b)
        @Expect(r.to_u64(), 2u64)
    }

    @TestCase
    public func test_and() {
        let a = UInt128(0xFF, 0)
        let b = UInt128(0x0F, 0)
        let r = a.op_and(b)
        @Expect(r.to_u64(), 0x0Fu64)
    }

    @TestCase
    public func test_or() {
        let a = UInt128(0xF0, 0)
        let b = UInt128(0x0F, 0)
        let r = a.op_or(b)
        @Expect(r.to_u64(), 0xFFu64)
    }

    @TestCase
    public func test_xor() {
        let a = UInt128(0xFF, 0)
        let b = UInt128(0x0F, 0)
        let r = a.op_xor(b)
        @Expect(r.to_u64(), 0xF0u64)
    }

    @TestCase
    public func test_not() {
        let u = UInt128(0xFFFFFFFFFFFFFFFF, 0)
        let r = u.op_not()
        @Expect(r.to_u64(), 0u64)
    }

    @TestCase
    public func test_shl() {
        let u = UInt128(1, 0)
        let r = u.op_shl(1)
        @Expect(r.to_u64(), 2u64)
    }

    @TestCase
    public func test_shr() {
        let u = UInt128(2, 0)
        let r = u.op_shr(1)
        @Expect(r.to_u64(), 1u64)
    }

    @TestCase
    public func test_to_le_bytes() {
        let u = UInt128(0x0102030405060708, 0)
        let bytes = u.to_le_bytes()
        @Expect(bytes.size, 16)
        @Expect(bytes[0], 0x08u8)
    }

    @TestCase
    public func test_from_le_bytes() {
        let bytes = Array<UInt8>(16, {_ => 0u8})
        let u = UInt128.from_le_bytes(bytes)
        @Expect(u.to_u64(), 0u64)
    }

    @TestCase
    public func test_equals() {
        let a = UInt128(42, 0)
        let b = UInt128(42, 0)
        @Expect(a.equals(b))
    }

    @TestCase
    public func test_less_than() {
        let a = UInt128(1, 0)
        let b = UInt128(2, 0)
        @Expect(a.less_than(b))
        @Expect(!b.less_than(a))
    }

    @TestCase
    public func test_to_string() {
        let u = UInt128(42, 0)
        let s = u.to_string()
        @Expect(s.contains("42"))
    }

    // === Edge cases ===
    @TestCase
    public func test_shl_overflow() {
        let u = UInt128(1, 0)
        let r = u.op_shl(128)
        @Expect(r.to_u64(), 0u64)
    }

    @TestCase
    public func test_shl_cross_boundary() {
        let u = UInt128(1, 0)
        let r = u.op_shl(64)
        @Expect(r.to_u64(), 0u64)
        @Expect(r.equals(UInt128(0, 1)))
    }

    @TestCase
    public func test_shr_overflow() {
        let u = UInt128(0, 1)
        let r = u.op_shr(128)
        @Expect(r.to_u64(), 0u64)
    }

    @TestCase
    public func test_shr_cross_boundary() {
        let u = UInt128(0, 1)
        let r = u.op_shr(64)
        @Expect(r.to_u64(), 1u64)
    }

    @TestCase
    public func test_from_le_bytes_short() {
        let bytes = Array<UInt8>(4, {_ => 0xFFu8})
        let u = UInt128.from_le_bytes(bytes)
        @Expect(u.to_u64() > 0)
    }

    @TestCase
    public func test_hi_operations() {
        let a = UInt128(0, 0xFFFFFFFFFFFFFFFF)
        let b = UInt128(0, 1)
        let r = a.op_add(b)
        @Expect(r.equals(UInt128(0, 0)))
    }
}