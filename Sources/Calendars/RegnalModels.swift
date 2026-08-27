import Foundation

// MARK: - Regnal Data Models

public struct RegnalPerson: Codable, Identifiable {
    public let id: String
    public let name: NormalizedName
    public let variants: [NameVariant]
    
    public struct NormalizedName: Codable {
        public let normalized: String
    }
    
    public struct NameVariant: Codable {
        public let form: String
        public let lang: String?
        public let script: String?
        public let kind: String?
        public let casus: String?
        public let confidence: Double?
    }
}

public struct RegnalTenure: Codable, Identifiable {
    public let id: String
    public let officeID: String
    public let personID: String
    public let ordinal: Int?
    public let start: [DateDefinition]
    public let end: [DateDefinition]
    public let certainty: String
    public let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, ordinal, start, end, certainty, status
        case officeID = "office_id"
        case personID = "person_id"
    }
    
    public struct DateDefinition: Codable {
        // TODO: Represent bounded month/day ranges directly (for example, February–May 824)
        // instead of reducing them to an approximate point.
        // TODO: Preserve correlations between alternative starts and ends so consumers cannot
        // combine mutually incompatible chronology branches.
        public let rep: String // "ymd" or "open"
        public let calendar: String
        public let ymd: YMD?

        enum CodingKeys: String, CodingKey {
            case rep, calendar, ymd
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            rep = try container.decode(String.self, forKey: .rep)
            calendar = try container.decodeIfPresent(String.self, forKey: .calendar) ?? ""
            ymd = try container.decodeIfPresent(YMD.self, forKey: .ymd)
        }
    }
    
    public struct YMD: Codable {
        public let year: Int
        public let month: Int?
        public let day: Int?
    }
}

public struct RegnalOffice: Codable, Identifiable, Sendable {
    public let id: String
    public let label: String
    public let polityID: String

    enum CodingKeys: String, CodingKey {
        case id, label
        case polityID = "polity_id"
        case scopePolityID = "scope_polity_id"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)

        if let polityID = try container.decodeIfPresent(String.self, forKey: .polityID) {
            self.polityID = polityID
        } else {
            polityID = try container.decode(String.self, forKey: .scopePolityID)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(polityID, forKey: .polityID)
    }
}

public struct RegnalSource: Codable, Sendable, Equatable {
    public let title: String
    public let url: String
    public let note: String?
}

public struct RegnalPolity: Codable, Identifiable, Sendable {
    public let id: String
    public let label: String
    public let region: String
    public let notes: String?
    public let sources: [RegnalSource]

    enum CodingKeys: String, CodingKey {
        case id, label, region, notes, sources
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        region = try container.decodeIfPresent(String.self, forKey: .region) ?? ""
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        sources = try container.decodeIfPresent([RegnalSource].self, forKey: .sources) ?? []
    }
}

public struct RomanConsulYear: Codable, Identifiable, Sendable {
    public let auc: Int
    public let bc: Int
    public let consuls: [ConsulName]?
    public let suffects: [ConsulName]?
    public let notes: String?
    
    // Derived ID
    public var id: Int { auc }
    
    public var consulList: [ConsulName] { consuls ?? [] }
    public var suffectList: [ConsulName] { suffects ?? [] }
    public var noteText: String { notes ?? "" }
    
    public struct ConsulName: Codable, Sendable {
        public let name: String
    }
}

// Wrapper for the file structure
struct RomanConsulsFile: Codable {
    let years: [RomanConsulYear]
}
