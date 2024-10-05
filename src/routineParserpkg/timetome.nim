from std/strutils import join, contains, split
from std/times import Duration, inSeconds, now, toUnix, toTime
from std/strformat import fmt
from std/json import JsonNode, `%*`, `%`, `[]`, items, getInt, getStr, `[]=`, newJNull
from std/tables import Table, `[]=`
from std/random import randomize, rand
from std/options import Option, isSome, get, none, some

export tables.`[]`

const ownIdentifier = "[routine]"

type
  TtmRepeatingTask* = object
    name*: string
    important*: bool
    duration*: Duration
    scheduled*: Option[Duration]
    activityId*: string

using
  task: TtmRepeatingTask

func textFeatures*(task): string =
  ## Source:
  ##   timeto.me/src/commit/4cbbe980cff2b36596ea69f4e7bb503e6277f310/shared/src/commonMain/kotlin/me/timeto/shared/TextFeatures.kt
  var results = @[
    task.name,
    ownIdentifier,
    fmt"#a{task.activityId}",
    fmt"#t{task.duration.inSeconds}",
  ]
  if task.important:
    results.add "#important"
  result = results.join " "

proc id*(task): int64 =
  ## timeto.me task ids is it's epoch
  var seed = 0
  for ch in task.name & task.activityId:
    seed += int ch
  randomize(seed)
  result = rand(0..999999999)

func initTtmRepeatingTask*(
  name: string;
  duration: Duration;
  activityId: string;
  important = false
): TtmRepeatingTask =
  TtmRepeatingTask(
    name: name,
    duration: duration,
    scheduled: none Duration,
    activityId: activityId,
    important: important
  )

func initTtmRepeatingTask*(
  name: string;
  duration, scheduled: Duration;
  activityId: string;
  important = false
): TtmRepeatingTask =
  TtmRepeatingTask(
    name: name,
    duration: duration,
    scheduled: scheduled.some,
    activityId: activityId,
    important: important
  )

proc toJson*(task): JsonNode =
  ## Converts timeto.me repeating task into same format as exported
  result = %*[
    %task.id, # id
    %task.textFeatures, # text
    %19960, # last_day
    %1, # type_id
    %"1", # value - repetition (every day)
    if task.scheduled.isSome: %task.scheduled.get.inSeconds else: %newJNull(), # daytime
    %(if task.important: 1 else: 0) # is_important
  ]

proc activities*(ttmExportNode: JsonNode): Table[string, string] =
  ## Extracts activities from timeto.me export
  for activity in ttmExportNode["activities"]:
    let id = $activity[0].getInt
    var name = activity[1].getStr
    if '#' in name:
      let parts = name.split " #"
      name = parts[0]
    result[name] = id

proc `repeatings=`*(
  ttmExportNode: var JsonNode;
  repeatingTasks: seq[TtmRepeatingTask]
) =
  var allRepeatingTasks: seq[JsonNode]
  for existingTask in ttmExportNode["repeatings"]:
    let name = existingTask[1].getStr
    if ownIdentifier notin name:
      allRepeatingTasks.add existingTask

  for task in repeatingTasks:
    allRepeatingTasks.add task.toJson

  ttmExportNode["repeatings"] = %allRepeatingTasks
