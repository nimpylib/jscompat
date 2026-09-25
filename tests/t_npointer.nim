
discard """
  targets: "c js"
"""

import std/[strutils, os]
import std/unittest


import jscompat/[
  npointer,
]

test "basic":
  let p = alloc0(4)
  #echo p.repr
  check 0 == p.getint8 0
  p.setUint16 2, 1
  check 1 == p.getint16(2)
  dealloc p

