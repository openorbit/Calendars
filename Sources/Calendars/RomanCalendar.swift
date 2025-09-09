//
// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2024 Mattias Holm
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

public enum RomanMonth: UInt8, Sendable, Equatable {
  case IAN
  case FEB
  case INT
  case MAR
  case APR
  case MAI
  case IUN
  case QUI
  case SEX
  case SEP
  case OCT
  case NOV
  case INT_I
  case INT_II
  case DEC

  var slot: Int {
    Int(self.rawValue)
  }
  public static func < (lhs: RomanMonth, rhs: RomanMonth) -> Bool {
    lhs.slot < rhs.slot
  }

}

public struct RomanDay : Sendable, Hashable, Equatable, Comparable {
  public let month: RomanMonth
  public let day: Int  // 1..31 (Kalends=1, Nones=5/7, Ides=13/15 if you ever want those names)

  // Lexicographic ordering: first by month slot, then by day.
  public static func < (lhs: RomanDay, rhs: RomanDay) -> Bool {
    if lhs.month.slot != rhs.month.slot {
      return lhs.month.slot < rhs.month.slot
    }
    return lhs.day < rhs.day
  }
}

public struct RomanDate : Sendable, Hashable, Equatable, Comparable {
  public let year: Int
  public let month: RomanMonth
  public let day: Int  // 1..31 (Kalends=1, Nones=5/7, Ides=13/15 if you ever want those names)

  public var jdn: Int {
    get {
      RomanCalendar.shared.jdn(forYear: year, month: month.slot, day: day)
    }
  }
  // Total order: year, then month slot, then day.
  public static func < (lhs: RomanDate, rhs: RomanDate) -> Bool {
    lhs.jdn < rhs.jdn
  }
}


public struct RomanMonthInfo : Sendable {
  public let month: RomanMonth
  public let julian: JulianDate
  public let days: Int
  public let notes: [String] = []
}

public struct RomanYear : Sendable {
  public let auc: Int
  public let consularYearStart: RomanDay  // <-- day-aware

  public let months: InlineArray<15, RomanMonthInfo?>
  public let days: Int
  public let nundialPhase: Character
  public let nundialPhaseAfterIntercalation: Character?

  public let notes: [String]
}

public struct RomanForwardIndex : Sendable {


  // key = (AUC << 8) | month.rawValue
  private let years: [RomanYear]
  private let earliestDate: RomanDate
  private let lastDate: RomanDate
  public init(years: [RomanYear]) {
    self.years = years
    self.earliestDate = RomanDate(year: years[0].auc, month: .IAN, day: 1)
    self.lastDate = RomanDate(year: years.last!.auc, month: .DEC, day: 31)
  }

  /// Core lookup: (AUC, RomanMonth, day) -> JulianDate
  public func romanToJulian(auc: Int, month: RomanMonth, day: Int) -> JulianDate {
    precondition(auc >= earliestDate.year)
    precondition(auc <= lastDate.year)

    let romanDay = RomanDay(month: month, day: day)

    let romanYear =
    if years[auc -  earliestDate.year].consularYearStart != RomanDay(month: .IAN, day: 1) &&
        romanDay >= years[auc -  earliestDate.year].consularYearStart {
      // We need to look in the previous year
      years[auc -  earliestDate.year - 1]
    } else {
      years[auc -  earliestDate.year]
    }

    guard let month = romanYear.months[month.slot] else {
      // Invalid date
      fatalError("Invalid date")
    }
    let julianDate = month.julian + (day - 1)
    return julianDate
  }

  /// Convenience for your RomanDay
  public func romanToJulian(auc: Int, _ rd: RomanDay) -> JulianDate {
    romanToJulian(auc: auc, month: rd.month, day: rd.day)
  }
  public func romanToJulian(forDate date: RomanDate) -> JulianDate {
    romanToJulian(auc: date.year, month: date.month, day: date.day)
  }
}

public final class RomanCalendar : CalendarProtocol, WeekdayProtocol, Sendable {
  public static let shared: RomanCalendar = RomanCalendar()

  public var numberOfDays: Int { get {8} }

  public func weekday(forYear year: Int, month: Int, day: Int) -> Int {
    return 0
  }

  public func name(ofWeekday day: Int) -> String {
    return ""
  }

  static let forwardIndex: RomanForwardIndex = RomanForwardIndex(years: RomanYears_Bennett)

  public var calendarId: String { get { "roman_republican" } }

  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    false
  }
  public func monthName(forYear year: Int, month: Int) -> String {""}
  public func daysInMonth(year: Int, month: Int) -> Int {0}
  public func isProleptic(julianDay jdn: Int) -> Bool {false}
  public func monthNumber(for month: String, in year: Int) -> Int? {0}

  public func jdn(forYear year: Int, month: Int, day: Int) -> Int {
    let julian = self.julian(forRomanYear: year,
                             month: RomanMonth(rawValue: UInt8(month))!, day: day)
    return julian.jdn
  }
  public func date(fromJDN jdn: Int) -> (Int, Int, Int) {
    let julian = JulianDate(jdn: jdn)
    return (julian.year, julian.month, julian.day)
  }

  public func julian(forRomanYear year: Int, month: RomanMonth, day: Int) -> JulianDate {
    let result = RomanCalendar.forwardIndex.romanToJulian(auc: year, month: month, day: day)
    return result
  }

  public func roman(forJulianYear year: Int, month: Int, day: Int) -> RomanDate {
    //var jd = JulianDate(year: year, month: month, day: day)
    let rd = RomanDate(year: year, month: .IAN, day: 1)
    return rd
  }

}


fileprivate let dayNamesJAD = [
  "Kalendae",
  "IV Non.", "III Non.", "Prid. Non.", "Nonae",
  "VIII Id.", "VII Id.", "VI Id.", "V Id.", "IV Id.", "III Id.", "Pred. Id.", "Idus",
  "XIX Kal.", "XVIII Kal.", "XVII Kal.", "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]
fileprivate let dayNamesF = [
  "Kalendae",
  "IV Non.", "III Non.", "Prid. Non.", "Nonae",
  "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]
fileprivate let dayNamesMMJO = [
  "Kalendae",
  "VI Non.", "IV Non.", "III Non.", "Prid. Non.", "Nonae",
  "VIII Id.", "VII Id.", "VI Id.", "V Id.", "IV Id.", "III Id.", "Pred. Ides", "Ides",
  "XVII Kal.", "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]
fileprivate let dayNamesAJSN = [
  "Kalendae",
  "IV Non.", "III Non.", "Prid. Non.", "Nonae",
  "VIII Id.", "VII Id.", "VI Id.", "V Id.", "IV Id.", "III Id.", "Pred. Id.", "Idus",
  "XVIII Kal.", "XVII Kal.", "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]

