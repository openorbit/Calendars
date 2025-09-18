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


fileprivate let egyptianMonths: [MonthSpec] = [
  MonthSpec(
    monthUID: "egyptian:M01",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .theophoric,
        priority: 80,
        variants: [
          "en": "Toth",
          "gr": "Θωθ",
          "cop" : "Ⲑⲱⲟⲩⲧ"
        ],
        sources: nil
      ),
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "I Akhet"
        ],
        sources: nil
      )
    ]
  ),

  MonthSpec(
    monthUID: "egyptian:M02",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .theophoric,
        priority: 80,
        variants: [
          "en": "Paophi",
          "gr": "Φαωφί",
          "cop" : "Ⲡⲁⲱⲡⲉ"
        ],
        sources: nil
      ),
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "II Akhet"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "egyptian:M03",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "Athyr",
          "gr": "Ἀθύρ",
          "cop" : "Ϩⲁⲑⲱⲣ"
        ],
        sources: nil
      ),
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "III Akhet"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "egyptian:M04",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .theophoric,
        priority: 80,
        variants: [
          "en": "Cohiac",
          "gr": "Χοιάκ",
          "cop" : "Ⲕⲟⲓⲁⲕ", // Also: "Ⲕⲓⲁϩⲕ"
        ],
        sources: nil
      ),
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "IV Akhet"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "egyptian:M05",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .theophoric,
        priority: 80,
        variants: [
          "en": "Tybi",
          "gr": "Τυβί",
          "cop" : "Ⲧⲱⲃⲓ",
        ],
        sources: nil
      ),
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "I Peret"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "egyptian:M06",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .theophoric,
        priority: 80,
        variants: [
          "en": "Mesir",
          "gr": "Μεχίρ",
          "cop" : "Ⲙⲉϣⲓⲣ"
        ],
        sources: nil
      ),
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "II Peret"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "egyptian:M07",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .theophoric,
        priority: 80,
        variants: [
          "en": "Phanemoth",
          "gr": "Φαμενώθ",
          "cop" : "Ⲡⲁⲣⲉⲙϩⲁⲧ"
        ],
        sources: nil
      ),
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "III Peret"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "egyptian:M08",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .theophoric,
        priority: 80,
        variants: [
          "en": "Pharmouti",
          "gr": "Φαρμουθί",
          "cop" : "Ⲡⲁⲣⲙⲟⲩⲧⲉ"
        ],
        sources: nil
      ),
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "IV Peret"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "egyptian:M09",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .theophoric,
        priority: 80,
        variants: [
          "en": "Pachons",
          "gr": "Παχών",
          "cop" : "Ⲡⲁϣⲟⲛⲥ"
        ],
        sources: nil
      ),
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "I Shemu"
        ],
        sources: nil
      )
    ]
  ),
  MonthSpec(
    monthUID: "egyptian:M10",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .theophoric,
        priority: 80,
        variants: [
          "en": "Payni",
          "gr": "Παϋνί",
          "cop" : "Ⲡⲁⲱⲛⲓ"
        ],
        sources: nil
      ),
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "II Shemu"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "egyptian:M11",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .theophoric,
        priority: 80,
        variants: [
          "en": "Epiphi",
          "gr": "Ἐπιφί",
          "cop" : "Ⲉⲡⲓⲡ"
        ],
        sources: nil
      ),
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "III Shemu"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "egyptian:M12",
    intercalary: false,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .theophoric,
        priority: 80,
        variants: [
          "en": "Mesori",
          "gr": "Μεσορή",
          "cop" : "Ⲙⲉⲥⲱⲣⲓ"
        ],
        sources: nil
      ),
      MonthNameRecord(
        nameType: .seasonalNumeric,
        priority: 80,
        variants: [
          "en": "IV Shemu"
        ],
        sources: nil
      )

    ]
  ),
  MonthSpec(
    monthUID: "egyptian:epagomenal",
    intercalary: true,
    intercalaryRuleRef: nil,
    names: [
      MonthNameRecord(
        nameType: .theophoric,
        priority: 80,
        variants: [
          "en": "Epagomenal",
          "gr": "ἐπαγόμεναι",
          "cop" : "Ⲡⲓⲕⲟⲩϫⲓ ⲛ̀ⲁⲃⲟⲧ"
        ],
        sources: nil
      )
    ]
  ),
]


public struct EgyptianCalendar : CalendarProtocol {
  public var identifier: CalendarId { .egyptian }
  public var calendarKey: String { "egyptian" }
  public func months(forYear year: Int, mode: YearMode) -> [ResolvedMonth]
  {
    var result: [ResolvedMonth] = []
    for (i, month) in zip(1 ... egyptianMonths.count, egyptianMonths) {
      result.append(ResolvedMonth(spec: month, index: i, mode: mode, firstDay: 1,
                                  length: daysInMonth(year: year, month: i)))
    }
    return result
  }

  public func isValidDate(year: Int, month: Int, day: Int) -> Bool {
    EgyptianCalendar.isValidDate(Y: year, M: month, D: day)
  }

  public func monthName(forYear year: Int, month: Int) -> String {
    return EgyptianCalendar.nameOfMonth(month)
  }

  public func daysInMonth(year: Int, month: Int) -> Int {
    EgyptianCalendar.daysInMonth(year: year, month: month)
  }

  public func isProleptic(julianDay jdn: Int) -> Bool {
    EgyptianCalendar.isProleptic(jdn)
  }

  public func monthNumber(for month: String, in year: Int) -> Int? {
    EgyptianCalendar.numberOfMonth(month)
  }

  public func jdn(forYear year: Int, month: Int, day: Int) -> Int {
    EgyptianCalendar.toJDN(Y: year, M: month, D: day)
  }

  public func date(fromJDN jdn: Int) -> CalendarDateComponents? {
    let (y, m, d) = EgyptianCalendar.toDate(J: jdn)
    return CalendarDateComponents(calendar: .egyptian,
                                  yearMode: .civil, year: y, month: m, day: d)
  }

  public static let epoch = 1448638
  public static let shared = EgyptianCalendar()

  public static func daysInMonth(year: Int, month: Int) -> Int {
    if month == 13 {
      return 5
    }
    return 30
  }

  public static func isValidDate(Y: Int, M: Int, D: Int) -> Bool {
    if M < 1 || 13 < M {
      return false
    }
    if D < 1 || daysInMonth(year: Y, month: M) < D {
      return false
    }
    return true
  }

  public static func numberOfMonth(_ month: String) -> Int? {
    let monthDictionary = ["toth": 1, "paophi": 2, "athyr": 3,
                           "cohiac": 4, "tybi": 5, "mesir": 6,
                           "phanemoth": 7, "pharmouti": 8, "pachons": 9,
                           "payni": 10, "epiphi": 11, "mesori": 12, "": 13]
    return monthDictionary[month.lowercased()]
  }

  public static func nameOfMonth(_ month: Int) -> String {
    let monthNames = ["Toth", "Paophi", "Athyr",
                      "Cohiac", "Tybi", "Mesir",
                      "Phanemoth", "Pharmouti", "Pachons",
                      "Payni", "Epiphi", "Mesori", ""]
    return monthNames[month-1]
  }

  public static func isProleptic(_ d: Int) -> Bool {
    return d < epoch
  }

  static let algorithm = CalendarAlgorithm(y: 3968, j: 47, m: 0, n: 13, r: 1, p: 365, q: 0, v: 0, u: 1, s: 30, t: 0, w: 0)

  static func toJDN(Y: Int, M: Int, D: Int) -> Int {
    algorithm.toJd(Y: Y, M: M, D: D)
  }
  static func toDate(J: Int) -> (Int, Int, Int) {
    algorithm.toDate(J: J)
  }

}

