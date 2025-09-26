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

public struct CalendarRegistry : Sendable {
  public static let shared = CalendarRegistry()
  private var map: [String: CalendarProtocol] = [
    BahaiCalendar.shared.calendarKey.lowercased() : BahaiCalendar.shared,
    CivilIslamicCalendar.shared.calendarKey.lowercased() : CivilIslamicCalendar.shared,
    CopticCalendar.shared.calendarKey.lowercased() : CopticCalendar.shared,
    EgyptianCalendar.shared.calendarKey.lowercased() : EgyptianCalendar.shared,
    EthiopianCalendar.shared.calendarKey.lowercased() : EthiopianCalendar.shared,
    FrenchRepublicanCalendar.shared.calendarKey.lowercased() : FrenchRepublicanCalendar.shared,
    GregorianCalendar.shared.calendarKey.lowercased() : GregorianCalendar.shared,
    JewishCalendar.shared.calendarKey.lowercased() : JewishCalendar.shared,
    JulianCalendar.shared.calendarKey.lowercased() : JulianCalendar.shared,
    RomanCalendar.shared.calendarKey.lowercased() : RomanCalendar.shared,
    SakaCalendar.shared.calendarKey.lowercased() : SakaCalendar.shared,
    SwedishCalendar.shared.calendarKey.lowercased() : SwedishCalendar.shared
  ]
  private var idMap: [String: CalendarId] = [
    BahaiCalendar.shared.calendarKey.lowercased() : .bahai,
    CivilIslamicCalendar.shared.calendarKey.lowercased() : .civilIslamic,
    CopticCalendar.shared.calendarKey.lowercased() : .coptic,
    EgyptianCalendar.shared.calendarKey.lowercased() : .egyptian,
    EthiopianCalendar.shared.calendarKey.lowercased() : .ethiopian,
    FrenchRepublicanCalendar.shared.calendarKey.lowercased() : .frenchRepublican,
    GregorianCalendar.shared.calendarKey.lowercased() : .gregorian,
    JewishCalendar.shared.calendarKey.lowercased() : .jewish,
    JulianCalendar.shared.calendarKey.lowercased() : .julian,
    RomanCalendar.shared.calendarKey.lowercased() : .romanRepublican,
    SakaCalendar.shared.calendarKey.lowercased() : .saka,
    SwedishCalendar.shared.calendarKey.lowercased() : .swedish
  ]

  public func calendar(for id: String) -> CalendarProtocol? {
    return map[id.lowercased()]
  }
  public func calendarID(for id: String) -> CalendarId? {
    return idMap[id.lowercased()]
  }

}
