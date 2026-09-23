import Testing
@testable import Calendars

@Test("Coptic calendar exposes its epagomenal month")
func copticMonthStructure() {
  let commonMonths = CopticCalendar.shared.months(forYear: 2, mode: .civil)
  let leapMonths = CopticCalendar.shared.months(forYear: 3, mode: .civil)

  #expect(commonMonths.count == 13)
  #expect(commonMonths.prefix(12).allSatisfy { $0.length == 30 })
  #expect(commonMonths[12].length == 5)
  #expect(commonMonths[12].spec.intercalary)
  #expect(leapMonths[12].length == 6)
  #expect(leapMonths[12].leapDayNumber == 6)
  #expect(CopticCalendar.nameOfMonth(1) == "Thout")
  #expect(CopticCalendar.nameOfMonth(13) == "Pi Kogi Enavot")
  #expect(CopticCalendar.numberOfMonth("pi kogi enavot") == 13)
  #expect(CopticCalendar.isValidDate(Y: 3, M: 13, D: 6))
  #expect(!CopticCalendar.isValidDate(Y: 2, M: 13, D: 6))
}

@Test("Ethiopian calendar exposes Pagume")
func ethiopianMonthStructure() {
  let commonMonths = EthiopianCalendar.shared.months(forYear: 2, mode: .civil)
  let leapMonths = EthiopianCalendar.shared.months(forYear: 3, mode: .civil)

  #expect(commonMonths.count == 13)
  #expect(commonMonths.prefix(12).allSatisfy { $0.length == 30 })
  #expect(commonMonths[12].length == 5)
  #expect(commonMonths[12].spec.intercalary)
  #expect(leapMonths[12].length == 6)
  #expect(leapMonths[12].leapDayNumber == 6)
  #expect(EthiopianCalendar.nameOfMonth(1) == "Meskerem")
  #expect(EthiopianCalendar.nameOfMonth(13) == "Pagume")
  #expect(EthiopianCalendar.numberOfMonth("pagume") == 13)
  #expect(EthiopianCalendar.isValidDate(Y: 3, M: 13, D: 6))
  #expect(!EthiopianCalendar.isValidDate(Y: 2, M: 13, D: 6))
}

@Test("French Republican calendar exposes the complementary days")
func frenchRepublicanMonthStructure() {
  let commonMonths = FrenchRepublicanCalendar.shared.months(forYear: 2, mode: .civil)
  let leapMonths = FrenchRepublicanCalendar.shared.months(forYear: 3, mode: .civil)

  #expect(commonMonths.count == 13)
  #expect(commonMonths.prefix(12).allSatisfy { $0.length == 30 })
  #expect(commonMonths[12].length == 5)
  #expect(commonMonths[12].spec.intercalary)
  #expect(leapMonths[12].length == 6)
  #expect(leapMonths[12].leapDayNumber == 6)
  #expect(FrenchRepublicanCalendar.nameOfMonth(13) == "Sansculottides")
  #expect(FrenchRepublicanCalendar.numberOfMonth("vendémiaire") == 1)
  #expect(FrenchRepublicanCalendar.numberOfMonth("Sansculottides") == 13)
  #expect(FrenchRepublicanCalendar.isValidDate(Y: 3, M: 13, D: 6))
  #expect(!FrenchRepublicanCalendar.isValidDate(Y: 2, M: 13, D: 6))
}

@Test("Epagomenal dates round-trip through JDN")
func epagomenalDatesRoundTrip() {
  let cases: [(any CalendarProtocol, Int, Int)] = [
    (CopticCalendar.shared, 3, 6),
    (EthiopianCalendar.shared, 3, 6),
    (FrenchRepublicanCalendar.shared, 3, 6)
  ]

  for (calendar, year, day) in cases {
    let jdn = calendar.jdn(forYear: year, month: 13, day: day)
    let date = calendar.date(fromJDN: jdn)
    #expect(date?.year == year)
    #expect(date?.month == 13)
    #expect(date?.day == day)
  }
}
