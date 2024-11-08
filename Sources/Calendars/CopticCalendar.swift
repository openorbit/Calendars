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


public struct CopticCalendar {
  static let epoch = 1825030

  public static func isProleptic(_ d: Int) -> Bool {
    return d < epoch
  }

  // TODO: Fixme
  public static func daysInMonth(year: Int, month: Int) -> Int {
    let normalMonthLength = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    return normalMonthLength[month - 1]
  }
  public static func numberOfMonth(_ month: String) -> Int? {
    let monthDictionary = ["january": 1, "february": 2, "march": 3,
                           "april": 4, "may": 5, "june": 6,
                           "july": 7, "august": 8, "september": 9,
                           "october": 10, "november": 11, "december": 12]
    return monthDictionary[month.lowercased()]
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

  static let algorithm = CalendarAlgorithm(y: 4996, j: 124, m: 0, n: 13, r: 4, p: 1461, q: 0, v: 3, u: 1, s: 30, t: 0, w: 0)

  static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    algorithm.toJd(Y: Y, M: M, D: D)
  }
  static func toDate(J: Int) -> (Int, Int, Int) {
    algorithm.toDate(J: J)
  }

}
