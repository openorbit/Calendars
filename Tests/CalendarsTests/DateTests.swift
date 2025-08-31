//
//  DateTests.swift
//  Calendars
//
//  Created by Mattias Holm on 2025-08-30.
//
import Testing
@testable import Calendars

@Test
func testJulianDateEaster() {
  #expect(JulianDate.dayOfEaster(year: 1300) == JulianDate(year: 1300, month: 4, day: 10))
  #expect(JulianDate.dayOfEaster(year: 1400) == JulianDate(year: 1400, month: 4, day: 18))
}
