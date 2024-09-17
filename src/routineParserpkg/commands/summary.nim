from std/times import initDuration, now, parse

import routineParserpkg/[config, utils]

proc summaryCommand*(
  routineYaml: string;
  today = ""
): tuple[
  valid: bool;
  rawNeededHours: float;
  realNeededHours: float;
  dayHours: float,
  rawStoryPoints: int,
  rawEnergyBack: int,
  totalStoryPoints: int,
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
  result.rawNeededHours = toHours blocks.duration RoutineConfigTolerance()
  result.realNeededHours = toHours blocks.duration routine.config.tolerance
  result.rawStoryPoints = blocks.totalStoryPoints
  result.rawEnergyBack = blocks.totalEnergyBack
  result.totalStoryPoints = result.rawStoryPoints - result.rawEnergyBack

  result.valid = result.realNeededHours <= result.dayHours and
                 result.totalStoryPoints <= routine.config.idealStoryPoints
