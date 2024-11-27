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

// Parse date using heuristic:

// In the case of three fields, we try the following:
//   In case the field is an ISO date YYYY-MM-DD, handle it as such
//   If a field looks like roman numerals, and it is larger than 31, assume it is a year
//   If a field is larger than 31, assume it is a year
//   If a field is a non-roman numeral text, assume this is a month,
//   try to match it against known months.
//   In case we have 2 remaining numbers if one is larger than 12, then assume this is a day
//   In case of ambiguous month/day pair or month/day/year triplet, fail parsing.

public struct DateParser {
  nonisolated(unsafe)
  static let isoDate = /(\d+)-(\d+)-(\d+)/

  nonisolated(unsafe)
  static let namedMonthDayYear = /(\w+) (\d+)(,?) (\d+)/

  nonisolated(unsafe)
  static let dayNamedMonthYear = /(\d+) (\w+) (\d+)/

  public static func parse(_ s: String, calendar: CalendarId) -> (Int, Int, Int)? {
    if let match = s.firstMatch(of: isoDate) {
      let y = Int(match.1)!
      let m = Int(match.2)!
      let d = Int(match.3)!
      
      if calendar.isValidDate(Y: y, M: m, D: d) {
        return (y, m, d)
      }
    }
    if let match = s.firstMatch(of: namedMonthDayYear) {
      let m = String(match.1)
      let d = Int(match.2)!
      let y = Int(match.4)!

      if let m = calendar.numberOfMonth(m) {
        if calendar.isValidDate(Y: y, M: m, D: d) {
          return (y, m, d)
        }
      }
    }
    if let match = s.firstMatch(of: dayNamedMonthYear) {
      let d = Int(match.1)!
      let m = String(match.2)
      let y = Int(match.3)!

      if let m = calendar.numberOfMonth(m) {
        if calendar.isValidDate(Y: y, M: m, D: d) {
          return (y, m, d)
        }
      }
    }

    return nil
  }
}
