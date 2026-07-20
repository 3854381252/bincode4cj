# bincode4cj

[![Cangjie](https://img.shields.io/badge/Cangjie-1.0.5-blue)](https://cangjie-lang.cn)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

Rust [bincode 2.0.1](https://github.com/bincode-org/bincode) 序列化库的仓颉语言迁移版本。**≈98% 功能迁移完成**，所有不可直接迁移的特性均通过平替方案实现。

## 功能

- ✅ 基本类型编码/解码：bool, u8-u64, i8-i64, f32, f64, string, Rune(char)
- ✅ 配置系统：大端/小端字节序、定长/变长整数编码
- ✅ Varint 变长整数编码（含 zigzag 有符号编码，支持 u128/usize/isize）
- ✅ 自定义错误类型
- ✅ 容器类型：`ArrayList<T>`, `HashMap<K,V>`, `HashSet<T>`, `Option<T>`, `Array<T>`, `MyResult<T,E>` 编码/解码
- ✅ 原子类型：`AtomicBool`, `AtomicUInt8/16/32/64`, `AtomicInt8/16/32/64`, `AtomicUsize/Isize` 编码/解码
- ✅ 元组编码/解码：支持 1-8 元组
- ✅ `Path` 编码/解码
- ✅ 网络地址：`IPv4Address`, `IPAddress`, `IPv6Address`, `IPSocketAddress`, `SocketAddrV4`, `SocketAddrV6` 编码/解码
- ✅ `DateTime` 编码/解码（ISO 8601 格式，替代 Rust `SystemTime`）
- ✅ `Duration` 编码/解码
- ✅ `UInt128` 自定义类 + varint 编解码（替代缺失的 128 位整数）
- ✅ `Serialize`/`Deserialize` 兼容层 + `Compat` 包装器
- ✅ `IoReader`/`IoWriter` 适配器（适配 Cangjie `InputStream`/`OutputStream`）
- ✅ 便捷函数：`encode_to_vec`, `encode_into_writer`, `encode_into_std_write`, `decode_from_reader`, `decode_from_std_read`
- ✅ VecWriter：动态字节数组写入器
- ✅ 大端/小端字节序完全支持：所有整数和浮点数编码/解码均尊重 `config.endianness()`
- ✅ 大端读取函数：`read_u16_be`/`read_u32_be`/`read_u64_be`
- ✅ 自建包装类型：`Boxed<T>`, `RefCounted<T>`, `AtomicRefCounted<T>`, `CowEnum<T>`, `BoundEnum<T>`, `NonZeroU8/16/32/64`, `NonZeroI8/I16/I32/I64`, `NonZeroU128`, `NonZeroUsize`, `Wrapping<T>`, `Reverse<T>`, `Cell<T>`, `RefCell<T>`, `CString`, `SyncMutex<T>`, `RwLock_<T>`, `PhantomData<T>`, `BinaryHeap<T>`, `VecDeque<T>`, `BTreeMap<K,V>`, `BTreeSet<T>`, `BoxedStr`, `BoxedSlice<T>`, `RefCountedStr`, `AtomicRefCountedStr`, `SocketAddrV4`, `SocketAddrV6`
- ✅ 测试用例：18 个测试文件，391 个测试用例，**全部通过**（0 FAILED, 0 ERROR）
- ✅ 文档：设计文档、API 参考、更新日志、架构图、覆盖率报告
- ✅ 构建通过：`cjpm build` 通过（0 错误，7 警告）
- ✅ 行覆盖率：**83.3%**

## 快速开始

### 编码

```cangjie
import std.collection.*
import bincode4cj.{ standard, encode_u32, encode_string }

let buf = ArrayList<UInt8>()
encode_u32(42, standard, buf)
encode_string("hello", standard, buf)
```

### 解码

```cangjie
import bincode4cj.{ standard, decode_u32, decode_string, MyResult }

let data = buf.toArray()
match (decode_u32(data, 0, standard)) {
    case MyResult.Ok((val, pos)) => {
        match (decode_string(data, pos, standard)) {
            case MyResult.Ok((s, _)) => { /* s = "hello" */ }
            case MyResult.Err(e) => { /* 处理错误 */ }
        }
    }
    case MyResult.Err(e) => { /* 处理错误 */ }
}
```

## 构建

```bash
source <cangjie_home>/envsetup.sh
cd bincode4cj
cjpm build
```

## 项目结构

```
bincode4cj/
├── doc/                        # 设计文档和 API 参考
│   ├── assets/                 # 架构图
│   ├── cjcov/                  # 覆盖率报告
│   ├── design.md               # 设计文档
│   └── feature_api.md          # API 参考
├── src/                        # 源码 (15 文件, ~2900 行)
│   ├── config.cj               # 配置系统
│   ├── error.cj                # 错误类型 + MyResult
│   ├── conv.cj                 # 类型转换辅助 (40+ 函数)
│   ├── varint.cj               # Varint 编解码 + 读写辅助 (LE/BE)
│   ├── encode.cj               # 编码函数
│   ├── decode.cj               # 解码函数
│   ├── atomic.cj               # 原子类型编码/解码（11 种）
│   ├── uint128.cj              # 自定义 UInt128
│   ├── builtins.cj             # 自建包装类型 (30+ 平替方案)
│   ├── impl_interface.cj       # Encode/Decode 接口实现
│   ├── impl_std.cj             # IoReader/IoWriter 适配器
│   ├── interface.cj            # Encode/Decode 接口
│   ├── serde_interface.cj      # Serialize/Deserialize 接口
│   ├── serde_compat.cj         # Compat 包装器
│   └── lib.cj                  # 顶层 API
│   └── test/                   # 测试用例 (18 文件, 391 用例)
│       ├── config_test.cj      # 配置系统测试
│       ├── error_test.cj       # 错误类型测试
│       ├── builtins_test.cj    # 自建包装类型测试
│       ├── atomic_test.cj      # 原子类型测试
│       ├── lib_test.cj         # 顶层 API 测试
│       ├── ...                 # 更多测试文件
├── CHANGELOG.md
├── LICENSE
├── README.OpenSource
├── README.md
└── cjpm.toml
```

## 平替方案说明

| Rust 原始类型 | 仓颉平替 | 实现文件 |
|--------------|---------|---------|
| `Box<T>`, `Rc<T>`, `Arc<T>`, `Cow<'_, T>`, `Bound<T>` | `Boxed<T>`, `RefCounted<T>`, `AtomicRefCounted<T>`, `CowEnum<T>`, `BoundEnum<T>` | `builtins.cj` |
| `NonZeroU*`, `NonZeroI*`, `Wrapping<T>`, `Reverse<T>`, `Cell<T>`, `RefCell<T>` | `NonZeroU8/16/32/64`, `NonZeroI8/I16/I32/I64`, `Wrapping<T>`, `Reverse<T>`, `Cell<T>`, `RefCell<T>` | `builtins.cj` |
| `CString`, `Mutex<T>`, `RwLock<T>`, `PhantomData<T>` | `CString`, `SyncMutex<T>`, `RwLock_<T>`, `PhantomData<T>` | `builtins.cj` |
| `Encode`/`Decode` trait | `extend T <: Encode/Decode<T>` (30+ 类型) | `impl_interface.cj` |
| `u128` varint | `varint_encode_u128`/`varint_decode_u128` (基于 `UInt128` 类) | `varint.cj` |
| `SocketAddrV4`/`SocketAddrV6` | `SocketAddrV4`/`SocketAddrV6` 自定义 struct | `builtins.cj` |

## 测试

```bash
cjpm test
```

当前 **391 个测试用例，全部通过**（0 FAILED, 0 ERROR）。

## 已知限制

| 限制 | 原因 | 影响范围 |
|------|------|---------|
| `BorrowDecode` 不支持 | Cangjie 无生命周期系统 | 零拷贝解码不可用，全部转为 owned 拷贝 |
| 9-16 元组不支持 | Cangjie 不支持 >8 元组字面量 | 大元组无法编解码 |
| `const Limit<N>` 不支持 | Cangjie 不支持 const 泛型 | 编译期字节限制不可用 |
| `i128` 原生类型不支持 | Cangjie 1.0.5 无 128 位整数 | 通过自定义 `UInt128` 类替代 |

## 协议

[MIT](LICENSE) © 2026 bincode4cj