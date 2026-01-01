import Foundation

/// Clean note service - simple CRUD operations
@MainActor
final class NoteService {
    private let database: DatabaseManager
    
    init(database: DatabaseManager) {
        self.database = database
    }
    
    // MARK: - Fetch
    
    func fetchAll(
        projectId: String? = nil,
        limit: Int? = nil,
        offset: Int = 0
    ) async throws -> [Note] {
        try await database.fetchNotes(projectId: projectId, limit: limit, offset: offset)
    }
    
    func fetch(id: String) async throws -> Note {
        guard let note = try await database.fetchNote(id: id) else {
            throw ScribeError.noteNotFound(id)
        }
        return note
    }
    
    // MARK: - Create
    
    func create(
        title: String,
        content: String = "",
        projectId: String? = nil
    ) async throws -> Note {
        let note = Note(
            title: title,
            content: content,
            projectId: projectId,
            wordCount: calculateWordCount(for: content)
        )
        
        try await database.saveNote(note)
        return note
    }
    
    func createDailyNote(for date: Date = Date(), projectId: String? = nil) async throws -> Note {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let title = formatter.string(from: date)
        
        // Check if exists
        let existing = try await fetchAll(projectId: projectId)
        if let found = existing.first(where: { $0.title == title }) {
            return found
        }
        
        // Create new
        let content = """
        # \(title)
        
        ## Notes
        
        
        ## Tasks
        
        - [ ] 
        """
        
        return try await create(title: title, content: content, projectId: projectId)
    }
    
    // MARK: - Update
    
    func save(_ note: Note) async throws {
        var updated = note
        updated.updatedAt = Date().unixTimestamp
        updated.wordCount = calculateWordCount(for: note.content)
        try await database.saveNote(updated)
    }
    
    // MARK: - Delete
    
    func delete(id: String) async throws {
        try await database.deleteNote(id: id)
    }
    
    // MARK: - Search
    
    func search(query: String, projectId: String? = nil) async throws -> [Note] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        return try await database.searchNotes(query: query, projectId: projectId)
    }
    
    // MARK: - Helpers
    
    private func calculateWordCount(for content: String) -> Int {
        let text = content
            .replacingOccurrences(of: "```[\\s\\S]*?```", with: "", options: .regularExpression)
            .replacingOccurrences(of: "`[^`]+`", with: "", options: .regularExpression)
            .replacingOccurrences(of: "[#*_~>\\-]", with: "", options: .regularExpression)
        return text.split(separator: " ").count
    }
}
