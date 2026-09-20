import Foundation

public enum CalendarCycle: String, CaseIterable, Codable, Hashable, Sendable {
  case sevenDay
  case nundinal
  case frenchDecade
  case sovietFiveDay
  case sovietSixDay
}

public struct CalendarCycleDay: Codable, Hashable, Sendable {
  public enum Role: String, Codable, Hashable, Sendable {
    case working
    case commonRest
    case rotatingRest
    case publicHoliday
    case supplementary
    case outsideCycle
  }

  public enum RestGroup: String, Codable, CaseIterable, Hashable, Sendable {
    case yellow, pink, red, purple, green
  }

  public let cycle: CalendarCycle
  public let ordinal: Int?
  public let label: String
  public let role: Role
  public let restGroup: RestGroup?

  public init(cycle: CalendarCycle, ordinal: Int?, label: String, role: Role, restGroup: RestGroup? = nil) {
    self.cycle = cycle
    self.ordinal = ordinal
    self.label = label
    self.role = role
    self.restGroup = restGroup
  }

  public var isRestDay: Bool {
    role == .commonRest || role == .publicHoliday
  }
}

public extension CalendarProtocol {
  func cycleDay(atJDN jdn: Int, cycle: CalendarCycle) -> CalendarCycleDay? {
    defaultCycleDay(atJDN: jdn, cycle: cycle)
  }

  internal func defaultCycleDay(atJDN jdn: Int, cycle: CalendarCycle) -> CalendarCycleDay? {
    switch cycle {
    case .sevenDay:
      let ordinal = positiveCycleMod(jdn, 7)
      let labels = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      return CalendarCycleDay(cycle: cycle, ordinal: ordinal, label: labels[ordinal], role: ordinal >= 5 ? .commonRest : .working)

    case .nundinal:
      guard let date = date(fromJDN: jdn), let yearStart = startOfYearJDN(year: date.year) else { return nil }
      var offset = jdn - yearStart
      if identifier == .julian,
         JulianCalendar.isLeapYear(year: date.year),
         let month = date.month,
         let day = date.day,
         month > 2 || (month == 2 && day > 24) {
        offset -= 1
      }
      let ordinal = positiveCycleMod(offset, 8)
      guard let scalar = UnicodeScalar(65 + ordinal) else { return nil }
      return CalendarCycleDay(cycle: cycle, ordinal: ordinal, label: String(scalar), role: .working)

    case .frenchDecade:
      guard identifier == .frenchRepublican,
            let date = date(fromJDN: jdn),
            let month = date.month,
            let day = date.day else { return nil }
      if month == 13 {
        return CalendarCycleDay(cycle: cycle, ordinal: nil, label: "Complementary day \(day)", role: .supplementary)
      }
      guard (1...12).contains(month), (1...30).contains(day) else { return nil }
      let labels = ["Primidi", "Duodi", "Tridi", "Quartidi", "Quintidi", "Sextidi", "Septidi", "Octidi", "Nonidi", "Décadi"]
      let ordinal = (day - 1) % 10
      return CalendarCycleDay(cycle: cycle, ordinal: ordinal, label: labels[ordinal], role: ordinal == 9 ? .commonRest : .working)

    case .sovietFiveDay:
      return SovietCalendarCycles.fiveDay(atJDN: jdn)
    case .sovietSixDay:
      return SovietCalendarCycles.sixDay(atJDN: jdn)
    }
  }
}

private enum SovietCalendarCycles {
  static let fiveDayStart = GregorianCalendar.toJDN(Y: 1929, M: 10, D: 1)
  static let fiveDayEnd = GregorianCalendar.toJDN(Y: 1931, M: 11, D: 30)
  static let fiveDayAnchor = GregorianCalendar.toJDN(Y: 1930, M: 1, D: 1)
  static let sixDayStart = GregorianCalendar.toJDN(Y: 1931, M: 12, D: 1)
  static let sixDayEnd = GregorianCalendar.toJDN(Y: 1940, M: 6, D: 26)
  static let groups: [CalendarCycleDay.RestGroup] = [.yellow, .pink, .red, .purple, .green]

  static func fiveDay(atJDN jdn: Int) -> CalendarCycleDay? {
    guard (fiveDayStart...fiveDayEnd).contains(jdn) else { return nil }
    let (year, month, day) = GregorianCalendar.toDate(J: jdn)
    if isNationalHoliday(year: year, month: month, day: day) {
      return CalendarCycleDay(cycle: .sovietFiveDay, ordinal: nil, label: "Public holiday", role: .publicHoliday)
    }
    let displacement = countedFiveDayDates(from: fiveDayAnchor, to: jdn)
    let ordinal = positiveCycleMod(3 + displacement, 5)
    let group = groups[ordinal]
    return CalendarCycleDay(cycle: .sovietFiveDay, ordinal: ordinal, label: group.rawValue.capitalized, role: .rotatingRest, restGroup: group)
  }

  static func sixDay(atJDN jdn: Int) -> CalendarCycleDay? {
    guard (sixDayStart...sixDayEnd).contains(jdn) else { return nil }
    let (year, month, day) = GregorianCalendar.toDate(J: jdn)
    let isHoliday = isNationalHoliday(year: year, month: month, day: day) || (year >= 1936 && month == 12 && day == 5)
    if day == 31 {
      return CalendarCycleDay(cycle: .sovietSixDay, ordinal: nil, label: isHoliday ? "Public holiday" : "Extra working day", role: isHoliday ? .publicHoliday : .outsideCycle)
    }
    let isMarchSubstitute = month == 3 && day == 1
    let ordinal = isMarchSubstitute ? 5 : (day - 1) % 6
    let commonRest = isMarchSubstitute || day % 6 == 0
    return CalendarCycleDay(
      cycle: .sovietSixDay,
      ordinal: ordinal,
      label: isHoliday ? "Public holiday" : (commonRest ? "Rest day" : "Day \(ordinal + 1)"),
      role: isHoliday ? .publicHoliday : (commonRest ? .commonRest : .working)
    )
  }

  static func countedFiveDayDates(from start: Int, to end: Int) -> Int {
    guard start != end else { return 0 }
    let step = end > start ? 1 : -1
    var count = 0
    var cursor = start
    while cursor != end {
      cursor += step
      let (year, month, day) = GregorianCalendar.toDate(J: cursor)
      if !isNationalHoliday(year: year, month: month, day: day) { count += step }
    }
    return count
  }

  static func isNationalHoliday(year: Int, month: Int, day: Int) -> Bool {
    guard (1929...1940).contains(year) else { return false }
    return (month == 1 && day == 22)
      || (month == 5 && (day == 1 || day == 2))
      || (month == 11 && (day == 7 || day == 8))
  }
}

private func positiveCycleMod(_ value: Int, _ modulus: Int) -> Int {
  let remainder = value % modulus
  return remainder >= 0 ? remainder : remainder + modulus
}
