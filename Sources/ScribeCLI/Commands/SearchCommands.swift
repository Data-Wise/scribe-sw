import Foundation

/// Search commands using FTS5
enum SearchCommands {
    
    @MainActor
    static func search(_ noteService: NoteService, args: [String]) async throws {
        var query = ""
        var projectId: String? = nil
        var tag: String? = nil
        var titleOnly = false
        
        // Parse arguments
        var i = 0
        while i < args.count {
            let arg = args[i]
            
            if arg == "--project" && i + 1 < args.count {
                projectId = args[i + 1]
                i += 2
            } else if arg == "--tag" && i + 1 < args.count {
                tag = args[i + 1]
                i += 2
            } else if arg == "--title-only" {
                titleOnly = true
                i += 1
            } else {
                query = arg
                i += 1
            }
        }
        
        guard !query.isEmpty else {
            print("❌ Usage: scribe-cli search <query> [--project <id>] [--tag <tag>] [--title-only]")
            return
        }
        
        // Perform search
        var results = try await noteService.search(query: query, projectId: projectId)
        
        // Apply tag filter if specified
        if let tag = tag {
            results = results.filter { $0.tags.contains(tag.lowercased()) }
        }
        
        // Apply title-only filter if specified
        if titleOnly {
            results = results.filter { $0.title.localizedCaseInsensitiveContains(query) }
        }
        
        // Display results
        if results.isEmpty {
            print("🔍 No results found for '\(query)'")
            return
        }
        
        print("🔍 Search results for '\(query)' (\(results.count)):")
        print("--------------------------------")
        for note in results {
            let id = note.id.prefix(8)
            let preview = note.preview.isEmpty ? "(empty)" : note.preview
            print("[\(id)] \(note.title)")
            print("  \(preview)")
            if !note.tags.isEmpty {
                print("  Tags: \(note.tags.map { "#\($0)" }.joined(separator: " "))")
            }
            print("")
        }
    }
}
