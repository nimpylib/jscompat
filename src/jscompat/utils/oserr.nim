

when NimMajor > 1:
  from std/oserrors import OSErrorCode
else:
  from std/os import OSErrorCode

const
  InNodeJs* = defined(nodejs)

import ./consts
import ./private/catchJsErrAux

const DEF_INT = low(int)
let
  ErrExist* = from_js_const(EEXIST, DEF_INT)
  ErrNoent* = from_js_const(ENOENT, DEF_INT)
  ErrIsdir* = from_js_const(EISDIR, DEF_INT)

proc jsErrnoMsg*(errorCode: OSErrorCode): string =
  let ie = errorCode.int
  if ie == ErrExist: "File exists"
  elif ie == ErrNoent: "No such file or directory"
  elif ie == ErrIsdir: "Is a directory"
  else: "<unmapped error msg yet>"


const fallbackV = low cint
proc isErrnoSet*(e: cint): bool =
  ## internal.
  e != 0 and e != fallbackV

template st {.dirty.} =
  bind fallbackV
  {.emit: [`res@jscompat`, " = (-e.errno)",
    # without following, res may become NaN due to `-undefined`
    "?? ", fallbackV, ";"
  ].}

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

