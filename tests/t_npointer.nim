
discard """
  targets: "c js"
"""

import std/unittest

import jscompat/[
  npointer,
]
const Js = defined(js)
when Js:
  import jscompat/utils/[
    jstypedarrays, jsdataview,
  ]

suite "npointer":
  test "basic":
    let p = alloc0(4)
    #echo p.repr
    check 0 == p.getint8 0
    p.setUint16 2, 1
    check 1 == p.getint16(2)
    dealloc p

  test "asDataView":
    when not Js: skip()
    else:
      let p = alloc0(4)
      p.asDataViewIt:
        let arr = newUint8Array(it.buffer)
        arr[1] = 1
      check p.getint8(1) == 1
      dealloc p

