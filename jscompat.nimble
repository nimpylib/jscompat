# Package

version       = "0.1.11"
author        = "litlighilit"
description   = "Compatible layer for some of Nim's stdlib, for node or deno, as well as WASI"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim > 2.0.8"

var pylibPre = "https://github.com/nimpylib"
let envVal = getEnv("NIMPYLIB_PKGS_BARE_PREFIX")
if envVal != "": pylibPre = ""
#if pylibPre == Def: pylibPre = ""
elif pylibPre[^1] != '/':
  pylibPre.add '/'
template pylib(x, ver) =
  requires if pylibPre == "": x & ver
           else: pylibPre & x

pylib "errno", " ^= 0.1.0"

task test, "run testament":
  exec """testament p "tests/*.nim" """

