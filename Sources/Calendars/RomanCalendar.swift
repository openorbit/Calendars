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


public struct RomanMonthInfo : Sendable {
  public let month: RomanMonth
  public let jdn: Int
  public let days: Int
  public let notes: [String] = []
}

public struct RomanYear : Sendable {
  public let auc: Int
  public let consularYearStart: RomanDay  // <-- day-aware

  public let months: InlineArray<15, RomanMonthInfo?>
  public let days: Int
  public let nundialPhase: Character
  public let nundialPhaseAfterIntercalation: Character?

  public let notes: [String]
}

public struct RomanForwardIndex : Sendable {
  fileprivate let years: [RomanYear]
  fileprivate let earliestJDN: Int
  fileprivate let lastJDN: Int

  fileprivate let earliestDate: RomanDate
  fileprivate let lastDate: RomanDate
  public init(years: [RomanYear]) {
    self.years = years

    self.earliestJDN = years[0].months[0]!.jdn
    self.lastJDN = years.last!.months[14]!.jdn + 31 - 1

    self.earliestDate = RomanDate(year: years[0].auc, month: .IAN, day: 1)
    self.lastDate = RomanDate(year: years.last!.auc, month: .DEC, day: 31)
  }

  fileprivate func yearInfoFor(date: RomanDate) -> RomanYear? {
    guard (date.year > earliestDate.year || (date.year == earliestDate.year && date.month < .MAI)) else {
      return nil
    }
    guard (date.year <= lastDate.year) else {
      return nil
    }
    let romanDay = RomanDay(month: date.month, day: date.day)

    let romanYear =
    if years[date.year -  earliestDate.year].consularYearStart != RomanDay(month: .IAN, day: 1) &&
        romanDay >= years[date.year -  earliestDate.year].consularYearStart {
      // We need to look in the previous year
      years[date.year -  earliestDate.year - 1]
    } else {
      years[date.year -  earliestDate.year]
    }

    return romanYear
  }
  /// Core lookup: (AUC, RomanMonth, day) -> JulianDate
  public func romanToJulian(auc: Int, month: RomanMonth, day: Int) -> JulianDate {
    precondition(auc > earliestDate.year || (auc == earliestDate.year && month < .MAI))
    precondition(auc <= lastDate.year)

    let romanDay = RomanDay(month: month, day: day)

    let romanYear =
    if years[auc -  earliestDate.year].consularYearStart != RomanDay(month: .IAN, day: 1) &&
        romanDay >= years[auc -  earliestDate.year].consularYearStart {
      // We need to look in the previous year
      years[auc -  earliestDate.year - 1]
    } else {
      years[auc -  earliestDate.year]
    }

    guard let month = romanYear.months[month.slot] else {
      // Invalid date
      fatalError("Invalid date")
    }
    let julianDate = JulianDate(jdn: month.jdn + day - 1)
    return julianDate
  }

  public func monthSlotsForYear(auc: Int) -> [RomanMonthInfo] {
    var months: [RomanMonthInfo] = []
    if auc < 531 {
      // Years started on May 1

      for i in 5 ..< 15 {
        guard let m = years[auc - earliestDate.year - 1].months[i] else {
          continue
        }
        months.append(m)
      }
      for i in 0 ..< 5 {
        guard let m = years[auc - earliestDate.year].months[i] else {
          continue
        }
        months.append(m)
      }

    } else if auc < 601 {
      // Years started on Ides March
      for i in 4 ..< 15 {
        guard let m = years[auc - earliestDate.year - 1].months[i] else {
          continue
        }
        months.append(m)
      }
      // This generates an extra month
      // as Ides March splits the month in two parts
      for i in 0 ..< 5 {
        guard let m = years[auc - earliestDate.year].months[i] else {
          continue
        }
        months.append(m)
      }
    } else {
      // Years started on 1 January
      for i in years[auc -  earliestDate.year].months.indices {
        guard let m = years[auc - earliestDate.year].months[i] else {
          continue
        }
        months.append(m)
      }
    }

    return months
  }
  /// Convenience for your RomanDay
  public func romanToJulian(auc: Int, _ rd: RomanDay) -> JulianDate {
    romanToJulian(auc: auc, month: rd.month, day: rd.day)
  }
  public func romanToJulian(forDate date: RomanDate) -> JulianDate {
    romanToJulian(auc: date.year, month: date.month, day: date.day)
  }

  public func isValid(date: RomanDate) -> Bool {
    if date.year < earliestDate.year || date.year > lastDate.year {
      return false
    }
    if date.year == earliestDate.year && date.month >= .MAI {
      return false
    }
    let romanDay = RomanDay(month: date.month, day: date.day)

    let romanYear =
    if years[date.year -  earliestDate.year].consularYearStart != RomanDay(month: .IAN, day: 1) &&
        romanDay >= years[date.year -  earliestDate.year].consularYearStart {
      // We need to look in the previous year
      years[date.year -  earliestDate.year - 1]
    } else {
      years[date.year -  earliestDate.year]
    }

    guard let rm = romanYear.months[date.month.slot] else {
      return false
    }

    guard date.day >= 1 else {
      return false
    }

    guard date.day <= rm.days else {
      return false
    }

    return true
  }
}

public struct JdnBucketReverse : Sendable {
  public let baseJDN: Int
  public let bucketSize: Int  // 30 or 32
  public let buckets: [Bucket]

  public struct Bucket : Sendable {
    public let year: Int
    public var kalends: [RomanMonth]
  }

  init(forwardIndex: RomanForwardIndex) {
    baseJDN = forwardIndex.earliestJDN
    bucketSize = 32
    var tmpBuckets: [Bucket] = []

    for y in 0 ..< forwardIndex.years.count {
      for m in forwardIndex.years[y].months.indices {
        guard let month = forwardIndex.years[y].months[m] else {
          continue
        }

        if tmpBuckets.count <= (month.jdn - baseJDN) / bucketSize {
          tmpBuckets.append(Bucket(year: y, kalends: [month.month]))
        } else {
          tmpBuckets[(month.jdn - baseJDN) / bucketSize].kalends.append(month.month)
        }
      }
    }

    buckets = tmpBuckets
  }

  func bucket(forJDN jdn: Int) -> Bucket? {
    let bucketIndex = (jdn - baseJDN) / bucketSize
    if bucketIndex >= buckets.count {
      return nil
    }
    return buckets[bucketIndex]
  }
}


public final class RomanCalendar : CalendarProtocol, WeekdayProtocol, Sendable {
  public var identifier: CalendarId { .romanRepublican }
  public var calendarKey: String { "roman_republican" }
  public func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth]
  {
    // Note that the order of the months above is the same as the slot numbers.
    let months = Self.forwardIndex.monthSlotsForYear(auc: year)

    var result: [ResolvedMonth] = []

    for (i,m) in zip(1...months.count, months) {
      let firstDay =
      if 531 <= year && year < 601 {
        15
      } else {
        1
      }
      result.append(ResolvedMonth(spec: romanMonths[m.month.slot],
                                  index: i, mode: mode, firstDay: firstDay, length: m.days))
    }

    return result
  }

  public static let shared: RomanCalendar = RomanCalendar()

  public var numberOfDays: Int { get {8} }

  public func weekday(forYear year: Int, month: Int, day: Int) -> Int {
    return 0
  }

  public func name(ofWeekday day: Int) -> String {
    return ""
  }

  static let forwardIndex: RomanForwardIndex = RomanForwardIndex(years: RomanYears_Bennett)
  static let reverseIndex: JdnBucketReverse = JdnBucketReverse(forwardIndex: RomanForwardIndex(years: RomanYears_Bennett))

  public var calendarId: String { get { "roman_republican" } }

  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    if year < RomanCalendar.forwardIndex.earliestDate.year {
      return false
    }
    if month < 1 || month > 15 {
      return false
    }

    let m = RomanMonth(rawValue: UInt8(month - 1))!
    if year == RomanCalendar.forwardIndex.earliestDate.year && m >= .MAI {
      return false
    }

    return true
  }
  public func monthName(forYear year: Int, month: Int) -> String {""}
  public func daysInMonth(year: Int, month: Int) -> Int {0}
  public func isProleptic(julianDay jdn: Int) -> Bool {false}
  public func monthNumber(for month: String, in year: Int) -> Int? {0}

  public func jdn(forYear year: Int, month: Int, day: Int) -> Int {
    let julian = self.julian(forRomanYear: year,
                             month: RomanMonth(rawValue: UInt8(month))!, day: day)
    return julian.jdn
  }
  public func date(fromJDN jdn: Int) -> CalendarDateComponents? {
    precondition(jdn >= Self.forwardIndex.earliestJDN, "JDN before coverage")
    precondition(jdn <= Self.forwardIndex.lastJDN, "JDN before coverage")
    guard let bucket = Self.reverseIndex.bucket(forJDN: jdn) else {
      return nil
    }

    let yearInfo = Self.forwardIndex.years[bucket.year]
    for kal in bucket.kalends {
      guard yearInfo.months[kal.slot] != nil else {
        continue
      }

      if yearInfo.months[kal.slot]!.jdn <= jdn && jdn < yearInfo.months[kal.slot]!.jdn + yearInfo.months[kal.slot]!.days {
        let day = jdn - yearInfo.months[kal.slot]!.jdn

        return CalendarDateComponents(calendar: CalendarInfo(id: .romanRepublican, engine: self),
                                      yearMode: .civil, year: yearInfo.auc, month: kal.slot, day: day + 1)
      }
    }

    return nil
  }

  public func julian(forRomanYear year: Int, month: RomanMonth, day: Int) -> JulianDate {
    let result = RomanCalendar.forwardIndex.romanToJulian(auc: year, month: month, day: day)
    return result
  }

  public func roman(forJulianYear year: Int, month: Int, day: Int) -> RomanDate {
    //var jd = JulianDate(year: year, month: month, day: day)
    let rd = RomanDate(year: year, month: .IAN, day: 1)
    return rd
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

