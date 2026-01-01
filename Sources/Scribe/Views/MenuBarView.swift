import SwiftUI

/// Menu bar extra window for quick access
struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Scribe")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("Synced")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()

            Divider()

            // Quick stats
            HStack(spacing: 16) {
                VStack {
                    Text("\(appState.pages.count)")
                        .font(.title2.weight(.bold))
                    Text("Pages")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Text("\(wordsToday)")
                        .font(.title2.weight(.bold))
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Text("🔥 \(streak)")
                        .font(.title2)
                    Text("Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.controlBackgroundColor))

            Divider()

            // Quick actions
            VStack(spacing: 2) {
                MenuBarButton(
                    title: "Daily Note",
                    icon: "calendar",
                    shortcut: "⌘D"
                ) {
                    appState.openDailyNote()
                    NSApp.activate(ignoringOtherApps: true)
                }

                MenuBarButton(
                    title: "New Page",
                    icon: "square.and.pencil",
                    shortcut: "⌘N"
                ) {
                    appState.createNewPage()
                    NSApp.activate(ignoringOtherApps: true)
                }

                MenuBarButton(
                    title: "Quick Capture",
                    icon: "bolt.fill",
                    shortcut: "⌘⇧C"
                ) {
                    openWindow(id: "quick-capture")
                }
            }
            .padding(.vertical, 8)

            Divider()

            // Recent pages
            if !recentPages.isEmpty {
                Text("Recent")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)

                ForEach(recentPages.prefix(3)) { page in
                    MenuBarButton(
                        title: page.title,
                        icon: page.isDaily ? "calendar" : "doc.text"
                    ) {
                        appState.openPage(page)
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
                .padding(.bottom, 8)
            }

            Divider()

            // Footer
            HStack {
                Button("Settings...") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Quit Scribe") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .font(.caption)
            .padding()
        }
        .frame(width: 280)
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

// MARK: - Menu Bar Button

private struct MenuBarButton: View {
    let title: String
    let icon: String
    var shortcut: String? = nil
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20)
                Text(title)
                    .lineLimit(1)
                Spacer()
                if let shortcut {
                    Text(shortcut)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isHovering ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}

#Preview {
    MenuBarView()
        .environmentObject(AppState())
}
