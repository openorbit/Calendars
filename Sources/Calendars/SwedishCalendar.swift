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

public struct SwedishCalendar : CalendarProtocol {
  public var calendarId: String { "swedish_transitional" }

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

  public func date(fromJDN jdn: Int) -> (Int, Int, Int) {
    SwedishCalendar.toDate(J: jdn)
  }

  static let epoch = 2342042
  static let endEpoch = 2346425
  static let shared = SwedishCalendar()

  public static func isLeapYear(year: Int) -> Bool {
    year != 1700 && year % 4 == 0
  }
  public static func daysInMonth(year: Int, month: Int) -> Int {
    let normalMonthLength = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if month == 2 {
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

  static let algorithm = SwedishCalendarAlgorithm(y: 4716, j: 1401, m: 2, n: 12, r: 4, p: 1461, q: 0, v: 3, u: 5, s: 153, t: 2, w: 2)

  public static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    algorithm.toJd(Y: Y, M: M, D: D)
  }
  public static func toDate(J: Int) -> (Int, Int, Int) {
    algorithm.toDate(J: J)
  }

  public static func dayOfWeek(Y: Int, M: Int, D: Int) -> Int {
    let J = toJDN(Y: Y, M: M, D: D)
    let W = 1 + (J + 1) % 7
    return W
  }
}

