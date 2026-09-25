discard """
  targets: "js"
"""

import std/unittest
import jscompat/utils/[jstypedarrays, jstypedarraysOps]

test "unicode toUint8Array":
  check "你好".toUint8Array == newUint8Array [
    uint8 228, 189, 160, 229, 165, 189]

