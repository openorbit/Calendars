import Testing
@testable import Calendars

private struct HistoricalSolarAnchor: Sendable {
  let event: String
  let year: Int
  let month: Int
  let day: Int
  let type: String
  let saros: Int
}

private struct HistoricalLunarAnchor: Sendable {
  let event: String
  let year: Int
  let month: Int
  let day: Int
  let type: String
  let saros: Int
}

// NASA dates before 1582 are Julian and use astronomical year numbering:
// 585 BCE is year -584, for example.
@Test("Historically associated solar eclipses preserve their Julian dates")
func historicalSolarEclipseAnchors() throws {
  let anchors = [
    // Proposed identification of Joshua 10:12–13; the historical interpretation is disputed.
    // https://academic.oup.com/astrogeo/article/58/5/5.39/4159289
    HistoricalSolarAnchor(
      event: "Joshua/Gibeon candidate", year: -1206, month: 10, day: 30, type: "A", saros: 43),
    // Conventional identification; Herodotus does not supply an exact date and alternatives exist.
    // https://eclipse.gsfc.nasa.gov/SEhistory/SEhistory.html
    HistoricalSolarAnchor(
      event: "Battle of Halys candidate", year: -584, month: 5, day: 28, type: "T", saros: 57),
    // Herodotus IX.10; associated with the Persian campaign rather than securely with its outset.
    // https://eclipse.gsfc.nasa.gov/SEhistory/SEhistory.html
    HistoricalSolarAnchor(
      event: "Xerxes campaign eclipse", year: -479, month: 10, day: 2, type: "A", saros: 65),
    // Diodorus 20.5.5 dates the eclipse to the morning after the fleet escaped Syracuse.
    // https://penelope.uchicago.edu/Thayer/E/Roman/Texts/Diodorus_Siculus/20a*.html
    HistoricalSolarAnchor(
      event: "Agathocles fleet escape", year: -309, month: 8, day: 15, type: "T", saros: 69),
    // This eclipse has been proposed in reconstructions of Zama, but it does not securely date the battle.
    // https://www.perseus.tufts.edu/hopper/text?doc=Perseus:text:1999.02.0159:book=back:chapter=1
    HistoricalSolarAnchor(
      event: "Battle of Zama candidate", year: -201, month: 10, day: 19, type: "T", saros: 69),
  ]
  let catalog = try SolarEclipseCatalog.loadBundled()

  for anchor in anchors {
    let eclipse = try #require(catalog.eclipses(fromYear: anchor.year, through: anchor.year).first {
      $0.month == anchor.month && $0.day == anchor.day
    }, "Missing eclipse associated with \(anchor.event)")
    let civilJDN = Int(eclipse.julianDateTerrestrialDynamicalTime + 0.5)

    #expect(eclipse.type == anchor.type, "Unexpected eclipse type for \(anchor.event)")
    #expect(eclipse.sarosNumber == anchor.saros, "Unexpected Saros series for \(anchor.event)")
    #expect(civilJDN == JulianCalendar.toJDN(
      Y: anchor.year, M: anchor.month, D: anchor.day),
      "NASA Julian date disagrees with Calendars conversion for \(anchor.event)")
  }
}

@Test("Historically observed lunar eclipses preserve their Julian dates")
func historicalLunarEclipseAnchors() throws {
  let anchors = [
    // Thucydides 7.50: the eclipse began on the evening of 27 August at Syracuse;
    // the NASA catalog date is 28 August because greatest eclipse followed midnight.
    HistoricalLunarAnchor(
      event: "Athenian withdrawal from Syracuse", year: -412, month: 8, day: 28,
      type: "T", saros: 60),
    // Babylonian astronomical diary and classical accounts; eleven days before Gaugamela.
    // https://www.livius.org/articles/battle/gaugamela-331-bce/
    HistoricalLunarAnchor(
      event: "Battle of Gaugamela", year: -330, month: 9, day: 20,
      type: "T", saros: 51),
    // The eclipse on the night of 21–22 June preceded the battle on 22 June 168 BCE.
    // https://www.livius.org/articles/battle/pydna-168-bce/
    HistoricalLunarAnchor(
      event: "Battle of Pydna", year: -167, month: 6, day: 21,
      type: "T", saros: 56),
    // Observed during the siege, seven days before the city fell.
    // https://eclipse.gsfc.nasa.gov/LEcat5/LE1401-1500.html
    HistoricalLunarAnchor(
      event: "Fall of Constantinople", year: 1453, month: 5, day: 22,
      type: "P", saros: 102),
  ]
  let catalog = try LunarEclipseCatalog.loadBundled()

  for anchor in anchors {
    let eclipse = try #require(catalog.eclipses(fromYear: anchor.year, through: anchor.year).first {
      $0.month == anchor.month && $0.day == anchor.day
    }, "Missing eclipse associated with \(anchor.event)")
    let civilJDN = Int(eclipse.julianDateTerrestrialDynamicalTime + 0.5)

    #expect(eclipse.type.hasPrefix(anchor.type), "Unexpected eclipse type for \(anchor.event)")
    #expect(eclipse.sarosNumber == anchor.saros, "Unexpected Saros series for \(anchor.event)")
    #expect(civilJDN == JulianCalendar.toJDN(
      Y: anchor.year, M: anchor.month, D: anchor.day),
      "NASA Julian date disagrees with Calendars conversion for \(anchor.event)")
  }
}

@Test("Eclipse anchors reproduce documented event intervals")
func historicalEclipseIntervals() {
  let agathoclesEscape = JulianCalendar.toJDN(Y: -309, M: 8, D: 14)
  let agathoclesEclipse = JulianCalendar.toJDN(Y: -309, M: 8, D: 15)
  #expect(agathoclesEclipse - agathoclesEscape == 1)

  let gaugamelaEclipse = JulianCalendar.toJDN(Y: -330, M: 9, D: 20)
  let gaugamelaBattle = JulianCalendar.toJDN(Y: -330, M: 10, D: 1)
  #expect(gaugamelaBattle - gaugamelaEclipse == 11)

  let pydnaEclipse = JulianCalendar.toJDN(Y: -167, M: 6, D: 21)
  let pydnaBattle = JulianCalendar.toJDN(Y: -167, M: 6, D: 22)
  #expect(pydnaBattle - pydnaEclipse == 1)

  let constantinopleEclipse = JulianCalendar.toJDN(Y: 1453, M: 5, D: 22)
  let fallOfConstantinople = JulianCalendar.toJDN(Y: 1453, M: 5, D: 29)
  #expect(fallOfConstantinople - constantinopleEclipse == 7)
}
