import Foundation
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

@Test("2024 calculated central path agrees with NASA path table")
func totalSolarEclipsePath2024() throws {
  let catalog = try SolarEclipseCatalog.loadBundled()
  let eclipse = try #require(catalog.eclipses(fromYear: 2024, through: 2024).first {
    $0.month == 4 && $0.day == 8
  })
  let path = try #require(SolarEclipsePathCalculator.path(for: eclipse))

  let centralError = path.centralLine.map {
    hypot($0.latitude - 25.485, $0.longitude + 103.947)
  }.min() ?? .infinity
  let northernError = path.northernLimit.map {
    hypot($0.latitude - 26.098, $0.longitude + 104.663)
  }.min() ?? .infinity
  let southernError = path.southernLimit.map {
    hypot($0.latitude - 24.872, $0.longitude + 103.237)
  }.min() ?? .infinity
  #expect(centralError < 0.35)
  #expect(northernError < 0.35)
  #expect(southernError < 0.35)
}

@Test("2026 central path limits remain on continuous branches")
func totalSolarEclipsePath2026DoesNotCrossNearBiscay() throws {
  let catalog = try SolarEclipseCatalog.loadBundled()
  let eclipse = try #require(catalog.eclipses(fromYear: 2026, through: 2026).first {
    $0.month == 8 && $0.day == 12
  })
  let path = try #require(SolarEclipsePathCalculator.path(for: eclipse))
  let northernSegments = zip(path.northernLimit, path.northernLimit.dropFirst())
  let southernSegments = Array(zip(path.southernLimit, path.southernLimit.dropFirst()))

  let crossesNearBiscay = northernSegments.contains { northern in
    guard biscayRegionContains(northern.0) || biscayRegionContains(northern.1) else {
      return false
    }
    return southernSegments.contains {
      segmentsIntersect(northern.0, northern.1, $0.0, $0.1)
    }
  }
  #expect(!crossesNearBiscay)
}

private func biscayRegionContains(_ point: EclipseCoordinate) -> Bool {
  (35...55).contains(point.latitude) && (-30...10).contains(point.longitude)
}

private func segmentsIntersect(
  _ a: EclipseCoordinate, _ b: EclipseCoordinate,
  _ c: EclipseCoordinate, _ d: EclipseCoordinate
) -> Bool {
  func orientation(
    _ p: EclipseCoordinate, _ q: EclipseCoordinate, _ r: EclipseCoordinate
  ) -> Double {
    (q.longitude - p.longitude) * (r.latitude - p.latitude)
      - (q.latitude - p.latitude) * (r.longitude - p.longitude)
  }
  let first = orientation(a, b, c)
  let second = orientation(a, b, d)
  let third = orientation(c, d, a)
  let fourth = orientation(c, d, b)
  return first * second < 0 && third * fourth < 0
}
