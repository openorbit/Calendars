//
//  RomanCalendarTests.swift
//  Calendars
//
//  Created by Mattias Holm on 2025-09-08.
//
import Testing
@testable import Calendars

@Test func testRomanCalendar() async throws {
  var jd = RomanCalendar.shared.julian(forRomanYear: 491, month: .IAN, day: 1)
  #expect(jd.year == -262)
  #expect(jd.month == 12)
  #expect(jd.day == 2)


  jd = RomanCalendar.shared.julian(forRomanYear: 491, month: .FEB, day: 1)
  #expect(jd.year == -262)
  #expect(jd.month == 12)
  #expect(jd.day == 31)

  jd = RomanCalendar.shared.julian(forRomanYear: 491, month: .MAR, day: 1)
  #expect(jd.year == -261)
  #expect(jd.month == 1)
  #expect(jd.day == 28)

  jd = RomanCalendar.shared.julian(forRomanYear: 491, month: .APR, day: 1)
  #expect(jd.year == -261)
  #expect(jd.month == 2)
  #expect(jd.day == 28)


  jd = RomanCalendar.shared.julian(forRomanYear: 492, month: .MAI, day: 1)
  #expect(jd.year == -261)
  #expect(jd.month == 3)
  #expect(jd.day == 29)

}
