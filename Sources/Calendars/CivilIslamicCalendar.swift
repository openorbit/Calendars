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

fileprivate let islamicMonths: [MonthSpec] = [
  MonthSpec(
    monthUID: "islamic:muharram",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Muharram"
        ],
        sources: nil
      )
    ]
  ),

  MonthSpec(
    monthUID: "islamic:safar",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Safar"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "islamic:rabi_i",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Rabi' I"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "islamic:rabi_ii",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Rabi' II"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "islamic:jumada_i",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Jumada I"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "islamic:jumada_ii",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Jumada II"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "islamic:rajab",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Rajab"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "islamic:shaabán",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Shaabán"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "islamic:ramadan",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Ramadân"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "islamic:shawwál",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Shawwál"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "islamic:dhú_l_Qa_da",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Dhú'l-Qa'da"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "islamic:l_hijjab",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "'l-Hijjab"
        ],
        sources: nil
      )
    ]
  ),
]



public struct CivilIslamicCalendar : CalendarProtocol {
  public var identifier: CalendarId { .civilIslamic }
  public var calendarKey: String { "civil_islamic" }
  public func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth]
  {
    var result: [ResolvedMonth] = []
    for (i, month) in zip(1 ... islamicMonths.count, islamicMonths) {
      result.append(ResolvedMonth(spec: month, index: i, mode: mode, firstDay: 1,
                                  length: daysInMonth(year: year, month: i)))
    }

    return result
  }

  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    CivilIslamicCalendar.isValidDate(Y: year, M: month, D: day)
  }

  public func monthName(forYear year: Int, month: Int) -> String {
    return CivilIslamicCalendar.nameOfMonth(month)
  }

  public func daysInMonth(year: Int, month: Int) -> Int {
    CivilIslamicCalendar.daysInMonth(year: year, month: month)
  }

  public func isProleptic(julianDay jdn: Int) -> Bool {
    CivilIslamicCalendar.isProleptic(jdn)
  }

  public func monthNumber(for month: String, in year: Int) -> Int? {
    CivilIslamicCalendar.numberOfMonth(month)
  }

  public func jdn(forYear year: Int, month: Int, day: Int) -> Int {
    CivilIslamicCalendar.toJDN(Y: year, M: month, D: day)
  }

  public func date(fromJDN jdn: Int) -> CalendarDateComponents? {
    let (y, m, d) = CivilIslamicCalendar.toDate(J: jdn)

    return CalendarDateComponents(calendar: CalendarInfo(id: .civilIslamic, engine: self),
                                  yearMode: .civil, year: y, month: m, day: d)
  }



  static let epoch = 1948440
  static let shared = CivilIslamicCalendar()

  public static func isLeapYear(year: Int) -> Bool {
    let yearInCycle = (year - 1) % 30 + 1
    return [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29].contains(yearInCycle)
  }
  public static func daysInMonth(year: Int, month: Int) -> Int {
    let normalMonthLength = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29]
    if month == 12 {
      if isLeapYear(year: year) {
        return 30
      }
    }

    return normalMonthLength[month - 1]
  }
  public static func isProleptic(_ d: Int) -> Bool {
    return d < epoch
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

  public static func nameOfMonth(_ month: Int) -> String {
    let monthNames = ["Muharram", "Safar", "Rabi' I",
                      "Rabi' II", "Jumada I", "Jumada II",
                      "Rajab", "Shaabán", "Ramadân",
                      "Shawwál", "Dhú'l-Qa'da", "Dhú'l-Hijjab"]
    return monthNames[month-1]
  }
  public static func numberOfMonth(_ month: String) -> Int? {
    let monthDictionary = ["muharram": 1, "safar": 2, "rabi' I": 3,
                           "rabi' II": 4, "jumada I": 5, "jumada II": 6,
                           "rajab": 7, "shaabán": 8, "ramadân": 9,
                           "shawwál": 10, "dhú'l-qa'da": 11, "dhú'l-hijjab": 12]
    return monthDictionary[month.lowercased()]
  }


  static let algorithm = CalendarAlgorithm(y: 5519, j: 7664, m: 0, n: 12, r: 30, p: 10631, q: 14, v: 15, u: 100, s: 2951, t: 51, w: 10)

  static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    algorithm.toJd(Y: Y, M: M, D: D)
  }
  static func toDate(J: Int) -> (Int, Int, Int) {
    algorithm.toDate(J: J)
  }

}

