import routineParserpkg/commands/[summary, represent, patchTimetomeRepeatingTasks]

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
  ], [
    patchTimetomeRepeatingTasksCommand,
    cmdName = "patchTimetomeRepeatingTasks",
  ])
