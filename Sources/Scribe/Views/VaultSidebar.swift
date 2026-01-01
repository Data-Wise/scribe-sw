import SwiftUI

/// Project sidebar for navigation
struct VaultSidebar: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        List(selection: $appState.selectedProjectId) {
            // Inbox section
            Section("QUICK ACCESS") {
                HStack(spacing: 12) {
                    Text("📥")
                        .font(.title3)
                    
                    Text("All Notes")
                        .font(.body)
                    
                    Spacer()
                    
                    if inboxCount > 0 {
                        Text("\(inboxCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                .tag(nil as String?)
            }
            
            // Projects section
            Section("PROJECTS") {
                ForEach(appState.projects) { project in
                    ProjectCard(project: project)
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
    
    private var inboxCount: Int {
        appState.notes.filter { $0.projectId == nil || $0.folder == "inbox" }.count
    }
}

private struct ProjectCard: View {
    let project: Project
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator (vertical bar)
            RoundedRectangle(cornerRadius: 2)
                .fill(project.type.swiftuiColor)
                .frame(width: 4, height: 24)
            
            // Icon + Name
            HStack(spacing: 8) {
                Text(project.type.emoji)
                    .font(.body)
                
                Text(project.name)
                    .font(.body)
            }
            
            Spacer()
            
            // Badge count
            if noteCount > 0 {
                Text("\(noteCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(project.type.swiftuiColor.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var noteCount: Int {
        appState.notes.filter { $0.projectId == project.id }.count
    }
}
