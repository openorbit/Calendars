import Testing
@testable import Calendars

@Test func sevenDayCycleUsesMondayBasedOrdinals() throws {
  let jdn = GregorianCalendar.toJDN(Y: 2000, M: 1, D: 1)
  let day = try #require(GregorianCalendar.shared.cycleDay(atJDN: jdn, cycle: .sevenDay))
  #expect(day.ordinal == 5)
  #expect(day.label == "Saturday")
  #expect(day.isRestDay)
}

@Test func frenchDecadesRestartWithinEveryMonth() throws {
  let calendar = FrenchRepublicanCalendar.shared
  let primidi = try #require(calendar.cycleDay(atJDN: calendar.jdn(forYear: 2, month: 1, day: 1), cycle: .frenchDecade))
  let decadi = try #require(calendar.cycleDay(atJDN: calendar.jdn(forYear: 2, month: 1, day: 10), cycle: .frenchDecade))
  let complementary = try #require(calendar.cycleDay(atJDN: calendar.jdn(forYear: 2, month: 13, day: 1), cycle: .frenchDecade))
  #expect(primidi.ordinal == 0)
  #expect(decadi.ordinal == 9)
  #expect(decadi.isRestDay)
  #expect(complementary.ordinal == nil)
  #expect(complementary.role == .supplementary)
}

@Test func romanCycleUsesReconstructedMarketLetter() throws {
  let calendar = RomanCalendar.shared
  let start = try #require(calendar.startOfYearJDN(year: 600))
  let first = try #require(calendar.cycleDay(atJDN: start, cycle: .nundinal))
  let market = try #require(calendar.cycleDay(atJDN: start + 5, cycle: .nundinal))
  #expect(first.label == "A")
  #expect(!first.isRestDay)
  #expect(market.label == "F")
  #expect(market.isRestDay)
}

@Test func julianNundinalCycleRestartsAndHoldsAtBissextum() throws {
  let calendar = JulianCalendar.shared
  let newYear = try #require(calendar.cycleDay(atJDN: calendar.jdn(forYear: 2024, month: 1, day: 1), cycle: .nundinal))
  let firstBissextile = try #require(calendar.cycleDay(atJDN: calendar.jdn(forYear: 2024, month: 2, day: 24), cycle: .nundinal))
  let secondBissextile = try #require(calendar.cycleDay(atJDN: calendar.jdn(forYear: 2024, month: 2, day: 25), cycle: .nundinal))
  #expect(newYear.label == "A")
  #expect(firstBissextile.ordinal == secondBissextile.ordinal)
}

@Test func sovietFiveDayCycleIdentifiesGroupsAndExcludedHolidays() throws {
  let calendar = GregorianCalendar.shared
  let januaryFirst = try #require(calendar.cycleDay(atJDN: GregorianCalendar.toJDN(Y: 1930, M: 1, D: 1), cycle: .sovietFiveDay))
  let holiday = try #require(calendar.cycleDay(atJDN: GregorianCalendar.toJDN(Y: 1930, M: 1, D: 22), cycle: .sovietFiveDay))
  #expect(januaryFirst.restGroup == .purple)
  #expect(januaryFirst.role == .rotatingRest)
  #expect(holiday.ordinal == nil)
  #expect(holiday.role == .publicHoliday)
}

@Test func sovietSixDayCycleUsesFixedMonthDates() throws {
  let calendar = GregorianCalendar.shared
  let rest = try #require(calendar.cycleDay(atJDN: GregorianCalendar.toJDN(Y: 1932, M: 1, D: 6), cycle: .sovietSixDay))
  let extra = try #require(calendar.cycleDay(atJDN: GregorianCalendar.toJDN(Y: 1932, M: 1, D: 31), cycle: .sovietSixDay))
  let marchSubstitute = try #require(calendar.cycleDay(atJDN: GregorianCalendar.toJDN(Y: 1932, M: 3, D: 1), cycle: .sovietSixDay))
  #expect(rest.role == .commonRest)
  #expect(extra.role == .outsideCycle)
  #expect(marchSubstitute.role == .commonRest)
}
