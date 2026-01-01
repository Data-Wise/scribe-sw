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
    }
}
