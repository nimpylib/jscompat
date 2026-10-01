
import ../utils/catchJsErr
import ./idxChkUtils
export idxChkUtils

template genBasicArrOps*(JsArray) {.dirty.} =
  bind jsTryAsError
  proc length*(arr: JsArray): cint{.importjs: "#.length".}
  proc len*(arr: JsArray): int {.inline.} = arr.length.int
  proc high*(arr: JsArray): int = arr.len - 1
  proc toString*(arr: JsArray): cstring{.importcpp.}
  proc `$`*(arr: JsArray): string =
    result.add '['
    let L = arr.length
    if L > 0:
      result.add $arr[0]
      for i in 1..<L:
        result.add ", "
        result.add $arr[i]
    result.add ']'

  type JsCb[T, Arr, R] = proc (element: T, idx: cint, arr: Arr): R
  template gen(nimName, jsName, R; CbR: untyped = R) {.dirty.} =
    proc jsName*[T](arr: JsArray[T];
      callbackFn: JsCb[T, typeof(arr), CbR],
      thisArg: JsObject = jsUndefined): R {.importcpp.}
    proc nimName*[T](arr: JsArray[T], cb: proc(ele: T) {.closure.}): R =
      arr.jsName proc (element: T, _: cint, _: typeof(arr)) =
        cb(element)
  gen all, every: bool
  gen any, some: bool
  gen filter, filter, typeof(arr), bool
  gen map, map, typeof(arr), T
  proc findIndex*[T](arr: JsArray[T]; cb: JsCb[T, typeof(arr), bool]): cint {.importcpp.}
  proc findLastIndex*[T](arr: JsArray[T]; cb: JsCb[T, typeof(arr), bool]): cint {.importcpp.}
  proc join*[T](arr: JsArray[T]; sep: cstring): cstring {.importcpp.}
  proc join*[T](arr: JsArray[T]; sep=""): string =
    ##JS-DIFF: sep=","
    for c in arr.join cstring sep:
      result.add c
  
  type ReduceCb[T, Arr] = proc (accu, curVal: T, curIdx: int, arr: Arr): T
  proc reduce*[T](arr: JsArray[T]; callbackFn: ReduceCb[T, typeof(arr)],
                  init: T|JsObject = jsUndefined): T {.importcpp.}
  proc reduceRight*[T](arr: JsArray[T]; callbackFn: ReduceCb[T, typeof(arr)],
                  init: T|JsObject = jsUndefined): T {.importcpp.}

  # std/sequtils foldl, foldr works for JsArray

  proc indexOf*[T](arr: JsArray[T]; x: T, fromIndex: cint = 0): cint{.importcpp.}
  proc find*[T](arr: JsArray[T]; x: T, fromIndex: int = 0): int = int arr.indexOf(x, fromIndex.cint)
  proc lastIndexOf*[T](arr: JsArray[T]; x: T, fromIndex: cint = 0): cint{.importcpp.}
  proc rfind*[T](arr: JsArray[T]; x: T, fromIndex: int = 0): int = int arr.lastIndexOf(x, fromIndex.cint)
  proc contains*[T](arr: JsArray[T]; x: T): bool{.importcpp: "includes".}
  proc `[]`*[T](arr: JsArray[T]; i: cint): T{.importcpp: "#[#]", wrapChkIdx.}
  proc `[]=`*[T](arr: JsArray[T]; i: cint; x : T){.importcpp: "#[#] = #;", wrapChkIdx.}

  proc `[]`*[T](arr: JsArray[T]; i: int): T = arr[cint i]
  proc `[]=`*[T](arr: JsArray[T]; i: int; x : T) = arr[cint i] = x

  proc slice*[T](arr: JsArray[T]; start, stop: int): JsArray[T] {.importcpp.}
  proc `[]`*[T](arr: JsArray[T]; s: Slice[int]): JsArray[T] =
    bind chkSliceIdx
    chkSliceIdx(arr, s.a, s.b)
    arr.slice(s.a, s.b+1)
  proc `[]`*[T](arr: JsArray[T]; s: HSlice[int, BackwardsIndex]): JsArray[T] =
    let b = arr.len - int(s.b)
    arr[s.a..b]

  proc `[]`*[T](arr: JsArray[T]; i: BackwardsIndex): T = arr[arr.len-int(i)]
  proc `[]=`*[T](arr: JsArray[T]; i: BackwardsIndex; x: T) = arr[arr.len-int(i)] = x

  proc fillImpl[T](arr: JsArray[T]; x: T, start=0, `end` = arr.len
                         ): typeof(arr) {.discardable, importcpp: "fill".}
  proc fill*[T](arr: JsArray[T]; start, `end`: int, x: T) =
    arr.fillImpl x, start, `end`
  proc fill*[T](arr: JsArray[T]; x: T) = arr.fillImpl x

  proc withImpl[T](arr: JsArray[T]; index: cint, x: T): typeof(arr) {.importcpp: "with".}
  proc with*[T](arr: JsArray[T]; index: int, x: T): typeof(arr) =
    jsTryAsError IndexError: arr.withImpl cint index, x

  proc reverse*(arr: JsArray) {.importcpp.}
  proc reversed*[A: JsArray](arr: A): A {.importcpp: "toReversed".}
  #NOTE: JsArray's sort() (without compareFn given) uses
  # `(a, b: T) => a.toString().cmp b.toString()  (against utf-16 codepoints)
  proc sort*[T](arr: JsArray[T]; compareFn = cmp[T]) {.importcpp.}
  proc sorted*[T](arr: JsArray[T]; compareFn = cmp[T]
                    ): typeof(arr) {.importcpp: "toSorted".}

  iterator items*[T](arr: JsArray[T]): T =
    for i in jsffi.items cast[JsObject](arr): yield i.to T
  iterator pairs*[T](arr: JsArray[T]): (int, T) =
    var i = 0
    for e in arr:
      yield (i, e)
      i.inc

  proc `==`*[T](a, b: JsArray[T]): bool =
    if a.isNull: return b.isNull
    if b.isNull: return a.isNull
    if a.len != b.len: return
    for i, e in a:
      if e != b[i]: return
    return true

  proc `@`*[T](arr: JsArray[T]): seq[T] =
    result = (when declared(newSeqUninit): newSeqUninit else: newSeq)[T](arr.len)
    for i, e in arr:
      result[i] = e

