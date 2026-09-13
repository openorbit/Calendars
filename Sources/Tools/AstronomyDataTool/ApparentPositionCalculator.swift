import Foundation

struct ApparentPositionCalculator {
  private static let speedOfLightAUPerDay = 173.1446326846693

  let ephemeris: DE441Ephemeris

  func direction(body: Int, at receptionDate: Double) throws -> SIMD3<Double> {
    let earth = try ephemeris.vector(target: 3, center: 12, at: receptionDate)
    var emissionDate = receptionDate
    var displacement = SIMD3<Double>()
    for _ in 0..<2 {
      let target = try ephemeris.vector(target: body, center: 12, at: emissionDate)
      displacement = target.position - earth.position
      emissionDate = receptionDate - length(displacement) / Self.speedOfLightAUPerDay
    }
    let naturalDirection = normalized(displacement)
    return aberrated(naturalDirection, observerVelocity: earth.velocity)
  }

  func apparentEclipticLongitude(body: Int, at julianDate: Double) throws -> Double {
    let meanLongitude = try meanEclipticLongitude(body: body, at: julianDate)
    return normalizedAngle(meanLongitude + (try ephemeris.nutation(at: julianDate)).longitude)
  }

  func meanEclipticLongitude(body: Int, at julianDate: Double) throws -> Double {
    normalizedAngle(AstronomicalReferenceFrame.meanEclipticLongitude(
      of: try direction(body: body, at: julianDate),
      julianDate: julianDate
    ))
  }

  private func aberrated(
    _ direction: SIMD3<Double>,
    observerVelocity: SIMD3<Double>
  ) -> SIMD3<Double> {
    // Adapted from the special-relativistic part of IAU SOFA `iauAb`.
    // Solar gravitational deflection is deliberately excluded: it is undefined
    // for the Sun itself and negligible for the phase/equinox roots generated here.
    let velocity = observerVelocity / Self.speedOfLightAUPerDay
    let betaSquared = dot(velocity, velocity)
    let reciprocalLorentzFactor = sqrt(1 - betaSquared)
    let product = dot(direction, velocity)
    let weight = 1 + product / (1 + reciprocalLorentzFactor)
    return normalized(direction * reciprocalLorentzFactor + velocity * weight)
  }

  private func dot(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> Double {
    a.x * b.x + a.y * b.y + a.z * b.z
  }

  private func length(_ vector: SIMD3<Double>) -> Double {
    sqrt(dot(vector, vector))
  }

  private func normalized(_ vector: SIMD3<Double>) -> SIMD3<Double> {
    vector / length(vector)
  }

  private func normalizedAngle(_ angle: Double) -> Double {
    var result = angle.truncatingRemainder(dividingBy: 2 * .pi)
    if result < 0 { result += 2 * .pi }
    return result
  }
}
