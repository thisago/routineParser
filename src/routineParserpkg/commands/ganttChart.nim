from std/strformat import fmt
from std/strutils import strip, replace
from std/times import `+=`, parse, now, inMinutes, format, `+`

import routineParserpkg/[config, utils]


proc ganttChartCommand*(
  routineYaml: string;
  dayStart = -1.0;
  today = ""
): string =
  ## Generates the routine representation in Mermaid Gantt chart
  ##
  ## The float hours described at `dayStart` overrides the configuration day start
  let routine = loadConfig routineYaml
  var realDayStart = if dayStart >= 0: dayStart
                     else: clockToHours routine.config.dayStart.get
  var time = realDayStart.toDuration
  let
    toleranceBetweenBlocks = routine.config.tolerance.betweenBlocks.get.toDuration
    toleranceBetweenTasks = routine.config.tolerance.betweenTasks.get.toDuration
    toleranceBetweenActions = routine.config.tolerance.betweenActions.get.toDuration

  let todayDt = if today.len > 0: today.parse("yyyy-MM-dd") else: now()

  result.add fmt"""gantt
  title Routine for {todayDt.format "yyyy-MM-dd"} ({routine.version})
  dateFormat HH:mm
  axisFormat %H:%M

  Day Start : milestone, m1, {hr time}, 2m
"""

  for blk in routine.blocks:
    if blk.repeat.get.isForToday todayDt:
      let blockStart = time
      var tasksResult = ""
      for task in blk.tasks:
        let
          taskStart = time
          taskDuration = task.duration(RoutineConfigTolerance())
          taskDurationMin = taskDuration.inMinutes
          timeEnd = time + taskDuration
          readableTime = fmt"{time.hr}-{timeEnd.hr}".replace(":", ".")
        tasksResult.add fmt"  {readableTime} "
        if task.important.get:
          tasksResult.add "!"
        tasksResult.add fmt"{task.name} - {task.storyPoints.get}sp{task.satisfaction.get}sf{task.price.get.int}pr{taskDurationMin}min : {hr time}, {taskDurationMin}m" & "\l"

        var actionsResult = ""
        for action in task.actions:
          let actionStart = time
          time += action.duration.toDuration
          time += toleranceBetweenActions
        tasksResult.add actionsResult
        time += toleranceBetweenTasks

      result.add "\l" & fmt"  section {blk.name}" & "\l" # ({hr blockStart}-{hr time})" & "\l"
      result.add tasksResult
      time += toleranceBetweenBlocks

  result.add "\l" & fmt"  Day End : milestone, m2, {routine.config.dayEnd.get.clockToHours.toDuration.hr}, 2m" & "\l" # ({hr blockStart}-{hr time})" & "\l"
  result = strip result
