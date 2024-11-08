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

public struct CivilIslamicCalendar {
  static let epoch = 1948440

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
