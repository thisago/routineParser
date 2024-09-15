import pkg/yaml

type
  Routine* = object
    version*: string
    config*: RoutineConfig
    blocks*: seq[RoutineBlock]

  RoutineConfig* = object
    dayStart*: string
    dayEnd*: string
    idealStoryPoints*: int
    tolerance*: RoutineConfigTolerance

  RoutineConfigTolerance* = object
    betweenBlocks*: string
    betweenTasks*: string
    betweenActions*: string

  RoutineBlock* = object
    name*: string
    repeat*: set[RoutineBlockRepetition]
    tasks*: seq[RoutineBlockTask]

  RoutineBlockRepetition* = enum
    Everyday,
    Weekdays, Weekends,
    Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday,
    Monthend, Monthstart

  RoutineBlockTask* = object
    name*: string
    timetome*: string # optional?
    important*: bool
    storyPoints*: int
    actions*: seq[RoutineBlockTaskAction]

  RoutineBlockTaskAction* = object
    name*: string
    duration*: string

proc loadConfig*(yamlFile: string): Routine =
  result = loadAs[Routine](yamlFile.readFile)
