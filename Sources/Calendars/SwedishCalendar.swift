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
fileprivate let swedishMonths: [MonthSpec] = [
  MonthSpec(
    monthUID: "swedish:M01",
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
    monthUID: "swedish:M02",
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
    monthUID: "swedish:M03",
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
    monthUID: "swedish:M04",
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
    monthUID: "swedish:M05",
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
    monthUID: "swedish:M06",
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
    monthUID: "swedish:M07",
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
    monthUID: "swedish:M08",
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
    monthUID: "swedish:M09",
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
    monthUID: "swedish:M10",
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
    monthUID: "swedish:M11",
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
    monthUID: "swedish:M12",
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


public struct SwedishCalendar : CalendarProtocol {

  public var identifier: CalendarId { .swedish }
  public var calendarKey: String { "swedish_transitional" }
  public func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth]
  {
    var result: [ResolvedMonth] = []

    for (i, month) in zip(1 ... swedishMonths.count, swedishMonths) {
      result.append(ResolvedMonth(spec: month, index: i, mode: mode, firstDay: 1,
                                  length: daysInMonth(year: year, month: i),
                                  leapDayNumber: nil))
    }

    return result
  }

  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    SwedishCalendar.isValidDate(Y: year, M: month, D: day)
  }

  public func monthName(forYear year: Int, month: Int) -> String {
    return SwedishCalendar.nameOfMonth(month)
  }

  public func daysInMonth(year: Int, month: Int) -> Int {
    SwedishCalendar.daysInMonth(year: year, month: month)
  }

  public func isProleptic(julianDay jdn: Int) -> Bool {
    SwedishCalendar.isProleptic(jdn)
  }

  public func monthNumber(for month: String, in year: Int) -> Int? {
    SwedishCalendar.numberOfMonth(month)
  }

  public func jdn(forYear year: Int, month: Int, day: Int) -> Int {
    SwedishCalendar.toJDN(Y: year, M: month, D: day)
  }

  public func date(fromJDN jdn: Int) -> CalendarDateComponents? {
    let (y, m, d) = SwedishCalendar.toDate(J: jdn)
    return CalendarDateComponents(calendar: .swedish,
                                  yearMode: .civil, year: y, month: m, day: d)
  }

  public static let epoch = JulianCalendar.toJDN(Y: 1700, M: 2, D: 29)
  public static let endEpoch = GregorianCalendar.toJDN(Y: 1753, M: 3, D: 1) - 1
  public static let shared = SwedishCalendar()

  public static func isLeapYear(year: Int) -> Bool {
    year != 1700 && year % 4 == 0
  }
  public static func daysInMonth(year: Int, month: Int) -> Int {
    let normalMonthLength = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if month == 2 {
      if year == 1753 {
        return 17
      }
      if year == 1712 {
        return 30
      }

      if isLeapYear(year: year) {
        return 29
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
    if Y == 1753 && M == 2 && D > 17 {
      return false
    }
    return true
  }

  public static func isProleptic(_ d: Int) -> Bool {
    return d < epoch
  }

  public static func numberOfMonth(_ month: String) -> Int? {
    let monthDictionary = ["january": 1, "february": 2, "march": 3,
                           "april": 4, "may": 5, "june": 6,
                           "july": 7, "august": 8, "september": 9,
                           "october": 10, "november": 11, "december": 12]
    return monthDictionary[month.lowercased()]
  }

  public static func nameOfMonth(_ month: Int) -> String {
    let monthNames = ["January", "February", "March",
                      "April", "May", "June",
                      "July", "August", "September",
                      "October", "November", "December"]
    return monthNames[month-1]
  }

  public static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    if (Y, M, D) >= (1753, 3, 1) {
      return GregorianCalendar.toJDN(Y: Y, M: M, D: D)
    }
    if (Y, M, D) >= (1712, 3, 1) {
      return JulianCalendar.toJDN(Y: Y, M: M, D: D)
    }
    if Y == 1712 && M == 2 && D == 30 {
      return JulianCalendar.toJDN(Y: 1712, M: 2, D: 29)
    }
    if (Y, M, D) >= (1700, 3, 1) {
      return JulianCalendar.toJDN(Y: Y, M: M, D: D) - 1
    }
    return JulianCalendar.toJDN(Y: Y, M: M, D: D)
  }
  public static func toDate(J: Int) -> (Int, Int, Int) {
    let gregorianAdoptionJDN = GregorianCalendar.toJDN(Y: 1753, M: 3, D: 1)
    if gregorianAdoptionJDN <= J {
      return GregorianCalendar.toDate(J: J)
    }

    let julianResumptionJDN = JulianCalendar.toJDN(Y: 1712, M: 3, D: 1)
    if julianResumptionJDN <= J {
      return JulianCalendar.toDate(J: J)
    }
    if J == JulianCalendar.toJDN(Y: 1712, M: 2, D: 29) {
      return (1712, 2, 30)
    }
    if epoch <= J {
      return JulianCalendar.toDate(J: J + 1)
    }
    return JulianCalendar.toDate(J: J)
  }

  public static func dayOfWeek(Y: Int, M: Int, D: Int) -> Int {
    let J = toJDN(Y: Y, M: M, D: D)
    let W = 1 + (J + 1) % 7
    return W
  }
}
