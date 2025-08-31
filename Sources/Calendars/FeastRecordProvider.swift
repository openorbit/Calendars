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


/// Minimal introspection so we can iterate feasts.
public protocol FeastCatalog {
  var allFixedIDs: [String] { get }
  var allMovableIDs: [String] { get }
}

public final class FeastRecordProvider: FeastProvider, FeastCatalog {
  public struct Config {
    public let activeRegions: Set<FeastRecord.RegionTag>
    public init(activeRegions: Set<FeastRecord.RegionTag> = [.universal]) {
      self.activeRegions = activeRegions
    }
  }

  private let cfg: Config
  private var fixedByID: [String: MonthDay] = [:]
  private var movableByID: [String:Int] = [:]
  private var weekdayByID: [String:Int?] = [:]
  private var validityByID: [String:(from:Int?, to:Int?)] = [:]
  private var variant2id: [String:String] = [:]

  // Keep the merged, region-effective record for easy access
  private var effectiveByID: [String: FeastRecord] = [:]


  public init(records: [FeastRecord], config: Config = .init()) {
    self.cfg = config

    for base in records {
      let eff = Self.applyOverrides(base, active: cfg.activeRegions)

      // store effective record
      effectiveByID[eff.id] = eff

      // Dates
      if eff.kind == .fixed, let md = eff.julianFixed {
        fixedByID[eff.id] = md
      }

      if eff.kind == .movable, let k = eff.relationToEasterDays {
        movableByID[eff.id] = k
      }
      weekdayByID[eff.id] = eff.weekdayConstraint
      validityByID[eff.id] = (eff.validFromYear, eff.validToYear)

      // Variants
      for (lang, names) in eff.namesByLanguage {
        for raw in names {
          for key in Self.variantKeys(raw, lang: lang) { variant2id[key] = eff.id }
        }
      }
      for key in Self.variantKeys(eff.id, lang: "la") { variant2id[key] = eff.id }
    }
  }

  /// The merged, region-effective record (if known).
  public func effectiveRecord(for id: String) -> FeastRecord? {
    effectiveByID[id]
  }

  /// All display names for a feast, grouped by language (deduplicated & sorted).
  public func names(for id: String) -> [String:[String]] {
    guard let r = effectiveByID[id] else { return [:] }
    var out: [String:[String]] = [:]
    for (lang, arr) in r.namesByLanguage {
      // de-duplicate and sort for stable UI
      let uniq = Array(Set(arr)).sorted()
      out[lang] = uniq
    }
    return out
  }

  public func normalizedVariants(for id: String) -> [String] {
    guard let r = effectiveByID[id] else { return [] }
    var keys: Set<String> = []
    for (lang, arr) in r.namesByLanguage {
      for raw in arr {
        for k in Self.variantKeys(raw, lang: lang) { keys.insert(k) }
      }
    }
    return Array(keys).sorted()
  }

  // Apply any overrides whose regions intersect with activeRegions
  private static func applyOverrides(
    _ base: FeastRecord,
    active: Set<FeastRecord.RegionTag>
  ) -> FeastRecord {
    // Start with base (effective) values in mutable locals
    var effJulianFixed         = base.julianFixed
    var effRelationToEaster    = base.relationToEasterDays
    var effWeekdayConstraint   = base.weekdayConstraint
    var effValidFrom           = base.validFromYear
    var effValidTo             = base.validToYear
    var effNames               = base.namesByLanguage
    var effNotes               = base.notes

    // Apply overrides whose regions intersect with the active set
    if let ovs = base.overrides {
      for o in ovs where !active.isDisjoint(with: Set(o.regions)) {
        if let jf = o.julianFixed { effJulianFixed = jf }
        if let rel = o.relationToEasterDays { effRelationToEaster = rel }
        if let w = o.weekdayConstraint { effWeekdayConstraint = w }

        // validity = intersection of windows
        if let f = o.validFromYear {
          effValidFrom = (effValidFrom == nil) ? f : max(effValidFrom!, f)
        }
        if let t = o.validToYear {
          effValidTo = (effValidTo == nil) ? t : min(effValidTo!, t)
        }

        // names: append by default, or replace if requested
        if let extra = o.extraNamesByLanguage {
          if o.replaceNames == true {
            effNames = extra
          } else {
            for (lang, vals) in extra {
              effNames[lang, default: []].append(contentsOf: vals)
            }
          }
        }

        // optional: accumulate notes
        if let n = o.notes, !n.isEmpty {
          effNotes = [effNotes, n].compactMap { $0 }.joined(separator: " ")
        }
      }
    }

    // Return a brand-new merged record (immutability preserved)
    return FeastRecord(
      id: base.id,
      kind: base.kind,
      julianFixed: effJulianFixed,
      relationToEasterDays: effRelationToEaster,
      weekdayConstraint: effWeekdayConstraint,
      universal: base.universal,
      regions: base.regions,
      validFromYear: effValidFrom,
      validToYear: effValidTo,
      namesByLanguage: effNames,
      notes: effNotes,
      overrides: base.overrides
    )
  }

  // Tiny helper to copy-mutate
  private static func with(_ r: FeastRecord, _ f: (inout FeastRecord) -> Void) -> FeastRecord {
    var x = r; f(&x); return x
  }

  // FeastProvider
  public func feastID(forNormalizedVariant v: String) -> String? { variant2id[v.lowercased()] }
  public func isMovableFeast(_ id: String) -> Bool { movableByID[id] != nil }
  public func fixedDate(for id: String, year: Int) -> JulianDate? {
    // respect validity window
    if let (f,t) = validityByID[id], !Self.yearAllowed(year, from: f, to: t) { return nil }
    guard let md = fixedByID[id] else { return nil }
    return JulianDate(year: year, month: md.month, day: md.day)
  }
  public func movableBaseDate(for id: String, year: Int) -> (base: JulianDate, delta: Int)? {
    if let (f,t) = validityByID[id], !Self.yearAllowed(year, from: f, to: t) { return nil }
    guard let delta = movableByID[id] else { return nil }
    return (JulianDate.dayOfEaster(year: year), delta)
  }
  public func weekdayConstraint(for id: String) -> Int? { weekdayByID[id] ?? nil }

  // FeastCatalog
  public var allFixedIDs: [String]  { Array(fixedByID.keys) }
  public var allMovableIDs: [String]{ Array(movableByID.keys) }

  private static func yearAllowed(_ y: Int, from: Int?, to: Int?) -> Bool {
    if let f = from, y < f { return false }
    if let t = to,   y > t { return false }
    return true
  }

  // MARK: variant folding (Latin vs vernacular)
  private static func variantKeys(_ raw: String, lang: String) -> Set<String> {
    var forms: Set<String> = [raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()]
    // strip punctuation dots
    forms.formUnion(forms.map { $0.replacingOccurrences(of: ".", with: "") })
    // diacritics
    forms.formUnion(forms.map { $0.applyingTransform(.stripDiacritics, reverse: false) ?? $0 })
    // ligatures common in medieval texts
    for (from,to) in [("æ","ae"),("œ","oe"),("ß","ss"),("ſ","s")] {
      forms.formUnion(forms.map { $0.replacingOccurrences(of: from, with: to) })
    }
    // nordic diacritics: philological folds + ascii
    forms.formUnion(forms.map {
      $0.replacingOccurrences(of:"å", with:"aa")
        .replacingOccurrences(of:"ä", with:"ae")
        .replacingOccurrences(of:"ö", with:"oe")
    })
    forms.formUnion(forms.map {
      $0.replacingOccurrences(of:"å", with:"a")
        .replacingOccurrences(of:"ä", with:"a")
        .replacingOccurrences(of:"ö", with:"o")
    })
    // Latin-only alternations
    if lang == "la" {
      var vuij: Set<String> = []
      for f in forms {
        vuij.insert(f.replacingOccurrences(of: "v", with: "u"))
        vuij.insert(f.replacingOccurrences(of: "u", with: "v"))
        vuij.insert(f.replacingOccurrences(of: "j", with: "i"))
        vuij.insert(f.replacingOccurrences(of: "i", with: "j"))
      }
      forms.formUnion(vuij)

      // 1) Also index bare form without "sancti "
      forms.formUnion(forms.compactMap { $0.hasPrefix("sancti ") ? String($0.dropFirst(7)) : nil })
      forms.formUnion(forms.compactMap { $0.hasPrefix("sanctae ") ? String($0.dropFirst(8)) : nil })
      forms.formUnion(forms.compactMap { $0.hasPrefix("sancte ") ? String($0.dropFirst(7)) : nil })
      forms.formUnion(forms.compactMap { $0.hasPrefix("sanctus ") ? String($0.dropFirst(8)) : nil })

      // 2) Generate common medieval abbreviations for "sanct*"
      func abbrev(_ prefix: String, drop n: Int) -> Set<String> {
        Set(forms.compactMap { $0.hasPrefix(prefix) ? String($0.dropFirst(n)) : nil })
      }
      let afterSancti  = abbrev("sancti ", drop: 7)
      let afterSanctae = abbrev("sanctae ", drop: 8)
      let afterSancte  = abbrev("sancte ", drop: 7)
      let afterSanctus = abbrev("sanctus ", drop: 8)
      let tails = afterSancti.union(afterSanctae).union(afterSancte).union(afterSanctus)

      var abbrs: Set<String> = []
      for t in tails {
        abbrs.insert("s " + t)     // "s laurentii"
        abbrs.insert("s. " + t)    // "s. laurentii"
        abbrs.insert("sci " + t)   // "sci laurentii"
        abbrs.insert("scti " + t)  // "scti laurentii"
      }
      forms.formUnion(abbrs)


    }
    // collapse whitespace
    forms.formUnion(forms.map { $0.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression) })
    return forms
  }

  /// Returns feast IDs whose computed day equals `date` (Julian).
  /// - Notes: For movables we compute Easter once; for fixed we compare MonthDay.
  public func feasts(on date: JulianDate) -> [String] {
    let y = date.year
    let dateW0 = date.dayOfWeekIndex
    var out: [String] = []

    // Fixed
    for (id, md) in fixedByID {
      guard let (from,to) = validityByID[id], Self.yearAllowed(y, from: from, to: to) else { continue }
      if md.month == date.month && md.day == date.day {
        if let w = weekdayByID[id], let w, dateW0 != w { continue }
        out.append(id)
      }
    }

    // Movables
    let easter = JulianDate.dayOfEaster(year: y)
    for (id, delta) in movableByID {
      guard let (from,to) = validityByID[id], Self.yearAllowed(y, from: from, to: to) else { continue }
      var d = easter.dateAdding(days: delta)

      if let w = weekdayByID[id], let w {
        let dw0 = d.dayOfWeekIndex
        if dw0 != w {
          let adv = (w - dw0 + 7) % 7
          d = d.dateAdding(days: adv)
        }
      }
      if d == date { out.append(id) }
    }

    return out.sorted()
  }
}


#if DEBUG
public extension FeastRecordProvider {
  func _debugLookup(_ s: String) -> String? { feastID(forNormalizedVariant: s) }
}
#endif
