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

@Test
func testRomanToJDN() async throws {
  var jdn = RomanCalendar.shared.jdn(forYear:491, month: RomanMonth.IAN.slot, day: 1)
  #expect(jdn == 1625698)

  jdn = RomanCalendar.shared.jdn(forYear:491, month: RomanMonth.IAN.slot, day: 2)
  #expect(jdn == 1625699)
}

@Test
func testJDNToRoman() async throws {
  let date = RomanCalendar.shared.date(fromJDN: 1625698)
  #expect(date?.year == 491)
  #expect(date?.month == 0)
  #expect(date?.day == 1)
}

