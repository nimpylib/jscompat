# Package

version       = "0.1.8"
author        = "litlighilit"
description   = "Compatible layer for some of Nim's stdlib, for node or deno, as well as WASI"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim > 2.0.8"

task test, "run testament":
  exec """testament p "tests/*.nim" """

