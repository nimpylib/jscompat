

import std/jsffi
import ./private/jsffiMacros
type
  ArrayBuffer*{.importjs.} = distinct JsObject
  SharedArrayBuffer*{.importjs.} = distinct JsObject
  ArrayBufferOptions*{.pure.} = ref object
    maxByteLength*: cint

using self: ArrayBuffer|SharedArrayBuffer

genAttr byteLength, cint
genAttr maxByteLength, cint

func len*(self): int = self.byteLength.int

using self: ArrayBuffer
genAttr detached, bool
genAttr resizable, bool
func isView*(self): bool {.importcpp.}
proc resize*(self; newLength: cint) {.importcpp.}
func slice*(self; start = cint 0, `end` = cint self.byteLength): ArrayBuffer {.importcpp.}

using self: SharedArrayBuffer
genAttr growable, bool
proc grow*(self; newLength: cint) {.importcpp.}
func slice*(self; start = cint 0, `end` = cint self.byteLength): SharedArrayBuffer {.importcpp.}


genNew ArrayBuffer(length: cint, options = ArrayBufferOptions{})
genNew SharedArrayBuffer(length: cint, options = ArrayBufferOptions{})

when isMainModule:
  assert 8 == len newArrayBuffer(8)
