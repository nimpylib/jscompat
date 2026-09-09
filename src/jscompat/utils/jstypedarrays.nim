
import std/macros
import std/jsffi

import ../private/arrayCommon
import ./jsarraybuffer
import ./private/jsffiMacros

declareJsType TypedArray[T: SomeNumber, Buf: ArrayBuffer|SharedArrayBuffer]:
  # `genBasicArrOps` generates others
  buffer: Buf
  byteLength: cint
  byteOffset: cint

type TypedArrayMayShared[T] = TypedArray[T, auto]
genBasicArrOps TypedArrayMayShared

func capName(s: string): string{.compileTime.} =
  char(s[0].int and ord('_')) & s[1..^1]

proc genNewTAAux(T: NimNode, symName = capName($T) & "Array"): NimNode =
  let
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
      buffer: Buf, byteOffset, length: cint|JsObject = jsUndefined
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
genNewTA  int64, "BigInt64Array"

genNewTA uint8
genNewTA uint16
genNewTA uint32
genNewTA uint64, "BigUint64Array"

genNewTA float32
genNewTA float64

when isMainModule:
  let arr = newBigInt64Array([0i64, 1, 2])
  assert arr.len == 3, $arr.len
  arr[0] = 1
  assert arr[0] == 1


