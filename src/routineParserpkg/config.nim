import pkg/yaml

type
  Routine* = object
    version*: string
    config*: RoutineConfig
    blocks*: seq[RoutineBlock]

  RoutineConfig* = object
    dayStart*: string
    dayEnd*: string
    tolerance*: RoutineConfigTolerance

  RoutineConfigTolerance* = object
    betweenBlocks*: string
    betweenTasks*: string
    betweenActions*: string

  RoutineBlock* = object
    name*: string
    tasks*: seq[RoutineBlockTask]

  RoutineBlockTask* = object
    name*: string
    timetome*: string
    important*: bool
    actions*: seq[RoutineBlockTaskAction]

  RoutineBlockTaskAction* = object
    name*: string
    duration*: string

proc loadConfig*(yamlFile: string): Routine =
  result = loadAs[Routine](yamlFile.readFile)

