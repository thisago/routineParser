from std/strformat import fmt
from std/strutils import strip
from std/times import `+=`, parse, now, `<`, initDuration, hour, minute, second, `+`, inMinutes

import routineParserpkg/[config, utils]

proc representCommand*(
  routineYaml: string;
  dayStart = -1.0;
  today = "",
  highlightAction = false
): string =
  ## Generates the routine representation in Markdown
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
        let
          taskStart = time
          taskDuration = task.duration(RoutineConfigTolerance())
          timeEnd = time + taskDuration
        var actionsResult = ""
        for action in task.actions:
          var nextTime = time
          let actionStart = time
          nextTime += action.duration.toDuration
          actionsResult.add "- "
          if highlightAction and nowDur > time and nowDur < nextTime:
            actionsResult.add fmt"**{action.name}**"
          else:
            actionsResult.add action.name
          actionsResult.add fmt" - {action.duration} ({hr actionStart}-{hr nextTime})" & " \l"
          nextTime += toleranceBetweenActions
          time = nextTime
        tasksResult.add fmt"### {task.repr} ({hr taskStart}-{hr timeEnd})" & "\l"
        tasksResult.add actionsResult
        time += toleranceBetweenTasks
      result.add "\l" & fmt"## {blk.name} ({hr blockStart}-{hr time})" & "\l"
      result.add tasksResult
      time += toleranceBetweenBlocks

  result = strip result

