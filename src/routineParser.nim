import routineParserpkg/commands/[
  summary,
  represent,
  patchTimetomeRepeatingTasks,
  ganttChart,
  representUnplanned,
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
  ])
