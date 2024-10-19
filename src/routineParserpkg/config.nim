import std/options
import pkg/yaml

type
  Routine* = object
    version*: string
    config*: RoutineConfig
    blocks*: seq[RoutineBlock]
    unplannedTasks*: seq[UnplannedTask]

  RoutineConfig* {.sparse.} = object
    dayStart* {.defaultVal: "06:00".some.}: Option[string] = "06:00".some
    dayEnd* {.defaultVal: "22:00".some.}: Option[string] = "22:00".some
    tolerance*: RoutineConfigTolerance
    prerequisites*: RoutineConfigPrerequisites
    nonWorkDays*: Option[set[RoutineBlockRepetition]]

  RoutineConfigPrerequisites* {.sparse.} = object
    maxStoryPoints* {.defaultVal: 100.some.}: Option[int] = 100.some
    minSatisfaction*: Option[int]
    minBalance*, minAverageHourPrice*, minBilled*, minBilledHours*: Option[float]

  RoutineConfigTolerance* {.sparse.} = object
    betweenBlocks* {.defaultVal: "0min".some.}: Option[string] = "0min".some
    betweenTasks* {.defaultVal: "0min".some.}: Option[string] = "0min".some
    betweenActions* {.defaultVal: "0min".some.}: Option[string] = "0min".some

  RoutineBlockRepetition* = enum
    Everyday,
    Weekdays, Weekends,
    Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday,
    Monthend, Monthstart

  RoutineBlock* {.sparse.} = object
    name*: string
    repeat* {.defaultVal: {Everyday}.some.}: Option[set[RoutineBlockRepetition]] = {Everyday}.some
    tasks*: seq[RoutineBlockTask]

  RoutineBlockTask* {.sparse.} = object
    name*: string
    timetome* {.defaultVal: "Other".some}: Option[string] = "Other".some
    important*: Option[bool]
    storyPoints*, satisfaction*: Option[int]
    price*: Option[float]
    actions*: seq[RoutineBlockTaskAction]
    perfectness*: Option[float]
    repeat* {.defaultVal: {Everyday}.some.}: Option[set[RoutineBlockRepetition]] = {Everyday}.some

  RoutineBlockTaskAction* = object
    name*: string
    duration*: string


  UnplannedTask* {.sparse.} = object
    name*: string
    timetome* {.defaultVal: "Other".some}: Option[string] = "Other".some
    repeat* {.defaultVal: {Everyday}.some.}: Option[set[RoutineBlockRepetition]] = {Everyday}.some
    important*: Option[bool]
    storyPoints*, satisfaction*: Option[int]
    price*: Option[float]
    duration*: string


proc loadConfig*(yamlFile: string): Routine =
  result = loadAs[Routine](yamlFile.readFile)
