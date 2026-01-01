import SwiftUI

/// Project sidebar for navigation
struct VaultSidebar: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        List(selection: $appState.selectedProjectId) {
            // Inbox section
            Section("Inbox") {
                Label("All Notes", systemImage: "tray")
                    .tag(nil as String?)
            }
            
            // Projects section
            Section("Projects") {
                ForEach(appState.projects) { project in
                    ProjectRow(project: project)
                        .tag(project.id as String?)
                }
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            Button(action: { /* Create project */ }) {
                Image(systemName: "plus")
            }
        }
    }
}

private struct ProjectRow: View {
    let project: Project
    
    var body: some View {
        Label {
            Text(project.name)
        } icon: {
            Text(project.type.emoji)
        }
    }
}
