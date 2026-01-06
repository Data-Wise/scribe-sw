import Foundation

/// Tag management commands
enum TagsCommands {
    
    // MARK: - List All Tags
    
    @MainActor
    static func list(_ noteService: NoteService) async throws {
        let tagCounts = try await noteService.fetchAllTags()
        
        if tagCounts.isEmpty {
            print("📌 No tags found")
            return
        }
        
        print("📌 Tags (\(tagCounts.count)):")
        print("--------------------------------")
        
        // Sort by count (descending), then alphabetically
        let sorted = tagCounts.sorted { 
            $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value 
        }
        
        for (tag, count) in sorted {
            print("#\(tag) (\(count) notes)")
        }
    }
    
    // MARK: - Search by Tag
    
    @MainActor
    static func search(_ noteService: NoteService, tag: String) async throws {
        let notes = try await noteService.fetchByTag(tag)
        
        if notes.isEmpty {
            print("📌 No notes found with tag #\(tag)")
            return
        }
        
        print("📌 Notes with #\(tag) (\(notes.count)):")
        print("--------------------------------")
        for note in notes {
            let id = note.id.prefix(8)
            print("[\(id)] \(note.title)")
        }
    }
    
    // MARK: - Tag Statistics
    
    @MainActor
    static func stats(_ noteService: NoteService) async throws {
        let tagCounts = try await noteService.fetchAllTags()
        let allNotes = try await noteService.fetchAll()
        
        if tagCounts.isEmpty {
            print("📌 No tag statistics available")
            return
        }
        
        let totalTags = tagCounts.count
        let totalNotes = allNotes.count
        let notesWithTags = allNotes.filter { !$0.tags.isEmpty }.count
        let avgTagsPerNote = Double(tagCounts.values.reduce(0, +)) / Double(max(notesWithTags, 1))
        
        print("📌 Tag Statistics")
        print("--------------------------------")
        print("Total tags: \(totalTags)")
        print("Notes with tags: \(notesWithTags)/\(totalNotes)")
        print("Avg tags per note: \(String(format: "%.1f", avgTagsPerNote))")
        print("")
        print("Top 5 tags:")
        
        let top5 = tagCounts.sorted { $0.value > $1.value }.prefix(5)
        for (tag, count) in top5 {
            print("  #\(tag): \(count) notes")
        }
    }
}
