
import std/jsffi
import std/macros

template collectGenerics(T: NimNode, TT): NimNode =
  let generics = newNimNode nnkGenericParams
  for i in 1..<T.len:
    let e = T[i]
    var g: NimNode
    case e.kind
    of nnkIdent:
      TT.add e
      g = newIdentDefs(e, emptyn)
    of nnkIdentDefs:
      for i in 0..<(e.len-2):
        TT.add e[i]
      g = e
    of nnkExprColonExpr:
      let id = e[0]
      TT.add id
      g = newIdentDefs(id, e[1])
    else:
      error "unreachable: " & $e.kind, e
    generics.add g
  generics

macro genNew*(TAndParams) =
  TAndParams.expectKind {nnkCall, nnkObjConstr}
  let T = TAndParams[0]
  var pparams = newSeq[NimNode]()
  let isGeneric = T.kind == nnkBracketExpr
  let emptyn = newEmptyNode()
  var generics = emptyn
  let TBare = if isGeneric:
    let TT = T.copyNimNode.add T[0]
    generics = collectGenerics(T, TT)
    pparams.add TT
    T[0]
  else:
    pparams.add T
    T

  var param = newNimNode nnkIdentDefs
  for i in 1..<TAndParams.len:
    let e = TAndParams[i]
    case e.kind
    of nnkIdentDefs:
      for ee in e:
        param.add ee
    of nnkIdent:
      param.add e
      continue
    of nnkExprColonExpr: param.add(e[0], e[1], emptyn)
    of nnkExprEqExpr: param.add(e[0], emptyn, e[1])
    else:
      error "unexpected kind for " & e.repr, e
    pparams.add param
    param = newNimNode nnkIdentDefs

  let Tname = $TBare
  result = newProc(ident("new" & Tname).postfix"*", pparams)
  result.addPragma nnkExprColonExpr.newTree(
    ident"importjs",
    newLit("new " & Tname & "(@)")
  )
  result[2] = generics


template genAttrWithStr(name; nameStr: string; R: untyped = JsObject) {.dirty.} =
  func name*(self): R{.importjs: "(#)." & nameStr.}
template genAttr*(name; R: untyped = JsObject) {.dirty.} =
  bind genAttrWithStr
  genAttrWithStr(name, astToStr(name), R)

proc expect2Call(field: NimNode) =
  field.expectKind nnkCall
  field.expectLen 2
proc nOf(e: NimNode, i: int, k: NimNodeKind): NimNode =
  result = e[i]
  result.expectKind k

proc declareJsTypeAux(nameMayWithGenerics, attrs: NimNode): NimNode =
  let emptyn = newEmptyNode()
  let isGeneric = nameMayWithGenerics.kind == nnkBracketExpr
  let name = if isGeneric:
    nameMayWithGenerics[0]
  else:
    nameMayWithGenerics
  result = newStmtList()

  let typDefSect = quote do:
    type `name`*{.importjs.} = distinct JsObject

  var generics = emptyn
  var genericParams: seq[NimNode]
  if isGeneric:
    generics = collectGenerics(nameMayWithGenerics, genericParams)
    typDefSect.nOf(0, nnkTypeDef)[1] = generics
  result.add typDefSect

  result.add quote do:
    converter toJsObject*(x: `name`): JsObject = JsObject(x)

  if attrs.len == 0: return
  attrs.expectKind nnkStmtList
  if attrs.len == 1 and attrs[0].kind == nnkDiscardStmt:
    return

  result.add quote do:
    using self: `name`
  for field in attrs:
    field.expect2Call
    let typ = field.nOf(1, nnkStmtList).nOf(0, nnkIdent)
    let typName = typ.strVal
    let id = field[0]
    let attrDef = getAst genAttrWithStr(id, id.strVal, ident typName)
    attrDef.expectKind {nnkProcDef, nnkFuncDef}
    if isGeneric:
      let param1Type = nnkBracketExpr.newTree(name)
      for T in genericParams:
        param1Type.add T
      attrDef[2] = generics.copyNimTree
      let params = attrDef.nOf(3, nnkFormalParams)
      params[1][1] = param1Type
    result.add attrDef

macro declareJsType*(nameMayWithGenerics; attrs) = declareJsTypeAux nameMayWithGenerics, attrs
macro declareJsType*(nameMayWithGenerics) =
  declareJsTypeAux nameMayWithGenerics, newEmptyNode()

macro declareJsObject*(name, attrs) =
  result = quote do:
    type
      `name`*{.pure.} = ref object
  let fields = newNimNode(nnkRecList, attrs)
  for field in attrs:
    field.expect2Call
    fields.add newIdentDefs(
      field[0].postfix"*", field[1]
    )
  result.nOf(0, nnkTypeDef)
        .nOf(2, nnkRefTy)
        .nOf(0, nnkObjectTy)[2] = fields

  result = newStmtList(result).add quote("@") do:
    template `{}`*(typ: typedesc[@name], xs: varargs[untyped]): auto =
      jsffi.`{}`(typ, xs)

