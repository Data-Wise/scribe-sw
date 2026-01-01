import SwiftUI

/// Main content view with sidebar and editor
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            VaultSidebar()
                .navigationSplitViewColumnWidth(min: 200, ideal: 260, max: 350)
        } detail: {
            // Main editor area
            EditorArea()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: { appState.showSidebar.toggle() }) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Sidebar (⌘B)")
                .keyboardShortcut("b", modifiers: .command)
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { Task { await appState.createNewNote() } }) {
                    Image(systemName: "doc.badge.plus")
                }
                .help("New Note (⌘N)")
                .keyboardShortcut("n", modifiers: .command)
                
                Button(action: { Task { await appState.openDailyNote() } }) {
                    Image(systemName: "calendar")
                }
                .help("Daily Note (⌘D)")
                .keyboardShortcut("d", modifiers: .command)
                
                Button(action: { appState.showQuickCapture = true }) {
                    Image(systemName: "bolt.fill")
                }
                .help("Quick Capture (⌘⇧C)")
                .keyboardShortcut("c", modifiers: [.command, .shift])
            }
        }
        .sheet(isPresented: $appState.showQuickCapture) {
            QuickCaptureView()
        }
        .alert("Error", isPresented: .constant(appState.error != nil)) {
            Button("OK") {
                appState.error = nil
            }
        } message: {
            if let error = appState.error {
                Text(error.localizedDescription)
            }
        }
        .overlay {
            if appState.showCommandPalette {
                ZStack {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                        .onTapGesture {
                            appState.showCommandPalette = false
                        }
                    
                    CommandPaletteView()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .frame(width: 1200, height: 800)
}
