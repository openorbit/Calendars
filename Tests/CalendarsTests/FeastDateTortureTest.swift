//
//  FeastDateTortureTest.swift
//  Calendars
//
//  Created by Mattias Holm on 2025-08-30.
//

import Testing
@testable import Calendars

@Suite
struct VariantIndexingRegressions {
  fileprivate let fx = SwedishFeasts()

  @Test
  func latin_u_v_and_i_j_equivalence() {
    let p = fx.feasts
    #expect(p.feastID(forNormalizedVariant: "sancti olaui") == "ST_OLAF")   // v→u
    #expect(p.feastID(forNormalizedVariant: "olaui") == "ST_OLAF")
    #expect(p.feastID(forNormalizedVariant: "s laurentii") == "ST_LAWRENCE") // abbrev sans dot
  }

  @Test
  func oswe_valborg_variants() {
    let p = fx.feasts
    #expect(p.feastID(forNormalizedVariant: "valborg") == "PHILIP_JAMES")
    #expect(p.feastID(forNormalizedVariant: "valborgsmassa") == "PHILIP_JAMES") // diacritic-stripped
    #expect(p.feastID(forNormalizedVariant: "valborgsmäss") == "PHILIP_JAMES")
  }
}

// MARK: - Latin parsing breadth

@Suite
struct LatinParsing {
  fileprivate let fx = SwedishFeasts()

  // “pridie s. Laurentii” → Aug 9 (1400)
  @Test
  func pridie_genitive() throws {
    let out = try #require(fx.resolve(1400, "pridie s. Laurentii"))
    #expect(out.anchor == JulianDate(year: 1400, month: 8, day: 10))
    #expect(out.computed == JulianDate(year: 1400, month: 8, day: 9))
  }

  // “postridie s. Olavi” → Jul 30 (1300)
  @Test
  func postridie() throws {
    let out = try #require(fx.resolve(1300, "postridie s. Olavi"))
    #expect(out.anchor == JulianDate(year: 1300, month: 7, day: 29))
    #expect(out.computed == JulianDate(year: 1300, month: 7, day: 30))
  }

  // “perendie s. Olavi” → Jul 31 (1300)
  @Test
  func perendie() throws {
    let out = try #require(fx.resolve(1300, "perendie s. Olavi"))
    #expect(out.computed == JulianDate(year: 1300, month: 7, day: 31))
  }

  // “tertia post festum s. Olavi” → Aug 1 (1300)
  @Test
  func tertia_post() throws {
    let out = try #require(fx.resolve(1300, "tertia post festum s. Olavi"))
    #expect(out.computed == JulianDate(year: 1300, month: 8, day: 1))
  }

  // Reversed order: “post diem tertiam s. Olavi” → Aug 1 (1300)
  @Test
  func post_diem_tertiam() throws {
    let out = try #require(fx.resolve(1300, "post diem tertiam s. Olavi"))
    #expect(out.computed == JulianDate(year: 1300, month: 8, day: 1))
  }

  // Ablative ordinal: “tertio die post s. Olavi” → Aug 1 (1300)
  @Test
  func tertio_die_post() throws {
    let out = try #require(fx.resolve(1300, "tertio die post s. Olavi"))
    #expect(out.computed == JulianDate(year: 1300, month: 8, day: 1))
  }

  // Negative offset: “ante diem quartum s. Michaelis” → Sep 25 (1400)
  @Test
  func ante_diem_quartum() throws {
    let out = try #require(fx.resolve(1400, "ante diem quartum s. Michaelis"))
    #expect(out.anchor == JulianDate(year: 1400, month: 9, day: 29))
    #expect(out.computed == JulianDate(year: 1400, month: 9, day: 25))
  }

  // Octave: “in octava s. Laurentii” → Aug 17 (1400)
  @Test
  func in_octava() throws {
    let out = try #require(fx.resolve(1400, "in octava s. Laurentii"))
    #expect(out.computed == JulianDate(year: 1400, month: 8, day: 17))
  }

  // Weekday-specific movable: “in feria secunda Paschae” → no double-snap (Apr 11, 1300)
  @Test
  func easter_monday_no_double_snap() throws {
    let out = try #require(fx.resolve(1300, "in feria secunda Paschae"))
    #expect(out.computed == JulianDate(year: 1300, month: 4, day: 11))
  }

  // Corpus Christi (genitive): “in festo Corporis Christi” (Easter +60; 1400-06-17)
  @Test
  func corpus_christi_genitive() throws {
    let out = try #require(fx.resolve(1400, "in festo Corporis Christi"))
    #expect(out.computed == JulianDate(year: 1400, month: 6, day: 17))
  }

  // Marian ablative: “in annuntiatione beatae Mariae” → Mar 25
  @Test
  func annuntiatione_bmv() throws {
    let out = try #require(fx.resolve(1300, "in annuntiatione beatae Mariae"))
    #expect(out.computed == JulianDate(year: 1300, month: 3, day: 25))
  }

  // Bare saint (no “sancti”): “in die Laurentii” → Aug 10
  @Test
  func bare_genitive() throws {
    let out = try #require(fx.resolve(1400, "in die Laurentii"))
    #expect(out.computed == JulianDate(year: 1400, month: 8, day: 10))
  }

  // Weekday snap after offset: “feria quinta post s. Olavi” → first Thursday on/after (Jul 29) = Aug 1, 1300 is Friday? check:
  // We assert weekday and on/after, not the exact date (computus-independent).
  @Test
  func weekday_snap_after() throws {
    let out = try #require(fx.resolve(1300, "feria quinta post s. Olavi"))
    #expect(out.computed.dayOfWeekIndex == 4) // Thursday
    let jA = out.anchor.jdn
    let jC = out.computed.jdn
    #expect(jC >= jA)
  }
}

// MARK: - Old Swedish parsing breadth

@Suite
struct OldSwedishParsing {
  fileprivate let fx = SwedishFeasts()

  // After Olsmässa variants (mässa/messa/mæssa/massa)
  @Test
  func efter_olsmassa_variants() throws {
    let phrases = [
      "i tredje dagen efter Olsmässa",
      "i tredje dagen efter Olsmessa",
      "i tredje dagen efter Olsmæssa",
      "i tredie dagen efter Olsmassa" // normalized variant
    ]
    for ph in phrases {
      let out = try #require(fx.resolve(1300, ph))
      #expect(out.anchor == JulianDate(year: 1300, month: 7, day: 29))
      #expect(out.computed == JulianDate(year: 1300, month: 8, day: 1))
    }
  }

  // “dagen före Mickelsmässa” → Sep 28 (1400)
  @Test
  func dagen_fore_michael() throws {
    let out = try #require(fx.resolve(1400, "dagen före Mickelsmässa"))
    #expect(out.computed == JulianDate(year: 1400, month: 9, day: 28))
  }

  // Short Valborg (anchor only) → May 1 (1300)
  @Test
  func pa_valborg_short() throws {
    let out = try #require(fx.resolve(1300, "på Valborg"))
    #expect(out.computed == JulianDate(year: 1300, month: 5, day: 1))
  }

  // Weekday Swedish: “måndag efter Larsmässa” → snap on/after
  @Test
  func mandag_efter_larsmassa() throws {
    let out = try #require(fx.resolve(1300, "måndag efter Larsmässa"))
    #expect(out.computed.dayOfWeekIndex == 1) // Monday
    let jA = out.anchor.jdn
    let jC = out.computed.jdn
    #expect(jC >= jA)
  }
}

@Suite
struct ModeHeuristics {
  fileprivate let fx = SwedishFeasts()

  @Test
  func latin_phrase_detects_latin() {
    // Had failed before; ensure it stays Latin:
    let phrase = "tertia post festum s. Olavi"
    let p = fx.parser.parse(phrase)
    #expect(p != nil)
    #expect(p?.notes == "Latin-mode parse")
    #expect(p?.offsetDays == 3)
  }

  @Test
  func swedish_phrase_detects_oswe() {
    let p = fx.parser.parse("dagen före Mickelsmässa")
    #expect(p != nil)
    #expect(p?.notes == "Old Swedish-mode parse")
    #expect(p?.offsetDays == -1)
  }
}

@Test
func test_it_works() {
  let fx = SwedishFeasts()

  #expect(fx.feasts._debugLookup("sancti olaui") == "ST_OLAF")
  #expect(fx.feasts._debugLookup("valborgsmassa") == "PHILIP_JAMES")
  #expect(fx.feasts._debugLookup("corporis christi") == "CORPUS_CHRISTI")
  #expect(fx.feasts._debugLookup("olsmessa") == "ST_OLAF")
  #expect(fx.resolve(1400, "ante diem quartum s. Michaelis")?.computed
          == JulianDate(year: 1400, month: 9, day: 25))
}



@Test
func latin_variants_exist() {
  let p = SwedishFeasts().feasts
  #expect(p.feastID(forNormalizedVariant: "sancti olavi") == "ST_OLAF")
  #expect(p.feastID(forNormalizedVariant: "corporis christi") == "CORPUS_CHRISTI")
  #expect(p.feastID(forNormalizedVariant: "laurentii") == "ST_LAWRENCE")
}


@Test
func michaelmas_reverse_lookup() {
  let fx = SwedishFeasts()
  let d = JulianDate(year: 1400, month: 9, day: 29)
  let occ = feasts(on: d, using: fx.feasts)   // FeastCatalog + Provider
  #expect(occ.contains { $0.id == "ST_MICHAEL" })
}


struct FeastProviderNamesTests {

  // Helper to build a region-configured provider
  private func makeProvider(_ regions: Set<FeastRecord.RegionTag>) -> FeastRecordProvider {
    FeastRecordProvider(records: feastRecords,
                        config: .init(activeRegions: regions))
  }

  @Test
  func names_for_ST_OLAF_in_Sweden_includes_sv_old_and_Latin() {
    let provider = makeProvider([.universal, .scandinavia, .sweden])

    // effective record exists
    let eff = provider.effectiveRecord(for: "ST_OLAF")
    #expect(eff != nil)
    #expect(eff?.julianFixed?.month == 7)
    #expect(eff?.julianFixed?.day == 29)

    // names() groups by language and dedupes
    let names = provider.names(for: "ST_OLAF")
    // Latin bucket present
    #expect(names["la"]?.contains(where: { $0.contains("olavi") }) == true)
    // Swedish medieval bucket present and includes common forms
    let sv = names["sv_old"] ?? []
    #expect(sv.contains("olsmässa"))
    #expect(sv.contains("olsmessa") || sv.contains("olsmæssa"))

    // Danish/Norwegian buckets should not appear when only .sweden is active
    #expect(names["da_old"] == nil)
    #expect(names["no_old"] == nil)
  }

  @Test
  func names_for_PHILIP_JAMES_in_Denmark_has_da_old_valborg_but_not_sv_old() {
    let provider = makeProvider([.universal, .scandinavia, .denmark])

    let names = provider.names(for: "PHILIP_JAMES")
    // Latin present
    #expect(names["la"]?.contains("ss philippi et iacobi") == true)

    // Danish vernacular present
    let da = names["da_old"] ?? []
    #expect(da.contains("valborg"))
    #expect(da.contains("valborgsaften"))

    // Swedish vernacular absent in DK config
    #expect(names["sv_old"] == nil)
  }

  @Test
  func names_are_deduplicated_and_sorted() {
    let provider = makeProvider([.universal, .scandinavia, .sweden])
    let names = provider.names(for: "CANDLEMAS")

    // Should have a Swedish bucket with no duplicates
    let sv = names["sv_old"] ?? []
    let setCount = Set(sv).count
    #expect(sv.count == setCount) // deduped

    // Basic monotonic check for sorting (lexicographic)
    #expect(sv == sv.sorted())
  }

  @Test
  func normalized_variants_can_include_valborg_spellings() {
    // Only run if you added `normalizedVariants(for:)`
    let provider = makeProvider([.universal, .scandinavia, .sweden])

    // Safeguard: if the helper isn’t present, skip gracefully
#if compiler(>=6.0)
    if let _: (String) -> [String] = {
      // reflectively check existence; or just call if it's definitely there
      provider.normalizedVariants
    } as? ((String) -> [String]) {
      let variants = provider.normalizedVariants(for: "PHILIP_JAMES")
      // Expect folded forms for Valborg to be indexed
      // (Your variantKeys should fold diacritics; "valborgsmassa" is the ascii fold of "valborgsmässa")
      #expect(variants.contains("valborgsmassa"))
      #expect(variants.contains("valborg"))
    } else {
      // If helper not present, at least assert names(for:) has sv_old bucket
      let names = provider.names(for: "PHILIP_JAMES")
      #expect(names["sv_old"]?.isEmpty == false)
    }
#else
    let names = provider.names(for: "PHILIP_JAMES")
    #expect(names["sv_old"]?.isEmpty == false)
#endif
  }
}


struct FeastReverseLookupTests {

  // Helper to build a region-configured provider (Scandinavia is fine; all universals are included)
  private func makeProvider(_ regions: Set<FeastRecord.RegionTag> = [.universal, .scandinavia, .sweden]) -> FeastRecordProvider {
    FeastRecordProvider(records: feastRecords,
                        config: .init(activeRegions: regions))
  }

  @Test
  func fixed_ST_OLAF_on_1300_07_29() {
    let p = makeProvider()
    let d = JulianDate(year: 1300, month: 7, day: 29)
    let ids = p.feasts(on: d)
    #expect(ids.contains("ST_OLAF"))
  }

  @Test
  func fixed_ST_MICHAEL_on_1400_09_29() {
    let p = makeProvider()
    let d = JulianDate(year: 1400, month: 9, day: 29)
    let ids = p.feasts(on: d)
    #expect(ids.contains("ST_MICHAEL"))
  }

  @Test
  func movable_EASTER_MONDAY_on_easter_plus_1_1300() {
    let p = makeProvider()
    let easter = JulianDate.dayOfEaster(year: 1300)        // Julian Easter Sunday
    let easterMonday = easter.dateAdding(days: 1)
    // sanity: monday
    #expect(easterMonday.dayOfWeek == 2)
    let ids = p.feasts(on: easterMonday)
    #expect(ids.contains("EASTER_MONDAY"))
  }

  @Test
  func movable_CORPUS_CHRISTI_easter_plus_60_1400_and_is_thursday() {
    let p = makeProvider()
    let easter = JulianDate.dayOfEaster(year: 1400)
    let cc = easter.dateAdding(days: 60)
    // identity should be Thursday for our dataset
    #expect(cc.dayOfWeek == 5)
    let ids = p.feasts(on: cc)
    #expect(ids.contains("CORPUS_CHRISTI"))
  }

  @Test
  func movable_CORPUS_CHRISTI_not_listed_before_1264() {
    let p = makeProvider()
    let easter1200 = JulianDate.dayOfEaster(year: 1200)
    let cc1200 = easter1200.dateAdding(days: 60)
    let ids = p.feasts(on: cc1200)
    #expect(!ids.contains("CORPUS_CHRISTI"))
  }

  @Test
  func movable_TRINITY_SUNDAY_easter_plus_56_is_sunday() {
    let p = makeProvider()
    let easter = JulianDate.dayOfEaster(year: 1350)
    let trinity = easter.dateAdding(days: 56)
    #expect(trinity.dayOfWeek == 1)  // Sunday
    let ids = p.feasts(on: trinity)
    #expect(ids.contains("TRINITY_SUNDAY"))
  }
}

struct MedievalNordicParserTests {
  let fx = SwedishFeasts()

  // Latin: “pridie s. Laurentii” → anchor = St Lawrence (Aug 10), computed = Aug 9
  @Test
  func latin_pridie_lawrence_fixed() throws {
    let year = 1400
    let out = try #require(fx.resolve(year, "pridie s. Laurentii"))
    #expect(out.anchor == JulianDate(year: year, month: 8, day: 10))
    #expect(out.computed == JulianDate(year: year, month: 8, day: 9))
    #expect(out.usedWeekday == nil)
  }

  // Old Swedish: “i tredje dagen efter Olsmässa” → +3 from July 29 → Aug 1
  @Test
  func oswe_third_day_after_olsmassa() throws {
    let year = 1300
    let out = try #require(fx.resolve(year, "i tredje dagen efter Olsmässa"))
    #expect(out.anchor == JulianDate(year: year, month: 7, day: 29))
    #expect(out.computed == JulianDate(year: year, month: 8, day: 1))
  }

  // Latin weekday snap: “feria secunda post festum s. Michaelis”
  // Monday ON/AFTER Sep 29
  @Test
  func latin_monday_after_michaelmas() throws {
    let year = 1400
    let out = try #require(fx.resolve(year, "feria secunda post festum s. Michaelis"))
    #expect(out.anchor == JulianDate(year: year, month: 9, day: 29))
    // Monday = 1 with our weekday map; snap is on/after anchor
    #expect(out.computed.dayOfWeekIndex == 1)
    let jA = out.anchor.jdn
    let jC = out.computed.jdn
    #expect(jC >= jA)
  }

  // Movable feast: “in feria secunda Paschae” (Easter Monday)
  // 1300 Easter (Julian) = Apr 10 → Easter Monday = Apr 11
  @Test
  func latin_easter_monday_1300() throws {
    let year = 1300
    let out = try #require(fx.resolve(year, "in feria secunda Paschae"))
    // Our static provider defines EASTER_MONDAY as +1 from Easter; resolver uses that as ANCHOR.
    let expected = JulianDate.dayOfEaster(year: year)
    let easterMonday = expected.dateAdding(days: 1)
    #expect(out.anchor == easterMonday)
    #expect(out.computed == easterMonday)
  }

  // Movable feast: “Corpus Christi” = Easter + 60 days
  // 1400 Easter = Apr 18 (Julian) → +60 = Jun 17 (Julian)
  @Test
  func latin_corpus_christi_1400() throws {
    let year = 1400
    let out = try #require(fx.resolve(year, "in festo Corporis Christi"))
    let easter = JulianDate.dayOfEaster(year: year)
    let expected = easter.dateAdding(days: 60)
    #expect(out.anchor == expected)     // anchor is already the moved base
    #expect(out.computed == expected)
  }

  // Variant/short form: “på Valborg” → May 1
  @Test
  func oswe_valborg_short() throws {
    let year = 1300
    let out = try #require(fx.resolve(year, "på Valborg"))
    #expect(out.anchor == JulianDate(year: year, month: 5, day: 1))
    #expect(out.computed == out.anchor)
  }

  // Latin: ordinal + post → “tertia post festum s. Olavi” = +3 from July 29 → Aug 1
  @Test
  func latin_tertia_post_olaf() throws {
    let year = 1300
    let out = try #require(fx.resolve(year, "tertia post festum s. Olavi"))
    #expect(out.anchor == JulianDate(year: year, month: 7, day: 29))
    #expect(out.computed == JulianDate(year: year, month: 8, day: 1))
  }

  // Old Swedish: “dagen före Mickelsmässa” → Sep 28
  @Test
  func oswe_day_before_michaelmas() throws {
    let year = 1400
    let out = try #require(fx.resolve(year, "dagen före Mickelsmässa"))
    #expect(out.anchor == JulianDate(year: year, month: 9, day: 29))
    #expect(out.computed == JulianDate(year: year, month: 9, day: 28))
  }
}


@Test
func oswe_variant_generation_catches_olsmassa() throws {
  let fx = SwedishFeasts()
  let p = fx.feasts
  #expect(p.feastID(forNormalizedVariant: "olsmassa") == "ST_OLAF")
  #expect(p.feastID(forNormalizedVariant: "s laurentii") == "ST_LAWRENCE")
}

@Test
func latin_anchor_u_v_fold_hits_olaui() {
  let fx = SwedishFeasts()
  let p = fx.feasts
  #expect(p.feastID(forNormalizedVariant: "sancti olaui") == "ST_OLAF")
  #expect(p.feastID(forNormalizedVariant: "olaui") == "ST_OLAF")
}

