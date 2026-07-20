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
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │  builtins.cj     │  │impl_interface.cj │  │  test/       │ │
│  │  自建包装类型    │  │Encode/Decode     │  │  391 测试用例│ │
│  │  30+ 平替方案    │  │接口实现(30+类型) │  │  全部通过    │ │
│  └──────────────────┘  └──────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 模块依赖关系

```
config.cj  ──→  error.cj  ──→  interface.cj  ──→  encode.cj
                                    │                  │
                                    ├──────────────────┤
                                    │                  │
                                    ▼                  ▼
                              decode.cj  ←──  varint.cj  ←──  conv.cj
                                    │
                                    ├──→  impl_std.cj
                                    ├──→  atomic.cj
                                    ├──→  uint128.cj
                                    ├──→  builtins.cj
                                    ├──→  impl_interface.cj
                                    └──→  lib.cj (顶层 API)
```

## 数据流

### 编码路径
```
用户数据 → encode_u32/encode_string/encode_arraylist/...
         → 判断 varint/fixed → 判断 LE/BE
         → buf.add(byte) → ArrayList<UInt8>
```

### 解码路径
```
Array<UInt8> + pos → decode_u32/decode_string/decode_arraylist/...
                  → 判断 varint/fixed → 判断 LE/BE
                  → read_u8/read_u16_le/be/read_u32_le/be/read_u64_le/be
                  → MyResult.Ok((value, newPos))
```

## 配置系统

```
Configuration<E, I, L>
  E → BigEndian | LittleEndian  (字节序)
  I → Varint | Fixint          (整数编码)
  L → NoLimit                  (字节限制，Cangjie 1.0.5 不支持 const 泛型)
```

预置配置：
- `standard` = `Configuration<LittleEndian, Varint, NoLimit>`
- `legacy` = `Configuration<LittleEndian, Fixint, NoLimit>`

## 文件清单

| 文件 | 行数 | 功能 |
|------|------|------|
| src/lib.cj | ~50 | 顶层 API (encode_into_slice, decode_from_slice, ...) |
| src/config.cj | ~46 | 配置系统 |
| src/error.cj | ~50 | 错误类型 + MyResult |
| src/interface.cj | ~12 | Encode/Decode 接口 |
| src/conv.cj | ~167 | 类型转换辅助函数 (40+ 函数) |
| src/varint.cj | ~357 | Varint 编解码 + 读写辅助 (含 BE/LE 读取 + u128) |
| src/encode.cj | ~344 | 编码函数 (基本类型、容器、元组、网络地址、char、duration、result) |
| src/decode.cj | ~603 | 解码函数 (基本类型、容器、元组、网络地址、char、duration、result) |
| src/atomic.cj | ~127 | 原子类型编码/解码 (11 种) |
| src/uint128.cj | ~98 | 自定义 UInt128 类 |
| src/impl_std.cj | ~39 | IoReader/IoWriter 适配器 |
| src/builtins.cj | ~477 | 自建包装类型 (30+ 平替方案) |
| src/impl_interface.cj | ~489 | Encode/Decode 接口实现 (30+ 类型) |
| src/serde_interface.cj | ~12 | Serialize/Deserialize 接口 |
| src/serde_compat.cj | ~16 | Compat 包装器 |
| test/*.cj | 19 文件 | 391 个测试用例，全部通过 |

## 构建状态

- **构建**: `cjpm build` ✅（7 warnings, 0 errors）
- **测试**: `cjpm test` ✅（391/391 PASSED, 0 FAILED, 0 ERROR）

> 设计文档详见 [doc/design.md](../design.md)
> API 参考详见 [doc/feature_api.md](../feature_api.md)
> 迁移覆盖率详见 [doc/migration_coverage.md](../migration_coverage.md)