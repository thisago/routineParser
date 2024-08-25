from std/strutils import join
from std/times import Duration, inSeconds, now, toUnix, toTime
from std/strformat import fmt
from std/json import JsonNode, `%*`, `%`

type
  TtmRepeatingTask* = object
    name: string
    isImportant: bool
    duration: Duration
    scheduled: Duration

    lastDay: int
    typeId: int
    value: string


using
  task: TtmRepeatingTask

func textFeatures*(task): string =
  ## Source:
  ##   timeto.me/src/commit/4cbbe980cff2b36596ea69f4e7bb503e6277f310/shared/src/commonMain/kotlin/me/timeto/shared/TextFeatures.kt
  var results = @[task.name]
  if task.isImportant:
    results.add "#important"
  if task.duration.inSeconds > 0:
    results.add fmt"#d{task.duration.inSeconds}"
  result = results.join " "

proc id*(task): int64 =
  ## timeto.me task ids is it's epoch
  result = now().toTime.toUnix

func initTtmRepeatingTask*(
  name: string;
  duration, scheduled: Duration
): TtmRepeatingTask =
  TtmRepeatingTask(
    name: name,
    duration: duration,
    scheduled: scheduled
  )

proc toJson*(task): JsonNode =
  ## Converts timeto.me repeating task into same format as exported
  result = %*[
    %task.id, # id
    %task.textFeatures, # text
    %0, # last_day
    %1, # type_id
    %"1", # value - repetition (every day)
    %task.scheduled.inSeconds, # daytime
    %(if task.isImportant: 1 else: 0) # is_important
  ]
