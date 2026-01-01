import Foundation
import GRDB

/// A note is a single document within a project
/// Schema matches Tauri version for database compatibility
struct Note: Identifiable, Codable, Equatable {
    // MARK: - Properties
    
    var id: String
    var title: String
    var content: String
    var folder: String
    var projectId: String?
    var properties: String?  // JSON frontmatter
    var createdAt: Int64
    var updatedAt: Int64
    var deletedAt: Int64?
    
    // MARK: - Initialization
    
    init(
        id: String = UUID().uuidString.lowercased(),
        title: String = "Untitled",
        content: String = "",
        folder: String = "inbox",
        projectId: String? = nil,
        properties: String? = nil,
        createdAt: Int64 = Int64(Date().timeIntervalSince1970),
        updatedAt: Int64 = Int64(Date().timeIntervalSince1970),
        deletedAt: Int64? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.folder = folder
        self.projectId = projectId
        self.properties = properties
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    // MARK: - Computed Properties
    
    var wordCount: Int {
        let text = content
            .replacingOccurrences(of: "```[\\s\\S]*?```", with: "", options: .regularExpression)
            .replacingOccurrences(of: "`[^`]+`", with: "", options: .regularExpression)
            .replacingOccurrences(of: "[#*_~>\\-]", with: "", options: .regularExpression)
        return text.split(separator: " ").count
    }
    
    var preview: String {
        String(content.prefix(200))
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespaces)
    }
    
    var isDeleted: Bool {
        deletedAt != nil
    }
    
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(createdAt))
    }
    
    var modifiedDate: Date {
        Date(timeIntervalSince1970: TimeInterval(updatedAt))
    }
}

// MARK: - GRDB Conformance

extension Note: FetchableRecord, PersistableRecord {
    static let databaseTableName = "notes"
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, folder, properties
        case projectId = "project_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Date Helpers

extension Date {
    var unixTimestamp: Int64 {
        Int64(timeIntervalSince1970)
    }
    
    init(unixTimestamp: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
    }
}
