# bincode4cj 架构概览

## 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        bincode4cj 库                            │
│                                                                 │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │  config.cj   │  │   error.cj   │  │      interface.cj      │ │
│  │ 配置系统     │  │  错误类型    │  │  Encode / Decode 接口  │ │
│  └──────┬───────┘  └──────┬───────┘  └───────────┬────────────┘ │
│         │                 │                       │              │
│         ▼                 ▼                       ▼              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                      varint.cj                            │  │
│  │              Varint 变长整数编解码 + 读写辅助              │  │
│  │    read_u8 / read_u16_le/be / read_u32_le/be /            │  │
│  │    read_u64_le/be / varint_encode/decode_*                │  │
│  └─────────────────────────┬─────────────────────────────────┘  │
│                            │                                     │
│         ┌──────────────────┴──────────────────┐                 │
│         ▼                                     ▼                 │
│  ┌───────────────┐                  ┌──────────────────┐        │
│  │  encode.cj    │                  │   decode.cj      │        │
│  │  编码函数     │                  │   解码函数       │        │
│  │  encode_u8..  │                  │  decode_u8..     │        │
│  │  encode_f32.. │                  │  decode_f32..    │        │
│  │  encode_string│                  │  decode_string   │        │
│  │  encode_*     │                  │  decode_*        │        │
│  │  (容器/元组/  │                  │  (容器/元组/     │        │
│  │   网络地址/   │                  │   网络地址/      │        │
│  │   DateTime)   │                  │   DateTime)      │        │
│  └───────┬───────┘                  └────────┬─────────┘        │
│          │                                   │                   │
│          └───────────────┬───────────────────┘                 │
│                          │                                     │
│                          ▼                                     │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                      conv.cj                              │  │
│  │       类型转换辅助函数 (u32_to_u8, combine_u8_*, ...)      │  │
│  │       容器编解码辅助 (arraylist_add_and_return, ...)       │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐  ┌──────────────┐ │
│  │atomic.cj │  │uint128.cj│  │impl_std.cj │  │  lib.cj      │ │
│  │原子类型  │  │ 128位整数│  │IoReader/   │  │ 顶层 API     │ │
│  │编码(11种)│  │ 自定义类 │  │IoWriter    │  │ 便捷函数     │ │
│  └──────────┘  └──────────┘  └────────────┘  └──────────────┘ │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐                            │
│  │  VecWriter   │  │  SizeWriter  │                            │
│  │  动态字节数组│  │  仅计数不写入│                            │
│  └──────────────┘  └──────────────┘                            │
│                                                                 │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │  builtins.cj     │  │impl_interface.cj │  │  test/       │ │
│  │  自建包装类型    │  │Encode/Decode     │  │  533 测试用例│ │
│  │  30+ 平替方案    │  │接口实现(40+类型) │  │  全部通过    │ │
│  └──────────────────┘  └──────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 模块依赖关系

```
config.cj  ──->  error.cj  ──->  interface.cj  ──->  encode.cj
                                    │                  │
                                    ├──────────────────┤
                                    │                  │
                                    ▼                  ▼
                              decode.cj  ←──  varint.cj  ←──  conv.cj
                                    │
                                    ├──->  impl_std.cj
                                    ├──->  atomic.cj
                                    ├──->  uint128.cj
                                    ├──->  builtins.cj
                                    ├──->  impl_interface.cj
                                    └──->  lib.cj (顶层 API)
```

## 数据流

### 编码路径
```
用户数据 -> encode_u32/encode_string/encode_arraylist/...
         -> 判断 varint/fixed -> 判断 LE/BE
         -> VecWriter.write(byte) / SizeWriter.count(byte)
         -> ArrayList<UInt8>
```

> **注意**: varint 和 fixint 均会根据 endian 参数判断 LE/BE（之前 varint 仅使用 LE）。

### 解码路径
```
Array<UInt8> + pos -> decode_u32/decode_string/decode_arraylist/...
                   -> 判断 varint/fixed -> 判断 LE/BE
                   -> read_u8/read_u16_le/be/read_u32_le/be/read_u64_le/be
                   -> MyResult.Ok((value, newPos))
```

> **注意**: varint 和 fixint 均会根据 endian 参数判断 LE/BE（之前 varint 仅使用 LE）。

## 配置系统

```
Configuration<E, I, L>
  E -> BigEndian | LittleEndian  (字节序)
  I -> Varint | Fixint          (整数编码)
  L -> NoLimit                  (字节限制，Cangjie 1.0.5 不支持 const 泛型)
```

预置配置：
- `standard` = `Configuration<LittleEndian, Varint, NoLimit>`
- `legacy` = `Configuration<LittleEndian, Fixint, NoLimit>`

> **注意**: Varint 编码现在通过 `endian` 参数支持 BigEndian / LittleEndian 双端模式（之前仅支持 LittleEndian）。Fixint 同样支持双端。

## 文件清单

| 文件 | 行数 | 功能 |
|------|------|------|
| src/lib.cj | 62 | 顶层 API (encode_into_slice, decode_from_slice, ...) |
| src/config.cj | 48 | 配置系统 |
| src/error.cj | 116 | 错误类型 + MyResult + toString |
| src/interface.cj | 10 | Encode/Decode 接口 |
| src/conv.cj | 160 | 类型转换辅助函数 (40+ 函数) |
| src/varint.cj | 520 | Varint 编解码 + 读写辅助 (含 BE/LE 读取 + u128 + endian 参数) |
| src/encode.cj | 399 | 编码函数 (基本类型、容器、元组 1-16、网络地址、char、duration、result、SizeWriter) |
| src/decode.cj | 1088 | 解码函数 (基本类型、容器、元组 1-16、网络地址、char、duration、result) |
| src/atomic.cj | 127 | 原子类型编码/解码 (11 种) |
| src/uint128.cj | 132 | 自定义 UInt128 类 |
| src/impl_std.cj | 39 | IoReader/IoWriter 适配器 |
| src/builtins.cj | 518 | 自建包装类型 (30+ 平替方案) |
| src/impl_interface.cj | 642 | Encode/Decode 接口实现 (40+ 类型，含集合 Decode + PhantomData) |
| src/serde_interface.cj | 12 | Serialize/Deserialize 接口 |
| src/serde_compat.cj | 24 | Compat 包装器 |
| derive/derive.cj (子包) | 220 | 派生宏 (@Encode / @Decode 代码生成) |
| **合计** | **4117** | **15 个生产文件 + 1 个子包文件** |
| test/*.cj | 28 文件 | 957 个测试用例，全部通过 |

## 构建状态

- **构建**: `cjpm build` ✅（2 warnings, 0 errors）
- **测试**: `cjpm test` ✅（957/957 PASSED, 0 FAILED, 0 ERROR）
- **行覆盖率**: 87.8% (6093/6941)
- **分支覆盖率**: 56.2% (1663/2960, `cjcov -b` 实验性功能)
- **生产源码**: 15 个文件，3897 行 + derive.cj 220 行
- **测试文件**: 28 个，957 个用例

### 各文件覆盖率

| 文件 | 覆盖率 |
|------|--------|
| config.cj | 100.0% |
| conv.cj | 100.0% |
| impl_std.cj | 100.0% |
| lib.cj | 100.0% |
| atomic.cj | 98.5% |
| builtins.cj | 97.4% |
| uint128.cj | 97.4% |
| error.cj | 96.6% |
| encode.cj | 87.7% |
| serde_compat.cj | 87.5% |
| varint.cj | 85.8% |
| impl_interface.cj | 80.2% |
| decode.cj | 58.7% |
| derive.cj | 0.0% (宏代码) |

## 已知限制

> 以下限制均有 Cangjie 编译器实测证据。

1. **BorrowDecode 不支持** — Cangjie 无生命周期系统（编译器实测：`<'a, T>` 语法报错）
2. **const Limit\<N\> 不支持** — Cangjie 不支持 const 泛型（编译器实测：`<const N: Int64>` 语法报错）
3. **i128 原生类型不支持** — Cangjie 1.0.5 无 128 位整数（官方文档整数类型清单无 Int128/UInt128）

### 限制证据

以下证据通过 cjc 1.0.5 编译器实测获取：

| # | 限制 | 测试代码 | 编译器报错 | 文档依据 |
|---|------|---------|-----------|---------|
| 1 | 生命周期 | `func f<'a>(x: &'a String): &'a String` | `error: expected a generic type name after '<' in generic, found ''` | - |
| 2 | const 泛型 | `class A<T, const N: Int64>` | `error: expected a generic type name after ',' in generic, found keyword 'const'` | - |
| 3 | i128/u128 | - | - | `cangjie-original-docs/kernel/source_zh_cn/basic_data_type/integer.md` 整数类型清单仅到 Int64/UInt64 |

> 注：9-16 元组经同样方式实测，编译通过（仅 unused warning），证明"不支持 >8 元组"是错误说法，已实现 1-16 元组编解码。

> 设计文档详见 [doc/design.md](../design.md)
> API 参考详见 [doc/feature_api.md](../feature_api.md)
