//
// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Mattias Holm
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

public enum JulianYearStartUsage: String, Codable, Sendable, CaseIterable {
  case civil
  case ecclesiastical
}

public enum JulianYearStartEntity: String, Codable, Sendable, CaseIterable {
  case global
  case estatesOfHolland
  case france
  case utrecht
  case englandAndWales
  case scotland
  case florence
  case pisa
  case venice
}

public struct JulianYearStartRule: Sendable, Hashable {
  public let entity: JulianYearStartEntity
  public let usage: JulianYearStartUsage
  public let culture: JulianYearStartCulture
  public let startJDN: Int?
  public let endJDN: Int?
  public let source: String
  public let note: String?

  public init(entity: JulianYearStartEntity,
              usage: JulianYearStartUsage,
              culture: JulianYearStartCulture,
              startJDN: Int?,
              endJDN: Int?,
              source: String,
              note: String? = nil) {
    self.entity = entity
    self.usage = usage
    self.culture = culture
    self.startJDN = startJDN
    self.endJDN = endJDN
    self.source = source
    self.note = note
  }

  func contains(jdn: Int) -> Bool {
    if let startJDN, jdn < startJDN {
      return false
    }
    if let endJDN, jdn > endJDN {
      return false
    }
    return true
  }
}

public enum JulianYearStartPolicy {
  // Seed rules with examples requested in Testimonia planning.
  // These should be treated as extensible historical defaults, not exhaustive truth.
  public static let rules: [JulianYearStartRule] = [
    // Global default used when no regional rule matches.
    JulianYearStartRule(entity: .global,
                        usage: .civil,
                        culture: .civilJan1,
                        startJDN: nil,
                        endJDN: nil,
                        source: "Default policy",
                        note: "Fallback only; regional overrides should take precedence."),

    // Poole-style examples requested by user.
    JulianYearStartRule(entity: .estatesOfHolland,
                        usage: .civil,
                        culture: .annunciationMar25,
                        startJDN: nil,
                        endJDN: JulianCalendar.toJDN(Y: 1531, M: 12, D: 31),
                        source: "Poole (1921)",
                        note: "Pre-change civil usage"),
    JulianYearStartRule(entity: .estatesOfHolland,
                        usage: .civil,
                        culture: .civilJan1,
                        startJDN: JulianCalendar.toJDN(Y: 1532, M: 1, D: 1),
                        endJDN: nil,
                        source: "Poole (1921)",
                        note: "Civil New Year moved to 1 January"),

    JulianYearStartRule(entity: .france,
                        usage: .civil,
                        culture: .annunciationMar25,
                        startJDN: nil,
                        endJDN: JulianCalendar.toJDN(Y: 1566, M: 12, D: 31),
                        source: "Poole (1921)",
                        note: "Pre-Edict baseline"),
    JulianYearStartRule(entity: .france,
                        usage: .civil,
                        culture: .civilJan1,
                        startJDN: JulianCalendar.toJDN(Y: 1567, M: 1, D: 1),
                        endJDN: nil,
                        source: "Poole (1921)",
                        note: "Edict-era transition represented as 1567 effective in this table"),

    JulianYearStartRule(entity: .utrecht,
                        usage: .civil,
                        culture: .annunciationMar25,
                        startJDN: nil,
                        endJDN: JulianCalendar.toJDN(Y: 1699, M: 12, D: 31),
                        source: "Poole (1921)",
                        note: "Pre-change civil usage"),
    JulianYearStartRule(entity: .utrecht,
                        usage: .civil,
                        culture: .civilJan1,
                        startJDN: JulianCalendar.toJDN(Y: 1700, M: 1, D: 1),
                        endJDN: nil,
                        source: "Poole (1921)",
                        note: "Civil New Year moved to 1 January"),

    // Additional examples to demonstrate mixed regimes.
    JulianYearStartRule(entity: .englandAndWales,
                        usage: .civil,
                        culture: .annunciationMar25,
                        startJDN: nil,
                        endJDN: JulianCalendar.toJDN(Y: 1751, M: 12, D: 31),
                        source: "Conventional British legal dating",
                        note: "Old Style legal year start"),
    JulianYearStartRule(entity: .englandAndWales,
                        usage: .civil,
                        culture: .civilJan1,
                        startJDN: JulianCalendar.toJDN(Y: 1752, M: 1, D: 1),
                        endJDN: nil,
                        source: "Calendar reform era",
                        note: "Civil New Year aligned to 1 January"),

    JulianYearStartRule(entity: .scotland,
                        usage: .civil,
                        culture: .civilJan1,
                        startJDN: JulianCalendar.toJDN(Y: 1600, M: 1, D: 1),
                        endJDN: nil,
                        source: "Scottish New Year reform",
                        note: "Scotland moved earlier than England/Wales"),

    JulianYearStartRule(entity: .florence,
                        usage: .civil,
                        culture: .annunciationMar25,
                        startJDN: nil,
                        endJDN: nil,
                        source: "Common Florentine style examples",
                        note: "Table placeholder for expansion"),
    JulianYearStartRule(entity: .pisa,
                        usage: .civil,
                        culture: .annunciationMar25,
                        startJDN: nil,
                        endJDN: nil,
                        source: "Common Pisan style examples",
                        note: "Table placeholder for expansion"),
    JulianYearStartRule(entity: .venice,
                        usage: .civil,
                        culture: .civilJan1,
                        startJDN: nil,
                        endJDN: nil,
                        source: "Common Venetian style examples",
                        note: "Table placeholder for expansion")
  ]

  public static func culture(for entity: JulianYearStartEntity,
                             usage: JulianYearStartUsage,
                             onJDN jdn: Int) -> JulianYearStartCulture? {
    let matches = rules
      .filter { $0.usage == usage }
      .filter { $0.entity == entity || $0.entity == .global }
      .filter { $0.contains(jdn: jdn) }

    guard !matches.isEmpty else {
      return nil
    }

    // Prefer exact entity over global fallback, then latest start date.
    let best = matches.sorted { lhs, rhs in
      let lhsSpecificity = lhs.entity == entity ? 1 : 0
      let rhsSpecificity = rhs.entity == entity ? 1 : 0
      if lhsSpecificity != rhsSpecificity {
        return lhsSpecificity > rhsSpecificity
      }
      return (lhs.startJDN ?? Int.min) > (rhs.startJDN ?? Int.min)
    }.first

    return best?.culture
  }

  public static func culture(for entity: JulianYearStartEntity,
                             usage: JulianYearStartUsage,
                             year: Int,
                             month: Int,
                             day: Int,
                             in calendar: CalendarId = .julian) -> JulianYearStartCulture? {
    guard let jdn = jdn(year: year, month: month, day: day, calendar: calendar) else {
      return nil
    }
    return culture(for: entity, usage: usage, onJDN: jdn)
  }

  public static func cultures(for entity: JulianYearStartEntity,
                              onJDN jdn: Int) -> [JulianYearStartUsage: JulianYearStartCulture] {
    var result: [JulianYearStartUsage: JulianYearStartCulture] = [:]
    for usage in JulianYearStartUsage.allCases {
      if let culture = culture(for: entity, usage: usage, onJDN: jdn) {
        result[usage] = culture
      }
    }
    return result
  }

  public static func rules(for entity: JulianYearStartEntity,
                           usage: JulianYearStartUsage? = nil) -> [JulianYearStartRule] {
    rules
      .filter { $0.entity == entity || $0.entity == .global }
      .filter { usage == nil || $0.usage == usage }
      .sorted { ($0.startJDN ?? Int.min) < ($1.startJDN ?? Int.min) }
  }

  private static func jdn(year: Int, month: Int, day: Int, calendar: CalendarId) -> Int? {
    switch calendar {
    case .julian:
      return JulianCalendar.toJDN(Y: year, M: month, D: day)
    case .gregorian:
      return GregorianCalendar.toJDN(Y: year, M: month, D: day)
    case .swedish:
      return SwedishCalendar.toJDN(Y: year, M: month, D: day)
    default:
      return nil
    }
  }
}

public extension JulianCalendar {
  func yearStartCulture(for entity: JulianYearStartEntity,
                        usage: JulianYearStartUsage,
                        onJDN jdn: Int) -> JulianYearStartCulture? {
    JulianYearStartPolicy.culture(for: entity, usage: usage, onJDN: jdn)
  }

  func yearStartCulture(for entity: JulianYearStartEntity,
                        usage: JulianYearStartUsage,
                        year: Int,
                        month: Int,
                        day: Int,
                        in calendar: CalendarId = .julian) -> JulianYearStartCulture? {
    JulianYearStartPolicy.culture(for: entity,
                                  usage: usage,
                                  year: year,
                                  month: month,
                                  day: day,
                                  in: calendar)
  }
}
