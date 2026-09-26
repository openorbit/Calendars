//
//  RomanCalendarTests.swift
//  Calendars
//
//  Created by Mattias Holm on 2025-09-08.
//
import Testing
@testable import Calendars

@Test
func testRomanFirstDateRoundtrip() async throws {
  // AUC 491 MAI = Julian -262-4-8
  #expect(
    RomanCalendar.shared.jdn(forYear:491, month: 1, day: 1)
    == JulianCalendar.shared.jdn(forYear: -262, month: 4, day: 8))


  let reverse = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -262, month: 4, day: 8))
  #expect(reverse!.year == 491)
  #expect(reverse!.month == 1)
  #expect(reverse!.day == 1)
}

@Test
func testRomanMayToIdesConsularYearBoundary() throws {
  let calendar = RomanCalendar.shared

  // AUC 531 still begins on Kal. Mai.; its final Martius begins on
  // Julian 9 March 222 BC.
  let auc531Start = try #require(calendar.startOfYearJDN(year: 531))
  #expect(auc531Start == calendar.jdn(forYear: 531, month: 1, day: 1))
  #expect(auc531Start == JulianCalendar.toJDN(Y: -222, M: 5, D: 18))

  let auc531MarchStart = calendar.jdn(forYear: 531, month: 11, day: 1)
  #expect(auc531MarchStart == JulianCalendar.toJDN(Y: -221, M: 3, D: 9))

  // AUC 532 begins on Id. Mart., fourteen elapsed days after Martius 1.
  let auc532Start = try #require(calendar.startOfYearJDN(year: 532))
  #expect(auc532Start - auc531MarchStart == 14)
  #expect(auc532Start == calendar.jdn(forYear: 532, month: 0, day: 1))
  #expect(auc532Start == JulianCalendar.toJDN(Y: -221, M: 3, D: 23))

  let lastDayOfAUC531 = try #require(calendar.date(fromJDN: auc532Start - 1))
  #expect(lastDayOfAUC531.year == 531)
  #expect(lastDayOfAUC531.month == 11)
  #expect(lastDayOfAUC531.day == 14)
}

@Test
func testRomanShortAUC600Boundary() throws {
  let calendar = RomanCalendar.shared

  // AUC 600 is the short transition year: Id. Mart. through prid. Kal. Ian.
  let auc600Start = try #require(calendar.startOfYearJDN(year: 600))
  #expect(auc600Start == calendar.jdn(forYear: 600, month: 0, day: 1))
  #expect(auc600Start == JulianCalendar.toJDN(Y: -153, M: 3, D: 5))

  let auc601Start = try #require(calendar.startOfYearJDN(year: 601))
  #expect(auc601Start == calendar.jdn(forYear: 601, month: 1, day: 1))
  #expect(auc601Start == JulianCalendar.toJDN(Y: -153, M: 12, D: 14))

  let lastDayOfAUC600 = try #require(calendar.date(fromJDN: auc601Start - 1))
  #expect(lastDayOfAUC600.year == 600)
  #expect(lastDayOfAUC600.month == 9)
  #expect(lastDayOfAUC600.day == 29)
}


@Test
func testRomanIdes15YearStartDate() async throws {
  // AUC 532 MAR 15 = 532-0-1 = Julian -221-3-23
  // AUC 532 APR 1 = Julian -221,4,9
  #expect(
    RomanCalendar.shared.jdn(forYear:532, month: 0, day: 1)
    == JulianCalendar.shared.jdn(forYear: -221, month: 3, day: 23))

  #expect(
    RomanCalendar.shared.jdn(forYear:532, month: 0, day: 17)
    == JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 8))

  #expect(
    RomanCalendar.shared.jdn(forYear:532, month: 1, day: 1)
    == JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 9))

  #expect(
    RomanCalendar.shared.jdn(forYear:532, month: 1, day: 15)
    == JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 23))


  #expect(
    RomanCalendar.shared.jdn(forYear:532, month: 13, day: 1)
    == JulianCalendar.shared.jdn(forYear: -220, month: 3, day: 21))

  #expect(
    RomanCalendar.shared.jdn(forYear:532, month: 13, day: 14)
    == JulianCalendar.shared.jdn(forYear: -220, month: 4, day: 3))
}


@Test
func testRomanIdes15YearStartDateReverse() async throws {
  let reverse = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 9))
  #expect(reverse!.year == 532)
  #expect(reverse!.month == 1)
  #expect(reverse!.day == 1)

  let a =
  RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -221, month: 3, day: 23))
  #expect(a!.year == 532)
  #expect(a!.month == 0)
  #expect(a!.day == 1)

  let b = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 8))
  #expect(b!.year == 532)
  #expect(b!.month == 0)
  #expect(b!.day == 17)

  let c = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 9))
  #expect(c!.year == 532)
  #expect(c!.month == 1)
  #expect(c!.day == 1)

  let d = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -221, month: 4, day: 23))
  #expect(d!.year == 532)
  #expect(d!.month == 1)
  #expect(d!.day == 15)

  let e = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -220, month: 3, day: 21))
  #expect(e!.year == 532)
  #expect(e!.month == 13)
  #expect(e!.day == 1)

  let f = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: -220, month: 4, day: 3))
  #expect(f!.year == 532)
  #expect(f!.month == 13)
  #expect(f!.day == 14)
}


@Test
func testRomanJulianAlignmentPostTables() async throws {

  let firstPostTabulatedDate
    = RomanCalendar.shared.date(fromJDN: JulianCalendar.shared.jdn(forYear: 61, month: 1, day: 1))
  #expect(firstPostTabulatedDate!.year == 814)
  #expect(firstPostTabulatedDate!.month == 1)
  #expect(firstPostTabulatedDate!.day == 1)

  
  let firstPostTabulatedJDN = RomanCalendar.shared.jdn(from: firstPostTabulatedDate!)
  #expect(firstPostTabulatedJDN == JulianCalendar.shared.jdn(forYear: 61, month: 1, day: 1))
}

@Test
func romanNundinalMarketLettersComeFromTheReconstructionTable() {
  let ordinary = RomanCalendar.shared.nundinalMarketLetters(forYear: 492)
  #expect(ordinary?.beforeIntercalation == .C)
  #expect(ordinary?.afterIntercalation == nil)
  #expect(ordinary?.conventionalBeforeIntercalation == .G)

  let intercalary = RomanCalendar.shared.nundinalMarketLetters(forYear: 493)
  #expect(intercalary?.beforeIntercalation == .H)
  #expect(intercalary?.afterIntercalation == .A)
  #expect(intercalary?.conventionalBeforeIntercalation == .B)
  #expect(intercalary?.conventionalAfterIntercalation == .A)

  // AUC 600 is the short year from Id. Mart. through December. Its dates are
  // on the January-aligned source row whose left AUC column is 599.
  let shortYear = RomanCalendar.shared.nundinalMarketLetters(forYear: 600)
  #expect(shortYear?.beforeIntercalation == .E)
  #expect(shortYear?.afterIntercalation == .F)

  let shortYearStart = RomanCalendar.shared.startOfYearJDN(year: 600)!
  #expect(RomanCalendar.shared.nundinalLetter(atJDN: shortYearStart) == .A)
  #expect(RomanCalendar.shared.nundinalLetter(atJDN: shortYearStart + 7) == .H)
  #expect(RomanCalendar.shared.nundinalLetter(atJDN: shortYearStart + 8) == .A)
  #expect(RomanCalendar.shared.isNundinalMarketDay(atJDN: shortYearStart + 5) == true)
  #expect(RomanCalendar.shared.isNundinalMarketDay(atJDN: shortYearStart + 4) == false)
}

@Test
func romanNundinalMarketLettersDoNotInventMissingAnchors() {
  #expect(RomanCalendar.shared.nundinalMarketLetters(forYear: 490) == nil)
  #expect(RomanCalendar.shared.nundinalMarketLetters(forYear: 491) == nil)
  #expect(RomanCalendar.shared.nundinalMarketLetters(forYear: 814) == nil)
}
