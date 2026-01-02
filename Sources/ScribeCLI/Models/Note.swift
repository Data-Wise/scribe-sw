import Foundation
import GRDB

/// A note - simple and clean
struct Note: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var projectId: String?
    var title: String
    var content: String
    var wordCount: Int
    var createdAt: Int64
    var updatedAt: Int64
    var deletedAt: Int64?
    
    init(
        id: String = UUID().uuidString.lowercased(),
        title: String = "Untitled",
        content: String = "",
        projectId: String? = nil,
        wordCount: Int = 0,
        createdAt: Int64 = Date().unixTimestamp,
        updatedAt: Int64 = Date().unixTimestamp,
        deletedAt: Int64? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.projectId = projectId
        self.wordCount = wordCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    // MARK: - Computed Properties
    
    var preview: String {
        String(content.prefix(200))
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - GRDB Conformance

extension Note: FetchableRecord, PersistableRecord {
    static let databaseTableName = "notes"
    
    enum CodingKeys: String, CodingKey {
        case id, title, content
        case wordCount = "word_count"
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
