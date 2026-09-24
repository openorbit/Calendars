import Foundation

public struct SolarEclipse: Equatable, Sendable {
  public let year: Int
  public let month: Int
  public let day: Int
  public let greatestEclipseSeconds: Int
  public let julianDateTerrestrialDynamicalTime: Double
  public let deltaTSeconds: Float
  public let lunationNumber: Int
  public let sarosNumber: Int
  public let type: String
  public let gamma: Float
  public let magnitude: Float
  public let greatestEclipseLatitude: Float
  public let greatestEclipseLongitude: Float
  public let sunAltitude: Float
  public let sunAzimuth: Float
  public let pathWidthKilometers: Float?
  public let centralDurationSeconds: Float?

  /// NASA/GSFC Besselian elements, in the source CSV column order `t0`...`tmax`.
  public let besselianElements: [Float]
}

public enum SolarEclipseCatalogError: Error, Equatable {
  case resourceMissing
  case invalidHeader
  case unsupportedVersion(UInt16)
  case truncatedData
}

public struct SolarEclipseCatalog: Sendable {
  public static let sourceAcknowledgement = "Eclipse Predictions by Fred Espenak, NASA/GSFC"

  public static let shared: SolarEclipseCatalog = {
    (try? loadBundled()) ?? SolarEclipseCatalog(eclipses: [])
  }()

  public let eclipses: [SolarEclipse]

  public init(eclipses: [SolarEclipse]) {
    self.eclipses = eclipses.sorted {
      $0.julianDateTerrestrialDynamicalTime < $1.julianDateTerrestrialDynamicalTime
    }
  }

  public func eclipses(fromYear startYear: Int, through endYear: Int) -> [SolarEclipse] {
    guard startYear <= endYear else { return [] }
    return eclipses.filter { (startYear...endYear).contains($0.year) }
  }

  public func eclipses(from startDateTD: Double, through endDateTD: Double) -> [SolarEclipse] {
    guard startDateTD <= endDateTD else { return [] }
    let start = eclipses.partitioningIndex {
      $0.julianDateTerrestrialDynamicalTime >= startDateTD
    }
    let end = eclipses.partitioningIndex {
      $0.julianDateTerrestrialDynamicalTime > endDateTD
    }
    return Array(eclipses[start..<end])
  }

  public static func loadBundled() throws -> SolarEclipseCatalog {
    guard let url = Bundle.module.url(
      forResource: "solar-eclipses",
      withExtension: "bin",
      subdirectory: "AstronomyData"
    ) else { throw SolarEclipseCatalogError.resourceMissing }
    return try decode(Data(contentsOf: url))
  }

  static func decode(_ data: Data) throws -> SolarEclipseCatalog {
    var reader = SolarEclipseReader(data: data)
    guard try reader.bytes(8) == Array("CALSE001".utf8) else {
      throw SolarEclipseCatalogError.invalidHeader
    }
    let version = try reader.uint16()
    guard version == 1 else { throw SolarEclipseCatalogError.unsupportedVersion(version) }
    guard try reader.uint16() == 162 else { throw SolarEclipseCatalogError.invalidHeader }
    let count = try reader.uint32()
    _ = try reader.uint32()
    var eclipses: [SolarEclipse] = []
    eclipses.reserveCapacity(Int(count))
    for _ in 0..<count {
      let year = Int(try reader.int16())
      let month = Int(try reader.uint8())
      let day = Int(try reader.uint8())
      let seconds = Int(try reader.uint32())
      let julianDate = try reader.double()
      let deltaT = try reader.float()
      let lunation = Int(try reader.int32())
      let saros = Int(try reader.int16())
      let type = String(bytes: try reader.bytes(4).prefix { $0 != 0 }, encoding: .ascii) ?? ""
      let values = try (0..<33).map { _ in try reader.float() }
      eclipses.append(SolarEclipse(
        year: year, month: month, day: day, greatestEclipseSeconds: seconds,
        julianDateTerrestrialDynamicalTime: julianDate, deltaTSeconds: deltaT,
        lunationNumber: lunation, sarosNumber: saros, type: type,
        gamma: values[0], magnitude: values[1], greatestEclipseLatitude: values[2],
        greatestEclipseLongitude: values[3], sunAltitude: values[4], sunAzimuth: values[5],
        pathWidthKilometers: values[6].isNaN ? nil : values[6],
        centralDurationSeconds: values[7].isNaN ? nil : values[7],
        besselianElements: Array(values[8...32])
      ))
    }
    return SolarEclipseCatalog(eclipses: eclipses)
  }
}

private extension Collection {
  func partitioningIndex(where predicate: (Element) -> Bool) -> Index {
    var lower = startIndex
    var count = self.count
    while count > 0 {
      let step = count / 2
      let candidate = index(lower, offsetBy: step)
      if predicate(self[candidate]) {
        count = step
      } else {
        lower = index(after: candidate)
        count -= step + 1
      }
    }
    return lower
  }
}

private struct SolarEclipseReader {
  let data: Data
  var offset = 0

  mutating func bytes(_ count: Int) throws -> [UInt8] {
    guard offset + count <= data.count else { throw SolarEclipseCatalogError.truncatedData }
    defer { offset += count }
    return Array(data[offset..<offset + count])
  }

  mutating func uint8() throws -> UInt8 { try bytes(1)[0] }
  mutating func uint16() throws -> UInt16 {
    let b = try bytes(2); return UInt16(b[0]) | UInt16(b[1]) << 8
  }
  mutating func int16() throws -> Int16 { Int16(bitPattern: try uint16()) }
  mutating func uint32() throws -> UInt32 {
    let b = try bytes(4)
    return b.enumerated().reduce(0) { $0 | UInt32($1.element) << UInt32(8 * $1.offset) }
  }
  mutating func int32() throws -> Int32 { Int32(bitPattern: try uint32()) }
  mutating func float() throws -> Float { Float(bitPattern: try uint32()) }
  mutating func double() throws -> Double {
    let b = try bytes(8)
    let bits = b.enumerated().reduce(UInt64(0)) {
      $0 | UInt64($1.element) << UInt64(8 * $1.offset)
    }
    return Double(bitPattern: bits)
  }
}
