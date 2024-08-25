import std/[times, streams, strutils]
import pkg/yaml

type
  Routine = object
    version: string
    context: RoutineConfig
    blocks: seq[RoutineBlock]

  RoutineConfig = object
    day: RoutineDayConfig

  RoutineDayConfig = object
    wakeUp: string
    sleep: string

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

func toInterval(spec: string): TimeInterval =
  ## Currently only supports minutes
  if "min" notin spec:
    throw newException(ValueError, "Duration should be intervals.")
  result = initTimeInterval(minutes = spec.strip(AllChars - Letters).parseInt)
 

func duration(dayConfig: RoutineDayConfig): TimeInterval =
  let
    start = dayConfig.start.toInterval


proc checkCli(routineYaml: string): bool =
  ## Checks if routine is not larger than day
  const routineFile = "routine.yaml"
  let
    routine = loadConfig routineFile
    routine.config.day.duration

when isMainModule:
  import pkg/cligen
  dispatchMulti([
    checkCli,
    cmdName: "check"
  ])
