
import std/jsffi
import ./private/jsffiMacros
import ./jsarraybuffer

declareJsType DataView[T: ArrayBuffer|SharedArrayBuffer]:
  buffer: T
  byteLength: cint
  byteOffset: cint

using self: DataView
func len*(self): int = self.byteLength.int

genNew DataView[T](buffer: T, byteOffset = cint 0, byteLength = buffer.byteLength)

const defLittleEndian* = false  # either is ok, we currently use bigEndian as in network such is used
template genGS(g, s, T, n){.dirty.} =
  bind DataView
  proc g*(d: DataView; i: int; isLittleEndian = defLittleEndian): T{.importcpp.}
  proc s*(d: DataView; i: int; v: T; isLittleEndian = defLittleEndian){.importcpp.}

template genIGS(n){.dirty.} =
  genGS `getUint n`, `setUint n`, `uint n`, n
  genGS `getInt n`, `setInt n`, `int n`, n
template genBigIGS(n) {.dirty.} =
  genGS `getBigUint n`, `setBigUint n`, `uint n`, n
  genGS `getBigInt n`, `setBigInt n`, `int n`, n
template genFGS(n){.dirty.} =
  genGS `getFloat n`, `setFloat n`, `float n`, n

genIGS 8
genIGS 16
genIGS 32
genBigIGS 64

#genFGS 16
genFGS 32
genFGS 64

