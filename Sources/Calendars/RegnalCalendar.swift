import Foundation

public final class RegnalCalendar: @unchecked Sendable {
    public static let shared = RegnalCalendar()
    
    public let tenures: [RegnalTenure]
    public let persons: [String: RegnalPerson]
    public let offices: [String: RegnalOffice]
    public let polities: [String: RegnalPolity]
    public let consulYears: [RomanConsulYear]
    
    private init() {
        // Load data into local vars first
        var t: [RegnalTenure] = []
        var p: [String: RegnalPerson] = [:]
        var o: [String: RegnalOffice] = [:]
        var pol: [String: RegnalPolity] = [:]
        var c: [RomanConsulYear] = []
        
        if let resourceURL = Bundle.module.url(forResource: "RegnalData", withExtension: nil) {
            let fileManager = FileManager.default
            if let enumerator = fileManager.enumerator(at: resourceURL, includingPropertiesForKeys: nil) {
                for case let fileURL as URL in enumerator {
                    if fileURL.pathExtension == "json" {
                        let filename = fileURL.lastPathComponent
                        if filename.contains("tenures") {
                            if let data = try? Data(contentsOf: fileURL),
                               let items = try? JSONDecoder().decode([RegnalTenure].self, from: data) {
                                t.append(contentsOf: items)
                            }
                        } else if filename.contains("persons") {
                            if let data = try? Data(contentsOf: fileURL),
                               let items = try? JSONDecoder().decode([RegnalPerson].self, from: data) {
                                for person in items {
                                    p[person.id] = person
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
                        } else if filename.contains("consuls") {
                             // "consuls" files have a root object with "years": [...]
                             // But checking the file viewing output in Step 1915, it starts with structure?
                             // Wait, cat output didn't show root key clearly.
                             // Let's check Step 1915 output carefully.
                             // It shows `[ ... ]` at the START? No, I saw `<truncated 327 lines>`.
                             // I should assume it might be wrapped.
                             // Wait, Step 1893 showed file `consuls_auc_445_544_prelude.json`.
                             // Step 1915 output snippet shows indentation suggesting array elements.
                             // Let's assume it IS a wrapper based on JSON standards in this repo.
                             // Or decode as Direct Array?
                             // If I try `RomanConsulsFile` (wrapped) and fail, try `[RomanConsulYear]`.
                             if let data = try? Data(contentsOf: fileURL) {
                                 if let wrapper = try? JSONDecoder().decode(RomanConsulsFile.self, from: data) {
                                     c.append(contentsOf: wrapper.years)
                                 } else if let items = try? JSONDecoder().decode([RomanConsulYear].self, from: data) {
                                     // Direct array
                                     c.append(contentsOf: items)
                                 }
                             }
                        }
                    }
                }
            }
        } else {
            print("RegnalData folder not found in Bundle.")
        }
        
        self.tenures = t
        self.persons = p
        self.offices = o
        self.polities = pol
        self.consulYears = c
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
            // Convert to Julian
            // Simplistic approximation for republic prior to 45 BCE: 1 AUC = 753 BCE
            // This is sufficient for simple "year of consul" display validation.
            // A more robust app would use the RomanCalendar for years > 491.
            startYear = rawYear - 753
            // Months/Days in pre-Julian Roman calendar might strictly differ,
            // but we often treat them as 1:1 if we lack better data.
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
            // Sort by start year
            let startA = $0.start.first?.ymd?.year ?? Int.min
            let startB = $1.start.first?.ymd?.year ?? Int.min
            return startA < startB
        }
    }
    
    public func person(forID id: String) -> RegnalPerson? {
        persons[id]
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
