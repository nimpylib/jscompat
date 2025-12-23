
const Js* = defined(js)

template jsOr*(a, b): untyped =
  bind Js
  when Js: a else: b

import std/macros
template forParams(iddef, restypeParams, body) =
  for i in 1..<restypeParams.len:
    let iddef = restypeParams[i]
    body

template forIdents(id, iddef, body) =
  for i in 0..<iddef.len-2:  # the last 2 is type and defval
    let id = iddef[i]
    body


proc newCallFromFormalParams(oriName, params: NimNode): NimNode =
  let body = newStmtList nnkBindStmt.newTree oriName
  let call = newCall oriName
  forParams iddef, params:
    forIdents id, iddef:
      call.add id
  body.add call

template genCompatTmplAux(oriName, params; jsImplDo; elseDo) =
  let emptyn = newEmptyNode()
  let kind = when Js:
    nnkProcDef
  else:
    nnkTemplateDef

  result = newNimNode(kind).add(
    ident(oriName.strVal & "Compat").postfix"*",
    emptyn,
    emptyn,
    params,
    emptyn,  # pragma
    newEmptyNode(),
    #emptyn  # body
  )
  when Js:
    jsImplDo
  else:
    elseDo

template genCompatTmplAux(oriName, params; jsImplDo) =
  genCompatTmplAux(oriName, params, jsImplDo):
    result.add newCallFromFormalParams(oriName, params)

template genCompatFromTyped(typedDef: NimNode, jsImplDo: untyped) =
  ## `typedDef` must be a `proc` (typed NimNode)
  let def = typedDef.getImpl
  let
    oriParams = def[3]
    oriName = def.name
  let params = newNimNode nnkFormalParams
  params.add oriParams[0]
  forParams iddef, oriParams:
    let
      n = newNimNode nnkIdentDefs
      L = iddef.len
    forIdents id, iddef:
      n.add ident id.strVal
    n.add iddef[L-2]
    n.add iddef[L-1]
    params.add n
  genCompatTmplAux(oriName, params, jsImplDo)


macro genCompatFromOrJs*(def: proc; jsImpl: untyped) =
  genCompatFromTyped(def):
    result.add jsImpl


macro genCompatStrImportJs*(oriName; jsImport: static[string]) =
  let params = nnkFormalParams.newTree ident"string"
  genCompatTmplAux(oriName, params):
    let jsSym = genSym(nskLet, "compatJsImpl")
    let jsDef = quote do: #newProc(name, [ident"cstring"])
      let `jsSym`{.importjs: `jsImport`.}: cstring
    result.add jsSym.prefix"$"
    result = newStmtList(jsDef, result)


macro toCompatUseStdOrJs*(def) =
  ## used as pragma
  let
    params = def.params
    oriName = def.name
  genCompatTmplAux(oriName, params):
    result.add def.body


