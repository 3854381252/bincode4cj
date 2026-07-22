// builtins_branch_test.cj - 分支覆盖测试：builtins.cj / config.cj / conv.cj / serde_compat.cj / lib.cj
package bincode4cj.test
import std.collection.*
import std.sync.*
import std.net.*
import std.io.*
import std.unittest.*
import bincode4cj.{ standard, legacy, Config, Endianness, IntEncoding,
    BigEndian, LittleEndian, Fixint, Varint, NoLimit,
    MyResult, DecodeError, EncodeError, Encode, Decode,
    BinaryHeap, VecDeque, BTreeMap, BTreeSet, BoxedSlice,
    Boxed, RefCounted, AtomicRefCounted, CowEnum, BoundEnum,
    SyncMutex, RwLock_, Cell, RefCell, Wrapping, Reverse,
    NonZeroU8, NonZeroU16, NonZeroU32, NonZeroU64,
    NonZeroI8, NonZeroI16, NonZeroI32, NonZeroI64,
    NonZeroU128, NonZeroUsize, NonZeroI128, NonZeroIsize,
    PhantomData, SocketAddrV4, SocketAddrV6,
    BoxedStr, RefCountedStr, AtomicRefCountedStr,
    UInt128, Int128, Serialize, Deserialize, Compat, BorrowCompat,
    SystemTime_, CString as CJString,
    encode_into_slice, encode_into_writer, encode_to_vec,
    encode_into_std_write, decode_from_slice, decode_from_reader,
    decode_from_std_read, decode_from_slice_with_context,
    decode_from_reader_with_context, VecWriter, SizeWriter,
    is_varint, is_little_endian, combine_u8_u16, combine_u8_u32, combine_u8_u64,
    zigzag_decode_helper_u16, zigzag_decode_helper_u32, zigzag_decode_helper_u64,
    encode_u8, decode_u8, encode_u16, decode_u16, encode_string, decode_string,
    IoReader, IoWriter }

// === 辅助类型：用于 serde_compat 测试 ===
class SerdeTestType <: Serialize {
    var val: UInt8
    public init(val: UInt8) { this.val = val }
    public func serialize(config: Config, buf: ArrayList<UInt8>): Unit {
        buf.add(this.val)
    }
}
extend SerdeTestType <: Deserialize<SerdeTestType> {
    public static func deserialize(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(SerdeTestType, Int64), DecodeError> {
        if (pos >= data.size) { MyResult.Err(DecodeError.UnexpectedEnd(1)) }
        else { MyResult.Ok((SerdeTestType(data[pos]), pos + 1)) }
    }
}

// ============================================================
// 1. builtins.cj 分支覆盖
// ============================================================

@Test
public class BuiltinsBranchTests {

    // --- NonZero 构造器零值异常分支 ---
    @TestCase
    public func test_nonzero_u8_zero_throws() {
        try { NonZeroU8(0u8); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }
    @TestCase
    public func test_nonzero_u16_zero_throws() {
        try { NonZeroU16(0u16); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }
    @TestCase
    public func test_nonzero_u32_zero_throws() {
        try { NonZeroU32(0u32); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }
    @TestCase
    public func test_nonzero_u64_zero_throws() {
        try { NonZeroU64(0u64); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }
    @TestCase
    public func test_nonzero_i8_zero_throws() {
        try { NonZeroI8(0i8); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }
    @TestCase
    public func test_nonzero_i16_zero_throws() {
        try { NonZeroI16(0i16); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }
    @TestCase
    public func test_nonzero_i32_zero_throws() {
        try { NonZeroI32(0i32); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }
    @TestCase
    public func test_nonzero_i64_zero_throws() {
        try { NonZeroI64(0i64); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }
    @TestCase
    public func test_nonzero_u128_zero_throws() {
        try { NonZeroU128(UInt128(0, 0)); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }
    @TestCase
    public func test_nonzero_i128_zero_throws() {
        try { NonZeroI128(Int128(0, 0)); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }
    @TestCase
    public func test_nonzero_usize_zero_throws() {
        try { NonZeroUsize(0u64); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }
    @TestCase
    public func test_nonzero_isize_zero_throws() {
        try { NonZeroIsize(0i64); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }

    // --- NonZeroI128 / NonZeroIsize 正常值 ---
    @TestCase
    public func test_nonzero_i128_get() {
        let nz = NonZeroI128(Int128(42, 0))
        @Expect(nz.get().lo, 42u64)
    }
    @TestCase
    public func test_nonzero_isize_get() {
        let nz = NonZeroIsize(42)
        @Expect(nz.get(), 42)
    }
    @TestCase
    public func test_nonzero_i128_negative() {
        let nz = NonZeroI128(Int128(0xFFFFFFFFFFFFFFFFu64, -1))
        @Expect(nz.get().hi, -1)
    }
    @TestCase
    public func test_nonzero_isize_negative() {
        let nz = NonZeroIsize(-42)
        @Expect(nz.get(), -42)
    }

    // --- BinaryHeap init(inner) / get_inner() ---
    @TestCase
    public func test_binary_heap_init_inner() {
        let list = ArrayList<UInt8>([1u8, 2u8, 3u8])
        let bh = BinaryHeap<UInt8>(list)
        @Expect(bh.size(), 3)
        @Expect(bh.get_inner().size, 3)
    }
    @TestCase
    public func test_binary_heap_get_inner() {
        let bh = BinaryHeap<UInt8>()
        bh.add(10u8)
        let inner = bh.get_inner()
        @Expect(inner[0], 10u8)
    }

    // --- VecDeque init(inner) / get_inner() ---
    @TestCase
    public func test_vec_deque_init_inner() {
        let list = ArrayList<UInt8>([1u8, 2u8])
        let vd = VecDeque<UInt8>(list)
        @Expect(vd.size(), 2)
        @Expect(vd.get_inner().size, 2)
    }
    @TestCase
    public func test_vec_deque_get_inner() {
        let vd = VecDeque<UInt8>()
        vd.add(5u8)
        let inner = vd.get_inner()
        @Expect(inner[0], 5u8)
    }

    // --- BTreeMap init(inner) / get_inner() ---
    @TestCase
    public func test_btree_map_init_inner() {
        let m0 = HashMap<String, UInt8>()
        m0.add("a", 1u8)
        let m = BTreeMap<String, UInt8>(m0)
        @Expect(m.size(), 1)
        @Expect(m.get_inner().size, 1)
    }
    @TestCase
    public func test_btree_map_get_inner() {
        let m = BTreeMap<String, UInt8>()
        m.put("x", 9u8)
        let inner = m.get_inner()
        @Expect(inner.size, 1)
    }

    // --- BTreeSet init(inner) / get_inner() ---
    @TestCase
    public func test_btree_set_init_inner() {
        let s0 = HashSet<UInt8>()
        s0.add(1u8)
        let s = BTreeSet<UInt8>(s0)
        @Expect(s.size(), 1)
        @Expect(s.get_inner().size, 1)
    }
    @TestCase
    public func test_btree_set_get_inner() {
        let s = BTreeSet<UInt8>()
        s.add(7u8)
        let inner = s.get_inner()
        @Expect(inner.size, 1)
    }

    // --- SocketAddrV6 全方法 ---
    @TestCase
    public func test_socket_addr_v6_full() {
        let ip = IPv6Address(0x2001u16, 0x0db8u16, 0, 0, 0, 0, 0, 1u16)
        let sa = SocketAddrV6(ip, 443u16, 0x12345u32, 0x67u32)
        @Expect(sa.get_port(), 443u16)
        @Expect(sa.get_flow_info(), 0x12345u32)
        @Expect(sa.get_scope_id(), 0x67u32)
    }
    @TestCase
    public func test_socket_addr_v6_get_ip() {
        let ip = IPv6Address(0, 0, 0, 0, 0, 0, 0, 1u16)
        let sa = SocketAddrV6(ip, 8080u16, 0u32, 0u32)
        @Expect(sa.get_ip().toString().contains("1"), true)
    }

    // --- RefCountedStr clone / drop ---
    @TestCase
    public func test_ref_counted_str_clone_drop() {
        let rcs = RefCountedStr("hello")
        let cloned = rcs.clone()
        @Expect(rcs.get(), "hello")
        cloned.drop()
        @Expect(rcs.get(), "hello")
    }

    // --- AtomicRefCountedStr clone / drop ---
    @TestCase
    public func test_atomic_ref_counted_str_clone_drop() {
        let acs = AtomicRefCountedStr("world")
        let cloned = acs.clone()
        @Expect(acs.get(), "world")
        cloned.drop()
        @Expect(acs.get(), "world")
    }

    // --- BoundEnum match 提取 ---
    @TestCase
    public func test_bound_enum_match_unbounded() {
        let b = BoundEnum<Int64>.Unbounded
        match (b) {
            case BoundEnum.Unbounded => @Expect(true)
            case _ => @Expect(false)
        }
    }
    @TestCase
    public func test_bound_enum_match_included() {
        let b = BoundEnum<Int64>.Included(42)
        match (b) {
            case BoundEnum.Included(v) => @Expect(v, 42)
            case _ => @Expect(false)
        }
    }
    @TestCase
    public func test_bound_enum_match_excluded() {
        let b = BoundEnum<Int64>.Excluded(99)
        match (b) {
            case BoundEnum.Excluded(v) => @Expect(v, 99)
            case _ => @Expect(false)
        }
    }

    // --- CowEnum match 提取 ---
    @TestCase
    public func test_cow_enum_match_borrowed() {
        let c = CowEnum<String>.Borrowed("borrowed")
        match (c) {
            case CowEnum.Borrowed(v) => @Expect(v, "borrowed")
            case _ => @Expect(false)
        }
    }
    @TestCase
    public func test_cow_enum_match_owned() {
        let c = CowEnum<String>.Owned("owned")
        match (c) {
            case CowEnum.Owned(v) => @Expect(v, "owned")
            case _ => @Expect(false)
        }
    }

    // --- SystemTime_ ---
    @TestCase
    public func test_system_time_create() {
        let st = SystemTime_(100u64, 500u32)
        @Expect(st.get_secs(), 100u64)
        @Expect(st.get_nanos(), 500u32)
    }
    @TestCase
    public func test_system_time_encode_decode() {
        let buf = ArrayList<UInt8>()
        SystemTime_(1000u64, 200u32).encode(standard, buf)
        match (SystemTime_.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get_secs(), 1000u64); @Expect(v.get_nanos(), 200u32)
            case _ => @Expect(false)
        }
    }

    // --- BoxedSlice encode/decode ---
    @TestCase
    public func test_boxed_slice_encode_decode() {
        let buf = ArrayList<UInt8>()
        BoxedSlice<UInt8>([1u8, 2u8, 3u8]).encode(standard, buf)
        match (BoxedSlice<UInt8>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, _)) => @Expect(v.get().size, 3); @Expect(v.get()[0], 1u8)
            case _ => @Expect(false)
        }
    }

    // --- RefCell 异常分支 ---
    @TestCase
    public func test_refcell_borrow_mut_throws_when_borrowed() {
        let rc = RefCell(42)
        rc.borrow()
        try { rc.borrow_mut(); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
        rc.release()
    }
    @TestCase
    public func test_refcell_try_borrow_none_when_mut_borrowed() {
        let rc = RefCell(42)
        rc.borrow_mut()
        match (rc.try_borrow()) {
            case Option.None => @Expect(true)
            case _ => @Expect(false)
        }
        rc.release()
    }
    @TestCase
    public func test_refcell_try_borrow_mut_none_when_borrowed() {
        let rc = RefCell(42)
        rc.borrow()
        match (rc.try_borrow_mut()) {
            case Option.None => @Expect(true)
            case _ => @Expect(false)
        }
        rc.release()
    }
    @TestCase
    public func test_refcell_into_inner() {
        let rc = RefCell(42)
        @Expect(rc.into_inner(), 42)
    }
    @TestCase
    public func test_refcell_release_no_op() {
        let rc = RefCell(42)
        rc.release()
        @Expect(rc.into_inner(), 42)
    }

    // --- RwLock_ 分支 ---
    @TestCase
    public func test_rw_lock_into_inner() {
        let rw = RwLock_(42)
        @Expect(rw.into_inner(), 42)
    }
    @TestCase
    public func test_rw_lock_try_read_none_when_writer() {
        let rw = RwLock_(42)
        rw.write()
        match (rw.try_read()) {
            case Option.None => @Expect(true)
            case _ => @Expect(false)
        }
        rw.write_release()
    }
    @TestCase
    public func test_rw_lock_try_write_none_when_reader() {
        let rw = RwLock_(42)
        rw.read()
        match (rw.try_write()) {
            case Option.None => @Expect(true)
            case _ => @Expect(false)
        }
        rw.read_release()
    }

    // --- CString 异常分支 ---
    @TestCase
    public func test_cstring_null_byte_throws() {
        try { CJString(String.fromUtf8([104u8, 0u8, 108u8])); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }
    @TestCase
    public func test_cstring_from_bytes_null_throws() {
        try { CJString.fromBytes([104u8, 0u8, 108u8]); @Expect(false) }
        catch (_: Exception) { @Expect(true) }
    }

    // --- Boxed set / as_ref ---
    @TestCase
    public func test_boxed_set_as_ref() {
        let b = Boxed(10)
        b.set(20)
        @Expect(b.as_ref(), 20)
        @Expect(b.get(), 20)
    }

    // --- Cell replace ---
    @TestCase
    public func test_cell_replace() {
        let c = Cell(10)
        let old = c.replace(20)
        @Expect(old, 10)
        @Expect(c.get(), 20)
    }

    // --- PhantomData ---
    @TestCase
    public func test_phantom_data_init() {
        let p = PhantomData<String>()
        @Expect(true)
    }

    // --- Wrapping / Reverse with different types ---
    @TestCase
    public func test_wrapping_int64() {
        let w = Wrapping<Int64>(-1)
        @Expect(w.get(), -1)
    }
    @TestCase
    public func test_reverse_int32() {
        let r = Reverse<Int32>(-100i32)
        @Expect(r.get(), -100i32)
    }

    // --- RefCounted clone / drop / ref_count ---
    @TestCase
    public func test_ref_counted_ref_count() {
        let rc = RefCounted(42)
        @Expect(rc.ref_count(), 1)
        let c1 = rc.clone()
        @Expect(rc.ref_count(), 2)
        c1.drop()
        @Expect(rc.ref_count(), 1)
    }

    // --- AtomicRefCounted clone / drop / ref_count ---
    @TestCase
    public func test_atomic_ref_counted_ref_count() {
        let arc = AtomicRefCounted(42)
        @Expect(arc.ref_count(), 1)
        let c1 = arc.clone()
        @Expect(arc.ref_count(), 2)
        c1.drop()
        @Expect(arc.ref_count(), 1)
    }

    // --- SyncMutex lock_and_set / lock_and_replace ---
    @TestCase
    public func test_sync_mutex_lock_and_set() {
        let m = SyncMutex(42)
        m.lock_and_set(99)
        @Expect(m.lock_and_get(), 99)
    }
    @TestCase
    public func test_sync_mutex_lock_and_replace() {
        let m = SyncMutex(42)
        let old = m.lock_and_replace(100)
        @Expect(old, 42)
        @Expect(m.lock_and_get(), 100)
    }

    // --- NonZeroU8/U16/U32/U64 get ---
    @TestCase
    public func test_nonzero_u8_get() { @Expect(NonZeroU8(1u8).get(), 1u8) }
    @TestCase
    public func test_nonzero_u16_get() { @Expect(NonZeroU16(1u16).get(), 1u16) }
    @TestCase
    public func test_nonzero_u32_get() { @Expect(NonZeroU32(1u32).get(), 1u32) }
    @TestCase
    public func test_nonzero_u64_get() { @Expect(NonZeroU64(1u64).get(), 1u64) }
    @TestCase
    public func test_nonzero_i8_get() { @Expect(NonZeroI8(1i8).get(), 1i8) }
    @TestCase
    public func test_nonzero_i16_get() { @Expect(NonZeroI16(1i16).get(), 1i16) }
    @TestCase
    public func test_nonzero_i32_get() { @Expect(NonZeroI32(1i32).get(), 1i32) }
    @TestCase
    public func test_nonzero_i64_get() { @Expect(NonZeroI64(1i64).get(), 1i64) }
    @TestCase
    public func test_nonzero_u128_get() { @Expect(NonZeroU128(UInt128(1, 0)).get().lo, 1u64) }
    @TestCase
    public func test_nonzero_usize_get() { @Expect(NonZeroUsize(1u64).get(), 1u64) }

    // --- SocketAddrV4 ---
    @TestCase
    public func test_socket_addr_v4_full() {
        let sa = SocketAddrV4(IPv4Address(192, 168, 1, 1), 80u16)
        @Expect(sa.get_ip().toString(), "192.168.1.1")
        @Expect(sa.get_port(), 80u16)
    }
}

// ============================================================
// 2. config.cj 分支覆盖
// ============================================================

@Test
public class ConfigBranchTests {

    // --- Configuration 链式调用 ---
    @TestCase
    public func test_chain_big_endian() {
        let c = standard.with_big_endian()
        @Expect(c.endianness(), Endianness.Big)
        @Expect(c.int_encoding(), IntEncoding.Variable)
    }
    @TestCase
    public func test_chain_little_endian() {
        let c = standard.with_little_endian()
        @Expect(c.endianness(), Endianness.Little)
    }
    @TestCase
    public func test_chain_variable_int() {
        let c = legacy.with_variable_int_encoding()
        @Expect(c.int_encoding(), IntEncoding.Variable)
    }
    @TestCase
    public func test_chain_fixed_int() {
        let c = standard.with_fixed_int_encoding()
        @Expect(c.int_encoding(), IntEncoding.Fixed)
    }
    @TestCase
    public func test_chain_no_limit() {
        let c = standard.with_no_limit()
        @Expect(c.limit(), Option<Int64>.None)
    }
    @TestCase
    public func test_chain_big_then_little() {
        let c = standard.with_big_endian().with_little_endian()
        @Expect(c.endianness(), Endianness.Little)
    }
    @TestCase
    public func test_chain_fixed_then_variable() {
        let c = standard.with_fixed_int_encoding().with_variable_int_encoding()
        @Expect(c.int_encoding(), IntEncoding.Variable)
    }
    @TestCase
    public func test_chain_all() {
        let c = standard.with_big_endian().with_fixed_int_encoding().with_no_limit()
        @Expect(c.endianness(), Endianness.Big)
        @Expect(c.int_encoding(), IntEncoding.Fixed)
        @Expect(c.limit(), Option<Int64>.None)
    }

    // --- 标记类型静态方法 ---
    @TestCase
    public func test_big_endian_static() {
        @Expect(BigEndian.endianness(), Endianness.Big)
    }
    @TestCase
    public func test_little_endian_static() {
        @Expect(LittleEndian.endianness(), Endianness.Little)
    }
    @TestCase
    public func test_fixint_static() {
        @Expect(Fixint.int_encoding(), IntEncoding.Fixed)
    }
    @TestCase
    public func test_varint_static() {
        @Expect(Varint.int_encoding(), IntEncoding.Variable)
    }
    @TestCase
    public func test_no_limit_static() {
        @Expect(NoLimit.limit(), Option<Int64>.None)
    }

    // --- standard / legacy 配置值验证 ---
    @TestCase
    public func test_standard_all_values() {
        @Expect(standard.endianness(), Endianness.Little)
        @Expect(standard.int_encoding(), IntEncoding.Variable)
        @Expect(standard.limit(), Option<Int64>.None)
    }
    @TestCase
    public func test_legacy_all_values() {
        @Expect(legacy.endianness(), Endianness.Little)
        @Expect(legacy.int_encoding(), IntEncoding.Fixed)
        @Expect(legacy.limit(), Option<Int64>.None)
    }

    // --- Endianness / IntEncoding 相等性 ---
    @TestCase
    public func test_endianness_equality() {
        @Expect(Endianness.Big == Endianness.Big, true)
        @Expect(Endianness.Little == Endianness.Little, true)
        @Expect(Endianness.Big == Endianness.Little, false)
    }
    @TestCase
    public func test_int_encoding_equality() {
        @Expect(IntEncoding.Fixed == IntEncoding.Fixed, true)
        @Expect(IntEncoding.Variable == IntEncoding.Variable, true)
        @Expect(IntEncoding.Fixed == IntEncoding.Variable, false)
    }

    // --- is_varint / is_little_endian ---
    @TestCase
    public func test_is_varint_standard() {
        @Expect(is_varint(standard), true)
    }
    @TestCase
    public func test_is_varint_legacy() {
        @Expect(is_varint(legacy), false)
    }
    @TestCase
    public func test_is_little_endian_standard() {
        @Expect(is_little_endian(standard), true)
    }
    @TestCase
    public func test_is_little_endian_big() {
        let c = standard.with_big_endian()
        @Expect(is_little_endian(c), false)
    }
}

// ============================================================
// 3. conv.cj 分支覆盖
// ============================================================

@Test
public class ConvBranchTests {

    // --- combine_u8_u16 边界值 ---
    @TestCase
    public func test_combine_u8_u16_zeros() {
        @Expect(combine_u8_u16(0u8, 0u8), 0u16)
    }
    @TestCase
    public func test_combine_u8_u16_max() {
        @Expect(combine_u8_u16(255u8, 255u8), 0xFFFFu16)
    }
    @TestCase
    public func test_combine_u8_u16_lo_only() {
        @Expect(combine_u8_u16(0xABu8, 0u8), 0x00ABu16)
    }
    @TestCase
    public func test_combine_u8_u16_hi_only() {
        @Expect(combine_u8_u16(0u8, 0xCDu8), 0xCD00u16)
    }

    // --- combine_u8_u32 边界值 ---
    @TestCase
    public func test_combine_u8_u32_zeros() {
        @Expect(combine_u8_u32(0u8, 0u8, 0u8, 0u8), 0u32)
    }
    @TestCase
    public func test_combine_u8_u32_max() {
        @Expect(combine_u8_u32(255u8, 255u8, 255u8, 255u8), 0xFFFFFFFFu32)
    }
    @TestCase
    public func test_combine_u8_u32_partial() {
        @Expect(combine_u8_u32(0x78u8, 0u8, 0u8, 0u8), 0x00000078u32)
    }
    @TestCase
    public func test_combine_u8_u32_mixed() {
        @Expect(combine_u8_u32(0x78u8, 0x56u8, 0u8, 0x12u8), 0x12005678u32)
    }

    // --- combine_u8_u64 边界值 ---
    @TestCase
    public func test_combine_u8_u64_zeros() {
        @Expect(combine_u8_u64(0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8), 0u64)
    }
    @TestCase
    public func test_combine_u8_u64_max() {
        @Expect(combine_u8_u64(255u8, 255u8, 255u8, 255u8, 255u8, 255u8, 255u8, 255u8), 0xFFFFFFFFFFFFFFFFu64)
    }
    @TestCase
    public func test_combine_u8_u64_lo_only() {
        @Expect(combine_u8_u64(0x42u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8), 0x42u64)
    }
    @TestCase
    public func test_combine_u8_u64_hi_only() {
        @Expect(combine_u8_u64(0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0xFFu8), 0xFF00000000000000u64)
    }

    // --- zigzag_decode_helper_u16 边界值 ---
    @TestCase
    public func test_zigzag_u16_zero() {
        @Expect(zigzag_decode_helper_u16(0u16), 0i16)
    }
    @TestCase
    public func test_zigzag_u16_even() {
        @Expect(zigzag_decode_helper_u16(2u16), 1i16)
    }
    @TestCase
    public func test_zigzag_u16_odd() {
        @Expect(zigzag_decode_helper_u16(1u16), -1i16)
    }
    @TestCase
    public func test_zigzag_u16_max() {
        @Expect(zigzag_decode_helper_u16(0xFFFFu16), -32768i16)
    }
    @TestCase
    public func test_zigzag_u16_neg2() {
        @Expect(zigzag_decode_helper_u16(3u16), -2i16)
    }

    // --- zigzag_decode_helper_u32 边界值 ---
    @TestCase
    public func test_zigzag_u32_zero() {
        @Expect(zigzag_decode_helper_u32(0u32), 0i32)
    }
    @TestCase
    public func test_zigzag_u32_even() {
        @Expect(zigzag_decode_helper_u32(2u32), 1i32)
    }
    @TestCase
    public func test_zigzag_u32_odd() {
        @Expect(zigzag_decode_helper_u32(1u32), -1i32)
    }
    @TestCase
    public func test_zigzag_u32_large() {
        @Expect(zigzag_decode_helper_u32(0xFFFFFFFEu32), 0x7FFFFFFFi32)
    }

    // --- zigzag_decode_helper_u64 边界值 ---
    @TestCase
    public func test_zigzag_u64_zero() {
        @Expect(zigzag_decode_helper_u64(0u64), 0i64)
    }
    @TestCase
    public func test_zigzag_u64_even() {
        @Expect(zigzag_decode_helper_u64(2u64), 1i64)
    }
    @TestCase
    public func test_zigzag_u64_odd() {
        @Expect(zigzag_decode_helper_u64(1u64), -1i64)
    }
    @TestCase
    public func test_zigzag_u64_large() {
        @Expect(zigzag_decode_helper_u64(0xFFFFFFFFFFFFFFFEu64), 0x7FFFFFFFFFFFFFFFi64)
    }
}

// ============================================================
// 4. serde_compat.cj 分支覆盖
// ============================================================

@Test
public class SerdeCompatBranchTests {

    // --- Compat encode ---
    @TestCase
    public func test_compat_encode_value() {
        let inner = SerdeTestType(42u8)
        let compat = Compat(inner)
        let buf = ArrayList<UInt8>()
        compat.encode(standard, buf)
        @Expect(buf.size, 1)
        @Expect(buf[0], 42u8)
    }

    // --- Compat encode + decode 往返 ---
    @TestCase
    public func test_compat_roundtrip() {
        let compat = Compat(SerdeTestType(99u8))
        let buf = ArrayList<UInt8>()
        compat.encode(standard, buf)
        match (Compat<SerdeTestType>.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((v, p)) => @Expect(v.inner.val, 99u8); @Expect(p, 1)
            case _ => @Expect(false)
        }
    }

    // --- Compat decode Err 路径 ---
    @TestCase
    public func test_compat_decode_err() {
        let data: Array<UInt8> = []
        match (Compat<SerdeTestType>.decode(data, 0, standard)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- BorrowCompat 创建 ---
    @TestCase
    public func test_borrow_compat_create() {
        let bc = BorrowCompat(SerdeTestType(42u8))
        @Expect(true)
    }

    // --- Compat with different value ---
    @TestCase
    public func test_compat_encode_zero() {
        let compat = Compat(SerdeTestType(0u8))
        let buf = ArrayList<UInt8>()
        compat.encode(standard, buf)
        @Expect(buf[0], 0u8)
    }

    // --- Compat decode with valid data at non-zero pos ---
    @TestCase
    public func test_compat_decode_at_pos() {
        let data: Array<UInt8> = [0u8, 0u8, 55u8]
        match (Compat<SerdeTestType>.decode(data, 2, standard)) {
            case MyResult.Ok((v, p)) => @Expect(v.inner.val, 55u8); @Expect(p, 3)
            case _ => @Expect(false)
        }
    }
}

// ============================================================
// 5. lib.cj 分支覆盖
// ============================================================

@Test
public class LibBranchTests {

    // --- encode_into_slice 返回值 ---
    @TestCase
    public func test_encode_into_slice_return() {
        let buf = ArrayList<UInt8>()
        let n = encode_into_slice(42u8, standard, buf)
        @Expect(n, 1)
        @Expect(buf.size, 1)
    }
    @TestCase
    public func test_encode_into_slice_u16() {
        let buf = ArrayList<UInt8>()
        let n = encode_into_slice(256u16, standard, buf)
        @Expect(n > 0, true)
        @Expect(buf.size, n)
    }

    // --- encode_into_writer 返回值 ---
    @TestCase
    public func test_encode_into_writer_return() {
        let writer = VecWriter()
        let n = encode_into_writer(42u8, standard, writer)
        @Expect(n > 0, true)
        @Expect(writer.collect().size, n)
    }
    @TestCase
    public func test_encode_into_writer_multiple() {
        let writer = VecWriter()
        let n1 = encode_into_writer(1u8, standard, writer)
        let n2 = encode_into_writer(2u8, standard, writer)
        @Expect(n2, n1 + 1)
        @Expect(writer.collect().size, n2)
    }

    // --- encode_into_std_write 测试 ---
    @TestCase
    public func test_encode_into_std_write_return() {
        let buf = ByteBuffer()
        let n = encode_into_std_write(42u8, standard, buf)
        @Expect(n, 1)
        @Expect(buf.length, 1)
    }
    @TestCase
    public func test_encode_into_std_write_u16() {
        let buf = ByteBuffer()
        let n = encode_into_std_write(300u16, standard, buf)
        @Expect(n > 0, true)
        @Expect(buf.length, n)
    }

    // --- decode_from_slice 返回值 ---
    @TestCase
    public func test_decode_from_slice_return() {
        let buf = ArrayList<UInt8>(); buf.add(42u8)
        match (decode_from_slice<UInt8>(buf.toArray(), standard)) {
            case MyResult.Ok((val, pos)) => @Expect(val, 42u8); @Expect(pos, 1)
            case _ => @Expect(false)
        }
    }

    // --- decode_from_reader 返回值 ---
    @TestCase
    public func test_decode_from_reader_return() {
        let buf = ArrayList<UInt8>(); buf.add(42u8)
        match (decode_from_reader<UInt8>(buf.toArray(), standard)) {
            case MyResult.Ok(val) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }

    // --- decode_from_std_read 测试 ---
    @TestCase
    public func test_decode_from_std_read_ok() {
        let data = Array<Byte>(1, {_ => 42u8})
        let stream = ByteBuffer(data)
        match (decode_from_std_read<UInt8>(stream, standard)) {
            case MyResult.Ok(val) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }
    @TestCase
    public func test_decode_from_std_read_multi_byte() {
        let buf = ArrayList<UInt8>()
        encode_u8(1u8, standard, buf)
        encode_u8(2u8, standard, buf)
        let data = Array<Byte>(buf.size, { i => buf[i] })
        let stream = ByteBuffer(data)
        match (decode_from_std_read<UInt8>(stream, standard)) {
            case MyResult.Ok(val) => @Expect(val, 1u8)
            case _ => @Expect(false)
        }
    }
    @TestCase
    public func test_decode_from_std_read_empty() {
        let data: Array<Byte> = []
        let stream = ByteBuffer(data)
        match (decode_from_std_read<UInt8>(stream, standard)) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_from_slice_with_context (Context 被忽略) ---
    @TestCase
    public func test_decode_from_slice_with_context_ok() {
        let buf = ArrayList<UInt8>(); buf.add(42u8)
        match (decode_from_slice_with_context<UInt8, Int64>(buf.toArray(), standard, 0)) {
            case MyResult.Ok((val, _)) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }
    @TestCase
    public func test_decode_from_slice_with_context_err() {
        let data: Array<UInt8> = []
        match (decode_from_slice_with_context<UInt8, String>(data, standard, "ctx")) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- decode_from_reader_with_context (Context 被忽略) ---
    @TestCase
    public func test_decode_from_reader_with_context_ok() {
        let buf = ArrayList<UInt8>(); buf.add(42u8)
        match (decode_from_reader_with_context<UInt8, Int64>(buf.toArray(), standard, 0)) {
            case MyResult.Ok(val) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }
    @TestCase
    public func test_decode_from_reader_with_context_err() {
        let data: Array<UInt8> = []
        match (decode_from_reader_with_context<UInt8, String>(data, standard, "ctx")) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    // --- encode_to_vec 往返 ---
    @TestCase
    public func test_encode_to_vec_roundtrip() {
        match (encode_to_vec(42u8, standard)) {
            case MyResult.Ok(buf) => @Expect(buf.size, 1); @Expect(buf[0], 42u8)
            case _ => @Expect(false)
        }
    }

    // --- VecWriter ---
    @TestCase
    public func test_vec_writer_write_byte() {
        let w = VecWriter()
        w.write_byte(1u8)
        w.write_byte(2u8)
        @Expect(w.collect().size, 2)
    }
    @TestCase
    public func test_vec_writer_write_bytes() {
        let w = VecWriter()
        w.write_bytes([1u8, 2u8, 3u8])
        @Expect(w.collect().size, 3)
    }

    // --- SizeWriter ---
    @TestCase
    public func test_size_writer_write_byte() {
        let w = SizeWriter()
        w.write_byte(1u8)
        w.write_byte(2u8)
        @Expect(w.size(), 2)
    }
    @TestCase
    public func test_size_writer_write_bytes() {
        let w = SizeWriter()
        w.write_bytes([1u8, 2u8, 3u8, 4u8])
        @Expect(w.size(), 4)
    }
}
