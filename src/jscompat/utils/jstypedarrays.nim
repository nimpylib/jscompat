
import std/macros
import std/jsffi

import ../private/arrayCommon
import ./jsarraybuffer
import ./private/[jsffiMacros, results]
export results

declareJsType TypedArray[T: SomeNumber, Buf: ArrayBuffer|SharedArrayBuffer]:
  # `genBasicArrOps` generates others
  buffer: Buf
  byteLength: cint
  byteOffset: cint
  BYTES_PER_ELEMENT: cint

type TypedArrayMayShared[T] = TypedArray[T, auto]
genBasicArrOps TypedArrayMayShared

func capName(s: string): string{.compileTime.} =
  char(s[0].int and ord('_')) & s[1..^1]

template JsUndefined: JsObject =
  {.cast(noSideEffect).}:
    jsUndefined
proc genNewTAAux(T: NimNode, arrSymName = capName($T)): NimNode =
  let
    symName = arrSymName & "Array"
    sym = ident("new" & symName)
    pra = nnkExprColonExpr.newTree(
      ident"importjs",
      newLit("new " & symName & "(@)")
    )
  result = quote do:
    func `sym`*(x: cint|TypedArray = 0): TypedArray[`T`, ArrayBuffer]{.`pra`.}
    func `sym`*(x: Natural): TypedArray[`T`, ArrayBuffer] = `sym` x.cint
    func `sym`*(arrayLike: JsObject): TypedArray[`T`, ArrayBuffer]{.`pra`.}
    {.push warning[ImplicitDefaultValue]: off.}
    func `sym`*[Buf: ArrayBuffer|SharedArrayBuffer](
      buffer: Buf, byteOffset, length: cint|JsObject = JsUndefined
    ): TypedArray[`T`, Buf]{.`pra`.}
    {.pop.}
    proc `sym`*(x: openArray[`T`]): TypedArray[`T`, ArrayBuffer] =
      result = `sym`(x.len)
      for i, e in x: result[i] = e
macro genNewTA(T: typedesc) = genNewTAAux T
macro genNewTA(T: typedesc, symName: static[string]) = genNewTAAux T, symName

#func newTypedArray*[T](x: auto): TypedArray[T]{.importjs: "new " & toArrName($T) & "(#)".}
genNewTA  int8
genNewTA  int16
genNewTA  int32
genNewTA  int64, "BigInt64"

#TODO: TypedArray[T, Buf] cannot represent Uint8ClampedArray and Float16Array
#genNewTA uint8, "Uint8Clamped"
genNewTA uint8
genNewTA uint16
genNewTA uint32
genNewTA uint64, "BigUint64"

#genNewTA float64, "Float16"
genNewTA float32
genNewTA float64


declareJsObject FromBase64Options:
  alphabet: cstring = "base64"
  lastChunkHandling: cstring = "loose"

declareJsObject ToBase64Options:
  alphabet: cstring = "base64"
  omitPadding: bool = false

type Uint8Array = TypedArray[uint8, ArrayBuffer]
proc newUint8ArrayFromBase64*(str: cstring; options = FromBase64Options{}): Uint8Array {.importjs: "Uint8Array.fromBase64(@)".}
proc newUint8ArrayFromHex*(str: cstring): Uint8Array {.importjs: "Uint8Array.fromHex(@)".}

using self: TypedArrayMayShared[uint8]
proc setFromBase64*(self; str: cstring; options = FromBase64Options{}): EncodeIntoResult {.importcpp.}
proc setFromHex*(self; str: cstring): EncodeIntoResult {.importcpp.}

proc toBase64*(self; options = ToBase64Options{}): cstring {.importcpp.}
proc toHex*(self): cstring {.importcpp.}

when isMainModule:
  let arr = newBigInt64Array([0i64, 1, 2])
  assert arr.len == 3, $arr.len
  arr[0] = 1
  assert arr[0] == 1
  func f =
    # test noSideEffect
    let arr = newBigInt64Array([0i64, 1, 2])
    discard newBigInt64Array(arr.buffer)
  f()


