import Foundation

public final class RegnalCalendar: @unchecked Sendable {
    public static let shared = RegnalCalendar()
    
    public let tenures: [RegnalTenure]
    public let persons: [String: RegnalPerson]
    
    private init() {
        // Load data into local vars first
        var t: [RegnalTenure] = []
        var p: [String: RegnalPerson] = [:]
        
        if let resourceURL = Bundle.module.url(forResource: "RegnalData", withExtension: nil) {
            let fileManager = FileManager.default
            if let enumerator = fileManager.enumerator(at: resourceURL, includingPropertiesForKeys: nil) {
                for case let fileURL as URL in enumerator {
                    if fileURL.pathExtension == "json" {
                        if fileURL.lastPathComponent.contains("tenures") {
                            if let data = try? Data(contentsOf: fileURL),
                               let items = try? JSONDecoder().decode([RegnalTenure].self, from: data) {
                                t.append(contentsOf: items)
                            }
                        } else if fileURL.lastPathComponent.contains("persons") {
                            if let data = try? Data(contentsOf: fileURL),
                               let items = try? JSONDecoder().decode([RegnalPerson].self, from: data) {
                                for person in items {
                                    p[person.id] = person
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
    }
    
    // MARK: - Date Calculation
    
    public struct RegnalDate {
        public let year: Int // e.g., 5th year
        public let monarchName: String
    }
    
    /// Returns the (start, end) JulianDate for the Nth year of the given monarch tenure.
    /// Regnal years usually start on the accession date.
    public func julianDateRange(forRegnalYear year: Int, tenure: RegnalTenure) -> (JulianDate, JulianDate)? {
        guard let startDef = tenure.start.first?.ymd else { return nil }
        
        let startYear = startDef.year
        let startMonth = startDef.month
        let startDay = startDef.day
        
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
        let personIDs = persons.filter { $0.value.name.normalized.localizedCaseInsensitiveContains(name) || $0.value.variants.contains { $0.form.localizedCaseInsensitiveContains(name) } }.map { $0.key }
        
        return tenures.filter { personIDs.contains($0.personID) }
    }
}
