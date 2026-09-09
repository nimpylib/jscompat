discard """
  targets: "js"
"""

import std/unittest
import jscompat/utils/[jsarraybuffer, jsencodings, jstypedarrays]

test "TextEncoder encode":
  let enc = newTextEncoder()
  check enc.encoding == cstring"utf-8"
  let bytes = enc.encode("hello")
  check bytes.len == 5

test "TextEncoder encodeInto":
  let enc = newTextEncoder()
  let target = newUint8Array(16)
  let res = enc.encodeInto("hello", target)
  check res.read == 5
  check res.written == 5

test "TextDecoder defaults":
  let dec = newTextDecoder()
  check dec.encoding == cstring"utf-8"
  check dec.fatal == false
  check dec.ignoreBOM == false

test "TextDecoder decode":
  let enc = newTextEncoder()
  let dec = newTextDecoder()
  check ($dec.decode(enc.encode("hello"))) == "hello"

test "TextDecoder unicode roundtrip":
  let enc = newTextEncoder()
  let dec = newTextDecoder()
  let s = "héllo wörld"
  check ($dec.decode(enc.encode(s))) == s

test "TextDecoder with options":
  let dec = newTextDecoder("utf-8", TextDecoderOptions{fatal: true})
  check dec.fatal == true
  check dec.ignoreBOM == false

test "TextDecoder decode with stream option":
  let enc = newTextEncoder()
  let dec = newTextDecoder()
  let encoded = enc.encode("abc")
  check ($dec.decode(encoded, DecodeOptions{stream: true})) == "abc"
