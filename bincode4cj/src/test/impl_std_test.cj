// impl_std_test.cj — Tests for IoReader/IoWriter using ByteBuffer
package bincode4cj.test
import std.collection.*
import std.io.*
import std.unittest.*
import bincode4cj.{ IoReader, IoWriter, MyResult, DecodeError }

@Test
public class ImplStdTests {
    @TestCase
    public func test_iowriter_write_byte() {
        let buf = ByteBuffer()
        let writer = IoWriter(buf)
        writer.write_byte(42u8)
        @Expect(buf.length > 0)
    }

    @TestCase
    public func test_ioreader_read() {
        let data = Array<Byte>(1, {_ => 42u8})
        let buf = ByteBuffer(data)
        let reader = IoReader(buf)
        match (reader.read()) {
            case MyResult.Ok(b) => @Expect(b, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_ioreader_read_eof() {
        let buf = ByteBuffer()
        let reader = IoReader(buf)
        match (reader.read()) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }
}