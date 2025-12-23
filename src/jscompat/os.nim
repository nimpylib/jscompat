
import ./private/utils

import std/os

genCompatStrImportJs getCurrentDir: "process.cwd"

genCompatStrImportJs getAppFilename: "process.argv[1]"

when isMainModule:
  echo getAppFilenameCompat()

