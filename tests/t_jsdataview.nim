discard """
  targets: "js"
"""

import std/unittest
import jscompat/utils/[jsarraybuffer, jsdataview]

test "DataView over ArrayBuffer":
  let ab = newArrayBuffer(16)
  let dv = newDataView(ab)
  check dv.byteLength == 16
  check dv.byteOffset == 0
  check dv.len == 16
  check dv.buffer.byteLength == 16

test "DataView with offset and length":
  let ab = newArrayBuffer(16)
  let dv = newDataView(ab, 4, 8)
  check dv.byteLength == 8
  check dv.byteOffset == 4

test "DataView integer get/set":
  let ab = newArrayBuffer(16)
  let dv = newDataView(ab)
  dv.setUint8(0, 255)
  check dv.getUint8(0).int == 255
  dv.setInt8(1, -5)
  check dv.getInt8(1).int == -5
  dv.setUint16(2, 0x1234)
  check dv.getUint16(2).int == 0x1234
  dv.setInt16(4, -1234)
  check dv.getInt16(4).int == -1234
  dv.setUint32(6, 0xdeadbeef'u32)
  check dv.getUint32(6) == 0xdeadbeef'u32
  dv.setInt32(10, -123456)
  check dv.getInt32(10).int == -123456

test "DataView float get/set":
  let ab = newArrayBuffer(16)
  let dv = newDataView(ab)
  dv.setFloat32(0, 3.5'f32)
  check dv.getFloat32(0) == 3.5'f32
  dv.setFloat64(4, 2.718281828459045)
  check dv.getFloat64(4) == 2.718281828459045

test "DataView big int get/set":
  let ab = newArrayBuffer(16)
  let dv = newDataView(ab)
  dv.setBigUint64(0, 12345678901234567890'u64)
  check dv.getBigUint64(0) == 12345678901234567890'u64
  dv.setBigInt64(8, -9876543210'i64)
  check dv.getBigInt64(8) == -9876543210'i64

test "DataView little endian":
  let ab = newArrayBuffer(4)
  let dv = newDataView(ab)
  dv.setUint32(0, 0x01020304'u32, true)
  check dv.getUint8(0).int == 0x04
  check dv.getUint32(0, true) == 0x01020304'u32

test "DataView over SharedArrayBuffer":
  let sab = newSharedArrayBuffer(8)
  let dv = newDataView(sab)
  check dv.byteLength == 8
  dv.setUint16(0, 0xbeef)
  check dv.getUint16(0).int == 0xbeef
