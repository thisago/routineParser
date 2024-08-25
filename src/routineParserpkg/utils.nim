import std/[times, strutils, strformat, math]

import routineParserpkg/config

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
    dayStart = clockToHours routineConfig.dayStart
    dayEnd = clockToHours routineConfig.dayEnd
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
