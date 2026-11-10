
import std/oserrors
import pkg/errno
when defined(js):
  import ./utils/oserr
import ./private/utils
when defined(js):
  proc setOsLastError*(e: OSErrorCode) =
    ## EXT. internal. unstable.
    setErrnoRaw e.cint

proc osLastError*(): OSErrorCode {.toCompatUseStdOrJs.} =
  OSErrorCode getErrno()

proc osErrorMsg*(errorCode: OSErrorCode): string {.toCompatUseStdOrJs.} =
  jsErrnoMsg errorCode

