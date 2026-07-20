// tuple_test.cj — Tests for tuple encode/decode
package bincode4cj.test
import std.collection.*
import std.unittest.*
import bincode4cj.{ standard, encode_tuple1, encode_tuple2, decode_tuple1, decode_tuple2, MyResult }

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
}