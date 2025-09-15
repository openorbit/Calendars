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
