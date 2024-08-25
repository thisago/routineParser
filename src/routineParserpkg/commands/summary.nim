from std/times import initDuration, `+=`

import routineParserpkg/[config, utils]

proc summaryCommand*(routineYaml: string): tuple[
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
