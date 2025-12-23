discard """
  targets: "c js"
"""

import std/[strutils, os]
import unittest

import jscompat/[
  os, cmdline,
]
test "os":
  let fullpath = getAppFilenameCompat()
  let last = fullpath.lastPathPart
  check last.startsWith "t_others"
  echo paramStrCompat 0

