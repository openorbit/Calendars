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
          "en": "December"
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

  var slot: Int {
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
    let tc = TableDateComponents(year: year, month: month, day: day)
    return RomanCalendar.table.jdn(from: tc)!
  }

  private static let table = RomanCalendarFactory.make()

  public func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth] {
    let months = RomanCalendar.table.monthRows(forYear: year)

    var result: [ResolvedMonth] = []
    for (i, month) in zip(1...months.count, months) {
      result.append(ResolvedMonth(spec: romanMonths[month.monthInfoIndex],
                                  index: i, mode: mode,
                                  firstDay: 1, length: month.length))
    }

    return result
  }

  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    return true
  }
  public func monthName(forYear year: Int, month: Int) -> String {
    let months = RomanCalendar.table.monthRows(forYear: year)
    return romanMonths[months[month - 1].monthInfoIndex].names[0].variants["la"]!
  }
  public func daysInMonth(year: Int, month: Int) -> Int {
    let months = RomanCalendar.table.monthRows(forYear: year)

    return months[month-1].length
  }

  public func isProleptic(julianDay jdn: Int) -> Bool {
    return false
  }
  public func monthNumber(for month: String, in year: Int) -> Int? { return nil }


  // Forward
  public func jdn(from c: CalendarDateComponents) -> Int? {
    guard c.calendar.id == .romanRepublican,
          c.yearMode == .civil,
          let m = c.month, let d = c.day else {
      return nil
    }
    return jdn(forYear: c.year, month: m, day: d)
  }

  // Inverse
  public func date(fromJDN jdn: Int) -> CalendarDateComponents? {
    let tc = RomanCalendar.table.components(containing: jdn)
    guard let tc else { return nil }
    return CalendarDateComponents(calendar: CalendarInfo(id: .romanRepublican, engine: self),
                                  yearMode: .civil,
                                  year: tc.year,
                                  month: tc.month,
                                  day: tc.day)
  }
}
