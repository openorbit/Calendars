//
// SPDX-License-Identifier: Apache-2.0
//

/// The precision explicitly present in a historical date expression.
public enum HistoricalDatePrecision: String, Codable, Sendable, Hashable {
  case year
  case month
  case day
  case interval
  case unknown
}

/// A qualification applied to the projected interval.
public enum HistoricalDateQualifier: String, Codable, Sendable, Hashable {
  case exact
  case about
  case calculated
  case estimated
  case before
  case after
  case between
  case from
  case unknown
}

/// Serializable historical components. These remain authoritative when a JDN
/// projection is recalculated after calendar algorithms or tables change.
public struct HistoricalDateComponents: Codable, Sendable, Hashable {
  public let calendarID: CalendarId
  public let yearMode: YearMode
  public let year: Int
  public let month: Int?
  public let day: Int?
  public let regime: CalendarRegime

  public init(
    calendarID: CalendarId,
    yearMode: YearMode = .civil,
    year: Int,
    month: Int? = nil,
    day: Int? = nil,
    regime: CalendarRegime = .ruleBased
  ) {
    self.calendarID = calendarID
    self.yearMode = yearMode
    self.year = year
    self.month = month
    self.day = day
    self.regime = regime
  }

  public var precision: HistoricalDatePrecision {
    if day != nil { return .day }
    if month != nil { return .month }
    return .year
  }

  /// Expands the stated precision to inclusive absolute-day bounds.
  public func projectedJDNBounds() -> JulianDayInterval? {
    let engine = CalendarRegistry.shared.calendar(for: calendarID)
    guard let engine else { return nil }

    if let day, let month {
      guard engine.isValidDate(year: year, month: month, day: day) else { return nil }
      let jdn = engine.jdn(forYear: year, month: month, day: day)
      return JulianDayInterval(beginJDN: jdn, endJDN: jdn)
    }

    if let month {
      let days = engine.daysInMonth(year: year, month: month)
      guard days > 0,
            engine.isValidDate(year: year, month: month, day: 1),
            engine.isValidDate(year: year, month: month, day: days) else { return nil }
      return JulianDayInterval(
        beginJDN: engine.jdn(forYear: year, month: month, day: 1),
        endJDN: engine.jdn(forYear: year, month: month, day: days)
      )
    }

    let months = engine.months(forYear: year, mode: yearMode)
    guard let first = months.first, let last = months.last,
          engine.isValidDate(year: year, month: first.index, day: 1),
          engine.isValidDate(year: year, month: last.index, day: last.length) else { return nil }
    return JulianDayInterval(
      beginJDN: engine.jdn(forYear: year, month: first.index, day: 1),
      endJDN: engine.jdn(forYear: year, month: last.index, day: last.length)
    )
  }
}

/// Inclusive JDN bounds. A nil bound represents an open-ended interval.
public struct JulianDayInterval: Codable, Sendable, Hashable {
  public let beginJDN: Int?
  public let endJDN: Int?

  public init(beginJDN: Int?, endJDN: Int?) {
    if let beginJDN, let endJDN {
      precondition(beginJDN <= endJDN)
    }
    self.beginJDN = beginJDN
    self.endJDN = endJDN
  }

  public func overlaps(_ other: JulianDayInterval) -> Bool {
    let beginsBeforeOtherEnds = beginJDN.flatMap { begin in
      other.endJDN.map { begin <= $0 }
    } ?? true
    let otherBeginsBeforeEnd = other.beginJDN.flatMap { begin in
      endJDN.map { begin <= $0 }
    } ?? true
    return beginsBeforeOtherEnds && otherBeginsBeforeEnd
  }

  public func intersection(with other: JulianDayInterval) -> JulianDayInterval? {
    let begin = [beginJDN, other.beginJDN].compactMap { $0 }.max()
    let end = [endJDN, other.endJDN].compactMap { $0 }.min()
    if let begin, let end, begin > end { return nil }
    return JulianDayInterval(beginJDN: begin, endJDN: end)
  }
}

/// A lossless historical expression together with its materialized absolute-day projection.
public struct HistoricalDateInterval: Codable, Sendable, Hashable {
  public static let currentProjectionVersion = 1

  public let begin: HistoricalDateComponents?
  public let end: HistoricalDateComponents?
  public let beginJDN: Int?
  public let endJDN: Int?
  public let precision: HistoricalDatePrecision
  public let qualifier: HistoricalDateQualifier
  public let projectionVersion: Int

  public init(
    begin: HistoricalDateComponents?,
    end: HistoricalDateComponents? = nil,
    qualifier: HistoricalDateQualifier = .exact,
    projectionVersion: Int = Self.currentProjectionVersion
  ) {
    self.begin = begin
    self.end = end
    self.qualifier = qualifier
    self.projectionVersion = projectionVersion

    let beginProjection = begin?.projectedJDNBounds()
    let endProjection = end?.projectedJDNBounds()
    let statedPrecision = end == nil ? (begin?.precision ?? .unknown) : .interval
    precision = statedPrecision

    switch qualifier {
    case .before:
      beginJDN = nil
      endJDN = beginProjection?.beginJDN.map { $0 - 1 }
    case .after:
      beginJDN = beginProjection?.endJDN.map { $0 + 1 }
      endJDN = nil
    default:
      beginJDN = beginProjection?.beginJDN
      endJDN = endProjection?.endJDN ?? beginProjection?.endJDN
    }
  }

  public var jdnInterval: JulianDayInterval {
    JulianDayInterval(beginJDN: beginJDN, endJDN: endJDN)
  }
}
