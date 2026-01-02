import Foundation

/// Help and usage commands
enum HelpCommands {
    static func printUsage() {
        print("""
        
        📝 Scribe CLI - Note-taking with Micro Editor
        
        USAGE:
          scribe-cli <command> [arguments]
        
        COMMANDS:
          create <title>       Create and edit a new note
          edit <id>            Edit existing note in Micro
          list [count]         List notes (default: 20)
          show <id>            Display note content
          delete <id>          Delete a note
          search <query>       Full-text search (FTS5)
          projects             List all projects
          stats                Show statistics
          help                 Show this message
        
        EDITOR:
          Uses 'micro' if installed, falls back to $EDITOR or vim
          Install micro: brew install micro
        
        EXAMPLES:
          scribe-cli create "Research Notes"
          scribe-cli list
          scribe-cli edit abc123
          scribe-cli search "keyword"
        
        """)
    }
}
