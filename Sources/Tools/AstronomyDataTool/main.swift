import Foundation

private struct BrightStar {
  let hr: UInt32
  let hd: UInt32
  let designation: String
  let radialVelocity: Float?
  let visualMagnitude: Float
}

private struct HipparcosAstrometry {
  let hip: UInt32
  let solutionType: UInt8
  let componentCount: UInt8
  let rightAscension: Double
  let declination: Double
  let parallax: Float
  let properMotionRA: Float
  let properMotionDE: Float
  let colorIndexBV: Float?
}

private struct OutputStar {
  let bright: BrightStar
  let astrometry: HipparcosAstrometry
}

enum GeneratorError: Error, CustomStringConvertible {
  case usage(String)
  case malformedRecord(file: String, line: Int)
  case noRecords
  case validationFailed(maximumError: Double, tolerance: Double)

  var description: String {
    switch self {
    case .usage(let message): message
    case .malformedRecord(let file, let line): "Malformed record in \(file) at line \(line)"
    case .noRecords: "No linked stars were produced"
    case .validationFailed(let error, let tolerance):
      "DE441 validation error \(error) exceeded tolerance \(tolerance)"
    }
  }
}

private func field(_ line: Substring, _ range: Range<Int>) -> Substring {
  let start = line.index(line.startIndex, offsetBy: range.lowerBound)
  let end = line.index(line.startIndex, offsetBy: min(range.upperBound, line.count))
  return line[start ..< end]
}

private func integer<T: FixedWidthInteger>(_ value: Substring, as: T.Type = T.self) -> T? {
  T(value.trimmingCharacters(in: .whitespaces))
}

private func floating<T: LosslessStringConvertible>(_ value: Substring, as: T.Type = T.self) -> T? {
  T(value.trimmingCharacters(in: .whitespaces))
}

private func lines(at url: URL) throws -> [Substring] {
  try String(contentsOf: url, encoding: .ascii).split(separator: "\n", omittingEmptySubsequences: false)
}

private func readBrightStars(_ url: URL) throws -> [BrightStar] {
  try lines(at: url).enumerated().compactMap { lineNumber, line in
    guard !line.isEmpty else { return nil }
    guard line.count >= 107,
          let hr: UInt32 = integer(field(line, 0 ..< 4)) else {
      throw GeneratorError.malformedRecord(file: url.lastPathComponent, line: lineNumber + 1)
    }
    guard let hd: UInt32 = integer(field(line, 25 ..< 31)),
          let magnitude: Float = floating(field(line, 102 ..< 107)) else {
      return nil
    }
    return BrightStar(
      hr: hr,
      hd: hd,
      designation: String(field(line, 4 ..< 14)).trimmingCharacters(in: .whitespaces),
      radialVelocity: line.count >= 170 ? floating(field(line, 166 ..< 170)) : nil,
      visualMagnitude: magnitude
    )
  }
}

private func readHDToHIP(_ url: URL) throws -> [UInt32: Set<UInt32>] {
  var result: [UInt32: Set<UInt32>] = [:]
  for (lineNumber, line) in try lines(at: url).enumerated() where !line.isEmpty {
    guard line.count >= 396,
          let hip: UInt32 = integer(field(line, 8 ..< 14)) else {
      throw GeneratorError.malformedRecord(file: url.lastPathComponent, line: lineNumber + 1)
    }
    guard let hd: UInt32 = integer(field(line, 390 ..< 396)) else { continue }
    result[hd, default: []].insert(hip)
  }
  return result
}

private func readHipparcos2(_ url: URL) throws -> [UInt32: HipparcosAstrometry] {
  var result: [UInt32: HipparcosAstrometry] = [:]
  for (lineNumber, line) in try lines(at: url).enumerated() where !line.isEmpty {
    guard line.count >= 171,
          let hip: UInt32 = integer(field(line, 0 ..< 6)),
          let solution: UInt8 = integer(field(line, 7 ..< 10)),
          let components: UInt8 = integer(field(line, 13 ..< 14)),
          let ra: Double = floating(field(line, 15 ..< 28)),
          let dec: Double = floating(field(line, 29 ..< 42)),
          let parallax: Float = floating(field(line, 43 ..< 50)),
          let pmRA: Float = floating(field(line, 51 ..< 59)),
          let pmDE: Float = floating(field(line, 60 ..< 68)) else {
      throw GeneratorError.malformedRecord(file: url.lastPathComponent, line: lineNumber + 1)
    }
    result[hip] = HipparcosAstrometry(
      hip: hip,
      solutionType: solution,
      componentCount: components,
      rightAscension: ra,
      declination: dec,
      parallax: parallax,
      properMotionRA: pmRA,
      properMotionDE: pmDE,
      colorIndexBV: floating(field(line, 152 ..< 158))
    )
  }
  return result
}

private extension Data {
  mutating func appendLittleEndian<T: FixedWidthInteger>(_ value: T) {
    var littleEndian = value.littleEndian
    Swift.withUnsafeBytes(of: &littleEndian) { append(contentsOf: $0) }
  }

  mutating func append(_ value: Float) { appendLittleEndian(value.bitPattern) }
  mutating func append(_ value: Double) { appendLittleEndian(value.bitPattern) }
}

private func encode(_ stars: [OutputStar]) -> Data {
  var data = Data("CALSTAR1".utf8)
  data.appendLittleEndian(UInt16(1))
  data.appendLittleEndian(UInt16(68))
  data.appendLittleEndian(UInt32(stars.count))
  data.appendLittleEndian(UInt32(0))

  for star in stars {
    data.appendLittleEndian(star.bright.hr)
    data.appendLittleEndian(star.astrometry.hip)
    data.appendLittleEndian(star.bright.hd)
    data.append(star.astrometry.rightAscension)
    data.append(star.astrometry.declination)
    data.append(star.astrometry.parallax)
    data.append(star.astrometry.properMotionRA)
    data.append(star.astrometry.properMotionDE)
    data.append(star.bright.radialVelocity ?? .nan)
    data.append(star.bright.visualMagnitude)
    data.append(star.astrometry.colorIndexBV ?? .nan)
    data.append(star.astrometry.solutionType)
    data.append(star.astrometry.componentCount)
    data.appendLittleEndian(UInt16(0))
    let designation = Array(star.bright.designation.utf8.prefix(12))
    data.append(contentsOf: designation)
    data.append(contentsOf: repeatElement(0, count: 12 - designation.count))
  }
  return data
}

private func locatePackageDirectory() throws -> URL {
  let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
  let candidates = [
    currentDirectory,
    currentDirectory.appendingPathComponent("Packages/Calendars", isDirectory: true),
  ]
  guard let packageDirectory = candidates.first(where: {
    FileManager.default.fileExists(atPath: $0.appendingPathComponent("Data").path)
  }) else {
    throw GeneratorError.usage("Could not locate Packages/Calendars; pass the Data directory explicitly")
  }
  return packageDirectory
}

private func generateStars(arguments: [String]) throws {
  let paths: [String]
  if arguments.isEmpty {
    let packageDirectory = try locatePackageDirectory()
    paths = [
      packageDirectory.appendingPathComponent("Data").path,
      packageDirectory.appendingPathComponent(
        "Sources/Calendars/Resources/AstronomyData/historical-stars.bin"
      ).path,
    ]
  } else if arguments.count == 2 {
    paths = arguments
  } else {
    throw GeneratorError.usage("Usage: AstronomyDataTool stars [<Data directory> <output file>]")
  }
  let dataDirectory = URL(fileURLWithPath: paths[0], isDirectory: true)
  let outputURL = URL(fileURLWithPath: paths[1])

  let brightStars = try readBrightStars(dataDirectory.appendingPathComponent("YBSC5/catalog"))
  let hdToHIP = try readHDToHIP(dataDirectory.appendingPathComponent("Hipparcos-I-239/hip_main.dat"))
  let hipparcos2 = try readHipparcos2(dataDirectory.appendingPathComponent("Hipparcos-2-CDS/hip2.dat"))

  var ambiguous = 0
  var unmatched = 0
  var output: [OutputStar] = []
  for bright in brightStars {
    guard let candidates = hdToHIP[bright.hd] else {
      unmatched += 1
      continue
    }
    guard candidates.count == 1, let hip = candidates.first else {
      ambiguous += 1
      continue
    }
    guard let astrometry = hipparcos2[hip] else {
      unmatched += 1
      continue
    }
    output.append(OutputStar(bright: bright, astrometry: astrometry))
  }
  guard !output.isEmpty else { throw GeneratorError.noRecords }
  output.sort { $0.bright.hr < $1.bright.hr }

  try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
  )
  try encode(output).write(to: outputURL, options: .atomic)
  print("Wrote \(output.count) stars to \(outputURL.path)")
  print("Omitted \(ambiguous) ambiguous and \(unmatched) unmatched YBSC records")
}

private func validateDE441(arguments: [String]) throws {
  let dataDirectory: URL
  if arguments.isEmpty {
    dataDirectory = try locatePackageDirectory().appendingPathComponent("Data", isDirectory: true)
  } else if arguments.count == 1 {
    dataDirectory = URL(fileURLWithPath: arguments[0], isDirectory: true)
  } else {
    throw GeneratorError.usage("Usage: AstronomyDataTool validate-de441 [<Data directory>]")
  }

  let directory = dataDirectory.appendingPathComponent("DE441", isDirectory: true)
  let ephemeris = try DE441Ephemeris(
    url: directory.appendingPathComponent("linux_m13000p17000.441")
  )
  let testLines = try lines(at: directory.appendingPathComponent("testpo.441"))
  var tested = 0
  var testedNutation = 0
  var maximumError = 0.0
  for (lineNumber, line) in testLines.enumerated() where lineNumber % 997 == 0 {
    let fields = line.split(whereSeparator: { $0 == " " || $0 == "\t" })
    guard fields.count >= 6,
          let julianDate = Double(fields[fields.count - 5]),
          let target = Int(fields[fields.count - 4]),
          let center = Int(fields[fields.count - 3]),
          let coordinate = Int(fields[fields.count - 2]),
          let expected = Double(fields[fields.count - 1]),
          (1...6).contains(coordinate),
          julianDate >= ephemeris.startDate,
          julianDate <= ephemeris.endDate else { continue }
    let actual: Double
    if target == 14, center == 0, coordinate <= 4 {
      let nutation = try ephemeris.nutation(at: julianDate)
      actual = [
        nutation.longitude, nutation.obliquity,
        nutation.longitudeRate, nutation.obliquityRate,
      ][coordinate - 1]
      testedNutation += 1
    } else if (1...13).contains(target), (1...13).contains(center) {
      let vector = try ephemeris.vector(target: target, center: center, at: julianDate)
      actual = coordinate <= 3 ? vector.position[coordinate - 1] : vector.velocity[coordinate - 4]
    } else {
      continue
    }
    maximumError = max(maximumError, abs(actual - expected))
    tested += 1
  }
  guard tested >= 100 else {
    throw GeneratorError.usage("Too few usable vectors in testpo.441 (found \(tested))")
  }
  let tolerance = 1e-11
  guard maximumError <= tolerance else {
    throw GeneratorError.validationFailed(maximumError: maximumError, tolerance: tolerance)
  }
  print("Validated \(tested) DE441 coordinates over JD \(ephemeris.startDate)...\(ephemeris.endDate)")
  print("Included \(testedNutation) nutation coordinates")
  print("Maximum absolute error: \(maximumError) AU or AU/day")
}

private func validateReferenceFrame(arguments: [String]) throws {
  guard arguments.isEmpty else {
    throw GeneratorError.usage("Usage: AstronomyDataTool validate-reference-frame")
  }
  let cases = [
    (
      AstronomicalReferenceFrame.eclipticPole(epoch: -1500),
      SIMD3(0.4768625676477096525e-3, -0.4052259533091875112, 0.9142164401096448012)
    ),
    (
      AstronomicalReferenceFrame.equatorPole(epoch: -2500),
      SIMD3(-0.3586652560237326659, -0.1996978910771128475, 0.9118552442250819624)
    ),
  ]
  let maximumError = cases.flatMap { actual, expected in
    (0..<3).map { abs(actual[$0] - expected[$0]) }
  }.max() ?? .infinity
  let tolerance = 1e-14
  guard maximumError <= tolerance else {
    throw GeneratorError.validationFailed(maximumError: maximumError, tolerance: tolerance)
  }
  print("Validated long-term equator and ecliptic poles against IAU SOFA reference values")
  print("Maximum absolute error: \(maximumError)")
}

private func prolepticGregorianJDN(year: Int, month: Int, day: Int) -> Double {
  var adjustedYear = year
  var adjustedMonth = month
  if adjustedMonth <= 2 {
    adjustedYear -= 1
    adjustedMonth += 12
  }
  let century = floor(Double(adjustedYear) / 100)
  let correction = 2 - century + floor(century / 4)
  return floor(365.25 * Double(adjustedYear + 4_716))
    + floor(30.6001 * Double(adjustedMonth + 1))
    + Double(day) + correction - 1_524.5
}

private func generateEvents(arguments: [String]) throws {
  let startYear: Int
  let endYear: Int
  let outputURL: URL
  if arguments.isEmpty {
    let packageDirectory = try locatePackageDirectory()
    startYear = -4_000
    endYear = 3_000
    outputURL = packageDirectory.appendingPathComponent(
      "Sources/Calendars/Resources/AstronomyData/astronomical-events.bin"
    )
  } else if arguments.count == 3,
            let parsedStart = Int(arguments[0]),
            let parsedEnd = Int(arguments[1]),
            parsedStart <= parsedEnd {
    startYear = parsedStart
    endYear = parsedEnd
    outputURL = URL(fileURLWithPath: arguments[2])
  } else {
    throw GeneratorError.usage(
      "Usage: AstronomyDataTool generate-events [<start year> <end year> <output file>]"
    )
  }
  let dataDirectory = try locatePackageDirectory().appendingPathComponent("Data/DE441")
  let ephemeris = try DE441Ephemeris(
    url: dataDirectory.appendingPathComponent("linux_m13000p17000.441")
  )
  let startDate = prolepticGregorianJDN(year: startYear, month: 1, day: 1)
  let endDate = prolepticGregorianJDN(year: endYear + 1, month: 1, day: 1)
  guard startDate >= ephemeris.startDate, endDate <= ephemeris.endDate else {
    throw GeneratorError.usage("Requested years are outside the installed DE441 segment")
  }
  let generator = AstronomicalEventGenerator(
    positions: ApparentPositionCalculator(ephemeris: ephemeris)
  )
  let events = try generator.events(from: startDate, through: endDate)

  var encoded = Data("CALEVT01".utf8)
  encoded.appendLittleEndian(UInt16(1))
  encoded.appendLittleEndian(UInt16(16))
  encoded.appendLittleEndian(UInt32(events.count))
  encoded.appendLittleEndian(UInt32(0))
  for event in events {
    encoded.append(event.kind.rawValue)
    encoded.append(contentsOf: repeatElement(0, count: 7))
    encoded.append(event.julianDateTDB)
  }
  try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
  )
  try encoded.write(to: outputURL, options: .atomic)
  print("Wrote \(events.count) astronomical events for \(startYear)...\(endYear) to \(outputURL.path)")
}

private func validateEvents2024(arguments: [String]) throws {
  guard arguments.isEmpty else {
    throw GeneratorError.usage("Usage: AstronomyDataTool validate-events-2024")
  }
  let directory = try locatePackageDirectory().appendingPathComponent("Data/DE441")
  let ephemeris = try DE441Ephemeris(
    url: directory.appendingPathComponent("linux_m13000p17000.441")
  )
  let events = try AstronomicalEventGenerator(
    positions: ApparentPositionCalculator(ephemeris: ephemeris)
  ).events(
    from: prolepticGregorianJDN(year: 2024, month: 1, day: 1),
    through: prolepticGregorianJDN(year: 2025, month: 1, day: 1)
  )
  // USNO publishes UTC rounded to the minute. TT-UTC was 69.184 seconds in
  // 2024; TDB-TT is below two milliseconds for this comparison.
  let offsetToTDB = 69.184 / 86_400
  let references: [(GeneratedAstronomicalEventKind, Int, Int, Int, Int)] = [
    (.lastQuarter, 1, 4, 3, 30),
    (.newMoon, 1, 11, 11, 57),
    (.firstQuarter, 1, 18, 3, 52),
    (.fullMoon, 1, 25, 17, 54),
    (.marchEquinox, 3, 20, 3, 6),
    (.juneSolstice, 6, 20, 20, 51),
    (.septemberEquinox, 9, 22, 12, 44),
    (.decemberSolstice, 12, 21, 9, 20),
  ]
  var maximumDifferenceMinutes = 0.0
  for (kind, month, day, hour, minute) in references {
    let expected = prolepticGregorianJDN(year: 2024, month: month, day: day)
      + Double(hour * 60 + minute) / 1_440 + offsetToTDB
    guard let actual = events.filter({ $0.kind == kind }).min(by: {
      abs($0.julianDateTDB - expected) < abs($1.julianDateTDB - expected)
    }) else {
      throw GeneratorError.validationFailed(maximumError: .infinity, tolerance: 2)
    }
    maximumDifferenceMinutes = max(
      maximumDifferenceMinutes,
      abs(actual.julianDateTDB - expected) * 1_440
    )
  }
  let toleranceMinutes = 2.0
  guard maximumDifferenceMinutes <= toleranceMinutes else {
    throw GeneratorError.validationFailed(
      maximumError: maximumDifferenceMinutes,
      tolerance: toleranceMinutes
    )
  }
  print("Validated 2024 seasons and representative lunar phases against USNO")
  print("Maximum difference from minute-rounded published values: \(maximumDifferenceMinutes) minutes")
}

private func generateSolarEclipses(arguments: [String]) throws {
  let packageDirectory = try locatePackageDirectory()
  let inputURL: URL
  let outputURL: URL
  if arguments.isEmpty {
    inputURL = packageDirectory.appendingPathComponent(
      "Data/NASA-Eclipses/solar-eclipse-besselian.csv"
    )
    outputURL = packageDirectory.appendingPathComponent(
      "Sources/Calendars/Resources/AstronomyData/solar-eclipses.bin"
    )
  } else if arguments.count == 2 {
    inputURL = URL(fileURLWithPath: arguments[0])
    outputURL = URL(fileURLWithPath: arguments[1])
  } else {
    throw GeneratorError.usage(
      "Usage: AstronomyDataTool generate-solar-eclipses [<NASA CSV> <output file>]"
    )
  }
  let eclipses = try SolarEclipseDataGenerator.read(inputURL)
  var encoded = Data("CALSE001".utf8)
  encoded.appendLittleEndian(UInt16(1))
  encoded.appendLittleEndian(UInt16(162))
  encoded.appendLittleEndian(UInt32(eclipses.count))
  encoded.appendLittleEndian(UInt32(0))
  for eclipse in eclipses {
    encoded.appendLittleEndian(eclipse.year)
    encoded.append(eclipse.month)
    encoded.append(eclipse.day)
    encoded.appendLittleEndian(eclipse.greatestEclipseSeconds)
    encoded.append(eclipse.julianDate)
    encoded.append(eclipse.deltaT)
    encoded.appendLittleEndian(eclipse.lunation)
    encoded.appendLittleEndian(eclipse.saros)
    let type = Array(eclipse.type.utf8.prefix(4))
    encoded.append(contentsOf: type)
    encoded.append(contentsOf: repeatElement(0, count: 4 - type.count))
    for value in [
      eclipse.gamma, eclipse.magnitude, eclipse.latitude, eclipse.longitude,
      eclipse.sunAltitude, eclipse.sunAzimuth, eclipse.pathWidthKilometers,
      eclipse.centralDurationSeconds,
    ] + eclipse.besselian {
      encoded.append(value)
    }
  }
  try encoded.write(to: outputURL, options: .atomic)
  print("Wrote \(eclipses.count) NASA solar eclipses to \(outputURL.path)")
}

private func generateLunarEclipses(arguments: [String]) throws {
  let packageDirectory = try locatePackageDirectory()
  let inputURL: URL
  let outputURL: URL
  if arguments.isEmpty {
    inputURL = packageDirectory.appendingPathComponent(
      "Data/NASA-Eclipses/5MKLEcatalog.txt"
    )
    outputURL = packageDirectory.appendingPathComponent(
      "Sources/Calendars/Resources/AstronomyData/lunar-eclipses.bin"
    )
  } else if arguments.count == 2 {
    inputURL = URL(fileURLWithPath: arguments[0])
    outputURL = URL(fileURLWithPath: arguments[1])
  } else {
    throw GeneratorError.usage(
      "Usage: AstronomyDataTool generate-lunar-eclipses [<NASA catalog> <output file>]"
    )
  }
  let eclipses = try LunarEclipseDataGenerator.read(inputURL)
  var encoded = Data("CALLE001".utf8)
  encoded.appendLittleEndian(UInt16(1))
  encoded.appendLittleEndian(UInt16(54))
  encoded.appendLittleEndian(UInt32(eclipses.count))
  encoded.appendLittleEndian(UInt32(0))
  for eclipse in eclipses {
    encoded.appendLittleEndian(eclipse.year)
    encoded.append(eclipse.month)
    encoded.append(eclipse.day)
    encoded.appendLittleEndian(eclipse.greatestEclipseSeconds)
    encoded.append(eclipse.julianDate)
    encoded.append(eclipse.deltaT)
    encoded.appendLittleEndian(eclipse.lunation)
    encoded.appendLittleEndian(eclipse.saros)
    let type = Array(eclipse.type.utf8.prefix(4))
    encoded.append(contentsOf: type)
    encoded.append(contentsOf: repeatElement(0, count: 4 - type.count))
    for value in [
      eclipse.gamma,
      eclipse.penumbralMagnitude,
      eclipse.umbralMagnitude,
      eclipse.penumbralDurationMinutes ?? .nan,
      eclipse.partialDurationMinutes ?? .nan,
      eclipse.totalDurationMinutes ?? .nan,
    ] {
      encoded.append(value)
    }
  }
  try encoded.write(to: outputURL, options: .atomic)
  print("Wrote \(eclipses.count) NASA lunar eclipses to \(outputURL.path)")
}

private func run() throws {
  var arguments = Array(CommandLine.arguments.dropFirst())
  let command = arguments.first ?? "stars"
  if !arguments.isEmpty { arguments.removeFirst() }
  switch command {
  case "stars":
    try generateStars(arguments: arguments)
  case "validate-de441":
    try validateDE441(arguments: arguments)
  case "validate-reference-frame":
    try validateReferenceFrame(arguments: arguments)
  case "generate-events":
    try generateEvents(arguments: arguments)
  case "validate-events-2024":
    try validateEvents2024(arguments: arguments)
  case "generate-solar-eclipses":
    try generateSolarEclipses(arguments: arguments)
  case "generate-lunar-eclipses":
    try generateLunarEclipses(arguments: arguments)
  default:
    // Preserve the original two-positional-argument invocation.
    try generateStars(arguments: [command] + arguments)
  }
}

do {
  try run()
} catch {
  FileHandle.standardError.write(Data("AstronomyDataTool: \(error)\n".utf8))
  exit(1)
}
