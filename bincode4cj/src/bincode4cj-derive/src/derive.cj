// derive.cj - bincode4cj derive macros
macro package bincode4cj_derive

import std.ast.*
import std.collection.*

// @deriveEncode - 生成 extend T <: Encode 并列在 class/enum 之后
public macro deriveEncode(input: Tokens): Tokens {
    let srcTokens = input
    let decl = parseDecl(input)

    // 尝试作为 ClassDecl 处理
    match (decl as ClassDecl) {
        case Some(classDecl) =>
            return deriveEncodeClass(srcTokens, classDecl)
        case None => ()
    }

    // 尝试作为 EnumDecl 处理
    match (decl as EnumDecl) {
        case Some(enumDecl) =>
            return deriveEncodeEnum(srcTokens, enumDecl)
        case None => ()
    }

    diagReport(DiagReportLevel.ERROR, input,
        "@deriveEncode 只能用于 class 或 enum", "")
    return input
}

func deriveEncodeClass(srcTokens: Tokens, classDecl: ClassDecl): Tokens {
    let className = classDecl.identifier.value

    var encodeBody = ""
    for (d in classDecl.body.decls) {
        match (d as VarDecl) {
            case Some(vd) =>
                encodeBody += "        this.${vd.identifier.value}.encode(config, buf)\n"
            case None => ()
        }
    }

    let code = "extend ${className} <: Encode {\n" +
        "    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {\n" +
        encodeBody +
        "    }\n" +
        "}\n"
    let extendTokens = cangjieLex(code)
    srcTokens + cangjieLex(";") + extendTokens
}

func deriveEncodeEnum(srcTokens: Tokens, enumDecl: EnumDecl): Tokens {
    let enumName = enumDecl.identifier.value

    // 构建 match(this) { case Ctor => ...; case Ctor(v) => {...} }
    var matchBody = ""
    var idx: Int64 = 0
    for (ctor in enumDecl.constructors) {
        let ctorName = ctor.identifier.value
        let typeArgs = ctor.typeArguments
        if (typeArgs.size == 0) {
            // 无参构造器：仅编码变体索引
            matchBody += "        case ${ctorName} => encode_u32(${idx}u32, config, buf)\n"
        } else {
            // 有参构造器：编码索引 + 逐字段编码（不用 {} 包裹，直接多行表达式）
            var binds = ""
            var encodes = ""
            var k: Int64 = 0
            while (k < typeArgs.size) {
                if (k > 0) { binds += ", " }
                binds += "v${k}"
                encodes += "            v${k}.encode(config, buf)\n"
                k += 1
            }
            matchBody += "        case ${ctorName}(${binds}) =>\n"
            matchBody += "            encode_u32(${idx}u32, config, buf)\n"
            matchBody += encodes
        }
        idx += 1
    }

    let code = "extend ${enumName} <: Encode {\n" +
        "    public func encode(config: Config, buf: ArrayList<UInt8>): Unit {\n" +
        "        match (this) {\n" +
        matchBody +
        "        }\n" +
        "    }\n" +
        "}\n"
    srcTokens + cangjieLex(";") + cangjieLex(code)
}

// @deriveDecode - 生成 extend T <: Decode<T> 并列在 class/enum 之后
public macro deriveDecode(input: Tokens): Tokens {
    let srcTokens = input
    let decl = parseDecl(input)

    match (decl as ClassDecl) {
        case Some(classDecl) =>
            return deriveDecodeClass(srcTokens, classDecl)
        case None => ()
    }

    match (decl as EnumDecl) {
        case Some(enumDecl) =>
            return deriveDecodeEnum(srcTokens, enumDecl)
        case None => ()
    }

    diagReport(DiagReportLevel.ERROR, input,
        "@deriveDecode 只能用于 class 或 enum", "")
    return input
}

func deriveDecodeClass(srcTokens: Tokens, classDecl: ClassDecl): Tokens {
    let className = classDecl.identifier.value

    var fieldTypes = ArrayList<String>()
    var fieldNames = ArrayList<String>()
    for (d in classDecl.body.decls) {
        match (d as VarDecl) {
            case Some(vd) =>
                fieldNames.add(vd.identifier.value)
                fieldTypes.add(vd.declType.toTokens().toString().trimAscii())
            case None => ()
        }
    }
    if (fieldNames.size == 0) { return srcTokens }

    var ctorArgs = ""
    var i: Int64 = 0
    while (i < fieldNames.size) {
        if (i > 0) { ctorArgs += ", " }
        ctorArgs += "v${i}"
        i += 1
    }

    var body = "MyResult.Ok((${className}(${ctorArgs}), p${fieldNames.size}))"

    var j = fieldNames.size - 1
    while (j >= 0) {
        let tname = fieldTypes[j]
        let pThis = if (j == 0) { "pos" } else { "p${j}" }
        body = "match (${tname}.decode(data, ${pThis}, config)) {\n" +
            "        case MyResult.Ok((v${j}, p${j + 1})) =>\n" +
            "            ${body}\n" +
            "        case MyResult.Err(e) => MyResult.Err(e)\n" +
            "    }"
        j -= 1
    }

    let code = "extend ${className} <: Decode<${className}> {\n" +
        "    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(${className}, Int64), DecodeError> {\n" +
        "        ${body}\n" +
        "    }\n" +
        "}\n"
    srcTokens + cangjieLex(";") + cangjieLex(code)
}

func deriveDecodeEnum(srcTokens: Tokens, enumDecl: EnumDecl): Tokens {
    let enumName = enumDecl.identifier.value
    let ctorCount = enumDecl.constructors.size

    if (ctorCount == 0) { return srcTokens }

    // 构建内层 match(idx) { case 0u32 => ...; case _ => Err(...) }
    var cases = ""
    var idx: Int64 = 0
    for (ctor in enumDecl.constructors) {
        let ctorName = ctor.identifier.value
        let typeArgs = ctor.typeArguments

        if (typeArgs.size == 0) {
            // 无参构造器：直接返回枚举值
            cases += "                case ${idx}u32 => MyResult.Ok((${enumName}.${ctorName}, p1))\n"
        } else {
            // 有参构造器：嵌套 decode 各字段
            var ctorArgList = ""
            var k: Int64 = 0
            while (k < typeArgs.size) {
                if (k > 0) { ctorArgList += ", " }
                ctorArgList += "v${k}"
                k += 1
            }

            // 从内向外构建嵌套 match
            let depth = typeArgs.size
            var body = "MyResult.Ok((${enumName}.${ctorName}(${ctorArgList}), p${depth + 1}))"
            var j = depth - 1
            while (j >= 0) {
                let tname = typeArgs[j].toTokens().toString().trimAscii()
                let pThis = if (j == 0) { "p1" } else { "p${j + 1}" }
                body = "match (${tname}.decode(data, ${pThis}, config)) {\n" +
                    "                    case MyResult.Ok((v${j}, p${j + 2})) =>\n" +
                    "                        ${body}\n" +
                    "                    case MyResult.Err(e) => MyResult.Err(e)\n" +
                    "                }"
                j -= 1
            }
            cases += "                case ${idx}u32 =>\n                    ${body}\n"
        }
        idx += 1
    }

    // 兜底：变体索引超出范围
    let maxIdx = ctorCount - 1
    cases += "                case _ => MyResult.Err(DecodeError.UnexpectedVariant(\"${enumName}\", AllowedEnumVariants.Range(0u32, ${maxIdx}u32), idx))\n"

    let code = "extend ${enumName} <: Decode<${enumName}> {\n" +
        "    public static func decode(data: Array<UInt8>, pos: Int64, config: Config): MyResult<(${enumName}, Int64), DecodeError> {\n" +
        "        match (decode_u32(data, pos, config)) {\n" +
        "            case MyResult.Ok((idx, p1)) =>\n" +
        "                match (idx) {\n" +
        cases +
        "                }\n" +
        "            case MyResult.Err(e) => MyResult.Err(e)\n" +
        "        }\n" +
        "    }\n" +
        "}\n"
    srcTokens + cangjieLex(";") + cangjieLex(code)
}
