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

func toDuration(spec: string): Duration =
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

func splitHours(hours: float): tuple[hours, minutes: int] =
  ## Extracts minutes from the rest
  result.hours = int hours
  result.minutes = int round 60 * (hours mod 1.0)

func dayDuration(routineConfig: RoutineConfig): Duration =
  let
    dayStart = clockToHours routineConfig.dayStart
    dayEnd = clockToHours routineConfig.dayEnd
    duration = dayEnd - dayStart
    t = splitHours duration
  result = initDuration(hours = t.hours, minutes = t.minutes)

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

proc hr(dur: Duration): string =
  ## Converts duration into readable hours representation (10:30)
  let t = splitHours dur.inMinutes / 60
  result = fmt"{t.hours:>02}:{t.minutes:>02}"

func toDuration(hours: float): Duration =
  ## Converts a floating hour into Duration
  let t = hours.splitHours
  initDuration(hours = t.hours, minutes = t.minutes)


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
