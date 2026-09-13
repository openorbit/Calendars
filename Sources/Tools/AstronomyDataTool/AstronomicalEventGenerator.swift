import Foundation

enum GeneratedAstronomicalEventKind: UInt8, CaseIterable {
  case marchEquinox
  case juneSolstice
  case septemberEquinox
  case decemberSolstice
  case newMoon
  case firstQuarter
  case fullMoon
  case lastQuarter
}

struct GeneratedAstronomicalEvent {
  let kind: GeneratedAstronomicalEventKind
  let julianDateTDB: Double
}

struct AstronomicalEventGenerator {
  let positions: ApparentPositionCalculator

  func events(from startDate: Double, through endDate: Double) throws -> [GeneratedAstronomicalEvent] {
    var result: [GeneratedAstronomicalEvent] = []
    let seasonalKinds: [GeneratedAstronomicalEventKind] = [
      .marchEquinox, .juneSolstice, .septemberEquinox, .decemberSolstice,
    ]
    for (index, kind) in seasonalKinds.enumerated() {
      result += try roots(
        from: startDate,
        through: endDate,
        step: 20,
        targetAngle: Double(index) * .pi / 2,
        kind: kind
      ) { date in
        try positions.apparentEclipticLongitude(body: 11, at: date)
      }
    }

    let phaseKinds: [GeneratedAstronomicalEventKind] = [
      .newMoon, .firstQuarter, .fullMoon, .lastQuarter,
    ]
    for (index, kind) in phaseKinds.enumerated() {
      result += try roots(
        from: startDate,
        through: endDate,
        step: 3,
        targetAngle: Double(index) * .pi / 2,
        kind: kind
      ) { date in
        // Nutation in longitude is common to both bodies and cancels here.
        let moon = try positions.meanEclipticLongitude(body: 10, at: date)
        let sun = try positions.meanEclipticLongitude(body: 11, at: date)
        return moon - sun
      }
    }
    return result.sorted { $0.julianDateTDB < $1.julianDateTDB }
  }

  private func roots(
    from startDate: Double,
    through endDate: Double,
    step: Double,
    targetAngle: Double,
    kind: GeneratedAstronomicalEventKind,
    angle: (Double) throws -> Double
  ) throws -> [GeneratedAstronomicalEvent] {
    var result: [GeneratedAstronomicalEvent] = []
    var lowerDate = startDate
    var lowerValue = normalizedSigned(try angle(lowerDate) - targetAngle)
    while lowerDate < endDate {
      let upperDate = min(endDate, lowerDate + step)
      let upperValue = normalizedSigned(try angle(upperDate) - targetAngle)
      // A genuine zero crossing is continuous. A jump close to 2π is merely
      // the signed-angle branch cut opposite the requested event.
      if lowerValue == 0 || lowerValue * upperValue < 0 && abs(upperValue - lowerValue) < .pi {
        let root = try solveBracketed(
          lowerDate: lowerDate,
          upperDate: upperDate,
          lowerValue: lowerValue,
          upperValue: upperValue,
          targetAngle: targetAngle,
          angle: angle
        )
        if result.last.map({ root - $0.julianDateTDB > 0.01 }) ?? true {
          result.append(GeneratedAstronomicalEvent(kind: kind, julianDateTDB: root))
        }
      }
      lowerDate = upperDate
      lowerValue = upperValue
    }
    return result
  }

  private func solveBracketed(
    lowerDate: Double,
    upperDate: Double,
    lowerValue: Double,
    upperValue: Double,
    targetAngle: Double,
    angle: (Double) throws -> Double
  ) throws -> Double {
    var lowerDate = lowerDate
    var upperDate = upperDate
    var lowerValue = lowerValue
    var upperValue = upperValue
    for _ in 0..<10 {
      let secant = (lowerDate * upperValue - upperDate * lowerValue)
        / (upperValue - lowerValue)
      let middle = secant > lowerDate && secant < upperDate
        ? secant : (lowerDate + upperDate) / 2
      let middleValue = normalizedSigned(try angle(middle) - targetAngle)
      if abs(middleValue) < 1e-12 { return middle }
      if lowerValue * middleValue <= 0 {
        upperDate = middle
        upperValue = middleValue
      } else {
        lowerDate = middle
        lowerValue = middleValue
      }
    }
    return (lowerDate + upperDate) / 2
  }

  private func normalizedSigned(_ angle: Double) -> Double {
    var result = angle.truncatingRemainder(dividingBy: 2 * .pi)
    if result <= -.pi { result += 2 * .pi }
    if result > .pi { result -= 2 * .pi }
    return result
  }
}
