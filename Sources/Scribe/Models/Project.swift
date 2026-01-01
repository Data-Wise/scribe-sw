import Foundation
import GRDB

/// A project is a collection of notes
/// Schema matches Tauri version for database compatibility
struct Project: Identifiable, Codable, Equatable {
    // MARK: - Properties
    
    var id: String
    var name: String
    var description: String?
    var type: ProjectType
    var color: String?
    var settings: String?  // JSON blob
    var createdAt: Int64
    var updatedAt: Int64
    
    // MARK: - Initialization
    
    init(
        id: String = UUID().uuidString.lowercased(),
        name: String,
        description: String? = nil,
        type: ProjectType = .generic,
        color: String? = nil,
        settings: String? = nil,
        createdAt: Int64 = Int64(Date().timeIntervalSince1970),
        updatedAt: Int64 = Int64(Date().timeIntervalSince1970)
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.color = color
        self.settings = settings
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(createdAt))
    }
    
    var modifiedDate: Date {
        Date(timeIntervalSince1970: TimeInterval(updatedAt))
    }
}

// MARK: - Project Type

enum ProjectType: String, Codable, CaseIterable {
    case research
    case teaching
    case rPackage = "r-package"
    case rDev = "r-dev"
    case generic
    
    var displayName: String {
        switch self {
        case .research: return "Research"
        case .teaching: return "Teaching"
        case .rPackage: return "R Package"
        case .rDev: return "R Dev"
        case .generic: return "Generic"
        }
    }
    
    var icon: String {
        switch self {
        case .research: return "🔬"
        case .teaching: return "📚"
        case .rPackage: return "📦"
        case .rDev: return "🛠️"
        case .generic: return "📁"
        }
    }
    
    var systemImage: String {
        switch self {
        case .research: return "flask"
        case .teaching: return "graduationcap"
        case .rPackage: return "shippingbox"
        case .rDev: return "hammer"
        case .generic: return "folder"
        }
    }
}

// MARK: - GRDB Conformance

extension Project: FetchableRecord, PersistableRecord {
    static let databaseTableName = "projects"
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, type, color, settings
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
