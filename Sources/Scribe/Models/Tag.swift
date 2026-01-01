import Foundation
import GRDB
import SwiftUI

/// Tag definition with optional color
struct Tag: Codable, FetchableRecord, PersistableRecord, Identifiable, Sendable {
    let id: String
    var name: String
    var color: String?
    var createdAt: Int64
    
    init(
        id: String = UUID().uuidString.lowercased(),
        name: String,
        color: String? = nil,
        createdAt: Int64 = Date().unixTimestamp
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = createdAt
    }
    
    static let databaseTableName = "tags"
    
    enum CodingKeys: String, CodingKey {
        case id, name, color
        case createdAt = "created_at"
    }
    
    enum Columns {
        static let id = Column("id")
        static let name = Column("name")
        static let color = Column("color")
        static let createdAt = Column("created_at")
    }
    
    var displayName: String {
        name
    }
    
    var swiftuiColor: Color? {
        guard let hexColor = color else { return nil }
        return Color(hex: hexColor)
    }
}
