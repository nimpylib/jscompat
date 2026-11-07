
import std/jsffi
template genXIsX*(X) =
  bind JsObject
  const s = astToStr(X)
  proc `is X`*(o: JsObject): bool {.importjs: s&".is"&s&"(#)".}

