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

public struct EgyptianCalendar {
  static let epoch = 1448638

  public static func daysInMonth(year: Int, month: Int) -> Int {
    if month == 13 {
      return 5
    }
    return 30
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

  public static func numberOfMonth(_ month: String) -> Int? {
    let monthDictionary = ["toth": 1, "paophi": 2, "athyr": 3,
                           "cohiac": 4, "tybi": 5, "mesir": 6,
                           "phanemoth": 7, "pharmouti": 8, "pachons": 9,
                           "payni": 10, "epiphi": 11, "mesori": 12, "": 13]
    return monthDictionary[month.lowercased()]
  }

  public static func nameOfMonth(_ month: Int) -> String {
    let monthNames = ["Toth", "Paophi", "Athyr",
                      "Cohiac", "Tybi", "Mesir",
                      "Phanemoth", "Pharmouti", "Pachons",
                      "Payni", "Epiphi", "Mesori", ""]
    return monthNames[month-1]
  }

  public static func isProleptic(_ d: Int) -> Bool {
    return d < epoch
  }

  static let algorithm = CalendarAlgorithm(y: 3968, j: 47, m: 0, n: 13, r: 1, p: 365, q: 0, v: 0, u: 1, s: 30, t: 0, w: 0)

  static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    algorithm.toJd(Y: Y, M: M, D: D)
  }
  static func toDate(J: Int) -> (Int, Int, Int) {
    algorithm.toDate(J: J)
  }

}
