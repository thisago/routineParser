from std/times import initDuration, `+=`, parse, now
import std/json

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
                     else: clockToHours routine.config.dayStart
  var time = realDayStart.toDuration

  for blk in routine.blocks:
    if blk.repeat.isForToday today:
      for task in blk.tasks:
        var taskDuration = initDuration(hours = 0)
        for action in task.actions:
          taskDuration += action.duration.toDuration
        repeatingTasks.add initTtmRepeatingTask(
          name = task.name,
          duration = taskDuration,
          activityId = activities[task.timetome],
          scheduled = time,
          important = task.important
        )
        time += taskDuration
        time += routine.config.tolerance.betweenTasks.toDuration
      time += routine.config.tolerance.betweenBlocks.toDuration

  timetome.repeatings = repeatingTasks

  timetomeJson.writeFile $timetome
