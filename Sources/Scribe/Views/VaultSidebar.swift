import SwiftUI

/// Left sidebar showing vault tree navigation (Obsidian-style)
struct VaultSidebar: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var expandedVaults: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search pages...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color(.textBackgroundColor).opacity(0.5))
            .cornerRadius(6)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            // Vault list
            List(selection: $appState.selectedVaultId) {
                // Inbox section (always first, permanent)
                InboxSection()

                // Vaults
                ForEach(appState.vaults.filter { $0.type != .inbox }) { vault in
                    VaultSection(
                        vault: vault,
                        isExpanded: expandedVaults.contains(vault.id)
                    ) {
                        expandedVaults.formSymmetricDifference([vault.id])
                    }
                }
            }
            .listStyle(.sidebar)

            Divider()

            // Quick stats footer
            HStack {
                Label("\(appState.pages.count)", systemImage: "doc.text")
                Spacer()
                Label("\(totalWordCount)", systemImage: "textformat")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(minWidth: 200)
    }

    private var totalWordCount: String {
        let count = appState.pages.reduce(0) { $0 + $1.wordCount }
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000)
        }
        return "\(count)"
    }
}

// MARK: - Inbox Section

private struct InboxSection: View {
    @EnvironmentObject var appState: AppState

    private var inboxPages: [Page] {
        appState.pages.filter { $0.vaultId == nil && !$0.isDeleted }
    }

    var body: some View {
        Section {
            ForEach(inboxPages.prefix(5)) { page in
                PageRow(page: page)
            }

            if inboxPages.count > 5 {
                Text("\(inboxPages.count - 5) more...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } header: {
            HStack {
                Image(systemName: "tray")
                Text("Inbox")
                Spacer()
                Text("\(inboxPages.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Vault Section

private struct VaultSection: View {
    let vault: Vault
    let isExpanded: Bool
    let onToggle: () -> Void

    @EnvironmentObject var appState: AppState

    private var vaultPages: [Page] {
        appState.pages.filter { $0.vaultId == vault.id && !$0.isDeleted }
    }

    var body: some View {
        Section(isExpanded: .constant(isExpanded)) {
            ForEach(vaultPages) { page in
                PageRow(page: page)
            }
        } header: {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: vault.type.icon)
                        .foregroundColor(Color(hex: vault.color))
                    Text(vault.name)
                    Spacer()
                    Text("\(vaultPages.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Page Row

private struct PageRow: View {
    let page: Page
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: { appState.openPage(page) }) {
            HStack {
                Image(systemName: page.isDaily ? "calendar" : "doc.text")
                    .foregroundColor(.secondary)
                Text(page.title)
                    .lineLimit(1)
                Spacer()
                if page.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Open in New Tab") {
                appState.openPage(page)
            }
            Divider()
            Button("Rename...") {
                // TODO: Rename
            }
            Menu("Move to...") {
                ForEach(appState.vaults) { vault in
                    Button(vault.name) {
                        // TODO: Move
                    }
                }
            }
            Divider()
            Button("Delete", role: .destructive) {
                // TODO: Delete
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
