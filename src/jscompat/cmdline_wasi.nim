## This module provides command line argument support for WASI targets
##  for Nim's std/cmdline module,
##  and was transpliled from C code in
##    https://gist.github.com/litlighilit/616d4b3886792c99387a2a59031c1be8
when defined(nimPreviewSlimSystem):
  import std/assertions

static:assert defined(wasi)
import ./private/wasi

proc args_sizes_get(argc, argv_buf_size: var Size): Errno{.importc, codegenDecl: wasip1_decl.}
proc args_get(argv: ptr charp#[array[argc, charp]]#, argv_buf: ptr uint8): Errno{.importc, codegenDecl: wasip1_decl.}

# ref std/cmdline, when not(defined(posix) and appType == "lib"),
#  it requires:
var cmdCount: cint
var cmdLine: cstringArray

proc init*(){.cdecl.} =
  var argc, buf_size: Size
  var r: Errno
  r = args_sizes_get(argc, buf_size)

  assert (r==0)

  cmdCount = cint argc

  var buf{.global.}: ptr uint8
  buf = cast[ptr uint8](alloc(buf_size))
  let args = create(charp, argc)

  r = args_get(args, buf)
  assert (r==0)

  cmdLine = cast[typeof(cmdLine)](args)  #FIXME: leak memory

init()

proc paramStr*(i: int): string =
  if i < cmdCount or i >= 0:
    result = $cmdLine[i]
  else:
    raise newException(IndexDefect, formatErrorIndexBound(i, cmdCount-1))
proc paramCount*: int = cmdCount - 1
proc commandLineParams*: seq[string] =
  result = newSeqOfCap[string](cmdCount - 1)
  for i in 1 ..< cmdCount:
    result.add $cmdLine[i]

when isMainModule:
  echo commandLineParams()

