import Testing
@testable import Scribe
import Foundation

@Suite("AppState Tests")
@MainActor
struct AppStateTests {
    let database: DatabaseManager
    let noteService: NoteService
    let projectService: ProjectService
    var appState: AppState
    
    init() async throws {
        database = DatabaseManager.shared
        noteService = NoteService(database: database)
        projectService = ProjectService(database: database)
        appState = AppState(
            noteService: noteService,
            projectService: projectService
        )
    }
    
    @Test("Create new note updates notes array")
    func createNewNote() async throws {
        let initialCount = appState.notes.count
        
        await appState.createNewNote()
        
        // Wait for async operation
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(appState.notes.count == initialCount + 1)
    }
    
    @Test("Open note adds to tabs")
    func openNote() async throws {
        let note = try await noteService.create(
            title: "Tab Test",
            content: ""
        )
        
        let initialTabCount = appState.openTabs.count
        appState.openNote(note)
        
        #expect(appState.openTabs.count == initialTabCount + 1)
        #expect(appState.selectedNoteId == note.id)
    }
    
    @Test("Close tab removes from tabs array")
    func closeTab() async throws {
        let note = try await noteService.create(title: "Close Test", content: "")
        appState.openNote(note)
        
        guard let tabId = appState.openTabs.first?.id else {
            throw TestError.tabNotFound
        }
        
        let initialCount = appState.openTabs.count
        appState.closeTab(tabId)
        
        #expect(appState.openTabs.count == initialCount - 1)
    }
    
    @Test("Search notes updates search results")
    func searchNotes() async throws {
        _ = try await noteService.create(title: "Search Match", content: "Content")
        _ = try await noteService.create(title: "No Match", content: "Content")
        
        await appState.searchNotes(query: "Match")
        
        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)
        
        #expect(appState.searchResults.count == 1)
        #expect(appState.searchResults.first?.title.contains("Match") == true)
    }
    
    @Test("Delete note removes from notes array")
    func deleteNote() async throws {
        let note = try await noteService.create(title: "Delete Test", content: "")
        
        appState.notes.append(note)
        let initialCount = appState.notes.count
        
        await appState.deleteNote(note.id)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(appState.notes.count == initialCount - 1)
    }
    
    @Test("Toggle sidebar")
    func toggleSidebar() {
        let initial = appState.showSidebar
        appState.showSidebar.toggle()
        
        #expect(appState.showSidebar == !initial)
    }
    
    @Test("Create quick capture note")
    func quickCaptureNote() async throws {
        let initialCount = appState.notes.count
        
        let note = try await appState.createQuickCaptureNote(
            title: "Quick Note",
            content: "Quick content",
            projectId: nil
        )
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(appState.notes.count == initialCount + 1)
        #expect(note.title == "Quick Note")
    }
    
    @Test("Get backlinks through AppState")
    func getBacklinks() async throws {
        let targetNote = try await noteService.create(
            title: "Backlink Target",
            content: ""
        )
        let sourceNote = try await noteService.create(
            title: "Backlink Source",
            content: "[[Backlink Target]]"
        )
        
        try await noteService.updateLinks(for: sourceNote)
        
        let backlinks = await appState.backlinks(for: targetNote.id)
        
        #expect(backlinks.count == 1)
        #expect(backlinks.first?.id == sourceNote.id)
    }
    
    @Test("Filtered citations")
    func filteredCitations() async throws {
        let citation1 = Citation(id: "smith2023", title: "Smith Paper", author: "Smith, J.", year: "2023")
        let citation2 = Citation(id: "jones2023", title: "Jones Paper", author: "Jones, A.", year: "2023")
        
        appState.citations = [citation1, citation2]
        
        let results = appState.filteredCitations(query: "Smith")
        
        #expect(results.count == 1)
        #expect(results.first?.id == "smith2023")
    }
}

enum TestError: Error {
    case tabNotFound
}
