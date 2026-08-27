import Foundation

public final class RegnalCalendar: @unchecked Sendable {
    public static let shared = RegnalCalendar()
    
    public let tenures: [RegnalTenure]
    public let persons: [String: RegnalPerson]
    public let offices: [String: RegnalOffice]
    public let polities: [String: RegnalPolity]
    public let magistracyGaps: [RomanMagistracyGap]
    public var consulYears: [RomanConsulYear] {
        let years = Set(
            tenures.compactMap { tenure -> Int? in
                guard tenure.consular?.role == .ordinaryConsul,
                      tenure.start.first?.calendar == "AUC" else { return nil }
                return tenure.start.first?.ymd?.year
            }
        )
        return years.sorted().compactMap { consularYear(auc: $0) }
    }
    
    private init() {
        // Load data into local vars first
        var t: [String: RegnalTenure] = [:]
        var p: [String: RegnalPerson] = [:]
        var o: [String: RegnalOffice] = [:]
        var pol: [String: RegnalPolity] = [:]
        var gaps: [String: RomanMagistracyGap] = [:]
        
        if let resourceURL = Bundle.module.url(forResource: "RegnalData", withExtension: nil) {
            let fileManager = FileManager.default
            if let enumerator = fileManager.enumerator(at: resourceURL, includingPropertiesForKeys: nil) {
                for case let fileURL as URL in enumerator {
                    if fileURL.pathExtension == "json" {
                        let filename = fileURL.lastPathComponent
                        if filename.contains("magistracy_gaps") {
                            if let data = try? Data(contentsOf: fileURL),
                               let items = try? JSONDecoder().decode([RomanMagistracyGap].self, from: data) {
                                for gap in items {
                                    gaps[gap.id] = gap
                                }
                            }
                        } else if filename.contains("tenures") {
                            if let data = try? Data(contentsOf: fileURL),
                               let items = try? JSONDecoder().decode([RegnalTenure].self, from: data) {
                                for tenure in items {
                                    let existingIsSourcedConsular = t[tenure.id]?.consular != nil
                                    if !existingIsSourcedConsular || tenure.consular != nil {
                                        t[tenure.id] = tenure
                                    }
                                }
                            }
                        } else if filename.contains("persons") {
                            if let data = try? Data(contentsOf: fileURL),
                                let items = try? JSONDecoder().decode([RegnalPerson].self, from: data) {
                                for person in items {
                                    let existingHasSourcedForm = p[person.id]?.variants.contains {
                                        $0.kind == "source"
                                    } == true
                                    let candidateHasSourcedForm = person.variants.contains {
                                        $0.kind == "source"
                                    }
                                    if !existingHasSourcedForm || candidateHasSourcedForm {
                                        p[person.id] = person
                                    }
                                }
                            }
                        } else if filename.contains("offices") {
                             if let data = try? Data(contentsOf: fileURL),
                                let items = try? JSONDecoder().decode([RegnalOffice].self, from: data) {
                                 for office in items {
                                     o[office.id] = office
                                 }
                             }
                        } else if filename.contains("polities") {
                             if let data = try? Data(contentsOf: fileURL),
                                let items = try? JSONDecoder().decode([RegnalPolity].self, from: data) {
                                 for polity in items {
                                     pol[polity.id] = polity
                                 }
                             }
                        }
                    }
                }
            }
        } else {
            print("RegnalData folder not found in Bundle.")
        }
        
        let assertedRomanGapYears = Set(
            gaps.values
                .filter { $0.polityID == "POLITY_ROMAN_REPUBLIC" }
                .map(\.auc)
        )
        self.tenures = t.values.filter { tenure in
            guard tenure.start.first?.calendar == "AUC",
                  let auc = tenure.start.first?.ymd?.year,
                  assertedRomanGapYears.contains(auc),
                  o[tenure.officeID]?.polityID == "POLITY_ROMAN_REPUBLIC" else {
                return true
            }
            return false
        }
        self.persons = p
        self.offices = o
        self.polities = pol
        self.magistracyGaps = Array(gaps.values)
    }
    
    // MARK: - Date Calculation
    
    public struct RegnalDate {
        public let year: Int // e.g., 5th year
        public let monarchName: String
    }
    
    /// Returns the (start, end) JulianDate for the Nth year of the given monarch/tenure.
    /// Regnal years usually start on the accession date.
    public func julianDateRange(forRegnalYear year: Int, tenure: RegnalTenure) -> (JulianDate, JulianDate)? {
        guard let startDefinition = tenure.start.first else { return nil }
        guard let startYMD = startDefinition.ymd else { return nil }
        
        let rawYear = startYMD.year
        let rawMonth = startYMD.month ?? 1
        let rawDay = startYMD.day ?? 1
        
        // Resolve Calendar
        var startYear = rawYear
        let startMonth = rawMonth
        let startDay = rawDay
        
        if startDefinition.calendar == "AUC" {
            let romanYear = rawYear + year - 1
            guard let startJDN = RomanCalendar.shared.startOfYearJDN(year: romanYear),
                  let endJDN = RomanCalendar.shared.endOfYearJDN(year: romanYear) else {
                return nil
            }
            return (JulianDate(jdn: startJDN), JulianDate(jdn: endJDN))
        }
        
        // Start of Nth year = Accession Day in (StartYear + N - 1)
        let regnalStartYear = startYear + (year - 1)
        let regnalStart = JulianDate(year: regnalStartYear, month: startMonth, day: startDay)
        
        // End is Start of (N+1)th year minus 1 day
        let regnalEndYear = startYear + year
        let regnalEndStart = JulianDate(year: regnalEndYear, month: startMonth, day: startDay)
        let regnalEnd = regnalEndStart.dateAdding(days: -1)
        
        return (regnalStart, regnalEnd)
    }
    
    /// Finds tenure candidates by monarch name (fuzzy or exact)
    public func findTenures(forMonarch name: String) -> [RegnalTenure] {
        let cleanName = name.normalizedRegnalName()
        
        let personIDs = persons.filter {
            let pName = $0.value.name.normalized.normalizedRegnalName()
            if pName.localizedCaseInsensitiveContains(cleanName) { return true }
            
            // Check variants
            if $0.value.variants.contains(where: { $0.form.normalizedRegnalName().localizedCaseInsensitiveContains(cleanName) }) { return true }
            
            return false
        }.map { $0.key }
        
        return tenures.filter { personIDs.contains($0.personID) }
    }



    
    // MARK: - Accessors
    
    public var allPolities: [RegnalPolity] {
        polities.values.sorted { $0.label < $1.label }
    }
    
    public func offices(forPolity polityID: String) -> [RegnalOffice] {
        return offices.values.filter { $0.polityID == polityID }.sorted { $0.label < $1.label }
    }
    
    public func tenures(forOffice officeID: String) -> [RegnalTenure] {
        tenures.filter { $0.officeID == officeID }.sorted {
            let startA = $0.start.first?.ymd?.year ?? Int.min
            let startB = $1.start.first?.ymd?.year ?? Int.min
            if startA != startB { return startA < startB }

            let endA = $0.end.first?.ymd?.year ?? Int.max
            let endB = $1.end.first?.ymd?.year ?? Int.max
            if endA != endB { return endA < endB }

            return $0.id < $1.id
        }
    }
    
    public func person(forID id: String) -> RegnalPerson? {
        persons[id]
    }

    public func magistracyGap(
        auc: Int,
        dataset: ConsularTenure.Dataset = .republican
    ) -> RomanMagistracyGap? {
        magistracyGaps.first { $0.auc == auc && $0.dataset == dataset }
    }

    /// Derives the eponymous pair and within-year suffects from canonical tenures.
    public func consularYear(
        auc: Int,
        dataset: ConsularTenure.Dataset = .republican
    ) -> RomanConsulYear? {
        let yearTenures = tenures.filter { tenure in
            tenure.consular?.dataset == dataset
                && tenure.start.first?.calendar == "AUC"
                && tenure.start.first?.ymd?.year == auc
        }
        guard yearTenures.contains(where: { $0.consular?.role == .ordinaryConsul }) else {
            return nil
        }

        func names(for role: ConsularTenure.Role) -> [RomanConsulYear.ConsulName] {
            yearTenures
                .filter {
                    $0.consular?.role == role
                        && $0.consular?.alternativeToTenureID == nil
                }
                .sorted { ($0.consular?.seat ?? Int.max) < ($1.consular?.seat ?? Int.max) }
                .map { tenure in
                    RomanConsulYear.ConsulName(
                        personID: tenure.personID,
                        name: persons[tenure.personID]?.name.normalized ?? tenure.personID,
                        seat: tenure.consular?.seat,
                        consulshipNumber: tenure.consular?.consulshipNumber
                    )
                }
        }

        let notes = yearTenures.compactMap(\.notes).filter { !$0.isEmpty }
        return RomanConsulYear(
            auc: auc,
            startJDN: RomanCalendar.shared.startOfYearJDN(year: auc),
            endJDN: RomanCalendar.shared.endOfYearJDN(year: auc),
            consuls: names(for: .ordinaryConsul),
            suffects: names(for: .suffectConsul),
            notes: notes.isEmpty ? nil : notes.joined(separator: " ")
        )
    }
}

extension String {
    func normalizedRegnalName() -> String {
        var s = self.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ".", with: "").lowercased()
        
        // Manual common abbreviations
        if s.starts(with: "hen ") { s = s.replacingOccurrences(of: "hen ", with: "henry ") }
        if s.starts(with: "geo ") { s = s.replacingOccurrences(of: "geo ", with: "george ") }
        if s.starts(with: "wdr ") { s = s.replacingOccurrences(of: "wdr ", with: "william ") } // less common, maybe Edw?
        if s.starts(with: "edw ") { s = s.replacingOccurrences(of: "edw ", with: "edward ") }
        if s.starts(with: "eliz ") { s = s.replacingOccurrences(of: "eliz ", with: "elizabeth ") }
        if s.starts(with: "chas ") { s = s.replacingOccurrences(of: "chas ", with: "charles ") }
        if s.starts(with: "jam ") { s = s.replacingOccurrences(of: "jam ", with: "james ") }
        if s.starts(with: "ric ") { s = s.replacingOccurrences(of: "ric ", with: "richard ") }
        
        // Arabic to Roman numerals (1-20 usually sufficient for monarchs)
        // regex replacement might be safer to ensure it IS a number at end?
        // Patterns like "henry 8" -> "henry viii"
        // We look for digits at the end of the string
        if let range = s.range(of: "\\d+$", options: .regularExpression) {
             let numStr = String(s[range])
             if let n = Int(numStr) {
                 let roman = toRoman(n)
                 s = s.replacingOccurrences(of: numStr, with: roman, options: .backwards, range: range)
             }
        }
        
        return s
    }
    
    private func toRoman(_ n: Int) -> String {
        let romanValues = [
            (1000, "m"), (900, "cm"), (500, "d"), (400, "cd"),
            (100, "c"), (90, "xc"), (50, "l"), (40, "xl"),
            (10, "x"), (9, "ix"), (5, "v"), (4, "iv"), (1, "i")
        ]
        var num = n
        var result = ""
        for (value, letter) in romanValues {
            while num >= value {
                result += letter
                num -= value
            }
        }
        return result
    }
}
