discard """
  targets: "c js"
"""

import std/[strutils, os]
import unittest

import jscompat/[
  os, cmdline, syncio
]

template check_is_this_file_result(s: string) =
  check s.lastPathPart.startsWith"t_others"
  # XXX: renaming this file requires update string above

test "os":
  check_is_this_file_result getAppFilenameCompat()
  check fileExistsCompat currentSourcePath()

test "cmdline":
  check_is_this_file_result paramStrCompat(0)
  check commandLineParams().len == 0

test "syncio":
  let content = readFileCompat currentSourcePath()
  check content.startsWith "discard"
  expect IOError:
    discard readFileCompat "<?:*>"
 

