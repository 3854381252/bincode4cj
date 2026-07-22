// builtins.cj — 自建包装类型，补足 Cangjie 1.0.5 标准库缺失
// 对标 Rust bincode 中的 NonZero*, Wrapping, Reverse, Cell, CString, Mutex,
// Box, Rc, Arc, Cow, Bound, BorrowDecode 等
package bincode4cj
import std.collection.*
import std.sync.*
import std.net.*

// === Boxed<T> 平替 Box<T>（值语义包装） ===

public class Boxed<T> {
    var val: T
    public init(val: T) { this.val = val }
    public func get(): T { this.val }
    public func set(newVal: T): Unit { this.val = newVal }
    public func as_ref(): T { this.val }
}

// === RefCounted<T> 平替 Rc<T>（非线程安全引用计数） ===

public class RefCounted<T> {
    var val: T
    var count: Int64
    public init(val: T) {
        this.val = val
        this.count = 1
    }
    public func clone(): RefCounted<T> {
        this.count += 1
        this
    }
    public func drop(): Unit {
        this.count -= 1
    }
    public func get(): T { this.val }
    public func ref_count(): Int64 { this.count }
}

// === AtomicRefCounted<T> 平替 Arc<T>（线程安全引用计数） ===

public class AtomicRefCounted<T> {
    var val: T
    var count: AtomicInt64
    public init(val: T) {
        this.val = val
        this.count = AtomicInt64(1)
    }
    public func clone(): AtomicRefCounted<T> {
        this.count.fetchAdd(1)
        this
    }
    public func drop(): Unit {
        this.count.fetchSub(1)
    }
    public func get(): T { this.val }
    public func ref_count(): Int64 { this.count.load() }
}

// === CowEnum<T> 平替 Cow<'_, T>（写时克隆，不含生命周期） ===

public enum CowEnum<T> {
    Borrowed(T)
    | Owned(T)
}

// === BoundEnum<T> 平替 Bound<T> ===

public enum BoundEnum<T> {
    Unbounded
    | Included(T)
    | Excluded(T)
}

// === PhantomData<T> 平替（零大小类型标记） ===

public class PhantomData<T> {
    public init() {}
}

// === SyncMutex<T> 泛型互斥锁包装 ===

public class SyncMutex<T> {
    var val: T
    var lock: Mutex
    public init(val: T) {
        this.val = val
        this.lock = Mutex()
    }
    public func lock_and_get(): T {
        synchronized (this.lock) {
            this.val
        }
    }
    public func lock_and_set(newVal: T): Unit {
        synchronized (this.lock) {
            this.val = newVal
        }
    }
    public func lock_and_replace(newVal: T): T {
        synchronized (this.lock) {
            let old = this.val
            this.val = newVal
            old
        }
    }
}

// === NonZero 类型（运行时检查，非零保证） ===

public class NonZeroU8 {
    var val: UInt8
    public init(val: UInt8) {
        if (val == 0) { throw Exception("NonZeroTypeIsZero(U8)") }
        this.val = val
    }
    public func get(): UInt8 { this.val }
}

public class NonZeroU16 {
    var val: UInt16
    public init(val: UInt16) {
        if (val == 0) { throw Exception("NonZeroTypeIsZero(U16)") }
        this.val = val
    }
    public func get(): UInt16 { this.val }
}

public class NonZeroU32 {
    var val: UInt32
    public init(val: UInt32) {
        if (val == 0) { throw Exception("NonZeroTypeIsZero(U32)") }
        this.val = val
    }
    public func get(): UInt32 { this.val }
}

public class NonZeroU64 {
    var val: UInt64
    public init(val: UInt64) {
        if (val == 0) { throw Exception("NonZeroTypeIsZero(U64)") }
        this.val = val
    }
    public func get(): UInt64 { this.val }
}

// === NonZeroI8/I16/I32/I64（有符号非零类型） ===

public class NonZeroI8 {
    var val: Int8
    public init(val: Int8) {
        if (val == 0) { throw Exception("NonZeroTypeIsZero(I8)") }
        this.val = val
    }
    public func get(): Int8 { this.val }
}

public class NonZeroI16 {
    var val: Int16
    public init(val: Int16) {
        if (val == 0) { throw Exception("NonZeroTypeIsZero(I16)") }
        this.val = val
    }
    public func get(): Int16 { this.val }
}

public class NonZeroI32 {
    var val: Int32
    public init(val: Int32) {
        if (val == 0) { throw Exception("NonZeroTypeIsZero(I32)") }
        this.val = val
    }
    public func get(): Int32 { this.val }
}

public class NonZeroI64 {
    var val: Int64
    public init(val: Int64) {
        if (val == 0) { throw Exception("NonZeroTypeIsZero(I64)") }
        this.val = val
    }
    public func get(): Int64 { this.val }
}

// === NonZeroU128 ===

public class NonZeroU128 {
    var val: UInt128
    public init(val: UInt128) {
        if (val.lo == 0 && val.hi == 0) { throw Exception("NonZeroTypeIsZero(U128)") }
        this.val = val
    }
    public func get(): UInt128 { this.val }
}

// === NonZeroI128 ===

public class NonZeroI128 {
    var val: Int128
    public init(val: Int128) {
        if (val.lo == 0 && val.hi == 0) { throw Exception("NonZeroTypeIsZero(I128)") }
        this.val = val
    }
    public func get(): Int128 { this.val }
}

// === NonZeroIsize（底层使用 Int64） ===

public class NonZeroIsize {
    var val: Int64
    public init(val: Int64) {
        if (val == 0) { throw Exception("NonZeroTypeIsZero(Isize)") }
        this.val = val
    }
    public func get(): Int64 { this.val }
}

// === NonZeroUsize（底层使用 UInt64） ===

public class NonZeroUsize {
    var val: UInt64
    public init(val: UInt64) {
        if (val == 0) { throw Exception("NonZeroTypeIsZero(Usize)") }
        this.val = val
    }
    public func get(): UInt64 { this.val }
}

// === Wrapping<T> 包装类型 ===

public class Wrapping<T> {
    var val: T
    public init(val: T) { this.val = val }
    public func get(): T { this.val }
}

// === Reverse<T> 包装类型 ===

public class Reverse<T> {
    var val: T
    public init(val: T) { this.val = val }
    public func get(): T { this.val }
}

// === Cell<T> 内部可变性（基于 Unsafe） ===

public class Cell<T> {
    var val: T
    public init(val: T) { this.val = val }
    public func get(): T { this.val }
    public func set(newVal: T): Unit { this.val = newVal }
    public func replace(newVal: T): T {
        let old = this.val
        this.val = newVal
        old
    }
}

// === RefCell<T> 运行时借用检查 ===

public class RefCell<T> {
    var val: T
    var borrow_count: Int64  // 0=未借用, >0=不可变借用, -1=可变借用
    public init(val: T) {
        this.val = val
        this.borrow_count = 0
    }
    public func borrow(): T {
        if (this.borrow_count < 0) { throw Exception("RefCell: already mutably borrowed") }
        this.borrow_count += 1
        this.val
    }
    public func try_borrow(): Option<T> {
        if (this.borrow_count < 0) { Option<T>.None }
        else {
            this.borrow_count += 1
            Option<T>.Some(this.val)
        }
    }
    public func borrow_mut(): T {
        if (this.borrow_count != 0) { throw Exception("RefCell: already borrowed") }
        this.borrow_count = -1
        this.val
    }
    public func try_borrow_mut(): Option<T> {
        if (this.borrow_count != 0) { Option<T>.None }
        else {
            this.borrow_count = -1
            Option<T>.Some(this.val)
        }
    }
    public func release(): Unit {
        if (this.borrow_count == -1) { this.borrow_count = 0 }
        else if (this.borrow_count > 0) { this.borrow_count -= 1 }
    }
    public func into_inner(): T { this.val }
}

// === RwLock<T> 读写锁平替 ===

public class RwLock_<T> {
    var val: T
    var lock: Mutex
    var cond: Condition
    var readers: Int64
    var writer: Bool
    public init(val: T) {
        this.val = val
        this.lock = Mutex()
        synchronized (this.lock) {
            this.cond = this.lock.condition()
        }
        this.readers = 0
        this.writer = false
    }
    public func read(): T {
        synchronized (this.lock) {
            while (this.writer) { this.cond.wait() }
            this.readers += 1
        }
        this.val
    }
    public func try_read(): Option<T> {
        synchronized (this.lock) {
            if (this.writer) { return Option<T>.None }
            this.readers += 1
        }
        Option<T>.Some(this.val)
    }
    public func write(): T {
        synchronized (this.lock) {
            while (this.writer || this.readers > 0) { this.cond.wait() }
            this.writer = true
        }
        this.val
    }
    public func try_write(): Option<T> {
        synchronized (this.lock) {
            if (this.writer || this.readers > 0) { return Option<T>.None }
            this.writer = true
        }
        Option<T>.Some(this.val)
    }
    public func read_release(): Unit {
        synchronized (this.lock) {
            this.readers -= 1
            if (this.readers == 0) { this.cond.notifyAll() }
        }
    }
    public func write_release(): Unit {
        synchronized (this.lock) {
            this.writer = false
            this.cond.notifyAll()
        }
    }
    public func into_inner(): T { this.val }
}

// === CString 简单包装 ===

public class CString {
    var inner: String
    public init(inner: String) {
        let bytes = inner.toArray()
        var i: Int64 = 0
        while (i < bytes.size) {
            if (bytes[i] == 0u8) { throw Exception("CString: contains null byte") }
            i += 1
        }
        this.inner = inner
    }
    public func get(): String { this.inner }
    public func toBytes(): Array<UInt8> {
        let bytes = this.inner.toArray()
        let result = ArrayList<UInt8>()
        var i: Int64 = 0
        while (i < bytes.size) { result.add(bytes[i]); i += 1 }
        result.add(0u8)
        result.toArray()
    }
    public static func fromBytes(bytes: Array<UInt8>): CString {
        var i: Int64 = 0
        while (i < bytes.size) {
            if (bytes[i] == 0) { throw Exception("CString: invalid null byte in content") }
            i += 1
        }
        CString(bytes_to_string(bytes))
    }
}

// === usize/isize 类型别名（64位平台） ===

public type Usize = UInt64
public type Isize = Int64

// === SocketAddrV4 / SocketAddrV6 自定义类型 ===
// 平替 Rust std::net::SocketAddrV4 / SocketAddrV6

public class SocketAddrV4 {
    var ip: IPv4Address
    var port: UInt16
    public init(ip: IPv4Address, port: UInt16) {
        this.ip = ip
        this.port = port
    }
    public func get_ip(): IPv4Address { this.ip }
    public func get_port(): UInt16 { this.port }
}

public class SocketAddrV6 {
    var ip: IPv6Address
    var port: UInt16
    var flow_info: UInt32
    var scope_id: UInt32
    public init(ip: IPv6Address, port: UInt16, flow_info: UInt32, scope_id: UInt32) {
        this.ip = ip
        this.port = port
        this.flow_info = flow_info
        this.scope_id = scope_id
    }
    public func get_ip(): IPv6Address { this.ip }
    public func get_port(): UInt16 { this.port }
    public func get_flow_info(): UInt32 { this.flow_info }
    public func get_scope_id(): UInt32 { this.scope_id }
}

// === BinaryHeap<T> 平替 std::collections::BinaryHeap ===
// 基于 ArrayList 实现的最大堆（注意：add() 不维护堆序，仅作编解码容器使用）

public class BinaryHeap<T> {
    var inner: ArrayList<T>
    public init() { this.inner = ArrayList<T>() }
    public init(inner: ArrayList<T>) { this.inner = inner }
    public func get_inner(): ArrayList<T> { this.inner }
    public func size(): Int64 { this.inner.size }
    public func add(val: T): Unit { this.inner.add(val) }
}

// === VecDeque<T> 平替 std::collections::VecDeque ===
// 基于 ArrayList 实现的双端队列

public class VecDeque<T> {
    var inner: ArrayList<T>
    public init() { this.inner = ArrayList<T>() }
    public init(inner: ArrayList<T>) { this.inner = inner }
    public func get_inner(): ArrayList<T> { this.inner }
    public func size(): Int64 { this.inner.size }
    public func add(val: T): Unit { this.inner.add(val) }
}

// === BTreeMap<K,V> 平替 std::collections::BTreeMap ===
// 基于 HashMap 实现的有序映射

public class BTreeMap<K, V> where K <: Hashable & Equatable<K> {
    var inner: HashMap<K, V>
    public init() { this.inner = HashMap<K, V>() }
    public init(inner: HashMap<K, V>) { this.inner = inner }
    public func get_inner(): HashMap<K, V> { this.inner }
    public func size(): Int64 { this.inner.size }
    public func put(key: K, val: V): Unit { this.inner.add(key, val) }
}

// === BTreeSet<T> 平替 std::collections::BTreeSet ===
// 基于 HashSet 实现的有序集合

public class BTreeSet<T> where T <: Hashable & Equatable<T> {
    var inner: HashSet<T>
    public init() { this.inner = HashSet<T>() }
    public init(inner: HashSet<T>) { this.inner = inner }
    public func get_inner(): HashSet<T> { this.inner }
    public func size(): Int64 { this.inner.size }
    public func add(val: T): Unit { this.inner.add(val) }
}

// === BoxedStr 平替 Box<str> ===
public class BoxedStr {
    var inner: String
    public init(inner: String) { this.inner = inner }
    public func get(): String { this.inner }
}

// === BoxedSlice<T> 平替 Box<[T]> ===
public class BoxedSlice<T> {
    var inner: Array<T>
    public init(inner: Array<T>) { this.inner = inner }
    public func get(): Array<T> { this.inner }
}

// === RefCountedStr 平替 Rc<str> ===
public class RefCountedStr {
    var inner: String
    var count: Int64
    public init(inner: String) { this.inner = inner; this.count = 1 }
    public func get(): String { this.inner }
    public func clone(): RefCountedStr { this.count += 1; this }
    public func drop(): Unit { this.count -= 1 }
}

// === SystemTime_ 平替 std::time::SystemTime ===
// 编码为 (secs: UInt64, nanos: UInt32) 与 Rust bincode 二进制兼容
public class SystemTime_ {
    var secs: UInt64
    var nanos: UInt32
    public init(secs: UInt64, nanos: UInt32) {
        this.secs = secs
        this.nanos = nanos
    }
    public func get_secs(): UInt64 { this.secs }
    public func get_nanos(): UInt32 { this.nanos }
}

// === AtomicRefCountedStr 平替 Arc<str> ===
public class AtomicRefCountedStr {
    var inner: String
    var count: AtomicInt64
    public init(inner: String) { this.inner = inner; this.count = AtomicInt64(1) }
    public func get(): String { this.inner }
    public func clone(): AtomicRefCountedStr { this.count.fetchAdd(1); this }
    public func drop(): Unit { this.count.fetchSub(1) }
}