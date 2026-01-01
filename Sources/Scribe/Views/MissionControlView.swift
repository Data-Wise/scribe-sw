import SwiftUI

/// Mission Control - Dashboard home screen (pinned tab)
struct MissionControlView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("Mission Control")
                        .font(.system(size: 32, weight: .bold))
                    Text("Your writing dashboard")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // Quick actions
                HStack(spacing: 16) {
                    QuickActionButton(
                        title: "Daily Note",
                        icon: "calendar",
                        color: .blue
                    ) {
                        appState.openDailyNote()
                    }

                    QuickActionButton(
                        title: "New Page",
                        icon: "square.and.pencil",
                        color: .green
                    ) {
                        appState.createNewPage()
                    }

                    QuickActionButton(
                        title: "Quick Capture",
                        icon: "bolt.fill",
                        color: .orange
                    ) {
                        appState.showQuickCapture = true
                    }

                    QuickActionButton(
                        title: "New Vault",
                        icon: "folder.badge.plus",
                        color: .purple
                    ) {
                        // TODO: Create vault
                    }
                }

                // Stats grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(
                        title: "Pages",
                        value: "\(appState.pages.count)",
                        icon: "doc.text",
                        color: .blue
                    )
                    StatCard(
                        title: "Words Today",
                        value: "\(wordsToday)",
                        icon: "textformat",
                        color: .green
                    )
                    StatCard(
                        title: "Vaults",
                        value: "\(appState.vaults.count)",
                        icon: "folder",
                        color: .purple
                    )
                    StatCard(
                        title: "Streak",
                        value: "🔥 \(streak)",
                        icon: "flame",
                        color: .orange
                    )
                }
                .padding(.horizontal, 40)

                // Recent pages
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent")
                        .font(.title2.weight(.semibold))

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(recentPages.prefix(6)) { page in
                            RecentPageCard(page: page) {
                                appState.openPage(page)
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)

                Spacer(minLength: 40)
            }
        }
        .background(Color(.windowBackgroundColor))
    }

    private var recentPages: [Page] {
        appState.pages
            .filter { !$0.isDeleted }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    private var wordsToday: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return appState.pages
            .filter { Calendar.current.isDate($0.updatedAt, inSameDayAs: today) }
            .reduce(0) { $0 + $1.wordCount }
    }

    private var streak: Int {
        // Simple streak calculation - count consecutive days with pages
        var streak = 0
        var currentDate = Date()

        while true {
            let dayStart = Calendar.current.startOfDay(for: currentDate)
            let hasPageForDay = appState.pages.contains {
                Calendar.current.isDate($0.updatedAt, inSameDayAs: dayStart)
            }

            if hasPageForDay {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }

        return streak
    }
}

// MARK: - Quick Action Button

private struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(width: 100, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isHovering ? color.opacity(0.15) : Color(.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(isHovering ? 0.5 : 0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title2.weight(.bold))
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - Recent Page Card

private struct RecentPageCard: View {
    let page: Page
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: page.isDaily ? "calendar" : "doc.text")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(page.updatedAt.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Text(page.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(page.preview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Spacer()

                Text("\(page.wordCount) words")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isHovering ? Color(.selectedContentBackgroundColor).opacity(0.3) : Color(.controlBackgroundColor))
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}

#Preview {
    MissionControlView()
        .environmentObject(AppState())
}
