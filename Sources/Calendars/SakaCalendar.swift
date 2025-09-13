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

fileprivate let sakaMonths: [MonthSpec] = [
  MonthSpec(
    monthUID: "saka:M01",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Chaitra"
        ],
        sources: nil
      )
    ]
  ),

  MonthSpec(
    monthUID: "saka:M02",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Vaiśākha"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "saka:M03",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Jyēṣṭha"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "saka:M04",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Ashādha"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "saka:M05",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Srāvana"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "saka:M06",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Bhādra"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "saka:M07",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Aśvin"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "saka:M08",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Kārtika"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "saka:M09",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Mārgaśīrṣa"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "saka:M10",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Pauṣa"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "saka:M11",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Māgha"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "saka:M12",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Phālguna"
        ],
        sources: nil
      )
    ]
  ),
]

public struct SakaCalendar : CalendarProtocol {
  public var identifier: CalendarId { .saka }
  public var calendarKey: String { "saka" }
  public func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth]
  {
    var result: [ResolvedMonth] = []

    for (i, month) in zip(1 ... sakaMonths.count, sakaMonths) {
      result.append(ResolvedMonth(spec: month, index: i, mode: mode, firstDay: 1,
                                  length: daysInMonth(year: year, month: i),
                                  leapDayNumber: nil))
    }

    return result
  }

  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    SakaCalendar.isValidDate(Y: year, M: month, D: day)
  }

  public func monthName(forYear year: Int, month: Int) -> String {
    return SakaCalendar.nameOfMonth(month)
  }

  public func daysInMonth(year: Int, month: Int) -> Int {
    SakaCalendar.daysInMonth(year: year, month: month)
  }

  public func isProleptic(julianDay jdn: Int) -> Bool {
    SakaCalendar.isProleptic(jdn)
  }

  public func monthNumber(for month: String, in year: Int) -> Int? {
    SakaCalendar.numberOfMonth(month)
  }

  public func jdn(forYear year: Int, month: Int, day: Int) -> Int {
    SakaCalendar.toJDN(Y: year, M: month, D: day)
  }

  public func date(fromJDN jdn: Int) -> CalendarDateComponents? {
    let (y, m, d) = SakaCalendar.toDate(J: jdn)
    return CalendarDateComponents(calendar: CalendarInfo(id: .saka, engine: self),
                                  yearMode: .civil, year: y, month: m, day: d)
  }


  static let epoch = 1749995
  static let shared = SakaCalendar()

  public static func isLeapYear(year: Int) -> Bool {
    (year+78) % 400 == 0 || ((year+78) % 4 == 0 && (year+78) % 100 != 0)
  }
  public static func daysInMonth(year: Int, month: Int) -> Int {
    let normalMonthLength = [30, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 30]
    if month == 1 {
      if isLeapYear(year: year) {
        return 31
      }
    }

    return normalMonthLength[month - 1]
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
  public static func isProleptic(_ d: Int) -> Bool {
    return d < epoch
  }

  public static func numberOfMonth(_ month: String) -> Int? {
    let monthDictionary = ["chaitra": 1, "vaiśākha": 2, "jyēṣṭha": 3,
                           "ashādha": 4, "srāvana": 5, "bhādra": 6,
                           "aśvin": 7, "kārtika": 8, "mārgaśīrṣa": 9,
                           "pauṣa": 10, "māgha": 11, "phālguna": 12]
    return monthDictionary[month.lowercased()]
  }

  public static func nameOfMonth(_ month: Int) -> String {
    let monthNames = ["Chaitra", "Vaiśākha", "Jyēṣṭha",
                      "Āshādha", "Śrāvana", "Bhādra",
                      "Āśvin", "Kārtika", "Mārgaśīrṣa",
                      "Pauṣa", "Māgha", "Phālguna"]

    return monthNames[month-1]
  }

  static let algorithm = SakaCalendarAlgorithm(y: 4794, j: 1348, m: 1, n: 12, r: 4, p: 1461, q: 0, v: 3, u: 1, s: 31, t: 0, w: 0, A: 184, B: 274073, C: -36)

  static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    algorithm.toJd(Y: Y, M: M, D: D)
  }
  static func toDate(J: Int) -> (Int, Int, Int) {
    algorithm.toDate(J: J)
  }

}

