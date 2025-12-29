
when defined(js):
  import std/jsffi
  import ./dispatch
  import ./denoAttrs
  const
    InNodeJs = defined(nodejs)

  let noConstants = constantsMod.isNull
  template from_js_constImpl[T](econsts; name; defVal: T): T =
    bind isUndefined, to, `[]`, noConstants
    let n{.importjs: constantsModInJs & '.' & astToStr(name).}: JsObject
    if noConstants or n.isUndefined: defVal else: n.to(T)

  template from_js_const*[T](name; defval: T): T =
    bind constantsMod
    from_js_constImpl(constantsMod, name, defval)

  let os_constants*{.importNode(os, constants).}: JsObject
  when defined(nodejs):
    assert not os_constants.isUndefined

