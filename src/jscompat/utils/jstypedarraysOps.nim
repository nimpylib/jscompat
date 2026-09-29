

import ./jstypedarrays
import ./jsarraybuffer
export jstypedarrays
# XXX: this relies on assumption: Nim openArray[char] is represeted as
#  UTF-8 Array[Number] or Uint8[Clamped]Array/Int8Array in js.
# tho it's correct currently, no gurantee from official.
proc toUint8Array*(s: openArray[char]): TypedArray[uint8, ArrayBuffer] {.
  importjs: "Uint8Array.from(#)".}

when not defined(release):
  # one-time runtime assert
  when defined(nimPreviewSlimSystem):
    import std/assertions
  using s: string
  proc isUtf8Array(s; arr: openArray[int]) =
    proc isArray(s): bool {.importjs: "Array.isArray(#)".}
    proc length(s): cint {.importjs: "#.length".}
    proc at(s; i: int): cint {.importjs: "#[#]".}
    assert s.isArray
    assert s.length == arr.len
    for i, e in arr:
      assert s.at(i) == cint e

  isUtf8Array "÷", [0xc3, 0xb7]

