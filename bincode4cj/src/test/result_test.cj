// result_test.cj — Tests for MyResult encode/decode
package bincode4cj.test
import std.collection.*
import std.unittest.*
import bincode4cj.{ standard, encode_result, decode_result, MyResult, Encode, Decode }

@Test
public class ResultTests {
    @TestCase
    public func test_result_ok_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_result(MyResult.Ok(42u8), standard, buf)
        let r = decode_result<UInt8, UInt8>(buf.toArray(), 0, standard)
        match (r) {
            case MyResult.Ok((MyResult.Ok(val), _)) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_result_err_roundtrip() {
        let buf = ArrayList<UInt8>()
        encode_result(MyResult.Err(99u8), standard, buf)
        let r = decode_result<UInt8, UInt8>(buf.toArray(), 0, standard)
        match (r) {
            case MyResult.Ok((MyResult.Err(err), _)) => @Expect(err, 99u8)
            case _ => @Expect(false)
        }
    }
}