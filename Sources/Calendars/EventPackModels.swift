import Foundation

/// A portable, versioned collection of historical events.
public struct EventPack: Codable, Equatable, Sendable {
    public static let currentFormatVersion = 1

    public var formatVersion: Int
    public var id: String
    public var version: String
    public var title: String
    public var summary: String
    public var description: String?
    public var author: String?
    public var license: String?
    public var language: String?
    public var homepage: URL?
    public var created: Date?
    public var modified: Date?
    public var categories: [EventCategory]
    public var events: [HistoricalEvent]

    public init(
        formatVersion: Int = EventPack.currentFormatVersion,
        id: String,
        version: String,
        title: String,
        summary: String,
        description: String? = nil,
        author: String? = nil,
        license: String? = nil,
        language: String? = nil,
        homepage: URL? = nil,
        created: Date? = nil,
        modified: Date? = nil,
        categories: [EventCategory] = [],
        events: [HistoricalEvent] = []
    ) {
        self.formatVersion = formatVersion
        self.id = id
        self.version = version
        self.title = title
        self.summary = summary
        self.description = description
        self.author = author
        self.license = license
        self.language = language
        self.homepage = homepage
        self.created = created
        self.modified = modified
        self.categories = categories
        self.events = events
    }

    enum CodingKeys: String, CodingKey {
        case id, version, title, summary, description, author, license, language
        case homepage, created, modified, categories, events
        case formatVersion = "format_version"
    }
}

/// A pack-local category. The icon is a portable semantic identifier such as
/// "battle", "birth", or "treaty"; applications map it to their native icon set.
public struct EventCategory: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var name: String
    public var icon: String?
    public var color: String?

    public init(id: String, name: String, icon: String? = nil, color: String? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
    }
}

public struct HistoricalEvent: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var title: String
    public var summary: String?
    public var description: String?
    public var time: HistoricalEventTime
    public var categoryIDs: [String]
    public var tags: [String]
    public var people: [String]
    public var places: [EventPlace]
    public var links: [EventLink]
    public var comments: String?
    public var sources: [EventSource]
    public var references: [EventReference]

    public init(
        id: String,
        title: String,
        summary: String? = nil,
        description: String? = nil,
        time: HistoricalEventTime,
        categoryIDs: [String] = [],
        tags: [String] = [],
        people: [String] = [],
        places: [EventPlace] = [],
        links: [EventLink] = [],
        comments: String? = nil,
        sources: [EventSource] = [],
        references: [EventReference] = []
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.description = description
        self.time = time
        self.categoryIDs = categoryIDs
        self.tags = tags
        self.people = people
        self.places = places
        self.links = links
        self.comments = comments
        self.sources = sources
        self.references = references
    }

    enum CodingKeys: String, CodingKey {
        case id, title, summary, description, time, tags, people, places, links
        case comments, sources, references
        case categoryIDs = "category_ids"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        time = try container.decode(HistoricalEventTime.self, forKey: .time)
        categoryIDs = try container.decodeIfPresent([String].self, forKey: .categoryIDs) ?? []
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        people = try container.decodeIfPresent([String].self, forKey: .people) ?? []
        places = try container.decodeIfPresent([EventPlace].self, forKey: .places) ?? []
        links = try container.decodeIfPresent([EventLink].self, forKey: .links) ?? []
        comments = try container.decodeIfPresent(String.self, forKey: .comments)
        sources = try container.decodeIfPresent([EventSource].self, forKey: .sources) ?? []
        references = try container.decodeIfPresent([EventReference].self, forKey: .references) ?? []
    }
}

/// A point event has only start; a duration also has end. Each endpoint may use
/// a different calendar or level of precision.
public struct HistoricalEventTime: Codable, Equatable, Sendable {
    public var start: HistoricalDate
    public var end: HistoricalDate?

    public init(start: HistoricalDate, end: HistoricalDate? = nil) {
        self.start = start
        self.end = end
    }
}

/// An asserted historical date in its source calendar. Uncertainty describes
/// fuzziness around the assertion and remains separate from event duration.
public struct HistoricalDate: Codable, Equatable, Sendable {
    public enum Precision: String, Codable, Sendable {
        case day, month, year, decade, century
    }

    public enum Qualifier: String, Codable, Sendable {
        case exact, circa, before, after
    }

    public enum Certainty: String, Codable, Sendable {
        case certain, probable, possible, disputed, unknown
    }

    public var calendarID: String
    public var year: Int
    public var month: Int?
    public var day: Int?
    public var precision: Precision
    public var qualifier: Qualifier
    public var certainty: Certainty
    public var uncertaintyDays: Int?
    public var originalText: String?
    public var note: String?

    public init(
        calendarID: String,
        year: Int,
        month: Int? = nil,
        day: Int? = nil,
        precision: Precision,
        qualifier: Qualifier = .exact,
        certainty: Certainty = .certain,
        uncertaintyDays: Int? = nil,
        originalText: String? = nil,
        note: String? = nil
    ) {
        self.calendarID = calendarID
        self.year = year
        self.month = month
        self.day = day
        self.precision = precision
        self.qualifier = qualifier
        self.certainty = certainty
        self.uncertaintyDays = uncertaintyDays
        self.originalText = originalText
        self.note = note
    }

    enum CodingKeys: String, CodingKey {
        case year, month, day, precision, qualifier, certainty, note
        case calendarID = "calendar"
        case uncertaintyDays = "uncertainty_days"
        case originalText = "original_text"
    }
}

public struct EventPlace: Codable, Equatable, Sendable, Identifiable {
    public var id: String?
    public var name: String
    public var latitude: Double?
    public var longitude: Double?

    public init(id: String? = nil, name: String, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct EventLink: Codable, Equatable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case wikipedia, wikidata, source, other
    }

    public var kind: Kind
    public var title: String
    public var url: URL

    public init(kind: Kind, title: String, url: URL) {
        self.kind = kind
        self.title = title
        self.url = url
    }
}

public struct EventSource: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var title: String
    public var citation: String?
    public var url: URL?
    public var note: String?

    public init(
        id: String,
        title: String,
        citation: String? = nil,
        url: URL? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.title = title
        self.citation = citation
        self.url = url
        self.note = note
    }
}

/// A stable, optionally cross-pack relationship. A nil pack ID means the
/// referenced event is in the same pack.
public struct EventReference: Codable, Equatable, Sendable, Identifiable {
    public enum Relationship: String, Codable, Sendable, CaseIterable {
        case related
        case causes
        case causedBy = "caused_by"
        case partOf = "part_of"
        case follows
        case precedes
    }

    public var packID: String?
    public var eventID: String
    public var relationship: Relationship
    public var note: String?

    public init(
        packID: String? = nil,
        eventID: String,
        relationship: Relationship = .related,
        note: String? = nil
    ) {
        self.packID = packID
        self.eventID = eventID
        self.relationship = relationship
        self.note = note
    }

    public var id: String {
        "\(packID ?? "."):\(eventID):\(relationship.rawValue)"
    }

    enum CodingKeys: String, CodingKey {
        case relationship, note
        case packID = "pack_id"
        case eventID = "event_id"
    }
}
