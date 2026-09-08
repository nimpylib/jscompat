

import std/jsffi
type
  ArrayBuffer*{.importjs.} = distinct JsObject
  ArrayBufferOptions*{.pure.} = ref object
    maxByteLength*: cint
proc newArrayBuffer*(length: cint, options = ArrayBufferOptions{}): ArrayBuffer {.importjs: "new ArrayBuffer(@)".}

using self: ArrayBuffer
template genAttr(name; R: untyped = JsObject) {.dirty.} =
  func name*(self): R{.importjs: "(#)." & astToStr(name).}

func isView*(self): bool {.importcpp.}

genAttr byteLength, cint
genAttr maxByteLength, cint
genAttr detached, bool
genAttr resizable, bool

proc resize*(self; newLength: cint) {.importcpp.}

func slice*(self; start = cint 0, `end` = cint self.byteLength): ArrayBuffer {.importcpp.}

func len*(self): int = self.byteLength.int

when isMainModule:
  assert 8 == len newArrayBuffer(8)
