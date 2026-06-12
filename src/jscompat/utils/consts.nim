
when defined(js):
  import std/jsffi
  import ./dispatch
  import ./denoAttrs
  import ./jspure
  const
    InNodeJs = defined(nodejs)

  let noConstants = when defined(jspure): true else: constantsMod.isNull
  template from_js_constImpl[T](econsts; name; defVal: T): T =
    bind isUndefined, to, `[]`, noConstants
    let n{.importjs: constantsModInJs & '.' & astToStr(name).}: JsObject
    if noConstants or n.isUndefined: defVal else: n.to(T)

  when Jspure:
    let constantsMod = 0  # NIM-BUG: workaround for `bind constantsMod`
  template from_js_const*[T](name; defval: T): T =
    when Jspure: defval
    else:
      bind constantsMod
      from_js_constImpl(constantsMod, name, defval)

  when not Jspure:
    let os_constants*{.importNode(os, constants).}: JsObject
    when defined(nodejs):
      assert not os_constants.isUndefined

