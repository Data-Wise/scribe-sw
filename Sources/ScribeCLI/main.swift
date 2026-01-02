import Foundation

// CLI Entry Point

@MainActor
func main() async {
    let args = CommandLine.arguments
    
    guard args.count > 1 else {
        HelpCommands.printUsage()
        return
    }
    
    let command = args[1].lowercased()
    let commandArgs = Array(args.dropFirst(2))
    
    do {
        try await executeCommand(command, args: commandArgs)
    } catch {
        print("❌ Error: \(error.localizedDescription)")
        exit(1)
    }
}

@MainActor
func executeCommand(_ command: String, args: [String]) async throws {
    let db = DatabaseManager.shared
    let noteService = NoteService(database: db)
    let projectService = ProjectService(database: db)
    
    switch command {
    case "create":
        try await NoteCommands.create(noteService, args: args)
        
    case "edit":
        try await NoteCommands.edit(noteService, args: args)
        
    case "list", "ls":
        try await NoteCommands.list(noteService, args: args)
        
    case "show":
        try await NoteCommands.show(noteService, args: args)
        
    case "delete", "rm":
        try await NoteCommands.delete(noteService, args: args)
        
    case "search":
        try await SearchCommands.search(noteService, args: args)
        
    case "projects":
        try await ProjectCommands.list(projectService)
        
    case "stats":
        try await StatsCommands.printStats(noteService, projectService)
        
    case "help", "--help", "-h":
        HelpCommands.printUsage()
        
    default:
        print("❌ Unknown command: \(command)")
        HelpCommands.printUsage()
        exit(1)
    }
}

// Run the CLI
let task = Task {
    await main()
    exit(0)
}
RunLoop.main.run()
