import Testing
@testable import Calendars

@Test func testParseISODate() async throws {
  let ymd = DateParser.parse("2022-01-01", calendar: .gregorian)

  #expect(ymd != nil)

  #expect(ymd!.0 == 2022)
  #expect(ymd!.1 == 1)
  #expect(ymd!.2 == 1)
}


@Test func testParseMonthDayDate() async throws {
  let ymd = DateParser.parse("January 1, 2022", calendar: .gregorian)

  #expect(ymd != nil)

  #expect(ymd!.0 == 2022)
  #expect(ymd!.1 == 1)
  #expect(ymd!.2 == 1)


  let ymd2 = DateParser.parse("January 1 2022", calendar: .gregorian)

  #expect(ymd2 != nil)

  #expect(ymd2!.0 == 2022)
  #expect(ymd2!.1 == 1)
  #expect(ymd2!.2 == 1)
}


@Test func testParseDayMonthDate() async throws {
  let ymd = DateParser.parse("1 January 2022", calendar: .gregorian)

  #expect(ymd != nil)

  #expect(ymd!.0 == 2022)
  #expect(ymd!.1 == 1)
  #expect(ymd!.2 == 1)
}
