// interface.cj — Core encoding/decoding interfaces
package bincode4cj
import std.collection.*

public interface Encode {
    func encode(config: Config, buf: ArrayList<UInt8>): Unit
}

public interface Decode<T> {
    static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(T, Int64), DecodeError>
}