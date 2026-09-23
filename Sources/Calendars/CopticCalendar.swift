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

fileprivate let copticMonths: [MonthSpec] = [
  MonthSpec(
    monthUID: "coptic:M01",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Thout"
        ],
        sources: nil
      )
    ]
  ),

  MonthSpec(
    monthUID: "coptic:M02",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Paopi"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "coptic:M03",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Hathor"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "coptic:M04",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Koiak"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "coptic:M05",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Tobi"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "coptic:M06",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Meshir"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "coptic:M07",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Paremhat"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "coptic:M08",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Paremoude"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "coptic:M09",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Pashons"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "coptic:M10",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Paoni"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "coptic:M11",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Epip"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "coptic:M12",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Mesori"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "coptic:M13",
    intercalary: true,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: ["en": "Pi Kogi Enavot"],
        sources: nil
      )
    ]
  ),
]


public struct CopticCalendar : CalendarProtocol {
  public var identifier: CalendarId { .coptic }
  public var calendarKey: String { "coptic" }
  public func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth]
  {
    var result: [ResolvedMonth] = []

    for (i, month) in zip(1 ... copticMonths.count, copticMonths) {
      let length = daysInMonth(year: year, month: i)
      result.append(ResolvedMonth(spec: month, index: i, mode: mode, firstDay: 1,
                                  length: length,
                                  leapDayNumber: i == 13 && length == 6 ? 6 : nil))
    }

    return result
  }

  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    CopticCalendar.isValidDate(Y: year, M: month, D: day)
  }

  public func monthName(forYear year: Int, month: Int) -> String {
    return CopticCalendar.nameOfMonth(month)!
  }

  public func daysInMonth(year: Int, month: Int) -> Int {
    CopticCalendar.daysInMonth(year: year, month: month)
  }

  public func isProleptic(julianDay jdn: Int) -> Bool {
    CopticCalendar.isProleptic(jdn)
  }

  public func monthNumber(for month: String, in year: Int) -> Int? {
    CopticCalendar.numberOfMonth(month)
  }

  public func jdn(forYear year: Int, month: Int, day: Int) -> Int {
    CopticCalendar.toJDN(Y: year, M: month, D: day)
  }

  public func date(fromJDN jdn: Int) -> CalendarDateComponents? {
    let (y, m, d) = CopticCalendar.toDate(J: jdn)
    return CalendarDateComponents(calendar: .coptic,
                                  yearMode: .civil, year: y, month: m, day: d)

  }



  public static let epoch = 1825030
  public static let shared = CopticCalendar()

  public static func isProleptic(_ d: Int) -> Bool {
    return d < epoch
  }

  public static func daysInMonth(year: Int, month: Int) -> Int {
    guard (1...13).contains(month) else { return 0 }
    if month <= 12 { return 30 }
    return toJDN(Y: year + 1, M: 1, D: 1) - toJDN(Y: year, M: 13, D: 1)
  }
  public static func numberOfMonth(_ month: String) -> Int? {
    let monthDictionary = ["thout": 1, "paopi": 2, "hathor": 3,
                           "koiak": 4, "tobi": 5, "meshir": 6,
                           "paremhat": 7, "paremoude": 8, "pashons": 9,
                           "paoni": 10, "epip": 11, "mesori": 12,
                           "pi kogi enavot": 13]
    return monthDictionary[month.lowercased()]
  }

  public static func nameOfMonth(_ month: Int) -> String? {
    let monthNames = ["Thout", "Paopi", "Hathor", "Koiak", "Tobi", "Meshir",
                      "Paremhat", "Paremoude", "Pashons", "Paoni", "Epip", "Mesori",
                      "Pi Kogi Enavot"]
    guard monthNames.indices.contains(month - 1) else { return nil }
    return monthNames[month - 1]
  }

  public static func isValidDate(Y: Int, M: Int, D: Int) -> Bool {
    if M < 1 || 13 < M {
      return false
    }
    if D < 1 || daysInMonth(year: Y, month: M) < D {
      return false
    }
    return true
  }

  static let algorithm = CalendarAlgorithm(y: 4996, j: 124, m: 0, n: 13, r: 4, p: 1461, q: 0, v: 3, u: 1, s: 30, t: 0, w: 0)

  static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    algorithm.toJd(Y: Y, M: M, D: D)
  }
  static func toDate(J: Int) -> (Int, Int, Int) {
    algorithm.toDate(J: J)
  }

}

