
import ./private/utils
when defined(js):
  import std/jsffi
  import ./utils/dispatch
  proc bufferAsString(buf: JsObject): string =
    let n = buf.length.to int
    when declared(newStringUninit):
      result = newStringUninit(n)
      for i in 0..<n:
        result[i] = buf[i].to char
    else:
      for i in 0..<n:
        result.add buf[i]

  # without {'encoding': ...} option, Buffer returned
  proc readFileSync(p: cstring): JsObject{.importjs: fsDeno"readFileSync".}
  proc writeFileSync(p, data: cstring){.importjs: fsDeno"writeFileSync".}
  # there is existsSync in deno's @std/fs, but that must be added as a JSR dependency

when defined(nimPreviewSlimSystem):
  import std/syncio

genCompatFromOrJs readFile: readFileSync(cstring filename).bufferAsString
proc writeFile(filename, content: string){.toCompatUseStdOrJs.} =
  writeFileSync(cstring filename, cstring content)

when isMainModule:
  echo readFileCompat "syncio.nim"

