# Changelog

## 0.13.0 (2026-07-20)

### 测试改进
- **测试用例从 193 增至 391**（+198），全部通过，0 失败，0 错误
- **conv.cj 测试增强**：新增 8 个测试覆盖所有类型转换函数，修复 5 个 `as` 操作函数（`i16_to_u16`、`i32_to_u32`、`u16_to_u32`、`u16_to_u64`、`u32_to_u64`）
- **error.cj 测试增强**：新增 15 个测试覆盖所有 EncodeError/DecodeError 变体 + MyResult
- **lib.cj 测试增强**：新增 5 个测试（with_context 函数、error 路径、多次写入）
- **atomic.cj 测试增强**：新增 decode 错误路径测试、AtomicUsize/Isize 编解码测试
- **builtins.cj 测试增强**：新增 clone/drop/borrow_mut 测试、Reverse/RefCell/RefCounted/SyncMutex/RwLock_/CowEnum 编解码 + NonZero 更多类型 + Usize/Isize
- **component_test.cj 增强**：新增 varint 大值测试、config marker 实例测试、serde_compat decode 测试
- **uint128.cj**：添加 `@OverflowWrapping` 到 `op_add`，修复 hi 溢出问题

### 修复
- **zigzag 编码 Bug**：`zigzag_encode_i16/i32/i64` 中 `!val` 改为 `-val`，修复负值编码错误
- **conv.cj 修复**：`i16_to_u16`、`i32_to_u32`、`u16_to_u32`、`u16_to_u64`、`u32_to_u64` 从 `x as T` 改为 `@OverflowWrapping` + `T(x)`
- **NonZero 构造器**：统一异常消息格式为 `NonZeroTypeIsZero(...)`，与 decode 路径一致

### 文档
- 全面更新 `architecture_overview.md`、`feature_api.md`、`design.md`、`coverage_report.md` 数据修正
- `design.md`：移除过时覆盖率表、修复测试计数、修正 BinaryHeap 等集合标注 ✅→⚠️
- `feature_api.md`：移除不存在的 IoReader.read_bytes、删除 u64_to_i64 重复、修正 Compat 声明
- `architecture_overview.md`：原子类型 9→11 种、测试 193→391、文件行数更新
- 更新 `README.md`：测试 176→391、覆盖率 65.4%→83.3%、移除已修复的编译器 Bug 记录

### 覆盖率提升
- **conv.cj**：52.3% → **100.0%** ✅
- **config.cj**：75.9% → **100.0%** ✅
- **lib.cj**：50.0% → **100.0%** ✅
- **atomic.cj**：60.8% → **98.5%** ✅
- **builtins.cj**：79.2% → **92.9%** ✅
- **全局**：65.4% → **83.3%** ✅

## 0.12.0 (2026-07-20)

### 新增
- **迁移覆盖率提升至 ≈98%**：填补所有剩余可迁移功能缺口
  - **NonZero 类型**：新增 `NonZeroI8/I16/I32/I64`/`NonZeroU128`/`NonZeroUsize` 类型及 Encode/Decode 实现
  - **智能指针编解码**：`Boxed<T>`/`RefCounted<T>`/`AtomicRefCounted<T>`/`CowEnum<T>` 实现 Encode/Decode
  - **包装类型编解码**：`Wrapping<T>`/`Reverse<T>`/`Cell<T>`/`RefCell<T>` 实现 Encode/Decode
  - **并发原语编解码**：`SyncMutex<T>`/`RwLock_<T>` 实现 Encode/Decode
  - **CString 编解码**：`CString` 实现 Encode/Decode
  - **Serde 兼容层**：`Compat<T>` 增加 Decode 实现
  - **原子类型全量**：新增 `encode_atomic_usize/isize`、`decode_atomic_*` 全部 11 种解码函数
  - **Varint 完整**：新增 `varint_encode_usize/isize`、`varint_decode_usize/isize` 函数
  - **UInt128 Encode/Decode trait**：`UInt128` 实现 Encode/Decode 接口
  - **RangeInclusive 编解码**：新增 `encode_range_inclusive`/`decode_range_inclusive`
  - **SocketAddrV4/V6**：自定义 struct + encode/decode 函数
  - **Context 参数 API**：新增 `decode_from_slice_with_context`/`decode_from_reader_with_context`
  - **IntegerType.U128**：添加到 IntegerType 枚举
  - **附加包装类型**：`BoxedStr`/`BoxedSlice`/`RefCountedStr`/`AtomicRefCountedStr` 及 Encode/Decode
  - **集合包装类**：`BinaryHeap`/`VecDeque`/`BTreeMap`/`BTreeSet` 自定义包装类

### 文档
- 新增 `doc/migration_coverage.md`：完整迁移覆盖率对比报告
- 更新所有文档反映 193/193 测试全通过状态

## 0.11.0 (2026-07-20)

### 修复
- **消除所有 roundtrip 和 zigzag_decode 测试失败**：193 个测试全部通过，0 失败，0 错误
  - 根因：Cangjie 1.0.5 中 `x as TargetType` 操作符在不同整数类型之间（如 `UInt16 as UInt8`、`Int64 as UInt64`、`UInt8 as Rune`）始终返回 `None`，即使值完全在目标类型范围内
  - 修复：将 `conv.cj` 中所有 `x as TargetType` 替换为 `@OverflowWrapping` + `TargetType(x)` 构造函数语法
  - 修复 `bytes_to_string` 中的 `b[i] as Rune` 改用 `Rune(UInt32(b[i]))` + `@OverflowWrapping`
- **修正此前对问题根因的错误判断**
  - 此前 `question.md` 和 `CHANGELOG.md` 将失败归因于"`UInt8→UInt32/UInt64` 转换在 `varint.cj` 中始终返回 0"的编译器 Bug
  - 实际根因是 `conv.cj` 中所有使用 `as` 操作符的跨整数类型转换函数均失效，包括 `u16_to_u8`、`i64_to_u64`、`bytes_to_string` 等
  - 规避方案：使用 `@OverflowWrapping` + `T(x)` 构造函数语法替代 `x as T`
- **`varint_decode_u32` 代码风格对齐**：改为与 `varint_decode_u16`/`u64` 一致的模式（`if-else` 链 + `u8_to_u32_local` 函数调用）
- **`zigzag_decode_helper_u16/u32/u64`**：添加 `@OverflowWrapping` 注解，修复 `!(val & 1) + 1` 在偶数值时的溢出错误

### 新增
- 诊断测试 `diag_test.cj` 新增详细的编解码中间值测试

### 移除
- 移除 `varint.cj` 中未使用的 `decode_u32_inner` 函数（此前作为规避编译器 Bug 的尝试，现已不再需要）

## 0.9.0 (2026-07-19)

### 新增
- **全面测试覆盖提升**：覆盖率从 43.2% 提升至 65.4%
  - 新增 10 个测试文件（atomic_test, lib_test, uint128_test, serde_compat_test, encode_comprehensive_test, impl_std_test, conv_comprehensive_test, decode_fixed_test 等）
  - 测试用例从 76 增至 170（162 PASSED, 5 因编译器限制失败）
- **impl_std.cj 测试**：使用 ByteBuffer 实现 IoReader/IoWriter 测试
- **lib.cj 完整测试**：encode_into_std_write、decode_from_std_read 等全部顶层 API
- **encode.cj 全面覆盖**：所有编码函数（含大端/小端、定长/变长、网络地址、Bound、Range 等）
- **conv.cj 组件测试**：combine 函数、zigzag 辅助函数、容器辅助函数
- **uint128.cj 完整测试**：16 个测试覆盖全部方法

### 修复
- `varint_encode_u64` 缺失 `U64_BYTE` 标记（已修复）
- `@OverflowWrapping` 注解在 conv.cj 中修复 `UInt8→UInt32` 转换，但跨文件调用时仍失效
- 将 combine 函数本地复制到 varint.cj（`combine_u8_u*_local`）尝试修复，但 Cangjie 1.0.5 编译器 Bug 仍存在

### 已知问题
- Cangjie 1.0.5 编译器 Bug：`UInt8→UInt32`/`UInt64` 转换运行时返回 0，影响 varint_decode、decode 等 5 个 roundtrip 测试
- 所有 `as` 操作符和 `T(e)` 构造器在 `UInt8→`宽类型时均失效，`@OverflowWrapping` 仅在 conv.cj 内有效

## 0.8.0 (2026-07-19)

### 新增
- **自建包装类型**（`builtins.cj`，157 行）：25+ 平替方案实现 Rust 标准库缺失类型
  - `Boxed<T>` 平替 `Box<T>`，`RefCounted<T>` 平替 `Rc<T>`，`AtomicRefCounted<T>` 平替 `Arc<T>`
  - `CowEnum<T>` 平替 `Cow<'_, T>`，`BoundEnum<T>` 平替 `Bound<T>`
  - `NonZeroU8/16/32/64`，`Wrapping<T>`，`Reverse<T>`，`Cell<T>`，`RefCell<T>`
  - `CString`，`SyncMutex<T>`，`RwLock_<T>`，`PhantomData<T>`，`Usize`/`Isize` 类型别名
- **新编解码函数**：
  - `encode_char`/`decode_char`：Rune UTF-8 编解码
  - `encode_duration`/`decode_duration`：Duration 编解码（secs + nanos）
  - `encode_result`/`decode_result`：MyResult 编解码
  - `encode_array`/`decode_array`：泛型 `Array<T>` 编解码
  - `encode_tuple1`/`decode_tuple1`：1 元组编解码
  - `encode_bound`/`decode_bound`：BoundEnum 编解码
  - `encode_range_custom`/`decode_range_custom`：自定义 Range 编解码
- **Encode/Decode 接口实现**（`impl_interface.cj`，94 行）：14 种基本类型通过 `extend` 实现接口
- **u128 varint 编解码**：`varint_encode_u128`/`varint_decode_u128`（基于 UInt128 类）
- **测试文件**：新增 5 个测试文件（builtins, char, duration, result, tuple），共 28 个测试用例

### 修复
- `varint_encode_u64` 缺失 `U64_BYTE` 标记
- `UInt128` 类非 `public`

### 变化
- 构建警告数从 29 降至 18（编译通过，0 错误）
- 测试用例从 11 增至 28（全部通过）

## 0.7.1 (2026-07-19)

### 修复
- **大端字节序支持**：`encode.cj` 和 `decode.cj` 中所有固定大小整数和浮点数类型（`u16/u32/u64/i16/i32/i64/f32/f64`）的编码/解码现在均尊重 `config.endianness()` 配置，此前始终使用小端序
- **大端读取函数**：`varint.cj` 新增 `read_u16_be`/`read_u32_be`/`read_u64_be` 三个大端读取函数
- **decode_arraylist 结果空列表**：`decode.cj` 中 `decode_arraylist` 解码元素后未添加到结果列表，导致始终返回空列表
- **decode_hashset 结果空集合**：`decode.cj` 中 `decode_hashset` 解码元素后未添加到结果集合，导致始终返回空集合
- **IoWriter 写入零值**：`impl_std.cj` 中 `IoWriter.write_byte` 始终写入 0 而非实际参数 `b`
- **缺失 u64_to_i64**：`conv.cj` 新增 `u64_to_i64` 转换函数，修复 `decode_string`/`decode_arraylist`/`decode_hashmap`/`decode_hashset` 的编译警告
- **缺失 decode_tuple5-8**：`decode.cj` 新增 `decode_tuple5/6/7/8` 函数，与 `encode.cj` 的元组编码函数对齐
- **IoReader 类型转换**：`impl_std.cj` 中 `IoReader.read()` 使用安全的 `as` 转换替代不安全的 `UInt8(Int64(...))` 构造

### 变化
- 构建警告数从 32 降至 29（编译通过，0 错误）

## 0.7.0 (2026-07-19)

### 新增
- `impl_std.rs` 全部迁移完成：
  - `IoReader` / `IoWriter`：适配 Cangjie `InputStream`/`OutputStream` 的读写器
  - `decode_from_std_read` / `encode_into_std_write`：从输入流读取/写入输出流的便捷函数
  - `IPv6Address` 编码/解码
- 自定义 `UInt128` 类（两个 `UInt64` 实现 128 位运算，支持 varint 编解码）
- `@Encode` / `@Decode` 派生宏包（`macro_derive/`，基于 `std.ast` 解析类声明生成代码）
- `Serialize` / `Deserialize` 接口 + `Compat` 包装器（serde 兼容层）

### 修复
- 所有代码通过 `cjpm build` 编译（32 个警告，0 个错误）
- 未使用变量警告均为新模块的备用函数，不影响功能

## 0.6.0 (2026-07-19)

### 新增
- DateTime 编码/解码：`encode_date_time` / `decode_date_time`（ISO 8601 字符串格式，替代 Rust `SystemTime`）
- 非阻塞项绕过审查：28 项不可迁移中 25 项可绕过，仅 3 项真正阻塞
- 绕过方案：`BinaryHeap`/`VecDeque`/`LinkedList` → `ArrayList<T>` 替代等

## 0.5.0 (2026-07-19)

### 新增
- 网络地址编码/解码：`IPv4Address`, `IPAddress`, `IPSocketAddress`
- 修正 harness 中 Cangjie 语法描述：`T(e)` 数值转换、match 多行表达式等

## 0.4.0 (2026-07-18)

### 新增
- 便捷函数：`encode_into_writer`, `decode_from_reader`
- 元组编码/解码：2-8 元组
- `Path` 编码/解码
- `basic_types_test.cj` 测试

## 0.3.0 (2026-07-18)

### 新增
- HashMap、HashSet 编码/解码
- 原子类型编码（9 种）
- VecWriter、encode_uint8_array

## 0.2.0 (2026-07-18)

### 新增
- `ArrayList<T>`, `HashMap<K,V>`, `Option<T>` 容器编码/解码
- `encode_to_vec` 便捷函数
- 30+ 类型转换辅助函数
- 完整文档体系

## 0.1.0 (2026-07-18)

### 新增
- 初始版本：Rust bincode 2.0.1 迁移至仓颉 1.0.5
- 配置系统、Varint 编解码、基本类型编码/解码
- 自定义 `MyResult<T,E>` 类型
- 顶层 API：`encode_into_slice`、`decode_from_slice`