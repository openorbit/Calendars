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


fileprivate let bahaiMonths: [MonthSpec] = [
  MonthSpec(
    monthUID: "bahai:M01",
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
    monthUID: "bahai:M02",
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
    monthUID: "bahai:M03",
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
    monthUID: "bahai:M04",
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
    monthUID: "bahai:M05",
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
    monthUID: "bahai:M06",
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
    monthUID: "bahai:M07",
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
    monthUID: "bahai:M08",
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
    monthUID: "bahai:M09",
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
    monthUID: "bahai:M10",
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
    monthUID: "bahai:M11",
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
    monthUID: "bahai:M12",
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


public struct BahaiCalendar : CalendarProtocol {
  public var identifier: CalendarId { .bahai }
  public var calendarKey: String { "bahai" }

  public func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth]
  {
    var result: [ResolvedMonth] = []

    for (i, month) in zip(1 ... 12, bahaiMonths) {
      result.append(ResolvedMonth(spec: month, index: i, mode: mode, firstDay: 1,
                                  length: daysInMonth(year: year, month: i),
                                  leapDayNumber: nil))
    }

    return result
  }


  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    BahaiCalendar.isValidDate(Y: year, M: month, D: day)
  }

  public func monthName(forYear year: Int, month: Int) -> String {
    precondition(1 <= month && month <= 12)
    return BahaiCalendar.nameOfMonth(month)!
  }

  public func daysInMonth(year: Int, month: Int) -> Int {
    BahaiCalendar.daysInMonth(year: year, month: month)
  }

  public func isProleptic(julianDay jdn: Int) -> Bool {
    BahaiCalendar.isProleptic(jdn)
  }

  public func monthNumber(for month: String, in year: Int) -> Int? {
    BahaiCalendar.numberOfMonth(month)
  }

  public func jdn(forYear year: Int, month: Int, day: Int) -> Int {
    BahaiCalendar.toJDN(Y: year, M: month, D: day)
  }

  public func date(fromJDN jdn: Int) -> CalendarDateComponents? {
    let (y, m, d) = BahaiCalendar.toDate(J: jdn)

    return CalendarDateComponents(calendar: .bahai,
                                  yearMode: .civil, year: y, month: m, day: d)
  }


  
  static let epoch = 2394647
  static let shared = BahaiCalendar()

  public static func isProleptic(_ d: Int) -> Bool {
    return d < epoch
  }

  public static func daysInMonth(year: Int, month: Int) -> Int {
    let normalMonthLength = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    return normalMonthLength[month - 1]
  }
  public static func numberOfMonth(_ month: String) -> Int? {
    let monthDictionary = ["january": 1, "february": 2, "march": 3,
                           "april": 4, "may": 5, "june": 6,
                           "july": 7, "august": 8, "september": 9,
                           "october": 10, "november": 11, "december": 12]
    return monthDictionary[month.lowercased()]
  }
  
  public static func nameOfMonth(_ month: Int) -> String? {
    let monthNames = ["january", "february", "march",
                      "april", "may", "june",
                      "july", "august", "september",
                      "october", "november", "december"]
    return monthNames[month-1]
  }

  public static func isValidDate(Y: Int, M: Int, D: Int) -> Bool {
    if M < 1 || 12 < M {
      return false
    }
    if D < 1 || daysInMonth(year: Y, month: M) < D {
      return false
    }
    return true
  }

  static let algorithm = GregorianStyleCalendarAlgorithm(y: 6560, j: 1412, m: 19, n: 20, r: 4, p: 1461, q: 0, v: 3, u: 1, s: 19, t: 0, w: 0, A: 184, B: 274273, C: -50)

  static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    algorithm.toJd(Y: Y, M: M, D: D)
  }
  static func toDate(J: Int) -> (Int, Int, Int) {
    algorithm.toDate(J: J)
  }

}

