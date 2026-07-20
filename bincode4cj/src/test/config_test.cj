// config_test.cj — Tests for configuration system
package bincode4cj.test
import bincode4cj.{ standard, legacy, Endianness, IntEncoding, BigEndian, LittleEndian, Fixint, Varint, NoLimit }
import std.unittest.*

@Test
public class ConfigTests {
    @TestCase
    public func test_standard_config() {
        let config = standard
        @Expect(config.endianness(), Endianness.Little)
        @Expect(config.int_encoding(), IntEncoding.Variable)
        @Expect(config.limit(), Option<Int64>.None)
    }

    @TestCase
    public func test_legacy_config() {
        let config = legacy
        @Expect(config.endianness(), Endianness.Little)
        @Expect(config.int_encoding(), IntEncoding.Fixed)
        @Expect(config.limit(), Option<Int64>.None)
    }

    @TestCase
    public func test_big_endian() {
        let config = standard.with_big_endian()
        @Expect(config.endianness(), Endianness.Big)
    }

    @TestCase
    public func test_little_endian() {
        let config = standard.with_little_endian()
        @Expect(config.endianness(), Endianness.Little)
    }

    @TestCase
    public func test_variable_int_encoding() {
        let config = standard.with_variable_int_encoding()
        @Expect(config.int_encoding(), IntEncoding.Variable)
    }

    @TestCase
    public func test_fixed_int_encoding() {
        let config = standard.with_fixed_int_encoding()
        @Expect(config.int_encoding(), IntEncoding.Fixed)
    }

    @TestCase
    public func test_with_no_limit() {
        let config = standard.with_no_limit()
        @Expect(config.limit(), Option<Int64>.None)
    }

    @TestCase
    public func test_marker_types() {
        @Expect(BigEndian.endianness(), Endianness.Big)
        @Expect(LittleEndian.endianness(), Endianness.Little)
        @Expect(Fixint.int_encoding(), IntEncoding.Fixed)
        @Expect(Varint.int_encoding(), IntEncoding.Variable)
        @Expect(NoLimit.limit(), Option<Int64>.None)
    }

    @TestCase
    public func test_marker_instances() {
        let be = BigEndian()
        let le = LittleEndian()
        let fi = Fixint()
        let vi = Varint()
        let nl = NoLimit()
        @Expect(BigEndian.endianness(), Endianness.Big)
        @Expect(LittleEndian.endianness(), Endianness.Little)
        @Expect(Fixint.int_encoding(), IntEncoding.Fixed)
        @Expect(Varint.int_encoding(), IntEncoding.Variable)
        @Expect(NoLimit.limit(), Option<Int64>.None)
    }
}