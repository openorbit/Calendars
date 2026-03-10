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

fileprivate let romanMonths: [MonthSpec] = [
  MonthSpec(
    monthUID: "roman_republican:M01",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "Ianuarius"
        ],
        sources: nil
      )
    ]
  ),

  MonthSpec(
    monthUID: "roman_republican:M02",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "Februarius"
        ],
        sources: nil
      )
    ]
  ),

  MonthSpec(
    monthUID: "roman_republican:I1",
    intercalary: true,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "Mercedonius"
        ],
        sources: nil
      )
    ]
  ),


  MonthSpec(
    monthUID: "roman_republican:M03",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "Martius"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "roman_republican:M04",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "Aprilis"
        ],
        sources: nil
      ),

      // Nero renaming A.U.C. 818 = A.D. 65,
      // reverted on accession of Galba
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        validity: Validity(scope: "Roman Empire",
                           startJDN: JulianCalendar.toJDN(Y: 65, M: 1, D: 1),
                           endJDN: JulianCalendar.toJDN(Y: 68, M: 6, D: 8)),
        variants: [
          "la": "Neroneus"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "roman_republican:M05",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "Maius"
        ],
        sources: nil
      ),

      // Nero renaming A.U.C. 818 = A.D. 65
      // reverted on accession of Galba
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        validity: Validity(scope: "Roman Empire",
                           startJDN: JulianCalendar.toJDN(Y: 65, M: 1, D: 1),
                           endJDN: JulianCalendar.toJDN(Y: 68, M: 6, D: 8)),

        variants: [
          "la": "Claudius"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "roman_republican:M06",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "Iunius"
        ],
        sources: nil
      ),

      // Nero renaming A.U.C. 818 = A.D. 65, note name is same as september
      // in other renamings, reverted on accession of Galba.
      // As Galba's reigh started on 8 June, 68, we place this date here.
      // Renderer will most likely pick that June as Germanicus.
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        validity: Validity(scope: "Roman Empire",
                           startJDN: JulianCalendar.toJDN(Y: 65, M: 1, D: 1),
                           endJDN: JulianCalendar.toJDN(Y: 68, M: 6, D: 8)),
        variants: [
          "la": "Germanicus"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "roman_republican:M07",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "Quintilis"
        ],
        sources: nil
      ),

      // A.U.C. 710 = 44
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        validity: Validity(scope: "Roman Empire",
                           startJDN: JulianCalendar.toJDN(Y: -43, M: 1, D: 1),
                           endJDN: nil),
        variants: [
          "la": "Julius"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "roman_republican:M08",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "Sextilis"
        ],
        sources: nil
      ),

      // Renamed A.U.C. 746 = 8
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        validity: Validity(scope: "Roman Empire",
                           startJDN: JulianCalendar.toJDN(Y: 8, M: 1, D: 1),
                           endJDN: nil),
        variants: [
          "la": "Augustus"
        ],
        sources: nil
      ),
    ]
  ),
  MonthSpec(
    monthUID: "roman_republican:M09",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "September"
        ],
        sources: nil
      ),

      // Caligular renaming A.U.C. 790 = A.D. 37,
      // reverted on accession of Claudius
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        validity: Validity(scope: "Roman Empire",
                           startJDN: JulianCalendar.toJDN(Y: 37, M: 1, D: 1),
                           endJDN: JulianCalendar.toJDN(Y: 41, M: 1, D: 24)),

        variants: [
          "la": "Germanicus"
        ],
        sources: nil
      ),

      // Domitian renaming A.U.C. 836 = A.D. 83,
      // reverted on accession of Nerva
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        validity: Validity(scope: "Roman Empire",
                           startJDN: JulianCalendar.toJDN(Y: 83, M: 1, D: 1),
                           endJDN: JulianCalendar.toJDN(Y: 96, M: 9, D: 18)),
        variants: [
          "la": "Germanicus"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "roman_republican:M10",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "October"
        ],
        sources: nil
      ),

      // Domitian renaming A.U.C. 836 = A.D. 83
      // reverted on accession of Nerva
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        validity: Validity(scope: "Roman Empire",
                           startJDN: JulianCalendar.toJDN(Y: 83, M: 1, D: 1),
                           endJDN: JulianCalendar.toJDN(Y: 96, M: 9, D: 18)),
        variants: [
          "la": "Domitianus"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "roman_republican:M11",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "November"
        ],
        sources: nil
      )
    ]
  ),

  MonthSpec(
    monthUID: "roman_republican:I2",
    intercalary: true,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "Intercalaris I"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "roman_republican:I3",
    intercalary: true,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "Intercalaris II"
        ],
        sources: nil
      )
    ]
  ),

  MonthSpec(
    monthUID: "roman_republican:M12",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "la": "December"
        ],
        sources: nil
      )
    ]
  ),
]

public enum RomanMonth: UInt8, Sendable, Equatable, Comparable {
  case IAN
  case FEB
  case INT
  case MAR
  case APR
  case MAI
  case IUN
  case QUI
  case SEX
  case SEP
  case OCT
  case NOV
  case INT_I
  case INT_II
  case DEC

  package var slot: Int {
    Int(self.rawValue)
  }
  public static func < (lhs: RomanMonth, rhs: RomanMonth) -> Bool {
    lhs.slot < rhs.slot
  }

}



fileprivate let dayNamesJAD = [
  "Kalendae",
  "IV Non.", "III Non.", "Prid. Non.", "Nonae",
  "VIII Id.", "VII Id.", "VI Id.", "V Id.", "IV Id.", "III Id.", "Pred. Id.", "Idus",
  "XIX Kal.", "XVIII Kal.", "XVII Kal.", "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]
fileprivate let dayNamesF = [
  "Kalendae",
  "IV Non.", "III Non.", "Prid. Non.", "Nonae",
  "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]
fileprivate let dayNamesMMJO = [
  "Kalendae",
  "VI Non.", "IV Non.", "III Non.", "Prid. Non.", "Nonae",
  "VIII Id.", "VII Id.", "VI Id.", "V Id.", "IV Id.", "III Id.", "Pred. Ides", "Ides",
  "XVII Kal.", "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]
fileprivate let dayNamesAJSN = [
  "Kalendae",
  "IV Non.", "III Non.", "Prid. Non.", "Nonae",
  "VIII Id.", "VII Id.", "VI Id.", "V Id.", "IV Id.", "III Id.", "Pred. Id.", "Idus",
  "XVIII Kal.", "XVII Kal.", "XVI Kal.", "XV Kal.", "XIV Kal.", "XIII Kal.",
  "XII Kal.", "XI Kal.", "X Kal.", "IX Kal.", "VIII Kal.", "VII Kal.", "VI Kal.", "V Kal.",
  "IV Kal.", "III Kal.", "Prid. Kal."
]

public struct RomanDay : Sendable, Hashable, Equatable, Comparable {
  public let month: RomanMonth
  public let day: Int  // 1..31 (Kalends=1, Nones=5/7, Ides=13/15 if you ever want those names)

  // Lexicographic ordering: first by month slot, then by day.
  public static func < (lhs: RomanDay, rhs: RomanDay) -> Bool {
    if lhs.month.slot != rhs.month.slot {
      return lhs.month.slot < rhs.month.slot
    }
    return lhs.day < rhs.day
  }
}

public struct RomanDate : Sendable, Hashable, Equatable, Comparable {
  public let year: Int
  public let month: RomanMonth
  public let day: Int  // 1..31 (Kalends=1, Nones=5/7, Ides=13/15 if you ever want those names)

  public var jdn: Int {
    get {
      RomanCalendar.shared.jdn(forYear: year, month: month.slot, day: day)
    }
  }
  // Total order: year, then month slot, then day.
  public static func < (lhs: RomanDate, rhs: RomanDate) -> Bool {
    lhs.jdn < rhs.jdn
  }
}


enum RomanCalendarFactory {
  static func make() -> TableCalendar {
    // Pseudocode placeholders — wire these to your Bennett-derived data
    let years: [YearAnchor] = RomanTables.anchors  // sorted by AUC
    let months: [MonthRow]  = RomanTables.months   // grouped by AUC ranges
    let reverse: [Range<Int>]  = RomanTables.reverse   // grouped by AUC ranges
    return TableCalendar(years: years, months: months, reverse: reverse)
  }
}

public struct RomanCalendar : CalendarProtocol {
  public static let shared = RomanCalendar(identifier: .romanRepublican, calendarKey: "roman_republican")

  public var identifier: CalendarId

  public var calendarKey: String

  public func jdn(forYear year: Int, month: Int, day: Int) -> Int {
    // Check regime first to avoid table lookup crash
    if 813 < year {
       let tc = TableDateComponents(year: year, month: month, day: day)
       if let jdn = RomanCalendar.table.jdn(from: tc) {
           return jdn
       }
       
       // Fallback for years outside table
       // Assuming input year is AUC.
       // Convert AUC to Julian Year: AUC 1 = 753 BC (-752).
       // Julian Year = AUC - 753.
       // Example: AUC 754 = AD 1. (754 - 753 = 1).
       // Example: AUC 2025 = AD 1272. (2025 - 753 = 1272).
       return JulianCalendar.toJDN(Y: year - 753, M: month, D: day)
    }
    
    // Original logic was just:
    let tc = TableDateComponents(year: year, month: month, day: day)
    if let result = RomanCalendar.table.jdn(from: tc) {
        return result
    }
    
    // Fallback if table lookup failed
    return JulianCalendar.toJDN(Y: year - 753, M: month, D: day)
  }

  // 24-year cycle of year lengths (days)
  private static let extrapolationCycle = [
    355, 377, 355, 378,
    355, 377, 355, 378,
    355, 377, 355, 378,
    355, 377, 355, 378,
    355, 377, 355, 377,
    355, 377, 355, 355
  ]
  private static let table = RomanCalendarFactory.make()
  private static let averageCycleLength = 365.25 * 24 
  // Anchor: May 1, 491 AUC.
  // We need the JDN for this date.
  // Since we can't call instance methods easily in static context, we'll execute it at runtime or hardcode if known.
  // Using a computed property for safety.
  private var anchorJDN: Int {
      // 491-05-01 is within our table range.
      // TableDateComponents assumes month indices 1..12 + intercalaries.
      // Maius is Month 5.
      // We rely on the table being present.
      let tc = TableDateComponents(year: 491, month: 5, day: 1)
      return RomanCalendar.table.jdn(from: tc) ?? 1625460 + 120 // Fallback estimate if table fails (approx)
  }

  // Helper to get day lengths for a specific year in the cycle (0-23)
  // Years start on May 1.
  // 355: Mai(31), Iun(29), Qui(31), Sex(29), Sep(29), Oct(31), Nov(29), Dec(29), Ian(29), Feb(28), Mar(31), Apr(29)
  // 377: ... Feb(23), Int(27), Mar(31), Apr(29) -> Total 377. (23+27=50. Normal 28. +22).
  // 378: ... Feb(24), Int(27), Mar(31), Apr(29) -> Total 378. (24+27=51. Normal 28. +23).
  private func extrapolatedMonthLengths(cycleIndex: Int) -> [(length: Int, month: RomanMonth)] {
      let yearLen = RomanCalendar.extrapolationCycle[cycleIndex]
      // Common months
      let common: [(Int, RomanMonth)] = [
        (31, .MAI), (29, .IUN), (31, .QUI), (29, .SEX), (29, .SEP), (31, .OCT), (29, .NOV), (29, .DEC), (29, .IAN)
      ]
      let tail: [(Int, RomanMonth)] = [(31, .MAR), (29, .APR)]
      
      if yearLen == 355 {
          return common + [(28, .FEB)] + tail
      } else if yearLen == 377 {
          return common + [(23, .FEB), (27, .INT)] + tail
      } else { // 378
          return common + [(24, .FEB), (27, .INT)] + tail
      }
  }

  public func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth] {
    switch regime(forYear: year) {
    case .extrapolated:
      // Backward extrapolation from 491
      // Calculate cycle index for this year.
      // The cycle repeats every 24 years ending at 490 (inclusive).
      // 490 is index 23?
      // Let's align: 
      // 491 is the start of a new regime. Use 490 as the end of the last cycle.
      // Distance backwards from 491: delta = 491 - year.
      // Cycle index = (24 - (delta % 24)) % 24?
      // Let's assume the cycle as printed ends at 490.
      // So 490 is year 23 of the cycle. 489 is year 22.
      // 490 - y = 0 -> index 23.
      // Index = (23 - ((490 - year) % 24))
      
      let delta = 490 - year
      // Ensure positive
      let cycleIndex = (23 - (delta % 24) + 24) % 24
      
      var result: [ResolvedMonth] = []
      let specs = extrapolatedMonthLengths(cycleIndex: cycleIndex)
      
      for (i, (d, m)) in zip(1...specs.count, specs) {
          result.append(ResolvedMonth(spec: romanMonths[m.slot],
                                      index: i, mode: .civil,
                                      firstDay: 1, length: d))
      }
      return result

    case .reconstructed:
      let months = RomanCalendar.table.monthRows(forYear: year)

      var result: [ResolvedMonth] = []
      
      // Check for leading fragment (Month 0)
      if let anchor = RomanCalendar.table.anchor(forYear: year), let frag = anchor.leadingFragment {
          result.append(ResolvedMonth(spec: romanMonths[frag.monthInfoIndex],
                                      index: 0, mode: mode,
                                      firstDay: frag.startDay, length: frag.length))
      }

      for (i, month) in zip(1...months.count, months) {
        result.append(ResolvedMonth(spec: romanMonths[month.monthInfoIndex],
                                    index: i, mode: mode,
                                    firstDay: 1, length: month.length))
      }

      return result
    case .ruleBased:
      
      var result: [ResolvedMonth] = []

      for (i, (d, m)) in zip(1...12, [(31, RomanMonth.IAN), (28, RomanMonth.FEB), (31, RomanMonth.MAR), (30, RomanMonth.APR), (31, RomanMonth.MAI), (30, RomanMonth.IUN), (31, RomanMonth.QUI), (31, RomanMonth.SEX), (30, RomanMonth.SEP), (31, RomanMonth.OCT), (30, RomanMonth.NOV), (31, RomanMonth.DEC)]) {

        // We are one year out of phase with Julian year counting.
        if m == .FEB && (year + 1) % 4 == 0 {
          result.append(ResolvedMonth(spec: romanMonths[m.slot],
                                      index: i, mode: .civil,
                                      firstDay: 1, length: d + 1))

        } else {
          result.append(ResolvedMonth(spec: romanMonths[m.slot],
                                      index: i, mode: .civil,
                                      firstDay: 1, length: d))
        }
      }

      return result
    }
  }

  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    return true
  }
  public func monthName(forYear year: Int, month: Int) -> String {
    let list = months(forYear: year, mode: .civil)
    guard let m = list.first(where: { $0.index == month }) else { return "Unknown" }
    return m.spec.names[0].variants["la"] ?? "Unknown"
  }
  public func daysInMonth(year: Int, month: Int) -> Int {
    let list = months(forYear: year, mode: .civil)
    guard let m = list.first(where: { $0.index == month }) else { return 0 }
    return m.length
  }

  public func startOfYearJDN(year: Int) -> Int? {
    switch regime(forYear: year) {
    case .reconstructed:
      guard let anchor = RomanCalendar.table.anchor(forYear: year) else {
        return nil
      }
      return anchor.yearStartJDN
    case .extrapolated, .ruleBased:
      let months = months(forYear: year, mode: .civil).sorted { $0.index < $1.index }
      guard let first = months.first else {
        return nil
      }
      return jdn(forYear: year, month: first.index, day: first.firstDay)
    }
  }

  public func endOfYearJDN(year: Int) -> Int? {
    switch regime(forYear: year) {
    case .reconstructed:
      guard let anchor = RomanCalendar.table.anchor(forYear: year) else {
        return nil
      }
      // Table anchors store end as an exclusive bound.
      return anchor.yearEndJDN - 1
    case .extrapolated, .ruleBased:
      let months = months(forYear: year, mode: .civil).sorted { $0.index < $1.index }
      guard let last = months.last else {
        return nil
      }
      let lastDay = last.firstDay + last.length - 1
      return jdn(forYear: year, month: last.index, day: lastDay)
    }
  }

  public func isProleptic(julianDay jdn: Int) -> Bool {
    // If before our tables start, yes.
    // Table starts at 491.
    // Actually JDN check is better.
    // Let's assume JDN < AnchorJDN is extrapolated.
    return false // Placeholder
  }
  public func monthNumber(for month: String, in year: Int) -> Int? { return nil }


  // Forward
  public func jdn(from c: CalendarDateComponents) -> Int? {
    guard c.calendar.id == .romanRepublican,
          c.yearMode == .civil,
          let m = c.month, let d = c.day else {
      return nil
    }

    // Before AUC 491
    if c.year < 491 {
        // Find JDN of Mai 1, 491
        guard let anchor = RomanCalendar.table.jdn(from: TableDateComponents(year: 491, month: 5, day: 1)) else { return nil }
        
        // Days to subtract
        var daysToSubtract = 0
        
        // Full years between c.year and 491
        // Range: [c.year, 490]
        for y in c.year..<491 {
            let delta = 490 - y
            let cycleIndex = (23 - (delta % 24) + 24) % 24
            daysToSubtract += RomanCalendar.extrapolationCycle[cycleIndex]
        }
        
        // Now we are at Mai 1 of c.year.
        // We need to add days within the year.
        // Months for this year:
        let ms = months(forYear: c.year, mode: .civil)
        // Find index of target month 'm' in the list...
        // Wait, 'm' is the index (1..12/13).
        // But in extrapolated mode, months are ordered Mai..Apr.
        // If user passes month index 1, is it Jan? Or the 1st month of the year (Mai)?
        // CalendarProtocol usually assumes month 1 is the first month in the .months() list.
        // So m=1 -> Maius.
        
        // Sum days from start of year to target month
        var dayOffset = 0
        for i in 1..<m {
            if let mon = ms.first(where: { $0.index == i }) {
                dayOffset += mon.length
            }
        }
        dayOffset += (d - 1)
        
        // JDN = (Anchor - TotalYears) + DayOffset?
        // No.
        // Anchor is Start of 491.
        // Start of c.year = Anchor - DaysToSubtract.
        // Target = Start of c.year + DayOffset.
        
        return (anchor - daysToSubtract) + dayOffset
    } else if 813 < c.year {
      // After AUC 813 = CE 60, we resort to Julian
      return JulianCalendar.toJDN(Y: c.year - (813 - 60), M: m, D: d)
    }


    return jdn(forYear: c.year, month: m, day: d)
  }

  // Inverse
  public func date(fromJDN jdn: Int) -> CalendarDateComponents? {
    // 1. Try Table Lookup first (Covers 491 Jan 1 onwards)
    if let tc = RomanCalendar.table.components(containing: jdn) {
        return CalendarDateComponents(calendar: .romanRepublican,
                                      yearMode: .civil,
                                      year: tc.year,
                                      month: tc.month,
                                      day: tc.day)
    }
    
    // 2. Check for Extrapolation (Before Table)
    // Anchor JDN check (Start of Extrapolation Baseline - May 1, 491)
    let anchor = RomanCalendar.table.jdn(from: TableDateComponents(year: 491, month: 5, day: 1)) ?? 1625460
    
    if jdn < anchor {
      // Backward Extrapolation
      // Iterate backward years until we find the start of the year <= jdn
      // ...
          
          var currentStart = anchor
          var year = 491
          
          // Loop backward until currentStart is <= jdn
          // Actually, currentStart is Start of Year 'year'.
          // We want to find Year Y such that Start(Y) <= jdn < Start(Y+1).
          // We are moving backwards.
          // Start(491) > jdn.
          // Start(490) = Start(491) - Length(490).
          
          while currentStart > jdn {
              year -= 1
              let delta = 490 - year
              let cycleIndex = (23 - (delta % 24) + 24) % 24
              let len = RomanCalendar.extrapolationCycle[cycleIndex]
              currentStart -= len
          }
          
          // Now currentStart <= jdn. 'year' is the candidate.
          let dayOffset = jdn - currentStart
          
          // Find month
          let ms = months(forYear: year, mode: .civil)
          var d = dayOffset
          var mIndex = 1
          for mon in ms {
              if d < mon.length {
                  return CalendarDateComponents(calendar: .romanRepublican, yearMode: .civil, year: year, month: mon.index, day: d + 1)
              }
              d -= mon.length
              mIndex += 1
          }
          return nil // Should not reach here
          
      } else if jdn >= 1743339 {
      // After our tables
      let (y, m, d) = JulianCalendar.toDate(J: jdn)
      return CalendarDateComponents(calendar: .romanRepublican,
                                    yearMode: .civil,
                                    year: y + (813 - 60),
                                    month: m,
                                    day: d)
    }
    let tc = RomanCalendar.table.components(containing: jdn)
    guard let tc else { return nil }
    return CalendarDateComponents(calendar: .romanRepublican,
                                  yearMode: .civil,
                                  year: tc.year,
                                  month: tc.month,
                                  day: tc.day)
  }

  public func regime(forYear year: Int) -> CalendarRegime {
    if year < 491 {
      return .extrapolated
    } else if 813 < year {
      return .ruleBased
    } else {
      return .reconstructed
    }
  }
  public func formattedDayName(year: Int, month: Int, day: Int) -> String {
      // 1. Resolve proper month spec/length from engine
      let ms = months(forYear: year, mode: .civil)
      guard let resolvedMonth = ms.first(where: { $0.index == month }) else { return "\(day)" }
      
      let m = resolvedMonth.spec.names[0].variants["la"] ?? "Unknown"
      
      // Determine which table to use
      // MMJO: Mar, Mai, Qui, Oct -> Ides on 15th. 31 days.
      // JAD: Ian, Sex, Dec -> Ides on 13th. 31 days.
      // AJSN: Apr, Iun, Sep, Nov -> Ides on 13th. 30 days.
      // Feb: 28 days (Civil).
      
      // We need to map 'RomanMonth' from the spec to our table logic
      // Since we don't have direct access to 'RomanMonth' enum easily from ResolvedMonth without parsing UID or casting,
      // we can infer from properties or use a helper if we exposed 'monthEnum' on ResolvedMonth.
      // But ResolvedMonth.spec.monthUID is "roman_republican:M01" etc.
      
      let uid = resolvedMonth.spec.monthUID
      let suffix = uid.split(separator: ":").last ?? ""
      
      var names: [String] = []
      
      // Map UID to array
      switch suffix {
      case "M03", "M05", "M07", "M10": // Mar, Mai, Qui, Oct
          names = dayNamesMMJO
      case "M01", "M08", "M12": // Ian, Sex, Dec
          names = dayNamesJAD
      case "M04", "M06", "M09", "M11": // Apr, Iun, Sep, Nov
          names = dayNamesAJSN
      case "M02": // Feb
          // Check for Leap/Intercalary adjustments
          // If length is 28, use dayNamesF.
          // If length is 29 (Julian Leap), we insert "bis VI Kal."? AD 2025 style logic?
          // If length is 23/24 (Pre-Julian), we truncate?
          if resolvedMonth.length == 28 {
              names = dayNamesF
          } else if resolvedMonth.length == 29 {
             // Julian Leap Year: "bis VI Kal." inserted after VI Kal (Day 24).
             // Day 24 = VI Kal.
             // Day 25 = bis VI Kal.
             // Day 26 = V Kal...
             // Let's just use dayNamesF and handle the 'bis' manually or fallback.
             names = dayNamesF 
             // Logic below needs to handle index mapping for 29 days.
          } else {
             // 23 or 24 days.
             names = dayNamesF
          }
      case "I1", "I2", "I3": // Intercalaries (27 days usually)
          // Intercalaris I/II (Mercedonius).
          // Nones 5, Ides 13.
          // Length 27.
          // Similar to AJSN but shorter?
          // Let's fallback to number if we don't have a table, or use AJSN and truncate?
          // Array AJSN is 30 items.
          names = dayNamesAJSN 
      default:
          return "\(day)"
      }
      
      // Indexing logic
      var name = ""
      if day > 0 && day <= names.count {
          // Normal lookup
          // Handle Leap Year "bis VI Kal." for Feb 29
          if suffix == "M02" && resolvedMonth.length == 29 {
              // daysF has 28 items.
              // 1..23 match daysF[0..22]
              // 24 -> VI Kal. (daysF[23] is "VI Kal.")
              // 25 -> bis VI Kal.
              // 26 -> V Kal. (daysF[24])
              // ...
              // 29 -> Prid. Kal. (daysF[27])
              
              if day < 24 {
                  name = names[day - 1]
              } else if day == 24 {
                  name = "VI Kal."
              } else if day == 25 {
                  name = "bis VI Kal."
              } else {
                  // day 26 (V) -> index 24 (V) = day-2?
                  // day 29 (Prid) -> index 27 (Prid) = day-2.
                  name = names[day - 2]
              }
          } else {
              // Ensure we don't crash if month is shorter than array (e.g. Feb 23)
               if day - 1 < names.count {
                  name = names[day - 1]
               } else {
                  name = "\(day)"
               }
          }
      } else {
          name = "\(day)"
      }
      
      // Suffix Logic (Next Month)
      // If name contains "Kal." or "Prid." (unless it is Kalendae)
      if (name.contains("Kal.") && name != "Kalendae") || name.contains("Prid. Kal.") {
          // Find next month name
          var nextM = month + 1
          var nextY = year
          if nextM > 12 { // Assuming 12 months for visual... but Roman has 12/13.
              // Engine.months returns list.
              // We need the next month in the list, or first of next year?
          }
          
          // Better: ask engine for months of this year, find current, get next.
          // If current is last, ask for months of next year, get first.
          
          var nextMonthName = ""
          
          if let idx = ms.firstIndex(where: { $0.index == month }) {
              if idx < ms.count - 1 {
                  let nm = ms[idx + 1]
                  nextMonthName = nm.spec.names[0].variants["la"] ?? ""
                  // Shorten? "Februarius" -> "Feb."
                  // Simple truncation for now: 3 chars?
                  nextMonthName = String(nextMonthName.prefix(3)) + "."
              } else {
                  // Next year
                  let nextMs = months(forYear: year + 1, mode: .civil)
                  if let nm = nextMs.first {
                      nextMonthName = nm.spec.names[0].variants["la"] ?? ""
                      nextMonthName = String(nextMonthName.prefix(3)) + "."
                  }
              }
          }
          
          if !nextMonthName.isEmpty {
              return "\(name) \(nextMonthName)"
          }
      }
      
      return name
  }
}
