import Foundation
@preconcurrency import GRDB
import SwiftUI

// MARK: - Color Helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

/// A project is a collection of notes
/// Sendable for Swift 6 concurrency safety
struct Project: Identifiable, Codable, Hashable, Sendable {
    // MARK: - Properties
    
    let id: String
    var name: String
    var description: String?
    var type: ProjectType
    var color: String?
    var icon: String?
    var settings: ProjectSettings?
    var createdAt: Int64
    var updatedAt: Int64
    
    // MARK: - Initialization
    
    init(
        id: String = UUID().uuidString.lowercased(),
        name: String,
        description: String? = nil,
        type: ProjectType = .generic,
        color: String? = nil,
        icon: String? = nil,
        settings: ProjectSettings? = nil,
        createdAt: Int64 = Date().unixTimestamp,
        updatedAt: Int64 = Date().unixTimestamp
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.color = color
        self.icon = icon
        self.settings = settings
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    var date: Date {
        Date(unixTimestamp: createdAt)
    }
    
    var modifiedDate: Date {
        Date(unixTimestamp: updatedAt)
    }
}

// MARK: - Project Type

enum ProjectType: String, Codable, CaseIterable, Sendable {
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
    
    var emoji: String {
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
    
    var defaultColor: String {
        switch self {
        case .research: return "#3b82f6"  // Blue
        case .teaching: return "#10b981"  // Green
        case .rPackage: return "#f59e0b"  // Amber
        case .rDev: return "#6b7280"      // Gray
        case .generic: return "#8b5cf6"   // Purple
        }
    }
    
    var swiftuiColor: Color {
        Color(hex: defaultColor)
    }
}

// MARK: - Project Settings

struct ProjectSettings: Codable, Hashable, Sendable {
    var bibliography: String?
    var citationStyle: String?
    var exportTemplate: String?
    var aiContext: String?
    var defaultFolder: String?
    
    init(
        bibliography: String? = nil,
        citationStyle: String? = "apa",
        exportTemplate: String? = nil,
        aiContext: String? = nil,
        defaultFolder: String? = "inbox"
    ) {
        self.bibliography = bibliography
        self.citationStyle = citationStyle
        self.exportTemplate = exportTemplate
        self.aiContext = aiContext
        self.defaultFolder = defaultFolder
    }
}

// MARK: - GRDB Conformance

extension Project: FetchableRecord, PersistableRecord {
    static let databaseTableName = "projects"
    
    enum Columns {
        static let id = Column("id")
        static let name = Column("name")
        static let description = Column("description")
        static let type = Column("type")
        static let color = Column("color")
        static let icon = Column("icon")
        static let settings = Column("settings")
        static let createdAt = Column("created_at")
        static let updatedAt = Column("updated_at")
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, type, color, icon, settings
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Custom Encoding/Decoding for JSON settings

extension Project {
    private static let jsonEncoder = JSONEncoder()
    private static let jsonDecoder = JSONDecoder()
    
    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["name"] = name
        container["description"] = description
        container["type"] = type.rawValue
        container["color"] = color
        container["icon"] = icon
        container["created_at"] = createdAt
        container["updated_at"] = updatedAt
        
        if let settings {
            let data = try Self.jsonEncoder.encode(settings)
            container["settings"] = String(data: data, encoding: .utf8)
        }
    }
    
    init(row: Row) throws {
        self.id = row["id"]
        self.name = row["name"]
        self.description = row["description"]
        self.type = ProjectType(rawValue: row["type"]) ?? .generic
        self.color = row["color"]
        self.icon = row["icon"]
        self.createdAt = row["created_at"]
        self.updatedAt = row["updated_at"]
        
        if let settingsString: String = row["settings"],
           let data = settingsString.data(using: .utf8) {
            self.settings = try? Self.jsonDecoder.decode(ProjectSettings.self, from: data)
        } else {
            self.settings = nil
        }
    }
}

// MARK: - Associations

extension Project {
    static let notes = hasMany(Note.self)
    
    var notes: QueryInterfaceRequest<Note> {
        request(for: Project.notes)
    }
}
