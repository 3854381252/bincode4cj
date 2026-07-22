// tuple_branch_test.cj - Branch coverage tests for decode_tupleN Err paths
package bincode4cj.test
import std.collection.*
import std.unittest.*
import bincode4cj.{ standard, MyResult, DecodeError,
    encode_tuple1, encode_tuple2, encode_tuple3, encode_tuple4, encode_tuple5, encode_tuple6,
    encode_tuple7, encode_tuple8, encode_tuple9, encode_tuple10, encode_tuple11,
    encode_tuple12, encode_tuple13, encode_tuple14,
    decode_tuple2, decode_tuple3, decode_tuple4, decode_tuple5, decode_tuple6,
    decode_tuple7, decode_tuple8, decode_tuple9, decode_tuple10, decode_tuple11,
    decode_tuple12, decode_tuple13, decode_tuple14, decode_tuple15, decode_tuple16 }

@Test
public class TupleBranchTests {

    // ==================== tuple2: pos 1 ====================
    @TestCase
    public func test_tuple2_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple2<UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple3: pos 1, 2 ====================
    @TestCase
    public func test_tuple3_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple3<UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple3_truncate_at_2() {
        let buf = ArrayList<UInt8>()
        encode_tuple1(1u8, standard, buf)
        match (decode_tuple3<UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple4: pos 1, 3 ====================
    @TestCase
    public func test_tuple4_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple4<UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple4_truncate_at_3() {
        let buf = ArrayList<UInt8>()
        encode_tuple2((1u8, 2u8), standard, buf)
        match (decode_tuple4<UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple5: pos 1, 3 ====================
    @TestCase
    public func test_tuple5_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple5<UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple5_truncate_at_3() {
        let buf = ArrayList<UInt8>()
        encode_tuple2((1u8, 2u8), standard, buf)
        match (decode_tuple5<UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple6: pos 1, 4 ====================
    @TestCase
    public func test_tuple6_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple6<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple6_truncate_at_4() {
        let buf = ArrayList<UInt8>()
        encode_tuple3((1u8, 2u8, 3u8), standard, buf)
        match (decode_tuple6<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple7: pos 1, 4 ====================
    @TestCase
    public func test_tuple7_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple7<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple7_truncate_at_4() {
        let buf = ArrayList<UInt8>()
        encode_tuple3((1u8, 2u8, 3u8), standard, buf)
        match (decode_tuple7<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple8: pos 1, 4, 7 ====================
    @TestCase
    public func test_tuple8_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple8<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple8_truncate_at_4() {
        let buf = ArrayList<UInt8>()
        encode_tuple3((1u8, 2u8, 3u8), standard, buf)
        match (decode_tuple8<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple8_truncate_at_7() {
        let buf = ArrayList<UInt8>()
        encode_tuple6((1u8, 2u8, 3u8, 4u8, 5u8, 6u8), standard, buf)
        match (decode_tuple8<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple9: pos 1, 5, 8 ====================
    @TestCase
    public func test_tuple9_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple9<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple9_truncate_at_5() {
        let buf = ArrayList<UInt8>()
        encode_tuple4((1u8, 2u8, 3u8, 4u8), standard, buf)
        match (decode_tuple9<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple9_truncate_at_8() {
        let buf = ArrayList<UInt8>()
        encode_tuple7((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8), standard, buf)
        match (decode_tuple9<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple10: pos 1, 5, 9 ====================
    @TestCase
    public func test_tuple10_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple10<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple10_truncate_at_5() {
        let buf = ArrayList<UInt8>()
        encode_tuple4((1u8, 2u8, 3u8, 4u8), standard, buf)
        match (decode_tuple10<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple10_truncate_at_9() {
        let buf = ArrayList<UInt8>()
        encode_tuple8((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8), standard, buf)
        match (decode_tuple10<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple11: pos 1, 6, 10 ====================
    @TestCase
    public func test_tuple11_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple11<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple11_truncate_at_6() {
        let buf = ArrayList<UInt8>()
        encode_tuple5((1u8, 2u8, 3u8, 4u8, 5u8), standard, buf)
        match (decode_tuple11<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple11_truncate_at_10() {
        let buf = ArrayList<UInt8>()
        encode_tuple9((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8), standard, buf)
        match (decode_tuple11<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple12: pos 1, 6, 11 ====================
    @TestCase
    public func test_tuple12_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple12<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple12_truncate_at_6() {
        let buf = ArrayList<UInt8>()
        encode_tuple5((1u8, 2u8, 3u8, 4u8, 5u8), standard, buf)
        match (decode_tuple12<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple12_truncate_at_11() {
        let buf = ArrayList<UInt8>()
        encode_tuple10((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8, 10u8), standard, buf)
        match (decode_tuple12<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple13: pos 1, 7, 12 ====================
    @TestCase
    public func test_tuple13_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple13<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple13_truncate_at_7() {
        let buf = ArrayList<UInt8>()
        encode_tuple6((1u8, 2u8, 3u8, 4u8, 5u8, 6u8), standard, buf)
        match (decode_tuple13<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple13_truncate_at_12() {
        let buf = ArrayList<UInt8>()
        encode_tuple11((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8, 10u8, 11u8), standard, buf)
        match (decode_tuple13<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple14: pos 1, 7, 13 ====================
    @TestCase
    public func test_tuple14_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple14<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple14_truncate_at_7() {
        let buf = ArrayList<UInt8>()
        encode_tuple6((1u8, 2u8, 3u8, 4u8, 5u8, 6u8), standard, buf)
        match (decode_tuple14<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple14_truncate_at_13() {
        let buf = ArrayList<UInt8>()
        encode_tuple12((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8, 10u8, 11u8, 12u8), standard, buf)
        match (decode_tuple14<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple15: pos 1, 8, 14 ====================
    @TestCase
    public func test_tuple15_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple15<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple15_truncate_at_8() {
        let buf = ArrayList<UInt8>()
        encode_tuple7((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8), standard, buf)
        match (decode_tuple15<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple15_truncate_at_14() {
        let buf = ArrayList<UInt8>()
        encode_tuple13((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8, 10u8, 11u8, 12u8, 13u8), standard, buf)
        match (decode_tuple15<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    // ==================== tuple16: pos 1, 8, 15 ====================
    @TestCase
    public func test_tuple16_truncate_at_1() {
        let buf = ArrayList<UInt8>()
        match (decode_tuple16<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple16_truncate_at_8() {
        let buf = ArrayList<UInt8>()
        encode_tuple7((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8), standard, buf)
        match (decode_tuple16<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }

    @TestCase
    public func test_tuple16_truncate_at_15() {
        let buf = ArrayList<UInt8>()
        encode_tuple14((1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8, 9u8, 10u8, 11u8, 12u8, 13u8, 14u8), standard, buf)
        match (decode_tuple16<UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8>(buf.toArray(), 0, standard)) {
            case MyResult.Err(DecodeError.UnexpectedEnd(_)) => @Assert(true)
            case _ => @Assert(false)
        }
    }
}
