import SwiftUI

/// Scribe - ADHD-friendly distraction-free writer
/// Native SwiftUI version for macOS
@main
struct ScribeApp: App {
    @StateObject private var appState: AppState

    init() {
        // Initialize services
        let database = DatabaseManager.shared
        let noteService = NoteService(database: database)
        let projectService = ProjectService(database: database)
        
        // Create AppState with injected dependencies
        _appState = StateObject(wrappedValue: AppState(
            noteService: noteService,
            projectService: projectService
        ))
    }

    var body: some Scene {
        // Main window
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Note") {
                    Task { await appState.createNewNote() }
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("Daily Note") {
                    Task { await appState.openDailyNote() }
                }
                .keyboardShortcut("d", modifiers: .command)

                Divider()

                Button("Quick Capture") {
                    appState.showQuickCapture = true
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
            }

            CommandGroup(replacing: .sidebar) {
                Button("Toggle Sidebar") {
                    appState.showSidebar.toggle()
                }
                .keyboardShortcut("[", modifiers: .command)
            }
            
            CommandGroup(after: .sidebar) {
                Button("Search Notes") {
                    appState.showCommandPalette = true
                }
                .keyboardShortcut("k", modifiers: .command)
            }
        }

        // // Menu bar extra for quick access
        // MenuBarExtra("Scribe", systemImage: "doc.text") {
        //     MenuBarView()
        //         .environmentObject(appState)
        // }
        // .menuBarExtraStyle(.window)

        // Quick capture window
        Window("Quick Capture", id: "quick-capture") {
            QuickCaptureView()
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 400, height: 200)

        // Settings
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}
