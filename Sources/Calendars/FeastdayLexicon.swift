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

public protocol LexiconProvider {
  var ordinals: [String:Int] { get }
  var connectors: [String:String] { get }
  var latinWeekdays: [String:Int] { get }
  var osweWeekdays: [String:Int] { get }
}

public final class StaticLexiconProvider: LexiconProvider {
  public let ordinals: [String:Int]
  public let connectors: [String:String]
  public let latinWeekdays: [String:Int]
  public let osweWeekdays: [String:Int]

  public init() {
    var o: [String:Int] = [:]

    // Latin ordinals (common forms)
    let latin: [(Int,[String])] = [
      (1, ["prima","primo","primus"]),
      (2, ["secunda","secundus","secundo"]),
      (3, ["tertia","tertius","tertio"]),
      (4, ["quarta","quartus","quarto"]),
      (5, ["quinta","quintus","quinto"]),
      (6, ["sexta","sextus","sexto"]),
      (7, ["septima","septimus","septimo"]),
      (8, ["octava","octavus","octavo"]),
      (9, ["nona","nonus","nono"]),
      (10,["decima","decimus","decimo"])
    ]
    for (v,forms) in latin { for f in forms { o[f] = v } }

    // Old Swedish ordinals (incl. medieval variants)
    let oswe: [(Int,[String])] = [
      (1, ["första","fyrsta","forsta","førsta"]),
      (2, ["andra","annra"]),
      (3, ["tredje","tredia","tredie"]),
      (4, ["fjärde","fjerde","fierde"]),
      (5, ["femte"]),
      (6, ["sjätte","sjette"]),
      (7, ["sjunde"]),
      (8, ["åttonde","ottande","attande"]),
      (9, ["nionde","niunde"]),
      (10,["tionde","tiunde"]),
      (11,["elfte","elfde"]),
      (12,["tolfte","tolvte"]),
      (13,["trettonde"]),
      (14,["fjortonde"]),
      (15,["femtonde"]),
      (16,["sextonde"]),
      (17,["sjuttonde"]),
      (18,["artonde","arton­de"]),
      (19,["nittonde"]),
      (20,["tjugonde"]),
      (21,["tjugoförsta","tjugoforsta"]),
      (22,["tjugoandra"]),
      (23,["tjugotredje"]),
      (24,["tjugofjärde","tjugofjarde"]),
      (25,["tjugofemte"]),
      (26,["tjugosjätte","tjugosjette"]),
      (27,["tjugosjunde"]),
      (28,["tjugoåttonde","tjugoattande"]),
      (29,["tjugonionde"]),
      (30,["trettionde"]),
      (31,["trettioförsta","trettioforsta"])
    ]
    for (v,forms) in oswe { for f in forms { o[f] = v } }

    self.ordinals = o.mapKeys { $0.lowercased() }

    // Connectors (Latin + Old Swedish)
    self.connectors = [
      "post": "+", "ante": "-",
      "efter": "+", "före": "-", "fore": "-",
      "in": "@", "på": "@", "paa": "@"
    ]

    // Weekday maps
    self.latinWeekdays = [
      "dominica":0,
      "feria secunda":1, "feria tertia":2, "feria quarta":3,
      "feria quinta":4, "feria sexta":5, "sabbatum":6
    ]
    self.osweWeekdays = [
      "söndag":0, "sondag":0,
      "måndag":1, "mandag":1,
      "tisdag":2,
      "onsdag":3,
      "torsdag":4,
      "fredag":5,
      "lördag":6, "lordag":6
    ]
  }
}

// Small dictionary helper
private extension Dictionary {
  func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T:Value] {
    var out: [T:Value] = [:]
    for (k,v) in self { out[transform(k)] = v }
    return out
  }
}

// Optional: normalization map (if you want to extend Normalizer at runtime)
public struct NormalizationMap: Codable {
  public let title: String
  public let language_specific_maps: LanguageSpecificMaps?
  public struct LanguageSpecificMaps: Codable {
    public let latin: LatinMap?
    public let old_swedish: OldSwedishMap?
    public struct LatinMap: Codable {
      public let prepositions: [String:String]?
      public let weekday_forms: [String:Int]?
    }
    public struct OldSwedishMap: Codable {
      public let connectors: [String:String]?
      public let weekday_forms: [String:Int]?
      public let ordinal_variants_to_normal: [String:String]?
      public let feast_variants_to_ids: [String:String]?
    }
  }
}


public final class LexiconProviderImpl: LexiconProvider {
  public private(set) var ordinals: [String:Int] = [:]
  public private(set) var connectors: [String:String] = [:]
  public private(set) var latinWeekdays: [String:Int] = [:]
  public private(set) var osweWeekdays: [String:Int] = [:]

  public init(lexicon: OrdinalLexiconDataset,
              normalization: NormalizationMap? = nil,
              feastHints: FeastDataset.ParsingHints? = nil)
  {
    if let lat = lexicon.lang["latin"] {
      for o in lat.ordinals { o.forms.forEach { ordinals[$0.lowercased()] = o.value } }
      if let m = lat.weekday_map_latin_to_index {
        for (k,v) in m { latinWeekdays[k.lowercased()] = v }
      }
    }
    if let osw = lexicon.lang["old_swedish"] {
      for o in osw.ordinals { o.forms.forEach { ordinals[$0.lowercased()] = o.value } }
    }
    // Connectors / weekday forms from normalization map if provided
    if let norm = normalization?.language_specific_maps {
      if let osw = norm.old_swedish?.connectors {
        for (k,v) in osw { connectors[k.lowercased()] = v }
      }
      if let latW = norm.latin?.weekday_forms {
        for (k,v) in latW { latinWeekdays[k.lowercased()] = v }
      }
      if let oswW = norm.old_swedish?.weekday_forms {
        for (k,v) in oswW { osweWeekdays[k.lowercased()] = v }
      }
    }
    // Fallbacks if weekdays empty
    if latinWeekdays.isEmpty {
      latinWeekdays = [
        "dominica":0,"feria secunda":1,"feria tertia":2,"feria quarta":3,"feria quinta":4,"feria sexta":5,"sabbatum":6
      ]
    }
    if osweWeekdays.isEmpty {
      osweWeekdays = [
        "söndag":0,"sondag":0,"måndag":1,"mandag":1,"tisdag":2,"onsdag":3,"torsdag":4,"fredag":5,"lördag":6,"lordag":6
      ]
    }
    // Fallback connectors, latin + swedish
    if connectors.isEmpty {
      connectors = ["post":"+","ante":"-","efter":"+","före":"-","fore":"-","in":"@","på":"@","paa":"@", "pa": "@"]
    }
  }
}

/// Ordinal & relative-day lexicon
public struct OrdinalLexiconDataset: Codable {
  public struct Lang: Codable {
    public struct Ord: Codable { public let value: Int; public let forms: [String] }
    public let notes: String?
    public let ordinals: [Ord]
    public let relative_day_words: [RelativeWord]?
    public struct RelativeWord: Codable { public let delta_days: Int; public let forms: [String] }
    public let weekday_map_latin_to_index: [String:Int]? // we’ll support hints here too
  }
  public let title: String
  public let lang: [String: Lang] // "latin", "old_swedish"
}
