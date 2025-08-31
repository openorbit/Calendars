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



public enum LanguageMode { case latin, oldSwedish }

public enum MedievalDateNormalizer {
  public static func normalize(_ input: String, mode: LanguageMode) -> String {
    var s = input.precomposedStringWithCanonicalMapping
      .applyingTransform(.stripDiacritics, reverse: false) ?? input
    s = s.lowercased()

    // --- 1) Abbrev/ligature expansion (regex, token-safe) ---
    if mode == .latin {
      // Expand saint abbreviations robustly (no look-ahead; dot optional)
      s = s.replacingOccurrences(of: #"\b(?:s\.?|sci\.?|scti\.?)\b"#,
                                 with: "sancti",
                                 options: .regularExpression)

      // pridie forms: only if it's the short form "prid" as a whole word
      s = s.replacingOccurrences(of: #"\bprid\b\.?"#, with: "pridie",
                                 options: .regularExpression)

      // Common ligatures/marks
      let ligLatin: [String:String] = ["æ":"ae","œ":"oe","ſ":"s","⁊":"et","ꝯ":"con","ß":"ss"]
      s = s.applyMap(ligLatin)
    } else {
      // Old Swedish: S(ankte)/S(ankta) abbreviations seen in charters
      s = s.replacingOccurrences(of: #"\bs:ta\b"#, with: "sankta", options: .regularExpression)
      s = s.replacingOccurrences(of: #"\bs:t\b"#,  with: "sankt",  options: .regularExpression)
      let ligOSwe: [String:String] = ["æ":"ae","œ":"oe","ſ":"s","⁊":"och"]
      s = s.applyMap(ligOSwe)
      // Normalize ok/oc → och (common)
      s = s.replacingOccurrences(of: #"\b(?:ok|oc)\b"#, with: "och", options: .regularExpression)
    }

    // --- 2) Character folds (after regex expansions) ---
    switch mode {
    case .latin:
        // Latin-friendly folds
        let foldsLat: [String:String] = [
            "å":"aa","ä":"ae","ö":"oe",
            "j":"i","v":"u","w":"vv"   // ONLY in Latin
        ]
        s = s.applyMap(foldsLat)

    case .oldSwedish:
        // Keep only Nordic diacritics. DO NOT fold v/j here.
        let foldsOsw: [String:String] = [
            "å":"aa","ä":"ae","ö":"oe"
        ]
        s = s.applyMap(foldsOsw)
    }

    // --- 3) Whitespace collapse ---
    s = s.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    return s.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  public static func phoneticKey(_ input: String) -> String {
    var s = input.lowercased()
    let rules: [String:String] = ["aa":"a","ae":"e","oe":"e","vv":"w","ph":"f","th":"t","ch":"k","ck":"k"]
    s = s.applyMap(rules)
    s = s.replacingOccurrences(of: #"[^a-z]"#, with: "", options: .regularExpression)
    return s
  }
}
