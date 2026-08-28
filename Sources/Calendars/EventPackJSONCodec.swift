import Foundation

public struct EventPackValidationIssue: Equatable, Sendable {
    public var path: String
    public var message: String

    public init(path: String, message: String) {
        self.path = path
        self.message = message
    }
}

public struct EventPackValidationError: Error, Equatable, Sendable, LocalizedError {
    public var issues: [EventPackValidationIssue]

    public init(issues: [EventPackValidationIssue]) {
        self.issues = issues
    }

    public var errorDescription: String? {
        issues.map { "\($0.path): \($0.message)" }.joined(separator: "\n")
    }
}

public enum EventPackValidator {
    public static func issues(in pack: EventPack) -> [EventPackValidationIssue] {
        var issues: [EventPackValidationIssue] = []

        if pack.formatVersion != EventPack.currentFormatVersion {
            issues.append(.init(path: "format_version", message: "Unsupported format version \(pack.formatVersion)."))
        }
        requireText(pack.id, at: "id", into: &issues)
        requireText(pack.version, at: "version", into: &issues)
        requireText(pack.title, at: "title", into: &issues)
        requireText(pack.summary, at: "summary", into: &issues)
        validateUniqueIDs(pack.categories.map(\.id), path: "categories", into: &issues)
        validateUniqueIDs(pack.events.map(\.id), path: "events", into: &issues)

        let categoryIDs = Set(pack.categories.map(\.id))
        for (index, category) in pack.categories.enumerated() {
            requireText(category.id, at: "categories[\(index)].id", into: &issues)
            requireText(category.name, at: "categories[\(index)].name", into: &issues)
            if let icon = category.icon {
                requireText(icon, at: "categories[\(index)].icon", into: &issues)
            }
        }

        for (index, event) in pack.events.enumerated() {
            let path = "events[\(index)]"
            requireText(event.id, at: "\(path).id", into: &issues)
            requireText(event.title, at: "\(path).title", into: &issues)
            validate(event.time.start, path: "\(path).time.start", into: &issues)
            if let end = event.time.end {
                validate(end, path: "\(path).time.end", into: &issues)
            }
            for categoryID in event.categoryIDs where !categoryIDs.contains(categoryID) {
                issues.append(.init(path: "\(path).category_ids", message: "Unknown category ID '\(categoryID)'."))
            }
            for (placeIndex, place) in event.places.enumerated() {
                requireText(place.name, at: "\(path).places[\(placeIndex)].name", into: &issues)
                if let latitude = place.latitude, !(-90...90).contains(latitude) {
                    issues.append(.init(path: "\(path).places[\(placeIndex)].latitude", message: "Latitude must be between -90 and 90."))
                }
                if let longitude = place.longitude, !(-180...180).contains(longitude) {
                    issues.append(.init(path: "\(path).places[\(placeIndex)].longitude", message: "Longitude must be between -180 and 180."))
                }
            }
            for (linkIndex, link) in event.links.enumerated() {
                requireText(link.title, at: "\(path).links[\(linkIndex)].title", into: &issues)
                let scheme = link.url.scheme?.lowercased()
                if scheme != "http" && scheme != "https" {
                    issues.append(.init(path: "\(path).links[\(linkIndex)].url", message: "Only HTTP and HTTPS links are supported."))
                }
            }
            for (sourceIndex, source) in event.sources.enumerated() {
                requireText(source.id, at: "\(path).sources[\(sourceIndex)].id", into: &issues)
                requireText(source.title, at: "\(path).sources[\(sourceIndex)].title", into: &issues)
            }
            for (referenceIndex, reference) in event.references.enumerated() {
                requireText(reference.eventID, at: "\(path).references[\(referenceIndex)].event_id", into: &issues)
            }
        }
        return issues
    }

    public static func validate(_ pack: EventPack) throws {
        let issues = issues(in: pack)
        if !issues.isEmpty {
            throw EventPackValidationError(issues: issues)
        }
    }

    private static func validate(
        _ date: HistoricalDate,
        path: String,
        into issues: inout [EventPackValidationIssue]
    ) {
        requireText(date.calendarID, at: "\(path).calendar", into: &issues)
        if let month = date.month, month < 1 {
            issues.append(.init(path: "\(path).month", message: "Month must be positive."))
        }
        if let day = date.day, day < 1 {
            issues.append(.init(path: "\(path).day", message: "Day must be positive."))
        }
        if date.day != nil && date.month == nil {
            issues.append(.init(path: "\(path).day", message: "A day requires a month."))
        }
        switch date.precision {
        case .day:
            if date.month == nil || date.day == nil {
                issues.append(.init(path: "\(path).precision", message: "Day precision requires month and day."))
            }
        case .month:
            if date.month == nil || date.day != nil {
                issues.append(.init(path: "\(path).precision", message: "Month precision requires a month and no day."))
            }
        case .year, .decade, .century:
            if date.month != nil || date.day != nil {
                issues.append(.init(path: "\(path).precision", message: "\(date.precision.rawValue.capitalized) precision cannot include month or day."))
            }
        }
        if let uncertaintyDays = date.uncertaintyDays, uncertaintyDays < 0 {
            issues.append(.init(path: "\(path).uncertainty_days", message: "Uncertainty cannot be negative."))
        }
    }

    private static func requireText(
        _ value: String,
        at path: String,
        into issues: inout [EventPackValidationIssue]
    ) {
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(.init(path: path, message: "Value must not be empty."))
        }
    }

    private static func validateUniqueIDs(
        _ ids: [String],
        path: String,
        into issues: inout [EventPackValidationIssue]
    ) {
        var seen = Set<String>()
        for (index, id) in ids.enumerated() where !seen.insert(id).inserted {
            issues.append(.init(path: "\(path)[\(index)].id", message: "Duplicate ID '\(id)'."))
        }
    }
}

public enum EventPackJSONCodec {
    public static func decode(_ data: Data, validate: Bool = true) throws -> EventPack {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let pack = try decoder.decode(EventPack.self, from: data)
        if validate {
            try EventPackValidator.validate(pack)
        }
        return pack
    }

    public static func encode(_ pack: EventPack, validate: Bool = true) throws -> Data {
        if validate {
            try EventPackValidator.validate(pack)
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(pack)
    }
}
