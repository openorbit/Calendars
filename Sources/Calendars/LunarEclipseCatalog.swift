import Foundation

public struct LunarEclipse: Equatable, Sendable {
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
  public let penumbralMagnitude: Float
  public let umbralMagnitude: Float
  public let penumbralDurationMinutes: Float?
  public let partialDurationMinutes: Float?
  public let totalDurationMinutes: Float?
}

public enum LunarEclipseCatalogError: Error, Equatable {
  case resourceMissing
  case invalidHeader
  case unsupportedVersion(UInt16)
  case truncatedData
}

public struct LunarEclipseCatalog: Sendable {
  public static let sourceAcknowledgement = "Eclipse Predictions by Fred Espenak and Jean Meeus, NASA/GSFC"

  public static let shared: LunarEclipseCatalog = {
    (try? loadBundled()) ?? LunarEclipseCatalog(eclipses: [])
  }()

  public let eclipses: [LunarEclipse]

  public init(eclipses: [LunarEclipse]) {
    self.eclipses = eclipses.sorted {
      $0.julianDateTerrestrialDynamicalTime < $1.julianDateTerrestrialDynamicalTime
    }
  }

  public func eclipses(fromYear startYear: Int, through endYear: Int) -> [LunarEclipse] {
    guard startYear <= endYear else { return [] }
    return eclipses.filter { (startYear...endYear).contains($0.year) }
  }

  public func eclipses(from startDateTD: Double, through endDateTD: Double) -> [LunarEclipse] {
    guard startDateTD <= endDateTD else { return [] }
    let start = eclipses.partitioningIndex {
      $0.julianDateTerrestrialDynamicalTime >= startDateTD
    }
    let end = eclipses.partitioningIndex {
      $0.julianDateTerrestrialDynamicalTime > endDateTD
    }
    return Array(eclipses[start..<end])
  }

  public static func loadBundled() throws -> LunarEclipseCatalog {
    guard let url = Bundle.module.url(
      forResource: "lunar-eclipses",
      withExtension: "bin",
      subdirectory: "AstronomyData"
    ) else { throw LunarEclipseCatalogError.resourceMissing }
    return try decode(Data(contentsOf: url))
  }

  static func decode(_ data: Data) throws -> LunarEclipseCatalog {
    var reader = LunarEclipseReader(data: data)
    guard try reader.bytes(8) == Array("CALLE001".utf8) else {
      throw LunarEclipseCatalogError.invalidHeader
    }
    let version = try reader.uint16()
    guard version == 1 else { throw LunarEclipseCatalogError.unsupportedVersion(version) }
    guard try reader.uint16() == 54 else { throw LunarEclipseCatalogError.invalidHeader }
    let count = try reader.uint32()
    _ = try reader.uint32()
    var eclipses: [LunarEclipse] = []
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
      let values = try (0..<6).map { _ in try reader.float() }
      eclipses.append(LunarEclipse(
        year: year, month: month, day: day, greatestEclipseSeconds: seconds,
        julianDateTerrestrialDynamicalTime: julianDate, deltaTSeconds: deltaT,
        lunationNumber: lunation, sarosNumber: saros, type: type,
        gamma: values[0], penumbralMagnitude: values[1], umbralMagnitude: values[2],
        penumbralDurationMinutes: values[3].isNaN ? nil : values[3],
        partialDurationMinutes: values[4].isNaN ? nil : values[4],
        totalDurationMinutes: values[5].isNaN ? nil : values[5]
      ))
    }
    return LunarEclipseCatalog(eclipses: eclipses)
  }
}

private extension Collection {
  func partitioningIndex(where predicate: (Element) -> Bool) -> Index {
    var lower = startIndex
    var count = self.count
    while count > 0 {
      let step = count / 2
      let middle = index(lower, offsetBy: step)
      if predicate(self[middle]) {
        count = step
      } else {
        lower = index(after: middle)
        count -= step + 1
      }
    }
    return lower
  }
}

private struct LunarEclipseReader {
  let data: Data
  var offset = 0

  mutating func bytes(_ count: Int) throws -> [UInt8] {
    guard offset + count <= data.count else { throw LunarEclipseCatalogError.truncatedData }
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
