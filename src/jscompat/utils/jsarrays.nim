
import std/jsffi
import ../private/arrayCommon

type JsArray*[T] = distinct JsObject#JsAssoc[int, T]

proc newJsArray*[T]: JsArray[T]{.importjs: "[@]".}
proc add*[T](arr: JsArray[T]; x: T){.importcpp: "push".}
proc newJsArray*[T](x: openArray[T]): JsArray[T] =
  result = newJsArray[T]()
  for i in x: result.add i
proc newJsArrayFillWithEmpty[T](n: Natural): JsArray[T]{.importjs: "new Array(#)".}


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
  result = newJsArrayFillWithEmpty[T](n)
  for i in 0..<n:
    `[]= unchkIdx` result, i, default T
when isMainModule:
  let oriData = [1, 2, 3, 4]
  let a = newJsArray[int](oriData)

  import std/sequtils

  assert a == newJsArray[int](toSeq 1..4)
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

