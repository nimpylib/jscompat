
import std/jsffi
import std/macros


macro genNew*(TAndParams) =
  TAndParams.expectKind {nnkCall, nnkObjConstr}
  let T = TAndParams[0]
  var pparams = newSeq[NimNode]()
  let isGeneric = T.kind == nnkBracketExpr
  let emptyn = newEmptyNode()
  var generics = emptyn
  let TBare = if isGeneric:
    generics = nnkGenericParams.newTree
    let TT = T.copyNimNode.add T[0]
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
      else:
        error "unreachable", e
      generics.add g
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


template genAttr*(name; R: untyped = JsObject) {.dirty.} =
  func name*(self): R{.importjs: "(#)." & astToStr(name).}

