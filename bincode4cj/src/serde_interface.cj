// serde_interface.cj — Serialize/Deserialize interfaces for serde compatibility layer
package bincode4cj
import std.collection.*

// Serialize 接口 — 可序列化的类型实现此接口
interface Serialize {
    func serialize(config: Config, buf: ArrayList<UInt8>): Unit
}

// Deserialize 接口 — 可反序列化的类型实现此接口
interface Deserialize<T> {
    static func deserialize(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(T, Int64), DecodeError>
}