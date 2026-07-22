# LLT 覆盖率报告

> 生成日期：2026-07-22
> 工具：cjcov (Cangjie Coverage 1.0.5)
> 构建版本：0.1.0

## 覆盖率概览

| 指标 | 值 |
|------|-----|
| 文件总数 | 15 个生产文件 + 28 个测试文件 |
| 测试用例数 | 957（28 个测试文件） |
| 测试通过率 | **100%**（957/957 PASSED, 0 FAILED, 0 ERROR） |
| **行覆盖率** | **87.8%**（6093/6941） |
| 分支覆盖率 | **56.2%**（1663/2960，cjcov -b 实验性功能） |

## 行覆盖率明细

| 文件 | Hit/Total | 覆盖率 | 等级 |
|------|-----------|--------|------|
| config.cj | 24/24 | **100.0%** | high |
| conv.cj | 94/94 | **100.0%** | high |
| impl_std.cj | 15/15 | **100.0%** | high |
| lib.cj | 36/36 | **100.0%** | high |
| builtins.cj | 229/229 | **100.0%** | high |
| atomic.cj | 65/66 | **98.5%** | high |
| uint128.cj | 74/76 | **97.4%** | high |
| error.cj | 57/59 | **96.6%** | high |
| encode.cj | 212/228 | **93.0%** | high |
| varint.cj | 298/330 | **90.3%** | high |
| decode.cj | 654/739 | **88.5%** | medium |
| serde_compat.cj | 8/8 | **100.0%** | high |
| impl_interface.cj | 215/268 | **80.2%** | medium |
| derive.cj | 0/125 | **0.0%** | 宏代码（编译期展开，不可统计） |

> 等级标准：high ≥ 90.0%，medium ≥ 75.0%，low < 75.0%

## 分支覆盖率明细

> 使用 `cjcov -b` 选项生成（实验性功能，可能不精确）

| 文件 | Hit/Total | 覆盖率 |
|------|-----------|--------|
| impl_std.cj | 2/2 | **100.0%** |
| atomic.cj | 21/22 | **95.5%** |
| varint.cj | 186/214 | **86.9%** |
| error.cj | 118/142 | **83.1%** |
| config.cj | 13/16 | **81.2%** |
| lib.cj | 17/24 | **70.8%** |
| conv.cj | 8/12 | **66.7%** |
| uint128.cj | 64/104 | **61.5%** |
| impl_interface.cj | 87/148 | **58.8%** |
| decode.cj | 760/1366 | **55.6%** |
| encode.cj | 229/412 | **55.6%** |
| serde_compat.cj | 8/14 | **57.1%** |
| builtins.cj | 150/264 | **56.8%** |
| derive.cj | 0/220 | **0.0%**（宏代码） |

> 分支覆盖率偏低的主因：decode.cj/encode.cj 中大量嵌套 match 的错误处理分支未被测试触达（如 `case MyResult.Err(e) => MyResult.Err(e)` 错误传播路径）。

## 测试文件清单

| 测试文件 | 用例数 | 覆盖范围 |
|---------|--------|---------|
| component_test.cj | 55+ | 组件级综合测试 |
| encode_comprehensive_test.cj | 47 | 编码函数全面测试 |
| conv_test.cj | 46 | 类型转换测试 |
| coverage_test.cj | 68 | toString + decode 错误路径 |
| builtins_test.cj | 34+ | 自建包装类型测试 |
| atomic_test.cj | 34 | 原子类型测试 |
| diag_test.cj | 23 | 诊断测试 |
| uint128_test.cj | 22 | UInt128 测试 |
| varint_be_test.cj | 24 | varint 大端 + 网络类型测试 |
| error_test.cj | 26 | 错误类型测试 |
| collection_decode_test.cj | 11 | 集合 Decode 往返测试 |
| derive_test.cj | 18 | derive 宏测试（含 enum） |
| lib_test.cj | 11 | 顶层 API 测试 |
| config_test.cj | 8 | 配置系统测试 |
| roundtrip_test.cj | 8 | 编解码往返测试 |
| migration_test.cj | 10 | 迁移验证测试 |
| impl_std_test.cj | 3 | I/O 适配器测试 |
| serde_compat_test.cj | 2 | serde 兼容测试 |
| result_test.cj | 2 | Result 编解码测试 |
| tuple_test.cj | 2 | 元组编解码测试 |
| basic_types_test.cj | 2 | 基本类型测试 |
| char_test.cj | 1 | 字符编解码测试 |
| duration_test.cj | 1 | Duration 编解码测试 |

## 构建状态

- `cjpm build`：✅ 通过（2 warnings, 0 errors）
- `cjpm test`：✅ 957/957 PASSED（0 FAILED, 0 ERROR）



## 运行覆盖率

```bash
source <cangjie_home>/envsetup.sh
cd bincode4cj
cjpm build --coverage
cjpm test --coverage
cjcov -r . -o cov_output --html-details -s src/
```

> 覆盖率 HTML 详细报告生成在 `cov_output/` 目录（已加入 `.gitignore`），本摘要报告存放在 `doc/cjcov/`。
