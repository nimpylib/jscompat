discard """
  targets: "c js"
"""

import std/[strutils, os]
import unittest

import jscompat/[
  os, cmdline, syncio, envvars, oserrors,
]

template check_is_this_file_result(s: string) =
  check s.lastPathPart.startsWith"t_others"
  # XXX: renaming this file requires update string above

test "os": 
  check_is_this_file_result getAppFilenameCompat()
  check fileExistsCompat currentSourcePath()
  check not fileExistsCompat "."
  check not dirExistsCompat currentSourcePath()
  check dirExistsCompat "."
  check isAbsoluteCompat getCurrentDirCompat()

test "cmdline":
  check_is_this_file_result paramStrCompat(0)
  check commandLineParams().len == 0

proc readNonExisting =
  expect IOError:
    discard readFileCompat "<?:*>"
test "syncio":
  let content = readFileCompat currentSourcePath()
  check content.startsWith "discard"
  readNonExisting()
 
test "envvars":
  const
    name = "NIMPYLIB_JSCOMPAT_T_ENVVARS"
    val = "12"
  putEnvCompat(name, val)
  check getEnvCompat(name) == val

test "oserrors":
  readNonExisting()
  let e = osLastErrorCompat()
  check e.ord != 0
  check osErrorMsgCompat(e).len > 0

