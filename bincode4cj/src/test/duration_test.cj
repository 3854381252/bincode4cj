// duration_test.cj — Tests for Duration encode
package bincode4cj.test
import std.collection.*
import std.time.*
import std.unittest.*
import bincode4cj.{ standard, encode_duration }

@Test
public class DurationTests {
    @TestCase
    public func test_duration_encode() {
        let d = 5 * Duration.second + 500 * Duration.millisecond
        let buf = ArrayList<UInt8>()
        encode_duration(d, standard, buf)
        @Expect(buf.size > 0)
    }
}