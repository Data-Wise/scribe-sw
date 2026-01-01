import SwiftUI

/// ADHD-friendly stats footer with 5 key metrics
/// Format: 📝234w · ⏱12m · 🔥7d · ⚡15 · 🎯50%
struct StatsFooter: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: ScribeSpacing.md) {
            // Word count (current note)
            StatItem(
                icon: "pencil",
                value: "\(currentWordCount)w",
                color: ScribeColors.textSecondary
            )

            Divider()
                .frame(height: 12)
                .background(ScribeColors.border)

            // Session timer
            // The hidden Text observes sessionTimerTick to force timer refresh
            // without the old objectWillChange.send() that stole keyboard focus
            StatItem(
                icon: "clock",
                value: appState.writingStats.sessionDurationFormatted,
                color: ScribeColors.accent
            )
            .overlay(Text("\(appState.sessionTimerTick)").hidden())

            Divider()
                .frame(height: 12)
                .background(ScribeColors.border)

            // Writing streak
            StatItem(
                icon: "flame",
                value: "\(appState.writingStats.currentStreak)d",
                color: appState.writingStats.currentStreak > 0 ? ScribeColors.streak : ScribeColors.textTertiary
            )

            Divider()
                .frame(height: 12)
                .background(ScribeColors.border)

            // Today's words
            StatItem(
                icon: "bolt",
                value: "\(appState.writingStats.todayWordCount)",
                color: ScribeColors.success
            )

            Divider()
                .frame(height: 12)
                .background(ScribeColors.border)

            // Goal progress
            GoalProgress(progress: appState.writingStats.goalProgress)
        }
        .padding(.horizontal, ScribeSpacing.md)
        .frame(height: ScribeLayout.statsFooterHeight)
        .background(ScribeColors.surface)
    }

    // Current note word count
    private var currentWordCount: Int {
        guard let noteId = appState.selectedNoteId,
              let note = appState.notes.first(where: { $0.id == noteId }) else {
            return 0
        }
        return note.wordCount
    }
}

// MARK: - Stat Item Component

private struct StatItem: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: ScribeSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color.opacity(0.7))

            Text(value)
                .font(ScribeFonts.statsSmall)
                .foregroundColor(color)
        }
    }
}

// MARK: - Goal Progress Component

private struct GoalProgress: View {
    let progress: Double

    private var progressColor: Color {
        if progress >= 1.0 {
            return ScribeColors.success
        } else if progress >= 0.5 {
            return ScribeColors.accent
        } else {
            return ScribeColors.textSecondary
        }
    }

    var body: some View {
        HStack(spacing: ScribeSpacing.xs) {
            Image(systemName: progress >= 1.0 ? "checkmark.circle.fill" : "target")
                .font(.system(size: 10))
                .foregroundColor(progressColor.opacity(0.7))

            Text("\(Int(progress * 100))%")
                .font(ScribeFonts.statsSmall)
                .foregroundColor(progressColor)

            // Mini progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ScribeColors.border)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(width: 40, height: 4)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        StatsFooter()
    }
    .frame(width: 600, height: 100)
    .background(ScribeColors.background)
    .environmentObject(AppState(
        noteService: NoteService(database: DatabaseManager.shared),
        projectService: ProjectService(database: DatabaseManager.shared)
    ))
}
