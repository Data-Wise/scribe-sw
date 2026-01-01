import SwiftUI

/// Main app layout with sidebar, editor, and right panel
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Left sidebar - vault navigation
            VaultSidebar()
                .navigationSplitViewColumnWidth(min: 200, ideal: 260, max: 350)
        } detail: {
            // Editor area with tabs
            EditorArea()
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: { appState.showSidebar.toggle() }) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle sidebar (⌘[)")
            }

            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { appState.createNewPage() }) {
                    Image(systemName: "square.and.pencil")
                }
                .help("New page (⌘N)")

                Button(action: { appState.openDailyNote() }) {
                    Image(systemName: "calendar")
                }
                .help("Daily note (⌘D)")

                Button(action: { appState.showQuickCapture = true }) {
                    Image(systemName: "bolt.fill")
                }
                .help("Quick capture (⌘⇧C)")
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
