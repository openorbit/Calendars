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

public enum HistoricalCalendarPolity: String, Codable, Sendable, CaseIterable {
  case global
  case sweden
  case finland
  case greatBritain
  case france
  case denmark
  case norway
  case russia
}

public struct HistoricalCalendarUsageRule: Sendable, Hashable {
  public let polity: HistoricalCalendarPolity
  public let calendar: CalendarId
  public let startJDN: Int?
  public let endJDN: Int?
  public let source: String
  public let note: String?

  public init(polity: HistoricalCalendarPolity,
              calendar: CalendarId,
              startJDN: Int?,
              endJDN: Int?,
              source: String,
              note: String? = nil) {
    self.polity = polity
    self.calendar = calendar
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

public struct LocalSkippedDateRange: Sendable, Hashable {
  public let polity: HistoricalCalendarPolity
  public let calendar: CalendarId
  public let startYear: Int
  public let startMonth: Int
  public let startDay: Int
  public let endYear: Int
  public let endMonth: Int
  public let endDay: Int
  public let reason: String

  public init(polity: HistoricalCalendarPolity,
              calendar: CalendarId,
              startYear: Int,
              startMonth: Int,
              startDay: Int,
              endYear: Int,
              endMonth: Int,
              endDay: Int,
              reason: String) {
    self.polity = polity
    self.calendar = calendar
    self.startYear = startYear
    self.startMonth = startMonth
    self.startDay = startDay
    self.endYear = endYear
    self.endMonth = endMonth
    self.endDay = endDay
    self.reason = reason
  }

  func contains(year: Int, month: Int, day: Int) -> Bool {
    let v = (year, month, day)
    let start = (startYear, startMonth, startDay)
    let end = (endYear, endMonth, endDay)
    return v >= start && v <= end
  }
}

public enum LocalDateValidationResult: Sendable, Equatable {
  case valid(calendar: CalendarId)
  case invalid(reason: String)
  case ambiguous(calendars: [CalendarId])
  case unknown
}

public enum HistoricalCalendarUsagePolicy {
  private enum HistoricalCalendarProfile {
    case globalFallback
    case swedenFinland
    case greatBritain
    case france
    case denmarkNorway
    case russia
  }

  private struct ProfileRuleSegment {
    let calendar: CalendarId
    let startJDN: Int?
    let endJDN: Int?
    let source: String
    let note: String?
  }

  private struct ProfileSkippedSegment {
    let calendar: CalendarId
    let startYear: Int
    let startMonth: Int
    let startDay: Int
    let endYear: Int
    let endMonth: Int
    let endDay: Int
    let reason: String
  }

  public static let rules: [HistoricalCalendarUsageRule] = buildRules()

  public static let skippedLocalDates: [LocalSkippedDateRange] = buildSkippedLocalDates()

  private static func buildRules() -> [HistoricalCalendarUsageRule] {
    var result: [HistoricalCalendarUsageRule] = []
    appendRules(to: &result, polities: [.global], profile: .globalFallback)
    appendRules(to: &result, polities: [.sweden, .finland], profile: .swedenFinland)
    appendRules(to: &result, polities: [.greatBritain], profile: .greatBritain)
    appendRules(to: &result, polities: [.france], profile: .france)
    appendRules(to: &result, polities: [.denmark, .norway], profile: .denmarkNorway)
    appendRules(to: &result, polities: [.russia], profile: .russia)
    return result
  }

  private static func buildSkippedLocalDates() -> [LocalSkippedDateRange] {
    var result: [LocalSkippedDateRange] = []
    appendSkippedRanges(to: &result, polities: [.sweden, .finland], profile: .swedenFinland)
    appendSkippedRanges(to: &result, polities: [.greatBritain], profile: .greatBritain)
    appendSkippedRanges(to: &result, polities: [.france], profile: .france)
    appendSkippedRanges(to: &result, polities: [.denmark, .norway], profile: .denmarkNorway)
    appendSkippedRanges(to: &result, polities: [.russia], profile: .russia)
    return result
  }

  private static func appendRules(to result: inout [HistoricalCalendarUsageRule],
                                  polities: [HistoricalCalendarPolity],
                                  profile: HistoricalCalendarProfile) {
    let segments = profileRuleSegments(for: profile)
    for polity in polities {
      result.append(contentsOf: segments.map { segment in
        HistoricalCalendarUsageRule(
          polity: polity,
          calendar: segment.calendar,
          startJDN: segment.startJDN,
          endJDN: segment.endJDN,
          source: segment.source,
          note: segment.note
        )
      })
    }
  }

  private static func appendSkippedRanges(to result: inout [LocalSkippedDateRange],
                                          polities: [HistoricalCalendarPolity],
                                          profile: HistoricalCalendarProfile) {
    let segments = profileSkippedSegments(for: profile)
    for polity in polities {
      result.append(contentsOf: segments.map { segment in
        LocalSkippedDateRange(
          polity: polity,
          calendar: segment.calendar,
          startYear: segment.startYear,
          startMonth: segment.startMonth,
          startDay: segment.startDay,
          endYear: segment.endYear,
          endMonth: segment.endMonth,
          endDay: segment.endDay,
          reason: segment.reason
        )
      })
    }
  }

  private static func profileRuleSegments(for profile: HistoricalCalendarProfile) -> [ProfileRuleSegment] {
    switch profile {
    case .globalFallback:
      return [
        ProfileRuleSegment(
          calendar: .gregorian,
          startJDN: nil,
          endJDN: nil,
          source: "Default fallback",
          note: "Used only when no polity-specific rule matches."
        )
      ]

    case .swedenFinland:
      return [
        ProfileRuleSegment(
          calendar: .julian,
          startJDN: nil,
          endJDN: JulianCalendar.toJDN(Y: 1700, M: 2, D: 28),
          source: "Sweden-Finland calendar reform chronology",
          note: nil
        ),
        ProfileRuleSegment(
          calendar: .swedish,
          startJDN: SwedishCalendar.toJDN(Y: 1700, M: 3, D: 1),
          endJDN: SwedishCalendar.toJDN(Y: 1712, M: 2, D: 30),
          source: "Sweden-Finland calendar reform chronology",
          note: nil
        ),
        ProfileRuleSegment(
          calendar: .julian,
          startJDN: JulianCalendar.toJDN(Y: 1712, M: 3, D: 1),
          endJDN: JulianCalendar.toJDN(Y: 1753, M: 2, D: 17),
          source: "Sweden-Finland calendar reform chronology",
          note: nil
        ),
        ProfileRuleSegment(
          calendar: .gregorian,
          startJDN: GregorianCalendar.toJDN(Y: 1753, M: 3, D: 1),
          endJDN: nil,
          source: "Sweden-Finland calendar reform chronology",
          note: "Modeled as continuous Gregorian use after 1753."
        )
      ]

    case .greatBritain:
      return [
        ProfileRuleSegment(
          calendar: .julian,
          startJDN: nil,
          endJDN: JulianCalendar.toJDN(Y: 1752, M: 9, D: 2),
          source: "Calendar (New Style) Act implementation",
          note: nil
        ),
        ProfileRuleSegment(
          calendar: .gregorian,
          startJDN: GregorianCalendar.toJDN(Y: 1752, M: 9, D: 14),
          endJDN: nil,
          source: "Calendar (New Style) Act implementation",
          note: nil
        )
      ]

    case .france:
      return [
        ProfileRuleSegment(
          calendar: .julian,
          startJDN: nil,
          endJDN: JulianCalendar.toJDN(Y: 1582, M: 12, D: 9),
          source: "French Gregorian adoption chronology",
          note: nil
        ),
        ProfileRuleSegment(
          calendar: .gregorian,
          startJDN: GregorianCalendar.toJDN(Y: 1582, M: 12, D: 20),
          endJDN: nil,
          source: "French Gregorian adoption chronology",
          note: nil
        )
      ]

    case .denmarkNorway:
      return [
        ProfileRuleSegment(
          calendar: .julian,
          startJDN: nil,
          endJDN: JulianCalendar.toJDN(Y: 1700, M: 2, D: 18),
          source: "Danish-Norwegian Gregorian adoption chronology",
          note: nil
        ),
        ProfileRuleSegment(
          calendar: .gregorian,
          startJDN: GregorianCalendar.toJDN(Y: 1700, M: 3, D: 1),
          endJDN: nil,
          source: "Danish-Norwegian Gregorian adoption chronology",
          note: nil
        )
      ]

    case .russia:
      return [
        ProfileRuleSegment(
          calendar: .julian,
          startJDN: nil,
          endJDN: JulianCalendar.toJDN(Y: 1918, M: 1, D: 31),
          source: "Sovnarkom decree on calendar reform",
          note: nil
        ),
        ProfileRuleSegment(
          calendar: .gregorian,
          startJDN: GregorianCalendar.toJDN(Y: 1918, M: 2, D: 14),
          endJDN: nil,
          source: "Sovnarkom decree on calendar reform",
          note: nil
        )
      ]
    }
  }

  private static func profileSkippedSegments(for profile: HistoricalCalendarProfile) -> [ProfileSkippedSegment] {
    switch profile {
    case .globalFallback:
      return []

    case .swedenFinland:
      return [
        ProfileSkippedSegment(
          calendar: .julian,
          startYear: 1700,
          startMonth: 2,
          startDay: 29,
          endYear: 1700,
          endMonth: 2,
          endDay: 29,
          reason: "Skipped during the 1700 reform."
        ),
        ProfileSkippedSegment(
          calendar: .julian,
          startYear: 1753,
          startMonth: 2,
          startDay: 18,
          endYear: 1753,
          endMonth: 2,
          endDay: 28,
          reason: "Skipped during Gregorian adoption."
        )
      ]

    case .greatBritain:
      return [
        ProfileSkippedSegment(
          calendar: .julian,
          startYear: 1752,
          startMonth: 9,
          startDay: 3,
          endYear: 1752,
          endMonth: 9,
          endDay: 13,
          reason: "Skipped during Gregorian adoption."
        )
      ]

    case .france:
      return [
        ProfileSkippedSegment(
          calendar: .julian,
          startYear: 1582,
          startMonth: 12,
          startDay: 10,
          endYear: 1582,
          endMonth: 12,
          endDay: 19,
          reason: "Skipped during Gregorian adoption."
        )
      ]

    case .denmarkNorway:
      return [
        ProfileSkippedSegment(
          calendar: .julian,
          startYear: 1700,
          startMonth: 2,
          startDay: 19,
          endYear: 1700,
          endMonth: 2,
          endDay: 28,
          reason: "Skipped during Gregorian adoption."
        )
      ]

    case .russia:
      return [
        ProfileSkippedSegment(
          calendar: .julian,
          startYear: 1918,
          startMonth: 2,
          startDay: 1,
          endYear: 1918,
          endMonth: 2,
          endDay: 13,
          reason: "Skipped during Gregorian adoption."
        )
      ]
    }
  }

  public static func calendarInUse(for polity: HistoricalCalendarPolity, onJDN jdn: Int) -> CalendarId? {
    let matches = rules
      .filter { $0.polity == polity || $0.polity == .global }
      .filter { $0.contains(jdn: jdn) }
      .sorted { lhs, rhs in
        let lhsSpecificity = lhs.polity == polity ? 1 : 0
        let rhsSpecificity = rhs.polity == polity ? 1 : 0
        if lhsSpecificity != rhsSpecificity {
          return lhsSpecificity > rhsSpecificity
        }
        return (lhs.startJDN ?? Int.min) > (rhs.startJDN ?? Int.min)
      }
    return matches.first?.calendar
  }

  public static func validateUnspecifiedLocalDate(for polity: HistoricalCalendarPolity,
                                                  year: Int,
                                                  month: Int,
                                                  day: Int) -> LocalDateValidationResult {
    let candidates: [CalendarId] = [.swedish, .julian, .gregorian]
    var validCandidates: [CalendarId] = []
    var invalidReasons: [String] = []

    for calendar in candidates {
      guard let engine = calendarEngine(for: calendar),
            engine.isValidDate(year: year, month: month, day: day) else {
        continue
      }

      if let skipped = skippedLocalDates.first(where: {
        $0.polity == polity &&
        $0.calendar == calendar &&
        $0.contains(year: year, month: month, day: day)
      }) {
        invalidReasons.append(skipped.reason)
        continue
      }

      let jdn = engine.jdn(forYear: year, month: month, day: day)
      if calendarInUse(for: polity, onJDN: jdn) == calendar {
        validCandidates.append(calendar)
      }
    }

    if validCandidates.count == 1, let only = validCandidates.first {
      return .valid(calendar: only)
    }
    if validCandidates.count > 1 {
      return .ambiguous(calendars: validCandidates.sorted { $0.rawValue < $1.rawValue })
    }
    if let reason = invalidReasons.first {
      return .invalid(reason: reason)
    }
    return .unknown
  }

  private static func calendarEngine(for calendar: CalendarId) -> CalendarProtocol? {
    switch calendar {
    case .gregorian:
      return GregorianCalendar.shared
    case .julian:
      return JulianCalendar.shared
    case .swedish:
      return SwedishCalendar.shared
    default:
      return nil
    }
  }
}
