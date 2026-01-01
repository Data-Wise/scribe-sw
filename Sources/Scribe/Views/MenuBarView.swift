import SwiftUI

/// Menu bar extra view
struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Quick stats
            VStack(spacing: 8) {
                Text("Scribe")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    Label("\(appState.notes.count)", systemImage: "doc.text")
                    Label("\(appState.projects.count)", systemImage: "folder")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
            
            // Quick actions
            Button("New Note") {
                Task { await appState.createNewNote() }
            }
            
            Button("Daily Note") {
                Task { await appState.openDailyNote() }
            }
            
            Button("Quick Capture") {
                appState.showQuickCapture = true
            }
            
            Divider()
            
            // Recent notes
            if !appState.notes.isEmpty {
                Text("Recent")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ForEach(appState.notes.prefix(3)) { note in
                    Button(note.title) {
                        appState.openNote(note)
                    }
                }
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .frame(width: 250)
    }
}

#Preview {
    MenuBarView()
        .environmentObject(AppState())
}
