// derive_test.cj — Tests for @deriveEncode / @deriveDecode macros
package bincode4cj.test
import std.collection.*
import std.unittest.*
import std.collection.*
import std.deriving.*
import bincode4cj.{ standard, legacy, Config, MyResult, DecodeError, Encode, Decode, encode_to_vec, decode_from_slice, encode_u32, decode_u32, AllowedEnumVariants }
import bincode4cj_derive.{ deriveEncode, deriveDecode }

@deriveEncode
class DerivePoint {
    var x: Int64
    var y: Int64
    public init(x: Int64, y: Int64) {
        this.x = x
        this.y = y
    }
}

@deriveEncode
@deriveDecode
class DerivePoint2 {
    var x: Int64
    var y: Int64
    public init(x: Int64, y: Int64) {
        this.x = x
        this.y = y
    }
}

@deriveEncode
@deriveDecode
class DerivePair {
    var a: UInt8
    var b: UInt16
    public init(a: UInt8, b: UInt16) {
        this.a = a
        this.b = b
    }
}

@deriveEncode
@deriveDecode
@Derive[Equatable]
enum DeriveColor {
    | Red | Green | Blue
}

@deriveEncode
@deriveDecode
@Derive[Equatable]
enum DeriveMsg {
    | Quit
    | Move(Int64, Int64)
    | Text(String)
}

@deriveEncode
@deriveDecode
@Derive[Equatable]
enum DeriveSingleParam {
    | None
    | Some(UInt32)
}

@Test
public class DeriveTests {
    @TestCase
    public func test_derive_encode() {
        let pt = DerivePoint(3, 7)
        match (encode_to_vec(pt, standard)) {
            case MyResult.Ok(buf) => @Expect(buf.size > 0)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_derive_decode() {
        let pt = DerivePoint2(3, 7)
        match (encode_to_vec(pt, standard)) {
            case MyResult.Ok(buf) =>
                let data = buf.toArray()
                let r: MyResult<(DerivePoint2, Int64), DecodeError> = decode_from_slice(data, standard)
                match (r) {
                    case MyResult.Ok((decoded, _)) =>
                        @Expect(decoded.x, 3)
                        @Expect(decoded.y, 7)
                    case _ => @Expect(false)
                }
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_derive_pair_roundtrip() {
        let val = DerivePair(42u8, 1000u16)
        match (encode_to_vec(val, standard)) {
            case MyResult.Ok(buf) =>
                let data = buf.toArray()
                let r: MyResult<(DerivePair, Int64), DecodeError> = decode_from_slice(data, standard)
                match (r) {
                    case MyResult.Ok((decoded, _)) =>
                        @Expect(decoded.a, 42u8)
                        @Expect(decoded.b, 1000u16)
                    case _ => @Expect(false)
                }
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_derive_enum_unit_encode() {
        // 使用 legacy（fixint）配置：u32 固定 4 字节小端
        match (encode_to_vec(DeriveColor.Green, legacy)) {
            case MyResult.Ok(buf) =>
                @Expect(buf.size, 4)
                @Expect(buf[0], 1u8)
                @Expect(buf[1], 0u8)
                @Expect(buf[2], 0u8)
                @Expect(buf[3], 0u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_derive_enum_unit_roundtrip() {
        let colors = [DeriveColor.Red, DeriveColor.Green, DeriveColor.Blue]
        for (c in colors) {
            match (encode_to_vec(c, standard)) {
                case MyResult.Ok(buf) =>
                    let data = buf.toArray()
                    let r: MyResult<(DeriveColor, Int64), DecodeError> = decode_from_slice(data, standard)
                    match (r) {
                        case MyResult.Ok((decoded, _)) =>
                            @Expect(decoded, c)
                        case _ => @Expect(false)
                    }
                case _ => @Expect(false)
            }
        }
    }

    @TestCase
    public func test_derive_enum_with_params_roundtrip() {
        let msgs = [DeriveMsg.Quit, DeriveMsg.Move(10, 20), DeriveMsg.Text("hello")]
        for (m in msgs) {
            match (encode_to_vec(m, standard)) {
                case MyResult.Ok(buf) =>
                    let data = buf.toArray()
                    let r: MyResult<(DeriveMsg, Int64), DecodeError> = decode_from_slice(data, standard)
                    match (r) {
                        case MyResult.Ok((decoded, _)) =>
                            @Expect(decoded, m)
                        case _ => @Expect(false)
                    }
                case _ => @Expect(false)
            }
        }
    }

    @TestCase
    public func test_derive_enum_single_param_roundtrip() {
        match (encode_to_vec(DeriveSingleParam.Some(42u32), standard)) {
            case MyResult.Ok(buf) =>
                let data = buf.toArray()
                let r: MyResult<(DeriveSingleParam, Int64), DecodeError> = decode_from_slice(data, standard)
                match (r) {
                    case MyResult.Ok((decoded, _)) =>
                        @Expect(decoded, DeriveSingleParam.Some(42u32))
                    case _ => @Expect(false)
                }
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_derive_enum_invalid_variant() {
        // 使用 legacy（fixint）配置：u32 值 255 = [255, 0, 0, 0] 小端，超出 DeriveColor 范围（0-2）
        let buf = ArrayList<UInt8>([255u8, 0u8, 0u8, 0u8])
        let data = buf.toArray()
        let r: MyResult<(DeriveColor, Int64), DecodeError> = decode_from_slice(data, legacy)
        match (r) {
            case MyResult.Err(e) =>
                match (e) {
                    case DecodeError.UnexpectedVariant(_, _, _) => @Expect(true)
                    case _ => @Expect(false)
                }
            case _ => @Expect(false)
        }
    }
}
