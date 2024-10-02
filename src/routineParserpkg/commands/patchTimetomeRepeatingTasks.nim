from std/times import initDuration, `+=`, parse, now
import std/json
from std/strformat import fmt
from std/options import isSome

import routineParserpkg/[config, utils, timetome]

proc patchTimetomeRepeatingTasksCommand*(
  routineYaml: string;
  timetomeJson: string;
  dayStart = -1.0;
  today = ""
) =
  ## Patches the timeto.me export file with the routine tasks
  let routine = loadConfig routineYaml
  var timetome = parseJson readFile timetomeJson
  let activities = timetome.activities
  let today = if today.len > 0: today.parse("yyyy-MM-dd") else: now()

  var repeatingTasks: seq[TtmRepeatingTask]

  var realDayStart = if dayStart >= 0: dayStart
                     else: clockToHours routine.config.dayStart.get
  var time = realDayStart.toDuration

  for blk in routine.blocks:
    if blk.repeat.get.isForToday today:
      for task in blk.tasks:
        var
          taskDuration = initDuration(hours = 0)
          taskTolerance = initDuration(hours = 0)
        for action in task.actions:
          taskDuration += action.duration.toDuration
          taskTolerance += routine.config.tolerance.betweenActions.get.toDuration
        if task.timetome.isSome:
          repeatingTasks.add initTtmRepeatingTask(
            name = fmt"{task.name} - {task.storyPoints.get}sp{task.energyBack.get}eb",
            duration = taskDuration,
            activityId = activities[task.timetome.get],
            scheduled = time,
            important = task.important.get
          )
        time += taskDuration
        time += taskTolerance
        time += routine.config.tolerance.betweenTasks.get.toDuration
      time += routine.config.tolerance.betweenBlocks.get.toDuration

  timetome.repeatings = repeatingTasks

  timetomeJson.writeFile $timetome
