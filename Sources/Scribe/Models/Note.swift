import Foundation
import GRDB

/// A note is a single document within a project
/// Sendable for Swift 6 concurrency safety
struct Note: Identifiable, Codable, Hashable, Sendable {
    // MARK: - Properties
    
    let id: String
    var projectId: String?
    var title: String
    var content: String
    var folder: String
    var metadata: NoteMetadata?
    var createdAt: Int64
    var updatedAt: Int64
    var deletedAt: Int64?
    
    // MARK: - Initialization
    
    init(
        id: String = UUID().uuidString.lowercased(),
        projectId: String? = nil,
        title: String = "Untitled",
        content: String = "",
        folder: String = "inbox",
        metadata: NoteMetadata? = nil,
        createdAt: Int64 = Date().unixTimestamp,
        updatedAt: Int64 = Date().unixTimestamp,
        deletedAt: Int64? = nil
    ) {
        self.id = id
        self.projectId = projectId
        self.title = title
        self.content = content
        self.folder = folder
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    // MARK: - Computed Properties
    
    var isDeleted: Bool {
        deletedAt != nil
    }
    
    var date: Date {
        Date(unixTimestamp: createdAt)
    }
    
    var modifiedDate: Date {
        Date(unixTimestamp: updatedAt)
    }
    
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
    
    var tags: [String] {
        metadata?.tags ?? []
    }
    
    var isDaily: Bool {
        metadata?.isDaily ?? false
    }
    
    var isPinned: Bool {
        metadata?.isPinned ?? false
    }
}

// MARK: - Note Metadata

struct NoteMetadata: Codable, Hashable, Sendable {
    var tags: [String] = []
    var aliases: [String] = []
    var properties: [String: String] = [:]
    var isDaily: Bool = false
    var isPinned: Bool = false
    
    init(
        tags: [String] = [],
        aliases: [String] = [],
        properties: [String: String] = [:],
        isDaily: Bool = false,
        isPinned: Bool = false
    ) {
        self.tags = tags
        self.aliases = aliases
        self.properties = properties
        self.isDaily = isDaily
        self.isPinned = isPinned
    }
}

// MARK: - GRDB Conformance

extension Note: FetchableRecord, PersistableRecord {
    static let databaseTableName = "notes"
    
    enum Columns {
        static let id = Column("id")
        static let projectId = Column("project_id")
        static let title = Column("title")
        static let content = Column("content")
        static let folder = Column("folder")
        static let metadata = Column("metadata")
        static let createdAt = Column("created_at")
        static let updatedAt = Column("updated_at")
        static let deletedAt = Column("deleted_at")
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, folder, metadata
        case projectId = "project_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Custom Encoding/Decoding for JSON metadata

extension Note {
    private static let jsonEncoder = JSONEncoder()
    private static let jsonDecoder = JSONDecoder()
    
    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["project_id"] = projectId
        container["title"] = title
        container["content"] = content
        container["folder"] = folder
        container["created_at"] = createdAt
        container["updated_at"] = updatedAt
        container["deleted_at"] = deletedAt
        
        if let metadata {
            let data = try Self.jsonEncoder.encode(metadata)
            container["metadata"] = String(data: data, encoding: .utf8)
        }
    }
    
    init(row: Row) throws {
        self.id = row["id"]
        self.projectId = row["project_id"]
        self.title = row["title"]
        self.content = row["content"]
        self.folder = row["folder"]
        self.createdAt = row["created_at"]
        self.updatedAt = row["updated_at"]
        self.deletedAt = row["deleted_at"]
        
        if let metadataString: String = row["metadata"],
           let data = metadataString.data(using: .utf8) {
            self.metadata = try? Self.jsonDecoder.decode(NoteMetadata.self, from: data)
        } else {
            self.metadata = nil
        }
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
