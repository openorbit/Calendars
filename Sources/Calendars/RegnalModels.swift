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
    public let notes: String?
    public let consular: ConsularTenure?
    
    enum CodingKeys: String, CodingKey {
        case id, ordinal, start, end, certainty, status, notes, consular
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

/// Metadata attached to a neutral office tenure when that tenure participates in
/// Roman consular dating. The office remains the canonical fact; eponymous years
/// are derived from tenures whose role is `ordinaryConsul`.
public struct ConsularTenure: Codable, Sendable, Equatable {
    public let dataset: Dataset
    public let role: Role
    public let seat: Int?
    public let consulshipNumber: Int?
    public let alternativeToTenureID: String?
    public let tradition: Tradition
    public let sources: [RegnalSource]

    enum CodingKeys: String, CodingKey {
        case dataset, role, seat, tradition, sources
        case consulshipNumber = "consulship_number"
        case alternativeToTenureID = "alternative_to_tenure_id"
    }

    public enum Dataset: String, Codable, Sendable {
        case republican
        case imperial
    }

    public enum Role: String, Codable, Sendable {
        case ordinaryConsul = "ordinary_consul"
        case suffectConsul = "suffect_consul"
        case consularTribune = "consular_tribune"
        case decemvir
        case dictator
        case postConsulatum = "post_consulatum"
    }

    public enum Tradition: String, Codable, Sendable {
        case attested
        case traditional
        case disputed
        case reconstructed
        case alternative
        case fabricatedVarronian = "fabricated_varronian"
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

/// A sourced assertion that the annual magistracy sequence contains no office
/// tenure. This remains separate from RegnalTenure so absence is never
/// represented by a fictitious office or person.
public struct RomanMagistracyGap: Codable, Identifiable, Sendable, Equatable {
    public let id: String
    public let dataset: ConsularTenure.Dataset
    public let polityID: String
    public let auc: Int
    public let kind: Kind
    public let tradition: ConsularTenure.Tradition
    public let certainty: String
    public let notes: String?
    public let sources: [RegnalSource]

    enum CodingKeys: String, CodingKey {
        case id, dataset, auc, kind, tradition, certainty, notes, sources
        case polityID = "polity_id"
    }

    public enum Kind: String, Codable, Sendable {
        case noCuruleMagistrates = "no_curule_magistrates"
    }
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

/// A derived eponymous year. This is intentionally not a second canonical data
/// format: its officeholders come from ordinary-consul tenures.
public struct RomanConsulYear: Identifiable, Sendable {
    public let auc: Int
    public let startJDN: Int?
    public let endJDN: Int?
    public let consuls: [ConsulName]
    public let suffects: [ConsulName]
    public let notes: String?

    public var id: Int { auc }
    public var bc: Int { 754 - auc }
    public var consulList: [ConsulName] { consuls }
    public var suffectList: [ConsulName] { suffects }
    public var noteText: String { notes ?? "" }

    public struct ConsulName: Sendable {
        public let personID: String
        public let name: String
        public let seat: Int?
        public let consulshipNumber: Int?
    }
}
