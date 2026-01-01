import SwiftUI

/// Main application view - Minimal placeholder for fresh rebuild
/// This will be replaced with Phase 1 implementation
struct MainView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Scribe - Ready for Phase 1 Rebuild")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ScribeColors.textPrimary)
            
            Text("Backend: ✅ Complete | Frontend: 🚧 Starting Fresh")
                .font(.system(size: 14))
                .foregroundColor(ScribeColors.textSecondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ScribeColors.background)
    }
}

#Preview {
    MainView()
        .environmentObject(AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        ))
}
