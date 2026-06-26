
import ./private/utils



when defined(wasi):
  import ./cmdline_wasi
  proc getAppFilename: string = paramStr 0

  import std/os except getAppFilename
else:
  import std/os

genCompatStrImportJs getCurrentDir: "process.cwd()"

genCompatStrImportJs getAppFilename: "process.argv[1]"

when Js:
  import ./utils/[dispatch, jspure]
  import std/jsffi
  proc statSync(fp: cstring): JsObject{.handleOnPureJsOrimportjs: fs"statSync".}
  template gen(name, fun) {.dirty.} =
    proc name(fp: cstring): bool =
      var statRes: JsObject
      {.emit: [  #" <- lint
        "try{", statRes, "=", statSync(fp), "}catch{return false}"].}
      statRes.fun().to bool
  gen fileExistsJs, isFile
  gen dirExistsJs, isDirectory
#proc fileExistsCompat*(fp: string): bool = jsOr existsSync(cstring fp), fileExists(fp)
  proc path_isAbsolute(path: cstring): bool{.handleOnPureJsOrimportjs: node_path"isAbsolute".}

proc fileExists(filename: string): bool{.toCompatUseStdOrJs.} = fileExistsJs cstring filename
proc  dirExists(filename: string): bool{.toCompatUseStdOrJs.} =  dirExistsJs cstring filename


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

