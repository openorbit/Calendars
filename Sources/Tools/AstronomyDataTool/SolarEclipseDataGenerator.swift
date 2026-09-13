import Foundation

struct GeneratedSolarEclipse {
  let year: Int16
  let month: UInt8
  let day: UInt8
  let greatestEclipseSeconds: UInt32
  let julianDate: Double
  let deltaT: Float
  let lunation: Int32
  let saros: Int16
  let type: String
  let gamma: Float
  let magnitude: Float
  let latitude: Float
  let longitude: Float
  let sunAltitude: Float
  let sunAzimuth: Float
  let pathWidthKilometers: Float
  let centralDurationSeconds: Float
  let besselian: [Float]
}

enum SolarEclipseDataGenerator {
  static func read(_ url: URL) throws -> [GeneratedSolarEclipse] {
    let rows = try String(contentsOf: url, encoding: .utf8)
      .split(whereSeparator: \.isNewline)
    guard rows.count > 1 else { throw GeneratorError.noRecords }
    return try rows.dropFirst().enumerated().map { offset, row in
      let fields = row.split(separator: ",", omittingEmptySubsequences: false)
        .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) }
      guard fields.count >= 54,
            let year = Int16(fields[0]),
            let month = UInt8(fields[1]),
            let day = UInt8(fields[2]),
            let deltaT = Float(fields[4]),
            let lunation = Int32(fields[5]),
            let saros = Int16(fields[6]),
            let gamma = Float(fields[8]),
            let magnitude = Float(fields[9]),
            let latitude = Float(fields[12]),
            let longitude = Float(fields[13]),
            let sunAltitude = Float(fields[14]),
            let sunAzimuth = Float(fields[15]),
            let julianDate = Double(fields[21]) else {
        throw GeneratorError.malformedRecord(file: url.lastPathComponent, line: offset + 2)
      }
      let time = fields[3].split(separator: ":").compactMap { Int($0) }
      guard time.count == 3 else {
        throw GeneratorError.malformedRecord(file: url.lastPathComponent, line: offset + 2)
      }
      return GeneratedSolarEclipse(
        year: year,
        month: month,
        day: day,
        greatestEclipseSeconds: UInt32(time[0] * 3_600 + time[1] * 60 + time[2]),
        julianDate: julianDate,
        deltaT: deltaT,
        lunation: lunation,
        saros: saros,
        type: fields[7],
        gamma: gamma,
        magnitude: magnitude,
        latitude: latitude,
        longitude: longitude,
        sunAltitude: sunAltitude,
        sunAzimuth: sunAzimuth,
        pathWidthKilometers: Float(fields[16]) ?? .nan,
        centralDurationSeconds: Float(fields[18]) ?? .nan,
        besselian: (22...46).map { Float(fields[$0]) ?? .nan }
      )
    }
  }
}
