import Foundation

public enum AstronomicalEventKind: UInt8, CaseIterable, Sendable {
  case marchEquinox
  case juneSolstice
  case septemberEquinox
  case decemberSolstice
  case newMoon
  case firstQuarter
  case fullMoon
  case lastQuarter
}

public struct AstronomicalEvent: Equatable, Sendable {
  public let kind: AstronomicalEventKind

  /// Event instant as a Julian Date in the TDB time scale.
  public let julianDateTDB: Double
}

public enum AstronomicalEventCatalogError: Error, Equatable {
  case resourceMissing
  case invalidHeader
  case unsupportedVersion(UInt16)
  case truncatedData
  case unknownEventKind(UInt8)
}

public struct AstronomicalEventCatalog: Sendable {
  public static let shared: AstronomicalEventCatalog = {
    (try? loadBundled()) ?? AstronomicalEventCatalog(events: [])
  }()

  public let events: [AstronomicalEvent]

  public init(events: [AstronomicalEvent]) {
    self.events = events.sorted { $0.julianDateTDB < $1.julianDateTDB }
  }

  public func events(
    from startDateTDB: Double,
    through endDateTDB: Double,
    kinds: Set<AstronomicalEventKind> = Set(AstronomicalEventKind.allCases)
  ) -> [AstronomicalEvent] {
    guard startDateTDB <= endDateTDB else { return [] }
    let start = events.partitioningIndex { $0.julianDateTDB >= startDateTDB }
    let end = events.partitioningIndex { $0.julianDateTDB > endDateTDB }
    return events[start..<end].filter { kinds.contains($0.kind) }
  }

  public static func loadBundled() throws -> AstronomicalEventCatalog {
    guard let url = Bundle.module.url(
      forResource: "astronomical-events",
      withExtension: "bin",
      subdirectory: "AstronomyData"
    ) else {
      throw AstronomicalEventCatalogError.resourceMissing
    }
    return try decode(Data(contentsOf: url))
  }

  static func decode(_ data: Data) throws -> AstronomicalEventCatalog {
    var reader = AstronomyEventReader(data: data)
    guard try reader.bytes(count: 8) == Array("CALEVT01".utf8) else {
      throw AstronomicalEventCatalogError.invalidHeader
    }
    let version = try reader.uint16()
    guard version == 1 else {
      throw AstronomicalEventCatalogError.unsupportedVersion(version)
    }
    guard try reader.uint16() == 16 else {
      throw AstronomicalEventCatalogError.invalidHeader
    }
    let count = try reader.uint32()
    _ = try reader.uint32()
    var events: [AstronomicalEvent] = []
    events.reserveCapacity(Int(count))
    for _ in 0..<count {
      let rawKind = try reader.uint8()
      guard let kind = AstronomicalEventKind(rawValue: rawKind) else {
        throw AstronomicalEventCatalogError.unknownEventKind(rawKind)
      }
      _ = try reader.bytes(count: 7)
      events.append(AstronomicalEvent(kind: kind, julianDateTDB: try reader.double()))
    }
    if events.count > 1 {
      for index in 1..<events.count where
        events[index - 1].julianDateTDB > events[index].julianDateTDB {
        throw AstronomicalEventCatalogError.invalidHeader
      }
    }
    return AstronomicalEventCatalog(events: events)
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

private struct AstronomyEventReader {
  let data: Data
  var offset = 0

  mutating func bytes(count: Int) throws -> [UInt8] {
    guard count >= 0, offset + count <= data.count else {
      throw AstronomicalEventCatalogError.truncatedData
    }
    defer { offset += count }
    return Array(data[offset..<offset + count])
  }

  mutating func uint8() throws -> UInt8 { try bytes(count: 1)[0] }

  mutating func uint16() throws -> UInt16 {
    let bytes = try bytes(count: 2)
    return UInt16(bytes[0]) | UInt16(bytes[1]) << 8
  }

  mutating func uint32() throws -> UInt32 {
    let bytes = try bytes(count: 4)
    return bytes.enumerated().reduce(0) { $0 | UInt32($1.element) << UInt32($1.offset * 8) }
  }

  mutating func double() throws -> Double {
    let bytes = try bytes(count: 8)
    let bits = bytes.enumerated().reduce(UInt64(0)) {
      $0 | UInt64($1.element) << UInt64($1.offset * 8)
    }
    return Double(bitPattern: bits)
  }
}
