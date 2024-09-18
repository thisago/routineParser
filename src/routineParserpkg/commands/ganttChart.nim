from std/strformat import fmt
from std/strutils import strip, replace
from std/times import `+=`, parse, now, inMinutes

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
                     else: clockToHours routine.config.dayStart
  var time = realDayStart.toDuration
  let
    toleranceBetweenBlocks = routine.config.tolerance.betweenBlocks.toDuration
    toleranceBetweenTasks = routine.config.tolerance.betweenTasks.toDuration
    toleranceBetweenActions = routine.config.tolerance.betweenActions.toDuration

  let today = if today.len > 0: today.parse("yyyy-MM-dd") else: now()

  result.add fmt"""gantt
  title Routine ({routine.version})
  dateFormat HH:mm
  axisFormat %H:%M

  Day Start : milestone, m1, {hr time}, 2m
"""

  for blk in routine.blocks:
    if blk.repeat.isForToday today:
      let blockStart = time
      var tasksResult = ""
      for task in blk.tasks:
        let
          taskStart = time
          taskDurationMin = task.duration(RoutineConfigTolerance()).inMinutes
          readableTime = time.hr.replace(":", "-")
        tasksResult.add fmt"  {readableTime} {task.name} - {task.storyPoints}sp{task.energyBack}eb{taskDurationMin}min : {hr time}, {taskDurationMin}m" & "\l"

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

  result.add "\l" & fmt"  Day End : milestone, m2, {routine.config.dayEnd.clockToHours.toDuration.hr}, 2m" & "\l" # ({hr blockStart}-{hr time})" & "\l"
  result = strip result

