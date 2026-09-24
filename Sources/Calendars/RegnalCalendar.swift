import Foundation

public final class RegnalCalendar: @unchecked Sendable {
    public static let shared = RegnalCalendar()
    
    public let tenures: [RegnalTenure]
    public let persons: [String: RegnalPerson]
    public let offices: [String: RegnalOffice]
    public let polities: [String: RegnalPolity]
    public let calendarRulesByPolity: [String: [RegnalCalendarRule]]
    public let magistracyGaps: [RomanMagistracyGap]
    public let consulYears: [RomanConsulYear]
    private let consulYearsByAUC: [Int: RomanConsulYear]
    private let consulSearchIndex: [Int: String]
    
    private init() {
        // Load data into local vars first
        var t: [String: RegnalTenure] = [:]
        var p: [String: RegnalPerson] = [:]
        var o: [String: RegnalOffice] = [:]
        var pol: [String: RegnalPolity] = [:]
        var polityIDsByDirectory: [URL: [String]] = [:]
        var calendarRulesByDirectory: [URL: [RegnalCalendarRule]] = [:]
        var gaps: [String: RomanMagistracyGap] = [:]
        
        if let resourceURL = Bundle.module.url(forResource: "RegnalData", withExtension: nil) {
            let fileManager = FileManager.default
            if let enumerator = fileManager.enumerator(at: resourceURL, includingPropertiesForKeys: nil) {
                for case let fileURL as URL in enumerator {
                    if fileURL.pathExtension == "json" {
                        let filename = fileURL.lastPathComponent
                        let directory = fileURL.deletingLastPathComponent().standardizedFileURL
                        if filename.contains("calendar_rules") {
                            if let data = try? Data(contentsOf: fileURL),
                               let items = try? JSONDecoder().decode([RegnalCalendarRule].self, from: data) {
                                calendarRulesByDirectory[directory, default: []].append(contentsOf: items)
                            }
                        } else if filename.contains("magistracy_gaps") {
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
                                     polityIDsByDirectory[directory, default: []].append(polity.id)
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
        let loadedTenures = t.values.filter { tenure in
            guard tenure.start.first?.calendar == "AUC",
                  let auc = tenure.start.first?.ymd?.year,
                  assertedRomanGapYears.contains(auc),
                  o[tenure.officeID]?.polityID == "POLITY_ROMAN_REPUBLIC" else {
                return true
            }
            return false
        }
        let loadedConsulYears = Self.makeConsulYears(tenures: loadedTenures, persons: p)
        var rulesByPolity: [String: [RegnalCalendarRule]] = [:]
        for (directory, polityIDs) in polityIDsByDirectory {
            let rules = calendarRulesByDirectory[directory] ?? []
            for polityID in polityIDs {
                rulesByPolity[polityID] = rules
            }
        }
        self.tenures = loadedTenures
        self.persons = p
        self.offices = o
        self.polities = pol
        self.calendarRulesByPolity = rulesByPolity
        self.magistracyGaps = Array(gaps.values)
        self.consulYears = loadedConsulYears
        self.consulYearsByAUC = Dictionary(uniqueKeysWithValues: loadedConsulYears.map { ($0.auc, $0) })
        self.consulSearchIndex = Dictionary(uniqueKeysWithValues: loadedConsulYears.map { year in
            let names = (year.consuls + year.suffects).flatMap { consul -> [String] in
                let variants = p[consul.personID]?.variants.map(\.form) ?? []
                return [consul.name] + variants
            }
            return (year.auc, Self.canonicalSearchText(names.joined(separator: " ")))
        })
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
    

    public struct MonarchSelection {
        public let primary: RegnalTenure?
        public let candidates: [RegnalTenure]

        public var isAmbiguous: Bool { candidates.count > 1 }
    }

    public struct RegnalYearSpan {
        public let tenure: RegnalTenure
        public let regnalYear: Int
        public let startJDN: Int
        public let endJDN: Int
    }

    public func monarchSelection(forPolity polityID: String, onJDN jdn: Int) -> MonarchSelection {
        let officeIDs = Set(offices.values.filter {
            $0.polityID == polityID && ($0.successionMode == "monarchic" || $0.label.lowercased().contains("king"))
        }.map(\.id))
        let matching = tenures.filter {
            officeIDs.contains($0.officeID) && Self.possiblyContains($0, jdn: jdn)
        }.sorted { lhs, rhs in
            if lhs.status != rhs.status { return lhs.status == "recognized" }
            return lhs.id < rhs.id
        }
        var active: [RegnalTenure] = []
        for tenure in matching {
            if let index = active.firstIndex(where: { Self.sameMonarchAssertion($0, tenure, persons: persons) }) {
                let existingName = persons[active[index].personID]?.name.normalized ?? ""
                let candidateName = persons[tenure.personID]?.name.normalized ?? ""
                if candidateName.count > existingName.count { active[index] = tenure }
            } else {
                active.append(tenure)
            }
        }
        let recognized = active.filter { $0.status == "recognized" }
        let primary = recognized.count == 1 ? recognized[0] : (active.count == 1 ? active[0] : nil)
        return MonarchSelection(primary: primary, candidates: active)
    }

    /// Returns a numbered regnal year only when the accession anniversary is exact
    /// and the tenure has either an exact end or is explicitly open. Year-only data
    /// is never coerced to January 1.
    public func exactRegnalYear(containing jdn: Int, tenure: RegnalTenure) -> RegnalYearSpan? {
        guard let start = Self.exactJDN(tenure.start.first),
              let tenureEnd = Self.exactJDN(tenure.end.first) ?? Self.openEndJDN(tenure.end.first),
              start <= jdn, jdn <= tenureEnd,
              let definition = tenure.start.first,
              let ymd = definition.ymd,
              let month = ymd.month,
              let day = ymd.day,
              let calendar = CalendarRegistry.shared.calendar(for: definition.calendar),
              let current = calendar.date(fromJDN: jdn) else { return nil }

        var anniversaryYear = current.year
        var anniversary = calendar.jdn(forYear: anniversaryYear, month: month, day: day)
        if anniversary > jdn {
            anniversaryYear -= 1
            anniversary = calendar.jdn(forYear: anniversaryYear, month: month, day: day)
        }
        let number = anniversaryYear - ymd.year + 1
        guard number > 0 else { return nil }
        let next = calendar.jdn(forYear: anniversaryYear + 1, month: month, day: day)
        return RegnalYearSpan(
            tenure: tenure,
            regnalYear: number,
            startJDN: max(start, anniversary),
            endJDN: min(tenureEnd, next - 1)
        )
    }

    private static func exactJDN(_ definition: RegnalTenure.DateDefinition?) -> Int? {
        guard let definition,
              definition.rep == "ymd",
              let ymd = definition.ymd,
              let month = ymd.month,
              let day = ymd.day,
              let calendar = CalendarRegistry.shared.calendar(for: definition.calendar),
              calendar.isValidDate(year: ymd.year, month: month, day: day) else { return nil }
        return calendar.jdn(forYear: ymd.year, month: month, day: day)
    }

    private static func openEndJDN(_ definition: RegnalTenure.DateDefinition?) -> Int? {
        definition?.rep == "open" ? Int.max : nil
    }

    private static func sameMonarchAssertion(
        _ lhs: RegnalTenure,
        _ rhs: RegnalTenure,
        persons: [String: RegnalPerson]
    ) -> Bool {
        guard lhs.status == rhs.status,
              lhs.start.first?.ymd?.year == rhs.start.first?.ymd?.year,
              lhs.end.first?.ymd?.year == rhs.end.first?.ymd?.year else { return false }
        let lhsName = persons[lhs.personID]?.name.normalized.lowercased() ?? ""
        let rhsName = persons[rhs.personID]?.name.normalized.lowercased() ?? ""
        return lhsName == rhsName || lhsName.contains(rhsName) || rhsName.contains(lhsName)
    }

    private static func possiblyContains(_ tenure: RegnalTenure, jdn: Int) -> Bool {
        guard let start = endpointJDN(tenure.start.first, isEnd: false) else { return false }
        let end = endpointJDN(tenure.end.first, isEnd: true)
            ?? openEndJDN(tenure.end.first)
        guard let end else { return false }
        return start <= jdn && jdn <= end
    }

    private static func endpointJDN(
        _ definition: RegnalTenure.DateDefinition?,
        isEnd: Bool
    ) -> Int? {
        guard let definition,
              definition.rep == "ymd",
              let ymd = definition.ymd,
              let calendar = CalendarRegistry.shared.calendar(for: definition.calendar) else {
            return nil
        }
        let month = ymd.month ?? (isEnd ? calendar.months(forYear: ymd.year, mode: .civil).last?.index ?? 12 : 1)
        let day = ymd.day ?? (isEnd ? calendar.daysInMonth(year: ymd.year, month: month) : 1)
        guard calendar.isValidDate(year: ymd.year, month: month, day: day) else { return nil }
        return calendar.jdn(forYear: ymd.year, month: month, day: day)
    }

    public func calendarRules(forPolity polityID: String) -> [RegnalCalendarRule] {
        calendarRulesByPolity[polityID] ?? []
    }

    public func calendarRule(forPolity polityID: String, onJDN jdn: Int) -> RegnalCalendarRule? {
        let matches = calendarRules(forPolity: polityID).filter { $0.contains(jdn: jdn) }
        guard let latestStart = matches.map({ $0.validFromJDN ?? Int.min }).max() else {
            return nil
        }
        let latest = matches.filter { ($0.validFromJDN ?? Int.min) == latestStart }
        let highestSpecificity = latest.map { $0.regions == ["*"] ? 0 : 1 }.max() ?? 0
        let mostSpecific = latest.filter { ($0.regions == ["*"] ? 0 : 1) == highestSpecificity }
        guard let first = mostSpecific.first,
              mostSpecific.allSatisfy({
                  $0.calendarID == first.calendarID
                      && $0.historicalYearStart == first.historicalYearStart
              }) else {
            return nil
        }
        return first
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

    /// Searches ordinary and suffect consul names, including recorded name variants.
    /// Search text is normalized once when the bundled regnal data is loaded.
    public func searchConsulYears(matching query: String) -> [RomanConsulYear] {
        let terms = Self.canonicalSearchText(query).split(separator: " ")
        guard !terms.isEmpty else { return consulYears }

        return consulYears.filter { year in
            guard let searchableText = consulSearchIndex[year.auc] else { return false }
            return terms.allSatisfy(searchableText.contains)
        }
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
        if dataset == .republican {
            return consulYearsByAUC[auc]
        }
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

    private static func makeConsulYears(
        tenures: [RegnalTenure],
        persons: [String: RegnalPerson]
    ) -> [RomanConsulYear] {
        let grouped = Dictionary(grouping: tenures.filter {
            $0.consular?.dataset == .republican
                && $0.start.first?.calendar == "AUC"
                && $0.start.first?.ymd?.year != nil
        }) { $0.start.first!.ymd!.year }

        return grouped.keys.sorted().compactMap { auc in
            guard let yearTenures = grouped[auc],
                  yearTenures.contains(where: { $0.consular?.role == .ordinaryConsul }) else {
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

    private static func canonicalSearchText(_ value: String) -> String {
        value.folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: Locale(identifier: "en_US_POSIX")
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
