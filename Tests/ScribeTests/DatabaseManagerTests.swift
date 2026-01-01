import Testing
@testable import Scribe
import Foundation

@Suite("Database Manager Tests")
@MainActor
struct DatabaseManagerTests {
    let database: DatabaseManager
    
    init() async throws {
        database = DatabaseManager.shared
    }
    
    @Test("Fetch notes returns empty array initially")
    func fetchNotesEmpty() async throws {
        let notes = try await database.fetchNotes()
        #expect(notes.isEmpty == true)
    }
    
    @Test("Create and fetch note")
    func createAndFetchNote() async throws {
        let note = Note(
            title: "DB Test Note",
            content: "Content"
        )
        
        try await database.saveNote(note)
        
        let fetched = try await database.fetchNote(id: note.id)
        
        #expect(fetched != nil)
        #expect(fetched?.id == note.id)
        #expect(fetched?.title == note.title)
    }
    
    @Test("Save note updates word count")
    func saveNoteWordCount() async throws {
        var note = Note(
            title: "Word Count",
            content: "Hello world"
        )
        
        note.wordCount = 2
        try await database.saveNote(note)
        
        let fetched = try await database.fetchNote(id: note.id)
        #expect(fetched?.wordCount == 2)
    }
    
    @Test("Fetch notes with pagination")
    func fetchNotesPagination() async throws {
        // Create 10 notes
        for i in 1...10 {
            let note = Note(title: "Note \(i)", content: "Content \(i)")
            try await database.saveNote(note)
        }
        
        // Fetch first page
        let page1 = try await database.fetchNotes(limit: 5, offset: 0)
        #expect(page1.count == 5)
        
        // Fetch second page
        let page2 = try await database.fetchNotes(limit: 5, offset: 5)
        #expect(page2.count == 5)
    }
    
    @Test("Fetch notes by project ID")
    func fetchNotesByProject() async throws {
        let project = Project(name: "Test Project", type: .generic)
        try await database.saveProject(project)
        
        let note1 = Note(projectId: project.id, title: "Note 1", content: "")
        let note2 = Note(projectId: project.id, title: "Note 2", content: "")
        let note3 = Note(projectId: nil, title: "Note 3", content: "")
        
        try await database.saveNote(note1)
        try await database.saveNote(note2)
        try await database.saveNote(note3)
        
        let projectNotes = try await database.fetchNotes(projectId: project.id)
        
        #expect(projectNotes.count == 2)
        #expect(projectNotes.allSatisfy { $0.projectId == project.id })
    }
    
    @Test("Soft delete note")
    func softDeleteNote() async throws {
        let note = Note(title: "Delete Test", content: "")
        try await database.saveNote(note)
        
        try await database.deleteNote(id: note.id, permanent: false)
        
        let fetched = try await database.fetchNote(id: note.id)
        
        // Note should still exist but be deleted
        #expect(fetched != nil)
        #expect(fetched?.deletedAt != nil)
    }
    
    @Test("Permanent delete note")
    func permanentDeleteNote() async throws {
        let note = Note(title: "Delete Test", content: "")
        try await database.saveNote(note)
        
        try await database.deleteNote(id: note.id, permanent: true)
        
        let fetched = try await database.fetchNote(id: note.id)
        
        #expect(fetched == nil)
    }
    
    @Test("Fetch notes excludes deleted notes by default")
    func fetchNotesExcludesDeleted() async throws {
        let note1 = Note(title: "Active", content: "")
        let note2 = Note(title: "Deleted", content: "", deletedAt: Date().unixTimestamp)
        
        try await database.saveNote(note1)
        try await database.saveNote(note2)
        
        let notes = try await database.fetchNotes(includeDeleted: false)
        
        #expect(notes.count == 1)
        #expect(notes.first?.title == "Active")
    }
    
    @Test("Fetch notes includes deleted notes when requested")
    func fetchNotesIncludesDeleted() async throws {
        let note1 = Note(title: "Active", content: "")
        let note2 = Note(title: "Deleted", content: "", deletedAt: Date().unixTimestamp)
        
        try await database.saveNote(note1)
        try await database.saveNote(note2)
        
        let notes = try await database.fetchNotes(includeDeleted: true)
        
        #expect(notes.count == 2)
    }
    
    @Test("Search notes with FTS")
    func searchNotes() async throws {
        let note1 = Note(title: "Apple Pie", content: "Delicious")
        let note2 = Note(title: "Banana Bread", content: "Tasty")
        let note3 = Note(title: "Cherry Tart", content: "Sweet")
        
        try await database.saveNote(note1)
        try await database.saveNote(note2)
        try await database.saveNote(note3)
        
        let results = try await database.searchNotes(query: "apple")
        
        #expect(results.count == 1)
        #expect(results.first?.title == "Apple Pie")
    }
    
    @Test("Note count returns correct value")
    func noteCount() async throws {
        for i in 1...5 {
            let note = Note(title: "Note \(i)", content: "")
            try await database.saveNote(note)
        }
        
        let count = try await database.noteCount()
        #expect(count == 5)
    }
    
    @Test("Total word count sums all notes")
    func totalWordCount() async throws {
        let note1 = Note(title: "Note 1", content: "Hello world", wordCount: 2)
        let note2 = Note(title: "Note 2", content: "Test content", wordCount: 2)
        let note3 = Note(title: "Note 3", content: "More text here", wordCount: 3)
        
        try await database.saveNote(note1)
        try await database.saveNote(note2)
        try await database.saveNote(note3)
        
        let total = try await database.totalWordCount()
        #expect(total == 7) // 2 + 2 + 3
    }
    
    @Test("Create and fetch project")
    func createAndFetchProject() async throws {
        let project = Project(
            name: "Test Project",
            type: .research
        )
        
        try await database.saveProject(project)
        
        let fetched = try await database.fetchProject(id: project.id)
        
        #expect(fetched != nil)
        #expect(fetched?.id == project.id)
        #expect(fetched?.name == project.name)
    }
    
    @Test("Fetch all projects")
    func fetchAllProjects() async throws {
        let project1 = Project(name: "Project 1", type: .generic)
        let project2 = Project(name: "Project 2", type: .research)
        
        try await database.saveProject(project1)
        try await database.saveProject(project2)
        
        let projects = try await database.fetchProjects()
        
        #expect(projects.count >= 2)
    }
    
    @Test("Delete project")
    func deleteProject() async throws {
        let project = Project(name: "Delete Me", type: .generic)
        try await database.saveProject(project)
        
        try await database.deleteProject(id: project.id)
        
        let fetched = try await database.fetchProject(id: project.id)
        #expect(fetched == nil)
    }
    
    @Test("Create and fetch backlinks")
    func createAndFetchBacklinks() async throws {
        let sourceNote = Note(title: "Source", content: "")
        let targetNote = Note(title: "Target", content: "")
        
        try await database.saveNote(sourceNote)
        try await database.saveNote(targetNote)
        
        try await database.saveLink(
            sourceId: sourceNote.id,
            targetId: targetNote.id,
            type: "wiki"
        )
        
        let backlinks = try await database.fetchBacklinks(for: targetNote.id)
        
        #expect(backlinks.count == 1)
        #expect(backlinks.first?.id == sourceNote.id)
    }
}
