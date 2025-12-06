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
        public let rep: String // "ymd"
        public let calendar: String // "Julian"
        public let ymd: YMD?
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
    }
}

public struct RegnalPolity: Codable, Identifiable, Sendable {
    public let id: String
    public let label: String
    public let region: String
    public let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, label, region, notes
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
