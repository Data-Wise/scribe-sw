import XCTest
@testable import ScribeCLI

/// Unit tests for TagsCommands
final class TagsCommandsTests: XCTestCase {
    
    var noteService: NoteService!
    
    @MainActor
    override func setUp() async throws {
        noteService = NoteService(database: DatabaseManager.shared)
    }
    
    // MARK: - List Tests
    
    @MainActor
    func testListEmptyTags() async throws {
        // Create note without tags
        let note = try await noteService.create(title: "No tags", content: "Plain text")
        
        // List should show empty
        try await TagsCommands.list(noteService)
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    @MainActor
    func testListWithTags() async throws {
        // Create notes with tags
        let note1 = try await noteService.create(title: "Research", content: "#research #statistics")
        let note2 = try await noteService.create(title: "Teaching", content: "#teaching #lecture")
        
        // List should show tags
        try await TagsCommands.list(noteService)
        
        // Cleanup
        try await noteService.delete(id: note1.id)
        try await noteService.delete(id: note2.id)
    }
    
    // MARK: - Search Tests
    
    @MainActor
    func testSearchByTag() async throws {
        let note = try await noteService.create(title: "Test", content: "#research topic")
        
        try await TagsCommands.search(noteService, tag: "research")
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    @MainActor
    func testSearchByTagNoResults() async throws {
        try await TagsCommands.search(noteService, tag: "nonexistent")
    }
    
    @MainActor
    func testSearchByTagCaseInsensitive() async throws {
        let note = try await noteService.create(title: "Test", content: "#Research")
        
        try await TagsCommands.search(noteService, tag: "research")
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    // MARK: - Stats Tests
    
    @MainActor
    func testStatsEmpty() async throws {
        try await TagsCommands.stats(noteService)
    }
    
    @MainActor
    func testStatsWithTags() async throws {
        let note1 = try await noteService.create(title: "N1", content: "#research #stats")
        let note2 = try await noteService.create(title: "N2", content: "#research")
        
        try await TagsCommands.stats(noteService)
        
        // Cleanup
        try await noteService.delete(id: note1.id)
        try await noteService.delete(id: note2.id)
    }
    
    // MARK: - Integration Tests
    
    @MainActor
    func testMultipleTagsInNote() async throws {
        let note = try await noteService.create(
            title: "Multi-tag",
            content: "#research #statistics #causal-inference"
        )
        
        let tags = try await noteService.fetchAllTags()
        XCTAssertEqual(tags.count, 3)
        XCTAssertEqual(tags["research"], 1)
        XCTAssertEqual(tags["statistics"], 1)
        XCTAssertEqual(tags["causal-inference"], 1)
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    @MainActor
    func testSameTagAcrossNotes() async throws {
        let note1 = try await noteService.create(title: "N1", content: "#research")
        let note2 = try await noteService.create(title: "N2", content: "#research")
        
        let tags = try await noteService.fetchAllTags()
        XCTAssertEqual(tags["research"], 2)
        
        // Cleanup
        try await noteService.delete(id: note1.id)
        try await noteService.delete(id: note2.id)
    }
}
