
template declarePlainNonAsync* {.dirty.} =
  template mayAsync*(def): untyped = def
  template mayAwait*(x): untyped = x
  template mayWaitFor*(x): untyped = x
  template mayNewPromise*(x): untyped = x
  type MayPromise*[T] = T

when not defined(js):
  declarePlainNonAsync
else:
  import ./asyncIfJs/js
  type
    MayPromise*[T] = Promise[T]

  template mayAsync*(def): untyped =
    bind async
    async(def)
  template mayAwait*(x): untyped =
    bind await
    await x
  template mayWaitFor*(x): untyped =
    ## top level await
    bind waitFor
    waitFor x
  
  template mayNewPromise*(x): untyped =
    bind newPromise
    newPromise(x)

