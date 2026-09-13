import Testing
@testable import Calendars

struct CalendarRoundTripCase: Sendable, CustomTestStringConvertible {
    let id: CalendarId
    let jdnRange: ClosedRange<Int>

    var testDescription: String { id.description }
}

let calendarRoundTripCases: [CalendarRoundTripCase] = [
    .init(id: .gregorian, jdnRange: GregorianCalendar.toJDN(Y: -40, M: 1, D: 1)...GregorianCalendar.toJDN(Y: 40, M: 12, D: 31)),
    .init(id: .julian, jdnRange: JulianCalendar.toJDN(Y: -40, M: 1, D: 1)...JulianCalendar.toJDN(Y: 40, M: 12, D: 31)),
    .init(id: .swedish, jdnRange: SwedishCalendar.epoch...SwedishCalendar.endEpoch),
    .init(id: .civilIslamic, jdnRange: CivilIslamicCalendar.toJDN(Y: 1, M: 1, D: 1)...CivilIslamicCalendar.toJDN(Y: 80, M: 12, D: 29)),
    .init(id: .saka, jdnRange: SakaCalendar.toJDN(Y: 1, M: 1, D: 1)...SakaCalendar.toJDN(Y: 80, M: 12, D: 30)),
    .init(id: .egyptian, jdnRange: EgyptianCalendar.toJDN(Y: 1, M: 1, D: 1)...EgyptianCalendar.toJDN(Y: 80, M: 13, D: 5)),
    .init(id: .ethiopian, jdnRange: EthiopianCalendar.toJDN(Y: 1, M: 1, D: 1)...EthiopianCalendar.toJDN(Y: 80, M: 13, D: 5)),
    .init(id: .frenchRepublican, jdnRange: FrenchRepublicanCalendar.toJDN(Y: 1, M: 1, D: 1)...FrenchRepublicanCalendar.toJDN(Y: 80, M: 13, D: 5)),
    .init(id: .coptic, jdnRange: CopticCalendar.toJDN(Y: 1, M: 1, D: 1)...CopticCalendar.toJDN(Y: 80, M: 13, D: 5)),
    .init(id: .bahai, jdnRange: BahaiCalendar.toJDN(Y: 1, M: 1, D: 1)...BahaiCalendar.toJDN(Y: 80, M: 20, D: 19)),
    .init(id: .jewish, jdnRange: JewishCalendar.toJDN(Y: 1, M: 1, D: 1)...JewishCalendar.toJDN(Y: 80, M: 1, D: 1)),
    // The reconstructed Roman table begins at AUC 491; earlier dates use a separate extrapolation model.
    .init(id: .romanRepublican, jdnRange: 1_625_460...JulianCalendar.toJDN(Y: 100, M: 12, D: 31))
]

@Test("Calendar JDN conversions round-trip", arguments: calendarRoundTripCases)
func calendarJDNConversionsRoundTrip(testCase: CalendarRoundTripCase) throws {
    let calendar = try #require(CalendarRegistry.shared.calendar(for: testCase.id))

    if testCase.id == .romanRepublican {
        try withKnownIssue("Roman reconstructed leading fragments do not yet round-trip") {
            try verifyRoundTrips(calendar: calendar, testCase: testCase)
        }
    } else {
        try verifyRoundTrips(calendar: calendar, testCase: testCase)
    }
}

private func verifyRoundTrips(calendar: CalendarProtocol, testCase: CalendarRoundTripCase) throws {
    for jdn in testCase.jdnRange {
        let date = try #require(calendar.date(fromJDN: jdn), "\(testCase.id) returned no date for JDN \(jdn)")
        let month = try #require(date.month, "\(testCase.id) returned no month for JDN \(jdn)")
        let day = try #require(date.day, "\(testCase.id) returned no day for JDN \(jdn)")
        let result = calendar.jdn(forYear: date.year, month: month, day: day)

        #expect(result == jdn, "\(testCase.id): JDN \(jdn) returned \(date.year)-\(month)-\(day), which converted to \(result)")
    }
}

@Test("Mesoamerican Long Count round-trips through JDN")
func mesoamericanLongCountRoundTripsThroughJDN() {
    let start = MesoamericanLongCountCalendar.toJDN(baktun: 0, katun: 0, tun: 0, winal: 0, kin: 0)
    let end = MesoamericanLongCountCalendar.toJDN(piktun: 1, baktun: 0, katun: 0, tun: 0, winal: 0, kin: 0)

    for jdn in stride(from: start, through: end, by: 97) {
        let date = MesoamericanLongCountCalendar.toDate(J: jdn)
        let result = MesoamericanLongCountCalendar.toJDN(
            hablatun: date.hablatun,
            alautun: date.alautun,
            kinchiltun: date.kinchiltun,
            kalabtun: date.kalabtun,
            piktun: date.piktun,
            baktun: date.baktun,
            katun: date.katun,
            tun: date.tun,
            winal: date.winal,
            kin: date.kin
        )
        #expect(result == jdn)
    }
}
