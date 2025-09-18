//
//  TabularCalendar.swift
//  Calendars
//
//  Created by Mattias Holm on 2025-09-13.
//

/// Anchor for one civil year in a table-driven calendar
public struct YearAnchor: Sendable {
  public let year: Int                 // AUC, regnal year, etc.
  public let yearStartJDN: Int         // Absolute first day of this year
  public let yearEndJDN: Int           // Absolute day of next year day of this year
  public let monthRows: Range<Int>     // Slice into `months` for this year

  /// Optional leading fragment when a year starts mid-month (e.g., Mar 15  - Mar 31)
  /// length == number of days in the fragment; canonicalMonth is useful for display
  public let leadingFragment: LeadingFragment?
  
  public struct LeadingFragment : Sendable {
    let monthInfoIndex: Int // points into the same MonthInfo bank as MonthRow
    let startDay: Int       // e.g. 15 for March 15
    let length: Int         // e.g. 17
  }
}

public struct MonthRow: Sendable {
  public let year: Int
  public let appearanceMonth: Int
  public let offsetFromYearStart: Int
  public let length: Int
  public let isIntercalary: Bool
  public let monthInfoIndex: Int // Metadata index
}

/// Generic YMD-like components for table calendars
public struct TableDateComponents: Sendable {
    public let year: Int                  // The civil-year (e.g AUC for Rome)
    /// Appearance-based month:
    ///  - 0 = leading fragment (if present)
    ///  - 1..N = full months in appearance order
    public var month: Int
    public var day: Int                  // 1-based
}


public struct ReverseIndex : Sendable {
  public let auc: Int
  public let month: RomanMonth
  public let jdn: Int
  public let days: Int
  public let notes: [String] = []
}

public struct TableCalendar: Sendable {
  public let years: [YearAnchor]  // Sorted by year
  public let months: [MonthRow]   // Grouped per year, ranges referenced by anchors
  public let reverse: [Range<Int>] // Reverse mappings

  public init(years: [YearAnchor], months: [MonthRow], reverse: [Range<Int>]) {
    self.years = years
    self.months = months
    self.reverse = reverse
  }


  public func jdn(from c: TableDateComponents) -> Int? {
    let yearIndex = c.year - years.first!.year
    guard years.indices.contains(yearIndex) else {
      return nil
    }

    let year = years[yearIndex]
    // Leading fragment, this is when years start in the middle of the month?
    if c.month == 0 {
      guard let frag = year.leadingFragment, (1...frag.length).contains(c.day) else { return nil }
      return year.yearStartJDN + (c.day - 1)
    }

    // Regular appearance months
    let base = year.monthRows.lowerBound
    let idx = base + (c.month - 1)
    guard year.monthRows.contains(idx), idx < months.count else { return nil }
    let m = months[idx]
    guard m.year == c.year, (1...m.length).contains(c.day) else { return nil }
    return year.yearStartJDN + m.offsetFromYearStart + (c.day - 1)
  }

  public func components(containing jdn: Int) -> TableDateComponents? {
    let reverseIndex = (jdn - years.first!.yearStartJDN) / 32
    guard 0 <= reverseIndex && reverseIndex < reverse.count else {
      return nil
    }

    let monthRange = months[reverse[reverseIndex]]
    // Iterate over the year to find the matching month
    for m in monthRange {
      let y = years[m.year - years[0].year]
      let mjdn = y.yearStartJDN + m.offsetFromYearStart

      if mjdn <= jdn && jdn < mjdn + m.length {
        // We have the correct month, but it may be outside the year and belong to the next
        // because the next year started in the middle of the month.
        if jdn < y.yearEndJDN {
          return TableDateComponents(year: m.year, month: m.appearanceMonth, day: jdn - mjdn + 1)
        }
        let nextYearIndex = m.year - years[0].year + 1
        guard nextYearIndex < years.count else {
          return nil
        }
        let nextYear = years[nextYearIndex]
        guard let leadingFragment = nextYear.leadingFragment else {
          return nil
        }

        return TableDateComponents(year: nextYear.year, month: 0,
                                   day: jdn - mjdn + 1 - leadingFragment.startDay + 1)
      }
    }
    return nil
  }

  func anchor(forYear year: Int) -> YearAnchor? {
    let yearIndex = year - years.first!.year
    guard years.indices.contains(yearIndex) else {
      return nil
    }

    return years[yearIndex]
  }

  func monthRows(forYear year: Int) -> [MonthRow] {
    guard let anchor = anchor(forYear: year) else {
      return []
    }

    return Array<MonthRow>(months[anchor.monthRows])
  }
}
