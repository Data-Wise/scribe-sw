import SwiftUI

/// Main editor area with tabs and page editor
struct EditorArea: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            EditorTabBar()

            Divider()

            // Editor content
            if let pageId = appState.selectedPageId,
               let page = appState.pages.first(where: { $0.id == pageId }) {
                PageEditor(page: page)
            } else {
                // Empty state - Mission Control
                MissionControlView()
            }
        }
    }
}

// MARK: - Tab Bar

private struct EditorTabBar: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                // Pinned Mission Control tab
                TabButton(
                    title: "Mission Control",
                    icon: "square.grid.2x2",
                    isActive: appState.selectedPageId == nil,
                    isPinned: true
                ) {
                    appState.selectedPageId = nil
                    appState.activeTabId = nil
                }

                ForEach(appState.openTabs) { tab in
                    if let page = appState.pages.first(where: { $0.id == tab.pageId }) {
                        TabButton(
                            title: page.title,
                            icon: page.isDaily ? "calendar" : "doc.text",
                            isActive: appState.activeTabId == tab.id,
                            isPinned: tab.isPinned
                        ) {
                            appState.activeTabId = tab.id
                            appState.selectedPageId = page.id
                        } onClose: {
                            appState.closeTab(tab.id)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .background(Color(.windowBackgroundColor))
    }
}

// MARK: - Tab Button (Gradient Style)

private struct TabButton: View {
    let title: String
    let icon: String
    let isActive: Bool
    let isPinned: Bool
    let action: () -> Void
    var onClose: (() -> Void)? = nil

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))

                Text(title)
                    .font(.system(size: 12, weight: isActive ? .medium : .regular))
                    .lineLimit(1)

                if !isPinned, isHovering || isActive {
                    Button(action: { onClose?() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Group {
                    if isActive {
                        // Gradient background for active tab
                        LinearGradient(
                            colors: [
                                Color.accentColor.opacity(0.3),
                                Color.accentColor.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else if isHovering {
                        Color(.controlBackgroundColor)
                    } else {
                        Color.clear
                    }
                }
            )
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isActive ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}

#Preview {
    EditorArea()
        .environmentObject(AppState())
}
