import routineParserpkg/commands/[
  summary,
  represent,
  patchTimetomeRepeatingTasks,
  ganttChart,
  representUnplanned,
  simpleRepresent,
]

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
  ], [
    ganttChartCommand,
    cmdName = "ganttChart",
  ], [
    representUnplannedCommand,
    cmdName = "representUnplanned",
  ], [
    simpleRepresentCommand,
    cmdName = "simpleRepresent",
  ])
else:
  import routineParserpkg/config
  export config
