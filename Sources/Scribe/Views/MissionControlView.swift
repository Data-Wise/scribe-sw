import SwiftUI

/// Mission control dashboard view
struct MissionControlView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("⚡")
                        .font(.system(size: 60))
                    Text("Mission Control")
                        .font(.largeTitle.bold())
                    Text("Your writing command center")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Quick actions
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    QuickActionCard(
                        title: "New Note",
                        icon: "doc.badge.plus",
                        color: .blue
                    ) {
                        Task { await appState.createNewNote() }
                    }
                    
                    QuickActionCard(
                        title: "Daily Note",
                        icon: "calendar",
                        color: .green
                    ) {
                        Task { await appState.openDailyNote() }
                    }
                    
                    QuickActionCard(
                        title: "Quick Capture",
                        icon: "bolt.fill",
                        color: .orange
                    ) {
                        appState.showQuickCapture = true
                    }
                    
                    QuickActionCard(
                        title: "Search",
                        icon: "magnifyingglass",
                        color: .purple
                    ) {
                        // TODO: Show search
                    }
                }
                .padding(.horizontal)
                
                // Recent notes
                if !appState.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Notes")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(appState.notes.prefix(5)) { note in
                            NoteListItem(note: note)
                        }
                    }
                }
                
                // Statistics
                StatisticsCard(appState: appState)
                    .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: 800)
        .frame(maxWidth: .infinity)
    }
}

private struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

private struct NoteListItem: View {
    let note: Note
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button {
            appState.openNote(note)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.headline)
                    Text(note.preview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Text(note.modifiedDate.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

private struct StatisticsCard: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Statistics")
                .font(.headline)
            
            HStack(spacing: 32) {
                StatItem(
                    label: "Total Notes",
                    value: "\(appState.notes.count)",
                    icon: "doc.text"
                )
                
                StatItem(
                    label: "Projects",
                    value: "\(appState.projects.count)",
                    icon: "folder"
                )
                
                StatItem(
                    label: "Words",
                    value: "\(totalWords)",
                    icon: "textformat"
                )
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var totalWords: Int {
        appState.notes.reduce(0) { $0 + $1.wordCount }
    }
}

private struct StatItem: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(value)
                .font(.title.bold())
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    MissionControlView()
        .environmentObject(AppState())
}
