
import std/macros
import std/jsffi

import ../private/arrayCommon
import ./jsarraybuffer

type
  TypedArray*[T] = distinct JsObject

genBasicArrOps TypedArray

using self: TypedArray
template genAttr(name; R: untyped = JsObject) {.dirty.} =
  func name*(self): R{.importjs: "(#)." & astToStr(name).}
genAttr buffer, ArrayBuffer
genAttr byteLength, cint
genAttr byteOffset, cint

func capName(s: string): string{.compileTime.} =
  char(s[0].int and ord('_')) & s[1..^1]

proc genNewTAAux(T: NimNode, symName = capName($T) & "Array"): NimNode =
  let
    typeName = newLit symName
    sym = ident("new" & symName)
    pra = nnkExprColonExpr.newTree(
      ident"importjs",
      newLit("new " & symName & "(@)")
    )
  result = quote do:
    func `sym`*(x: cint|TypedArray|ArrayBuffer = 0): TypedArray[`T`]{.`pra`.}
    func `sym`*(x: Natural): TypedArray[`T`] = `sym` x.cint
    func `sym`*(arrayLike: JsObject): TypedArray[`T`]{.`pra`.}
    func `sym`*(buffer: ArrayBuffer, byteOffset: cint): TypedArray[`T`]{.`pra`.}
    func `sym`*(buffer: ArrayBuffer, byteOffset, length: cint): TypedArray[`T`]{.`pra`.}
    proc `sym`*(x: openArray[`T`]): TypedArray[`T`] =
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


