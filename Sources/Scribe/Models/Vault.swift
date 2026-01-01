import Foundation

/// A vault is a collection of pages (similar to Projects in browser version)
struct Vault: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var color: String
    var icon: String?
    var type: VaultType
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        color: String = "#3b82f6",
        icon: String? = nil,
        type: VaultType = .generic,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.type = type
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum VaultType: String, Codable, CaseIterable {
    case inbox = "inbox"
    case research = "research"
    case manuscript = "manuscript"
    case teaching = "teaching"
    case notes = "notes"
    case generic = "generic"

    var displayName: String {
        switch self {
        case .inbox: return "Inbox"
        case .research: return "Research"
        case .manuscript: return "Manuscript"
        case .teaching: return "Teaching"
        case .notes: return "Notes"
        case .generic: return "General"
        }
    }

    var icon: String {
        switch self {
        case .inbox: return "tray"
        case .research: return "magnifyingglass"
        case .manuscript: return "doc.text"
        case .teaching: return "graduationcap"
        case .notes: return "note.text"
        case .generic: return "folder"
        }
    }
}
