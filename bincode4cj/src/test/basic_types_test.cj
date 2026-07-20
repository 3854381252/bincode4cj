// basic_types_test.cj — Tests for basic type encode/decode roundtrip (UInt8/Bool 类型)
package bincode4cj.test
import std.collection.*
import std.unittest.*
import bincode4cj.{ standard, encode_u8, encode_bool, decode_u8, decode_bool, MyResult }

@Test
public class BasicTypesTests {
    @TestCase
    public func test_u8_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_u8(42u8, standard, buf)
        match (decode_u8(buf.toArray(), 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_bool_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_bool(true, standard, buf)
        match (decode_bool(buf.toArray(), 0)) {
            case MyResult.Ok((val, _)) => @Expect(val)
            case _ => @Expect(false)
        }
    }
}