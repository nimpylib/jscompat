


import std/jsffi
import ./private/[jsffiMacros, results]
export results
import ./[jsdataview, jsarraybuffer, jstypedarrays]

declareJsType TextEncoder:
  encoding: cstring
declareJsType TextDecoder:
  encoding: cstring
  fatal: bool
  ignoreBOM: bool

declareJsObject TextDecoderOptions:
  fatal: bool
  ignoreBOM: bool

declareJsObject DecodeOptions:
  stream: bool

using self: TextDecoder
genNew TextDecoder(label = cstring"utf-8", options = TextDecoderOptions{})

proc decode*(self; s: ArrayBuffer|TypedArray|DataView): cstring {.importcpp.}
proc decode*(self; s: ArrayBuffer|TypedArray|DataView, options: DecodeOptions): cstring {.importcpp.}


using self: TextEncoder
genNew TextEncoder()

proc encode*(self; s: cstring): TypedArray[uint8, ArrayBuffer] {.importcpp.}
proc encodeInto*(self; s: cstring, a: TypedArray[uint8, ArrayBuffer]): EncodeIntoResult {.importcpp.}

when isMainModule:
  import std/jsconsole
  console.log newTextDecoder()

