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

fileprivate let ethiopianMonths: [MonthSpec] = [
  MonthSpec(
    monthUID: "ethiopian:M01",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Meskerem"
        ],
        sources: nil
      )
    ]
  ),

  MonthSpec(
    monthUID: "ethiopian:M02",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Tikimt"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "ethiopian:M03",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Hidar"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "ethiopian:M04",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Tahsas"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "ethiopian:M05",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Tir"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "ethiopian:M06",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Yekatit"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "ethiopian:M07",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Megabit"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "ethiopian:M08",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Miyazya"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "ethiopian:M09",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Ginbot"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "ethiopian:M10",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Sene"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "ethiopian:M11",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Hamle"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "ethiopian:M12",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Nehase"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "ethiopian:M13",
    intercalary: true,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: ["en": "Pagume"],
        sources: nil
      )
    ]
  ),
]

public struct EthiopianCalendar : CalendarProtocol {
  public var identifier: CalendarId { .ethiopian }
  public var calendarKey: String { "ethiopian" }
  public func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth]
  {
    var result: [ResolvedMonth] = []

    for (i, month) in zip(1 ... ethiopianMonths.count, ethiopianMonths) {
      let length = daysInMonth(year: year, month: i)
      result.append(ResolvedMonth(spec: month, index: i, mode: mode, firstDay: 1,
                                  length: length,
                                  leapDayNumber: i == 13 && length == 6 ? 6 : nil))
    }

    return result
  }

  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    EthiopianCalendar.isValidDate(Y: year, M: month, D: day)
  }

  public func monthName(forYear year: Int, month: Int) -> String {
    return EthiopianCalendar.nameOfMonth(month)!
  }

  public func daysInMonth(year: Int, month: Int) -> Int {
    EthiopianCalendar.daysInMonth(year: year, month: month)
  }

  public func isProleptic(julianDay jdn: Int) -> Bool {
    EthiopianCalendar.isProleptic(jdn)
  }

  public func monthNumber(for month: String, in year: Int) -> Int? {
    EthiopianCalendar.numberOfMonth(month)
  }

  public func jdn(forYear year: Int, month: Int, day: Int) -> Int {
    EthiopianCalendar.toJDN(Y: year, M: month, D: day)
  }

  public func date(fromJDN jdn: Int) -> CalendarDateComponents? {
    let (y, m, d) = EthiopianCalendar.toDate(J: jdn)
    return CalendarDateComponents(calendar: .ethiopian,
                                  yearMode: .civil, year: y, month: m, day: d)

  }


  public static let epoch = 1724221
  public static let shared = EthiopianCalendar()

  public static func isProleptic(_ d: Int) -> Bool {
    return d < epoch
  }

  public static func daysInMonth(year: Int, month: Int) -> Int {
    guard (1...13).contains(month) else { return 0 }
    if month <= 12 { return 30 }
    return toJDN(Y: year + 1, M: 1, D: 1) - toJDN(Y: year, M: 13, D: 1)
  }
  public static func numberOfMonth(_ month: String) -> Int? {
    let monthDictionary = ["meskerem": 1, "tikimt": 2, "hidar": 3,
                           "tahsas": 4, "tir": 5, "yekatit": 6,
                           "megabit": 7, "miyazya": 8, "ginbot": 9,
                           "sene": 10, "hamle": 11, "nehase": 12,
                           "pagume": 13]
    return monthDictionary[month.lowercased()]
  }

  public static func nameOfMonth(_ month: Int) -> String? {
    let monthNames = ["Meskerem", "Tikimt", "Hidar", "Tahsas", "Tir", "Yekatit",
                      "Megabit", "Miyazya", "Ginbot", "Sene", "Hamle", "Nehase", "Pagume"]
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

  static let algorithm = CalendarAlgorithm(y: 4720, j: 124, m: 0, n: 13, r: 4, p: 1461, q: 0, v: 3, u: 1, s: 30, t: 0, w: 0)

  static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    algorithm.toJd(Y: Y, M: M, D: D)
  }
  static func toDate(J: Int) -> (Int, Int, Int) {
    algorithm.toDate(J: J)
  }

}

