import Testing
@testable import Calendars

@Test func testFirstSwedishDateToJulian() async throws {
  let jd = SwedishCalendar.toJDN(Y: 1700, M: 3, D: 1)
  let jdJulian = JulianCalendar.toJDN(Y: 1700, M: 2, D: 29)
  #expect(jd == jdJulian)

  let (y, m, d) = JulianCalendar.toDate(J: jd)
  #expect(y == 1700)
  #expect(m == 2)
  #expect(d == 29)
}
@Test func testJulianToLastSwedishDate() async throws {
  let jd = SwedishCalendar.toJDN(Y: 1712, M: 2, D: 30)
  let jdJulian = JulianCalendar.toJDN(Y: 1712, M: 2, D: 29)
  #expect(jd == jdJulian)

  let (y, m, d) = SwedishCalendar.toDate(J: jd)
  #expect(y == 1712)
  #expect(m == 2)
  #expect(d == 30)
}

@Test func testSwedishDateToJulian() async throws {
  let jd = SwedishCalendar.toJDN(Y: 1700, M: 12, D: 25)
  let (y, m, d) = JulianCalendar.toDate(J: jd)

  #expect(y == 1700)
  #expect(m == 12)
  #expect(d == 24)
}
@Test func testJulianToSwedishDate() async throws {
  let jd = JulianCalendar.toJDN(Y: 1700, M: 12, D: 24)
  let (y, m, d) = SwedishCalendar.toDate(J: jd)

  #expect(y == 1700)
  #expect(m == 12)
  #expect(d == 25)
}
@Test func testJulianToGregorian() async throws {
  // Julian, Gregorian (Y, M, D)
  let dates = [
    ((   4,  3,  3), (   4,  3,  1)),
    (( 100,  3,  1), ( 100,  2, 28)),
    (( 100,  3,  2), ( 100,  3,  1)),
    (( 200,  2, 29), ( 200,  2, 28)),
    (( 200,  3,  1), ( 200,  3,  1)),
    (( 300,  2, 28), ( 300,  2, 28)),
    (( 300,  2, 29), ( 300,  3,  1)),
    (( 500,  2, 27), ( 500,  2, 28)),
    (( 500,  2, 28), ( 500,  3,  1)),
    (( 600,  2, 26), ( 600,  2, 28)),
    (( 600,  2, 27), ( 600,  3,  1)),
    (( 700,  2, 25), ( 700,  2, 28)),
    (( 700,  2, 26), ( 700,  3,  1)),
    (( 900,  2, 24), ( 900,  2, 28)),
    (( 900,  2, 25), ( 900,  3,  1)),
    ((1000,  2, 23), (1000,  2, 28)),
    ((1000,  2, 24), (1000,  3,  1)),
    ((1100,  2, 22), (1100,  2, 28)),
    ((1100,  2, 23), (1100,  3,  1)),
    ((1300,  2, 21), (1300,  2, 28)),
    ((1300,  2, 22), (1300,  3,  1)),
    ((1400,  2, 20), (1400,  2, 28)),
    ((1400,  2, 21), (1400,  3,  1)),
    ((1500,  2, 19), (1500,  2, 28)),
    ((1500,  2, 20), (1500,  3,  1)),
    ((1582, 10,  4), (1582, 10, 14)),
    ((1582, 10,  5), (1582, 10, 15)),
    ((1700,  2, 18), (1700,  2, 28)),
    ((1700,  2, 19), (1700,  3,  1)),
    ((1800,  2, 17), (1800,  2, 28)),
    ((1800,  2, 18), (1800,  3,  1)),
    ((1900,  2, 16), (1900,  2, 28)),
    ((1900,  2, 17), (1900,  3,  1)),
    ((1923,  2, 15), (1923,  2, 28)),
    ((1923,  2, 16), (1923,  3,  1)),
    ((2100,  2, 15), (2100,  2, 28)),
    ((2100,  2, 16), (2100,  3,  1)
    )
  ]

  for ((julianYear, julianMonth, julianDay), (gregorianYear, gregorianMonth, gregorianDay)) in dates {
    let jjd = JulianCalendar.toJDN(Y: julianYear, M: julianMonth, D: julianDay)
    let gjd = GregorianCalendar.toJDN(Y: gregorianYear, M: gregorianMonth, D: gregorianDay)
    #expect(jjd == gjd)

    let (jy, jm, jd) = JulianCalendar.toDate(J: gjd)
    let (gy, gm, gd) = GregorianCalendar.toDate(J: jjd)

    #expect(gy == gregorianYear)
    #expect(gm == gregorianMonth)
    #expect(gd == gregorianDay)

    #expect(jy == julianYear)
    #expect(jm == julianMonth)
    #expect(jd == julianDay)

  }

  print ("\(JulianCalendar.toJDN(Y: 8, M: 1, D: 1))")
}

@Test func testCivilIslamic() async throws {
  let ijdn = CivilIslamicCalendar.toJDN(Y: 1, M: 1, D: 1)
  let jjdn = JulianCalendar.toJDN(Y: 622, M: 7, D: 16)

  #expect(ijdn == jjdn)
  let (y, m, d) = CivilIslamicCalendar.toDate(J: jjdn)
  #expect(y == 1)
  #expect(m == 1)
  #expect(d == 1)
}

@Test func testFrenchRepublican() async throws {
  let fjdn = FrenchRepublicanCalendar.toJDN(Y: 1, M: 1, D: 1)

  #expect(fjdn == 2375840)
  let (y, m, d) = GregorianCalendar.toDate(J: fjdn)
  #expect(y == 1792)
  #expect(m == 9)
  #expect(d == 22)

  let (fy, fm, fd) = FrenchRepublicanCalendar.toDate(J: 2375840)
  #expect(fy == 1)
  #expect(fm == 1)
  #expect(fd == 1)
}

@Test func testBahai() async throws {
  let bjdn = BahaiCalendar.toJDN(Y: 1, M: 1, D: 1)

  #expect(bjdn == 2394647)
  let (y, m, d) = GregorianCalendar.toDate(J: bjdn)
  #expect(y == 1844)
  #expect(m == 3)
  #expect(d == 21)

  let (by, bm, bd) = BahaiCalendar.toDate(J: 2394647)
  #expect(by == 1)
  #expect(bm == 1)
  #expect(bd == 1)
}

@Test func testJewish() async throws {
  let jdn = JewishCalendar.toJDN(Y: 1, M: 1, D: 1)
  #expect(jdn == 347998)
  let (y, m, d) = JewishCalendar.toDate(J: 347998)
  #expect(y == 1)
  #expect(m == 1)
  #expect(d == 1)
}

@Test func testSaka() async throws {
  let jdn = SakaCalendar.toJDN(Y: 1, M: 1, D: 1)
  #expect(jdn == 1749995)
  let (y, m, d) = SakaCalendar.toDate(J: 1749995)
  #expect(y == 1)
  #expect(m == 1)
  #expect(d == 1)
}

@Test func testEgyptian() throws {
  let jdn = EgyptianCalendar.toJDN(Y: 1, M: 1, D: 1)
  #expect(jdn == 1448638)
  let (y, m, d) = EgyptianCalendar.toDate(J: 1448638)
  #expect(y == 1)
  #expect(m == 1)
  #expect(d == 1)
}

@Test func testMayan() async throws {
  let testDates = [
    (MesoamericanDate(comps: [0, 0, 0, 0, 0]), 584283),
    (MesoamericanDate(comps: [1, 0, 0, 0, 0]), 728283),
    (MesoamericanDate(comps: [2, 0, 0, 0, 0]), 872283),
    (MesoamericanDate(comps: [3, 0, 0, 0, 0]), 1016283),
    (MesoamericanDate(comps: [4, 0, 0, 0, 0]), 1160283),
    (MesoamericanDate(comps: [5, 0, 0, 0, 0]), 1304283),
    (MesoamericanDate(comps: [6, 0, 0, 0, 0]), 1448283),
    (MesoamericanDate(comps: [7, 0, 0, 0, 0]), 1592283),
    (MesoamericanDate(comps: [8, 0, 0, 0, 0]), 1736283),
    (MesoamericanDate(comps: [9, 0, 0, 0, 0]), 1880283),
    (MesoamericanDate(comps: [10, 0, 0, 0, 0]), 2024283),
    (MesoamericanDate(comps: [11, 0, 0, 0, 0]), 2168283),
    (MesoamericanDate(comps: [12, 0, 0, 0, 0]), 2312283),
    (MesoamericanDate(comps: [13, 0, 0, 0, 0]), 2456283),
    (MesoamericanDate(comps: [14, 0, 0, 0, 0]), 2600283),
    (MesoamericanDate(comps: [15, 0, 0, 0, 0]), 2744283),
    (MesoamericanDate(comps: [16, 0, 0, 0, 0]), 2888283),
    (MesoamericanDate(comps: [17, 0, 0, 0, 0]), 3032283),
    (MesoamericanDate(comps: [18, 0, 0, 0, 0]), 3176283),
    (MesoamericanDate(comps: [19, 0, 0, 0, 0]), 3320283),
    (MesoamericanDate(comps: [1, 0, 0, 0, 0, 0]), 3464283),
  ]

  for (meso, jdn) in testDates {
    let calcJdn = MesoamericanLongCountCalendar.toJDN(
      piktun: meso.piktun,
      baktun: meso.baktun,
      katun: meso.katun,
      tun: meso.tun,
      winal: meso.winal,
      kin: meso.kin)
    #expect(calcJdn == jdn)
    let d = MesoamericanLongCountCalendar.toDate(J: jdn)
    #expect(d == meso)
  }
}

@Test func testCoptic() async throws {
  // Epoch is 0284-08-29 (Julian)
  let jdn = CopticCalendar.toJDN(Y: 1, M: 1, D: 1)
  #expect(jdn == 1825030)
  let (y, m, d) = CopticCalendar.toDate(J: 1825030)
  #expect(y == 1)
  #expect(m == 1)
  #expect(d == 1)
}

@Test func testEthiopian() async throws {
  // Epoch is 0008-08-29 (Julian)
  let jdn = EthiopianCalendar.toJDN(Y: 1, M: 1, D: 1)
  #expect(jdn == 1724221)
  let (y, m, d) = EthiopianCalendar.toDate(J: 1724221)
  #expect(y == 1)
  #expect(m == 1)
  #expect(d == 1)
}

@Test func testJulianDayNames() async throws {
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 1, day: 1) == "Kal. Jan")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 1, day: 31) == "Prid. Kal. Feb")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 2, day: 1) == "Kal. Feb")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 2, day: 29) == "Prid. Kal. Mar")
  #expect(JulianCalendar.nameOfDay(year: 2001, month: 2, day: 28) == "Prid. Kal. Mar")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 3, day: 1) == "Kal. Mar")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 3, day: 31) == "Prid. Kal. Apr")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 4, day: 1) == "Kal. Apr")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 4, day: 30) == "Prid. Kal. May")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 5, day: 1) == "Kal. May")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 5, day: 31) == "Prid. Kal. Jun")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 6, day: 1) == "Kal. Jun")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 6, day: 30) == "Prid. Kal. Jul")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 7, day: 1) == "Kal. Jul")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 7, day: 31) == "Prid. Kal. Aug")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 8, day: 1) == "Kal. Aug")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 8, day: 31) == "Prid. Kal. Sep")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 9, day: 1) == "Kal. Sep")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 9, day: 30) == "Prid. Kal. Oct")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 10, day: 1) == "Kal. Oct")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 10, day: 31) == "Prid. Kal. Nov")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 11, day: 1) == "Kal. Nov")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 11, day: 30) == "Prid. Kal. Dec")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 12, day: 1) == "Kal. Dec")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 12, day: 31) == "Prid. Kal. Jan")

  // Kal switch over
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 1, day: 13) == "Idus Jan")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 1, day: 14) == "XIX Kal. Feb")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 2, day: 13) == "Idus Feb")
  // XVII Kal, but we name the leap day bis, unclear what should be standard here
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 2, day: 14) == "XVI Kal. Mar")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 3, day: 15) == "Idus Mar")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 3, day: 16) == "XVII Kal. Apr")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 4, day: 13) == "Idus Apr")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 4, day: 14) == "XVIII Kal. May")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 5, day: 15) == "Idus May")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 5, day: 16) == "XVII Kal. Jun")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 6, day: 13) == "Idus Jun")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 6, day: 14) == "XVIII Kal. Jul")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 7, day: 15) == "Idus Jul")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 7, day: 16) == "XVII Kal. Aug")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 8, day: 13) == "Idus Aug")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 8, day: 14) == "XIX Kal. Sep")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 9, day: 13) == "Idus Sep")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 9, day: 14) == "XVIII Kal. Oct")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 10, day: 15) == "Idus Oct")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 10, day: 16) == "XVII Kal. Nov")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 11, day: 13) == "Idus Nov")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 11, day: 14) == "XVIII Kal. Dec")

  #expect(JulianCalendar.nameOfDay(year: 2000, month: 12, day: 13) == "Idus Dec")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 12, day: 14) == "XIX Kal. Jan")

  // Leap days
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 2, day: 24) == "Bis. VI Kal. Mar")
  #expect(JulianCalendar.nameOfDay(year: 2000, month: 2, day: 25) == "VI Kal. Mar")
  #expect(JulianCalendar.nameOfDay(year: 2001, month: 2, day: 24) == "VI Kal. Mar")
}
