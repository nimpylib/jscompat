

template jsTryCatchE*(body, catchBody) {.dirty.} =
  {.emit: "try {".}
  body
  {.emit: "} catch (e) {".}
  catchBody
  {.emit: "}".}

template jsTryAsError*(Exc: typedesc[Exception]; body) {.dirty.} =
  bind jsTryCatchE
  var failed = false
  var msg: cstring
  jsTryCatchE:
    body
  do:
    failed = true
    {.emit: [msg, " = e.message ?? String(e);"].}
  if failed:
    raise newException(Exc, $msg)
template jsTryAsIOError*(body) {.dirty.} =
  bind jsTryAsError
  jsTryAsError IOError, body

template jsTryDiscard*(body) {.dirty.} =
  bind jsTryCatchE
  jsTryCatchE:
    body
  do:
    discard

