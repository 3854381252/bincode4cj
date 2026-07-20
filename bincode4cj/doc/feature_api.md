# bincode4cj — API 参考

## 配置系统

### 枚举

| 类型 | 变体 | 说明 |
|------|------|------|
| `Endianness` | `Little \| Big` | 字节序 |
| `IntEncoding` | `Fixed \| Variable` | 整数编码方式 |

### 配置接口

```cangjie
public interface Config {
    func endianness(): Endianness
    func int_encoding(): IntEncoding
    func limit(): Option<Int64>
}
```

### Configuration 类

```cangjie
public class Configuration<E, I, L> where E <: EndianConfig, I <: IntEncodingConfig, L <: LimitConfig {
    public func endianness(): Endianness
    public func int_encoding(): IntEncoding
    public func limit(): Option<Int64>
    public func with_big_endian(): Configuration<BigEndian, I, L>
    public func with_little_endian(): Configuration<LittleEndian, I, L>
    public func with_variable_int_encoding(): Configuration<E, Varint, L>
    public func with_fixed_int_encoding(): Configuration<E, Fixint, L>
    public func with_no_limit(): Configuration<E, I, NoLimit>
}
```

### 预置配置

```cangjie
let standard: Configuration<LittleEndian, Varint, NoLimit>  // 默认：小端 + varint + 无限制
let legacy: Configuration<LittleEndian, Fixint, NoLimit>    // 兼容：小端 + 定长 + 无限制
```

### 标记类型

| 类型 | 用途 | 所属类别 |
|------|------|---------|
| `BigEndian` | 大端字节序 | 字节序 |
| `LittleEndian` | 小端字节序 | 字节序 |
| `Fixint` | 定长整数编码 | 整数编码 |
| `Varint` | 变长整数编码 | 整数编码 |
| `NoLimit` | 无字节限制 | 字节限制 |

## 错误类型

### MyResult（自定义 Result）

```cangjie
public enum MyResult<T, E> { Ok(T) | Err(E) }
```

### EncodeError

```cangjie
public enum EncodeError {
    UnexpectedEnd
    | RefCellAlreadyBorrowed(String, String)
    | Other(String)
    | InvalidPathCharacters
    | Io(String, Int64)
    | LockFailed(String)
    | InvalidSystemTime(String, String)
}
```

### DecodeError

```cangjie
public enum DecodeError {
    UnexpectedEnd(Int64)
    | LimitExceeded
    | InvalidIntegerType(IntegerType, IntegerType)
    | NonZeroTypeIsZero(IntegerType)
    | UnexpectedVariant(String, AllowedEnumVariants, UInt32)
    | Utf8(String)
    | InvalidCharEncoding(UInt8, UInt8, UInt8, UInt8)
    | InvalidBooleanValue(UInt8)
    | ArrayLengthMismatch(Int64, Int64)
    | OutsideUsizeRange(UInt64)
    | EmptyEnum(String)
    | InvalidDuration(UInt64, UInt32)
    | InvalidSystemTime(Duration)
    | CStringNulError(Int64)
    | Io(String, Int64)
    | Other(String)
}
```

### 辅助类型

```cangjie
public enum AllowedEnumVariants { Range(UInt32, UInt32) | Allowed(Array<UInt32>) }
public enum IntegerType { U8 | U16 | U32 | U64 | U128 | Usize | I8 | I16 | I32 | I64 | Isize | Reserved }
```

## 编码函数

### 基本类型

```cangjie
public func encode_bool(val: Bool, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_u8(val: UInt8, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_u16(val: UInt16, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_u32(val: UInt32, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_u64(val: UInt64, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_i8(val: Int8, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_i16(val: Int16, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_i32(val: Int32, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_i64(val: Int64, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_f32(val: Float32, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_f64(val: Float64, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_string(val: String, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_char(val: Rune, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_duration(val: Duration, config: Config, buf: ArrayList<UInt8>): Unit
```

### 容器类型

```cangjie
public func encode_arraylist<T>(val: ArrayList<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode
public func encode_hashmap<K, V>(val: HashMap<K, V>, config: Config, buf: ArrayList<UInt8>): Unit where K <: Encode & Hashable & Equatable<K>, V <: Encode
public func encode_hashset<T>(val: HashSet<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode & Hashable & Equatable<T>
public func encode_option<T>(val: Option<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode
public func encode_result<T, E>(val: MyResult<T, E>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode, E <: Encode
public func encode_uint8_array(val: Array<UInt8>, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_array<T>(val: Array<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode
```

### VecWriter

```cangjie
public class VecWriter {
    public init()
    public func write_byte(b: UInt8): Unit
    public func write_bytes(bytes: Array<UInt8>): Unit
    public func collect(): ArrayList<UInt8>
}
```

### 便捷函数

```cangjie
public func encode_to_vec<E>(val: E, config: Config): ArrayList<UInt8> where E <: Encode
public func encode_into_writer<E>(val: E, config: Config, writer: VecWriter): Unit where E <: Encode
public func decode_from_reader<D>(data: Array<UInt8>, config: Config): MyResult<D, DecodeError> where D <: Decode<D>
```

### 元组编码 (2-8)

```cangjie
public func encode_tuple2<A, B>(val: (A, B), config: Config, buf: ArrayList<UInt8>): Unit where A <: Encode, B <: Encode
public func encode_tuple3<A, B, C>(val: (A, B, C), config: Config, buf: ArrayList<UInt8>): Unit where A <: Encode, B <: Encode, C <: Encode
// ... 至 encode_tuple8
```

### Path 编码

```cangjie
public func encode_path(val: Path, config: Config, buf: ArrayList<UInt8>): Unit
```

### 网络地址编码

```cangjie
public func encode_ipv4_address(val: IPv4Address, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_ip_address(val: IPAddress, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_ipv6_address(val: IPv6Address, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_ip_socket_address(val: IPSocketAddress, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_socket_addr_v4(val: SocketAddrV4, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_socket_addr_v6(val: SocketAddrV6, config: Config, buf: ArrayList<UInt8>): Unit
```

### 原子类型编码

```cangjie
public func encode_atomic_bool(val: AtomicBool, config: Config, buf: ArrayList<UInt8>): Unit
public func encode_atomic_uint8/uint16/uint32/uint64(val: ..., config: Config, buf: ArrayList<UInt8>): Unit
public func encode_atomic_int8/int16/int32/int64(val: ..., config: Config, buf: ArrayList<UInt8>): Unit
public func encode_atomic_usize/isize(val: ..., config: Config, buf: ArrayList<UInt8>): Unit
```

### 编解码辅助

```cangjie
public func encode_range_custom<T>(start: T, end: T, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode
public func encode_range_inclusive<T>(start: T, end: T, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode
public func encode_bound<T>(val: BoundEnum<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode
```

## 解码函数

### 基本类型

```cangjie
public func decode_u8(data: Array<UInt8>, pos: Int64): MyResult<(UInt8, Int64), DecodeError>
public func decode_bool(data: Array<UInt8>, pos: Int64): MyResult<(Bool, Int64), DecodeError>
public func decode_u16(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(UInt16, Int64), DecodeError>
public func decode_u32(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(UInt32, Int64), DecodeError>
public func decode_u64(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(UInt64, Int64), DecodeError>
public func decode_i8(data: Array<UInt8>, pos: Int64): MyResult<(Int8, Int64), DecodeError>
public func decode_i16(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Int16, Int64), DecodeError>
public func decode_i32(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Int32, Int64), DecodeError>
public func decode_i64(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Int64, Int64), DecodeError>
public func decode_f32(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Float32, Int64), DecodeError>
public func decode_f64(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Float64, Int64), DecodeError>
public func decode_string(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(String, Int64), DecodeError>
public func decode_char(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Rune, Int64), DecodeError>
public func decode_duration(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Duration, Int64), DecodeError>
```

### 容器类型

```cangjie
public func decode_arraylist<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(ArrayList<T>, Int64), DecodeError> where T <: Decode<T>
public func decode_hashmap<K, V>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(HashMap<K, V>, Int64), DecodeError> where K <: Decode<K> & Hashable & Equatable<K>, V <: Decode<V>
public func decode_hashset<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(HashSet<T>, Int64), DecodeError> where T <: Decode<T> & Hashable & Equatable<T>
public func decode_option<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Option<T>, Int64), DecodeError> where T <: Decode<T>
```

### 元组解码 (2-8)

```cangjie
public func decode_tuple2<A, B>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>
public func decode_tuple3<A, B, C>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B, C), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>, C <: Decode<C>
public func decode_tuple4<A, B, C, D>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B, C, D), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>, C <: Decode<C>, D <: Decode<D>
public func decode_tuple5<A, B, C, D, E>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B, C, D, E), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>, C <: Decode<C>, D <: Decode<D>, E <: Decode<E>
public func decode_tuple6<A, B, C, D, E, F>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B, C, D, E, F), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>, C <: Decode<C>, D <: Decode<D>, E <: Decode<E>, F <: Decode<F>
public func decode_tuple7<A, B, C, D, E, F, G>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B, C, D, E, F, G), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>, C <: Decode<C>, D <: Decode<D>, E <: Decode<E>, F <: Decode<F>, G <: Decode<G>
public func decode_tuple8<A, B, C, D, E, F, G, H>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B, C, D, E, F, G, H), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>, C <: Decode<C>, D <: Decode<D>, E <: Decode<E>, F <: Decode<F>, G <: Decode<G>, H <: Decode<H>
```

### Path 解码

```cangjie
public func decode_path(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Path, Int64), DecodeError>
```

### 网络地址解码

```cangjie
public func decode_ipv4_address(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(IPv4Address, Int64), DecodeError>
public func decode_ip_address(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(IPAddress, Int64), DecodeError>
public func decode_ipv6_address(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(IPAddress, Int64), DecodeError>
public func decode_ip_socket_address(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(IPSocketAddress, Int64), DecodeError>
public func decode_socket_addr_v4(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(SocketAddrV4, Int64), DecodeError>
public func decode_socket_addr_v6(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(SocketAddrV6, Int64), DecodeError>
```

### 原子类型解码

```cangjie
public func decode_atomic_bool/uint8/uint16/uint32/uint64/int8/int16/int32/int64(data: ..., pos: ..., config: ...): MyResult<(... , Int64), DecodeError>
public func decode_atomic_usize/isize(data: ..., pos: ..., config: ...): MyResult<(... , Int64), DecodeError>
```

### 解码辅助

```cangjie
public func decode_range_custom<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((T, T), Int64), DecodeError> where T <: Decode<T>
public func decode_range_inclusive<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((T, T), Int64), DecodeError> where T <: Decode<T>
public func decode_bound<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(BoundEnum<T>, Int64), DecodeError> where T <: Decode<T>
public func decode_result<T, E>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(MyResult<T, E>, Int64), DecodeError> where T <: Decode<T>, E <: Decode<E>
```

### DateTime 解码

```cangjie
public func decode_date_time(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(DateTime, Int64), DecodeError>
```

## Varint 函数

### 编码

```cangjie
public func varint_encode_u16(val: UInt16, buf: ArrayList<UInt8>): Unit
public func varint_encode_u32(val: UInt32, buf: ArrayList<UInt8>): Unit
public func varint_encode_u64(val: UInt64, buf: ArrayList<UInt8>): Unit
public func varint_encode_u128(val: UInt128, buf: ArrayList<UInt8>): Unit
public func varint_encode_usize(val: Usize, buf: ArrayList<UInt8>): Unit
public func varint_encode_i16(val: Int16, buf: ArrayList<UInt8>): Unit
public func varint_encode_i32(val: Int32, buf: ArrayList<UInt8>): Unit
public func varint_encode_i64(val: Int64, buf: ArrayList<UInt8>): Unit
public func varint_encode_isize(val: Isize, buf: ArrayList<UInt8>): Unit
```

### 解码

```cangjie
public func varint_decode_u16(data: Array<UInt8>, pos: Int64): MyResult<(UInt16, Int64), DecodeError>
public func varint_decode_u32(data: Array<UInt8>, pos: Int64): MyResult<(UInt32, Int64), DecodeError>
public func varint_decode_u64(data: Array<UInt8>, pos: Int64): MyResult<(UInt64, Int64), DecodeError>
public func varint_decode_u128(data: Array<UInt8>, pos: Int64): MyResult<(UInt128, Int64), DecodeError>
public func varint_decode_usize(data: Array<UInt8>, pos: Int64): MyResult<(Usize, Int64), DecodeError>
public func varint_decode_i16(data: Array<UInt8>, pos: Int64): MyResult<(Int16, Int64), DecodeError>
public func varint_decode_i32(data: Array<UInt8>, pos: Int64): MyResult<(Int32, Int64), DecodeError>
public func varint_decode_i64(data: Array<UInt8>, pos: Int64): MyResult<(Int64, Int64), DecodeError>
public func varint_decode_isize(data: Array<UInt8>, pos: Int64): MyResult<(Isize, Int64), DecodeError>
```

## 读写辅助函数

```cangjie
public func read_u8(data: Array<UInt8>, pos: Int64): MyResult<(UInt8, Int64), DecodeError>
public func read_u16_le(data: Array<UInt8>, pos: Int64): MyResult<(UInt16, Int64), DecodeError>
public func read_u16_be(data: Array<UInt8>, pos: Int64): MyResult<(UInt16, Int64), DecodeError>
public func read_u32_le(data: Array<UInt8>, pos: Int64): MyResult<(UInt32, Int64), DecodeError>
public func read_u32_be(data: Array<UInt8>, pos: Int64): MyResult<(UInt32, Int64), DecodeError>
public func read_u64_le(data: Array<UInt8>, pos: Int64): MyResult<(UInt64, Int64), DecodeError>
public func read_u64_be(data: Array<UInt8>, pos: Int64): MyResult<(UInt64, Int64), DecodeError>
```

## 类型转换辅助函数

```cangjie
public func u32_to_u8(x: UInt32): UInt8
public func u64_to_u8(x: UInt64): UInt8
public func u16_to_u8(x: UInt16): UInt8
public func u64_to_u32(x: UInt64): UInt32
public func u64_to_u16(x: UInt64): UInt16
public func u32_to_u16(x: UInt32): UInt16
public func i64_to_u64(x: Int64): UInt64
public func u64_to_i64(x: UInt64): Int64
public func u8_to_i8(x: UInt8): Int8
public func u16_to_i16(x: UInt16): Int16
public func u32_to_i32(x: UInt32): Int32
public func f32_from_bits(x: UInt32): Float32
public func f64_from_bits(x: UInt64): Float64
public func i8_to_u8(x: Int8): UInt8
public func bytes_to_string(b: Array<UInt8>): String
public func combine_u8_u16(lo: UInt8, hi: UInt8): UInt16
public func combine_u8_u32(b0: UInt8, b1: UInt8, b2: UInt8, b3: UInt8): UInt32
public func combine_u8_u64(b0..b7: UInt8): UInt64
```

## 顶层 API

```cangjie
public func encode_into_slice<E>(val: E, config: Config, buf: ArrayList<UInt8>): Unit where E <: Encode
public func encode_into_writer<E>(val: E, config: Config, writer: VecWriter): Unit where E <: Encode
public func encode_into_std_write<E>(val: E, config: Config, stream: OutputStream): Unit where E <: Encode
public func decode_from_slice<D>(data: Array<UInt8>, config: Config): MyResult<(D, Int64), DecodeError> where D <: Decode<D>
public func decode_from_slice_with_context<D, Context>(data: Array<UInt8>, config: Config, _: Context): MyResult<(D, Int64), DecodeError> where D <: Decode<D>
public func decode_from_reader<D>(data: Array<UInt8>, config: Config): MyResult<D, DecodeError> where D <: Decode<D>
public func decode_from_reader_with_context<D, Context>(data: Array<UInt8>, config: Config, _: Context): MyResult<D, DecodeError> where D <: Decode<D>
public func decode_from_std_read<D>(stream: InputStream, config: Config): MyResult<D, DecodeError> where D <: Decode<D>
```

## IoReader / IoWriter

```cangjie
public class IoReader {
    public init(input: InputStream)
    public func read(): MyResult<UInt8, DecodeError>
}
public class IoWriter {
    public init(output: OutputStream)
    public func write_byte(b: UInt8): Unit
}
```

## UInt128

```cangjie
public class UInt128 {
    public init(lo: UInt64, hi: UInt64)
    public func to_le_bytes(): Array<UInt8>
    public static func from_le_bytes(bytes: Array<UInt8>): UInt128
    // 支持 +, -, &, |, ^, ~, <<, >> 运算
}
```

## 派生宏

```cangjie
// @Encode 宏：自动生成类字段的 encode 函数
@Encode class Point { var x: Int64; var y: Int64 }
// 生成: public func encode_Point(val: Point, config: Config, buf: ArrayList<UInt8>): Unit

// @Decode 宏：自动生成类字段的 decode 函数
@Decode class Point { var x: Int64; var y: Int64 }
```

## Serde 兼容层

```cangjie
public interface Serialize {
    func serialize(config: Config, buf: ArrayList<UInt8>): Unit
}
public interface Deserialize<T> {
    static func deserialize(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(T, Int64), DecodeError>
}
public class Compat<T> <: Encode where T <: Serialize {
    public init(inner: T)
}
// Compat<T> 的 Decode 实现通过 extend 提供
```

## 接口

```cangjie
public interface Encode {
    func encode(config: Config, buf: ArrayList<UInt8>): Unit
}
public interface Decode<T> {
    static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(T, Int64), DecodeError>
}
```

## 使用示例

```cangjie
// 编码
let buf = ArrayList<UInt8>()
encode_u32(42, standard, buf)
encode_string("hello", standard, buf)

// 解码
let data = buf.toArray()
match (decode_u32(data, 0, standard)) {
    case MyResult.Ok((val, pos)) => { /* val = 42 */ }
    case MyResult.Err(e) => { /* 处理错误 */ }
}
```