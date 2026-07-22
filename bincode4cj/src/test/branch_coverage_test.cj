// branch_coverage_test.cj - Branch coverage tests for encode.cj, builtins.cj, impl_interface.cj, uint128.cj
package bincode4cj.test
import std.collection.*
import std.sync.*
import std.unittest.*
import bincode4cj.{ standard, legacy, Config, Endianness, IntEncoding, IntegerType,
    MyResult, DecodeError, Encode, Decode,
    varint_encode_u32, varint_encode_u64, varint_encode_u128,
    varint_encode_i128, varint_decode_u128, varint_decode_i128,
    encode_u8, encode_u16, encode_u32, encode_u64,
    UInt128, Int128, NonZeroU8, NonZeroU16, NonZeroU32, NonZeroU64,
    NonZeroI8, NonZeroI16, NonZeroI32, NonZeroI64,
    NonZeroU128, NonZeroUsize, NonZeroIsize, NonZeroI128,
    BinaryHeap, VecDeque, BTreeMap, BTreeSet, BoxedSlice,
    SyncMutex, RwLock_, Cell, RefCell, Wrapping, Reverse,
    SizeWriter, VecWriter, is_varint, is_little_endian }

// ============================================================
// 1. varint BE 大值测试（encode.cj BE 分支）
// ============================================================
@Test
public class VarintBeLargeTests {

    // varint_encode_u32 BE with val >= 65536（触发 U32_BYTE BE 分支）
    @TestCase
    public func test_varint_be_u32_large() {
        let buf = ArrayList<UInt8>()
        varint_encode_u32(1000000u32, Endianness.Big, buf)
        @Expect(buf.size, 5)
        @Expect(buf[0], 252u8)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) => @Expect(val.lo, 1000000u64)
            case _ => @Expect(false)
        }
    }

    // varint_encode_u64 BE with val >= 4294967296（触发 U64_BYTE BE 分支）
    @TestCase
    public func test_varint_be_u64_large() {
        let buf = ArrayList<UInt8>()
        varint_encode_u64(5000000000u64, Endianness.Big, buf)
        @Expect(buf.size, 9)
        @Expect(buf[0], 253u8)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((val, _)) => @Expect(val.lo, 5000000000u64)
            case _ => @Expect(false)
        }
    }

    // varint_encode_u128 BE with hi != 0（触发 U128_BYTE BE 分支）
    @TestCase
    public func test_varint_be_u128_hi_nonzero() {
        let buf = ArrayList<UInt8>()
        let val = UInt128(42, 7)
        varint_encode_u128(val, Endianness.Big, buf)
        @Expect(buf.size, 17)
        @Expect(buf[0], 254u8)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((v, _)) =>
                @Expect(v.lo, 42u64)
                @Expect(v.hi, 7u64)
            case _ => @Expect(false)
        }
    }

    // varint_encode_u128 BE with val < 65536（触发 U16_BYTE BE 分支）
    @TestCase
    public func test_varint_be_u128_u16_range() {
        let buf = ArrayList<UInt8>()
        let val = UInt128(500, 0)
        varint_encode_u128(val, Endianness.Big, buf)
        @Expect(buf.size, 3)
        @Expect(buf[0], 251u8)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((v, _)) => @Expect(v.lo, 500u64)
            case _ => @Expect(false)
        }
    }

    // varint_encode_u128 BE with val < 4294967296（触发 U32_BYTE BE 分支）
    @TestCase
    public func test_varint_be_u128_u32_range() {
        let buf = ArrayList<UInt8>()
        let val = UInt128(100000, 0)
        varint_encode_u128(val, Endianness.Big, buf)
        @Expect(buf.size, 5)
        @Expect(buf[0], 252u8)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((v, _)) => @Expect(v.lo, 100000u64)
            case _ => @Expect(false)
        }
    }

    // varint_encode_u128 BE with hi == 0 and lo >= 4294967296（触发 U64_BYTE BE 分支）
    @TestCase
    public func test_varint_be_u128_u64_range() {
        let buf = ArrayList<UInt8>()
        let val = UInt128(8000000000u64, 0)
        varint_encode_u128(val, Endianness.Big, buf)
        @Expect(buf.size, 9)
        @Expect(buf[0], 253u8)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((v, _)) => @Expect(v.lo, 8000000000u64)
            case _ => @Expect(false)
        }
    }

    // varint_decode_u128 BE U16_BYTE 解码往返
    @TestCase
    public func test_varint_be_u128_decode_u16() {
        let buf = ArrayList<UInt8>()
        varint_encode_u128(UInt128(300, 0), Endianness.Big, buf)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((v, _)) =>
                @Expect(v.lo, 300u64)
                @Expect(v.hi, 0u64)
            case _ => @Expect(false)
        }
    }

    // varint_decode_u128 BE U32_BYTE 解码往返
    @TestCase
    public func test_varint_be_u128_decode_u32() {
        let buf = ArrayList<UInt8>()
        varint_encode_u128(UInt128(999999, 0), Endianness.Big, buf)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((v, _)) =>
                @Expect(v.lo, 999999u64)
                @Expect(v.hi, 0u64)
            case _ => @Expect(false)
        }
    }

    // varint_decode_u128 BE U64_BYTE 解码往返
    @TestCase
    public func test_varint_be_u128_decode_u64() {
        let buf = ArrayList<UInt8>()
        varint_encode_u128(UInt128(6000000000u64, 0), Endianness.Big, buf)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((v, _)) =>
                @Expect(v.lo, 6000000000u64)
                @Expect(v.hi, 0u64)
            case _ => @Expect(false)
        }
    }

    // varint_decode_u128 BE U128_BYTE 解码往返
    @TestCase
    public func test_varint_be_u128_decode_full() {
        let buf = ArrayList<UInt8>()
        let orig = UInt128(0xDEADBEEF, 0xCAFEBABE)
        varint_encode_u128(orig, Endianness.Big, buf)
        match (varint_decode_u128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((v, _)) =>
                @Expect(v.lo, 0xDEADBEEFu64)
                @Expect(v.hi, 0xCAFEBABEu64)
            case _ => @Expect(false)
        }
    }

    // varint_encode_i128 BE 大值（触发 zigzag + U128_BYTE BE 分支）
    @TestCase
    public func test_varint_be_i128_large() {
        let buf = ArrayList<UInt8>()
        let val = Int128(0x100000000, 1)
        varint_encode_i128(val, Endianness.Big, buf)
        // zigzag of positive = val << 1, hi != 0 -> U128_BYTE (254)
        @Expect(buf[0], 254u8)
        @Expect(buf.size, 17)
        match (varint_decode_i128(buf.toArray(), 0, Endianness.Big)) {
            case MyResult.Ok((v, _)) =>
                @Expect(v.lo, 0x100000000u64)
                @Expect(v.hi, 1i64)
            case _ => @Expect(false)
        }
    }
}

// ============================================================
// 2. NonZero 零值错误测试（impl_interface.cj 分支）
// ============================================================
@Test
public class NonZeroZeroTests {

    @TestCase
    public func test_nonzero_u16_zero_decode() {
        let data: Array<UInt8> = [0u8]
        match (NonZeroU16.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(t)) => @Expect(t, IntegerType.U16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_u32_zero_decode() {
        let data: Array<UInt8> = [0u8]
        match (NonZeroU32.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(t)) => @Expect(t, IntegerType.U32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_u64_zero_decode() {
        let data: Array<UInt8> = [0u8]
        match (NonZeroU64.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(t)) => @Expect(t, IntegerType.U64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_i8_zero_decode() {
        let data: Array<UInt8> = [0u8]
        match (NonZeroI8.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(t)) => @Expect(t, IntegerType.I8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_i16_zero_decode() {
        let data: Array<UInt8> = [0u8]
        match (NonZeroI16.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(t)) => @Expect(t, IntegerType.I16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_i32_zero_decode() {
        let data: Array<UInt8> = [0u8]
        match (NonZeroI32.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(t)) => @Expect(t, IntegerType.I32)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_i64_zero_decode() {
        let data: Array<UInt8> = [0u8]
        match (NonZeroI64.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(t)) => @Expect(t, IntegerType.I64)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_u128_zero_decode() {
        let data: Array<UInt8> = [0u8]
        match (NonZeroU128.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(t)) => @Expect(t, IntegerType.U128)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_usize_zero_decode() {
        let data: Array<UInt8> = [0u8]
        match (NonZeroUsize.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(t)) => @Expect(t, IntegerType.Usize)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_isize_zero_decode() {
        let data: Array<UInt8> = [0u8]
        match (NonZeroIsize.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(t)) => @Expect(t, IntegerType.Isize)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_i128_zero_decode() {
        let data: Array<UInt8> = [0u8]
        match (NonZeroI128.decode(data, 0, standard)) {
            case MyResult.Err(DecodeError.NonZeroTypeIsZero(t)) => @Expect(t, IntegerType.I128)
            case _ => @Expect(false)
        }
    }

    // NonZero 有效值解码往返
    @TestCase
    public func test_nonzero_u16_valid_decode() {
        let data: Array<UInt8> = [42u8]
        match (NonZeroU16.decode(data, 0, standard)) {
            case MyResult.Ok((nz, _)) => @Expect(nz.get(), 42u16)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_nonzero_i128_valid_decode() {
        let buf = ArrayList<UInt8>()
        varint_encode_i128(Int128(42, 0), Endianness.Little, buf)
        match (NonZeroI128.decode(buf.toArray(), 0, standard)) {
            case MyResult.Ok((nz, _)) => @Expect(nz.get().lo, 42u64)
            case _ => @Expect(false)
        }
    }
}

// ============================================================
// 3. UInt128 运算边界测试（uint128.cj 分支）
// ============================================================
@Test
public class UInt128BoundaryTests {

    // op_add 进位：UInt64.MAX + 1 -> hi 进位
    @TestCase
    public func test_uint128_add_carry_lo_to_hi() {
        let a = UInt128(0xFFFFFFFFFFFFFFFF, 0)
        let b = UInt128(1, 0)
        let r = a.op_add(b)
        @Expect(r.lo, 0u64)
        @Expect(r.hi, 1u64)
    }

    // op_shl 移位跨越 64 位边界（1 位）
    @TestCase
    public func test_uint128_shl_bits_cross_boundary() {
        let u = UInt128(0x8000000000000000, 0)
        let r = u.op_shl(1)
        @Expect(r.lo, 0u64)
        @Expect(r.hi, 1u64)
    }

    // op_shl 移位 >= 64
    @TestCase
    public func test_uint128_shl_ge_64() {
        let u = UInt128(0xFF, 0)
        let r = u.op_shl(64)
        @Expect(r.lo, 0u64)
        @Expect(r.hi, 0xFFu64)
    }

    // op_shl 移位 >= 128
    @TestCase
    public func test_uint128_shl_ge_128() {
        let u = UInt128(0xFF, 0xFF)
        let r = u.op_shl(128)
        @Expect(r.lo, 0u64)
        @Expect(r.hi, 0u64)
    }

    // op_shr 移位跨越 64 位边界（1 位）
    @TestCase
    public func test_uint128_shr_bits_cross_boundary() {
        let u = UInt128(0, 1)
        let r = u.op_shr(1)
        @Expect(r.lo, 0x8000000000000000u64)
        @Expect(r.hi, 0u64)
    }

    // op_shr 移位 >= 64
    @TestCase
    public func test_uint128_shr_ge_64() {
        let u = UInt128(0, 0xFF)
        let r = u.op_shr(64)
        @Expect(r.lo, 0xFFu64)
        @Expect(r.hi, 0u64)
    }

    // op_shr 移位 >= 128
    @TestCase
    public func test_uint128_shr_ge_128() {
        let u = UInt128(0xFF, 0xFF)
        let r = u.op_shr(128)
        @Expect(r.lo, 0u64)
        @Expect(r.hi, 0u64)
    }

    // to_le_bytes / from_le_bytes 往返
    @TestCase
    public func test_uint128_le_bytes_roundtrip() {
        let orig = UInt128(0x0102030405060708, 0x090A0B0C0D0E0F10)
        let bytes = orig.to_le_bytes()
        let restored = UInt128.from_le_bytes(bytes)
        @Expect(restored.lo, 0x0102030405060708u64)
        @Expect(restored.hi, 0x090A0B0C0D0E0F10u64)
    }

    // op_and 包含 hi 部分
    @TestCase
    public func test_uint128_and_with_hi() {
        let a = UInt128(0xFF, 0xFF)
        let b = UInt128(0x0F, 0x0F)
        let r = a.op_and(b)
        @Expect(r.lo, 0x0Fu64)
        @Expect(r.hi, 0x0Fu64)
    }

    // op_or 包含 hi 部分
    @TestCase
    public func test_uint128_or_with_hi() {
        let a = UInt128(0xF0, 0xF0)
        let b = UInt128(0x0F, 0x0F)
        let r = a.op_or(b)
        @Expect(r.lo, 0xFFu64)
        @Expect(r.hi, 0xFFu64)
    }

    // op_xor 包含 hi 部分
    @TestCase
    public func test_uint128_xor_with_hi() {
        let a = UInt128(0xFF, 0xFF)
        let b = UInt128(0x0F, 0x0F)
        let r = a.op_xor(b)
        @Expect(r.lo, 0xF0u64)
        @Expect(r.hi, 0xF0u64)
    }

    // 比较运算：less_than 先比较 hi
    @TestCase
    public func test_uint128_less_than_hi_compare() {
        let a = UInt128(100, 1)
        let b = UInt128(200, 2)
        @Expect(a.less_than(b))
        @Expect(!b.less_than(a))
    }

    // 比较运算：equals 不相等
    @TestCase
    public func test_uint128_not_equals() {
        let a = UInt128(42, 0)
        let b = UInt128(43, 0)
        @Expect(!a.equals(b))
    }
}

// ============================================================
// 4. builtins.cj 方法测试
// ============================================================
@Test
public class BuiltinsMethodTests {

    // BinaryHeap: add + get_inner + size
    @TestCase
    public func test_binary_heap_get_inner() {
        let heap = BinaryHeap<UInt8>()
        heap.add(3u8)
        heap.add(1u8)
        heap.add(2u8)
        @Expect(heap.size(), 3)
        let inner = heap.get_inner()
        @Expect(inner.size, 3)
        @Expect(inner[0], 3u8)
    }

    // VecDeque: add + get_inner + size
    @TestCase
    public func test_vecdeque_get_inner() {
        let dq = VecDeque<UInt8>()
        dq.add(10u8)
        dq.add(20u8)
        @Expect(dq.size(), 2)
        let inner = dq.get_inner()
        @Expect(inner.size, 2)
        @Expect(inner[0], 10u8)
        @Expect(inner[1], 20u8)
    }

    // BTreeMap: put + get_inner + size
    @TestCase
    public func test_btreemap_get_inner() {
        let map = BTreeMap<String, UInt8>()
        map.put("a", 1u8)
        map.put("b", 2u8)
        @Expect(map.size(), 2)
        let inner = map.get_inner()
        @Expect(inner.size, 2)
    }

    // BTreeSet: add + get_inner + size
    @TestCase
    public func test_btreeset_get_inner() {
        let set = BTreeSet<UInt8>()
        set.add(1u8)
        set.add(2u8)
        set.add(3u8)
        @Expect(set.size(), 3)
        let inner = set.get_inner()
        @Expect(inner.size, 3)
    }

    // BoxedSlice: get
    @TestCase
    public func test_boxed_slice_get() {
        let slice = BoxedSlice<UInt8>([10u8, 20u8, 30u8])
        let arr = slice.get()
        @Expect(arr.size, 3)
        @Expect(arr[0], 10u8)
        @Expect(arr[1], 20u8)
        @Expect(arr[2], 30u8)
    }

    // SyncMutex: lock_and_get + 构造
    @TestCase
    public func test_sync_mutex_lock_and_get() {
        let m = SyncMutex<UInt8>(42u8)
        @Expect(m.lock_and_get(), 42u8)
    }

    // SyncMutex: lock_and_set
    @TestCase
    public func test_sync_mutex_lock_and_set() {
        let m = SyncMutex<UInt8>(10u8)
        m.lock_and_set(99u8)
        @Expect(m.lock_and_get(), 99u8)
    }

    // SyncMutex: lock_and_replace
    @TestCase
    public func test_sync_mutex_lock_and_replace() {
        let m = SyncMutex<UInt8>(10u8)
        let old = m.lock_and_replace(20u8)
        @Expect(old, 10u8)
        @Expect(m.lock_and_get(), 20u8)
    }

    // RwLock_: into_inner + 构造
    @TestCase
    public func test_rw_lock_into_inner() {
        let rw = RwLock_<UInt8>(77u8)
        @Expect(rw.into_inner(), 77u8)
    }

    // RwLock_: read + read_release
    @TestCase
    public func test_rw_lock_read_and_release() {
        let rw = RwLock_<UInt8>(55u8)
        let v = rw.read()
        @Expect(v, 55u8)
        rw.read_release()
    }

    // Cell: get + set
    @TestCase
    public func test_cell_get_set() {
        let c = Cell<UInt8>(10u8)
        @Expect(c.get(), 10u8)
        c.set(20u8)
        @Expect(c.get(), 20u8)
    }

    // RefCell: into_inner + borrow
    @TestCase
    public func test_refcell_into_inner_and_borrow() {
        let rc = RefCell<UInt8>(42u8)
        @Expect(rc.into_inner(), 42u8)
        let v = rc.borrow()
        @Expect(v, 42u8)
        rc.release()
    }

    // Wrapping: get
    @TestCase
    public func test_wrapping_get() {
        let w = Wrapping<UInt8>(200u8)
        @Expect(w.get(), 200u8)
    }

    // Reverse: get
    @TestCase
    public func test_reverse_get() {
        let r = Reverse<UInt8>(7u8)
        @Expect(r.get(), 7u8)
    }

}

// ============================================================
// 5. 配置系统分支测试
// ============================================================
@Test
public class ConfigSystemTests {

    // is_varint(standard) == true
    @TestCase
    public func test_is_varint_standard() {
        @Expect(is_varint(standard), true)
    }

    // is_varint(legacy) == false
    @TestCase
    public func test_is_varint_legacy() {
        @Expect(is_varint(legacy), false)
    }

    // is_little_endian(standard) == true
    @TestCase
    public func test_is_little_endian_standard() {
        @Expect(is_little_endian(standard), true)
    }

    // is_little_endian(standard.with_big_endian()) == false
    @TestCase
    public func test_is_little_endian_big_endian() {
        @Expect(is_little_endian(standard.with_big_endian()), false)
    }

    // config.limit() 返回 None
    @TestCase
    public func test_config_limit_none() {
        @Expect(standard.limit(), Option<Int64>.None)
        @Expect(legacy.limit(), Option<Int64>.None)
    }
}

// ============================================================
// 6. SizeWriter / VecWriter 测试
// ============================================================
@Test
public class SizeWriterTests {

    // write_byte 计数
    @TestCase
    public func test_size_writer_write_byte() {
        let sw = SizeWriter()
        sw.write_byte(0x41u8)
        sw.write_byte(0x42u8)
        sw.write_byte(0x43u8)
        @Expect(sw.size(), 3)
    }

    // write_bytes 计数
    @TestCase
    public func test_size_writer_write_bytes() {
        let sw = SizeWriter()
        sw.write_bytes([1u8, 2u8, 3u8, 4u8, 5u8])
        @Expect(sw.size(), 5)
    }

    // write_byte + write_bytes 组合计数
    @TestCase
    public func test_size_writer_combined() {
        let sw = SizeWriter()
        sw.write_byte(0u8)
        sw.write_byte(1u8)
        sw.write_bytes([2u8, 3u8, 4u8])
        sw.write_byte(5u8)
        @Expect(sw.size(), 6)
    }

    // 初始 size 为 0
    @TestCase
    public func test_size_writer_initial_zero() {
        let sw = SizeWriter()
        @Expect(sw.size(), 0)
    }

    // VecWriter: write_byte
    @TestCase
    public func test_vec_writer_write_byte() {
        let vw = VecWriter()
        vw.write_byte(0x41u8)
        vw.write_byte(0x42u8)
        let buf = vw.collect()
        @Expect(buf.size, 2)
        @Expect(buf[0], 0x41u8)
        @Expect(buf[1], 0x42u8)
    }

    // VecWriter: write_bytes
    @TestCase
    public func test_vec_writer_write_bytes() {
        let vw = VecWriter()
        vw.write_bytes([10u8, 20u8, 30u8])
        let buf = vw.collect()
        @Expect(buf.size, 3)
        @Expect(buf[0], 10u8)
        @Expect(buf[1], 20u8)
        @Expect(buf[2], 30u8)
    }

    // VecWriter: 组合写入
    @TestCase
    public func test_vec_writer_combined() {
        let vw = VecWriter()
        vw.write_byte(0u8)
        vw.write_bytes([1u8, 2u8])
        vw.write_byte(3u8)
        let buf = vw.collect()
        @Expect(buf.size, 4)
    }
}
