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

public struct SakaCalendar {
  static let epoch = 1749995

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

