discard """
  targets: "js"
"""

import std/unittest
import std/jsffi
import jscompat/utils/[jsarrays, jstypedarrays, jstypedarraysOps]

const
  uniHello = "你好"
  uniHelloNums = [
    uint8 228, 189, 160, 229, 165, 189]
test "unicode toUint8Array":
  check uniHello.toUint8Array == newUint8Array uniHelloNums

suite "toNimString":
  test "var":
    var s = "abc"
    check s.toJs[:string].isArray()
  test "var unicode":
    var s = uniHello
    let sJs = s.toJs[:string]
    check sJs.isArray()

    let res = sJs.to JsArray[cint]
    check res.len == uniHelloNums.len
    for i, e in res:
      check e == uniHelloNums[i].cint


