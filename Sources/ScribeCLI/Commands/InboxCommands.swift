import Foundation

/// Inbox management commands
enum InboxCommands {
    
    // MARK: - List Inbox
    
    @MainActor
    static func list(_ noteService: NoteService) async throws {
        // Fetch all notes with no project (inbox)
        let notes = try await noteService.fetchAll(projectId: nil)
        
        if notes.isEmpty {
            print("📥 Inbox is empty")
            return
        }
        
        print("📥 Inbox (\(notes.count) notes):")
        print("--------------------------------")
        for note in notes {
            let id = note.id.prefix(8)
            let date = formatDate(note.updatedAt)
            print("[\(id)] \(note.title) (\(date))")
        }
    }
    
    // MARK: - Quick Capture
    
    @MainActor
    static func quick(_ noteService: NoteService, args: [String]) async throws {
        guard !args.isEmpty else {
            print("❌ Usage: scribe-cli quick <content>")
            return
        }
        
        let title = args.joined(separator: " ")
        let note = try await noteService.create(title: title, content: "", projectId: nil)
        
        print("✅ Captured to inbox: \(note.title)")
    }
    
    // MARK: - Move to Project
    
    @MainActor
    static func move(_ noteService: NoteService, projectService: ProjectService, args: [String]) async throws {
        guard args.count >= 2 else {
            print("❌ Usage: scribe-cli inbox move <note-id> <project-id>")
            return
        }
        
        let noteId = args[0]
        let projectId = args[1]
        
        // Find note (supports partial ID)
        let allNotes = try await noteService.fetchAll()
        guard let note = allNotes.first(where: { $0.id.hasPrefix(noteId) }) else {
            print("❌ Note not found: \(noteId)")
            return
        }
        
        // Find project (supports partial ID)
        let allProjects = try await projectService.fetchAll()
        guard let project = allProjects.first(where: { $0.id.hasPrefix(projectId) }) else {
            print("❌ Project not found: \(projectId)")
            return
        }
        
        var updatedNote = note
        updatedNote.projectId = project.id
        try await noteService.save(updatedNote)
        
        print("✅ Moved '\(note.title)' to project '\(project.name)'")
    }
    
    // MARK: - Helpers
    
    private static func formatDate(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
