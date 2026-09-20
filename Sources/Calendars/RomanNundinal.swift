public enum RomanNundinalLetter: Character, CaseIterable, Codable, Sendable {
  case A = "A", B = "B", C = "C", D = "D"
  case E = "E", F = "F", G = "G", H = "H"

  public var conventional: RomanNundinalLetter {
    switch self {
    case .A: .A
    case .B: .H
    case .C: .G
    case .D: .F
    case .E: .E
    case .F: .D
    case .G: .C
    case .H: .B
    }
  }
}

public struct RomanNundinalMarketLetters: Equatable, Sendable {
  public let beforeIntercalation: RomanNundinalLetter
  public let afterIntercalation: RomanNundinalLetter?

  public var conventionalBeforeIntercalation: RomanNundinalLetter {
    beforeIntercalation.conventional
  }

  public var conventionalAfterIntercalation: RomanNundinalLetter? {
    afterIntercalation?.conventional
  }
}

extension RomanCalendar {
  public func cycleDay(atJDN jdn: Int, cycle: CalendarCycle) -> CalendarCycleDay? {
    guard cycle == .nundinal else {
      return defaultCycleDay(atJDN: jdn, cycle: cycle)
    }
    guard let letter = nundinalLetter(atJDN: jdn),
          let asciiValue = letter.rawValue.asciiValue else { return nil }
    return CalendarCycleDay(
      cycle: .nundinal,
      ordinal: Int(asciiValue) - 65,
      label: String(letter.rawValue),
      role: isNundinalMarketDay(atJDN: jdn) == true ? .commonRest : .working
    )
  }

  public func nundinalMarketLetters(forYear year: Int) -> RomanNundinalMarketLetters? {
    guard let anchor = RomanCalendar.table.anchor(forYear: year),
          let first = anchor.nundinalMarketLetter else { return nil }
    return RomanNundinalMarketLetters(
      beforeIntercalation: first,
      afterIntercalation: anchor.nundinalMarketLetterAfterIntercalation
    )
  }

  public func nundinalLetter(atJDN jdn: Int) -> RomanNundinalLetter? {
    guard let date = date(fromJDN: jdn),
          let anchor = RomanCalendar.table.anchor(forYear: date.year) else { return nil }
    let index = (jdn - anchor.yearStartJDN) % RomanNundinalLetter.allCases.count
    return RomanNundinalLetter.allCases[index]
  }

  public func isNundinalMarketDay(atJDN jdn: Int) -> Bool? {
    guard let date = date(fromJDN: jdn),
          let anchor = RomanCalendar.table.anchor(forYear: date.year),
          let letter = nundinalLetter(atJDN: jdn),
          let firstMarketLetter = anchor.nundinalMarketLetter else { return nil }

    let intercalationStart = RomanCalendar.table.monthRows(forYear: date.year)
      .first(where: \.isIntercalary)
      .map { anchor.yearStartJDN + $0.offsetFromYearStart }
    let isAfterIntercalation = anchor.nundinalAfterIntercalationAtYearStart
      || intercalationStart.map { jdn >= $0 } == true
    let marketLetter = if isAfterIntercalation,
                          let after = anchor.nundinalMarketLetterAfterIntercalation {
      after
    } else {
      firstMarketLetter
    }
    return letter == marketLetter
  }
}
