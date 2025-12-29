
import ./private/utils

import std/os

genCompatStrImportJs getCurrentDir: "process.cwd()"

genCompatStrImportJs getAppFilename: "process.argv[1]"

when Js:
  import ./utils/dispatch
  proc existsSync(fp: cstring): bool{.importjs: fs"existsSync".}
  #XXX: not suitable but cannot found another handy api
#proc fileExistsCompat*(fp: string): bool = jsOr existsSync(cstring fp), fileExists(fp)

proc fileExists(filename: string): bool{.toCompatUseStdOrJs.} = existsSync cstring filename

when isMainModule:
  echo fileExistsCompat "os.nim" #getAppFilenameCompat()

