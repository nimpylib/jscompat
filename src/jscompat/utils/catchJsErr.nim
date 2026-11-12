
import pkg/errno/errnoUtils
import pkg/jsbuiltins/catchJsErr as catchJsErrAux
import ./oserr
export catchJsErrAux

template jsTryAsIOError*(body) =
  bind catchJsErrAsCode, isErrnoSet
  bind setErrnoRaw
  var errMsg: string
  let e = catchJsErrAsCode(errMsg, doBody=body)
  if isErrnoSet e:
    setErrnoRaw e
    raise newException(IOError, errMsg)

