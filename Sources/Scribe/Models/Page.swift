import Foundation

/// A page is a single document/note within a vault
struct Page: Identifiable, Codable, Equatable {
    let id: UUID
    var vaultId: UUID?
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isDaily: Bool
    var isFavorite: Bool
    var tags: [String]
    var deletedAt: Date?

    init(
        id: UUID = UUID(),
        vaultId: UUID? = nil,
        title: String = "Untitled",
        content: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isDaily: Bool = false,
        isFavorite: Bool = false,
        tags: [String] = [],
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.vaultId = vaultId
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDaily = isDaily
        self.isFavorite = isFavorite
        self.tags = tags
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
}
