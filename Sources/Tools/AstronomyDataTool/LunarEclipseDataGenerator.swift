import Foundation

struct GeneratedLunarEclipse {
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
  let penumbralMagnitude: Float
  let umbralMagnitude: Float
  let penumbralDurationMinutes: Float?
  let partialDurationMinutes: Float?
  let totalDurationMinutes: Float?
}

enum LunarEclipseDataGenerator {
  private static let months = [
    "Jan": 1, "Feb": 2, "Mar": 3, "Apr": 4, "May": 5, "Jun": 6,
    "Jul": 7, "Aug": 8, "Sep": 9, "Oct": 10, "Nov": 11, "Dec": 12,
  ]

  static func read(_ url: URL) throws -> [GeneratedLunarEclipse] {
    try String(contentsOf: url, encoding: .ascii)
      .split(whereSeparator: \.isNewline)
      .enumerated()
      .compactMap { offset, row in
        let fields = row.split(whereSeparator: \.isWhitespace).map(String.init)
        guard fields.count >= 13, fields[0].count == 5,
              fields[0].allSatisfy(\.isNumber) else { return nil }
        guard let year = Int16(fields[1]),
              let month = months[fields[2]].flatMap(UInt8.init),
              let day = UInt8(fields[3]),
              let deltaT = Float(fields[5]),
              let lunation = Int32(fields[6]),
              let saros = Int16(fields[7]),
              let gamma = Float(fields[10]),
              let penumbralMagnitude = Float(fields[11]),
              let umbralMagnitude = Float(fields[12]) else {
          throw GeneratorError.malformedRecord(file: url.lastPathComponent, line: offset + 1)
        }
        let time = fields[4].split(separator: ":").compactMap { Int($0) }
        guard time.count == 3 else {
          throw GeneratorError.malformedRecord(file: url.lastPathComponent, line: offset + 1)
        }
        let seconds = time[0] * 3_600 + time[1] * 60 + time[2]
        return GeneratedLunarEclipse(
          year: year,
          month: month,
          day: day,
          greatestEclipseSeconds: UInt32(seconds),
          julianDate: julianDate(
            year: Int(year), month: Int(month), day: Int(day), seconds: seconds
          ),
          deltaT: deltaT,
          lunation: lunation,
          saros: saros,
          type: fields[8],
          gamma: gamma,
          penumbralMagnitude: penumbralMagnitude,
          umbralMagnitude: umbralMagnitude,
          penumbralDurationMinutes: optionalFloat(fields, at: 13),
          partialDurationMinutes: optionalFloat(fields, at: 14),
          totalDurationMinutes: optionalFloat(fields, at: 15)
        )
      }
  }

  private static func optionalFloat(_ fields: [String], at index: Int) -> Float? {
    guard fields.indices.contains(index), fields[index] != "-" else { return nil }
    return Float(fields[index])
  }

  /// NASA uses the Julian calendar before 1582-10-15 and Gregorian thereafter.
  private static func julianDate(year: Int, month: Int, day: Int, seconds: Int) -> Double {
    var adjustedYear = year
    var adjustedMonth = month
    if adjustedMonth <= 2 {
      adjustedYear -= 1
      adjustedMonth += 12
    }
    let isGregorian = (year, month, day) >= (1582, 10, 15)
    let correction: Double
    if isGregorian {
      let century = floor(Double(adjustedYear) / 100)
      correction = 2 - century + floor(century / 4)
    } else {
      correction = 0
    }
    return floor(365.25 * Double(adjustedYear + 4_716))
      + floor(30.6001 * Double(adjustedMonth + 1))
      + Double(day) + correction - 1_524.5 + Double(seconds) / 86_400
  }
}
