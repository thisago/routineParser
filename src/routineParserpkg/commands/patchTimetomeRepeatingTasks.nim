from std/times import initDuration, `+=`, parse, now
import std/json
from std/strformat import fmt

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
  let todayDt = if today.len > 0: today.parse("yyyy-MM-dd") else: now()

  var repeatingTasks: seq[TtmRepeatingTask]

  var realDayStart = if dayStart >= 0: dayStart
                     else: clockToHours routine.config.dayStart.get
  var time = realDayStart.toDuration

  for blk in routine.blocks:
    if blk.repeat.get.isForToday todayDt:
      for task in blk.tasks:
        if task.repeat.get.isForToday todayDt:
          var
            taskDuration = initDuration(hours = 0)
            taskTolerance = initDuration(hours = 0)
          for action in task.actions:
            if action.repeat.get.isForToday todayDt:
              taskDuration += action.duration.toDuration
              taskTolerance += routine.config.tolerance.betweenActions.get.toDuration
          repeatingTasks.add initTtmRepeatingTask(
            name = task.repr,
            duration = taskDuration,
            activityId = activities[task.timetome.get],
            scheduled = time,
            important = task.important.get
          )
          time += taskDuration
          time += taskTolerance
          time += routine.config.tolerance.betweenTasks.get.toDuration
      time += routine.config.tolerance.betweenBlocks.get.toDuration

  for task in routine.unplannedTasks:
    repeatingTasks.add initTtmRepeatingTask(
      name = fmt"{task.repr} [unplanned]",
      duration = task.duration.toDuration,
      activityId = activities[task.timetome.get],
      important = task.important.get
    )

  timetome.repeatings = repeatingTasks

  timetomeJson.writeFile $timetome
