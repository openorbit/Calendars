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

public enum CalendarId : Codable, Sendable {
  case julian
  case gregorian
  case swedish
  case civilIslamic
  case saka
  case egyptian
  case ethiopian
  case frenchRepublican
  case coptic
  case bahai
  case jewish
  case mesoamericanLongCount
  case romanRepublican
  case custom(String)
}

extension CalendarId {
  public var description : String {
    switch self {
    case .gregorian:
      return "Gregorian"
    case .julian:
      return "Julian"
    case .swedish:
      return "Swedish Transitional"
    case .frenchRepublican:
      return "French Revolutionary"
    case .jewish:
      return "Jewish"
    case .civilIslamic:
      return "Civil Islamic"
    case .saka:
      return "Saka"
    case .egyptian:
      return "Egyptian"
    case .coptic:
      return "Coptic"
    case .ethiopian:
      return "Ethiopian"
    case .bahai:
      return "Bahai"
    case .mesoamericanLongCount:
      return "Mesoamerican Long Count"
    case .romanRepublican:
      return "Roman Republican"
    case .custom(let s):
      return "\(s)"
    }
  }
  
  /// Returns the available date components (granularity) for this calendar.
  public var granularityComponents: [String] {
    switch self {
    case .gregorian, .julian, .swedish, .frenchRepublican, .jewish, .civilIslamic, .saka, .egyptian, .coptic, .ethiopian, .bahai, .romanRepublican, .custom:
      return ["year", "month", "day"]
    case .mesoamericanLongCount:
      return ["baktun", "katun", "tun", "uinal", "kin"]
    }
  }
}

public protocol WeekdayProtocol {
  var numberOfDays: Int { get }
  func weekday(forYear year: Int, month: Int, day: Int) -> Int
  func name(ofWeekday day: Int) -> String
}

public protocol CalendarProtocol: Sendable {
  var identifier: CalendarId { get }
  var calendarKey: String { get }

  func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth]

  func isValidDate(year: Int, month: Int, day: Int) -> Bool
  func monthName(forYear year: Int, month: Int) -> String
  func daysInMonth(year: Int, month: Int) -> Int
  func isProleptic(julianDay jdn: Int) -> Bool
  func monthNumber(for month: String, in year: Int) -> Int?

  func jdn(forYear year: Int, month: Int, day: Int) -> Int
  func date(fromJDN jdn: Int) -> CalendarDateComponents?
}

public struct Validity: Codable, Equatable, Sendable {
  public let scope: String   // "global", ISO region, "city:Rome", etc.
  public let startJDN: Int?
  public let endJDN: Int?
}
