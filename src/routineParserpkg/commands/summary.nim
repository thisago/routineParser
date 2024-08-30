from std/times import initDuration

import routineParserpkg/[config, utils]

proc summaryCommand*(routineYaml: string): tuple[
  valid: bool,
  rawNeededHours: float,
  realNeededHours: float,
  dayHours: float
] =
  ## Checks if routine is not larger than day
  let
    routine = loadConfig routineYaml
    dayDuration = routine.config.dayDuration

  result.dayHours = dayDuration.toHours
  result.rawNeededHours = toHours routine.blocks.duration RoutineConfigTolerance(
    betweenBlocks: "0min",
    betweenTasks: "0min",
    betweenActions: "0min"
  )
  result.realNeededHours = toHours routine.blocks.duration routine.config.tolerance
  result.valid = result.realNeededHours <= result.dayHours
