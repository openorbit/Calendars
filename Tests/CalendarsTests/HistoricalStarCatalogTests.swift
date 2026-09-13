import Testing
@testable import Calendars

@Test("Bundled historical star catalogue decodes")
func bundledHistoricalStarCatalogueDecodes() throws {
  let catalogue = try HistoricalStarCatalog.loadBundled()

  #expect(catalogue.stars.count == 8_984)
  #expect(catalogue.stars.map(\.brightStarNumber) == catalogue.stars.map(\.brightStarNumber).sorted())
}

@Test("Sirius is linked to its improved Hipparcos astrometry")
func siriusUsesHipparcos2Astrometry() throws {
  let catalogue = try HistoricalStarCatalog.loadBundled()
  let sirius = try #require(catalogue.star(brightStarNumber: 2_491))

  #expect(sirius.hipparcosIdentifier == 32_349)
  #expect(sirius.henryDraperIdentifier == 48_915)
  #expect(sirius.designation == "9Alp CMa")
  #expect(sirius.visualMagnitude < -1.4)
  #expect(sirius.parallaxMilliarcseconds > 370)
  #expect(sirius.radialVelocityKilometersPerSecond != nil)
}
