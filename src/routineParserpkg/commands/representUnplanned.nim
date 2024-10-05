from std/strformat import fmt
from std/strutils import strip
from std/times import parse, now

import routineParserpkg/[config, utils]

proc representUnplannedCommand*(
  routineYaml: string;
  today = ""
): string =
  ## Generates the representation in Markdown of unplanned tasks
  let
    routine = loadConfig routineYaml
    today = if today.len > 0: today.parse("yyyy-MM-dd") else: now()

  for task in routine.unplannedTasks:
    if task.repeat.get.isForToday today:
      result.add fmt"- {task.repr}" & "\l"

  result = strip result

