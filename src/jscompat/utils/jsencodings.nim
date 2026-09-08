


import std/jsffi
import ./private/jsffiMacros
import ./[jsdataview, jsarraybuffer, jstypedarrays]

type
  TextEncoder*{.importjs.} = distinct JsObject
  TextDecoder*{.importjs.} = distinct JsObject
  TextDecoderOptions*{.pure.} = ref object
    fatal*: bool
    ignoreBOM*: bool

  DecodeOptions*{.pure.} = ref object
    stream*: bool

  EncodeIntoResult*{.pure.} = ref object
    read*: cint
    written*: cint

using self: TextDecoder
genNew TextDecoder(label = cstring"utf-8", options = TextDecoderOptions{})

genAttr encoding: cstring
genAttr fatal: bool
genAttr ignoreBOM: bool
proc decode*(self; s: ArrayBuffer|TypedArray|DataView): cstring {.importcpp.}
proc decode*(self; s: ArrayBuffer|TypedArray|DataView, options: DecodeOptions): cstring {.importcpp.}


using self: TextEncoder
genNew TextEncoder()

genAttr encoding: cstring

proc encode*(self; s: cstring): TypedArray[uint8] {.importcpp.}
proc encodeInto*(self; s: cstring, a: TypedArray[uint8]): EncodeIntoResult {.importcpp.}

when isMainModule:
  import std/jsconsole
  console.log newTextDecoder()

