// collection_decode_test.cj - Tests for collection Decode implementations and PhantomData
package bincode4cj.test
import std.collection.*
import std.unittest.*
import bincode4cj.{ standard, MyResult, DecodeError, Encode, Decode,
    BinaryHeap, VecDeque, BTreeMap, BTreeSet, BoxedSlice, PhantomData }

@Test
public class CollectionDecodeTests {

    // === BinaryHeap<UInt32> roundtrip ===
    @TestCase
    public func test_binary_heap_roundtrip() {
        let heap = BinaryHeap<UInt32>(ArrayList<UInt32>([1u32, 2u32, 3u32]))
        let buf = ArrayList<UInt8>()
        heap.encode(standard, buf)
        match (BinaryHeap<UInt32>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((result, _)) =>
                @Expect(result.size(), 3)
                @Expect(result.get_inner()[0], 1u32)
                @Expect(result.get_inner()[1], 2u32)
                @Expect(result.get_inner()[2], 3u32)
            case MyResult.Err(_) => @Expect(false)
        }
    }

    // === VecDeque<UInt64> roundtrip ===
    @TestCase
    public func test_vec_deque_roundtrip() {
        let vd = VecDeque<UInt64>(ArrayList<UInt64>([10u64, 20u64, 30u64, 40u64]))
        let buf = ArrayList<UInt8>()
        vd.encode(standard, buf)
        match (VecDeque<UInt64>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((result, _)) =>
                @Expect(result.size(), 4)
                @Expect(result.get_inner()[0], 10u64)
                @Expect(result.get_inner()[1], 20u64)
                @Expect(result.get_inner()[2], 30u64)
                @Expect(result.get_inner()[3], 40u64)
            case MyResult.Err(_) => @Expect(false)
        }
    }

    // === BTreeMap<String, UInt32> roundtrip ===
    @TestCase
    public func test_btree_map_roundtrip() {
        let m = BTreeMap<String, UInt32>()
        m.put("a", 1u32)
        m.put("b", 2u32)
        m.put("c", 3u32)
        let buf = ArrayList<UInt8>()
        m.encode(standard, buf)
        match (BTreeMap<String, UInt32>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((result, _)) =>
                @Expect(result.size(), 3)
                match (result.get_inner().get("a")) {
                    case Some(v) => @Expect(v, 1u32)
                    case None => @Expect(false)
                }
                match (result.get_inner().get("b")) {
                    case Some(v) => @Expect(v, 2u32)
                    case None => @Expect(false)
                }
                match (result.get_inner().get("c")) {
                    case Some(v) => @Expect(v, 3u32)
                    case None => @Expect(false)
                }
            case MyResult.Err(_) => @Expect(false)
        }
    }

    // === BTreeSet<UInt32> roundtrip ===
    @TestCase
    public func test_btree_set_roundtrip() {
        let s = BTreeSet<UInt32>()
        s.add(1u32)
        s.add(2u32)
        s.add(3u32)
        let buf = ArrayList<UInt8>()
        s.encode(standard, buf)
        match (BTreeSet<UInt32>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((result, _)) =>
                @Expect(result.size(), 3)
                @Expect(result.get_inner().contains(1u32))
                @Expect(result.get_inner().contains(2u32))
                @Expect(result.get_inner().contains(3u32))
            case MyResult.Err(_) => @Expect(false)
        }
    }

    // === BoxedSlice<UInt64> roundtrip ===
    @TestCase
    public func test_boxed_slice_roundtrip() {
        let bs = BoxedSlice<UInt64>([100u64, 200u64, 300u64])
        let buf = ArrayList<UInt8>()
        bs.encode(standard, buf)
        match (BoxedSlice<UInt64>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((result, _)) =>
                @Expect(result.get().size, 3)
                @Expect(result.get()[0], 100u64)
                @Expect(result.get()[1], 200u64)
                @Expect(result.get()[2], 300u64)
            case MyResult.Err(_) => @Expect(false)
        }
    }

    // === PhantomData<UInt32> encode/decode (no-op) ===
    @TestCase
    public func test_phantom_data_encode_decode() {
        let pd = PhantomData<UInt32>()
        let buf = ArrayList<UInt8>()
        pd.encode(standard, buf)
        @Expect(buf.size, 0)
        match (PhantomData<UInt32>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((_, pos)) =>
                @Expect(pos, 0)
            case MyResult.Err(_) => @Expect(false)
        }
    }

    // === Empty collections encode/decode ===
    @TestCase
    public func test_empty_binary_heap() {
        let heap = BinaryHeap<UInt32>()
        let buf = ArrayList<UInt8>()
        heap.encode(standard, buf)
        match (BinaryHeap<UInt32>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((result, _)) => @Expect(result.size(), 0)
            case MyResult.Err(_) => @Expect(false)
        }
    }

    @TestCase
    public func test_empty_vec_deque() {
        let vd = VecDeque<UInt64>()
        let buf = ArrayList<UInt8>()
        vd.encode(standard, buf)
        match (VecDeque<UInt64>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((result, _)) => @Expect(result.size(), 0)
            case MyResult.Err(_) => @Expect(false)
        }
    }

    @TestCase
    public func test_empty_btree_map() {
        let m = BTreeMap<String, UInt32>()
        let buf = ArrayList<UInt8>()
        m.encode(standard, buf)
        match (BTreeMap<String, UInt32>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((result, _)) => @Expect(result.size(), 0)
            case MyResult.Err(_) => @Expect(false)
        }
    }

    @TestCase
    public func test_empty_btree_set() {
        let s = BTreeSet<UInt32>()
        let buf = ArrayList<UInt8>()
        s.encode(standard, buf)
        match (BTreeSet<UInt32>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((result, _)) => @Expect(result.size(), 0)
            case MyResult.Err(_) => @Expect(false)
        }
    }

    @TestCase
    public func test_empty_boxed_slice() {
        let bs = BoxedSlice<UInt64>(Array<UInt64>())
        let buf = ArrayList<UInt8>()
        bs.encode(standard, buf)
        match (BoxedSlice<UInt64>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((result, _)) => @Expect(result.get().size, 0)
            case MyResult.Err(_) => @Expect(false)
        }
    }
}
