// impl_std.cj — Std type adapters (IoReader, IoWriter, etc.)
package bincode4cj
import std.io.*

// IoReader — adapts Cangjie InputStream to bincode byte reading
class IoReader {
    var input: InputStream
    var buf: Array<UInt8>

    public init(input: InputStream) {
        this.input = input
        this.buf = Array<UInt8>(4096, {_ => 0u8})
    }

    public func read(): MyResult<UInt8, DecodeError> {
        let byte_buf = Array<Byte>(1, repeat: 0)
        let n = this.input.read(byte_buf)
        if (n == 0) { MyResult.Err(DecodeError.UnexpectedEnd(1)) }
        else {
            let b = byte_buf[0]
            MyResult.Ok(b)
        }
    }
}

// IoWriter — adapts Cangjie OutputStream to bincode byte writing
class IoWriter {
    var output: OutputStream
    var single_buf: Array<Byte>

    public init(output: OutputStream) {
        this.output = output
        this.single_buf = Array<Byte>(1, repeat: 0)
    }

    public func write_byte(b: UInt8): Unit {
        let byte_buf = Array<Byte>(1, {_ => b})
        this.output.write(byte_buf)
    }
}