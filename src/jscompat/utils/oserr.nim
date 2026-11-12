
import std/jsffi
import pkg/handy_sugars/assumes
import pkg/errno
import pkg/jsbuiltins/[denoDetect,
                       consts, catchJsErr]
when NimMajor > 1:
  from std/oserrors import OSErrorCode
else:
  from std/os import OSErrorCode

const
  InNodeJs* = defined(nodejs)

when not InNodeJs:
  import std/tables

const DEF_INT = low(int)

template nodeOrDeno(node, deno): untyped =
  when InNodeJs: node
  else:
    if inDeno: deno
    else: node

proc jsErrnoMsg*(e: OSErrorCode): string =
  let ie = e.int
  errno.strerror ie

const fallbackV = low cint
proc isErrnoSet*(e: cint): bool =
  ## internal.
  e != 0 and e != fallbackV

proc getErrno(e: JsObject): cint =
  nodeOrDeno:
    if not isUndefined e.errno:
      -e.errno.to cint
    else:
      fallbackV
  do:
    let name = e.code.to cstring
    for k, v in pairs(errorcode):
      if v == name:
        return cint k
    unreachable("Not registered errno(ref Errno enum inpkg/errno)")
    # without following, res may become NaN due to `-undefined`
    #fallbackV

template st {.dirty.} =
  bind getErrno
  bind isUndefined, to, `.`
  let e{.importc.}: JsObject
  `res@jscompat` = getErrno(e)

template catchJsErrCodeToRes(doBody; exceptDo: untyped = st): cint {.dirty.} =
  bind jsTryCatchE
  block:
    # we use `...` to manually "genSym"
    var `res@jscompat`: cint = 0
    jsTryCatchE(doBody, exceptDo)
    `res@jscompat`

template catchJsErrCodeToResAndMsg(errMsg: var string; doBody): int =
  bind catchJsErrCodeToRes, st
  block:
    var jsRes: cstring
    let res = catchJsErrCodeToRes(doBody):
      st
      {.emit: [jsRes, " = e.message;"].}
    if res.isErrnoSet: errMsg = $jsRes
    res

template callJs(prc: proc()) =
  {.emit: [prc, "();"].}


template catchJsErrAsCode*(doBodyS: static string): cint =
  bind catchJsErrCodeToRes
  catchJsErrCodeToRes:
    {.emit: doBodyS.}

template catchJsErrAsCode*(prc: proc ()): cint =
  bind catchJsErrCodeToRes, callJs
  catchJsErrCodeToRes:
    callJs prc

template catchJsErrAsCode*(doBody): cint =
  bind catchJsErrCodeToRes
  catchJsErrCodeToRes doBody

template catchJsErrAsCode*(errMsg: var string; doBodyS: static string): cint =
  bind catchJsErrCodeToResAndMsg
  catchJsErrCodeToResAndMsg errMsg:
    {.emit: doBodyS.}

template catchJsErrAsCode*(errMsg: var string; prc: proc): cint =
  bind catchJsErrCodeToResAndMsg, callJs
  catchJsErrCodeToResAndMsg errMsg:
    callJs prc

template catchJsErrAsCode*(errMsg: var string; doBody): cint =
  bind catchJsErrCodeToResAndMsg
  catchJsErrCodeToResAndMsg errMsg, doBody

