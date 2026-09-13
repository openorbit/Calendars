import Testing
@testable import Calendars

@Test("Bundled NASA solar eclipse catalog is complete")
func bundledSolarEclipseCatalog() throws {
  let catalog = try SolarEclipseCatalog.loadBundled()
  #expect(catalog.eclipses.count == 11_898)
  #expect(catalog.eclipses.first?.year == -1999)
  #expect(catalog.eclipses.last?.year == 3000)
}

@Test("2024 total solar eclipse preserves NASA catalog data")
func totalSolarEclipse2024() throws {
  let catalog = try SolarEclipseCatalog.loadBundled()
  let eclipse = try #require(catalog.eclipses(fromYear: 2024, through: 2024).first {
    $0.month == 4 && $0.day == 8
  })
  #expect(eclipse.type == "T")
  #expect(abs(eclipse.julianDateTerrestrialDynamicalTime - 2_460_409.263) < 0.000_001)
  #expect(abs(eclipse.magnitude - 1.05655) < 0.000_01)
  #expect(eclipse.sarosNumber == 139)
  #expect(eclipse.besselianElements.count == 25)
  #expect(SolarEclipseCatalog.sourceAcknowledgement.contains("NASA/GSFC"))
}
