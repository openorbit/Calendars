import Testing
@testable import Calendars

@Test("Swedish Easter follows Julian computus in the anomalous calendar")
func swedishAnomalousCalendarEaster() {
  let expected = [
    1700: (4, 1), 1701: (4, 21), 1702: (4, 6), 1703: (3, 29),
    1704: (4, 17), 1705: (4, 2), 1706: (3, 25), 1707: (4, 14),
    1708: (4, 5), 1709: (4, 18), 1710: (4, 10), 1711: (3, 26),
  ]

  for (year, date) in expected {
    let (actualYear, actualMonth, actualDay) = SwedishCalendar.dayOfEaster(Y: year)
    #expect(actualYear == year)
    #expect(actualMonth == date.0)
    #expect(actualDay == date.1)
    #expect(SwedishCalendar.dayOfWeek(Y: actualYear, M: actualMonth, D: actualDay) == 1)
  }
}

@Test("Swedish Easter in 1709 was four weeks after Gregorian and one week before Julian Easter")
func swedishEasterWasUniqueIn1709() {
  let (swedishYear, swedishMonth, swedishDay) = SwedishCalendar.dayOfEaster(Y: 1709)
  let (gregorianYear, gregorianMonth, gregorianDay) = GregorianCalendar.dayOfEaster(Y: 1709)
  let (julianYear, julianMonth, julianDay) = JulianCalendar.dayOfEaster(Y: 1709)

  let swedishJDN = SwedishCalendar.toJDN(Y: swedishYear, M: swedishMonth, D: swedishDay)
  let gregorianJDN = GregorianCalendar.toJDN(
    Y: gregorianYear,
    M: gregorianMonth,
    D: gregorianDay)
  let julianJDN = JulianCalendar.toJDN(Y: julianYear, M: julianMonth, D: julianDay)

  #expect(swedishJDN - gregorianJDN == 28)
  #expect(julianJDN - swedishJDN == 7)
}

@Test("Swedish astronomical Easter dates before Gregorian adoption")
func swedishAstronomicalEasterInJulianCalendar() {
  let expected = [
    1740: (4, 6), 1741: (3, 22), 1742: (3, 14), 1743: (4, 3),
    1744: (3, 18), 1745: (4, 7), 1746: (3, 30), 1747: (3, 22),
    1748: (4, 3), 1749: (3, 26), 1750: (3, 18), 1751: (3, 31),
    1752: (3, 22),
  ]

  for (year, date) in expected {
    let (_, month, day) = SwedishCalendar.dayOfEaster(Y: year)
    #expect(month == date.0)
    #expect(day == date.1)
    #expect(SwedishCalendar.dayOfWeek(Y: year, M: month, D: day) == 1)
  }
}

@Test("Swedish Easter after Gregorian civil calendar adoption")
func swedishAstronomicalEasterInGregorianCalendar() {
  let anomalies = [1802: (4, 25), 1805: (4, 21), 1818: (3, 29)]

  for (year, date) in anomalies {
    let (_, month, day) = SwedishCalendar.dayOfEaster(Y: year)
    #expect(month == date.0)
    #expect(day == date.1)
  }

  // These projected astronomical postponements were not observed in Sweden.
  for year in [1825, 1829, 1844] {
    let (expectedYear, expectedMonth, expectedDay) = GregorianCalendar.dayOfEaster(Y: year)
    let (actualYear, actualMonth, actualDay) = SwedishCalendar.dayOfEaster(Y: year)
    #expect(actualYear == expectedYear)
    #expect(actualMonth == expectedMonth)
    #expect(actualDay == expectedDay)
  }
}
