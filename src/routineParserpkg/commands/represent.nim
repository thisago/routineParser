from std/strformat import fmt
from std/strutils import strip
from std/times import `+=`, parse, now

import routineParserpkg/[config, utils]


proc representCommand*(
  routineYaml: string;
  dayStart = -1.0;
  today = ""
): string =
  ## Generates the routine representation in Markdown
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

  for blk in routine.blocks:
    if blk.repeat.isForToday today:
      let blockStart = time
      var tasksResult = ""
      for task in blk.tasks:
        let taskStart = time
        var actionsResult = ""
        for action in task.actions:
          let actionStart = time
          time += action.duration.toDuration
          actionsResult.add fmt"- {action.name} - {action.duration} ({hr actionStart}-{hr time})" & " \l"
          time += toleranceBetweenActions
        tasksResult.add fmt"### {task.name} - {task.storyPoints}sp{task.energyBack}eb ({hr taskStart}-{hr time})" & "\l"
        tasksResult.add actionsResult
        time += toleranceBetweenTasks
      result.add "\l" & fmt"## {blk.name} ({hr blockStart}-{hr time})" & "\l"
      result.add tasksResult
      time += toleranceBetweenBlocks

  result = strip result

