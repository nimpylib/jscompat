
import ./jscompat/private/utils

proc quit(errorcode: int = QuitSuccess){.toCompatUseStdOrJs.} =
  proc exit(i: cint){.importjs: "process.exit(#)".}
  exit errorcode

when isMainModule:
  quitCompat 1

