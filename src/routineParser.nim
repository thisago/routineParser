import std/[times, strutils, strformat, math]

import routineParserpkg/[config, utils]

proc summaryCommand(routineYaml: string): tuple[
  valid: bool,
  neededHours: float,
  dayHours: float
] =
  ## Checks if routine is not larger than day
  let
    routine = loadConfig routineYaml
    dayDuration = routine.config.dayDuration
    toleranceBetweenBlocks = routine.config.tolerance.betweenBlocks.toDuration
    toleranceBetweenTasks = routine.config.tolerance.betweenTasks.toDuration
    toleranceBetweenActions = routine.config.tolerance.betweenActions.toDuration
  var neededTime = initDuration(hours = 0)

  for blk in routine.blocks:
    neededTime += toleranceBetweenBlocks
    for task in blk.tasks:
      neededTime += toleranceBetweenTasks
      for action in task.actions:
        neededTime += toleranceBetweenActions
        neededTime += action.duration.toDuration

  result.dayHours = dayDuration.toHours
  result.neededHours = neededTime.toHours
  result.valid = result.neededHours <= result.dayHours


proc representCommand(routineYaml: string; dayStart = -1.0): string =
  ## Generates the routine representation in Markdown
  ##
  ## The float hours described at `dayStart` overrides the configuration day start
  let routine = loadConfig routineYaml
  var realDayStart = if dayStart >= 0: dayStart
                     else: clockToHours routine.config.dayStart
  var time = realDayStart.toDuration
  let
    toleranceBetweenBlocks = routine.config.tolerance.betweenBlocks.toDuration
    toleranceBetweenTasks = routine.config.tolerance.betweenTasks.toDuration
    toleranceBetweenActions = routine.config.tolerance.betweenActions.toDuration

  for blk in routine.blocks:
    let blockStart = time
    var tasksResult = ""
    for task in blk.tasks:
      let taskStart = time
      var actionsResult = ""
      for action in task.actions:
        let actionStart = time
        time += action.duration.toDuration
        actionsResult.add fmt"- {action.name} ({hr actionStart}-{hr time})" & " \l"
        time += toleranceBetweenActions
      tasksResult.add fmt"### {task.name} ({hr taskStart}-{hr time})" & "\l"
      tasksResult.add actionsResult
      time += toleranceBetweenTasks
    result.add "\l" & fmt"## {blk.name} ({hr blockStart}-{hr time})" & "\l"
    result.add tasksResult
    time += toleranceBetweenBlocks

  result = strip result

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
