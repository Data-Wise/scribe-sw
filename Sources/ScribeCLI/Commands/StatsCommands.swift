import Foundation

/// Statistics commands
enum StatsCommands {
    @MainActor
    static func printStats(_ noteService: NoteService, _ projectService: ProjectService) async throws {
        let notes = try await noteService.fetchAll(limit: 10000)
        let projects = try await projectService.fetchAll()
        
        let totalWords = notes.reduce(0) { $0 + $1.wordCount }
        
        print("📊 Statistics:\n")
        print("  Notes: \(notes.count)")
        print("  Projects: \(projects.count)")
        print("  Total Words: \(totalWords)")
    }
}
