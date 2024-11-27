import Testing
@testable import Calendars

@Test func testSwedishDateFormat() async throws {
  let jd = SwedishCalendar.toJDN(Y: 1700, M: 3, D: 1)
  let hd = HistoricDate(jd: Double(jd))
  let fmt = HistoricDateFormatter(calendar: .swedish, format: .ymd)
  let str = fmt.format(hd)

  #expect(str == "1700-March-01")
}
