import Foundation

public struct EclipseCoordinate: Equatable, Sendable {
  public let latitude: Double
  public let longitude: Double

  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
}

public struct SolarEclipsePath: Equatable, Sendable {
  public let northernLimit: [EclipseCoordinate]
  public let centralLine: [EclipseCoordinate]
  public let southernLimit: [EclipseCoordinate]
}

public enum SolarEclipsePathCalculator {
  /// Calculates the central path at two-minute intervals using the catalog's
  /// polynomial Besselian elements and WGS-84 reduced latitude.
  public static func path(for eclipse: SolarEclipse) -> SolarEclipsePath? {
    guard eclipse.type.first != "P", eclipse.besselianElements.count == 25 else { return nil }
    let elements = Elements(eclipse.besselianElements)
    var north: [EclipseCoordinate] = []
    var center: [EclipseCoordinate] = []
    var south: [EclipseCoordinate] = []
    var t = elements.minimumHour
    while t <= elements.maximumHour + 0.000_001 {
      if let central = inverse(x: elements.x(t), y: elements.y(t), at: t, elements: elements, eclipse: eclipse) {
        center.append(central.coordinate)
        let velocity = elements.velocity(t)
        let speed = hypot(velocity.x, velocity.y)
        if speed > 0 {
          let normal = (x: -velocity.y / speed, y: velocity.x / speed)
          let radius = abs(elements.l2(t) - central.zeta * elements.tangentF2)
          if let southern = solveLimit(
            t: t,
            offsetX: -radius * normal.x,
            offsetY: -radius * normal.y,
            elements: elements,
            eclipse: eclipse
          ) {
            south.append(southern)
          }
          if let northern = solveLimit(
              t: t,
              offsetX: radius * normal.x,
              offsetY: radius * normal.y,
              elements: elements,
              eclipse: eclipse
          ) {
            north.append(northern)
          }
        }
      }
      t += 1.0 / 30.0
    }
    guard center.count > 1 else { return nil }
    return SolarEclipsePath(northernLimit: north, centralLine: center, southernLimit: south)
  }

  private static func solveLimit(
    t: Double,
    offsetX: Double,
    offsetY: Double,
    elements: Elements,
    eclipse: SolarEclipse
  ) -> EclipseCoordinate? {
    guard let seed = inverse(
      x: elements.x(t) + offsetX, y: elements.y(t) + offsetY,
      at: t, elements: elements, eclipse: eclipse
    ) else { return nil }
    var latitude = seed.coordinate.latitude * .pi / 180
    var longitude = seed.coordinate.longitude * .pi / 180
    let h = 0.000_001
    for _ in 0..<12 {
      let a = boundary(latitude, longitude, t, elements, eclipse)
      let b = boundaryTimeDerivative(latitude, longitude, t, elements, eclipse)
      let aLat = (boundary(latitude + h, longitude, t, elements, eclipse)
        - boundary(latitude - h, longitude, t, elements, eclipse)) / (2 * h)
      let aLon = (boundary(latitude, longitude + h, t, elements, eclipse)
        - boundary(latitude, longitude - h, t, elements, eclipse)) / (2 * h)
      let bLat = (boundaryTimeDerivative(latitude + h, longitude, t, elements, eclipse)
        - boundaryTimeDerivative(latitude - h, longitude, t, elements, eclipse)) / (2 * h)
      let bLon = (boundaryTimeDerivative(latitude, longitude + h, t, elements, eclipse)
        - boundaryTimeDerivative(latitude, longitude - h, t, elements, eclipse)) / (2 * h)
      let determinant = aLat * bLon - aLon * bLat
      guard determinant.isFinite, abs(determinant) > 1e-12 else { return nil }
      latitude += (-a * bLon + aLon * b) / determinant
      longitude += (-aLat * b + a * bLat) / determinant
    }
    guard latitude.isFinite, longitude.isFinite, abs(latitude) <= .pi / 2 else { return nil }
    return EclipseCoordinate(
      latitude: latitude * 180 / .pi,
      longitude: normalizedLongitude(longitude * 180 / .pi)
    )
  }

  private static func boundary(
    _ latitude: Double, _ longitude: Double, _ t: Double,
    _ elements: Elements, _ eclipse: SolarEclipse
  ) -> Double {
    let observer = observer(latitude, longitude, t, elements, eclipse)
    let radius = elements.l2(t) - observer.zeta * elements.tangentF2
    return pow(elements.x(t) - observer.x, 2) + pow(elements.y(t) - observer.y, 2)
      - radius * radius
  }

  private static func boundaryTimeDerivative(
    _ latitude: Double, _ longitude: Double, _ t: Double,
    _ elements: Elements, _ eclipse: SolarEclipse
  ) -> Double {
    let h = 0.000_01
    return (boundary(latitude, longitude, t + h, elements, eclipse)
      - boundary(latitude, longitude, t - h, elements, eclipse)) / (2 * h)
  }

  private static func observer(
    _ latitude: Double, _ longitude: Double, _ t: Double,
    _ elements: Elements, _ eclipse: SolarEclipse
  ) -> (x: Double, y: Double, zeta: Double) {
    let reduced = atan(0.996_647_19 * tan(latitude))
    let rhoSin = 0.996_647_19 * sin(reduced)
    let rhoCos = cos(reduced)
    let declination = elements.declination(t) * .pi / 180
    let hourAngle = elements.mu(t) * .pi / 180 + longitude
      - Double(eclipse.deltaTSeconds) * 15 * .pi / (3_600 * 180)
    return (
      rhoCos * sin(hourAngle),
      rhoSin * cos(declination) - rhoCos * cos(hourAngle) * sin(declination),
      rhoSin * sin(declination) + rhoCos * cos(hourAngle) * cos(declination)
    )
  }

  private static func inverse(
    x: Double, y: Double, at t: Double, elements: Elements, eclipse: SolarEclipse
  ) -> (coordinate: EclipseCoordinate, zeta: Double)? {
    guard x * x + y * y < 1 else { return nil }
    let eccentricitySquared = 0.006_694_385
    let declination = elements.declination(t) * .pi / 180
    let rho = sqrt(1 - eccentricitySquared * pow(cos(declination), 2))
    let sinD = sin(declination) / rho
    let cosD = sqrt(1 - eccentricitySquared) * cos(declination) / rho
    let zeta = sqrt(1 - x * x - y * y)
    let sinLatitude = y * cosD + zeta * sinD
    let latitude = atan2(
      sinLatitude,
      sqrt(1 - eccentricitySquared) * sqrt(max(0, 1 - sinLatitude * sinLatitude))
    )
    var longitude = atan2(x, zeta * cosD - y * sinD) - elements.mu(t) * .pi / 180
    longitude += Double(eclipse.deltaTSeconds) * 15 * .pi / (3_600 * 180)
    return (
      EclipseCoordinate(
        latitude: latitude * 180 / .pi,
        longitude: normalizedLongitude(longitude * 180 / .pi)
      ),
      zeta
    )
  }

  private static func normalizedLongitude(_ longitude: Double) -> Double {
    (longitude + 540).truncatingRemainder(dividingBy: 360) - 180
  }

  private struct Elements {
    let values: [Double]

    init(_ values: [Float]) {
      self.values = values.map(Double.init)
    }

    var referenceHour: Double { values[0] }
    var tangentF2: Double { values[22] }
    var minimumHour: Double { values[23] }
    var maximumHour: Double { values[24] }

    func x(_ t: Double) -> Double { polynomial(start: 1, count: 4, t: t) }
    func y(_ t: Double) -> Double { polynomial(start: 5, count: 4, t: t) }
    func declination(_ t: Double) -> Double { polynomial(start: 9, count: 3, t: t) }
    func mu(_ t: Double) -> Double { polynomial(start: 12, count: 3, t: t) }
    func l2(_ t: Double) -> Double { polynomial(start: 18, count: 3, t: t) }

    func velocity(_ t: Double) -> (x: Double, y: Double) {
      (derivative(start: 1, count: 4, t: t), derivative(start: 5, count: 4, t: t))
    }

    private func polynomial(start: Int, count: Int, t: Double) -> Double {
      var result = 0.0
      for exponent in 0..<count {
        let coefficient = values[start + exponent]
        let power = pow(t, Double(exponent))
        result += coefficient * power
      }
      return result
    }

    private func derivative(start: Int, count: Int, t: Double) -> Double {
      var result = 0.0
      for exponent in 1..<count {
        let coefficient = Double(exponent) * values[start + exponent]
        let power = pow(t, Double(exponent - 1))
        result += coefficient * power
      }
      return result
    }
  }
}
