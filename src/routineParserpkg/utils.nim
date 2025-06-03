import std/[times, strutils, strformat, math]
from std/options import Option, isSome

import routineParserpkg/config

func get*[T](opt: Option[T]): T =
  ## Gets or default
  if opt.isSome:
    result = options.get opt

func toDuration*(spec: string): Duration =
  ## Currently only supports minutes
  if "min" notin spec:
    raise newException(ValueError, fmt"Duration should be minutes at {spec}")
  result = initDuration(minutes =
    spec.strip(chars = AllChars - Digits).parseInt)

func clockToHours*(hourRepr: string): float =
  ## Transforms a clock representation (10:30) to a hours number (10.5)
  if "am" in hourRepr or "pm" in hourRepr:
    raise newException(ValueError, fmt"Clock representation doesn't supports AM/PM at {hourRepr}")
  let
    parts = hourRepr.split ":"
    hours = float parseInt strip parts[0]
    minutes = parseInt strip parts[1]
  result = hours + (minutes / 60)

func splitHours*(hours: float): tuple[hours, minutes: int] =
  ## Extracts minutes from the rest
  result.hours = int hours
  result.minutes = int round 60 * (hours mod 1.0)

func dayDuration*(routineConfig: RoutineConfig): Duration =
  let
    dayStart = clockToHours routineConfig.dayStart.get
    dayEnd = clockToHours routineConfig.dayEnd.get
    duration = dayEnd - dayStart
    t = splitHours duration
  result = initDuration(hours = t.hours, minutes = t.minutes)

func toHours*(dur: Duration): float =
  ## Converts into a floating hours
  result = dur.inMinutes / 60


proc hr*(dur: Duration): string =
  ## Converts duration into readable hours representation (10:30)
  let t = splitHours dur.inMinutes / 60
  result = fmt"{t.hours:>02}:{t.minutes:>02}"

func toDuration*(hours: float): Duration =
  ## Converts a floating hour into Duration
  let t = hours.splitHours
  initDuration(hours = t.hours, minutes = t.minutes)

func weekday(dt: DateTime): WeekDay =
  getDayOfWeek(dt.monthday, dt.month, dt.year)


func isForToday*(repeat: RoutineBlockRepetition; dt: DateTime): bool =
  let weekday = dt.weekday
  case repeat:
    of Everyday: true

    of Sunday: weekday == dSun
    of Monday: weekday == dMon
    of Tuesday: weekday == dTue
    of Wednesday: weekday == dWed
    of Thursday: weekday == dThu
    of Friday: weekday == dFri
    of Saturday: weekday == dSat

    of Weekdays: weekday in {dMon, dTue, dWed, dThu, dFri}
    of Weekends: weekday in {dSat, dSun}

    of Monthstart: dt.monthday == 1
    of Monthend: dt.monthday == getDaysInMonth(dt.month, dt.year)


func isForToday*(repeat: set[RoutineBlockRepetition]; dt: DateTime): bool =
  result = false
  for item in repeat:
    if item.isForToday dt:
      return true

proc duration*(task: RoutineBlockTask; tolerances: RoutineConfigTolerance; today = now()): Duration =
  let toleranceBetweenActions = tolerances.betweenActions.get.toDuration
  for action in task.actions:
    if action.repeat.get.isForToday today:
      result += action.duration.toDuration
      result += toleranceBetweenActions

proc duration*(blk: RoutineBlock; tolerances: RoutineConfigTolerance; today = now()): Duration =
  let toleranceBetweenTasks = tolerances.betweenTasks.get.toDuration
  for task in blk.tasks:
    if task.repeat.get.isForToday today:
      result += task.duration(tolerances, today)
      result += toleranceBetweenTasks

proc duration*(
  blocks: seq[RoutineBlock];
  tolerances: RoutineConfigTolerance;
  today = now()
): Duration =
  let toleranceBetweenBlocks = tolerances.betweenBlocks.get.toDuration
  for blk in blocks:
    if blk.repeat.get.isForToday today:
       result += blk.duration(tolerances, today)
       result += toleranceBetweenBlocks

func totalStoryPoints*(blocks: seq[RoutineBlock]): int =
  ## Sums all routine storypoints
  for blk in blocks:
    for task in blk.tasks:
      result += task.storyPoints.get

func totalSatisfaction*(blocks: seq[RoutineBlock]): int =
  ## Sums all routine `satisfaction`
  for blk in blocks:
    for task in blk.tasks:
      result += task.satisfaction.get

proc billable*(blocks: seq[RoutineBlock]; today = now()): tuple[positive, negative, positiveHours, negativeHours, hours: float] =
  ## Sums all routine `satisfaction`
  for blk in blocks:
    if blk.repeat.get.isForToday today:
      for task in blk.tasks:
        if task.repeat.get.isForToday today:
          let
            duration = task.duration(RoutineConfigTolerance(), today)
            hours = duration.inMinutes / 60
            price = task.price.get * hours
          if price != 0:
            result.hours += hours
            if price > 0:
              result.positive += price
              result.positiveHours += hours
            elif price < 0:
              result.negative += price
              result.negativeHours += hours

proc repr*(task: RoutineBlockTask; today = now()): string =
  let taskDur = task.duration(RoutineConfigTolerance(), today)

  if task.important.get:
    result = "!"

  result.add [
    task.name,
    " - ",
    fmt"{task.storyPoints.get}sp",
    fmt"{task.satisfaction.get}sf",
    fmt"{task.price.get.int}pr",
    fmt"{taskDur.inMinutes}min"
  ].join ""

func repr*(task: UnplannedTask): string =
  let taskDur = task.duration.toDuration

  if task.important.get:
    result = "!"

  result.add [
    task.name,
    " - ",
    fmt"{task.storyPoints.get}sp",
    fmt"{task.satisfaction.get}sf",
    fmt"{task.price.get.int}pr",
    fmt"{taskDur.inMinutes}min"
  ].join ""
