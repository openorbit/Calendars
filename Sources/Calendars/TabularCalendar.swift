//
// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2025 Mattias Holm
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

/// Anchor for one civil year in a table-driven calendar
package struct YearAnchor: Sendable {
  package let year: Int                 // AUC, regnal year, etc.
  package let yearStartJDN: Int         // Absolute first day of this year
  package var yearEndJDN: Int           // Absolute day of next year day of this year
  package let monthRows: Range<Int>     // Slice into `months` for this year

  /// Optional leading fragment when a year starts mid-month (e.g., Mar 15  - Mar 31)
  /// length == number of days in the fragment; canonicalMonth is useful for display
  package let leadingFragment: LeadingFragment?

  package struct LeadingFragment : Sendable {
    package let monthInfoIndex: Int // points into the same MonthInfo bank as MonthRow
    package let startDay: Int       // e.g. 15 for March 15
    package let length: Int         // e.g. 17

    package init(monthInfoIndex: Int, startDay: Int, length: Int) {
      self.monthInfoIndex = monthInfoIndex
      self.startDay = startDay
      self.length = length
    }
  }

  package init(year: Int, yearStartJDN: Int, yearEndJDN: Int, monthRows: Range<Int>, leadingFragment: LeadingFragment?) {
    self.year = year
    self.yearStartJDN = yearStartJDN
    self.yearEndJDN = yearEndJDN
    self.monthRows = monthRows
    self.leadingFragment = leadingFragment
  }
}

package struct MonthRow: Sendable {
  package let year: Int
  package let appearanceMonth: Int
  package let offsetFromYearStart: Int
  package let length: Int
  package let isIntercalary: Bool
  package let monthInfoIndex: Int // Metadata index

  package init(year: Int, appearanceMonth: Int, offsetFromYearStart: Int, length: Int, isIntercalary: Bool, monthInfoIndex: Int) {
    self.year = year
    self.appearanceMonth = appearanceMonth
    self.offsetFromYearStart = offsetFromYearStart
    self.length = length
    self.isIntercalary = isIntercalary
    self.monthInfoIndex = monthInfoIndex
  }
}

/// Generic YMD-like components for table calendars
struct TableDateComponents: Sendable {
  let year: Int                  // The civil-year (e.g AUC for Rome)
  /// Appearance-based month:
  ///  - 0 = leading fragment (if present)
  ///  - 1..N = full months in appearance order
  var month: Int
  var day: Int                  // 1-based
}

struct ReverseIndex : Sendable {
  let auc: Int
  let month: RomanMonth
  let jdn: Int
  let days: Int
  let notes: [String] = []
}

package struct TableCalendar: Sendable {
  package let years: [YearAnchor]  // Sorted by year
  package let months: [MonthRow]   // Grouped per year, ranges referenced by anchors
  package let reverse: [Range<Int>] // Reverse mappings

  package init(years: [YearAnchor], months: [MonthRow], reverse: [Range<Int>]) {
    self.years = years
    self.months = months
    self.reverse = reverse
  }

  func jdn(from c: TableDateComponents) -> Int? {
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

  func components(containing jdn: Int) -> TableDateComponents? {
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
