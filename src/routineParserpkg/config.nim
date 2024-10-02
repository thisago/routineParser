import std/options
import pkg/yaml

type
  Routine* = object
    version*: string
    config*: RoutineConfig
    blocks*: seq[RoutineBlock]

  RoutineConfig* {.sparse.} = object
    dayStart* {.defaultVal: "06:00".some.}: Option[string]
    dayEnd* {.defaultVal: "22:00".some.}: Option[string]
    idealStoryPoints* {.defaultVal: 100.some.}: Option[int]
    tolerance*: RoutineConfigTolerance

  RoutineConfigTolerance* {.sparse.} = object
    betweenBlocks* {.defaultVal: "0min".some.}: Option[string]
    betweenTasks* {.defaultVal: "0min".some}: Option[string]
    betweenActions* {.defaultVal: "0min".some}: Option[string]

  RoutineBlock* {.sparse.} = object
    name*: string
    repeat*: Option[set[RoutineBlockRepetition]]
    tasks*: seq[RoutineBlockTask]

  RoutineBlockRepetition* = enum
    Everyday,
    Weekdays, Weekends,
    Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday,
    Monthend, Monthstart

  RoutineBlockTask* {.sparse.} = object
    name*: string
    timetome* {.defaultVal: "Other".some}: Option[string]
    important*: Option[bool]
    storyPoints*: Option[int]
    energyBack*: Option[int]
    actions*: seq[RoutineBlockTaskAction]

  RoutineBlockTaskAction* = object
    name*: string
    duration*: string

proc loadConfig*(yamlFile: string): Routine =
  result = loadAs[Routine](yamlFile.readFile)
