// tuple_test.cj - Tests for tuple encode/decode
package bincode4cj.test
import std.collection.*
import std.unittest.*
import bincode4cj.{ standard, encode_tuple1, encode_tuple2, encode_tuple9, encode_tuple10, encode_tuple11, encode_tuple12, encode_tuple13, encode_tuple14, encode_tuple15, encode_tuple16, decode_tuple1, decode_tuple2, decode_tuple9, decode_tuple10, decode_tuple11, decode_tuple12, decode_tuple13, decode_tuple14, decode_tuple15, decode_tuple16, MyResult }

@Test
public class TupleTests {
    @TestCase
    public func test_tuple1_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_tuple1(42u8, standard, buf)
        let r1 = decode_tuple1<UInt8>(buf.toArray(), 0, standard)
        match (r1) {
            case MyResult.Ok((val, _)) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_tuple2_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_tuple2((10u8, 20u8), standard, buf)
        let r2 = decode_tuple2<UInt8, UInt8>(buf.toArray(), 0, standard)
        match (r2) {
            case MyResult.Ok(((a, b), _)) =>
                @Expect(a, 10u8)
                @Expect(b, 20u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_tuple9_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_tuple9((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8), standard, buf)
        match (decode_tuple9<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Ok(((a, b, c, d, e, f, g, h, i), _)) =>
                @Expect(a, 1u8); @Expect(b, 2u8); @Expect(c, 3u8); @Expect(d, 4u8); @Expect(e, 5u8)
                @Expect(f, 6u8); @Expect(g, 7u8); @Expect(h, 8u8); @Expect(i, 9u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_tuple10_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_tuple10((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8, 10u8), standard, buf)
        match (decode_tuple10<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Ok(((a, b, c, d, e, f, g, h, i, j), _)) =>
                @Expect(a, 1u8); @Expect(j, 10u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_tuple11_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_tuple11((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8, 10u8, 11u8), standard, buf)
        match (decode_tuple11<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Ok(((a, b, c, d, e, f, g, h, i, j, k), _)) =>
                @Expect(a, 1u8); @Expect(k, 11u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_tuple12_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_tuple12((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8, 10u8, 11u8, 12u8), standard, buf)
        match (decode_tuple12<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Ok(((a, b, c, d, e, f, g, h, i, j, k, l), _)) =>
                @Expect(a, 1u8); @Expect(l, 12u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_tuple13_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_tuple13((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8, 10u8, 11u8, 12u8, 13u8), standard, buf)
        match (decode_tuple13<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Ok(((a, b, c, d, e, f, g, h, i, j, k, l, m), _)) =>
                @Expect(a, 1u8); @Expect(m, 13u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_tuple14_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_tuple14((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8, 10u8, 11u8, 12u8, 13u8, 14u8), standard, buf)
        match (decode_tuple14<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Ok(((a, b, c, d, e, f, g, h, i, j, k, l, m, n), _)) =>
                @Expect(a, 1u8); @Expect(n, 14u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_tuple15_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_tuple15((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8, 10u8, 11u8, 12u8, 13u8, 14u8, 15u8), standard, buf)
        match (decode_tuple15<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Ok(((a, b, c, d, e, f, g, h, i, j, k, l, m, n, o), _)) =>
                @Expect(a, 1u8); @Expect(o, 15u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_tuple16_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_tuple16((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8, 10u8, 11u8, 12u8, 13u8, 14u8, 15u8, 16u8), standard, buf)
        match (decode_tuple16<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Ok(((a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p), _)) =>
                @Expect(a, 1u8); @Expect(p, 16u8)
            case _ => @Expect(false)
        }
    }
}
