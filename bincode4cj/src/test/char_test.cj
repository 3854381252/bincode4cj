// char_test.cj — Tests for char (Rune) encode/decode
package bincode4cj.test
import std.collection.*
import std.unittest.*
import bincode4cj.{ standard, encode_char, decode_char, MyResult }

@Test
public class CharTests {
    @TestCase
    public func test_char_encode_decode() {
        let buf = ArrayList<UInt8>()
        encode_char(Rune(65), standard, buf)  // 'A'
        match (decode_char(buf.toArray(), 0, standard)) {
            case MyResult.Ok((r, _)) => @Expect(r, Rune(65))
            case _ => @Expect(false)
        }
    }
}