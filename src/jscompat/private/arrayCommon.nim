
import ./idxChkUtils
export idxChkUtils

template genBasicArrOps*(JsArray) {.dirty.} =
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

  proc indexOf*[T](arr: JsArray[T]; x: T, fromIndex: cint = 0): cint{.importcpp.}
  proc find*[T](arr: JsArray[T]; x: T, fromIndex: int = 0): int = int arr.indexOf(x, fromIndex.cint)
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

  proc reverse*(arr: JsArray) {.importcpp.}

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

