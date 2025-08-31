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

public struct ParserConfig {
  public enum Mode { case latin, oldSwedish, auto }
  public var mode: Mode = .auto
  public var maxWindow: Int = 80
  public var enableFuzzyFeastFallback = true
  public init() {}
}

public protocol FeastProvider {
  func feastID(forNormalizedVariant: String) -> String?;
  func isMovableFeast(_ id: String) -> Bool
  func fixedDate(for id: String, year: Int) -> JulianDate?
  func movableBaseDate(for id: String, year: Int) -> (base: JulianDate, delta: Int)?
  func weekdayConstraint(for id: String) -> Int?
}

public struct ParsedFeastDate: Equatable {
  public let anchorFeastID: String
  public let offsetDays: Int
  public let weekday: Int?
  public let rawAnchorText: String
  public let originalSnippet: String
  public let notes: String?
  public let confidence: Double
}

public final class MedievalFeastParser {
  private let feastProvider: FeastProvider
  private let lex: LexiconProvider
  private let config: ParserConfig

  public init(feastProvider: FeastProvider, lexiconProvider: LexiconProvider, config: ParserConfig = .init()) {
    self.feastProvider = feastProvider
    self.lex = lexiconProvider
    self.config = config
  }

  public func parse(_ original: String) -> ParsedFeastDate? {
    let trimmed = original.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }

    let mode = resolveMode(for: trimmed)
    let normalized = MedievalDateNormalizer.normalize(trimmed, mode: mode)

    let weekday = extractWeekday(from: normalized, mode: mode)
    let (offset, offsetConf, offsetRange) = extractOffset(from: normalized, mode: mode)
    let (anchorID, anchorText, anchorConf, anchorRange) =
    extractAnchorFeast(fromOriginal: trimmed, normalized: normalized, mode: mode)

    guard let feastID = anchorID else { return nil }

    let conf = clamp(0.55 + 0.30*anchorConf + 0.15*offsetConf + (weekday == nil ? 0.0 : 0.05), 0, 1)
    let snippet = snippetAround(original: trimmed, normalized: normalized,
                                focus: anchorRange ?? offsetRange, window: config.maxWindow)

    return ParsedFeastDate(
      anchorFeastID: feastID,
      offsetDays: offset ?? 0,
      weekday: weekday,
      rawAnchorText: anchorText ?? "",
      originalSnippet: snippet,
      notes: mode == .latin ? "Latin-mode parse" : "Old Swedish-mode parse",
      confidence: conf
    )
  }

  private func resolveMode(for s: String) -> LanguageMode {
    switch config.mode {
    case .latin: return .latin
    case .oldSwedish: return .oldSwedish
    case .auto:
      let l = s.lowercased()
      let toks = l.tokenize()                  // splits on non-letters; keeps å/ä/ö as letters

      // Helpers
      func has(_ t: String) -> Bool { toks.contains(t) }
      func hasAny(_ arr: [String]) -> Bool { arr.contains { has($0) } }
      func hasPrefixAny(_ prefixes: [String]) -> Bool { toks.contains { t in prefixes.contains { t.hasPrefix($0) } } }
      func hasBigram(_ a: String, _ b: String) -> Bool {
        guard toks.count >= 2 else { return false }
        for i in 0..<(toks.count-1) where toks[i] == a && toks[i+1] == b { return true }
        return false
      }

      // --- Latin cues ---
      let latinSingles = [
        "pridie","postridie","perendie","feria","sancti","sancte","sancta",
        "kalendas","kalendis","idus","idibus","nonae","nonas","octava","octavas","octavis",
        "festo","festi","festum","domini","coena","parasceve","sabbatum","dominica","diem","die"
      ]
      let latinPrefixes = ["sanct", "kalend", "idus", "octav", "domin"]  // catches variants like sancti/sancte, octava/octavis
      let latinBigrams  = [("post","diem"), ("ante","diem"), ("in","festo"), ("in","die")]

      var latinScore = 0
      if hasAny(latinSingles) { latinScore += 2 }
      if hasPrefixAny(latinPrefixes) { latinScore += 2 }
      for (a,b) in latinBigrams { if hasBigram(a,b) { latinScore += 3 } }

      // --- Old Swedish cues ---
      // handle diacritic-stripped earlier normalization by including ASCII forms too
      let osSingles = [
        "mässa","messa","massa","efter","före","fore","dagen","afton","på","paa","pa",
        "söndag","sondag","måndag","mandag","tisdag","onsdag","torsdag","fredag","lördag","lordag",
        "valborg","olsmässa","olsmassa","mickelsmässa","mickelsmassa","kyndelsmässa","kyndelsmassa"
      ]

      var osScore = 0
      if hasAny(osSingles) { osScore += 2 }

      // Decide
      if latinScore == 0 && osScore == 0 {
        // bias: Old Swedish as before
        return .oldSwedish
      }
      if latinScore >= osScore { return .latin }
      return .oldSwedish
    }
  }
  private func extractWeekday(from normalized: String, mode: LanguageMode) -> Int? {
    let toks = normalized.split(separator: " ").map(String.init)
    let wmap = (mode == .latin) ? lex.latinWeekdays : lex.osweWeekdays
    for i in 0..<toks.count {
      if i+1 < toks.count {
        let pair = toks[i] + " " + toks[i+1]
        if let v = wmap[pair] { return v }
      }
      if let v = wmap[toks[i]] { return v }
    }
    return nil
  }

  private func latinFoldVU(_ t: String) -> String {
      t.replacingOccurrences(of: "u", with: "v")
       .replacingOccurrences(of: "j", with: "i")
  }

  private func latinOrdinalFromToken(_ t: String) -> Int? {
      // Only i/j normalization. DO NOT fold u↔v here.
      let x = t.replacingOccurrences(of: "j", with: "i")
      // Accept both qu- and qv- for quart…
      let stems: [(String, Int)] = [
          ("prim", 1), ("secund", 2), ("terti", 3),
          ("quart", 4), ("qvart", 4),
          ("quint", 5),
          ("sext", 6), ("septim", 7), ("octav", 8), ("non", 9), ("decim", 10)
      ]
      return stems.first(where: { x.hasPrefix($0.0) })?.1
  }

  private func isLatinDie(_ t: String) -> Bool {
      // Only i/j normalization here as well.
      let x = t.replacingOccurrences(of: "j", with: "i")
      return x == "die" || x == "diem"
  }
  private func extractOffset(from s: String, mode: LanguageMode) -> (Int?, Double, Range<String.Index>?) {
    if mode == .latin {
      let toks = s.tokenize()
      
      // --- 0) Single-word relatives by stem (robust to punctuation) ---
      // pridie = -1; postridie = +1; perendie = +2
      for (stem, delta, conf) in [("prid", -1, 0.95), ("postrid", 1, 0.92), ("perend", 2, 0.92)] {
        if toks.contains(where: { $0.hasPrefix(stem) }) {
          // Try to get a range for nicer snippet; fall back to nil
          if let hit = toks.first(where: { $0.hasPrefix(stem) }),
             let r = s.range(of: hit) {
            return (delta, conf, r)
          }
          return (delta, conf, nil)
        }
      }



      // helpers
      func foldVU(_ t: String) -> String {
        t.replacingOccurrences(of: "u", with: "v")
          .replacingOccurrences(of: "j", with: "i")
      }
      func isDie(_ t: String) -> Bool {
        let x = foldVU(t)
        return x == "die" || x == "diem"
      }
      func ordinalFromToken(_ t: String) -> Int? {
        let x = foldVU(t)
        // accept prima/primo/primus/primam, tertio/tertiam, quartum, etc.
        let stems: [(String, Int)] = [
          ("prim", 1), ("secund", 2), ("terti", 3), ("quart", 4), ("quint", 5),
          ("sext", 6), ("septim", 7), ("octav", 8), ("non", 9), ("decim", 10)
        ]
        return stems.first(where: { x.hasPrefix($0.0) })?.1
      }
      
      // --- 1) ORDINAL [die/diem]? (post|ante)
      for i in 0..<toks.count {
        if let n = latinOrdinalFromToken(toks[i]) {
          var j = i + 1
          if j < toks.count, isLatinDie(toks[j]) { j += 1 }
          if j < toks.count {
            let dir = toks[j]
            if dir == "post" || dir == "ante" {
              let sign = (dir == "ante") ? -1 : 1
              if let r = s.range(of: toks[i]) { return (sign * n, 0.90, r) }
              return (sign * n, 0.90, nil)
            }
          }
        }
      }

      // --- 2) (post|ante) [die/diem]? ORDINAL
      for i in 0..<toks.count {
        let dir = toks[i]
        guard dir == "post" || dir == "ante" else { continue }
        var j = i + 1
        if j < toks.count, isLatinDie(toks[j]) { j += 1 }
        if j < toks.count, let n = latinOrdinalFromToken(toks[j]) {
          let sign = (dir == "ante") ? -1 : 1
          if let r = s.range(of: toks[j]) { return (sign * n, 0.88, r) }
          return (sign * n, 0.88, nil)
        }
      }
      // --- 3) in octava / octavis (already fixed earlier) ---
      for i in 0..<toks.count {
        if toks[i] == "in", i + 1 < toks.count {
          let n1 = foldVU(toks[i + 1])
          if n1.hasPrefix("octav") {
            if let r = s.range(of: toks[i + 1]) { return (7, 0.90, r) }
            return (7, 0.90, nil)
          }
        }
      }
      
      return (nil, 0.0, nil)
    } else {
      // Old Swedish
      // Pattern with no lookbehind: capture ord + (dagen)? + connector
      if let m = try? /(?:^|[^A-Za-z])(?<ord>[a-zæœåäö]+)\s+(?:dagen\s+)?(?<conn>efter|före|fore)(?:[^A-Za-z]|$)/.firstMatch(in: s) {
        let ordTok = String(m.output.ord)
        let conn   = String(m.output.conn)
        if let n = lex.ordinals[ordTok] {
          let sign = (conn.hasPrefix("före") || conn == "fore") ? -1 : +1
          return (sign * n, 0.85, m.range)
        }
      }
      // dagen före
      if let r = s.range(of: "dagen före") ?? s.range(of: "dagen fore") {
        return (-1, 0.80, r)
      }
      // nästa dag / dagen därpå (derpå)
      if let r = s.range(of: "nästa dag") ?? s.range(of: "dagen derpå") {
        return (1, 0.75, r)
      }
      return (nil, 0.0, nil)
    }
  }
  private func latinOrdinalFallback(_ tok: String) -> Int? {
    switch tok {
    case "prima","primo","primus": return 1
    case "secunda","secundo","secundus": return 2
    case "tertia","tertio","tertius": return 3
    case "quarta","quarto","quartus": return 4
    case "quinta","quinto","quintus": return 5
    case "sexta","sexto","sextus": return 6
    case "septima","septimo","septimus": return 7
    case "octava","octavo","octavus": return 8
    case "nona","nono","nonus": return 9
    case "decima","decimo","decimus": return 10
    default: return nil
    }
  }

  private func extractAnchorFeast(fromOriginal original: String, normalized: String, mode: LanguageMode)
  -> (String?, String?, Double, Range<String.Index>?) {
    let markerLatin = /(?:\bin\s+festo\b|\bin\s+die\b|\bfesto\b|\bfesti\b|\bs\.)/
    let markerOSwe  = /(?:\bm[aä]ssa\b|\bmessa\b|\bmassa\b|\bdag(?:en)?\b|\bafton\b)/
    let hits = normalized.matches(of: (mode == .latin ? markerLatin : markerOSwe)).map { $0.range }
    let windows: [Range<String.Index>] =
    hits.isEmpty ? [normalized.startIndex..<normalized.endIndex]
    : hits.map { expand(normalized, around: $0, tokensLeft: 6, tokensRight: 6) }

    for w in windows {
      let slice = String(normalized[w])
      if let (id, variant, conf) = findFeastVariant(in: slice) {
        return (id, variant, conf, w)
      }
    }
    if let (id, variant, conf) = findFeastVariant(in: normalized) {
      return (id, variant, conf, normalized.startIndex..<normalized.endIndex)
    }
    if let (id, variant, conf) = fuzzyFeast(in: normalized) {
      return (id, variant, conf, normalized.startIndex..<normalized.endIndex)
    }
    return (nil, nil, 0.0, nil)
  }
#if DEBUG
  private func _logAnchorTry(_ toks: [String]) {
    print("[anchor try] \(toks.joined(separator: " | "))")
  }
#endif

  private func findFeastVariant(in normalized: String) -> (String, String, Double)? {
    let tokens = normalized.tokenize()
#if DEBUG
    _logAnchorTry(tokens)
#endif

    let maxN = 3
    var best: (id: String, variant: String, score: Double)? = nil
    for n in stride(from: maxN, through: 1, by: -1) {
      if tokens.count < n { continue }
      for i in 0...(tokens.count - n) {
        let phrase = tokens[i..<i+n].joined(separator: " ")
        if let id = feastProvider.feastID(forNormalizedVariant: phrase) {
          let score = min(0.98, 0.7 + 0.3 * Double(n))
          if best == nil || score > best!.score { best = (id, phrase, score) }
        }
      }
      if best != nil { break }
    }
    return best.map { ($0.id, $0.variant, $0.score) }
  }

  private func fuzzyFeast(in normalized: String) -> (String, String, Double)? {
    let cores = ["ols","olav","olof","erik","lars","laur","mickel","michael","lucia","martin","andrew","nikola","valborg","kors","maria","johannes","iohannes"]
    for t in normalized.tokenize() {
      if cores.contains(where: { t.hasPrefix($0) }),
         let id = feastProvider.feastID(forNormalizedVariant: t) {
        return (id, t, 0.70)
      }
    }
    return nil
  }

  private func snippetAround(original: String, normalized: String,
                             focus: Range<String.Index>?, window: Int) -> String {
    guard let focus = focus else {
      return original.count > window ? String(original.prefix(window)) + "…" : original
    }
    let startOffset = normalized.distance(from: normalized.startIndex, to: focus.lowerBound)
    let endOffset   = normalized.distance(from: normalized.startIndex, to: focus.upperBound)
    let oStart = original.index(original.startIndex, offsetBy: max(0, startOffset - window/2))
    let oEnd   = original.index(original.startIndex, offsetBy: min(original.count, endOffset + window/2))
    return String(original[oStart..<oEnd])
  }

  private func expand(_ s: String, around r: Range<String.Index>, tokensLeft: Int, tokensRight: Int) -> Range<String.Index> {
    var left = r.lowerBound
    var right = r.upperBound
    var leftSteps = tokensLeft, rightSteps = tokensRight
    while left > s.startIndex && leftSteps > 0 {
      left = s.index(before: left)
      if s[left].isWhitespace { leftSteps -= 1 }
    }
    while right < s.endIndex && rightSteps > 0 {
      if s[right].isWhitespace { rightSteps -= 1 }
      right = s.index(after: right)
    }
    return left..<right
  }

  private func clamp(_ x: Double, _ lo: Double, _ hi: Double) -> Double { max(lo, min(hi, x)) }
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
