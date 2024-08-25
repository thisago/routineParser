import routineParserpkg/commands/[summary, represent]

when isMainModule:
  import pkg/cligen
  dispatchMulti([
    summaryCommand,
    cmdName = "summary",
    echoResult = true
  ], [
    representCommand,
    cmdName = "represent",
    echoResult = true
  ])
