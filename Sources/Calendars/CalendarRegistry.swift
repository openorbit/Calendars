//
//  CalendarRegistry.swift
//  Calendars
//
//  Created by Mattias Holm on 2025-09-07.
//
import Foundation

public actor CalendarRegistry {
  public static let shared = CalendarRegistry()
  private var map: [String: CalendarProtocol] = [:]

  public init() {
    // Actor inits are nonisolated. Directly initialize stored state instead of
    // calling an actor-isolated method.
    map[BahaiCalendar.shared.calendarKey.lowercased()] = BahaiCalendar.shared
    map[CivilIslamicCalendar.shared.calendarKey.lowercased()] = CivilIslamicCalendar.shared
    map[CopticCalendar.shared.calendarKey.lowercased()] = CopticCalendar.shared
    map[EgyptianCalendar.shared.calendarKey.lowercased()] = EgyptianCalendar.shared
    map[EthiopianCalendar.shared.calendarKey.lowercased()] = EthiopianCalendar.shared
    map[FrenchRepublicanCalendar.shared.calendarKey.lowercased()] = FrenchRepublicanCalendar.shared
    map[GregorianCalendar.shared.calendarKey.lowercased()] = GregorianCalendar.shared
    map[JewishCalendar.shared.calendarKey.lowercased()] = JewishCalendar.shared
    map[JulianCalendar.shared.calendarKey.lowercased()] = JulianCalendar.shared
    map[RomanCalendar.shared.calendarKey.lowercased()] = RomanCalendar.shared
    map[SakaCalendar.shared.calendarKey.lowercased()] = SakaCalendar.shared
    map[SwedishCalendar.shared.calendarKey.lowercased()] = SwedishCalendar.shared
  }

  public func register(_ cal: CalendarProtocol) {
    map[cal.calendarKey.lowercased()] = cal
  }

  public func calendar(for id: String) -> CalendarProtocol? {
    return map[id.lowercased()]
  }
}
