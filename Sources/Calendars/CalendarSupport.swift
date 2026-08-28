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

public enum CalendarId : String, Codable, Sendable, Equatable, Hashable, CaseIterable {
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
  case romanRepublican
}

public struct CalendarYearDesignation: Sendable, Equatable, Hashable {
  public let token: String
  public let description: String
  public let usesCommonEraPreference: Bool

  public init(token: String, description: String, usesCommonEraPreference: Bool = false) {
    self.token = token
    self.description = description
    self.usesCommonEraPreference = usesCommonEraPreference
  }

  public static let commonEra = CalendarYearDesignation(
    token: "CE", description: "Common Era", usesCommonEraPreference: true
  )
}

extension CalendarId {
  public var yearDesignation: CalendarYearDesignation {
    switch self {
    case .gregorian, .julian, .swedish:
      return .commonEra
    case .romanRepublican:
      return .init(token: "AUC", description: "Ab urbe condita")
    case .civilIslamic:
      return .init(token: "AH", description: "Anno Hegirae")
    case .jewish:
      return .init(token: "AM", description: "Anno Mundi")
    case .coptic:
      return .init(token: "AM", description: "Anno Martyrum")
    case .ethiopian:
      return .init(token: "EE", description: "Ethiopian Era")
    case .egyptian:
      return .init(token: "EN", description: "Era of Nabonassar")
    case .frenchRepublican:
      return .init(token: "An", description: "French Republican year")
    case .saka:
      return .init(token: "SE", description: "Saka Era")
    case .bahai:
      return .init(token: "BE", description: "Bahá’í Era")
    }
  }

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
    case .romanRepublican:
      return "Roman Republican"
    }
  }
  
  /// Returns the available date components (granularity) for this calendar.
  public var granularityComponents: [String] {
    switch self {
    case .gregorian, .julian, .swedish, .frenchRepublican, .jewish, .civilIslamic, .saka, .egyptian, .coptic, .ethiopian, .bahai, .romanRepublican:
      return ["year", "month", "day"]
    //case .mesoamericanLongCount:
    //  return ["baktun", "katun", "tun", "uinal", "kin"]
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

  /// Returns the first Julian day number in the calendar year.
  func startOfYearJDN(year: Int) -> Int?
  /// Returns the last Julian day number in the calendar year.
  func endOfYearJDN(year: Int) -> Int?
}

public extension CalendarProtocol {
  func startOfYearJDN(year: Int) -> Int? {
    guard isValidDate(year: year, month: 1, day: 1) else {
      return nil
    }
    return jdn(forYear: year, month: 1, day: 1)
  }

  func endOfYearJDN(year: Int) -> Int? {
    let lastDay = daysInMonth(year: year, month: 12)
    guard isValidDate(year: year, month: 12, day: lastDay) else {
      return nil
    }
    return jdn(forYear: year, month: 12, day: lastDay)
  }
}

public struct Validity: Codable, Equatable, Sendable {
  public let scope: String   // "global", ISO region, "city:Rome", etc.
  public let startJDN: Int?
  public let endJDN: Int?
}
