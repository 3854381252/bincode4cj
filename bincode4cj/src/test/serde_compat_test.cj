// serde_compat_test.cj — Tests for Compat/BorrowCompat wrappers
package bincode4cj.test
import std.collection.*
import std.unittest.*
import bincode4cj.{ Compat, BorrowCompat, Serialize, Deserialize, Config, Encode, Decode, standard, MyResult, DecodeError }

class MockSerializable <: Serialize {
    public init() {}
    public func serialize(config: Config, buf: ArrayList<UInt8>): Unit {
        buf.add(42u8)
    }
}
extend MockSerializable <: Deserialize<MockSerializable> {
    public static func deserialize(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(MockSerializable, Int64), DecodeError> {
        if (pos >= data.size) { MyResult.Err(DecodeError.UnexpectedEnd(1)) }
        else { MyResult.Ok((MockSerializable(), pos + 1)) }
    }
}

@Test
public class SerdeCompatTests {
    @TestCase
    public func test_compat_encode() {
        let inner = MockSerializable()
        let compat = Compat(inner)
        let buf = ArrayList<UInt8>()
        compat.encode(standard, buf)
        @Expect(buf.size > 0)
        @Expect(buf[0], 42u8)
    }

    @TestCase
    public func test_borrow_compat_create() {
        let inner = MockSerializable()
        let bc = BorrowCompat(inner)
        @Expect(true)
    }

    @TestCase
    public func test_compat_encode_decode() {
        let inner = MockSerializable()
        let compat = Compat(inner)
        let buf = ArrayList<UInt8>()
        compat.encode(standard, buf)
        // Compat decode requires Deserialize, test the decode path
        match (Compat<MockSerializable>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(true)
            case _ => @Expect(false)
        }
    }
}