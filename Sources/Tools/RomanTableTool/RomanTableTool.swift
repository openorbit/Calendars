// Helper tool to generate roman republican calendar tables.
//
// This tool reads the Bennett tables as found here:
//  https://www.instonebrewer.com/TyndaleSites/Egypt/ptolemies/chron/roman/046bc_fr.htm
//
// We have also added two columns, Julian Year, and Julian Year After.
// These are the astronomical year corresponding to the B.C field.
// I.e. negated B.C. field + 1 to align BC 1 to 0.
// We have also dropped the second header switching to AD,
// as this was redundant with astronomical years.
//
// We have ensured that the columns in the file have unique names, to simplify the
// parsing.
//
// This was done by rnaming the second B.C. field, and second AUC field.
// They are End AUC and End B.C. to ensure we do not have colliding column names.
//
// The columns are in order:
//  - B.C.
//  - AUC
//  - Julian Year
//  - Ianuarius
//  - Februarius
//  - Intercalaris
//  - Martius
//  - Aprilis
//  - Maius
//  - Iunius
//  - Quintilis
//  - Sextilis
//  - September
//  - October
//  - November
//  - Int I
//  - Int II
//  - December
//  - End AUC
//  - End B.C.
//  - Nundinal
//  - Julian Year After
//
// This code is fairly messy, and is not intended as an end user tool.
//
// The tool is run by giving the modified CSV of the Roman calendar tables.
// It then does the following:
//
// Normalizes every roman month to an entry of the AUC of the months Kalends,
// the month, and the corresponding Julian date components.
// It extrapolates the first year (there are no intercalations there)
// to ensure we cover the entire year. I.e. we extend the year from IAN to MAI,
// as the civil year starts in MAI at that time frame.
// We then build the Table calendar using our package types,
// and emits an initializer in Swift.
// This initializer is than pasted into the RomanYearsData.swift file.
// Note that the init function is currently using append on each entry,
// as the swift compiler / Xcode use excessive memory
// for large constant tables.



import Foundation
import Calendars
import SwiftCSV

extension RomanMonth: CustomStringConvertible {
  public var description: String {
    switch self {
    case .IAN: return "IAN"
    case .FEB: return "FEB"
    case .INT: return "INT"
    case .MAR: return "MAR"
    case .APR: return "APR"
    case .MAI: return "MAI"
    case .IUN: return "IUN"
    case .QUI: return "QUI"
    case .SEX: return "SEX"
    case .SEP: return "SEP"
    case .OCT: return "OCT"
    case .NOV: return "NOV"
    case .INT_I: return "INT_I"
    case .INT_II: return "INT_II"
    case .DEC: return "DEC"
    }
  }
}

extension RomanMonth {
  static func parse(_ raw: String) -> RomanMonth? {
    let s = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    switch s {
    case "IAN","IANUARIUS": return .IAN
    case "FEB","FEBRUARIUS": return .FEB
    case "MAR","MARTIUS": return .MAR
    case "APR","APRILIS": return .APR
    case "MAI","MAIUS","MAY": return .MAI
    case "IUN","JUN","IUNIUS": return .IUN
    case "QUI","QUINTILIS","IUL","JUL","JULIUS": return .QUI
    case "SEX","SEXTILIS","AUG","AUGUSTUS": return .SEX
    case "SEP","SEPTEMBER": return .SEP
    case "OCT","OCTOBER": return .OCT
    case "NOV","NOVEMBER": return .NOV
    case "DEC","DECEMBER": return .DEC
    case "INT","INTERCALARIS","MER","MERCEDONIUS": return .INT
    case "INT I","INTI","INTERCALARIS I": return .INT_I
    case "INT II","INTII","INTERCALARIS II": return .INT_II
    default: return nil
    }
  }
}

// Proleptic Julian month names used in Bennett’s file (English 3-letter)
private let julMonToInt: [String:Int] = [
    "JAN":1,"FEB":2,"MAR":3,"APR":4,"MAY":5,"MAJ":5,"JUN":6,"JUL":7,
    "AUG":8,"SEP":9,"SEPT":9,"OCT":10,"NOV":11,"DEC":12
]


// ------------------------
// Parsing Bennett row
// ------------------------
struct Anchor {
  let auc: Int
  let rmon: RomanMonth
  let jy: Int
  let jm: Int
  let jd: Int
  var jdn: Int { jdnFromJulian(jy, jm, jd) }
}


struct NormalizedRecord : Sendable {
  public let auc: Int
  public let month: RomanMonth
  public let julianYear: Int
  public let julianMonth: Int
  public let julianDay: Int
  public let days: Int
}
struct RomanDay : Sendable {
  public let month: RomanMonth
  public let day: Int  // 1..31 (Kalends=1, Nones=5/7, Ides=13/15 if you ever want those names)
}

struct NundinalPhase {
  public let start: Character              // e.g. "C"
  public let afterIntercalation: Character? // e.g. "D" or nil
}

func totalDays(_ rows: [NormalizedRecord]) -> Int {
  rows.reduce(0) { $0 + $1.days }
}



func normalize(csvPath: String) throws -> BuildInputs {
  // Read year-oriented CSV with SwiftCSV
  var records: [NormalizedRecord] = []
  var consularStartByAUC: [Int: RomanDay] = [:]        // default .IAN 1 if missing
  var nundinalPhaseByAUC: [Int: NundinalPhase]  = [:]  // must exist per year


  print("Loading CSV")
  let csv = try CSV<Named>(url: URL(fileURLWithPath: csvPath))

  // Build list of anchors (month Kalends) with AUC + RomanMonth + Julian date
  print("Building Anchors")

  let monthRegex = /(?<day>[0-9]+)-(?<month>Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)/

  let julianMonthValues = ["Jan": 1, "Feb": 2, "Mar": 3, "Apr": 4, "May": 5, "Jun": 6, "Jul": 7, "Aug": 8, "Sep": 9, "Oct": 10, "Nov": 11, "Dec": 12]

  // as appearing in file
  let indices : [Int: RomanMonth] = [
    0: .IAN ,1:  .FEB, 2: .INT, 3: .MAR, 4: .APR, 5: .MAI, 6: .IUN, 7: .QUI, 8: .SEX, 9: .SEP, 10: .OCT, 11: .NOV, 12: .INT_I, 13: .INT_II, 14: .DEC]

  print("CSV has \(csv.rows.count) rows")

  var julianDates: [(Int, RomanMonth, Int, Int, Int, Int)] = []

  let initialJulianYear = Int(csv.rows[0]["Julian Year"]!)!
  var year = initialJulianYear
  for row in csv.rows {
    print("CSV ROW: \(row)")
    guard let aucStr = row["AUC"], let auc = Int(aucStr) else {
      fatalError("Could not parse AUC from \(row)")
    }
    //guard let julianStartStr = row["Julian Year"], let jyStart = Int(julianStartStr) else {
    //  fatalError("Could not parse Julian Start from \(row)")
    //}
    //guard let julianEndStr = row["Julian Year After"], let jyEnd = Int(julianEndStr) else {
    //  fatalError("Could not parse Julian End from \(row)")
    //}
    //guard let aucEndStr = row["End AUC"], let aucEnd = Int(aucEndStr) else {
    //  fatalError("Could not parse AUC End from \(row)")
    //}
    let nundinal = row["Nundinal"] ?? ""
    guard let janStr = row["Ianuarius"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let febStr = row["Februarius"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let intStr = row["Intercalaris"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let marStr = row["Martius"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let aprStr = row["Aprilis"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let mayStr = row["Maius"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let junStr = row["Iunius"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let julStr = row["Quintilis"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let augStr = row["Sextilis"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let sepStr = row["September"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let octStr = row["October"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let novStr = row["November"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let intIStr = row["Int I"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let intIIStr = row["Int II"] else {
      fatalError("Could not get month from \(row)")
    }
    guard let decStr = row["December"] else {
      fatalError("Could not get month from \(row)")
    }

    if auc <= 530 {
      consularStartByAUC[auc] =  RomanDay(month: .MAI, day: 1)
    } else if auc < 599  {
      consularStartByAUC[auc] =  RomanDay(month: .MAR, day: 15)
    } else {
      consularStartByAUC[auc] =  RomanDay(month: .IAN, day: 1)
    }

    if nundinal.count == 1, let first = nundinal.first {
      nundinalPhaseByAUC[auc] = NundinalPhase(start: first, afterIntercalation: nil)
    } else if nundinal.count >= 2 {
      let first = nundinal[nundinal.startIndex]
      let secondIndex = nundinal.index(after: nundinal.startIndex)
      let second = nundinal[secondIndex]
      nundinalPhaseByAUC[auc] = NundinalPhase(start: first, afterIntercalation: second)
    } else {
      fatalError("Could not nundinal is not 1 or 2 characters in \(row)")
    }
    let months = [janStr, febStr, intStr, marStr, aprStr, mayStr, junStr,
                  julStr, augStr, sepStr, octStr, novStr,
                  intIStr, intIIStr, decStr]

    // Iterate over roman months starts in julian
    // We may need to bump the julian year
    var monthDayValues: [(Int, Int, RomanMonth)] = []
    for monthIndex in months.indices {
      let month = months[monthIndex]
      if let result = try? monthRegex.wholeMatch(in: month) {
        let day = Int(result.day)!
        let month = String(result.month)
        let monthValue = julianMonthValues[month]!
        monthDayValues.append((monthValue, day, indices[monthIndex]!))
      }
    }

    for (month, day, romanMonth) in monthDayValues {
      julianDates.append((auc, romanMonth, year, month, day, -1))
    }
  }

  year = initialJulianYear
  // Calculate exact years
  var (_, _, _, previousMonth, _, _) = julianDates[0]
  for i in julianDates.indices {
    let (auc, romanMonth, _, month, day, days) = julianDates[i]
    if previousMonth == 12 && month == 1 {
      year += 1
    }
    let aucAdjustment = ((auc <= 530 && romanMonth >= .MAI) || (531 <= auc && auc <= 599 && romanMonth >= .APR)) ? 1 : 0
    julianDates[i] = (auc + aucAdjustment, romanMonth, year, month, day, days)
    previousMonth = month
  }

  print("Number of collected dates: \(julianDates.count)")
  // Calculate lengths
  for i in julianDates.indices {
    let currentMonth = JulianCalendar.toJDN(Y: julianDates[i].2, M: julianDates[i].3, D: julianDates[i].4)

    let nextMonth =
    if i == julianDates.count - 1 {
      JulianCalendar.toJDN(Y: julianDates[i].2 + 1, M: 1, D: 1)
    } else {
      JulianCalendar.toJDN(Y: julianDates[i+1].2, M: julianDates[i+1].3, D: julianDates[i+1].4)
    }
    assert(nextMonth - currentMonth <= 34)
    let (auc, m, jy, jm, jd, _) = julianDates[i]
    julianDates[i] = (auc, m, jy, jm, jd, nextMonth - currentMonth)
  }

  // We now extrapolate the months back to MAI so we have the complete year
  var extrapolatedDates: [(Int, RomanMonth, Int, Int, Int, Int)] = []

  let (auc, _, jy, jm, jd, _) = julianDates[0]
  var monthJD = JulianCalendar.toJDN(Y: jy, M: jm, D: jd)
  for (month, days) in [(RomanMonth.DEC, 29), (RomanMonth.NOV, 29), (RomanMonth.OCT, 31),
            (RomanMonth.SEP, 29), (RomanMonth.SEX, 29), (RomanMonth.QUI, 31),
            (RomanMonth.IUN, 29), (RomanMonth.MAI, 31)] {
    monthJD -= days
    let (y,m,d) = JulianCalendar.toDate(J: monthJD)

    extrapolatedDates.append((auc, month, y, m, d, days))
  }

  extrapolatedDates.reverse()
  julianDates = extrapolatedDates + julianDates
  for (auc, mon, jy, jm, jd, days) in julianDates {
    records.append(NormalizedRecord(auc: auc, month: mon, julianYear: jy, julianMonth: jm, julianDay: jd, days: days))
  }

  return BuildInputs(records: records)
}

@main
struct RomanCalendarNormalize {
  static func main() {
    guard CommandLine.arguments.count >= 2 else {
      fputs("""
        Usage: roman-civil-normalize <year_oriented.csv> [output.csv]
        
        Input CSV headers (case-sensitive recommended):
          AUC, IAN, FEB, MAR, APR, MAI, IUN, QUI, SEX, SEP, OCT, NOV, DEC, INT, INT I, INT II
        
        Each month cell: e.g.  "-41 Jan 2" (astronomical year; English month; day)
        Empty cell => month absent that year.
        """, stderr)
      exit(2)
    }

    let input = CommandLine.arguments[1]
    let outputPath = (CommandLine.arguments.count >= 3) ? CommandLine.arguments[2] : nil

    do {
      let rows = try normalize(csvPath: input)
      var csvText = "auc,roman_month,julian_y,julian_m,julian_d,days,jdn\n"
      csvText.reserveCapacity(rows.records.count * 36)
      for r in rows.records {
        csvText += "\(r.auc),\(r.month.description),\(r.julianYear),\(r.julianMonth),\(r.julianDay),\(r.days),\(JulianCalendar.toJDN(Y: r.julianYear, M: r.julianMonth, D: r.julianDay))\n"
      }

      if let outPath = outputPath {
        try csvText.write(to: URL(fileURLWithPath: outPath), atomically: true, encoding: .utf8)
      } else {
        print(csvText, terminator: "")
      }

      let tables = buildRomanYears(rows)
      try emitSwift(tables: tables, into: "years.swift")


    } catch {
      fputs("Error: \(error)\n", stderr)
      exit(1)
    }
  }
}


@inline(__always) func jdnFromJulian(_ y: Int, _ m: Int, _ d: Int) -> Int {
  JulianCalendar.toJDN(Y: y, M: m, D: d)
}
@inline(__always) func julianFromJDN(_ J: Int) -> (y: Int, m: Int, d: Int) {
  JulianCalendar.toDate(J: J)
}

// Build years; you supply consular starts and nundinal phases per AUC
struct BuildInputs {
  let records: [NormalizedRecord]
  init(records: [NormalizedRecord]) {
    self.records = records
  }
}

func buildRomanYears(_ input: BuildInputs) -> TableCalendar {
  precondition(!input.records.isEmpty, "No normalized records provided")

  // Group by AUC
  // Collect indices of all AUC years in the input
  let startAUC = input.records[0].auc
  var aucIndices: [Int] = [0]
  var prevAUC = startAUC
  for i in 1..<input.records.count {
    if input.records[i].auc != prevAUC {
      aucIndices.append(i)
    }

    prevAUC = input.records[i].auc
  }

  var monthEntries: [MonthRow] = []

  // We now know the index in the recods for each AUC
  var yearAnchors: [YearAnchor] = []
  for i in 0..<aucIndices.count {
    let startIndex = aucIndices[i]
    let nextIndex =
    if aucIndices.indices.contains(i + 1) {
      aucIndices[i + 1]
    } else {
      startIndex + 12
    }

    let auc = startAUC + i
    let r = input.records[startIndex]
    let firstNormalMonthJDN = JulianCalendar.toJDN(Y: r.julianYear, M: r.julianMonth, D: r.julianDay)

    // March is 31 days, therefore we subtract 17 to get to march 15
    let adjustment = (531 <= auc && auc <= 599) ? 17 : 0
    let startJDN = firstNormalMonthJDN - adjustment

    var leadingFrag: YearAnchor.LeadingFragment? = nil
    if adjustment > 0 {
      leadingFrag = YearAnchor.LeadingFragment(monthInfoIndex: RomanMonth.MAR.slot, startDay: 15, length: 17)
    }
    yearAnchors.append(YearAnchor(year: auc, yearStartJDN: startJDN, yearEndJDN: 0,
                                  monthRows: startIndex ..< nextIndex,
                                  leadingFragment: leadingFrag))
  }


  for i in input.records.indices {
    let r = input.records[i]
    let monthJDN = JulianCalendar.toJDN(Y: r.julianYear, M: r.julianMonth, D: r.julianDay)
    print("\(r) \(monthJDN)")
    let offsetFromStart = monthJDN - yearAnchors[r.auc - startAUC].yearStartJDN
    assert(offsetFromStart >= 0)
    let monthIndex = i - yearAnchors[r.auc - startAUC].monthRows.startIndex + 1
    let row = MonthRow(year: r.auc, appearanceMonth: monthIndex, offsetFromYearStart: offsetFromStart,
                       length: r.days, isIntercalary: [.INT, .INT_I, .INT_II].contains(r.month),
                       monthInfoIndex: r.month.slot)
    monthEntries.append(row)
  }


  // Now update the endJDN for all the years
  for i in 0..<yearAnchors.count - 1 {
    let oldAnchor = yearAnchors[i]
    let nextAnchor = yearAnchors[i+1]
    yearAnchors[i] = YearAnchor(year: oldAnchor.year,
                                yearStartJDN: oldAnchor.yearStartJDN,
                                yearEndJDN: nextAnchor.yearStartJDN,
                                monthRows: oldAnchor.monthRows,
                                leadingFragment: oldAnchor.leadingFragment)
  }
  var lastYear = yearAnchors.last!
  lastYear.yearEndJDN = lastYear.yearStartJDN + monthEntries.last!.offsetFromYearStart + monthEntries.last!.length
  yearAnchors[yearAnchors.count-1] = lastYear
  var jdnBuckets: [Int : [Int]] = [:]
  let firstJDN = yearAnchors[0].yearStartJDN

  var maxBucketIndex = 0
  for i in monthEntries.indices {
    let month = monthEntries[i]
    let auc = month.year
    let startJDN = yearAnchors[auc - startAUC].yearStartJDN
    let jdnOfMonth = startJDN + month.offsetFromYearStart
    let endJDNOfMonth = jdnOfMonth + month.length - 1
    let bucketIndex = (jdnOfMonth - firstJDN) / 32
    let endBucketIndex = (endJDNOfMonth - firstJDN) / 32
    assert(bucketIndex >= 0)
    assert(endBucketIndex >= 0)

    for j in bucketIndex ... endBucketIndex {
      if jdnBuckets[j] == nil {
        jdnBuckets[j] = []
      }
    }

    for j in bucketIndex ... endBucketIndex {
      jdnBuckets[j]!.append(i)
      maxBucketIndex = max(maxBucketIndex, j)
    }
  }

  var buckets : [Range<Int>] = Array(repeating: 0..<0, count: maxBucketIndex + 1)
  for (bucketIndex, indices) in jdnBuckets {
    var minIndex = Int.max
    var maxIndex = -1
    for i in indices {
      minIndex = min(minIndex, i)
      maxIndex = max(maxIndex, i)
    }
    buckets[bucketIndex] = minIndex ..< maxIndex + 1
  }

  let tables = TableCalendar(years: yearAnchors, months: monthEntries, reverse: buckets)

  return tables
}

func emitSwift(tables: TableCalendar, into path: String) throws {
  var s = ""
  func w(_ line: String = "") { s += line + "\n" }

  w("// AUTO-GENERATED — Roman years (Bennett normalized)")
  w("import Foundation\n")

  w("enum RomanTables {")

  w("  static var months : [MonthRow] {")

  w("    var months: [MonthRow] = []")
  w("    months.reserveCapacity(\(tables.months.count))")
  for m in tables.months {
    w("    months.append(")
    w("      MonthRow(")
    w("        year: \(m.year),")
    w("        appearanceMonth: \(m.appearanceMonth),")
    w("        offsetFromYearStart: \(m.offsetFromYearStart),")
    w("        length: \(m.length),")
    w("        isIntercalary: \(m.isIntercalary),")
    w("        monthInfoIndex: \(m.monthInfoIndex),")
    w("      )")
    w("    )")
  }
  w("    return months")
  w("  }")

  w("  static var anchors : [YearAnchor] {")

  w("    var years: [YearAnchor] = []")
  w("    years.reserveCapacity(\(tables.years.count))")

  for y in tables.years {
    w("    years.append(")
    w("      YearAnchor(")
    w("        year: \(y.year),")
    w("        yearStartJDN: \(y.yearStartJDN),")
    w("        yearEndJDN: \(y.yearEndJDN),")
    w("        monthRows: \(y.monthRows.startIndex)..<\(y.monthRows.endIndex),")
    if let frag = y.leadingFragment {
      w("        leadingFragment: YearAnchor.LeadingFragment(monthInfoIndex: \(frag.monthInfoIndex), startDay: \(frag.startDay), length: \(frag.length)),")
    } else {
      w("        leadingFragment: nil,")
    }
    w("      )")
    w("    )")
  }
  w("    return years")
  w("  }")


  w("  static var reverse : [Range<Int>] {")
  w("    var buckets: [Range<Int>] = []")
  w("    buckets.reserveCapacity(\(tables.reverse.count))")

  for b in tables.reverse {
    w("    buckets.append(\(b.startIndex)..<\(b.endIndex))")
  }
  w("    return buckets")
  w("  }")

  w("}")

  try s.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
}
