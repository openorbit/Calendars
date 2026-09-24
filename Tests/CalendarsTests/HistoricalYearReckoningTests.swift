import Testing
@testable import Calendars

@Test("Fixed historical New Year rules resolve labelled spans")
func fixedHistoricalYearSpans() throws {
  let annunciation = try #require(HistoricalYearResolver.span(
    labeledYear: 1684,
    calendar: JulianCalendar.shared,
    yearStart: .march25
  ))
  #expect(annunciation.startJDN == JulianCalendar.toJDN(Y: 1684, M: 3, D: 25))
  #expect(annunciation.endJDN == JulianCalendar.toJDN(Y: 1685, M: 3, D: 24))

  let christmas = try #require(HistoricalYearResolver.span(
    labeledYear: 800,
    calendar: JulianCalendar.shared,
    yearStart: .december25
  ))
  #expect(christmas.startJDN == JulianCalendar.toJDN(Y: 799, M: 12, D: 25))
  #expect(christmas.endJDN == JulianCalendar.toJDN(Y: 800, M: 12, D: 24))
}

@Test("Historical year containing a day uses the alternative label")
func historicalYearContainingDay() throws {
  let jdn = JulianCalendar.toJDN(Y: 1685, M: 2, D: 10)
  let span = try #require(HistoricalYearResolver.span(
    containing: jdn,
    calendar: JulianCalendar.shared,
    yearStart: .march25
  ))
  #expect(span.labeledYear == 1684)
}

@Test("Regnal polity calendar rules change over time")
func regnalPolityCalendarRulesChangeOverTime() throws {
  let regnal = RegnalCalendar.shared
  let sweden1270 = try #require(regnal.calendarRule(
    forPolity: "POLITY_SWEDEN",
    onJDN: JulianCalendar.toJDN(Y: 1270, M: 2, D: 10)
  ))
  #expect(sweden1270.calendarID == .julian)
  #expect(sweden1270.historicalYearStart == .march25)

  let sweden1700 = try #require(regnal.calendarRule(
    forPolity: "POLITY_SWEDEN",
    onJDN: SwedishCalendar.toJDN(Y: 1700, M: 3, D: 1)
  ))
  #expect(sweden1700.calendarID == .swedish)
  #expect(sweden1700.historicalYearStart == .january1)

  let sweden1712 = try #require(regnal.calendarRule(
    forPolity: "POLITY_SWEDEN",
    onJDN: SwedishCalendar.toJDN(Y: 1712, M: 2, D: 30)
  ))
  #expect(sweden1712.calendarID == .swedish)

  let swedenRestoredJulian = try #require(regnal.calendarRule(
    forPolity: "POLITY_SWEDEN",
    onJDN: JulianCalendar.toJDN(Y: 1712, M: 3, D: 1)
  ))
  #expect(swedenRestoredJulian.calendarID == .julian)

  let swedenGregorian = try #require(regnal.calendarRule(
    forPolity: "POLITY_SWEDEN",
    onJDN: GregorianCalendar.toJDN(Y: 1753, M: 3, D: 1)
  ))
  #expect(swedenGregorian.calendarID == .gregorian)

  let selection = regnal.monarchSelection(
    forPolity: "POLITY_SWEDEN",
    onJDN: JulianCalendar.toJDN(Y: 1270, M: 6, D: 1)
  )
  #expect(selection.primary?.personID == "P_VALDEMAR_SW")
  #expect(selection.isAmbiguous == false)
  #expect(selection.primary.flatMap {
    regnal.exactRegnalYear(
      containing: JulianCalendar.toJDN(Y: 1270, M: 6, D: 1),
      tenure: $0
    )
  } == nil)

  let polityID = "POLITY_DENMARK_KINGDOM"
  let medieval = try #require(regnal.calendarRule(
    forPolity: polityID,
    onJDN: JulianCalendar.toJDN(Y: 1500, M: 2, D: 10)
  ))
  #expect(medieval.calendarID == .julian)
  #expect(medieval.historicalYearStart == .march25)

  let earlyModern = try #require(regnal.calendarRule(
    forPolity: polityID,
    onJDN: JulianCalendar.toJDN(Y: 1600, M: 2, D: 10)
  ))
  #expect(earlyModern.calendarID == .julian)
  #expect(earlyModern.historicalYearStart == .january1)

  let modern = try #require(regnal.calendarRule(
    forPolity: polityID,
    onJDN: GregorianCalendar.toJDN(Y: 1800, M: 2, D: 10)
  ))
  #expect(modern.calendarID == .gregorian)
  #expect(modern.historicalYearStart == .january1)
}

@Test("Swedish regnal years use exact accession anniversaries")
func swedishRegnalYearsUseAccessionAnniversaries() throws {
  let regnal = RegnalCalendar.shared
  let tenure = try #require(
    regnal.findTenures(forMonarch: "Gustav III")
      .first { $0.officeID == "OFFICE_SWEDEN_KING" }
  )

  let beforeAnniversary = GregorianCalendar.toJDN(Y: 1772, M: 2, D: 11)
  let onAnniversary = GregorianCalendar.toJDN(Y: 1772, M: 2, D: 12)

  #expect(regnal.exactRegnalYear(containing: beforeAnniversary, tenure: tenure)?.regnalYear == 1)
  #expect(regnal.exactRegnalYear(containing: onAnniversary, tenure: tenure)?.regnalYear == 2)
}

@Test("An open current Swedish reign still has exact regnal years")
func openSwedishReignHasExactRegnalYears() throws {
  let regnal = RegnalCalendar.shared
  let date = GregorianCalendar.toJDN(Y: 2026, M: 9, D: 24)
  let selection = regnal.monarchSelection(forPolity: "POLITY_SWEDEN", onJDN: date)
  let tenure = try #require(selection.primary)
  let span = try #require(regnal.exactRegnalYear(containing: date, tenure: tenure))

  #expect(tenure.personID == "P_CARL_XVI_GUSTAF")
  #expect(span.regnalYear == 54)
  #expect(span.startJDN == GregorianCalendar.toJDN(Y: 2026, M: 9, D: 15))
  #expect(span.endJDN == GregorianCalendar.toJDN(Y: 2027, M: 9, D: 14))
}

@Test("Fixed New Year rules work with non-Julian calendars")
func fixedNewYearRulesAreCalendarGeneric() throws {
  let span = try #require(HistoricalYearResolver.span(
    labeledYear: 10,
    calendar: EthiopianCalendar.shared,
    yearStart: .september1
  ))
  #expect(span.startJDN == EthiopianCalendar.shared.jdn(forYear: 9, month: 9, day: 1))
  #expect(span.endJDN == EthiopianCalendar.shared.jdn(forYear: 10, month: 8, day: 30))
}
