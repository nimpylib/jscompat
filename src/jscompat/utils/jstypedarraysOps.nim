

import ./jstypedarrays
import ./[jsarraybuffer, jsbuffer]
export jstypedarrays
# XXX: this relies on assumption: Nim openArray[char] is represeted as
#  UTF-8 Array[number] or Uint8[Clamped]Array/Int8Array in js.
# tho it's correct currently, no gurantee from official.
proc toUint8Array*(s: openArray[char]): TypedArray[uint8, ArrayBuffer] {.
  importjs: "Uint8Array.from(#)".}

# XXX: this relies on assumption: Nim's string is represented as Array[number]
proc toNimString*(s: TypedArray[uint8|int8, auto]|Buffer): string {.
  importjs: "Array.from(#)".}

# NOTE: jsffi.toJs(string) is specially overloaded,
#  converting an js Array to js string
when not defined(release):
  # one-time runtime assert
  when defined(nimPreviewSlimSystem):
    import std/assertions
  import std/jsffi
  import ./jsarrays
  using s: string
  proc isArray(s): bool =
    s.toJs[:string].isArray()
  proc isUtf8Array(s; arr: openArray[int]) =
    proc length(s): cint {.importjs: "#.length".}
    proc at(s; i: int): cint {.importjs: "#[#]".}
    assert s.isArray
    assert s.length == arr.len
    for i, e in arr:
      assert s.at(i) == cint e

  isUtf8Array "÷", [0xc3, 0xb7]

  block:
    var s = "abc"
    assert s.isArray()

