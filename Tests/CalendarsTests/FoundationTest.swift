import Foundation
import Testing
@testable import Calendars

@Test func testFoundationJDToDate() async throws {

  let date = FoundationDate.toDate(2460626.0)
  let isoDate = "2024-11-11T12:00:00+0000"

  let dateFormatter = ISO8601DateFormatter()
  let foundationDate = dateFormatter.date(from:isoDate)!


  #expect(date == foundationDate)
}

@Test func testFoundationDateToJD() async throws {
  let isoDate = "2024-11-11T12:00:00+0000"

  let dateFormatter = ISO8601DateFormatter()
  let foundationDate = dateFormatter.date(from:isoDate)!
  let date = FoundationDate.toJD(foundationDate)

  #expect(date == 2460626.0)
}
