import SwiftUI

@main
struct ScribeApp: App {
    // Initialize AppState with services
    // This must be a simple initialization, not a closure
    @StateObject private var appState = AppState(
        noteService: NoteService(database: DatabaseManager.shared),
        projectService: ProjectService(database: DatabaseManager.shared)
    )
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
        }
        .commands {
            // File menu commands
            CommandGroup(after: .newItem) {
                Button("New Note") {
                    Task {
                        await appState.createNewNote()
                    }
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            // View menu commands
            CommandGroup(after: .sidebar) {
                Button("Toggle Sidebar") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        appState.showSidebar.toggle()
                    }
                }
                .keyboardShortcut("[", modifiers: .command)
                
                Button("Toggle Right Sidebar") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        appState.showRightSidebar.toggle()
                    }
                }
                .keyboardShortcut("]", modifiers: .command)
            }
        }
    }
}
