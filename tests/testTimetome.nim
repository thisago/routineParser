from std/times import initDuration, inSeconds
from std/tables import `[]`
import std/json
import std/unittest

import routineParserpkg/timetome

let task = initTtmRepeatingTask(
  name = "Test task",
  duration = initDuration(minutes = 10),
  scheduled = initDuration(hours = 5),
  activityId = "1234",
  important = true
)

suite "task creation":
  test "task text features":
    check task.textFeatures == "Test task [routine] #a1234 #t600 #important"

  test "task id":
    check task.id.`$`.len == 10

  test "task to json":
    let node = task.toJson
    check node[0].getInt.`$`.len == 10
    check node[1].getStr == task.textFeatures
    check node[2].getInt > 0
    check node[3].getInt == 1
    check node[4].getStr == "1"
    check node[5].getInt == initDuration(hours = 5).inSeconds
    check node[6].getInt == 1

suite "export file":
  let exportFile = %*{
    "activities": [
      [
        %1234,
        %"Getting ready",
      ],
      [
        %5678,
        %"Work",
      ]
    ],
    "repeatings": [
      initTtmRepeatingTask(
        name = "Wake up",
        activityId = "1234",
        duration = initDuration(minutes = 10),
        scheduled = initDuration(hours = 10),
      ).toJson,
      initTtmRepeatingTask(
        name = "Work at PC",
        activityId = "5678",
        duration = initDuration(hours = 2),
        scheduled = initDuration(hours = 8),
      ).toJson,
      [
        1234,
        "Existing task",
        0,
        0,
        "1",
        0,
        0
      ]
    ]
  }

  test "read activities":
    let activities = exportFile.activities
    check activities["Getting ready"] == "1234"
    check activities["Work"] == "5678"

  test "filter generated tasks":
    var newExportFile = exportFile
    newExportFile.repeatings = @[
      task
    ]
    check newExportFile["repeatings"].len == 2
    check newExportFile["repeatings"][1][1].getStr == task.textFeatures
