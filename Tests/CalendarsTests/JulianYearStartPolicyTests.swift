import Testing
@testable import Calendars

@Test
func testHollandBoundaryTransition() async throws {
  let before = JulianYearStartPolicy.culture(
    for: .estatesOfHolland,
    usage: .civil,
    year: 1531,
    month: 12,
    day: 31,
    in: .julian
  )
  #expect(before == .annunciationMar25)

  let after = JulianYearStartPolicy.culture(
    for: .estatesOfHolland,
    usage: .civil,
    year: 1532,
    month: 1,
    day: 1,
    in: .julian
  )
  #expect(after == .civilJan1)
}

@Test
func testFranceAndUtrechtBoundaries() async throws {
  let franceBefore = JulianYearStartPolicy.culture(
    for: .france,
    usage: .civil,
    year: 1566,
    month: 12,
    day: 31,
    in: .julian
  )
  #expect(franceBefore == .annunciationMar25)

  let franceAfter = JulianYearStartPolicy.culture(
    for: .france,
    usage: .civil,
    year: 1567,
    month: 1,
    day: 1,
    in: .julian
  )
  #expect(franceAfter == .civilJan1)

  let utrechtBefore = JulianYearStartPolicy.culture(
    for: .utrecht,
    usage: .civil,
    year: 1699,
    month: 12,
    day: 31,
    in: .julian
  )
  #expect(utrechtBefore == .annunciationMar25)

  let utrechtAfter = JulianYearStartPolicy.culture(
    for: .utrecht,
    usage: .civil,
    year: 1700,
    month: 1,
    day: 1,
    in: .julian
  )
  #expect(utrechtAfter == .civilJan1)
}

@Test
func testSpecificRulePreferredOverGlobalFallback() async throws {
  let specific = JulianYearStartPolicy.culture(
    for: .estatesOfHolland,
    usage: .civil,
    year: 1500,
    month: 1,
    day: 1,
    in: .julian
  )
  #expect(specific == .annunciationMar25)

  let globalOnly = JulianYearStartPolicy.culture(
    for: .global,
    usage: .civil,
    year: 1500,
    month: 1,
    day: 1,
    in: .julian
  )
  #expect(globalOnly == .civilJan1)
}

@Test
func testUsageWithoutRulesReturnsNil() async throws {
  let ecclesiastical = JulianYearStartPolicy.culture(
    for: .france,
    usage: .ecclesiastical,
    year: 1600,
    month: 1,
    day: 1,
    in: .julian
  )
  #expect(ecclesiastical == nil)
}

@Test
func testJulianCalendarConvenienceDelegatesToPolicy() async throws {
  let policyValue = JulianYearStartPolicy.culture(
    for: .utrecht,
    usage: .civil,
    year: 1700,
    month: 1,
    day: 1,
    in: .julian
  )
  let calendarValue = JulianCalendar.shared.yearStartCulture(
    for: .utrecht,
    usage: .civil,
    year: 1700,
    month: 1,
    day: 1,
    in: .julian
  )
  #expect(calendarValue == policyValue)
  #expect(calendarValue == .civilJan1)
}

