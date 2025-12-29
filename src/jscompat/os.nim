
import ./private/utils

import std/os

genCompatStrImportJs getCurrentDir: "process.cwd()"

genCompatStrImportJs getAppFilename: "process.argv[1]"

when Js:
  import ./utils/dispatch
  proc existsSync(fp: cstring): bool{.importjs: fs"existsSync".}
  #XXX: not suitable but cannot found another handy api
#proc fileExistsCompat*(fp: string): bool = jsOr existsSync(cstring fp), fileExists(fp)

  proc path_isAbsolute(path: cstring): bool{.importjs: node_path"isAbsolute".}

proc fileExists(filename: string): bool{.toCompatUseStdOrJs.} = existsSync cstring filename


const
  weirdTarget* = defined(nimscript) or defined(js)
  supportedSystem* = weirdTarget or defined(windows) or defined(posix)

proc isAbsolute(path: string): bool {.toCompatUseStdOrJs, noSideEffect, raises: [].} =
  path_isAbsolute(cstring path)

proc absolutePath(path: string, root = when supportedSystem: getCurrentDirCompat() else: ""): string{.toCompatUseStdOrJs.} =
  if isAbsoluteCompat(path): path
  else:
    if not root.isAbsoluteCompat:
      raise newException(ValueError, "The specified root is not absolute: " & root)
    joinPath(root, path)

when isMainModule:
  echo fileExistsCompat "os.nim" #getAppFilenameCompat()

