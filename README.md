# bincode4cj

[![Cangjie](https://img.shields.io/badge/Cangjie-1.0.5-blue)](https://cangjie-lang.cn)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Build](https://img.shields.io/badge/build-passing-brightgreen)](https://gitcode.com/lifumin_gitcode/bincode4cj)
[![Tests](https://img.shields.io/badge/tests-957%20passed-brightgreen)]()

Rust [bincode 2.0.1](https://github.com/bincode-org/bincode) 序列化库的仓颉语言迁移版本。**≈98% 功能迁移完成**，所有不可直接迁移的特性均通过平替方案实现。

> 本仓库为 **Cangjie LTS（Long Term Support）版本适配**，基于 Cangjie 1.0.5 SDK 构建，确保在 LTS 环境下的稳定兼容性。

---

## 目录

- [概述](#概述)
- [功能特性](#功能特性)
- [快速开始](#快速开始)
- [配置系统](#配置系统)
- [API 概览](#api-概览)
- [项目结构](#项目结构)
- [平替方案](#平替方案)
- [构建与测试](#构建与测试)
- [已知限制](#已知限制)
- [许可证](#许可证)

---

## 概述

bincode4cj 是 Rust 生态中广泛使用的二进制序列化库 [bincode](https://github.com/bincode-org/bincode) 的 Cangjie 1.0.5 迁移版本。它提供高效、紧凑的二进制编码/解码能力，支持多种配置选项（字节序、整数编码方式），适用于网络通信、数据持久化等场景。

### 迁移状态

| 指标 | 值 |
|------|-----|
| 功能性 API 迁移率 | **≈98%** |
| 测试用例 | **957 个，全部通过** |
| 行覆盖率 | **87.8%** |
| 构建状态 | **0 errors, 7 warnings** |

---

## 功能特性

### 核心功能

- ✅ **基本类型编码/解码**：`bool`, `u8`-`u64`, `i8`-`i64`, `f32`, `f64`, `String`, `Rune`(char)
- ✅ **配置系统**：大端/小端字节序、定长/变长整数编码（Varint）
- ✅ **Varint 变长整数编码**：含 zigzag 有符号编码，支持 `u128`/`usize`/`isize`
- ✅ **自定义错误类型**：`EncodeError`（7 种变体）、`DecodeError`（14 种变体）
- ✅ **自定义 Result 类型**：`MyResult<T,E>`（Cangjie 标准库无内置 Result）

### 容器类型

- ✅ `ArrayList<T>` / `HashMap<K,V>` / `HashSet<T>` / `Option<T>` / `Array<T>` / `MyResult<T,E>`
- ✅ `Range` / `RangeInclusive` / `BoundEnum<T>` 编解码
- ✅ 元组编解码：支持 1-16 元组

### 扩展类型

- ✅ **原子类型**：`AtomicBool`, `AtomicUInt8/16/32/64`, `AtomicInt8/16/32/64`, `AtomicUsize/Isize`
- ✅ **网络地址**：`IPv4Address`, `IPAddress`, `IPv6Address`, `IPSocketAddress`, `SocketAddrV4`, `SocketAddrV6`
- ✅ **时间类型**：`DateTime`（ISO 8601 格式）、`Duration`
- ✅ **路径**：`Path` 编码/解码
- ✅ **UInt128**：自定义 128 位无符号整数类 + varint 编解码

### 便捷函数

- ✅ `encode_to_vec` / `encode_into_slice` / `encode_into_writer` / `encode_into_std_write`
- ✅ `decode_from_slice` / `decode_from_reader` / `decode_from_std_read`
- ✅ `decode_from_slice_with_context` / `decode_from_reader_with_context`

### 兼容层

- ✅ `Serialize`/`Deserialize` 接口 + `Compat<T>` 包装器
- ✅ `IoReader`/`IoWriter` 适配器（适配 Cangjie `InputStream`/`OutputStream`）
- ✅ `VecWriter`：动态字节数组写入器

### 自建平替类型

- ✅ **智能指针**：`Boxed<T>`, `RefCounted<T>`, `AtomicRefCounted<T>`, `CowEnum<T>`
- ✅ **非零类型**：`NonZeroU8/16/32/64`, `NonZeroI8/I16/I32/I64`, `NonZeroU128`, `NonZeroUsize`
- ✅ **包装类型**：`Wrapping<T>`, `Reverse<T>`, `Cell<T>`, `RefCell<T>`
- ✅ **并发原语**：`SyncMutex<T>`, `RwLock_<T>`
- ✅ **集合包装**：`BinaryHeap<T>`, `VecDeque<T>`, `BTreeMap<K,V>`, `BTreeSet<T>`
- ✅ **字符串/切片包装**：`BoxedStr`, `BoxedSlice<T>`, `RefCountedStr`, `AtomicRefCountedStr`
- ✅ **其他**：`CString`, `BoundEnum<T>`, `PhantomData<T>`, `SocketAddrV4`, `SocketAddrV6`

---

## 快速开始

### 编码

```cangjie
import std.collection.*
import bincode4cj.{ standard, encode_u32, encode_string }

let buf = ArrayList<UInt8>()
encode_u32(42, standard, buf)
encode_string("hello", standard, buf)
// buf 内容: [42, 0x00, 0x00, 0x00, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F]
```

### 解码

```cangjie
import bincode4cj.{ standard, decode_u32, decode_string, MyResult }

let data = buf.toArray()
match (decode_u32(data, 0, standard)) {
    case MyResult.Ok((val, pos)) => {
        // val = 42
        match (decode_string(data, pos, standard)) {
            case MyResult.Ok((s, _)) => { /* s = "hello" */ }
            case MyResult.Err(e) => { /* 处理错误 */ }
        }
    }
    case MyResult.Err(e) => { /* 处理错误 */ }
}
```

### 使用接口（Encode/Decode）

```cangjie
import bincode4cj.{ standard, Encode, Decode, MyResult }

let val: UInt32 = 42
let buf = ArrayList<UInt8>()
val.encode(standard, buf)  // 通过 Encode 接口编码

match (UInt32.decode(buf.toArray(), 0, standard)) {
    case MyResult.Ok((v, _)) => { /* v = 42 */ }
    case MyResult.Err(e) => { /* 处理错误 */ }
}
```

---

## 配置系统

bincode4cj 提供灵活的配置系统，通过 `Configuration` 泛型类控制编码行为：

```cangjie
// 预置配置
let config = standard                              // 小端 + varint + 无限制
let config = legacy                                // 小端 + 定长 + 无限制

// 自定义配置
let config = standard
    .with_big_endian()                             // 改为大端字节序
    .with_fixed_int_encoding()                     // 改为定长整数编码
```

### 配置选项

| 维度 | 可选值 | 说明 |
|------|--------|------|
| 字节序 | `BigEndian` / `LittleEndian` | 多字节整数的字节顺序 |
| 整数编码 | `Varint` / `Fixint` | 变长/定长整数编码 |
| 字节限制 | `NoLimit` | 最大解码字节数限制（`Limit<N>` 因 Cangjie 不支持 const 泛型而未实现） |

---

## API 概览

### 编码函数

| 类别 | 函数 |
|------|------|
| 基本类型 | `encode_bool`, `encode_u8`/`u16`/`u32`/`u64`, `encode_i8`/`i16`/`i32`/`i64`, `encode_f32`/`f64`, `encode_string`, `encode_char`, `encode_duration` |
| 容器 | `encode_arraylist`, `encode_array`, `encode_hashmap`, `encode_hashset`, `encode_option`, `encode_result`, `encode_bound`, `encode_range_custom`, `encode_range_inclusive` |
| 元组 | `encode_tuple1` ~ `encode_tuple16` |
| 网络/路径 | `encode_path`, `encode_ipv4_address`, `encode_ip_address`, `encode_ipv6_address`, `encode_ip_socket_address`, `encode_socket_addr_v4`, `encode_socket_addr_v6` |
| 时间 | `encode_date_time` |
| 原子类型 | `encode_atomic_bool`, `encode_atomic_uint8`/`16`/`32`/`64`, `encode_atomic_int8`/`16`/`32`/`64`, `encode_atomic_usize`, `encode_atomic_isize` |

### 解码函数

| 类别 | 函数 |
|------|------|
| 基本类型 | `decode_bool`, `decode_u8`/`u16`/`u32`/`u64`, `decode_i8`/`i16`/`i32`/`i64`, `decode_f32`/`f64`, `decode_string`, `decode_char`, `decode_duration` |
| 容器 | `decode_arraylist`, `decode_array`, `decode_hashmap`, `decode_hashset`, `decode_option`, `decode_result`, `decode_bound`, `decode_range_custom`, `decode_range_inclusive` |
| 元组 | `decode_tuple1` ~ `decode_tuple16` |
| 网络/路径 | `decode_path`, `decode_ipv4_address`, `decode_ip_address`, `decode_ipv6_address`, `decode_ip_socket_address`, `decode_socket_addr_v4`, `decode_socket_addr_v6` |
| 时间 | `decode_date_time` |
| 原子类型 | `decode_atomic_bool`, `decode_atomic_uint8`/`16`/`32`/`64`, `decode_atomic_int8`/`16`/`32`/`64`, `decode_atomic_usize`, `decode_atomic_isize` |

### Varint 函数

| 方向 | 函数 |
|------|------|
| 编码 | `varint_encode_u16`/`u32`/`u64`/`u128`/`usize`, `varint_encode_i16`/`i32`/`i64`/`isize` |
| 解码 | `varint_decode_u16`/`u32`/`u64`/`u128`/`usize`, `varint_decode_i16`/`i32`/`i64`/`isize` |

### 读写辅助

| 函数 | 说明 |
|------|------|
| `read_u8` | 读取单字节 |
| `read_u16_le`/`read_u16_be` | 读取 2 字节（小端/大端） |
| `read_u32_le`/`read_u32_be` | 读取 4 字节（小端/大端） |
| `read_u64_le`/`read_u64_be` | 读取 8 字节（小端/大端） |

---

## 项目结构

```
bincode4cj/
├── doc/                        # 文档
│   ├── assets/                 # 架构图
│   ├── cjcov/                  # 覆盖率报告
│   ├── design.md               # 设计文档
│   └── feature_api.md          # API 参考
├── src/                        # 源码 (15 文件, ~3450 行)
│   ├── config.cj               # 配置系统
│   ├── error.cj                # 错误类型 + MyResult
│   ├── conv.cj                 # 类型转换辅助 (40+ 函数)
│   ├── varint.cj               # Varint 编解码 + 读写辅助
│   ├── encode.cj               # 编码函数
│   ├── decode.cj               # 解码函数
│   ├── atomic.cj               # 原子类型编码/解码 (11 种)
│   ├── uint128.cj              # 自定义 UInt128
│   ├── builtins.cj             # 自建包装类型 (30+ 平替方案)
│   ├── impl_interface.cj       # Encode/Decode 接口实现
│   ├── impl_std.cj             # IoReader/IoWriter 适配器
│   ├── interface.cj            # Encode/Decode 接口
│   ├── serde_interface.cj      # Serialize/Deserialize 接口
│   ├── serde_compat.cj         # Compat 包装器
│   ├── lib.cj                  # 顶层 API
│   ├── bincode4cj-derive/      # derive 宏子包
│   │   └── src/derive.cj       # @Encode/@Decode 宏实现
│   └── test/                   # 测试用例 (28 文件, 957 用例)
│       ├── config_test.cj      # 配置系统测试
│       ├── error_test.cj       # 错误类型测试
│       ├── builtins_test.cj    # 自建包装类型测试
│       ├── atomic_test.cj      # 原子类型测试
│       ├── lib_test.cj         # 顶层 API 测试
│       ├── component_test.cj   # 组件测试
│       ├── conv_test.cj        # 类型转换测试
│       ├── varint_be_test.cj   # varint 大端测试
│       ├── collection_decode_test.cj # 集合 Decode 测试
│       ├── coverage_test.cj    # 覆盖率补充测试
│       ├── derive_test.cj      # derive 宏测试
│       ├── ...                 # 更多测试文件
├── .gitignore                  # Git 忽略配置
├── CHANGELOG.md                # 更新日志
├── LICENSE                     # 开源协议
├── README.OpenSource           # 上游仓库开源信息
├── README.md                   # 本文件
├── cjpm.toml                   # 项目配置
└── cjpm.lock                   # 依赖锁定
```

---

## 平替方案

由于 Cangjie 1.0.5 标准库和语言的限制，以下 Rust 类型通过自建平替方案实现：

| Rust 原始类型 | 仓颉平替 | 实现文件 | 编解码 |
|--------------|---------|---------|--------|
| `Box<T>`, `Rc<T>`, `Arc<T>`, `Cow<'_, T>`, `Bound<T>` | `Boxed<T>`, `RefCounted<T>`, `AtomicRefCounted<T>`, `CowEnum<T>`, `BoundEnum<T>` | `builtins.cj` | ✅ |
| `NonZeroU8/16/32/64`, `NonZeroI8/I16/I32/I64` | `NonZeroU8/16/32/64`, `NonZeroI8/I16/I32/I64` | `builtins.cj` | ✅ |
| `NonZeroU128`, `NonZeroUsize` | `NonZeroU128`, `NonZeroUsize` | `builtins.cj` | ✅ |
| `Wrapping<T>`, `Reverse<T>`, `Cell<T>`, `RefCell<T>` | `Wrapping<T>`, `Reverse<T>`, `Cell<T>`, `RefCell<T>` | `builtins.cj` | ✅ |
| `CString`, `Mutex<T>`, `RwLock<T>`, `PhantomData<T>` | `CString`, `SyncMutex<T>`, `RwLock_<T>`, `PhantomData<T>` | `builtins.cj` | ✅ |
| `SocketAddrV4`, `SocketAddrV6` | `SocketAddrV4`, `SocketAddrV6` | `builtins.cj` | ✅ |
| `Box<str>`, `Box<[T]>`, `Rc<str>`, `Arc<str>` | `BoxedStr`, `BoxedSlice<T>`, `RefCountedStr`, `AtomicRefCountedStr` | `builtins.cj` | ✅ |
| `BinaryHeap<T>`, `VecDeque<T>`, `BTreeMap<K,V>`, `BTreeSet<T>` | `BinaryHeap<T>`, `VecDeque<T>`, `BTreeMap<K,V>`, `BTreeSet<T>` | `builtins.cj` | ✅ |
| `Encode`/`Decode` trait | `extend T <: Encode/Decode<T>` (30+ 类型) | `impl_interface.cj` | ✅ |
| `u128` varint | `varint_encode_u128`/`varint_decode_u128` (基于 `UInt128` 类) | `varint.cj` | ✅ |

---

## 构建与测试

### 前置条件

- Cangjie 1.0.5 SDK
- 配置环境变量：`source <cangjie_home>/envsetup.sh`

### 构建

```bash
cd bincode4cj
cjpm build
```

### 测试

```bash
cjpm test
```

当前 **957 个测试用例，全部通过**（0 FAILED, 0 ERROR）。

### 覆盖率

```bash
cjpm build --coverage
cjpm test --coverage
cjcov -r . -o cov_output --html-details -s src/
```

当前行覆盖率 **87.8%**（15 个生产文件，其中 12 个 ≥80%）。

---

## 已知限制

| 限制 | 原因 | 影响范围 |
|------|------|---------|
| `BorrowDecode` 不支持 | Cangjie 无生命周期系统 | 零拷贝解码不可用，全部转为 owned 拷贝 |
| `const Limit<N>` 不支持 | Cangjie 不支持 const 泛型 | 编译期字节限制不可用，可在运行时手动检查 |
| `i128` 原生类型不支持 | Cangjie 1.0.5 无 128 位整数 | 通过自定义 `UInt128` 类替代 |

---

## 许可证

[MIT](LICENSE) © 2026 bincode4cj

---

*更多详情请参阅 [设计文档](doc/design.md)、[API 参考](doc/feature_api.md) 和 [迁移覆盖率报告](doc/migration_coverage.md)。*