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
public enum IntegerType { U8 | U16 | U32 | U64 | U128 | Usize | I8 | I16 | I32 | I64 | Isize | Reserved }

public func integer_type_into_signed(t: IntegerType): IntegerType {
    match (t) {
        case IntegerType.U8 => IntegerType.I8
        case IntegerType.U16 => IntegerType.I16
        case IntegerType.U32 => IntegerType.I32
        case IntegerType.U64 => IntegerType.I64
        case IntegerType.U128 => IntegerType.Reserved
        case IntegerType.Usize => IntegerType.Isize
        case _ => t
    }
}