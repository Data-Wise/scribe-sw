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
                
                // Enhanced Statistics
                EnhancedStatistics()
                    .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: 800)
        .frame(maxWidth: .infinity)
    }
}

private struct EnhancedStatistics: View {
    @EnvironmentObject var appState: AppState
    @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    @State private var sessionDuration: String = "0m"
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Statistics")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    icon: "🔥",
                    label: "Streak",
                    value: "\(appState.writingStats.streak) days",
                    color: .orange,
                    gradient: true
                )
                
                StatCard(
                    icon: "📊",
                    label: "Today",
                    value: "\(appState.writingStats.wordsToday) words",
                    color: .blue,
                    gradient: true
                )
                
                StatCard(
                    icon: "⏱️",
                    label: "Session",
                    value: sessionDuration,
                    color: .green,
                    gradient: true
                )
                
                StatCard(
                    icon: "🎯",
                    label: "Goal",
                    value: "\(goalPercent)%",
                    color: .purple,
                    gradient: true,
                    progress: Double(goalPercent) / 100.0
                )
                
                StatCard(
                    icon: "📝",
                    label: "Total Notes",
                    value: "\(appState.notes.count)",
                    color: .cyan
                )
                
                StatCard(
                    icon: "📁",
                    label: "Projects",
                    value: "\(appState.projects.count)",
                    color: .pink
                )
            }
        }
        .onReceive(timer) { _ in
            updateSessionDuration()
        }
        .onAppear {
            updateSessionDuration()
        }
    }
    
    private var goalPercent: Int {
        guard appState.writingStats.weeklyGoal > 0 else { return 0 }
        let totalWords = appState.notes.reduce(0) { $0 + $1.wordCount }
        return min(100, (totalWords * 100) / appState.writingStats.weeklyGoal)
    }
    
    private func updateSessionDuration() {
        let duration = appState.writingStats.sessionDuration
        let minutes = Int(duration / 60)
        if minutes < 60 {
            sessionDuration = "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            sessionDuration = "\(hours)h \(remainingMinutes)m"
        }
    }
}

private struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    var gradient: Bool = false
    var progress: Double? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with optional gradient background
            ZStack {
                if gradient {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                }
                
                Text(icon)
                    .font(.system(size: 24))
            }
            
            // Value (large)
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            // Label (small)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Optional progress bar
            if let progress = progress {
                ProgressView(value: progress)
                    .tint(color)
                    .padding(.horizontal, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    MissionControlView()
        .environmentObject(AppState())
}
