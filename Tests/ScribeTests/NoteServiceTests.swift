import Testing
@testable import Scribe
import Foundation

@Suite("Note Service Tests")
@MainActor
struct NoteServiceTests {
    let database: DatabaseManager
    let service: NoteService
    
    init() async throws {
        // Use in-memory database for testing
        database = DatabaseManager.shared
        service = NoteService(database: database)
    }
    
    @Test("Create note successfully")
    func createNote() async throws {
        let note = try await service.create(
            title: "Test Note",
            content: "Test content",
            projectId: nil,
            folder: "inbox"
        )
        
        #expect(note.id.isEmpty == false)
        #expect(note.title == "Test Note")
        #expect(note.content == "Test content")
        #expect(note.wordCount >= 0)
    }
    
    @Test("Create note with empty title throws error")
    func createNoteEmptyTitle() async throws {
        await #expect(throws: ScribeError.self) {
            try await service.create(title: "", content: "content")
        }
    }
    
    @Test("Fetch note by ID")
    func fetchNote() async throws {
        let created = try await service.create(
            title: "Fetch Test",
            content: "Content"
        )
        
        let fetched = try await service.fetch(id: created.id)
        
        #expect(fetched.id == created.id)
        #expect(fetched.title == created.title)
    }
    
    @Test("Fetch non-existent note throws error")
    func fetchNonExistentNote() async throws {
        await #expect(throws: ScribeError.self) {
            try await service.fetch(id: "non-existent-id")
        }
    }
    
    @Test("Update note and recalculate word count")
    func updateNoteWordCount() async throws {
        let note = try await service.create(
            title: "Word Count Test",
            content: "Hello world"
        )
        
        #expect(note.wordCount == 2)
        
        var updated = note
        updated.content = "Hello world this is a test"
        try await service.save(updated)
        
        let fetched = try await service.fetch(id: note.id)
        #expect(fetched.wordCount == 6)
    }
    
    @Test("Delete note")
    func deleteNote() async throws {
        let note = try await service.create(
            title: "Delete Test",
            content: "Content"
        )
        
        try await service.delete(id: note.id)
        
        await #expect(throws: ScribeError.self) {
            try await service.fetch(id: note.id)
        }
    }
    
    @Test("Search notes")
    func searchNotes() async throws {
        _ = try await service.create(title: "Apple", content: "Apple content")
        _ = try await service.create(title: "Banana", content: "Banana content")
        _ = try await service.create(title: "Cherry", content: "Cherry content")
        
        let results = try await service.search(query: "Apple")
        
        #expect(results.count == 1)
        #expect(results.first?.title == "Apple")
    }
    
    @Test("Extract wiki links from content")
    func extractWikiLinks() async throws {
        let content = "This links to [[Note 1]] and [[Note 2]]"
        let links = service.extractWikiLinks(from: content)
        
        #expect(links.count == 2)
        #expect(links.contains("Note 1"))
        #expect(links.contains("Note 2"))
    }
    
    @Test("Extract tags from content")
    func extractTags() async throws {
        let content = "This is #tag1 and #tag2"
        let tags = service.extractTags(from: content)
        
        #expect(tags.count == 2)
        #expect(tags.contains("#tag1"))
        #expect(tags.contains("#tag2"))
    }
    
    @Test("Create daily note")
    func createDailyNote() async throws {
        let today = Date()
        let note = try await service.createDailyNote(for: today, projectId: nil)
        
        #expect(note.isDaily == true)
        #expect(note.title.contains(today.formatted(.dateTime.year().month().day())))
    }
    
    @Test("Get backlinks for note")
    func getBacklinks() async throws {
        let targetNote = try await service.create(
            title: "Target Note",
            content: "Target content"
        )
        
        let sourceNote = try await service.create(
            title: "Source Note",
            content: "Links to [[Target Note]]"
        )
        
        // Update links
        try await service.updateLinks(for: sourceNote)
        
        let backlinks = try await service.backlinks(for: targetNote.id)
        
        #expect(backlinks.count == 1)
        #expect(backlinks.first?.id == sourceNote.id)
    }
}
