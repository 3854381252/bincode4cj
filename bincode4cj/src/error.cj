// error.cj — Error types
package bincode4cj
import std.deriving.*

public enum MyResult<T, E> { Ok(T) | Err(E) }

public enum EncodeError {
    UnexpectedEnd
    | RefCellAlreadyBorrowed(String, String)
    | Other(String)
    | InvalidPathCharacters
    | Io(String, Int64)
    | LockFailed(String)
    | InvalidSystemTime(String, String)
}

public enum DecodeError {
    UnexpectedEnd(Int64)
    | LimitExceeded
    | InvalidIntegerType(IntegerType, IntegerType)
    | NonZeroTypeIsZero(IntegerType)
    | UnexpectedVariant(String, AllowedEnumVariants, UInt32)
    | Utf8(String)
    | InvalidCharEncoding(UInt8, UInt8, UInt8, UInt8)
    | InvalidBooleanValue(UInt8)
    | ArrayLengthMismatch(Int64, Int64)
    | OutsideUsizeRange(UInt64)
    | EmptyEnum(String)
    | InvalidDuration(UInt64, UInt32)
    | InvalidSystemTime(Duration)
    | CStringNulError(Int64)
    | Io(String, Int64)
    | Other(String)
}

@Derive[Equatable]
public enum AllowedEnumVariants { Range(UInt32, UInt32) | Allowed(Array<UInt32>) }
@Derive[Equatable]
public enum IntegerType { U8 | U16 | U32 | U64 | U128 | Usize | I8 | I16 | I32 | I64 | I128 | Isize | Reserved }

public func integer_type_into_signed(t: IntegerType): IntegerType {
    match (t) {
        case IntegerType.U8 => IntegerType.I8
        case IntegerType.U16 => IntegerType.I16
        case IntegerType.U32 => IntegerType.I32
        case IntegerType.U64 => IntegerType.I64
        case IntegerType.U128 => IntegerType.I128
        case IntegerType.Usize => IntegerType.Isize
        case _ => t
    }
}

extend IntegerType <: ToString {
    public func toString(): String {
        match (this) {
            case IntegerType.U8 => "U8"
            case IntegerType.U16 => "U16"
            case IntegerType.U32 => "U32"
            case IntegerType.U64 => "U64"
            case IntegerType.U128 => "U128"
            case IntegerType.Usize => "Usize"
            case IntegerType.I8 => "I8"
            case IntegerType.I16 => "I16"
            case IntegerType.I32 => "I32"
            case IntegerType.I64 => "I64"
            case IntegerType.I128 => "I128"
            case IntegerType.Isize => "Isize"
            case IntegerType.Reserved => "Reserved"
        }
    }
}

extend AllowedEnumVariants <: ToString {
    public func toString(): String {
        match (this) {
            case AllowedEnumVariants.Range(min, max) => "Range(${min}, ${max})"
            case AllowedEnumVariants.Allowed(arr) => "Allowed(${arr})"
        }
    }
}

extend EncodeError <: ToString {
    public func toString(): String {
        match (this) {
            case EncodeError.UnexpectedEnd => "UnexpectedEnd"
            case EncodeError.RefCellAlreadyBorrowed(_, type_name) => "RefCellAlreadyBorrowed: ${type_name}"
            case EncodeError.Other(s) => s
            case EncodeError.InvalidPathCharacters => "InvalidPathCharacters"
            case EncodeError.Io(s, i) => "Io: ${s} at index ${i}"
            case EncodeError.LockFailed(s) => "LockFailed: ${s}"
            case EncodeError.InvalidSystemTime(s1, s2) => "InvalidSystemTime: ${s1}, ${s2}"
        }
    }
}

extend DecodeError <: ToString {
    public func toString(): String {
        match (this) {
            case DecodeError.UnexpectedEnd(n) => "UnexpectedEnd: expected ${n} more bytes"
            case DecodeError.LimitExceeded => "LimitExceeded"
            case DecodeError.InvalidIntegerType(expected, found) => "InvalidIntegerType: expected ${expected}, found ${found}"
            case DecodeError.NonZeroTypeIsZero(t) => "NonZeroTypeIsZero: ${t}"
            case DecodeError.UnexpectedVariant(name, variants, val) => "UnexpectedVariant: ${name}, ${variants}, ${val}"
            case DecodeError.Utf8(s) => "Utf8: ${s}"
            case DecodeError.InvalidCharEncoding(a, b, c, d) => "InvalidCharEncoding: ${a}, ${b}, ${c}, ${d}"
            case DecodeError.InvalidBooleanValue(v) => "InvalidBooleanValue: ${v}"
            case DecodeError.ArrayLengthMismatch(expected, found) => "ArrayLengthMismatch: expected ${expected}, found ${found}"
            case DecodeError.OutsideUsizeRange(v) => "OutsideUsizeRange: ${v}"
            case DecodeError.EmptyEnum(name) => "EmptyEnum: ${name}"
            case DecodeError.InvalidDuration(secs, nanos) => "InvalidDuration: ${secs}s, ${nanos}ns"
            case DecodeError.InvalidSystemTime(d) => "InvalidSystemTime: ${d}"
            case DecodeError.CStringNulError(pos) => "CStringNulError: nul byte at position ${pos}"
            case DecodeError.Io(s, i) => "Io: ${s} at index ${i}"
            case DecodeError.Other(s) => s
        }
    }
}