from std/times import initDateTime, Month
import std/unittest

import routineParserpkg/utils
from routineParserpkg/config import RoutineBlockRepetition

suite "Repeat parsing":
  let
    dtSunday = initDateTime(1, mSep, 2024, 00, 00, 00, 00)
    dtMonday = initDateTime(2, mSep, 2024, 00, 00, 00, 00)
    dtWednesday = initDateTime(31, mJul, 2024, 00, 00, 00, 00)

  test "Specific weekday":
    check Sunday.isForToday dtSunday
    check not Sunday.isForToday dtMonday
    check not Sunday.isForToday dtWednesday

    check not Monday.isForToday dtSunday
    check Monday.isForToday dtMonday
    check not Monday.isForToday dtWednesday

    check not Wednesday.isForToday dtSunday
    check not Wednesday.isForToday dtMonday
    check Wednesday.isForToday dtWednesday

    check {Wednesday, Sunday}.isForToday dtSunday
    check not {Wednesday, Sunday, Weekends}.isForToday dtMonday
    check {Weekdays, Wednesday}.isForToday dtWednesday


  test "Everyday":
    check Everyday.isForToday dtSunday
    check Everyday.isForToday dtMonday
    check Everyday.isForToday dtWednesday

  test "Weekdays":
    check not Weekdays.isForToday dtSunday
    check Weekdays.isForToday dtMonday
    check Weekdays.isForToday dtWednesday

  test "Weekends":
    check Weekends.isForToday dtSunday
    check not Weekends.isForToday dtMonday
    check not Weekends.isForToday dtWednesday

  test "Month start":
    check Monthstart.isForToday dtSunday
    check not Monthstart.isForToday dtMonday
    check not Monthstart.isForToday dtWednesday

  test "Month end":
    check not Monthend.isForToday dtSunday
    check not Monthend.isForToday dtMonday
    check Monthend.isForToday dtWednesday
