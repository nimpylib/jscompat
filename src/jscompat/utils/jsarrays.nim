
import std/jsffi
import ../private/[arrayCommon, ffiGen]
import ./private/jsffiMacros

declareJsType Array[T]

type JsArray*[T] = Array[T]
proc newJsArray*[T=JsObject]: JsArray[T]{.importjs: "[@]".}
proc add*[T](arr: JsArray[T]; x: T){.importcpp: "push".}
proc newJsArrayUninit*[T](n: Natural): JsArray[T]{.importjs: "new Array(#)".}  ## Fill with empty slots

genXIsX Array

using arr: JsArray

genBasicArrOps JsArray

proc pop*[T](arr: JsArray[T]): T{.importcpp, wrapChkIdx(0).}
proc delete*(arr: JsArray; i: int) {.importjs: "#.splice(#, 1)", wrapChkIdx.}
proc del*(arr: JsArray; i: int) =
  arr.chkIdx i
  discard jsDelete arr[i]
  if arr.len > 0:
    `[]= unchkIdx`(arr, i, arr.pop())

proc newJsArray*[T](n: Natural): JsArray[T] =
  result = newJsArrayUninit[T](n)
  for i in 0..<n:
    `[]= unchkIdx` result, i, default T
proc newJsArray*[T](x: openArray[T]): JsArray[T] =
  result = newJsArrayUninit[T](x.len)
  for i, e in x:
    `[]= unchkIdx` result, i, e

when isMainModule:
  assert newJsArray[]().len == 0

  let oriData = [1, 2, 3, 4]
  let a = newJsArray(oriData)

  import std/sequtils

  assert a == newJsArray(toSeq 1..4)
  assert @a == @oriData
  a[0] = 10
  assert a[0] == 10
  assert 2 in a
  assert @a == @[10, 2, 3, 4]
  a.del 0
  assert @a == @[4, 2, 3]
  a.delete 0
  var ls: seq[int]
  for e in a: ls.add e
  assert ls == @[2, 3]
  assert @a == ls

