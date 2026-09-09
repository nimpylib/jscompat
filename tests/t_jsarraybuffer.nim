discard """
  targets: "js"
"""

import std/unittest
import jscompat/utils/jsarraybuffer

test "ArrayBuffer basics":
  let ab = newArrayBuffer(8)
  check ab.byteLength == 8
  check ab.maxByteLength == 8
  check ab.resizable == false
  check ab.detached == false
  check ab.len == 8

test "ArrayBuffer slice":
  let ab = newArrayBuffer(8)
  let s = ab.slice(2, 6)
  check s.len == 4

test "ArrayBuffer slice to end":
  let ab = newArrayBuffer(8)
  let s = ab.slice(4)
  check s.len == 4

test "ArrayBuffer resize":
  let ab = newArrayBuffer(8, ArrayBufferOptions{maxByteLength: 16})
  check ab.resizable == true
  ab.resize(16)
  check ab.byteLength == 16

test "SharedArrayBuffer basics":
  let sab = newSharedArrayBuffer(8)
  check sab.byteLength == 8
  check sab.maxByteLength == 8
  check sab.growable == false
  check sab.len == 8

test "SharedArrayBuffer grow":
  let sab = newSharedArrayBuffer(8, ArrayBufferOptions{maxByteLength: 16})
  check sab.growable == true
  sab.grow(16)
  check sab.byteLength == 16

test "SharedArrayBuffer slice":
  let sab = newSharedArrayBuffer(8)
  let s = sab.slice(1, 4)
  check s.len == 3
