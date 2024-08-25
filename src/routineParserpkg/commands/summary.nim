from std/times import initDuration

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

  result.dayHours = dayDuration.toHours
  result.neededHours = toHours routine.blocks.duration routine.config.tolerance
  result.valid = result.neededHours <= result.dayHours
