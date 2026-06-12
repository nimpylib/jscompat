
const Jspure* = defined(jspure)


import std/macros
when defined(nimPreviewSlimSystem):
  import std/assertions

macro handleOnPureJsOrimportjs*(jsExpr, def) =
  when Jspure:
    let doAssert = bindSym"doAssert"
    def.body = quote do:
      `doAssert` false
  else:
    def.addPragma nnkExprColonExpr.newTree(ident"importjs", jsExpr)
  return def

