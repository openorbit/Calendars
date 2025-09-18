//
//  RomanCalendarTests.swift
//  Calendars
//
//  Created by Mattias Holm on 2025-09-08.
//
import Testing
@testable import Calendars

@Test
func testRomanFirstDateRoundtrip() async throws {
  // AUC 491 MAI = Julian -262-4-8
  #expect(
    RomanCalendar.shared.jdn(forYear:491, month: 1, day: 1)
    == JulianCalendar.shared.jdn(forYear: -262, month: 4, day: 8))


  let reverse = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -262, month: 4, day: 8))
  #expect(reverse!.year == 491)
  #expect(reverse!.month == 1)
  #expect(reverse!.day == 1)
}


@Test
func testRomanIdes15YearStartDate() async throws {
  // AUC 532 MAR 15 = = 532-0-1 = Julian -262-3-23
  // AUC 532 APR 1 = Julian -221,4,9
  #expect(
    RomanCalendar.shared.jdn(forYear:532, month: 0, day: 1)
    == JulianCalendar.shared.jdn(forYear: -221, month: 3, day: 23))

  #expect(
    RomanCalendar.shared.jdn(forYear:532, month: 0, day: 17)
    == JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 8))

  #expect(
    RomanCalendar.shared.jdn(forYear:532, month: 1, day: 1)
    == JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 9))

  #expect(
    RomanCalendar.shared.jdn(forYear:532, month: 1, day: 15)
    == JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 23))


  #expect(
    RomanCalendar.shared.jdn(forYear:532, month: 13, day: 1)
    == JulianCalendar.shared.jdn(forYear: -220, month: 3, day: 21))

  #expect(
    RomanCalendar.shared.jdn(forYear:532, month: 13, day: 14)
    == JulianCalendar.shared.jdn(forYear: -220, month: 4, day: 3))
}


@Test
func testRomanIdes15YearStartDateReverse() async throws {
  let reverse = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 9))
  #expect(reverse!.year == 532)
  #expect(reverse!.month == 1)
  #expect(reverse!.day == 1)

  let a =
  RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -221, month: 3, day: 23))
  #expect(a!.year == 532)
  #expect(a!.month == 0)
  #expect(a!.day == 1)

  let b = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 8))
  #expect(b!.year == 532)
  #expect(b!.month == 0)
  #expect(b!.day == 17)

  let c = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 9))
  #expect(c!.year == 532)
  #expect(c!.month == 1)
  #expect(c!.day == 1)

  let d = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 23))
  #expect(d!.year == 532)
  #expect(d!.month == 1)
  #expect(d!.day == 15)

  let e = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -220, month: 3, day: 21))
  #expect(e!.year == 532)
  #expect(e!.month == 13)
  #expect(e!.day == 1)

  let f = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -220, month: 4, day: 3))
  #expect(f!.year == 532)
  #expect(f!.month == 13)
  #expect(f!.day == 14)
}
