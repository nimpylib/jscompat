
import ./private/utils
when defined(js):
  import ./utils/[dispatch, catchJsErr, jspure, jsbuffer, jstypedarraysOps]

  # without {'encoding': ...} option, Buffer returned
  proc readFileSync(p: cstring): Buffer{.handleOnPureJsOrimportjs: fsDeno"readFileSync".}
  proc writeFileSync(p, data: cstring){.handleOnPureJsOrimportjs: fsDeno"writeFileSync".}
  # there is existsSync in deno's @std/fs, but that must be added as a JSR dependency

when defined(nimPreviewSlimSystem):
  import std/syncio

genCompatFromOrJs readFile:
  var res: string
  jsTryAsIOError:
    res = readFileSync(cstring filename).toNimString
  res
proc writeFile(filename, content: string){.toCompatUseStdOrJs.} =
  jsTryAsIOError writeFileSync(cstring filename, cstring content)

when isMainModule:
  echo readFileCompat currentSourcePath()

