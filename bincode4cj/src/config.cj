// config.cj — Configuration system
package bincode4cj
import std.deriving.*

@Derive[Equatable]
public enum Endianness { Little | Big }
@Derive[Equatable]
public enum IntEncoding { Fixed | Variable }

public interface EndianConfig { static func endianness(): Endianness }
public interface IntEncodingConfig { static func int_encoding(): IntEncoding }
public interface LimitConfig { static func limit(): Option<Int64> }

public interface Config {
    func endianness(): Endianness
    func int_encoding(): IntEncoding
    func limit(): Option<Int64>
}

public class BigEndian <: EndianConfig {
    public static func endianness(): Endianness { Endianness.Big }
}
public class LittleEndian <: EndianConfig {
    public static func endianness(): Endianness { Endianness.Little }
}
public class Fixint <: IntEncodingConfig {
    public static func int_encoding(): IntEncoding { IntEncoding.Fixed }
}
public class Varint <: IntEncodingConfig {
    public static func int_encoding(): IntEncoding { IntEncoding.Variable }
}
public class NoLimit <: LimitConfig {
    public static func limit(): Option<Int64> { Option<Int64>.None }
}

public class Configuration<E, I, L> <: Config where E <: EndianConfig, I <: IntEncodingConfig, L <: LimitConfig {
    public init() {}
    public func endianness(): Endianness { E.endianness() }
    public func int_encoding(): IntEncoding { I.int_encoding() }
    public func limit(): Option<Int64> { L.limit() }
    public func with_big_endian(): Configuration<BigEndian, I, L> { Configuration<BigEndian, I, L>() }
    public func with_little_endian(): Configuration<LittleEndian, I, L> { Configuration<LittleEndian, I, L>() }
    public func with_variable_int_encoding(): Configuration<E, Varint, L> { Configuration<E, Varint, L>() }
    public func with_fixed_int_encoding(): Configuration<E, Fixint, L> { Configuration<E, Fixint, L>() }
    public func with_no_limit(): Configuration<E, I, NoLimit> { Configuration<E, I, NoLimit>() }
}

public let standard: Configuration<LittleEndian, Varint, NoLimit> = Configuration<LittleEndian, Varint, NoLimit>()
public let legacy: Configuration<LittleEndian, Fixint, NoLimit> = Configuration<LittleEndian, Fixint, NoLimit>()