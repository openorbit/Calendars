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

public struct GregorianCalendar {
  // 1582-10-15
  static let epoch = 2299161

  public static func isLeapYear(year: Int) -> Bool {
    year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)
  }
  public static func daysInMonth(year: Int, month: Int) -> Int {
    let normalMonthLength = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if month == 2 {
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


  static let algorithm = GregorianStyleCalendarAlgorithm(y: 4716, j: 1401, m: 2, n: 12, r: 4, p: 1461, q: 0, v: 3, u: 5, s: 153, t: 2, w: 2, A: 184, B: 274277, C: -38)

  static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    algorithm.toJd(Y: Y, M: M, D: D)
  }
  static func toDate(J: Int) -> (Int, Int, Int) {
    algorithm.toDate(J: J)
  }

  static func dayOfWeek(Y: Int, M: Int, D: Int) -> Int {
    let a = (9 + M) % 12
    let b = Y - a/10
    let W = 1 + (2 + D + (13 * a + 2) / 5 + b + b / 4 - b / 100 + b / 400) % 7
    return W
  }

  static func dayOfEaster(Y: Int) -> (Int, Int, Int) {
    let a = Y / 100
    let b = a - a / 4
    let c = Y % 19
    let e = (15 + 19 * c + b - (a - (a - 17) / 25) / 3) % 30
    let f = e - (c + 11 * e) / 319
    let g = 22 + f + (140004 -  Y - Y / 4 + b - f) % 7
    let M = 3 + g / 32
    let D = 1 + (g - 1) % 31
    return (Y, M, D)
  }

}
