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

fileprivate let frenchMonths: [MonthSpec] = [
  MonthSpec(
    monthUID: "french_republican:M01",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Vendémiaire"
        ],
        sources: nil
      )
    ]
  ),

  MonthSpec(
    monthUID: "french_republican:M02",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Brumaire"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "french_republican:M03",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Frimaire"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "french_republican:M04",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Nivôse"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "french_republican:M05",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Pluviôse"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "french_republican:M06",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Ventôse"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "french_republican:M07",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Germinal"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "french_republican:M08",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Floréal"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "french_republican:M09",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Prairial"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "french_republican:M10",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Messidor"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "french_republican:M11",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Thermidor"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "french_republican:M12",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Fructidor"
        ],
        sources: nil
      )
    ]
  ),

]


public struct FrenchRepublicanCalendar : CalendarProtocol {


  public var identifier: CalendarId { .frenchRepublican }
  public var calendarKey: String { "french_republican" }


  public func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth]
  {
    var result: [ResolvedMonth] = []

    for (i, month) in zip(1 ... frenchMonths.count, frenchMonths) {
      result.append(ResolvedMonth(spec: month, index: i, mode: mode, firstDay: 1,
                                  length: daysInMonth(year: year, month: i),
                                  leapDayNumber: nil))
    }

    return result
  }

  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    FrenchRepublicanCalendar.isValidDate(Y: year, M: month, D: day)
  }

  public func monthName(forYear year: Int, month: Int) -> String {
    return FrenchRepublicanCalendar.nameOfMonth(month)
  }

  public func daysInMonth(year: Int, month: Int) -> Int {
    FrenchRepublicanCalendar.daysInMonth(year: year, month: month)
  }

  public func isProleptic(julianDay jdn: Int) -> Bool {
    FrenchRepublicanCalendar.isProleptic(jdn)
  }

  public func monthNumber(for month: String, in year: Int) -> Int? {
    FrenchRepublicanCalendar.numberOfMonth(month)
  }

  public func jdn(forYear year: Int, month: Int, day: Int) -> Int {
    FrenchRepublicanCalendar.toJDN(Y: year, M: month, D: day)
  }

  public func date(fromJDN jdn: Int) -> CalendarDateComponents? {
    let (y, m, d) = FrenchRepublicanCalendar.toDate(J: jdn)
    return CalendarDateComponents(calendar: CalendarInfo(id: .frenchRepublican, engine: self),
                                  yearMode: .civil, year: y, month: m, day: d)
  }

  static let epoch = 2375840
  static let shared = FrenchRepublicanCalendar()

  public static func nameOfMonth(_ month: Int) -> String {
    let monthNames = ["Vendémiaire", "Brumaire", "Frimaire",
                      "Nivôse", "Pluviôse", "Ventôse",
                      "Germinal", "Floréal", "Prairial",
                      "Messidor", "Thermidor", "Fructidor"]
    return monthNames[month-1]
  }
  public static func numberOfMonth(_ month: String) -> Int? {
    let monthDictionary = ["Vendémiaire": 1, "Brumaire": 2, "Frimaire": 3,
                           "Nivôse": 4, "Pluviôse": 5, "Ventôse": 6,
                           "Germinal": 7, "Floréal": 8, "Prairial": 9,
                           "Messidor": 10, "Thermidor": 11, "Fructidor": 12]
    return monthDictionary[month.lowercased()]
  }

  // TODO: Fixme
  public static func daysInMonth(year: Int, month: Int) -> Int {
    let normalMonthLength = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
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


  static let algorithm = GregorianStyleCalendarAlgorithm(y: 6504, j: 111, m: 0, n: 13, r: 4, p: 1461, q: 0, v: 3, u: 1, s: 30, t: 0, w: 0, A: 396, B: 578797, C: -51)

  public static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    algorithm.toJd(Y: Y, M: M, D: D)
  }
  public static func toDate(J: Int) -> (Int, Int, Int) {
    algorithm.toDate(J: J)
  }
}

