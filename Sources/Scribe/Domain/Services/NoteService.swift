import Foundation

/// Service for note operations
/// Provides business logic layer between UI and database
@MainActor
final class NoteService {
    // MARK: - Singleton
    
    static let shared = NoteService()
    
    // MARK: - Dependencies
    
    private let database: DatabaseManager
    
    init(database: DatabaseManager = .shared) {
        self.database = database
    }
    
    // MARK: - CRUD Operations
    
    func fetch(id: String) async throws -> Note {
        guard let note = try await database.fetchNote(id: id) else {
            throw ScribeError.noteNotFound(id)
        }
        return note
    }
    
    func fetchAll(projectId: String? = nil, includeDeleted: Bool = false) async throws -> [Note] {
        try await database.fetchNotes(projectId: projectId, includeDeleted: includeDeleted)
    }
    
    func create(
        title: String,
        content: String = "",
        projectId: String? = nil,
        folder: String = "inbox",
        metadata: NoteMetadata? = nil
    ) async throws -> Note {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ScribeError.emptyTitle
        }
        
        let note = Note(
            projectId: projectId,
            title: title,
            content: content,
            folder: folder,
            metadata: metadata
        )
        
        try await database.saveNote(note)
        return note
    }
    
    func save(_ note: Note) async throws {
        var updated = note
        updated.updatedAt = Date().unixTimestamp
        try await database.saveNote(updated)
    }
    
    func delete(id: String, permanent: Bool = false) async throws {
        try await database.deleteNote(id: id, permanent: permanent)
    }
    
    func restore(id: String) async throws {
        guard var note = try await database.fetchNote(id: id) else {
            throw ScribeError.noteNotFound(id)
        }
        
        note.deletedAt = nil
        try await database.saveNote(note)
    }
    
    // MARK: - Search
    
    func search(query: String, projectId: String? = nil) async throws -> [Note] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        
        return try await database.searchNotes(query: query, projectId: projectId)
    }
    
    // MARK: - Links
    
    func backlinks(for noteId: String) async throws -> [Note] {
        try await database.fetchBacklinks(for: noteId)
    }
    
    /// Extract wiki links from note content: [[Note Title]]
    func extractWikiLinks(from content: String) -> [String] {
        let pattern = #"\[\[([^\]]+)\]\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        let matches = regex.matches(
            in: content,
            range: NSRange(content.startIndex..., in: content)
        )
        
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return String(content[range])
        }
    }
    
    /// Update links for a note based on its content
    func updateLinks(for note: Note) async throws {
        // Delete existing links
        try await database.deleteLinks(for: note.id)
        
        // Extract wiki links
        let wikiLinks = extractWikiLinks(from: note.content)
        
        // Find target notes by title
        let allNotes = try await fetchAll(projectId: note.projectId)
        
        for linkTitle in wikiLinks {
            if let targetNote = allNotes.first(where: { $0.title == linkTitle }) {
                try await database.saveLink(
                    sourceId: note.id,
                    targetId: targetNote.id,
                    type: "wiki"
                )
            }
        }
    }
    
    // MARK: - Tags
    
    /// Extract tags from note content: #tag
    func extractTags(from content: String) -> [String] {
        let pattern = #"#([a-zA-Z0-9_-]+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        let matches = regex.matches(
            in: content,
            range: NSRange(content.startIndex..., in: content)
        )
        
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return "#" + String(content[range])
        }
    }
    
    /// Update note metadata with tags from content
    func updateTagsFromContent(_ note: Note) async throws {
        let tags = extractTags(from: note.content)
        
        var updated = note
        var metadata = updated.metadata ?? NoteMetadata()
        metadata.tags = tags
        updated.metadata = metadata
        
        try await database.saveNote(updated)
    }
    
    // MARK: - Daily Notes
    
    func createDailyNote(for date: Date = Date(), projectId: String? = nil) async throws -> Note {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let title = formatter.string(from: date)
        
        // Check if daily note already exists
        let existingNotes = try await fetchAll(projectId: projectId)
        if let existing = existingNotes.first(where: { 
            $0.isDaily && $0.title == title 
        }) {
            return existing
        }
        
        // Create new daily note
        var metadata = NoteMetadata()
        metadata.isDaily = true
        
        let content = """
        # \(title)
        
        ## Notes
        
        
        ## Tasks
        
        - [ ] 
        
        """
        
        return try await create(
            title: title,
            content: content,
            projectId: projectId,
            folder: "daily",
            metadata: metadata
        )
    }
    
    // MARK: - Statistics
    
    func count(projectId: String? = nil) async throws -> Int {
        try await database.noteCount(projectId: projectId)
    }
    
    func totalWordCount(projectId: String? = nil) async throws -> Int {
        try await database.totalWordCount(projectId: projectId)
    }
}
