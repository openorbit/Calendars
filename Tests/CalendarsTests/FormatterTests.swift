import Testing
@testable import Calendars



@Test func testGregorianDateFormat() async throws {
  let jdn = GregorianCalendar.toJDN(Y: 1, M: 1, D: 1)
  let hd = HistoricDate(jd: Double(jdn))
  let fmt = HistoricDateFormatter(calendar: .gregorian, format: .ymd)
  let str = fmt.format(hd)

  #expect(str == "0001-January-01")
}


@Test func testJulianDateFormat() async throws {
  let jdn = JulianCalendar.toJDN(Y: 1, M: 1, D: 1)
  let hd = HistoricDate(jd: Double(jdn))
  let fmt = HistoricDateFormatter(calendar: .julian, format: .ymd)
  let str = fmt.format(hd)

  #expect(str == "0001-January-01")
}

@Test func testSwedishDateFormat() async throws {
  let jdn = SwedishCalendar.toJDN(Y: 1700, M: 3, D: 1)
  let hd = HistoricDate(jd: Double(jdn))
  let fmt = HistoricDateFormatter(calendar: .swedish, format: .ymd)
  let str = fmt.format(hd)

  #expect(str == "1700-March-01")
}

@Test func testCivilIslamicDateFormat() async throws {
  let jdn = CivilIslamicCalendar.toJDN(Y: 1, M: 1, D: 1)
  let hd = HistoricDate(jd: Double(jdn))
  let fmt = HistoricDateFormatter(calendar: .civilIslamic, format: .ymd)
  let str = fmt.format(hd)

  #expect(str == "0001-Muharram-01")
}

@Test func testEgyptianDateFormat() async throws {
  let jdn = EgyptianCalendar.toJDN(Y: 1, M: 1, D: 1)
  let hd = HistoricDate(jd: Double(jdn))
  let fmt = HistoricDateFormatter(calendar: .egyptian, format: .ymd)
  let str = fmt.format(hd)

  #expect(str == "0001-Toth-01")
}

@Test func testFrenchDateFormat() async throws {
  let jdn = FrenchRepublicanCalendar.toJDN(Y: 1, M: 1, D: 1)
  let hd = HistoricDate(jd: Double(jdn))
  let fmt = HistoricDateFormatter(calendar: .frenchRepublican, format: .ymd)
  let str = fmt.format(hd)

  #expect(str == "0001-Vendémiaire-01")
}

@Test func testJewishDateFormat() async throws {
  let jdn = JewishCalendar.toJDN(Y: 1, M: 1, D: 1)
  let hd = HistoricDate(jd: Double(jdn))
  let fmt = HistoricDateFormatter(calendar: .jewish, format: .ymd)
  let str = fmt.format(hd)

  #expect(str == "0001-Tishiri-01")
}

@Test func testBahaiDateFormat() async throws {
  let jdn = BahaiCalendar.toJDN(Y: 1, M: 1, D: 1)
  let hd = HistoricDate(jd: Double(jdn))
  let fmt = HistoricDateFormatter(calendar: .bahai, format: .ymd)
  let str = fmt.format(hd)

  #expect(str == "0001-january-01")
}

@Test func testSakaDateFormat() async throws {
  let jdn = SakaCalendar.toJDN(Y: 1, M: 1, D: 1)
  let hd = HistoricDate(jd: Double(jdn))
  let fmt = HistoricDateFormatter(calendar: .saka, format: .ymd)
  let str = fmt.format(hd)

  #expect(str == "0001-Chaitra-01")

}

@Test func testCopticDateFormat() async throws {
  // Epoch is 0284-08-29 (Julian)
  let jdn = CopticCalendar.toJDN(Y: 1, M: 1, D: 1)
  let hd = HistoricDate(jd: Double(jdn))
  let fmt = HistoricDateFormatter(calendar: .coptic, format: .ymd)
  let str = fmt.format(hd)

  #expect(str == "0001-january-01")
}

@Test func testEthiopianDateFormat() async throws {
  // Epoch is 0008-08-29 (Julian)
  let jdn = EthiopianCalendar.toJDN(Y: 1, M: 1, D: 1)
  let hd = HistoricDate(jd: Double(jdn))
  let fmt = HistoricDateFormatter(calendar: .ethiopian, format: .ymd)
  let str = fmt.format(hd)

  #expect(str == "0001-january-01")
}
