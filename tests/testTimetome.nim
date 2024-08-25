from std/times import initDuration, inSeconds
import std/json
import std/unittest

import routineParserpkg/timetome

let task = initTtmRepeatingTask(
  name = "Test task",
  duration = initDuration(minutes = 10),
  scheduled = initDuration(hours = 5)
)

test "task text features":
  check task.textFeatures == "Test task #d600"

test "task id":
  check task.id.`$`.len == 10

test "task to json":
  let node = task.toJson
  check node[0].getInt.`$`.len == 10
  check node[1].getStr == task.textFeatures
  check node[2].getInt == 0
  check node[3].getInt == 1
  check node[4].getStr == "1"
  check node[5].getInt == initDuration(hours = 5).inSeconds
  check node[6].getInt == 0
