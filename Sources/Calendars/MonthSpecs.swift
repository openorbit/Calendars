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

public struct CalendarSpec: Codable, Equatable {
  public let calendarId: String
  public let months: [MonthSpec]
  public let intercalationRules: [IntercalationRule]
}

public struct MonthSpec: Sendable, Codable, Equatable {
  public let monthUID: String            // stable identity (not a number)
  public let intercalary: Bool
  public let intercalaryRuleRef: String? // link into IntercalationRule.id
  public let names: [MonthNameRecord]
}

public struct ResolvedMonth {
  public let spec: MonthSpec
  public let index: Int        // position in sequence, 1-based
  public let mode: YearMode    // context in which index was computed
  public let firstDay: Int
  public let length: Int
  public let leapDayNumber: Int?

  init(spec: MonthSpec, index: Int, mode: YearMode, firstDay: Int, length: Int, leapDayNumber: Int? = nil) {
    self.spec = spec
    self.index = index
    self.mode = mode
    self.firstDay = firstDay
    self.length = length
    self.leapDayNumber = leapDayNumber
  }
}


public enum MonthNameType : String, Sendable, Codable {
  case official
  case popular
  case seasonalNumeric
  case theophoric
  case liturgical
  case regnal
  case computed
}

public struct MonthNameRecord: Codable, Equatable, Sendable {
  /// taxonomy examples: "official","popular","seasonal_numeric","theophoric","liturgical","regnal","computed"
  public let nameType: MonthNameType
  /// higher wins if multiple candidates survive filtering
  public let priority: Int
  /// optional time/place window (for ephemeral renamings etc.)
  public let validity: Validity?
  /// language/script variants. examples of keys:
  /// "en","la","grc","he","ar","eg_translit","eg_hiero_emblem","eg_hiero_full","demotic","coptic"
  public let variants: [String:String]
  /// optional bibliography keys or URLs you maintain elsewhere
  public let sources: [String]?

  public init(nameType: MonthNameType, priority: Int, validity: Validity? = nil, variants: [String:String], sources: [String]? = nil) {
    self.nameType = nameType
    self.priority = priority
    self.validity = validity
    self.variants = variants
    self.sources = sources
  }
}

public struct IntercalationRule: Codable, Equatable {
  public let id: String
  public let description: String
  /// a human- or DSL-readable rule, e.g. "metonic19 ∈ {3,6,8,11,14,17,19}"
  public let whenApplies: String
  /// where the extra month goes, e.g. "after shevat"
  public let placement: String
  /// monthUIDs created/duplicated by this rule
  public let produces: [String]
}


public struct MonthNamePreference {
  public let preferredNameTypes: [String]      // e.g. ["official","theophoric","seasonal_numeric"]
  public let localeFallback: [String]          // e.g. ["en-GB","en","la","grc","eg_hiero_emblem"]
  public init(preferredNameTypes: [String], localeFallback: [String]) {
    self.preferredNameTypes = preferredNameTypes
    self.localeFallback = localeFallback
  }
}

public extension MonthSpec {
  /// pick best name given context (very light stub; integrate with your year builder & JDN/region filtering)
  func bestName(preference: MonthNamePreference,
                jdn: Int? = nil,
                scope: String = "global") -> (chosen: String?, variants: [String:String]) {
    let candidates = names.filter { rec in
      guard let v = rec.validity else { return true }
      // scope check (very naive: exact match or global)
      guard v.scope == "global" || v.scope == scope else { return false }
      // time window check if jdn present
      if let jdn = jdn {
        if let s = v.startJDN, jdn < s { return false }
        if let e = v.endJDN, jdn >= e { return false }
      }
      return true
    }
    // prefer by nameType list, then priority
    let sorted = candidates.sorted { a, b in
      func rank(_ t: String) -> Int {
        preference.preferredNameTypes.firstIndex(of: t) ?? Int.max
      }
      let ra = rank(a.nameType.rawValue), rb = rank(b.nameType.rawValue)
      return (ra, -a.priority) < (rb, -b.priority)
    }
    guard let best = sorted.first else { return (nil, [:]) }
    for key in preference.localeFallback {
      if let val = best.variants[key] { return (val, best.variants) }
    }
    // fallback to any variant value
    return (best.variants.values.first, best.variants)
  }
}
