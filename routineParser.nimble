# Package

version       = "0.6.4"
author        = "thisago"
description   = "Smart human routines as YAML"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["routineParser"]
binDir = "build"


# Dependencies

requires "nim >= 1.6.4"

requires "yaml"

when isMainModule:
  requires "cligen"
