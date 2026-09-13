import Testing
@testable import Calendars

@Test("Jewish conversion preserves the Battle of Cannae absolute day")
func jewishCalendarRoundTripsBattleOfCannae() {
    let cannaeJDN = JulianCalendar.toJDN(Y: -215, M: 8, D: 2)
    let (year, month, day) = JewishCalendar.toDate(J: cannaeJDN)

    #expect(JewishCalendar.toJDN(Y: year, M: month, D: day) == cannaeJDN)
}

@Test("Jewish conversion handles the formerly crashing year type")
func jewishCalendarHandlesFirstTableRow() {
    let jdn = JewishCalendar.toJDN(Y: 7306, M: 4, D: 3)
    let (year, month, day) = JewishCalendar.toDate(J: jdn)

    #expect(year == 7306)
    #expect(month == 4)
    #expect(day == 3)
}

@Test("Jewish conversion round-trips absolute days across year types")
func jewishCalendarRoundTripsAcrossYearTypes() {
    let firstJDN = JewishCalendar.toJDN(Y: 1, M: 1, D: 1)
    let lastJDN = JewishCalendar.toJDN(Y: 40, M: 1, D: 1)

    for jdn in firstJDN..<lastJDN {
        let (year, month, day) = JewishCalendar.toDate(J: jdn)
        #expect(JewishCalendar.toJDN(Y: year, M: month, D: day) == jdn)
    }
}
