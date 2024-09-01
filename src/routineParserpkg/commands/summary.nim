from std/times import initDuration, now, parse

import routineParserpkg/[config, utils]

proc summaryCommand*(
  routineYaml: string;
  today = ""
): tuple[
  valid: bool;
  rawNeededHours: float;
  realNeededHours: float;
  dayHours: float
] =
  ## Checks if routine is not larger than day
  let
    routine = loadConfig routineYaml
    dayDuration = routine.config.dayDuration

  let today = if today.len > 0: today.parse("yyyy-MM-dd") else: now()

  var blocks: seq[RoutineBlock]
  for blk in routine.blocks:
    if blk.repeat.isForToday today:
      blocks.add blk

  result.dayHours = dayDuration.toHours
  result.rawNeededHours = toHours blocks.duration RoutineConfigTolerance(
    betweenBlocks: "0min",
    betweenTasks: "0min",
    betweenActions: "0min"
  )
  result.realNeededHours = toHours blocks.duration routine.config.tolerance
  result.valid = result.realNeededHours <= result.dayHours
