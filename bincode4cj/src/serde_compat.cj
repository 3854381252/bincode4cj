// serde_compat.cj — Compat wrapper types for serde compatibility
package bincode4cj
import std.collection.*

class Compat<T> <: Encode where T <: Serialize {
    var inner: T
    public init(inner: T) { this.inner = inner }
    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {
        this.inner.serialize(config, buf)
    }
}
extend<T> Compat<T> <: Decode<Compat<T>> where T <: Deserialize<T> {
    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(Compat<T>, Int64), DecodeError> {
        match (T.deserialize(data, pos, config)) {
            case MyResult.Ok((v, p)) => MyResult.Ok((Compat<T>(v), p))
            case MyResult.Err(e) => MyResult.Err(e)
        }
    }
}

// BorrowCompat — 占位类型，Cangjie 无生命周期系统，BorrowDecode 不可用
class BorrowCompat<T> where T <: Serialize {
    var inner: T
    public init(inner: T) { this.inner = inner }
}