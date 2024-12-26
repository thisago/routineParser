from std/strformat import fmt
from std/strutils import strip, join
from std/times import `+=`, parse, now, `<`, initDuration, hour, minute, second, `+`, inMinutes

import routineParserpkg/[config, utils]

proc simpleRepresentCommand*(
  routineYaml: string;
  dayStart = -1.0;
  today = "",
  highlightAction = false
): string =
  ## Generates the routine representation in Markdown
  ##
  ## The float hours described at `dayStart` overrides the configuration day start
  ##
  ## Description of the output:
  ## - `!` in front of the task tells it's important
  let routine = loadConfig routineYaml
  var realDayStart = if dayStart >= 0: dayStart
                     else: clockToHours routine.config.dayStart.get
  var time = realDayStart.toDuration
  let
    toleranceBetweenBlocks = routine.config.tolerance.betweenBlocks.get.toDuration
    toleranceBetweenTasks = routine.config.tolerance.betweenTasks.get.toDuration
    toleranceBetweenActions = routine.config.tolerance.betweenActions.get.toDuration

  let today = if today.len > 0: today.parse("yyyy-MM-dd") else: now()
  let
    nowDt = now()
    nowDur = initDuration(
      hours = nowDt.hour,
      minutes = nowDt.minute,
      seconds = nowDt.second,
    )

  for blk in routine.blocks:
    if blk.repeat.get.isForToday today:
      let blockStart = time
      var tasksResult = ""
      for task in blk.tasks:
        if task.repeat.get.isForToday today:
          let
            taskStart = time
            taskDuration = task.duration(RoutineConfigTolerance())
            timeEnd = time + taskDuration
          var actionsResult: seq[string]
          for action in task.actions:
            actionsResult.add action.name
            time += action.duration.toDuration
            time += toleranceBetweenActions
          tasksResult.add "\l" & fmt"  - {task.name} (~{hr taskStart}-{hr timeEnd})" & "\l"
          tasksResult.add "    - Tasks: " & actionsResult.join ", "
          time += toleranceBetweenTasks
      result.add "\l" & fmt"- {blk.name} (~{hr blockStart}-{hr time})"
      result.add tasksResult
      time += toleranceBetweenBlocks

  result = strip result

