
import std/macros
import std/jsffi
type
  Promise*[T] = JsObject

template wrapPromise[T](x: T): Promise[T] = cast[Promise[T]](x) ## \
## async's result will be wrapped by JS as Promise'
## this is just to bypass Nim's type system
template wrapPromise[T](x: Promise[T]): Promise[T] = x

macro async*(def): untyped =
  var origType = def.params[0]
  let none = origType.kind == nnkEmpty
  if none: origType = bindSym"void"

  def.params[0] = nnkBracketExpr.newTree(bindSym"Promise", origType)
  if def.kind in RoutineNodes:
    def.addPragma nnkExprColonExpr.newTree(
        ident"codegenDecl",
        newLit"async function $2($3)"
    )
    if not none:
      def.body = newCall(nnkBracketExpr.newTree(bindSym"wrapPromise", origType), def.body)
  def

#template await*[T](exp: Promise[T]): T = {.emit: ["await ", exp].}

## XXX: top level await, cannot be in functions
template waitFor*[T](exp: Promise[T]): T =
  let e = exp
  var t: T
  {.emit: [t, " = await ", e].}
  # " <- for code hint
  t
template waitFor*(exp: Promise[void]) =
  let e = exp
  {.emit: ["await ", e].}

template await*[T](exp: Promise[T]): T =
  waitFor exp


proc Promise_resolve[T](x: T): Promise[T]{.importjs: "Promise.resolve(@)".}
template newPromise*[T](x: T): Promise[T] =
  Promise_resolve(x)

