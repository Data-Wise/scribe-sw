import Foundation

/// Search commands
enum SearchCommands {
    @MainActor
    static func search(_ service: NoteService, args: [String]) async throws {
        guard let query = args.first else {
            print("❌ Usage: scribe-cli search <query>")
            exit(1)
        }
        
        let results = try await service.search(query: query)
        
        if results.isEmpty {
            print("🔍 No results for: \(query)")
            return
        }
        
        print("🔍 Found \(results.count) results for: \(query)\n")
        for note in results {
            let id = String(note.id.prefix(8))
            print("  \(id) | \(note.title) (\(note.wordCount)w)")
        }
    }
}
