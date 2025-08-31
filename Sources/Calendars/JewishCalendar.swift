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

fileprivate struct TableA {
  let data = [
    [0, 30, 59, 88, 117, 147, 176, 206, 235, 265, 294, 324, 0],
    [0, 30, 59, 89, 118, 148, 177, 207, 236, 266, 295, 325, 0],
    [0, 30, 60, 90, 119, 149, 178, 208, 237, 267, 296, 326, 0],
    [0, 30, 59, 88, 117, 147, 177, 206, 236, 265, 295, 324, 354],
    [0, 30, 59, 89, 118, 148, 178, 207, 237, 266, 296, 325, 355],
    [0, 30, 60, 90, 119, 149, 179, 208, 238, 267, 297, 326, 356]
  ]

  subscript(i: Int, j: Int) -> Int {
    return data[i-1][j-1]
  }
}
fileprivate let A = TableA()

public struct JewishCalendar {
  static let epoch = 347998

  static func isAbundant(year: Int) -> Bool {
    let jdn0 = firstJDNOfYear(Y: year)
    let jdn1 = firstJDNOfYear(Y: year + 1)
    let daysInYear = jdn1 - jdn0
    return daysInYear == 355 || daysInYear == 385
  }
  static func isDeficient(year: Int) -> Bool {
    let jdn0 = firstJDNOfYear(Y: year)
    let jdn1 = firstJDNOfYear(Y: year + 1)
    let daysInYear = jdn1 - jdn0
    return daysInYear == 353 || daysInYear == 383
  }
  static func isRegular(year: Int) -> Bool {
    let jdn0 = firstJDNOfYear(Y: year)
    let jdn1 = firstJDNOfYear(Y: year + 1)
    let daysInYear = jdn1 - jdn0
    return daysInYear == 354 || daysInYear == 384
  }
  static func isLeapYear(year: Int) -> Bool {
    let y = (year - 1) % 19 + 1
    return [3, 6, 8, 11, 14, 17, 19].contains(y)
  }

  public static func daysInMonth(year: Int, month: Int) -> Int {
    let normalMonthLength = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29]
    let leapYearMonthLength = [30, 29, 30, 29, 30, 30, 29, 30, 29, 30, 29, 30, 29]
    if month == 2 {
      if isAbundant(year: year) {
        return 30
      }
    } else if month == 3 {
      if isDeficient(year: year) {
        return 29
      }
    }
    if isLeapYear(year: year) {
      return leapYearMonthLength[month - 1]
    }
    return normalMonthLength[month - 1]
  }

  public static func nameOfMonth(year: Int, month: Int) -> String {
    let monthNames = ["Tishiri", "Heshvan", "Kislev",
                      "Tebet", "Shebat", "Addar",
                      "Nisan", "Iyar", "Sivan",
                      "Tammuz", "Ab", "Elul"]
    let leapYearMonthNames = ["Tishiri", "Heshvan", "Kislev",
                      "Tebet", "Shebat", "Addar I", "Addar II",
                      "Nisan", "Iyar", "Sivan",
                      "Tammuz", "Ab", "Elul"]
    if isLeapYear(year: year) {
      return leapYearMonthNames[month-1]
    }
    return monthNames[month-1]
  }

  public static func numberOfMonth(year: Int, month: String) -> Int? {
    let monthDictionary = ["tishiri": 1, "heshvan": 2, "march": 3,
                           "kislev": 4, "shebat": 5, "addar": 6,
                           "nisan": 7, "iyar": 8, "sivan": 9,
                           "tammuz": 10, "ab": 11, "elul": 12]
    let leapYearMonthDictionary = [
      "tishiri" : 1, "heshvan" : 2, "kislev" : 3,
      "tebet": 4, "shebat": 5, "addar i": 6,
      "addar ii": 7,
      "nisan": 8, "iyar": 9, "sivan": 10,
      "tammuz": 11, "ab": 12, "elul": 13
    ]
    if isLeapYear(year: year) {
      return leapYearMonthDictionary[month.lowercased()]
    }
    return monthDictionary[month.lowercased()]
  }

  public static func numberOfMonths(year: Int) -> Int? {
    if isLeapYear(year: year) {
      return 13
    }
    return 12
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

  // Algorithm 5, Astronomical Almanac Supplement
  static func firstJDNOfYear(Y: Int) -> Int {
    let b = 31524 + 765433 * ((235 * Y - 234) / 19)
    var d = b / 25920
    let e = b % 25920
    let f = 1 + (d % 7)
    let g = ((7 * Y + 13) % 19) / 12
    let h = ((7 * Y + 6) % 19) / 12
    if (e >= 19440) ||
       (e >= 9924 && f == 3 && g == 0) ||
       (e >= 16788 && f == 2 && g == 0 && h == 1) {
      d = d + 1
    }
    let J = d + (((d + 5) % 7) % 2) + 347997
    return J
  }

  static func jewishYearOfJDN(J: Int) -> Int {
    let M = (25920 * (J - 347996)) / 765433
    var Y = 19 * (M / 235) + (19 * (M % 235) - 2) / 235 + 1
    let K = firstJDNOfYear(Y: Y)
    if K > J {
      Y = Y - 1
    }
    return Y
  }

  static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    let a = firstJDNOfYear(Y: Y)
    let b = firstJDNOfYear(Y: Y + 1)
    let K = b - a - 352 - 27 * (((7 * Y + 13) % 19) / 12)
    let J = a + A[K-1, M] + D - 1
    return J
  }
  static func toDate(J: Int) -> (Int, Int, Int) {
    let Y = jewishYearOfJDN(J: J)
    let a = firstJDNOfYear(Y: Y)
    let b = firstJDNOfYear(Y: Y + 1)
    let K = b - a - 352 - 27 * (((7 * Y + 13) % 19) / 12)
    let c = J - a + 1
    var M = 1
    for i in 1 ... 13 {
      if A[K,i] < c {
        M = i
      } else {
        break
      }
    }

    let D = c - A[K,M]
    return (Y, M, D)
  }

}
