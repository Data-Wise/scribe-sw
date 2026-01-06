import Foundation

/// Note management commands
enum NoteCommands {
    @MainActor
    static func create(_ service: NoteService, args: [String]) async throws {
        let title = args.first ?? "Untitled"
        
        // Create note in database first
        var note = try await service.create(title: title, content: "", projectId: nil)
        
        // Create temp file for editing
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("scribe-\(note.id).md")
        
        // Write initial content (title as header)
        try "# \(title)\n\n".write(to: tempFile, atomically: true, encoding: .utf8)
        
        // Open in editor
        try EditorLauncher.openInEditor(tempFile.path)
        
        // Read back content
        let content = try String(contentsOf: tempFile, encoding: .utf8)
        
        // Update note
        note.content = content
        note.wordCount = calculateWordCount(content)
        note.updatedAt = Date().unixTimestamp
        try await service.save(note)
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempFile)
        
        print("✅ Created note: \(note.id)")
        print("   Title: \(note.title)")
        print("   Words: \(note.wordCount)")
    }
    
    @MainActor
    static func edit(_ service: NoteService, args: [String]) async throws {
        guard let noteId = args.first else {
            print("❌ Usage: scribe-cli edit <note-id>")
            print("   Tip: Use 'scribe-cli list' to see note IDs")
            return
        }
        
        var note = try await service.fetch(id: noteId)
        
        // Create temp file with current content
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("scribe-\(note.id).md")
        try note.content.write(to: tempFile, atomically: true, encoding: .utf8)
        
        // Open in editor
        try EditorLauncher.openInEditor(tempFile.path)
        
        // Read back content
        let newContent = try String(contentsOf: tempFile, encoding: .utf8)
        
        // Update if changed
        if newContent != note.content {
            note.content = newContent
            note.wordCount = calculateWordCount(newContent)
            note.updatedAt = Date().unixTimestamp
            try await service.save(note)
            
            print("✅ Updated note: \(note.id)")
            print("  Title: \(note.title)")
            print("   Words: \(note.wordCount)")
        } else {
            print("ℹ️  No changes made")
        }
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempFile)
    }
    
    @MainActor
    static func list(_ service: NoteService, args: [String]) async throws {
        let limit = args.first.flatMap(Int.init) ?? 20
        let notes = try await service.fetchAll(limit: limit)
        
        if notes.isEmpty {
            print("📝 No notes found")
            print("💡 Create one with: scribe-cli create <title>")
            return
        }
        
        print("📝 Notes (\(notes.count)):\n")
        
        for note in notes {
            let shortId = String(note.id.prefix(8))
            print("  \(shortId) | \(note.title)")
            
            let preview = note.preview
            if !preview.isEmpty {
                print("         \(preview)...")
            }
        }
        
        print("\n💡 Edit a note: scribe-cli edit \(String(notes.first!.id.prefix(8)))")
    }
    
    @MainActor
    static func show(_ service: NoteService, args: [String]) async throws {
        guard let noteId = args.first else {
            print("❌ Usage: scribe-cli show <note-id>")
            exit(1)
        }
        
        let note = try await service.fetch(id: noteId)
        
        print("📝 \(note.title)")
        print("🆔 \(note.id)")
        print("📅 \(formatDate(note.createdAt))")
        print("\n\(note.content)")
    }
    
    @MainActor
    static func delete(_ service: NoteService, args: [String]) async throws {
        guard let noteId = args.first else {
            print("❌ Usage: scribe-cli delete <note-id>")
            exit(1)
        }
        
        let note = try await service.fetch(id: noteId)
        
        print("⚠️  Delete '\(note.title)'? (y/N) ", terminator: "")
        guard let response = readLine()?.lowercased(), response == "y" else {
            print("Cancelled")
            return
        }
        
        try await service.delete(id: noteId)
        print("✅ Deleted note")
    }
    
    // MARK: - Helpers
    
    private static func calculateWordCount(_ text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    private static func formatDate(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
