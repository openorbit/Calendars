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

public enum YearMode {
  case civil        // The calendar’s canonical year
  case regnal       // Starts on a ruler’s accession anniversary (varies by monarch)
  case fiscal       // Jurisdiction-defined FY (e.g., Apr 1, Jul 1, Oct 1)
  case liturgical   // Church year (e.g., Advent, 1 Sep Byzantine, etc.)
}

public enum CalendarRegime : Sendable {
  /// Date based on calendar being rule based, which is independent on historical reconstructtion
  case ruleBased
  /// Reconstructed date based on tables attested by scholars
  case reconstructed
  /// Date is calculated based on algorihtmic extrapolation, outside reconstructed table ranges
  case extrapolated
}

public struct CalendarDateComponents {
  public let calendar: CalendarInfo
  public let yearMode: YearMode
  public var year: Int
  public var month: Int?
  public var day: Int?

  public let regime: CalendarRegime

  public init(calendar: CalendarId, yearMode: YearMode = .civil, year: Int, month: Int? = nil, day: Int? = nil) {
    self.calendar =
    switch calendar {
    case .gregorian:
      CalendarInfo(id: calendar, engine: GregorianCalendar.shared)
    case .julian:
      CalendarInfo(id: calendar, engine: JulianCalendar.shared)
    case .romanRepublican:
      CalendarInfo(id: calendar, engine: RomanCalendar.shared)
    case .frenchRepublican:
      CalendarInfo(id: calendar, engine: FrenchRepublicanCalendar.shared)
    case .swedish:
      CalendarInfo(id: calendar, engine: SwedishCalendar.shared)
    case .saka:
      CalendarInfo(id: calendar, engine: SakaCalendar.shared)
    case .ethiopian:
      CalendarInfo(id: calendar, engine: EthiopianCalendar.shared)
    case .coptic:
      CalendarInfo(id: calendar, engine: CopticCalendar.shared)
    case .egyptian:
      CalendarInfo(id: calendar, engine: EgyptianCalendar.shared)
    case .jewish:
      CalendarInfo(id: calendar, engine: JewishCalendar.shared)
    case .civilIslamic:
      CalendarInfo(id: calendar, engine: CivilIslamicCalendar.shared)
    case .bahai:
      CalendarInfo(id: calendar, engine: BahaiCalendar.shared)
    }

    self.yearMode = yearMode
    self.year = year
    self.month = month
    self.day = day

    if calendar == .romanRepublican {
      self.regime = RomanCalendar.shared.regime(forYear: year)
    } else {
      self.regime = .ruleBased
    }
  }

  public var jdn: Int {
    let m = month ?? 1
    let d = day ?? 1
    return self.calendar.engine.jdn(forYear: year, month: m, day: d)
  }
}
