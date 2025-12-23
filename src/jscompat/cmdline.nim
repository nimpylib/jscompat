
import ./private/utils
when defined(js):
  import std/jsffi
  type Argv = JsObject
  let argv{.importjs: "process.argv".}: Argv
  proc len(a: Argv): int{.importjs: "#.length".}

  const argsStart = 2

import std/cmdline

genCompatFromOrJs paramCount: argv.len - argsStart

genCompatFromOrJs paramStr:
  let ii = i + 1  #[- 1 + argsStart]#
  let res = argv[ii]
  if res.isUndefined:
    raise newException(IndexDefect, formatErrorIndexBound(i, argv.len - argsStart))
  $(res.to cstring)

genCompatFromOrJs commandLineParams:
  let L = argv.len
  let argn = L - argsStart
  result = newSeqOfCap[string](argn)
  for i in argsStart ..< L:
    result.add $(argv[i].to cstring)

when isMainModule:
  #echo commandLineParamsCompat()
  echo paramStrCompat 0

