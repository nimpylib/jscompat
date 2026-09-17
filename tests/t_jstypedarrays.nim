discard """
  targets: "js"
"""

import std/unittest
import std/jsffi
import jscompat/utils/[jstypedarrays, jsarraybuffer]

test "construction with length":
  let arr = newInt8Array(4)
  check arr.len == 4
  check arr.length == 4
  check arr.high == 3
  check arr.byteLength == 4
  check arr.byteOffset == 0

test "construction from openArray":
  let arr = newInt32Array([10'i32, 20, 30, 40])
  check arr.len == 4
  check @arr == @[10'i32, 20, 30, 40]

test "index get/set":
  let arr = newInt16Array(4)
  arr[0] = 5
  arr[1] = 6
  arr[2] = 7
  arr[3] = 8
  check arr[0] == 5
  check arr[1] == 6
  check arr[2] == 7
  check arr[3] == 8
  arr[0] = 100
  check arr[0] == 100

test "iteration and pairs":
  let arr = newUint8Array([1'u8, 2, 3, 4])
  var s: seq[uint8]
  for e in arr:
    s.add e
  check s == @[1'u8, 2, 3, 4]
  var ps: seq[(int, uint8)]
  for i, e in arr:
    ps.add (i, e)
  check ps == @[(0, 1'u8), (1, 2'u8), (2, 3'u8), (3, 4'u8)]

test "contains/find/indexOf":
  let arr = newFloat64Array([1.0, 2.0, 3.0, 4.0])
  check 3.0 in arr
  check 5.0 notin arr
  check arr.find(3.0) == 2
  check arr.find(5.0) == -1
  check arr.indexOf(4.0) == 3.cint

test "slice via []":
  let arr = newInt8Array([1'i8, 2, 3, 4, 5])
  let s = arr[1..3]
  check s.len == 3
  check @s == @[2'i8, 3, 4]
  let tail = arr[3..4]
  check @tail == @[4'i8, 5]
  let bt = arr[2..^2]
  check @bt == @[3'i8, 4]

test "slice bounds check":
  let arr = newInt8Array([1'i8, 2, 3])
  check arr[3..2].len == 0
  check arr[2..1].len == 0
  expect IndexDefect:
    discard arr[2..5]
  expect IndexDefect:
    discard arr[5..6]
  expect IndexDefect:
    discard arr[-1..1]
  expect IndexDefect:
    discard arr[0..^0]

test "reverse":
  let arr = newUint16Array([1'u16, 2, 3, 4])
  arr.reverse
  check @arr == @[4'u16, 3, 2, 1]

test "backwards index":
  let arr = newInt32Array([1'i32, 2, 3, 4])
  check arr[^1] == 4
  check arr[^2] == 3
  arr[^1] = 42
  check arr[3] == 42

test "string conversion":
  let arr = newInt8Array([1'i8, 2, 3])
  check $arr == "[1, 2, 3]"
  check $toString(arr) == "1,2,3"

test "equality and seq conversion":
  let a = newInt8Array([1'i8, 2, 3])
  let b = newInt8Array([1'i8, 2, 3])
  let c = newInt8Array([1'i8, 2, 4])
  check a == b
  check a != c
  check @a == @[1'i8, 2, 3]

test "buffer/byteLength/byteOffset layout":
  let arr = newInt32Array(4)
  check arr.byteLength == 16
  check arr.byteOffset == 0
  check arr.buffer.byteLength == 16

test "view over ArrayBuffer with offset and length":
  let ab = newArrayBuffer(16)
  let arr = newInt16Array(ab, 4, 4)
  check arr.byteOffset == 4
  check arr.byteLength == 8
  check arr.len == 4
  arr[0] = 1234
  check arr[0] == 1234

test "uint arrays":
  let arr = newUint32Array([0xdeadbeef'u32, 42'u32])
  check arr[0] == 0xdeadbeef'u32
  check arr[1] == 42'u32

test "float arrays":
  let f32arr = newFloat32Array([1.5'f32, 2.5'f32])
  check f32arr[0] == 1.5'f32
  check f32arr[1] == 2.5'f32
  let f64arr = newFloat64Array([1.5, 2.5])
  check f64arr[0] == 1.5
  check f64arr[1] == 2.5

test "Uint8Array methods":
  let u8arr = newUint8Array([1'u8, 2])
  if u8arr.toJs.toHex.isUndefined:
    skip()
    # these methods not supported till node25
  else:
    check u8arr.toHex == "0102"
    check u8arr.toBase64 == "AQI="

test "big int arrays":
  let arr = newBigInt64Array([0'i64, 1, 2, -3])
  check arr.len == 4
  check arr[0] == 0'i64
  check arr[3] == -3'i64
  arr[0] = 9
  check arr[0] == 9'i64

test "big uint arrays":
  let arr = newBigUint64Array([0'u64, 12345678901234567890'u64])
  check arr[0] == 0'u64
  check arr[1] == 12345678901234567890'u64
