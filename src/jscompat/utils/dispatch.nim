
## this module's APIs is unstable
when defined(js):
  import std/jsffi
  export jsffi
  var ibindExpr{.compileTime.}: int
  template bindExpr*[T=JsObject](asIdent; exprOfJs: string) =
    ## helpers to cache exp (make sure `exp` evaluated by js only once)
    bind ibindExpr
    let tmp{.importjs: exprOfJs.}: T
    const `asIdent InJs`* = "_NPython_bindExpr" & $ibindExpr & '_' & astToStr(asIdent)
    static: ibindExpr.inc
    let asIdent*{.exportc: `asIdent InJs`.} = tmp

  template notDecl*(s): string = "(typeof("&s&")==='undefined')"
  template `&&`(a, b: string): string = "("&a&"&&"&b&")"
  template `||`(a, b: string): string = "("&a&"||"&b&")"
  template `!`*(a: string): string = "!("&a&")"  ## internal. unstable.


  bindExpr[bool] notDeno, notDecl"Deno"

  template ifOr*(cond, a, b: string): string = '('&cond&'?'&a&':'&b&')'
  template denoOr*(deno, node: string): string =
    bind notDenoInJs
    notDenoInJs.ifOr node, deno
  bindExpr[bool] notHasProcess, notDecl"process"  # as Deno also has `process`
  bindExpr[bool] notNode, (notHasProcessInJs || !notDenoInJs)
  template nodeno*(node, deno, def: string): string =
    ## node or node or def
    bind ifOr, notNodeInJs
    ifOr(notNodeInJs, denoOr(deno, def), node)
  #NOTE: As ./compat.nim uses js top-level import, so the whole JS file is
  # ES module, thus `require` is not defined, which we cannot use here.
  #template genX(name; s){.dirty.} =
  when defined(nodejs) and not defined(esModule):
    proc exprImportNode*(s: string): string =
      result = "require('" & s & "')"
    template collectImportNode* = discard
  else:
    import std/sets
    import std/macros
    from std/strutils import format
    var imports{.compileTime.}: HashSet[string]
    proc exprImportNode*(s: string): string =
      result = s
      imports.incl s
    when defined(karax) or defined(jsAlert):
      template collectImportNode* = discard
    else:
      macro collectImportNode* =
        var res = """/*INCLUDESECTION*/
    """
        for modu in imports:
          res.add "import * as $1 from 'node:$1'\n".format modu
        result = quote do:
          {.emit: `res`.}
        imports.clear()

  template genXorDeno(name; s){.dirty.} =
    bindExpr[] name, nodeno(exprImportNode s, "Deno", "null")
  template genX(name; s){.dirty.} =
    bindExpr[] name, ifOr(notNodeInJs && notDenoInJs, "null", exprImportNode s)
  # using `await import` without paran will causes js SyntaxError on non-nodejs
  genXorDeno fsOrDeno, "fs"
  genXorDeno ttyOrDeno, "tty"  # for .isatty
  genX fsMod, "fs"
  genX pathMod, "path"
  genX constantsMod, "constants"

  template jsFuncExpr(js, name: string): untyped{.dirty.} =
    js & '.' & name & "(@)"

  template genPragma(name, jsExp){.dirty.} =
    template name*(s): untyped =
      bind jsExp
      bind jsFuncExpr
      jsFuncExpr(jsExp, s)
  genPragma fsDeno, fsOrDenoInJs
  genPragma fs, fsModInJs
  genPragma node_path, pathModInJs

  collectImportNode()

