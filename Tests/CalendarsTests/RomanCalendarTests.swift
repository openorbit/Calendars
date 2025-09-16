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
func testRomanIdes15YearStartDateRoundtrip() async throws {
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



  let reverse = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 9))
  #expect(reverse!.year == 532)
  #expect(reverse!.month == 1)
  #expect(reverse!.day == 1)
}
