import Foundation

public struct HistoricalStar: Equatable, Sendable {
  public let brightStarNumber: UInt32
  public let hipparcosIdentifier: UInt32
  public let henryDraperIdentifier: UInt32
  public let designation: String
  public let rightAscensionRadians: Double
  public let declinationRadians: Double
  public let parallaxMilliarcseconds: Float
  public let properMotionRightAscension: Float
  public let properMotionDeclination: Float
  public let radialVelocityKilometersPerSecond: Float?
  public let visualMagnitude: Float
  public let colorIndexBV: Float?
  public let solutionType: UInt8
  public let componentCount: UInt8
}

public enum HistoricalStarCatalogError: Error, Equatable {
  case resourceMissing
  case invalidHeader
  case unsupportedVersion(UInt16)
  case truncatedData
}

public struct HistoricalStarCatalog: Sendable {
  public static let shared: HistoricalStarCatalog = {
    do {
      return try HistoricalStarCatalog.loadBundled()
    } catch {
      return HistoricalStarCatalog(stars: [])
    }
  }()

  public let stars: [HistoricalStar]

  public init(stars: [HistoricalStar]) {
    self.stars = stars
  }

  public func star(brightStarNumber: UInt32) -> HistoricalStar? {
    stars.first { $0.brightStarNumber == brightStarNumber }
  }

  public func star(hipparcosIdentifier: UInt32) -> HistoricalStar? {
    stars.first { $0.hipparcosIdentifier == hipparcosIdentifier }
  }

  public static func loadBundled() throws -> HistoricalStarCatalog {
    guard let url = Bundle.module.url(
      forResource: "historical-stars",
      withExtension: "bin",
      subdirectory: "AstronomyData"
    ) else {
      throw HistoricalStarCatalogError.resourceMissing
    }
    return try decode(Data(contentsOf: url))
  }

  static func decode(_ data: Data) throws -> HistoricalStarCatalog {
    var reader = LittleEndianReader(data: data)
    guard try reader.bytes(count: 8) == Array("CALSTAR1".utf8) else {
      throw HistoricalStarCatalogError.invalidHeader
    }
    let version = try reader.uint16()
    guard version == 1 else {
      throw HistoricalStarCatalogError.unsupportedVersion(version)
    }
    let recordSize = try reader.uint16()
    guard recordSize == 68 else {
      throw HistoricalStarCatalogError.invalidHeader
    }
    let count = try reader.uint32()
    _ = try reader.uint32()

    var stars: [HistoricalStar] = []
    stars.reserveCapacity(Int(count))
    for _ in 0 ..< count {
      let hr = try reader.uint32()
      let hip = try reader.uint32()
      let hd = try reader.uint32()
      let ra = try reader.double()
      let dec = try reader.double()
      let parallax = try reader.float()
      let pmRA = try reader.float()
      let pmDE = try reader.float()
      let radialVelocity = try reader.float()
      let magnitude = try reader.float()
      let colorIndex = try reader.float()
      let solutionType = try reader.uint8()
      let componentCount = try reader.uint8()
      _ = try reader.uint16()
      let designationBytes = try reader.bytes(count: 12)
      let designation = String(
        bytes: designationBytes.prefix { $0 != 0 },
        encoding: .utf8
      )?.trimmingCharacters(in: .whitespaces) ?? ""

      stars.append(HistoricalStar(
        brightStarNumber: hr,
        hipparcosIdentifier: hip,
        henryDraperIdentifier: hd,
        designation: designation,
        rightAscensionRadians: ra,
        declinationRadians: dec,
        parallaxMilliarcseconds: parallax,
        properMotionRightAscension: pmRA,
        properMotionDeclination: pmDE,
        radialVelocityKilometersPerSecond: radialVelocity.isNaN ? nil : radialVelocity,
        visualMagnitude: magnitude,
        colorIndexBV: colorIndex.isNaN ? nil : colorIndex,
        solutionType: solutionType,
        componentCount: componentCount
      ))
    }
    return HistoricalStarCatalog(stars: stars)
  }
}

private struct LittleEndianReader {
  let data: Data
  var offset = 0

  mutating func bytes(count: Int) throws -> [UInt8] {
    guard count >= 0, offset + count <= data.count else {
      throw HistoricalStarCatalogError.truncatedData
    }
    defer { offset += count }
    return Array(data[offset ..< offset + count])
  }

  mutating func uint8() throws -> UInt8 { try bytes(count: 1)[0] }

  mutating func uint16() throws -> UInt16 {
    let value = try bytes(count: 2)
    return UInt16(value[0]) | UInt16(value[1]) << 8
  }

  mutating func uint32() throws -> UInt32 {
    let value = try bytes(count: 4)
    return UInt32(value[0]) | UInt32(value[1]) << 8 |
      UInt32(value[2]) << 16 | UInt32(value[3]) << 24
  }

  mutating func float() throws -> Float {
    Float(bitPattern: try uint32())
  }

  mutating func double() throws -> Double {
    let low = UInt64(try uint32())
    let high = UInt64(try uint32())
    return Double(bitPattern: low | high << 32)
  }
}
