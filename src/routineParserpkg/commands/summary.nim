from std/times import initDuration, now, parse

import routineParserpkg/[config, utils]

proc summaryCommand*(
  routineYaml: string;
  today = ""
): tuple[
  valid: bool;
  rawNeededHours, realNeededHours, dayHours: float,
  totalStoryPoints, totalSatisfaction: int,
  totalPositiveBilled, totalNegativeBilled, totalBilled, totalBalance, totalBilledHours, totalPositiveBilledHours, totalNegativeBilledHours: float,
] =
  ## Checks if routine is not larger than day
  let
    routine = loadConfig routineYaml
    dayDuration = routine.config.dayDuration

  let today = if today.len > 0: today.parse("yyyy-MM-dd") else: now()

  var blocks: seq[RoutineBlock]
  for blk in routine.blocks:
    if blk.repeat.get.isForToday today:
      blocks.add blk

  result.dayHours = dayDuration.toHours
  result.rawNeededHours = toHours blocks.duration RoutineConfigTolerance()
  result.realNeededHours = toHours blocks.duration routine.config.tolerance
  result.totalStoryPoints = blocks.totalStoryPoints
  result.totalSatisfaction = blocks.totalSatisfaction

  let billed = blocks.billable
  result.totalPositiveBilled = billed.positive
  result.totalNegativeBilled = billed.negative
  result.totalBilled = billed.positive - billed.negative
  result.totalBalance = billed.positive + billed.negative
  result.totalBilledHours = billed.hours
  result.totalNegativeBilledHours = billed.negativeHours
  result.totalPositiveBilledHours = billed.positiveHours

  result.valid = result.realNeededHours <= result.dayHours and
                 result.totalStoryPoints <= routine.config.prerequisites.maxStoryPoints.get and
                 result.totalSatisfaction >= routine.config.prerequisites.minSatisfaction.get and
                 (if routine.config.nonWorkDays.get.isForToday today: true else:
                   result.totalBalance >= routine.config.prerequisites.minBalance.get and
                   result.totalBilled >= routine.config.prerequisites.minBilled.get and
                   result.totalBilledHours >= routine.config.prerequisites.minBilledHours.get)
