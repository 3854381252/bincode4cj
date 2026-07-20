// lib_test.cj — Tests for lib.cj top-level API functions
package bincode4cj.test
import std.collection.*
import std.io.*
import std.unittest.*
import bincode4cj.{ standard, encode_into_slice, encode_into_writer, encode_into_std_write, decode_from_slice, decode_from_slice_with_context, decode_from_reader, decode_from_reader_with_context, decode_from_std_read, VecWriter, MyResult, DecodeError }

@Test
public class LibTests {
    @TestCase
    public func test_encode_into_slice() {
        let buf = ArrayList<UInt8>()
        encode_into_slice(42u8, standard, buf)
        @Expect(buf.size > 0)
    }

    @TestCase
    public func test_encode_into_writer() {
        let writer = VecWriter()
        encode_into_writer(42u8, standard, writer)
        @Expect(writer.collect().size > 0)
    }

    @TestCase
    public func test_encode_into_std_write() {
        let buf = ByteBuffer()
        encode_into_std_write(42u8, standard, buf)
        @Expect(buf.length > 0)
    }

    @TestCase
    public func test_decode_from_slice() {
        let buf = ArrayList<UInt8>(); buf.add(42u8)
        let data = buf.toArray()
        let r: MyResult<(UInt8, Int64), DecodeError> = decode_from_slice(data, standard)
        match (r) {
            case MyResult.Ok((val, _)) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_from_reader() {
        let buf = ArrayList<UInt8>(); buf.add(42u8)
        let data = buf.toArray()
        let r: MyResult<UInt8, DecodeError> = decode_from_reader(data, standard)
        match (r) {
            case MyResult.Ok(val) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_from_std_read() {
        let data = Array<Byte>(1, {_ => 42u8})
        let stream = ByteBuffer(data)
        let r: MyResult<UInt8, DecodeError> = decode_from_std_read(stream, standard)
        match (r) {
            case MyResult.Ok(val) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_from_slice_with_context() {
        let buf = ArrayList<UInt8>(); buf.add(42u8)
        let data = buf.toArray()
        let r: MyResult<(UInt8, Int64), DecodeError> = decode_from_slice_with_context(data, standard, ())
        match (r) {
            case MyResult.Ok((val, _)) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_from_reader_with_context() {
        let buf = ArrayList<UInt8>(); buf.add(42u8)
        let data = buf.toArray()
        let r: MyResult<UInt8, DecodeError> = decode_from_reader_with_context(data, standard, ())
        match (r) {
            case MyResult.Ok(val) => @Expect(val, 42u8)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_from_slice_error() {
        let data: Array<UInt8> = []
        let r: MyResult<(UInt8, Int64), DecodeError> = decode_from_slice(data, standard)
        match (r) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_decode_from_reader_error() {
        let data: Array<UInt8> = []
        let r: MyResult<UInt8, DecodeError> = decode_from_reader(data, standard)
        match (r) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }

    @TestCase
    public func test_encode_into_writer_multiple() {
        let writer = VecWriter()
        encode_into_writer(1u8, standard, writer)
        encode_into_writer(2u8, standard, writer)
        @Expect(writer.collect().size > 1)
    }

    @TestCase
    public func test_decode_from_std_read_error() {
        let data: Array<Byte> = []
        let stream = ByteBuffer(data)
        let r: MyResult<UInt8, DecodeError> = decode_from_std_read(stream, standard)
        match (r) {
            case MyResult.Err(_) => @Expect(true)
            case _ => @Expect(false)
        }
    }
}