import Foundation
import GRDB

/// Links between notes (wiki-style [[link]])
struct Link: Codable, FetchableRecord, PersistableRecord, Identifiable, Sendable {
    var id: Int64?
    var sourceNoteId: String
    var targetNoteId: String
    var linkType: LinkType
    var createdAt: Int64
    
    init(
        id: Int64? = nil,
        sourceNoteId: String,
        targetNoteId: String,
        linkType: LinkType = .wiki,
        createdAt: Int64 = Date().unixTimestamp
    ) {
        self.id = id
        self.sourceNoteId = sourceNoteId
        self.targetNoteId = targetNoteId
        self.linkType = linkType
        self.createdAt = createdAt
    }
    
    static let databaseTableName = "links"
    
    enum CodingKeys: String, CodingKey {
        case id
        case sourceNoteId = "source_note_id"
        case targetNoteId = "target_note_id"
        case linkType = "link_type"
        case createdAt = "created_at"
    }
    
    enum Columns {
        static let id = Column("id")
        static let sourceNoteId = Column("source_note_id")
        static let targetNoteId = Column("target_note_id")
        static let linkType = Column("link_type")
        static let createdAt = Column("created_at")
    }
}

enum LinkType: String, Codable, CaseIterable, Sendable {
    case wiki      // [[note]]
    case cite      // @cite
    case embed     // ![[note]]
    
    var displayName: String {
        switch self {
        case .wiki: return "Wiki Link"
        case .cite: return "Citation"
        case .embed: return "Embed"
        }
    }
    
    var symbol: String {
        switch self {
        case .wiki: return "link"
        case .cite: return "quote.bubble"
        case .embed: return "square.and.arrow.down"
        }
    }
}
