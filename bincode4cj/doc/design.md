# bincode4cj - 设计文档

## 概述

bincode4cj 是 Rust 序列化库 [bincode 2.0.1](https://github.com/bincode-org/bincode) 的仓颉语言迁移版本，提供二进制序列化/反序列化能力。

## 架构

```
bincode4cj（15 个生产文件，3897 行）
├── interface.cj        # Encode/Decode 接口定义（10 行）
├── serde_interface.cj  # Serialize/Deserialize 接口（12 行）
├── serde_compat.cj     # Compat 包装器（serde -> Encode 桥接）（24 行）
├── impl_std.cj         # IoReader/IoWriter 适配器（InputStream/OutputStream）（39 行）
├── config.cj           # 配置系统：字节序、整数编码、字节限制（48 行）
├── lib.cj              # 顶层 API（encode_into_slice/writer, decode_from_slice/reader）（62 行）
├── error.cj            # 错误类型 + 自定义 MyResult（116 行）
├── atomic.cj           # 原子类型编码（AtomicBool, AtomicUInt*, AtomicInt*）（127 行）
├── uint128.cj          # 自定义 128 位无符号整数（两个 UInt64 实现）（132 行）
├── conv.cj             # 类型转换辅助函数（40+ 函数，160 行）
├── encode.cj           # 编码函数（基本类型、容器、HashSet、元组、VecWriter、SizeWriter、Path、网络地址、DateTime）（399 行）
├── builtins.cj         # 自建包装类型（Boxed/RefCounted/Cow/NonZero/Mutex 等）（518 行）
├── varint.cj           # Varint 变长整数编解码 + 读写辅助（LE/BE）（520 行）
├── impl_interface.cj   # 接口扩展实现（extend Encode/Decode 到标准类型）（642 行）
├── decode.cj           # 解码函数（基本类型、容器、HashSet、元组、Path、网络地址、DateTime）（1088 行）
└── bincode4cj-derive/  # derive 宏实现（derive.cj 220 行，@deriveEncode/@deriveDecode，支持 class + enum）

src/test/               # 测试文件（28 文件，957 用例）
├── config_test.cj      # 配置系统测试
├── error_test.cj       # 错误类型测试
├── builtins_test.cj    # 自建包装类型测试
├── atomic_test.cj      # 原子类型测试
├── lib_test.cj         # 顶层 API 测试
├── uint128_test.cj     # UInt128 测试
├── conv_test.cj        # 类型转换测试
├── diag_test.cj        # 诊断测试
├── roundtrip_test.cj   # 完整往返测试
├── component_test.cj   # 组件测试
├── char_test.cj        # Rune 编解码测试
├── duration_test.cj    # Duration 测试
├── result_test.cj      # MyResult 编解码测试
├── tuple_test.cj       # 元组编解码测试
├── basic_types_test.cj # 基本类型测试
├── encode_comprehensive_test.cj # 编码全面测试
├── impl_std_test.cj    # IoReader/IoWriter 测试
├── serde_compat_test.cj # Serde 兼容层测试
├── varint_be_test.cj   # Varint 大端编解码测试
├── collection_decode_test.cj # 集合类型 Decode 测试
├── coverage_test.cj    # 覆盖率补充测试
├── derive_test.cj      # derive 宏测试
└── ...
```

## 核心设计决策

### 1. 函数式 API 替代 Trait 式 API

Cangjie 1.0.5 不支持 `impl` 块和 `&T` 引用参数，因此采用函数式 API：

```cangjie
// 编码：值 + 配置 + 缓冲区
public func encode_u32(val: UInt32, config: Config, buf: ArrayList<UInt8>): Unit

// 解码：数据 + 位置 + 配置 -> 返回值 + 新位置
public func decode_u32(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(UInt32, Int64), DecodeError>
```

### 2. 自定义 Result 类型

Cangjie 1.0.5 标准库无内置 `Result<T,E>` 类型，使用自定义枚举：

```cangjie
public enum MyResult<T, E> { Ok(T) | Err(E) }
```

### 3. 值传递和元组返回值

Cangjie 不支持 `&T` 引用参数，解码函数通过返回 `(T, Int64)` 元组传递位置信息。

### 4. 类型转换方式

Cangjie 中数值类型转换有两种方式：

```cangjie
// 方式一：T(e) 构造函数语法（推荐）
@OverflowWrapping
public func u8_to_u32(x: UInt8): UInt32 { UInt32(x) }

// 方式二：x as T 安全转换操作符（需 match 解包）
match (x as UInt8) {
    case Some(v) => v
    case None => 0
}
```

**注意**：Cangjie 1.0.5 中 `x as TargetType` 操作符在不同整数类型之间（如 `UInt16 as UInt8`、`Int64 as UInt64`、`UInt8 as Rune`）始终返回 `None`，即使值完全在目标类型范围内。**应始终使用 `T(e)` 构造函数语法 + `@OverflowWrapping` 注解**替代 `as` 操作符：

```cangjie
// ✅ 正确：使用 T(e) 构造器
@OverflowWrapping
public func u16_to_u8(x: UInt16): UInt8 { UInt8(x) }

// ❌ 错误：as 操作符始终返回 None
public func u16_to_u8(x: UInt16): UInt8 {
    match (x as UInt8) {  // 始终进入 None 分支
        case Some(v) => v
        case None => 0    // 始终返回 0
    }
}
```

### 5. 多接口约束使用 `&` 语法

Cangjie 使用 `&` 而非 `+` 组合多个接口约束：

```cangjie
// 正确：where K <: Decode<K> & Hashable & Equatable<K>
// 错误：where K <: Decode<K> + Hashable + Eq
```

### 6. Varint 编码规则

与 Rust bincode 完全一致：

| 值范围 | 编码格式 | 字节数 |
|--------|---------|--------|
| 0-250 | 单字节 | 1 |
| 251-65535 | 0xFB + u16 | 3 |
| 65536-2^32-1 | 0xFC + u32 | 5 |
| 2^32-2^64-1 | 0xFD + u64 | 9 |

有符号整数使用 zigzag 编码后按无符号规则编码。

**大端支持**：所有 varint_encode/varint_decode 函数新增 `endian: Endianness` 参数，多字节分支（u16/u32/u64）按 endian 选择小端（LE）或大端（BE）写入/读取。签名示例：

```cangjie
public func varint_encode_u16(val: UInt16, endian: Endianness, buf: ArrayList<UInt8>): Unit
public func varint_decode_u16(data: Array<UInt8>, pos: Int64, endian: Endianness): MyResult<(UInt16, Int64), DecodeError>
```

encode.cj 调用处传 `config.endianness()`，使 varint 编码随配置自动适配双端。

### 7. 大端/小端字节序支持

所有固定大小的整数和浮点数编码/解码均尊重 `config.endianness()`，varint 编解码同样支持双端：

```cangjie
public func encode_u16(val: UInt16, config: Config, buf: ArrayList<UInt8>): Unit {
    if (is_varint(config)) { varint_encode_u16(val, config.endianness(), buf) }
    else {
        if (is_little_endian(config)) {
            buf.add(u16_to_u8(val & 0xFF)); buf.add(u16_to_u8((val >> 8) & 0xFF))
        } else {
            buf.add(u16_to_u8((val >> 8) & 0xFF)); buf.add(u16_to_u8(val & 0xFF))
        }
    }
}
```

适用类型：`u16/u32/u64/i16/i32/i64/f32/f64`，以及它们对应的原子类型。varint 路径下多字节整数同样按 `config.endianness()` 选择 LE/BE。

### 8. 大端读取函数

提供大端字节序的读取辅助函数，用于解码时按大端序组装多字节整数：

```cangjie
public func read_u16_be(data: Array<UInt8>, pos: Int64): MyResult<(UInt16, Int64), DecodeError>
public func read_u32_be(data: Array<UInt8>, pos: Int64): MyResult<(UInt32, Int64), DecodeError>
public func read_u64_be(data: Array<UInt8>, pos: Int64): MyResult<(UInt64, Int64), DecodeError>
```

### 9. Cangjie match 臂限制

Cangjie 1.0.5 的 match 臂只支持单表达式，不支持多语句块 `{ stmt1; stmt2 }`。对于需要执行多个操作（如添加元素到列表并更新位置）的场景，使用辅助函数封装：

```cangjie
// 反模式（编译错误）：
case MyResult.Ok((val, np)) => { result.add(val); cp = np }

// 正确模式（使用辅助函数）：
case MyResult.Ok((val, np)) => cp = arraylist_add_and_return(result, val, np)
```

### 10. 接口实现需显式声明

Cangjie 要求类必须显式实现接口（不同于 Rust 的"鸭子类型" trait 实现）：

```cangjie
// 必须显式 <: Config
public class Configuration<E, I, L> <: Config where E <: EndianConfig, ... {
    public func endianness(): Endianness { ... }
    public func int_encoding(): IntEncoding { ... }
    public func limit(): Option<Int64> { ... }
}
```

### 11. Result/Bound 标记使用 u32

与 Rust bincode 二进制格式对齐，`encode_result_ok/err` 和 `encode_bound` 使用 `encode_u32(0/1/2, config, buf)` 替代 `buf.add(0u8/1u8/2u8)`；`decode_result/bound` 使用 `decode_u32` 替代 `decode_u8`。标记值含义：

| 标记值 | Result | Bound |
|--------|--------|-------|
| 0 | Ok | Unbounded |
| 1 | Err | Included |
| 2 | - | Excluded |

## 容器类型 API

### ArrayList<T>

```cangjie
public func encode_arraylist<T>(val: ArrayList<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode
public func decode_arraylist<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(ArrayList<T>, Int64), DecodeError> where T <: Decode<T>
```

### HashMap<K, V>

```cangjie
public func encode_hashmap<K, V>(val: HashMap<K, V>, config: Config, buf: ArrayList<UInt8>): Unit where K <: Encode & Hashable & Equatable<K>, V <: Encode
public func decode_hashmap<K, V>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(HashMap<K, V>, Int64), DecodeError> where K <: Decode<K> & Hashable & Equatable<K>, V <: Decode<V>
```

### HashSet<T>

```cangjie
public func encode_hashset<T>(val: HashSet<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode & Hashable & Equatable<T>
public func decode_hashset<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(HashSet<T>, Int64), DecodeError> where T <: Decode<T> & Hashable & Equatable<T>
```

### Option<T>

```cangjie
public func encode_option<T>(val: Option<T>, config: Config, buf: ArrayList<UInt8>): Unit where T <: Encode
public func decode_option<T>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Option<T>, Int64), DecodeError> where T <: Decode<T>
```

### 便捷函数

```cangjie
public func encode_to_vec<E>(val: E, config: Config): MyResult<ArrayList<UInt8>, EncodeError> where E <: Encode
public func encode_into_writer<E>(val: E, config: Config, writer: VecWriter): Int64 where E <: Encode
public func decode_from_reader<D>(data: Array<UInt8>, config: Config): MyResult<D, DecodeError> where D <: Decode<D>
```

### 原子类型

Cangjie `std.sync` 包提供 9 种原子类型，bincode4cj 提供编码/解码函数。原子类型通过 `encode_u16` 等间接支持 varint 大端：

```cangjie
// 编码（11 种）
public func encode_atomic_bool/uint8/uint16/uint32/uint64/int8/int16/int32/int64(val: ..., config: Config, buf: ArrayList<UInt8>): Unit
// 新增：AtomicUsize/AtomicIsize（使用 AtomicUInt64/AtomicInt64 作为底层）
public func encode_atomic_usize/isize(val: ..., config: Config, buf: ArrayList<UInt8>): Unit

// 解码（11 种）
public func decode_atomic_bool/uint8/uint16/uint32/uint64/int8/int16/int32/int64/usize/isize(data: ..., pos: ..., config: ...): MyResult<(... , Int64), DecodeError>
```

## 元组编码/解码 (1-16)

已实现 1-16 元组编解码（编译器实测确认仓颉支持 9-16 元组字面量）。encode.cj 和 decode.cj 均提供 1-16 元组的编解码函数：

```cangjie
public func encode_tuple2<A, B>(val: (A, B), config: Config, buf: ArrayList<UInt8>): Unit where A <: Encode, B <: Encode
// ... 至 encode_tuple16
public func decode_tuple2<A, B>(data: Array<UInt8>, pos: Int64, config: Config): MyResult<((A, B), Int64), DecodeError> where A <: Decode<A>, B <: Decode<B>
// ... 至 decode_tuple16
```

## HashMap 迭代方式

Cangjie 的 `HashMap` 不支持 `keySet()` 方法。使用 `for (entry in map)` 迭代，通过 `entry[0]` 和 `entry[1]` 获取 key/value：

```cangjie
for (entry in val) {
    let k = entry[0]  // key
    let v = entry[1]  // value
    k.encode(config, buf)
    v.encode(config, buf)
}
```

## 测试策略

### 测试框架

使用 `std.unittest` 框架。测试文件位于 `src/test/` 目录，与源文件同包。

### 现有测试（957 用例，957 PASSED，0 FAILED，0 ERROR，覆盖率 87.8%）

| 测试文件 | 测试类 | 用例数 | 覆盖模块 |
|---------|--------|--------|---------|
| config_test.cj | ConfigTests | 8 | 配置系统 |
| error_test.cj | ErrorTests | 26 | 错误类型 |
| builtins_test.cj | BuiltinsTests | 34 | 自建包装类型 + Encode/Decode |
| atomic_test.cj | AtomicTests | 34 | 原子类型编码/解码 |
| lib_test.cj | LibTests | 11 | 顶层 API |
| uint128_test.cj | UInt128Tests | 22 | UInt128 类 |
| serde_compat_test.cj | SerdeCompatTests | 2 | Compat 包装器 |
| encode_comprehensive_test.cj | EncodeComprehensiveTests | 47 | 全部编码函数 |
| impl_std_test.cj | ImplStdTests | 3 | IoReader/IoWriter |
| conv_test.cj | ConvComprehensiveTests | 46 | conv 组件函数 |
| diag_test.cj | DiagTests | 23 | 诊断测试 |
| roundtrip_test.cj | RoundtripTests | 8 | roundtrip 测试 |
| component_test.cj | ComponentTests | 55+ | 组件测试 |
| char_test.cj | CharTests | 1 | Rune 编解码 |
| duration_test.cj | DurationTests | 1 | Duration 编码 |
| result_test.cj | ResultTests | 2 | MyResult 编解码 |
| tuple_test.cj | TupleTests | 2 | 元组编解码 |
| basic_types_test.cj | BasicTypesTests | 2 | 基本类型 roundtrip |
| varint_be_test.cj | VarintBeTests | - | Varint 大端编解码 |
| collection_decode_test.cj | CollectionDecodeTests | - | 集合类型 Decode |
| coverage_test.cj | CoverageTests | - | 覆盖率补充 |
| derive_test.cj | DeriveTests | - | derive 宏 |

## 配置系统

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
public class Configuration<E, I, L> <: Config where E <: EndianConfig, I <: IntEncodingConfig, L <: LimitConfig {
    public init() {}
    public func endianness(): Endianness { E.endianness() }
    public func int_encoding(): IntEncoding { I.int_encoding() }
    public func limit(): Option<Int64> { L.limit() }
    public func with_big_endian(): Configuration<BigEndian, I, L>
    public func with_little_endian(): Configuration<LittleEndian, I, L>
    public func with_variable_int_encoding(): Configuration<E, Varint, L>
    public func with_fixed_int_encoding(): Configuration<E, Fixint, L>
    public func with_no_limit(): Configuration<E, I, NoLimit>
}
```

### 预置配置

```cangjie
public let standard: Configuration<LittleEndian, Varint, NoLimit>  // 默认：小端 + varint + 无限制
public let legacy: Configuration<LittleEndian, Fixint, NoLimit>    // 兼容：小端 + 定长 + 无限制
```

### 标记类型

| 类型 | 用途 | 可见性 |
|------|------|--------|
| `BigEndian` | 大端字节序 | public |
| `LittleEndian` | 小端字节序 | public |
| `Fixint` | 定长整数编码 | public |
| `Varint` | 变长整数编码 | public |
| `NoLimit` | 无字节限制 | public |

> **注意**：Cangjie 1.0.5 不支持 const 泛型，因此 `Limit<N>` 类未实现。

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
    UnexpectedEnd(Int64) | LimitExceeded
    | InvalidIntegerType(IntegerType, IntegerType)
    | NonZeroTypeIsZero(IntegerType)
    | UnexpectedVariant(String, AllowedEnumVariants, UInt32)
    | Utf8(String) | InvalidCharEncoding(UInt8, UInt8, UInt8, UInt8)
    | InvalidBooleanValue(UInt8)
    | ArrayLengthMismatch(Int64, Int64)
    | OutsideUsizeRange(UInt64) | EmptyEnum(String)
    | InvalidDuration(UInt64, UInt32)
    | InvalidSystemTime(Duration) | CStringNulError(Int64)
    | Io(String, Int64) | Other(String)
}
```

### toString() 支持

`EncodeError`、`DecodeError`、`IntegerType`、`AllowedEnumVariants` 均实现了 `toString(): String` 方法，便于错误输出与调试。

## 已知限制与不可迁移项

### Cangjie 1.0.5 语言限制（编译器实测确认）

| 限制项 | 影响 | 证据来源 | 绕过方案 |
|--------|------|---------|---------|
| `BorrowDecode` | 无法实现零拷贝借用解码 | 编译器实测 `<'a, T>` 语法报错 | 使用 `extend T <: Decode<T>`，owned 拷贝替代 |
| `const Limit<N>` | 无法实现编译期字节限制 | 编译器实测 `<const N: Int64>` 语法报错 | 仅支持 `NoLimit`（运行时无限制） |
| `i128`/`u128` | 无原生 128 位整数类型 | 官方文档整数类型清单无 Int128/UInt128 | 自定义 `UInt128` 类（两个 UInt64 实现） |

### 限制证据详情

以下证据均通过 Cangjie 1.0.5 编译器（cjc）实测获取。

#### 1. 生命周期不可用（BorrowDecode 无法迁移）

**测试代码**：
```cangjie
func longest<'a>(s1: &'a String, s2: &'a String): &'a String {
    if (s1.size() > s2.size()) { s1 } else { s2 }
}
```

**编译命令**：`cjc test_lifetime.cj -o test_lifetime`

**编译器报错**：
```
error: expected a generic type name after '<' in generic, found ''
 ==> test_lifetime.cj:2:14:
2 | func longest<'a>(s1: &'a String, s2: &'a String): &'a String {
  |              ~^^^^^^^^^ expected a generic type name here
  |              |
  |              after '<' in generic
```

**结论**：仓颉泛型参数 `<>` 内只接受类型标识符，不接受 `'a` 生命周期参数。无法实现 Rust 的 `BorrowDecode<'de>` trait 和 `&'a str`/`&'a [u8]` 借用返回。

#### 2. const 泛型不可用（Limit\<N\> 无法迁移）

**测试代码**：
```cangjie
class FixedArray<T, const N: Int64> {
    var data: Array<T>
}
```

**编译命令**：`cjc test_const_generic.cj -o test_const_generic`

**编译器报错**：
```
error: expected a generic type name after ',' in generic, found keyword 'const'
 ==> test_const_generic.cj:2:21:
2 | class FixedArray<T, const N: Int64> {
  |                  ~^^^^ expected a generic type name here
```

**结论**：仓颉泛型参数只接受类型，不接受 `const N: Int64` 形式的编译期常量参数。无法实现 Rust 的 `Limit<const N: usize>` 类型。

**补充验证**：9-16 元组用同样方式实测，编译**通过**（仅 unused variable warning），证明"不支持 >8 元组"是错误说法，9-16 元组已实现。

#### 3. i128/u128 原生类型不存在

**官方文档路径**：`cangjie-original-docs/kernel/source_zh_cn/basic_data_type/integer.md`

**文档原文**：
> 有符号整数类型包括 `Int8`、`Int16`、`Int32`、`Int64` 和 `IntNative`，分别用于表示编码长度为 `8-bit`、`16-bit`、`32-bit`、`64-bit` 和平台相关大小的有符号整数值的类型。
> 无符号整数类型包括 `UInt8`、`UInt16`、`UInt32`、`UInt64` 和 `UIntNative`。

**结论**：整数类型清单最大为 64 位，无 Int128/UInt128。通过自定义 `UInt128` 类（两个 UInt64 拼接）和 `Int128` 类平替，功能等价。

### 标准库不存在的类型

> 以下类型在 Cangjie 1.0.5 标准库中不存在，已通过自建平替方案实现：
> **已实现编解码**：`Boxed<T>`（平替 `Box<T>`）、`RefCounted<T>`（平替 `Rc<T>`）、`AtomicRefCounted<T>`（平替 `Arc<T>`）、`CowEnum<T>`（平替 `Cow<'_, T>`）、`NonZeroI8/I16/I32/I64`、`NonZeroU128`、`NonZeroUsize`、`SyncMutex<T>`（平替 `Mutex<T>`）、`RwLock_<T>`（平替 `RwLock<T>`）、`CString`、`SocketAddrV4`、`SocketAddrV6`、`PhantomData<T>`（空操作 Encode/Decode）、`BinaryHeap<T>`、`VecDeque<T>`、`BTreeMap<K,V>`、`BTreeSet<T>`（均已有完整 Encode+Decode）

### SizeWriter

encode.cj 新增 `SizeWriter` 类，仅计数不写数据，用于预计算编码大小（如分配缓冲区前测算长度）。

### 网络类型对齐 Rust

网络类型编码格式与 Rust bincode 二进制兼容：

| 类型 | 编码格式 |
|------|---------|
| `IPv6Address` | 16 字节原始地址（大端） |
| `IPAddress` | u32 标记（0=V4, 1=V6）+ 地址 |
| `IPSocketAddress` | u32 标记（0=V4, 1=V6）+ socket |
| `SocketAddrV6` | ip（16 字节）+ port（u16），不含 flow_info/scope_id |

## 构建状态

- **构建**: `cjpm build` ✅（2 warnings, 0 errors）
- **测试**: `cjpm test` ✅（957/957 PASSED, 0 FAILED, 0 ERROR，覆盖率 87.8%）

## 平替方案说明

以下 Rust 类型/特性在 Cangjie 1.0.5 中无直接对应，已通过自建平替方案实现功能等价，在 `builtins.cj` 中统一提供。**所有标有 "✅" 的均已实现 Encode/Decode 编解码**：

| Rust 原始类型 | 平替方案 | 功能差异说明 | 编解码 |
|--------------|---------|------------|--------|
| `Box<T>` | `Boxed<T>` | 值语义包装，无堆分配语义 | ✅ |
| `Rc<T>` | `RefCounted<T>` | 非线程安全引用计数，需手动 `clone`/`drop` | ✅ |
| `Arc<T>` | `AtomicRefCounted<T>` | 线程安全原子引用计数 | ✅ |
| `Cow<'_, T>` | `CowEnum<T>` | 不含生命周期，始终 owned | ✅ |
| `Bound<T>` | `BoundEnum<T>` | 功能等价；标记使用 u32（与 Rust 对齐） | ✅ |
| `NonZeroU8/16/32/64` | `NonZeroU8/16/32/64` | 运行时检查非零 | ✅ |
| `NonZeroI8/I16/I32/I64` | `NonZeroI8/I16/I32/I64` | 有符号非零类型 | ✅ |
| `NonZeroU128` | `NonZeroU128` | 128 位非零类型 | ✅ |
| `NonZeroUsize` | `NonZeroUsize` | 平台无关非零类型 | ✅ |
| `Wrapping<T>` | `Wrapping<T>` | 功能等价 | ✅ |
| `Reverse<T>` | `Reverse<T>` | 功能等价 | ✅ |
| `Cell<T>` | `Cell<T>` | 功能等价 | ✅ |
| `RefCell<T>` | `RefCell<T>` | 运行时借用检查 | ✅ |
| `CString` | `CString` | NUL 字节检查 | ✅ |
| `Mutex<T>` | `SyncMutex<T>` | 基于 Cangjie `Mutex` + `synchronized` | ✅ |
| `RwLock<T>` | `RwLock_<T>` | 基于 `Mutex` 模拟读写锁 | ✅ |
| `PhantomData<T>` | `PhantomData<T>` | 零大小类型标记；已实现空操作 Encode/Decode | ✅ |
| `usize` / `isize` | `Usize` / `Isize` | 类型别名 = `UInt64` / `Int64` | ✅ |
| `SocketAddrV4` | `SocketAddrV4` | IPv4 地址 + 端口 | ✅ |
| `SocketAddrV6` | `SocketAddrV6` | IPv6 地址 + 端口（仅编码 ip+port，去掉 flow_info/scope_id） | ✅ |
| `BinaryHeap<T>` | `BinaryHeap<T>` | 基于 ArrayList 的最大堆；已实现完整 Encode+Decode | ✅ |
| `VecDeque<T>` | `VecDeque<T>` | 基于 ArrayList 的双端队列；已实现完整 Encode+Decode | ✅ |
| `BTreeMap<K,V>` | `BTreeMap<K,V>` | 基于 HashMap 的有序映射；已实现完整 Encode+Decode | ✅ |
| `BTreeSet<T>` | `BTreeSet<T>` | 基于 HashSet 的有序集合；已实现完整 Encode+Decode | ✅ |
| `Box<str>` | `BoxedStr` | 字符串包装 | ✅ |
| `Box<[T]>` | `BoxedSlice<T>` | 数组切片包装；已实现完整 Encode+Decode | ✅ |
| `Rc<str>` | `RefCountedStr` | 引用计数字符串 | ✅ |
| `Arc<str>` | `AtomicRefCountedStr` | 原子引用计数字符串 | ✅ |
| `Result<T,U>` 编解码 | `encode_result`/`decode_result` | 基于 `MyResult<T,E>`；标记使用 u32（与 Rust 对齐） | ✅ |
| `Range<T>` 编解码 | `encode_range_custom`/`decode_range_custom` | 返回 `(T,T)` 元组 | ✅ |
| `RangeInclusive<T>` | `encode_range_inclusive`/`decode_range_inclusive` | 闭区间编解码 | ✅ |
| `BorrowDecode` | `extend T <: Decode<T>` | 无生命周期，owned 拷贝 | ⚠️ |
| `Encode` trait | `extend T <: Encode` (14 种类型) | 接口实现 | ✅ |
| `Decode` trait | `extend T <: Decode<T>` (14 种类型) | 接口实现 | ✅ |
| `char` (UTF-8) | `encode_char`/`decode_char` | 手动 UTF-8 编解码 | ✅ |
| `Duration` 编解码 | `encode_duration`/`decode_duration` | secs + nanos 编码 | ✅ |
| `Array<T>` 编解码 | `encode_array`/`decode_array` | 泛型数组编解码 | ✅ |
| `u128` varint | `varint_encode_u128`/`varint_decode_u128` | 基于 `UInt128` 类 | ✅ |
| 1-16 元组 | `encode_tuple1`~`encode_tuple16`/`decode_tuple1`~`decode_tuple16` | 已实现 1-16 元组编解码（编译器实测确认仓颉支持 9-16 元组字面量） | ✅ |
| derive 宏 | `@deriveEncode`/`@deriveDecode`（bincode4cj-derive） | 已实现，支持 class + enum（不支持 bincode 属性） | ✅ |

## 偏离清单

| 偏离 | Rust 原始 | 仓颉处理 | 原因 |
|------|----------|---------|------|
| impl 块 | `impl Trait for Type` | `class <: Interface` | Cangjie 不支持 impl 关键字 |
| 引用参数 | `&T` / `&mut T` | 值传递/元组返回 | Cangjie 不支持引用参数 |
| ? 操作符 | `expr?` | `match { case Ok(v) => ... }` | Cangjie 不支持 ? 操作符 |
| Result 类型 | 内置 | 自定义 `MyResult<T,E>` | Cangjie stdlib 无 Result |
| 枚举变体访问 | `Enum::Variant` | `Enum.Variant` | Cangjie 使用 `.` 语法 |
| 多接口约束 | `+` 语法 | `&` 语法 | Cangjie 使用 `&` 组合约束 |
| 多语句 match 臂 | `{ stmt1; stmt2 }` | 需抽取为单独函数 | Cangjie match 臂只支持单表达式 |
| 数值类型转换 | `T as U` 或 `T::from(u)` | `T(e)` 构造器 + `@OverflowWrapping` | Cangjie 使用 `T(e)` 语法；`as` 在跨整数类型时始终返回 `None` |
| 接口实现 | 隐式实现 | 显式 ` <: Interface` | Cangjie 要求显式声明 |
| UInt128/Int128 | 原生支持 | 通过自定义 `UInt128` 类支持 | Cangjie 1.0.5 无 128 位整数 |
| serde 兼容 | 可选特性 | 首期跳过 | 仓颉无 serde 等价物 |
| derive 宏 | `#[derive(Encode,Decode)]` | 已实现 `@deriveEncode`/`@deriveDecode`，支持 class + enum（不支持 bincode 属性） | 仓颉 derive 机制不同 |
| varint 大端 | 仅小端 | varint 支持 BigEndian/LittleEndian | 已修复，通过 endian 参数支持双端 |
| 网络类型格式 | - | 与 Rust bincode 二进制兼容 | IPv6Address 16 字节大端；IPAddress/IPSocketAddress 带 u32 标记；SocketAddrV6 仅 ip+port |
