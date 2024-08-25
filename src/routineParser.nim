import std/[times, streams, strutils, strformat, math]
import pkg/yaml

type
  Routine = object
    version: string
    config: RoutineConfig
    blocks: seq[RoutineBlock]

  RoutineConfig = object
    dayStart: string
    dayEnd: string
    tolerance: RoutineConfigTolerance

  RoutineConfigTolerance = object
    betweenBlocks: string
    betweenTasks: string
    betweenActions: string

  RoutineBlock = object
    name: string
    tasks: seq[RoutineBlockTask]

  RoutineBlockTask = object
    name: string
    timetome: string
    actions: seq[RoutineBlockTaskAction]

  RoutineBlockTaskAction = object
    name: string
    duration: string

proc loadConfig(yamlFile: string): Routine =
  result = loadAs[Routine](yamlFile.readFile)

func toInterval(spec: string): Duration =
  ## Currently only supports minutes
  if "min" notin spec:
    raise newException(ValueError, fmt"Duration should be minutes at {spec}")
  result = initDuration(minutes =
    spec.strip(chars = AllChars - Digits).parseInt)

func clockToHours(hourRepr: string): float =
  ## Transforms a clock representation (10:30) to a hours number (10.5)
  if "am" in hourRepr or "pm" in hourRepr:
    raise newException(ValueError, fmt"Clock representation doesn't supports AM/PM at {hourRepr}")
  let
    parts = hourRepr.split ":"
    hours = float parseInt strip parts[0]
    minutes = parseInt strip parts[1]
  result = hours + (minutes / 60)

func dayDuration(routineConfig: RoutineConfig): Duration =
  let
    dayStart = clockToHours routineConfig.dayStart
    dayEnd = clockToHours routineConfig.dayEnd
    duration = dayEnd - dayStart
    hoursDuration = int duration
    minutesDuration = 60 * (duration mod 1.0).int
  result = initDuration(hours = hoursDuration, minutes = minutesDuration)

func toHours(dur: Duration): float =
  ## Converts into a floating hours
  result = dur.inMinutes / 60

proc summaryCommand(routineYaml: string): tuple[
  valid: bool,
  neededHours: float,
  dayHours: float
] =
  ## Checks if routine is not larger than day
  let
    routine = loadConfig routineYaml
    dayDuration = routine.config.dayDuration
    toleranceBetweenBlocks = routine.config.tolerance.betweenBlocks.toInterval
    toleranceBetweenTasks = routine.config.tolerance.betweenTasks.toInterval
    toleranceBetweenActions = routine.config.tolerance.betweenActions.toInterval
  var neededTime = initDuration(hours = 0)

  for blk in routine.blocks:
    neededTime += toleranceBetweenBlocks
    for task in blk.tasks:
      neededTime += toleranceBetweenTasks
      for action in task.actions:
        neededTime += toleranceBetweenActions
        neededTime += action.duration.toInterval

  result.dayHours = dayDuration.toHours
  result.neededHours = neededTime.toHours
  result.valid = result.neededHours <= result.dayHours

when isMainModule:
  import pkg/cligen
  dispatchMulti([
    summaryCommand,
    cmdName = "summary",
    echoResult = true
  ])
