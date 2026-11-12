
import std/oserrors
import pkg/errno
when defined(js):
  import ./utils/oserr
import ./private/utils

proc osLastError*(): OSErrorCode {.toCompatUseStdOrJs.} =
  OSErrorCode getErrno()

proc osErrorMsg*(errorCode: OSErrorCode): string {.toCompatUseStdOrJs.} =
  jsErrnoMsg errorCode

