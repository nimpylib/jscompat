# Package

version       = "0.1.3"
author        = "litlighilit"
description   = "Compatible layer for some of Nim's stdlib, for node or deno"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.8"

task test, "run testament":
  exec """testament p "tests/*.nim" """

