// lib.cj — bincode4cj library entry point
package bincode4cj
import std.collection.*
import std.io.*

public func encode_into_slice<E>(val: E, config: Config, buf: ArrayList<UInt8>): Unit where E <: Encode {
    val.encode(config, buf)
}

public func encode_into_writer<E>(val: E, config: Config, writer: VecWriter): Unit where E <: Encode {
    val.encode(config, writer.collect())
}

public func encode_into_std_write<E>(val: E, config: Config, stream: OutputStream): Unit where E <: Encode {
    let buf = ArrayList<UInt8>()
    val.encode(config, buf)
    let writer = IoWriter(stream)
    let arr = buf.toArray()
    var i: Int64 = 0
    while (i < arr.size) { writer.write_byte(arr[i]); i += 1 }
}

public func decode_from_slice<D>(data: Array<UInt8>, config: Config): MyResult<(D, Int64), DecodeError> where D <: Decode<D> {
    D.decode(data, 0, config)
}

// decode_from_slice_with_context — 兼容 Rust bincode 的 Context 参数 API
// Cangjie 不支持生命周期系统，因此 Context 仅作为 API 兼容占位，实际效果与 decode_from_slice 相同
public func decode_from_slice_with_context<D, Context>(data: Array<UInt8>, config: Config, _: Context): MyResult<(D, Int64), DecodeError> where D <: Decode<D> {
    decode_from_slice(data, config)
}

public func decode_from_reader<D>(data: Array<UInt8>, config: Config): MyResult<D, DecodeError> where D <: Decode<D> {
    match (D.decode(data, 0, config)) {
        case MyResult.Ok((val, _)) => MyResult.Ok(val)
        case MyResult.Err(e) => MyResult.Err(e)
    }
}

// decode_from_reader_with_context — 兼容 Rust bincode 的 Context 参数 API
public func decode_from_reader_with_context<D, Context>(data: Array<UInt8>, config: Config, _: Context): MyResult<D, DecodeError> where D <: Decode<D> {
    decode_from_reader(data, config)
}

public func decode_from_std_read<D>(stream: InputStream, config: Config): MyResult<D, DecodeError> where D <: Decode<D> {
    let reader = IoReader(stream)
    var buf = ArrayList<UInt8>()
    var cont = true
    while (cont) {
        let r = reader.read()
        match (r) {
            case MyResult.Ok(b) => buf.add(b)
            case MyResult.Err(_) => cont = false
        }
    }
    match (D.decode(buf.toArray(), 0, config)) {
        case MyResult.Ok((val, _)) => MyResult.Ok(val)
        case MyResult.Err(e) => MyResult.Err(e)
    }
}