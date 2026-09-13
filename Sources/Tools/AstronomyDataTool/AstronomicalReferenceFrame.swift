import Foundation

/// Long-term mean equator and ecliptic poles in the J2000 mean frame.
///
/// This is a Swift adaptation of the algorithms in the IAU SOFA `iauLtpequ`
/// and `iauLtpecl` routines, release 2023-10-11. It is a derived work and is
/// neither software provided by nor endorsed by SOFA. See `SOFA-NOTICE.md`.
enum AstronomicalReferenceFrame {
  private static let arcsecondsToRadians = Double.pi / (180 * 3_600)

  static func julianEpoch(for julianDate: Double) -> Double {
    2000 + (julianDate - 2_451_545) / 365.25
  }

  static func eclipticPole(epoch: Double) -> SIMD3<Double> {
    let polynomial = [
      [5_851.607687, -0.1189000, -0.00028913, 0.000000101],
      [-1_600.886300, 1.1689818, -0.00000020, -0.000000437],
    ]
    let periodic = [
      [708.15, -5_486.751211, -684.661560, 667.666730, -5_523.863691],
      [2_309.00, -17.127623, 2_446.283880, -2_354.886252, -549.747450],
      [1_620.00, -617.517403, 399.671049, -428.152441, -310.998056],
      [492.20, 413.442940, -356.652376, 376.202861, 421.535876],
      [1_183.00, 78.614193, -186.387003, 184.778874, -36.776172],
      [622.00, -180.732815, -316.800070, 335.321713, -145.278396],
      [882.00, -87.676083, 198.296701, -185.138669, -34.744450],
      [547.00, 46.140315, 101.135679, -120.972830, 22.885731],
    ]
    let values = evaluate(epoch: epoch, polynomial: polynomial, periodic: periodic)
    let p = values.x * arcsecondsToRadians
    let q = values.y * arcsecondsToRadians
    let w = sqrt(max(0, 1 - p * p - q * q))
    let obliquity = 84_381.406 * arcsecondsToRadians
    return SIMD3(
      p,
      -q * cos(obliquity) - w * sin(obliquity),
      -q * sin(obliquity) + w * cos(obliquity)
    )
  }

  static func equatorPole(epoch: Double) -> SIMD3<Double> {
    let polynomial = [
      [5_453.282155, 0.4252841, -0.00037173, -0.000000152],
      [-73_750.930350, -0.7675452, -0.00018725, 0.000000231],
    ]
    let periodic = [
      [256.75, -819.940624, 75_004.344875, 81_491.287984, 1_558.515853],
      [708.15, -8_444.676815, 624.033993, 787.163481, 7_774.939698],
      [274.20, 2_600.009459, 1_251.136893, 1_251.296102, -2_219.534038],
      [241.45, 2_755.175630, -1_102.212834, -1_257.950837, -2_523.969396],
      [2_309.00, -167.659835, -2_660.664980, -2_966.799730, 247.850422],
      [492.20, 871.855056, 699.291817, 639.744522, -846.485643],
      [396.10, 44.769698, 153.167220, 131.600209, -1_393.124055],
      [288.90, -512.313065, -950.865637, -445.040117, 368.526116],
      [231.10, -819.415595, 499.754645, 584.522874, 749.045012],
      [1_610.00, -538.071099, -145.188210, -89.756563, 444.704518],
      [620.00, -189.793622, 558.116553, 524.429630, 235.934465],
      [157.87, -402.922932, -23.923029, -13.549067, 374.049623],
      [220.30, 179.516345, -165.405086, -210.157124, -171.330180],
      [1_200.00, -9.814756, 9.344131, -44.919798, -22.899655],
    ]
    let values = evaluate(epoch: epoch, polynomial: polynomial, periodic: periodic)
    let x = values.x * arcsecondsToRadians
    let y = values.y * arcsecondsToRadians
    return SIMD3(x, y, sqrt(max(0, 1 - x * x - y * y)))
  }

  static func meanEclipticLongitude(of vector: SIMD3<Double>, julianDate: Double) -> Double {
    let epoch = julianEpoch(for: julianDate)
    let eclipticNorth = normalized(eclipticPole(epoch: epoch))
    let equatorialNorth = normalized(equatorPole(epoch: epoch))
    var equinox = normalized(cross(equatorialNorth, eclipticNorth))
    if equinox.x < 0 { equinox = -equinox }
    let longitude90 = cross(eclipticNorth, equinox)
    return atan2(dot(vector, longitude90), dot(vector, equinox))
  }

  private static func evaluate(
    epoch: Double,
    polynomial: [[Double]],
    periodic: [[Double]]
  ) -> SIMD2<Double> {
    let centuries = (epoch - 2000) / 100
    var result = SIMD2<Double>()
    for term in periodic {
      let angle = 2 * Double.pi * centuries / term[0]
      result.x += cos(angle) * term[1] + sin(angle) * term[3]
      result.y += cos(angle) * term[2] + sin(angle) * term[4]
    }
    var power = 1.0
    for index in polynomial[0].indices {
      result.x += polynomial[0][index] * power
      result.y += polynomial[1][index] * power
      power *= centuries
    }
    return result
  }

  private static func cross(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> SIMD3<Double> {
    SIMD3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
  }

  private static func dot(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> Double {
    a.x * b.x + a.y * b.y + a.z * b.z
  }

  private static func normalized(_ vector: SIMD3<Double>) -> SIMD3<Double> {
    vector / sqrt(dot(vector, vector))
  }
}
