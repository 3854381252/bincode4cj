// uint128.cj — 128-bit unsigned integer implementation
// Cangjie 1.0.5 不支持原生 UInt128/Int128，通过两个 UInt64 实现
package bincode4cj

public class UInt128 {
    var lo: UInt64
    var hi: UInt64

    public init(lo: UInt64, hi: UInt64) {
        this.lo = lo
        this.hi = hi
    }

    @OverflowWrapping
    public func op_add(other: UInt128): UInt128 {
        let newLo = this.lo + other.lo
        let carry = if (newLo < this.lo) { 1u64 } else { 0u64 }
        UInt128(newLo, this.hi + other.hi + carry)
    }

    public func op_sub(other: UInt128): UInt128 {
        let newLo = this.lo - other.lo
        let borrow = if (newLo > this.lo) { 1u64 } else { 0u64 }
        UInt128(newLo, this.hi - other.hi - borrow)
    }

    public func op_and(other: UInt128): UInt128 {
        UInt128(this.lo & other.lo, this.hi & other.hi)
    }

    public func op_or(other: UInt128): UInt128 {
        UInt128(this.lo | other.lo, this.hi | other.hi)
    }

    public func op_xor(other: UInt128): UInt128 {
        UInt128(this.lo ^ other.lo, this.hi ^ other.hi)
    }

    public func op_not(): UInt128 {
        UInt128(!this.lo, !this.hi)
    }

    public func op_shl(amount: Int64): UInt128 {
        if (amount >= 128) { UInt128(0, 0) }
        else if (amount >= 64) { UInt128(0, this.lo << (amount - 64)) }
        else { UInt128(this.lo << amount, (this.hi << amount) | (this.lo >> (64 - amount))) }
    }

    public func op_shr(amount: Int64): UInt128 {
        if (amount >= 128) { UInt128(0, 0) }
        else if (amount >= 64) { UInt128(this.hi >> (amount - 64), 0) }
        else { UInt128((this.lo >> amount) | (this.hi << (64 - amount)), this.hi >> amount) }
    }

    public func to_le_bytes(): Array<UInt8> {
        let result = Array<UInt8>(16, {_ => 0u8})
        var v = this.lo
        var i: Int64 = 0
        while (i < 8) {
            result[i] = UInt8(v & 0xFF)
            v = v >> 8
            i += 1
        }
        v = this.hi
        while (i < 16) {
            result[i] = UInt8(v & 0xFF)
            v = v >> 8
            i += 1
        }
        result
    }

    public static func from_le_bytes(bytes: Array<UInt8>): UInt128 {
        var lo: UInt64 = 0
        var hi: UInt64 = 0
        var i: Int64 = 0
        while (i < 8 && i < bytes.size) {
            lo = lo | (UInt64(bytes[i]) << (i * 8))
            i += 1
        }
        while (i < 16 && i < bytes.size) {
            hi = hi | (UInt64(bytes[i]) << ((i - 8) * 8))
            i += 1
        }
        UInt128(lo, hi)
    }

    public func equals(other: UInt128): Bool {
        this.lo == other.lo && this.hi == other.hi
    }

    public func less_than(other: UInt128): Bool {
        if (this.hi != other.hi) { this.hi < other.hi }
        else { this.lo < other.lo }
    }

    public func to_u64(): UInt64 { this.lo }
    public func to_string(): String { "UInt128(lo: ${this.lo}, hi: ${this.hi})" }
}

// Int128 — 128-bit signed integer, two's complement, lo=lower 64 bits, hi=upper 64 bits(signed)
public class Int128 {
    var lo: UInt64
    var hi: Int64

    public init(lo: UInt64, hi: Int64) {
        this.lo = lo
        this.hi = hi
    }

    public func is_negative(): Bool { this.hi < 0 }

    @OverflowWrapping
    public func negate(): Int128 {
        let notLo = !this.lo
        let notHi = !this.hi
        let newLo = notLo + 1u64
        let carry = if (newLo == 0u64) { 1i64 } else { 0i64 }
        Int128(newLo, notHi + carry)
    }

    public func to_unsigned(): UInt128 {
        UInt128(this.lo, i64_to_u64(this.hi))
    }

    public static func from_unsigned(val: UInt128): Int128 {
        Int128(val.lo, u64_to_i64(val.hi))
    }

    public func to_i64(): Int64 { u64_to_i64(this.lo) }
    public func equals(other: Int128): Bool { this.lo == other.lo && this.hi == other.hi }
    public func to_string(): String { "Int128(lo: ${this.lo}, hi: ${this.hi})" }
}