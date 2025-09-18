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

// Jan aug dec
fileprivate let dayNamesJAD = [
  "Kal.",
  "IV Non.", "III Non.", "Prid. Non.", "Non.",
  "VIII Id.", "VII Id.", "VI Id.", "V Id.", "IV Id.", "III Id.", "Pred. Id.", "Idus",
  "XIX Kal.", "XVIII Kal.", "XVII Kal.", "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]

fileprivate let dayNamesJADKalIndex = 14

fileprivate let dayNamesFebLeap = [
  "Kal.",
  "IV Non.", "III Non.", "Prid. Non.", "Non.",
  "VIII Id.", "VII Id.", "VI Id.", "V Id.", "IV Id.", "III Id.", "Pred. Id.", "Idus",
  "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "Bis. VI Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]

fileprivate let dayNamesFeb = [
  "Kal.",
  "IV Non.", "III Non.", "Prid. Non.", "Non.",
  "VIII Id.", "VII Id.", "VI Id.", "V Id.", "IV Id.", "III Id.", "Pred. Id.", "Idus",
  "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]

fileprivate let dayNamesFebKalIndex = 14

// Mar, may, jul, oct
fileprivate let dayNamesMMJO = [
  "Kal.",
  "VI Non.", "V Non.", "IV Non.", "III Non.", "Prid. Non.", "Non.",
  "VIII Id.", "VII Id.", "VI Id.", "V Id.", "IV Id.", "III Id.", "Pred. Idus", "Idus",
  "XVII Kal.", "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]

fileprivate let dayNamesMMJOKalIndex = 16

// April, june, sept, nov
fileprivate let dayNamesAJSN = [
  "Kal.",
  "IV Non.", "III Non.", "Prid. Non.", "Nonae",
  "VIII Id.", "VII Id.", "VI Id.", "V Id.", "IV Id.", "III Id.", "Pred. Id.", "Idus",
  "XVIII Kal.", "XVII Kal.", "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]
fileprivate let dayNamesAJSNKalIndex = 14

fileprivate let dayNames = [
  dayNamesJAD, dayNamesFeb, dayNamesMMJO,
  dayNamesAJSN, dayNamesMMJO, dayNamesAJSN,
  dayNamesMMJO, dayNamesJAD, dayNamesAJSN,
  dayNamesMMJO, dayNamesAJSN, dayNamesJAD
]
fileprivate let dayNamesLeap = [
  dayNamesJAD, dayNamesFebLeap, dayNamesMMJO,
  dayNamesAJSN, dayNamesMMJO, dayNamesAJSN,
  dayNamesMMJO, dayNamesJAD, dayNamesAJSN,
  dayNamesMMJO, dayNamesAJSN, dayNamesJAD
]
fileprivate let kalIndexOffset = [
  dayNamesJADKalIndex, dayNamesFebKalIndex, dayNamesMMJOKalIndex,
  dayNamesAJSNKalIndex, dayNamesMMJOKalIndex, dayNamesAJSNKalIndex,
  dayNamesMMJOKalIndex, dayNamesJADKalIndex, dayNamesAJSNKalIndex,
  dayNamesMMJOKalIndex, dayNamesAJSNKalIndex, dayNamesJADKalIndex
]


public struct JulianCalendar : CalendarProtocol, Sendable {
  static let months: [MonthSpec] = [
    MonthSpec(
      monthUID: "julian:M01",
      intercalary: false,
      intercalaryRuleRef: nil,
      names: [
        MonthNameRecord(
          nameType: .seasonalNumeric,
          priority: 80,
          variants: [
            "en": "January"
          ],
          sources: nil
        )
      ]
    ),

    MonthSpec(
      monthUID: "julian:M02",
      intercalary: false,
      intercalaryRuleRef: nil,
      names: [
        MonthNameRecord(
          nameType: .seasonalNumeric,
          priority: 80,
          variants: [
            "en": "February"
          ],
          sources: nil
        )
      ]
    ),
    MonthSpec(
      monthUID: "julian:M03",
      intercalary: false,
      intercalaryRuleRef: nil,
      names: [
        MonthNameRecord(
          nameType: .seasonalNumeric,
          priority: 80,
          variants: [
            "en": "March"
          ],
          sources: nil
        )
      ]
    ),
    MonthSpec(
      monthUID: "julian:M04",
      intercalary: false,
      intercalaryRuleRef: nil,
      names: [
        MonthNameRecord(
          nameType: .seasonalNumeric,
          priority: 80,
          variants: [
            "en": "April"
          ],
          sources: nil
        )
      ]
    ),
    MonthSpec(
      monthUID: "julian:M05",
      intercalary: false,
      intercalaryRuleRef: nil,
      names: [
        MonthNameRecord(
          nameType: .seasonalNumeric,
          priority: 80,
          variants: [
            "en": "May"
          ],
          sources: nil
        )
      ]
    ),
    MonthSpec(
      monthUID: "julian:M06",
      intercalary: false,
      intercalaryRuleRef: nil,
      names: [
        MonthNameRecord(
          nameType: .seasonalNumeric,
          priority: 80,
          variants: [
            "en": "June"
          ],
          sources: nil
        )
      ]
    ),
    MonthSpec(
      monthUID: "julian:M07",
      intercalary: false,
      intercalaryRuleRef: nil,
      names: [
        MonthNameRecord(
          nameType: .seasonalNumeric,
          priority: 80,
          variants: [
            "en": "July"
          ],
          sources: nil
        )
      ]
    ),
    MonthSpec(
      monthUID: "julian:M08",
      intercalary: false,
      intercalaryRuleRef: nil,
      names: [
        MonthNameRecord(
          nameType: .seasonalNumeric,
          priority: 80,
          variants: [
            "en": "August"
          ],
          sources: nil
        )
      ]
    ),
    MonthSpec(
      monthUID: "julian:M09",
      intercalary: false,
      intercalaryRuleRef: nil,
      names: [
        MonthNameRecord(
          nameType: .seasonalNumeric,
          priority: 80,
          variants: [
            "en": "September"
          ],
          sources: nil
        )
      ]
    ),
    MonthSpec(
      monthUID: "julian:M10",
      intercalary: false,
      intercalaryRuleRef: nil,
      names: [
        MonthNameRecord(
          nameType: .seasonalNumeric,
          priority: 80,
          variants: [
            "en": "October"
          ],
          sources: nil
        )
      ]
    ),
    MonthSpec(
      monthUID: "julian:M11",
      intercalary: false,
      intercalaryRuleRef: nil,
      names: [
        MonthNameRecord(
          nameType: .seasonalNumeric,
          priority: 80,
          variants: [
            "en": "November"
          ],
          sources: nil
        )
      ]
    ),
    MonthSpec(
      monthUID: "julian:M12",
      intercalary: false,
      intercalaryRuleRef: nil,
      names: [
        MonthNameRecord(
          nameType: .seasonalNumeric,
          priority: 80,
          variants: [
            "en": "December"
          ],
          sources: nil
        )
      ]
    ),
  ]

  public var identifier: CalendarId { .julian }
  public var calendarKey: String { "julian" }
  public func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth]
  {
    var result: [ResolvedMonth] = []

    for (i, month) in zip(1 ... 12, Self.months) {
      result.append(ResolvedMonth(spec: month, index: i, mode: mode, firstDay: 1,
                                  length: daysInMonth(year: year, month: i),
                                  leapDayNumber: nil))
    }

    return result
  }

  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    JulianCalendar.isValidDate(Y: year, M: month, D: day)
  }

  public func monthName(forYear year: Int, month: Int) -> String {
    return JulianCalendar.nameOfMonth(month)
  }

  public func daysInMonth(year: Int, month: Int) -> Int {
    JulianCalendar.daysInMonth(year: year, month: month)
  }

  public func isProleptic(julianDay jdn: Int) -> Bool {
    JulianCalendar.isProleptic(jdn)
  }

  public func monthNumber(for month: String, in year: Int) -> Int? {
    JulianCalendar.numberOfMonth(month)
  }

  public func jdn(forYear year: Int, month: Int, day: Int) -> Int {
    JulianCalendar.toJDN(Y: year, M: month, D: day)
  }

  public func date(fromJDN jdn: Int) -> CalendarDateComponents? {
    let (y, m, d) = JulianCalendar.toDate(J: jdn)
    return CalendarDateComponents(calendar: .julian,
                                  yearMode: .civil, year: y, month: m, day: d)
  }


  static let shared = JulianCalendar()
  // Corresponds to 0008-01-01 Julian calendar
  //   Before CE 8, leap years were erratic and even if the calendar
  //   was technically introduced in BCE 46, inconsistent use of leap years
  //   makes the calendar only accurate for dating from CE 8 (or possibly
  //   a few years earlier)
  static let epoch = 1723980

  // Calculate the Roman name of the day
  static public func nameOfDay(year: Int, month: Int, day: Int) -> String {
    let prefix =
    if isLeapYear(year: year) {
      dayNamesLeap[month-1][day - 1]
    } else {
      dayNames[month-1][day - 1]
    }

    if day >= kalIndexOffset[month-1] {
      // We need to add 1 to the month index
      let nextMonth = month == 12 ? 1 : (month + 1)
      return "\(prefix) \(nameAbbrOfMonth(nextMonth))"
    } else {
      return "\(prefix) \(nameAbbrOfMonth(month))"
    }
  }

  static public func isLeapYear(year: Int) -> Bool {
    year % 4 == 0
  }
  static public func daysInMonth(year: Int, month: Int) -> Int {
    let normalMonthLength = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if month == 2 {
      if isLeapYear(year: year) {
        return 29
      }
    }

    return normalMonthLength[month - 1]
  }


  static public func isValidDate(Y: Int, M: Int, D: Int) -> Bool {
    if M < 1 || 12 < M {
      return false
    }
    if D < 1 || daysInMonth(year: Y, month: M) < D {
      return false
    }
    return true
  }

  static public func isProleptic(_ d: Int) -> Bool {
    return d < epoch
  }

  static public func numberOfMonth(_ month: String) -> Int? {
    let monthDictionary = ["january": 1, "february": 2, "march": 3,
                           "april": 4, "may": 5, "june": 6,
                           "july": 7, "august": 8, "september": 9,
                           "october": 10, "november": 11, "december": 12]
    return monthDictionary[month.lowercased()]
  }

  static public func nameOfMonth(_ month: Int) -> String {
    let monthNames = ["January", "February", "March",
                      "April", "May", "June",
                      "July", "August", "September",
                      "October", "November", "December"]
    return monthNames[month-1]
  }
  static public func nameAbbrOfMonth(_ month: Int) -> String {
    let monthNames = ["Jan", "Feb", "Mar",
                      "Apr", "May", "Jun",
                      "Jul", "Aug", "Sep",
                      "Oct", "Nov", "Dec"]
    return monthNames[month-1]
  }


  static let algorithm = CalendarAlgorithm(y: 4716, j: 1401, m: 2, n: 12, r: 4, p: 1461, q: 0, v: 3, u: 5, s: 153, t: 2, w: 2)

  static public func toJDN(Y: Int, M: Int, D: Int) -> Int {
    JulianCalendar.algorithm.toJd(Y: Y, M: M, D: D)
  }
  static public func toDate(J: Int) -> (Int, Int, Int) {
    JulianCalendar.algorithm.toDate(J: J)
  }

  static public func dayOfWeek(Y: Int, M: Int, D: Int) -> Int {
    let J = toJDN(Y: Y, M: M, D: D)
    let W = 1 + (J + 1) % 7
    return W
  }

  static public func dayOfEaster(Y: Int) -> (Int, Int, Int) {
    let a = 22 + (255 - 11 * (Y % 19)) % 30
    let g = a + (56 + 6 * Y - Y / 4 - a) % 7
    let M = 3 + g / 32
    let D = 1 + (g - 1) % 31
    return (Y, M, D)
  }
}

