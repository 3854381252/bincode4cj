// builtins_test.cj — Tests for built-in wrapper types
package bincode4cj.test
import std.collection.*
import std.sync.*
import std.net.*
import std.unittest.*
import bincode4cj.{ NonZeroU8, NonZeroU16, NonZeroU32, NonZeroU64, NonZeroI8, NonZeroI16, NonZeroI32, NonZeroI64, NonZeroU128, NonZeroUsize, Wrapping, Reverse, Cell, RefCell, CString as CJString, Boxed, BoxedStr, BoxedSlice, RefCounted, AtomicRefCounted, RefCountedStr, AtomicRefCountedStr, PhantomData, BoundEnum, CowEnum, Usize, Isize, SocketAddrV4, SocketAddrV6, BinaryHeap, VecDeque, BTreeMap, BTreeSet, SyncMutex, RwLock_, UInt128, standard, encode_u8, decode_u8, encode_string, decode_string, MyResult, Encode, Decode }

@Test
public class BuiltinsTests {
    @TestCase
    public func test_nonzero_u8() {
        let nz = NonZeroU8(42u8)
        @Expect(nz.get(), 42u8)
    }

    @TestCase
    public func test_nonzero_u32() {
        let nz = NonZeroU32(100u32)
        @Expect(nz.get(), 100u32)
    }

    @TestCase
    public func test_wrapping() {
        let w = Wrapping(42)
        @Expect(w.get(), 42)
    }

    @TestCase
    public func test_reverse() {
        let r = Reverse("hello")
        @Expect(r.get(), "hello")
    }

    @TestCase
    public func test_cell() {
        let c = Cell(10)
        @Expect(c.get(), 10)
        c.set(20)
        @Expect(c.get(), 20)
        let old = c.replace(30)
        @Expect(old, 20)
        @Expect(c.get(), 30)
    }

    @TestCase
    public func test_refcell_borrow() {
        let rc = RefCell(42)
        let v = rc.borrow()
        @Expect(v, 42)
        rc.release()
    }

    @TestCase
    public func test_boxed() {
        let b = Boxed(99)
        @Expect(b.get(), 99)
    }

    @TestCase
    public func test_cstring() {
        let cs = CJString("hello")
        @Expect(cs.get(), "hello")
        let bytes = cs.toBytes()
        @Expect(bytes[bytes.size - 1], 0u8)
    }

    @TestCase
    public func test_phantom() {
        let p = PhantomData<Int64>()
        @Expect(true)
    }

    @TestCase
    public func test_bound_enum() {
        let ub = BoundEnum<Int64>.Unbounded
        let incl = BoundEnum<Int64>.Included(42)
        let excl = BoundEnum<Int64>.Excluded(99)
        @Expect(true)
    }

    @TestCase
    public func test_cow_enum() {
        let b = CowEnum<Int64>.Borrowed(10)
        let o = CowEnum<Int64>.Owned(20)
        @Expect(true)
    }

    // === New NonZero types ===
    @TestCase
    public func test_nonzero_i8() { let nz = NonZeroI8(42i8); @Expect(nz.get(), 42i8) }
    @TestCase
    public func test_nonzero_i16() { let nz = NonZeroI16(42i16); @Expect(nz.get(), 42i16) }
    @TestCase
    public func test_nonzero_i32() { let nz = NonZeroI32(42i32); @Expect(nz.get(), 42i32) }
    @TestCase
    public func test_nonzero_i64() { let nz = NonZeroI64(42i64); @Expect(nz.get(), 42i64) }
    @TestCase
    public func test_nonzero_u128() { let nz = NonZeroU128(UInt128(1, 0)); @Expect(nz.get().to_u64(), 1u64) }
    @TestCase
    public func test_nonzero_usize() { let nz = NonZeroUsize(1u64); @Expect(nz.get(), 1u64) }

    // === SocketAddrV4/V6 ===
    @TestCase
    public func test_socket_addr_v4() {
        let sa = SocketAddrV4(IPv4Address(127, 0, 0, 1), 8080u16)
        @Expect(sa.get_ip().toString(), "127.0.0.1")
        @Expect(sa.get_port(), 8080u16)
    }

    @TestCase
    public func test_socket_addr_v6() {
        let sa = SocketAddrV6(IPv6Address(0, 0, 0, 0, 0, 0, 0, 1), 8080u16, 0u32, 0u32)
        @Expect(sa.get_port(), 8080u16)
    }

    // === Collection wrappers ===
    @TestCase
    public func test_binary_heap() {
        let bh = BinaryHeap<UInt8>()
        bh.add(3u8); bh.add(1u8); bh.add(2u8)
        @Expect(bh.size(), 3)
    }

    @TestCase
    public func test_vec_deque() {
        let vd = VecDeque<UInt8>()
        vd.add(1u8); vd.add(2u8)
        @Expect(vd.size(), 2)
    }

    @TestCase
    public func test_btree_map() {
        let m = BTreeMap<String, UInt8>()
        m.put("a", 1u8); m.put("b", 2u8)
        @Expect(m.size(), 2)
    }

    @TestCase
    public func test_btree_set() {
        let s = BTreeSet<UInt8>()
        s.add(1u8); s.add(2u8)
        @Expect(s.size(), 2)
    }

    // === BoxedStr/BoxedSlice ===
    @TestCase
    public func test_boxed_str() {
        let bs = BoxedStr("hello")
        @Expect(bs.get(), "hello")
    }

    @TestCase
    public func test_boxed_slice() {
        let bs = BoxedSlice<UInt8>([1u8, 2u8, 3u8])
        @Expect(bs.get().size, 3)
    }

    // === RefCounted/AtomicRefCounted ===
    @TestCase
    public func test_ref_counted() {
        let rc = RefCounted(42)
        @Expect(rc.get(), 42)
    }

    @TestCase
    public func test_atomic_ref_counted() {
        let arc = AtomicRefCounted(42)
        @Expect(arc.get(), 42)
    }

    @TestCase
    public func test_ref_counted_str() {
        let rcs = RefCountedStr("hello")
        @Expect(rcs.get(), "hello")
    }

    @TestCase
    public func test_atomic_ref_counted_str() {
        let acs = AtomicRefCountedStr("hello")
        @Expect(acs.get(), "hello")
    }

    // === SyncMutex / RwLock_ ===
    @TestCase
    public func test_sync_mutex() {
        let m = SyncMutex(42)
        let v = m.lock_and_get()
        @Expect(v, 42)
    }

    @TestCase
    public func test_rw_lock() {
        let rw = RwLock_(42)
        let v = rw.read()
        @Expect(v, 42)
        rw.read_release()
    }

    // === NonZero Encode/Decode roundtrip ===
    @TestCase
    public func test_nonzero_u8_encode_decode() {
        let buf = ArrayList<UInt8>(); NonZeroU8(42u8).encode(standard, buf)
        match (NonZeroU8.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_i8_encode_decode() {
        let buf = ArrayList<UInt8>(); NonZeroI8(42i8).encode(standard, buf)
        match (NonZeroI8.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 42i8)
            case _ => @Expect(false)
        }
    }

    // === Wrapping/Reverse/Cell/RefCell Encode/Decode roundtrip ===
    @TestCase
    public func test_wrapping_encode_decode() {
        let buf = ArrayList<UInt8>(); Wrapping<UInt8>(42u8).encode(standard, buf)
        match (Wrapping<UInt8>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_cell_encode_decode() {
        let buf = ArrayList<UInt8>(); Cell<UInt8>(42u8).encode(standard, buf)
        match (Cell<UInt8>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_cstring_encode_decode() {
        let buf = ArrayList<UInt8>(); CJString("hello").encode(standard, buf)
        match (CJString.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), "hello")
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_boxed_encode_decode() {
        let buf = ArrayList<UInt8>(); Boxed<UInt8>(42u8).encode(standard, buf)
        match (Boxed<UInt8>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_cow_enum_encode_decode() {
        let buf = ArrayList<UInt8>(); (CowEnum<UInt8>.Owned(42u8)).encode(standard, buf)
        match (CowEnum<UInt8>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_boxed_str_encode_decode() {
        let buf = ArrayList<UInt8>(); BoxedStr("hello").encode(standard, buf)
        match (BoxedStr.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), "hello")
            case _ => @Expect(false)
        }
    }

    // === Additional Encode/Decode roundtrip tests ===
    @TestCase
    public func test_reverse_encode_decode() {
        let buf = ArrayList<UInt8>(); Reverse<UInt8>(42u8).encode(standard, buf)
        match (Reverse<UInt8>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_refcell_encode_decode() {
        let buf = ArrayList<UInt8>(); RefCell<UInt8>(42u8).encode(standard, buf)
        match (RefCell<UInt8>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.into_inner(), 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_ref_counted_encode_decode() {
        let buf = ArrayList<UInt8>(); RefCounted<UInt8>(42u8).encode(standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_sync_mutex_encode_decode() {
        let buf = ArrayList<UInt8>(); SyncMutex<UInt8>(42u8).encode(standard, buf)
        match (SyncMutex<UInt8>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.lock_and_get(), 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_rw_lock_encode_decode() {
        let buf = ArrayList<UInt8>(); RwLock_<UInt8>(42u8).encode(standard, buf)
        match (RwLock_<UInt8>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.into_inner(), 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_cow_enum_borrowed_encode() {
        let buf = ArrayList<UInt8>(); (CowEnum<UInt8>.Borrowed(42u8)).encode(standard, buf)
        match (CowEnum<UInt8>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_u16_encode_decode() {
        let buf = ArrayList<UInt8>(); NonZeroU16(100u16).encode(standard, buf)
        match (NonZeroU16.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 100u16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_u32_encode_decode() {
        let buf = ArrayList<UInt8>(); NonZeroU32(100u32).encode(standard, buf)
        match (NonZeroU32.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 100u32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_u64_encode_decode() {
        let buf = ArrayList<UInt8>(); NonZeroU64(100u64).encode(standard, buf)
        match (NonZeroU64.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 100u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_usize_isize() {
        let u: Usize = 42u64
        let i: Isize = -42i64
        @Expect(u, 42u64)
        @Expect(i, -42i64)
    }

    // === Builtin method tests ===
    @TestCase
    public func test_ref_counted_clone_drop() {
        let rc = RefCounted(42)
        let cloned = rc.clone()
        @Expect(rc.ref_count(), 2)
        cloned.drop()
        @Expect(rc.ref_count(), 1)
    }

    @TestCase
    public func test_atomic_ref_counted_clone_drop() {
        let arc = AtomicRefCounted(42)
        let cloned = arc.clone()
        @Expect(arc.ref_count(), 2)
        cloned.drop()
        @Expect(arc.ref_count(), 1)
    }

    @TestCase
    public func test_sync_mutex_lock_and_set() {
        let m = SyncMutex(42)
        m.lock_and_set(100)
        @Expect(m.lock_and_get(), 100)
    }

    @TestCase
    public func test_sync_mutex_lock_and_replace() {
        let m = SyncMutex(42)
        let old = m.lock_and_replace(100)
        @Expect(old, 42)
        @Expect(m.lock_and_get(), 100)
    }

    @TestCase
    public func test_refcell_try_borrow() {
        let rc = RefCell(42)
        match (rc.try_borrow()) {
            case Option.Some(v) => @Expect(v, 42)
            case _ => @Expect(false)
        }
        rc.release()
    }

    @TestCase
    public func test_refcell_borrow_mut() {
        let rc = RefCell(42)
        let v = rc.borrow_mut()
        @Expect(v, 42)
        rc.release()
    }

    @TestCase
    public func test_refcell_try_borrow_mut() {
        let rc = RefCell(42)
        match (rc.try_borrow_mut()) {
            case Option.Some(v) => @Expect(v, 42)
            case _ => @Expect(false)
        }
        rc.release()
    }

    @TestCase
    public func test_rw_lock_try_read() {
        let rw = RwLock_(42)
        match (rw.try_read()) {
            case Option.Some(v) => @Expect(v, 42)
            case _ => @Expect(false)
        }
        rw.read_release()
    }

    @TestCase
    public func test_rw_lock_write() {
        let rw = RwLock_(42)
        let v = rw.write()
        @Expect(v, 42)
        rw.write_release()
    }

    @TestCase
    public func test_rw_lock_try_write() {
        let rw = RwLock_(42)
        match (rw.try_write()) {
            case Option.Some(v) => @Expect(v, 42)
            case _ => @Expect(false)
        }
        rw.write_release()
    }

    @TestCase
    public func test_cstring_from_bytes() {
        let bytes: Array<UInt8> = [104u8, 101u8, 108u8, 108u8, 111u8]
        let cs = CJString.fromBytes(bytes)
        @Expect(cs.get(), "hello")
    }

    @TestCase
    public func test_boxed_set() {
        let b = Boxed(42)
        b.set(100)
        @Expect(b.get(), 100)
    }

    @TestCase
    public func test_boxed_as_ref() {
        let b = Boxed(42)
        @Expect(b.as_ref(), 42)
    }

    // === NonZero additional Encode/Decode roundtrip tests ===
    @TestCase
    public func test_nonzero_i16_encode_decode() {
        let buf = ArrayList<UInt8>(); NonZeroI16(42i16).encode(standard, buf)
        match (NonZeroI16.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 42i16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_i32_encode_decode() {
        let buf = ArrayList<UInt8>(); NonZeroI32(42i32).encode(standard, buf)
        match (NonZeroI32.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 42i32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_i64_encode_decode() {
        let buf = ArrayList<UInt8>(); NonZeroI64(42i64).encode(standard, buf)
        match (NonZeroI64.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 42i64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_u128_encode_decode() {
        let buf = ArrayList<UInt8>(); NonZeroU128(UInt128(1, 0)).encode(standard, buf)
        match (NonZeroU128.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get().to_u64(), 1u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_usize_encode_decode() {
        let buf = ArrayList<UInt8>(); NonZeroUsize(1u64).encode(standard, buf)
        match (NonZeroUsize.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 1u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_uint128_encode_decode() {
        let buf = ArrayList<UInt8>(); UInt128(42, 0).encode(standard, buf)
        match (UInt128.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.to_u64(), 42u64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_atomic_ref_counted_encode_decode() {
        let buf = ArrayList<UInt8>(); AtomicRefCounted<UInt8>(42u8).encode(standard, buf)
        match (AtomicRefCounted<UInt8>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_ref_counted_str_encode_decode() {
        let buf = ArrayList<UInt8>(); RefCountedStr("hello").encode(standard, buf)
        match (RefCountedStr.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), "hello")
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_atomic_ref_counted_str_encode_decode() {
        let buf = ArrayList<UInt8>(); AtomicRefCountedStr("hello").encode(standard, buf)
        match (AtomicRefCountedStr.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get(), "hello")
            case _ => @Expect(false)
        }
    }
}