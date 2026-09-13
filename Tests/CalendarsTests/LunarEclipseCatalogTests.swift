import Testing
@testable import Calendars

@Test("Bundled NASA lunar eclipse catalog is complete")
func bundledLunarEclipseCatalog() throws {
  let catalog = try LunarEclipseCatalog.loadBundled()
  #expect(catalog.eclipses.count == 12_064)
  #expect(catalog.eclipses.first?.year == -1999)
  #expect(catalog.eclipses.last?.year == 3000)
}

@Test("Lunar eclipse before the Battle of Pydna preserves NASA catalog data")
func lunarEclipseAtPydna() throws {
  let catalog = try LunarEclipseCatalog.loadBundled()
  let eclipse = try #require(catalog.eclipses(fromYear: -167, through: -167).first {
    $0.month == 6 && $0.day == 21
  })
  #expect(eclipse.type == "T")
  #expect(eclipse.greatestEclipseSeconds == 22 * 3_600 + 4 * 60 + 14)
  #expect(abs(eclipse.penumbralMagnitude - 2.3071) < 0.000_1)
  #expect(abs(eclipse.umbralMagnitude - 1.2517) < 0.000_1)
  #expect(eclipse.sarosNumber == 56)
  #expect(LunarEclipseCatalog.sourceAcknowledgement.contains("NASA/GSFC"))
}
