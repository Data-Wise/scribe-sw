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
        
    case "projects", "project":
        try await executeProjectCommand(projectService, args: args)
        
    case "stats":
        try await StatsCommands.printStats(noteService, projectService)
    
    case "vault":
        try await executeVaultCommand(args: args)
        
    case "inbox":
        try await executeInboxCommand(noteService, projectService, args: args)
        
    case "quick":
        try await InboxCommands.quick(noteService, args: args)
        
    case "tags", "tag":
        try await executeTagsCommand(noteService, args: args)
        
    case "help", "--help", "-h":
        HelpCommands.printUsage()
        
    default:
        print("❌ Unknown command: \(command)")
        HelpCommands.printUsage()
        exit(1)
    }
}

@MainActor
func executeVaultCommand(args: [String]) async throws {
    guard let subcommand = args.first else {
        print("❌ Usage: scribe-cli vault <command>")
        print("   Commands: create, list, switch, context, info, delete")
        return
    }
    
    let subcommandArgs = Array(args.dropFirst())
    
    switch subcommand {
    case "create":
        let name = subcommandArgs.first ?? "default"
        let path = subcommandArgs.count > 1 ? subcommandArgs[1] : nil
        let type = subcommandArgs.count > 2 ? subcommandArgs[2] : nil
        try await VaultCommands.create(name: name, path: path, type: type)
        
    case "list", "ls":
        try await VaultCommands.list()
        
    case "switch":
        guard let name = subcommandArgs.first else {
            print("❌ Usage: scribe-cli vault switch <name>")
            return
        }
        try await VaultCommands.switchVault(to: name)
        
    case "context":
        try await VaultCommands.showContext()
        
    case "info":
        let name = subcommandArgs.first
        try await VaultCommands.info(name: name)
        
    case "delete", "rm":
        guard let name = subcommandArgs.first else {
            print("❌ Usage: scribe-cli vault delete <name>")
            return
        }
        try await VaultCommands.delete(name: name)
        
    default:
        print("❌ Unknown vault command: \(subcommand)")
        print("   Valid commands: create, list, switch, context, info, delete")
    }
}

@MainActor
func executeProjectCommand(_ projectService: ProjectService, args: [String]) async throws {
    guard let subcommand = args.first else {
        try await ProjectCommands.list(projectService)
        return
    }
    
    let subcommandArgs = Array(args.dropFirst())
    
    switch subcommand {
    case "list", "ls":
        try await ProjectCommands.list(projectService)
    case "create":
        try await ProjectCommands.create(projectService, args: subcommandArgs)
    default:
        print("❌ Unknown project subcommand: \(subcommand)")
        print("   Valid subcommands: list, create")
    }
}

@MainActor
func executeInboxCommand(_ noteService: NoteService, _ projectService: ProjectService, args: [String]) async throws {
    guard let subcommand = args.first else {
        try await InboxCommands.list(noteService)
        return
    }
    
    let subcommandArgs = Array(args.dropFirst())
    
    switch subcommand {
    case "list", "ls":
        try await InboxCommands.list(noteService)
    case "move", "mv":
        try await InboxCommands.move(noteService, projectService: projectService, args: subcommandArgs)
    default:
        print("❌ Unknown inbox subcommand: \(subcommand)")
        print("   Valid subcommands: list, move")
    }
}

@MainActor
func executeTagsCommand(_ noteService: NoteService, args: [String]) async throws {
    guard let subcommand = args.first else {
        try await TagsCommands.list(noteService)
        return
    }
    
    let subcommandArgs = Array(args.dropFirst())
    
    switch subcommand {
    case "list", "ls":
        try await TagsCommands.list(noteService)
    case "search":
        guard let tag = subcommandArgs.first else {
            print("❌ Usage: scribe-cli tags search <tag>")
            return
        }
        try await TagsCommands.search(noteService, tag: tag)
    case "stats":
        try await TagsCommands.stats(noteService)
    default:
        print("❌ Unknown tags subcommand: \(subcommand)")
        print("   Valid subcommands: list, search, stats")
    }
}

// Run the CLI
let task = Task {
    await main()
    exit(0)
}
RunLoop.main.run()
