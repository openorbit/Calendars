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

import Foundation

/// Next (or same) weekday at/after a given date. Sunday=0…Saturday=6
private func nextOnOrAfterWeekday(_ date: JulianDate, targetWeekday: Int) -> JulianDate {
  precondition((0...6).contains(targetWeekday))
  let wd0 = date.dayOfWeekIndex           // 0..6
  let delta = (targetWeekday - wd0 + 7) % 7
  return date.dateAdding(days: delta)
}

// =====================================================
// MARK: - DATA MODELS (Codable for our JSON files)
// =====================================================

public struct FeastDataset: Codable {
  public struct FixedFeast: Codable {
    public let id: String
    public let julian_fixed_date: String // "MM-DD"
    public let latin_name: String?
    public let old_swedish_names: [String]?
    public let aliases: [String]?
    public let examples: [String]?
  }
  public struct MovableRef: Codable {
    public let id: String
    public let relation_to_easter_days: Int
    public let latin_name: String?
    public let old_swedish_names: [String]?
    public let examples: [String]?
  }
  public let period: String
  public let fixed_feasts: [FixedFeast]
  public let movable_feast_refs: [MovableRef]?
  public let parsing_hints: ParsingHints?
  public struct ParsingHints: Codable {
    public let weekday_map_latin_to_index: [String:Int]?
  }
}


public struct FeastDateResolver {
  public enum Strategy {
    /// If weekday provided, snap to the first ON/AFTER that weekday after applying offset (most common in charters: “Monday after …”)
    case weekdayOnOrAfter
    /// If weekday provided, snap to the first BEFORE/ON that weekday (rare; include if you parse “före” at the weekday level)
    case weekdayOnOrBefore
  }

  public struct Request {
    public let year: Int
    public let feastID: String
    public let offsetDays: Int
    public let weekday: Int? // Sunday=0…Saturday=6
    public let strategy: Strategy
    public init(year: Int, feastID: String, offsetDays: Int, weekday: Int?, strategy: Strategy = .weekdayOnOrAfter) {
      self.year = year; self.feastID = feastID; self.offsetDays = offsetDays; self.weekday = weekday; self.strategy = strategy
    }
  }

  public struct Response: Equatable {
    public let anchor: JulianDate        // base feast date (or Easter base if movable)
    public let computed: JulianDate      // after offset and weekday snapping
    public let usedWeekday: Int?         // nil if none provided
  }

  private let feasts: FeastProvider

  public init(feastProvider: FeastProvider) {
    self.feasts = feastProvider
  }

  public func resolve(_ req: Request) -> Response? {
    // 1) anchor
    let anchor: JulianDate
    if let fixed = feasts.fixedDate(for: req.feastID, year: req.year) {
      anchor = fixed
    } else if let (base, delta) = feasts.movableBaseDate(for: req.feastID, year: req.year) {
      anchor = base.dateAdding(days: delta)
    } else {
      return nil
    }
    // 2) apply offset
    var result = anchor.dateAdding(days: req.offsetDays)

    // 3) snap to weekday if provided
    // 3) weekday snap — but **skip** if feast already encodes the weekday
    if let wd = req.weekday {
      if let intrinsic = feasts.weekdayConstraint(for: req.feastID) {
        // Feast already encodes a weekday
        if wd != intrinsic {
          // optional: warn, lower confidence, or ignore mismatch
          
        }
        // Do nothing (skip snapping)
      } else {
        // Feast has no intrinsic weekday → snap
        switch req.strategy {
        case .weekdayOnOrAfter:
          result = nextOnOrAfterWeekday(result, targetWeekday: wd)
        case .weekdayOnOrBefore:
          var tmp = result
          while tmp.dayOfWeekIndex != wd { tmp = tmp.dateAdding(days: -1) }
          result = tmp
        }
      }
    }
    return Response(anchor: anchor, computed: result, usedWeekday: req.weekday)
  }
}



public protocol FeastProvider {
  func feastID(forNormalizedVariant: String) -> String?;
  func isMovableFeast(_ id: String) -> Bool
  func fixedDate(for id: String, year: Int) -> JulianDate?
  func movableBaseDate(for id: String, year: Int) -> (base: JulianDate, delta: Int)?
  func weekdayConstraint(for id: String) -> Int?
}



package extension String {
  func applyMap(_ m: [String:String]) -> String {
    var out = self
    for (k,v) in m { out = out.replacingOccurrences(of: k, with: v) }
    return out
  }
  func tokenize() -> [String] { self.split(whereSeparator: { !$0.isLetter }).map { String($0) } }
}

private extension Character {
  var isWhitespace: Bool { unicodeScalars.allSatisfy { CharacterSet.whitespaces.contains($0) } }
  var isLetter: Bool { unicodeScalars.allSatisfy { CharacterSet.letters.contains($0) } }
}
public struct MonthDay: Hashable, Sendable {
  public let month: Int   // 1…12
  public let day: Int     // 1…31 (range-checked; not month-length aware)

  public init(_ month: Int, _ day: Int) {
    precondition(1...12 ~= month, "MonthDay.month out of range")
    precondition(1...31 ~= day,   "MonthDay.day out of range")
    self.month = month; self.day = day
  }
}

extension MonthDay: Codable {
  public init(from decoder: Decoder) throws {
    let c = try decoder.singleValueContainer()
    if let s = try? c.decode(String.self) {
      // Accept "MM-DD"
      guard s.count == 5, s[s.index(s.startIndex, offsetBy: 2)] == "-" else {
        throw DecodingError.dataCorruptedError(in: c, debugDescription: "Expected MM-DD string")
      }
      let mm = Int(s.prefix(2))!, dd = Int(s.suffix(2))!
      self.init(mm, dd); return
    }
    // Accept {"month":2,"day":2}
    struct Obj: Decodable { let month: Int; let day: Int }
    let o = try decoder.singleValueContainer().decode(Obj.self)
    self.init(o.month, o.day)
  }

  public func encode(to encoder: Encoder) throws {
    var c = encoder.singleValueContainer()
    // Write as "MM-DD" for readability
    try c.encode(String(format: "%02d-%02d", month, day))
  }
}

extension MonthDay: CustomStringConvertible {
  public var description: String { String(format: "%02d-%02d", month, day) }
}


public struct FeastRecord: Codable, Hashable, Sendable {
  public enum Kind: String, Codable, Sendable { case fixed, movable }
  public enum RegionTag: String, Codable, Sendable {
    case universal
    case england, wales, scotland, ireland
    case france, lowcountries, hre, germany, austria, switzerland
    case bohemia, poland, hungary
    case italy, venice, papal_states
    case spain, portugal, aragon, castile
    case scandinavia, denmark, norway, sweden, iceland, finland
  }

  // — Base (global) definition —
  public let id: String
  public let kind: Kind
  public let julianFixed: MonthDay?
  public let relationToEasterDays: Int?      // if movable
  public let weekdayConstraint: Int?         // 0=Sun … 6=Sat, if feast identity encodes weekday

  public let universal: Bool                 // broadly Western “universal”?
  public let regions: [RegionTag]            // where it’s relevant by default
  public let validFromYear: Int?
  public let validToYear: Int?

  /// Global names; you already parse by language code
  public let namesByLanguage: [String:[String]]
  public let notes: String?

  /// Regional overrides (optional)
  public let overrides: [RegionalOverride]?
}

/// A small patch that applies when any of its regions are active.
/// Each field is “override if non-nil”. For names you can choose to
/// append or replace (default is append).
public struct RegionalOverride: Codable, Hashable, Sendable {
  public let regions: [FeastRecord.RegionTag]

  // Property overrides (only applied if non-nil)
  public let julianFixed: MonthDay?
  public let relationToEasterDays: Int?
  public let weekdayConstraint: Int?

  /// If set, constrains validity to this window (intersect with base window)
  public let validFromYear: Int?
  public let validToYear: Int?

  /// Add or replace names for these regions
  public let extraNamesByLanguage: [String:[String]]?
  public let replaceNames: Bool   // default false → append/merge

  public let notes: String?

  init(regions: [FeastRecord.RegionTag] = [], julianFixed: MonthDay? = nil,
       relationToEasterDays: Int? = nil, weekdayConstraint: Int? = nil,
       validFromYear: Int? = nil, validToYear: Int? = nil,
       extraNamesByLanguage: [String : [String]]? = nil,
       replaceNames: Bool = false, notes: String? = nil) {
    self.regions = regions
    self.julianFixed = julianFixed
    self.relationToEasterDays = relationToEasterDays
    self.weekdayConstraint = weekdayConstraint
    self.validFromYear = validFromYear
    self.validToYear = validToYear
    self.extraNamesByLanguage = extraNamesByLanguage
    self.replaceNames = replaceNames
    self.notes = notes
  }
}

public struct FeastOccurrence: Equatable, Hashable, Sendable {
  public enum Kind : Sendable { case fixed, movable }
  public let id: String
  public let kind: Kind
  public let date: JulianDate
}

public func feasts(on date: JulianDate,
                   using provider: (FeastProvider & FeastCatalog)) -> [FeastOccurrence] {
  var hits: [FeastOccurrence] = []
  for id in provider.allFixedIDs {
    if let d = provider.fixedDate(for: id, year: date.year), d.month == date.month, d.day == date.day {
      hits.append(.init(id: id, kind: .fixed, date: d))
    }
  }
  for id in provider.allMovableIDs {
    if let (base, delta) = provider.movableBaseDate(for: id, year: date.year) {
      let d = base.dateAdding(days: delta)
      if d == date { hits.append(.init(id: id, kind: .movable, date: d)) }
    }
  }
  return hits
}
