import SwiftUI
import Combine

/// Central app state management (similar to Zustand store)
@MainActor
final class AppState: ObservableObject {
    // MARK: - UI State
    @Published var showSidebar = true
    @Published var showQuickCapture = false
    @Published var sidebarWidth: CGFloat = 260

    // MARK: - Navigation
    @Published var selectedVaultId: UUID?
    @Published var selectedPageId: UUID?
    @Published var openTabs: [PageTab] = []
    @Published var activeTabId: UUID?

    // MARK: - Data
    @Published var vaults: [Vault] = []
    @Published var pages: [Page] = []

    // MARK: - Services
    private let database: DatabaseService

    init() {
        self.database = DatabaseService()
        loadData()
    }

    // MARK: - Actions

    func createNewPage() {
        let page = Page(
            id: UUID(),
            vaultId: selectedVaultId,
            title: "Untitled",
            content: "",
            createdAt: Date(),
            updatedAt: Date()
        )
        pages.append(page)
        openPage(page)
    }

    func openDailyNote() {
        let today = Calendar.current.startOfDay(for: Date())

        // Find existing daily note
        if let existing = pages.first(where: {
            Calendar.current.isDate($0.createdAt, inSameDayAs: today) && $0.isDaily
        }) {
            openPage(existing)
            return
        }

        // Create new daily note
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let title = formatter.string(from: today)

        let page = Page(
            id: UUID(),
            vaultId: selectedVaultId,
            title: title,
            content: "# \(title)\n\n",
            createdAt: today,
            updatedAt: today,
            isDaily: true
        )
        pages.append(page)
        openPage(page)
    }

    func openPage(_ page: Page) {
        // Add to tabs if not already open
        if !openTabs.contains(where: { $0.pageId == page.id }) {
            let tab = PageTab(id: UUID(), pageId: page.id, isPinned: false)
            openTabs.append(tab)
        }
        activeTabId = openTabs.first(where: { $0.pageId == page.id })?.id
        selectedPageId = page.id
    }

    func closeTab(_ tabId: UUID) {
        guard let index = openTabs.firstIndex(where: { $0.id == tabId }) else { return }
        let tab = openTabs[index]

        // Don't close pinned tabs
        guard !tab.isPinned else { return }

        openTabs.remove(at: index)

        // Select adjacent tab if closing active
        if activeTabId == tabId {
            activeTabId = openTabs.last?.id
            selectedPageId = openTabs.last.flatMap { tab in
                pages.first(where: { $0.id == tab.pageId })?.id
            }
        }
    }

    func savePage(_ page: Page) {
        if let index = pages.firstIndex(where: { $0.id == page.id }) {
            var updated = page
            updated.updatedAt = Date()
            pages[index] = updated
            database.savePage(updated)
        }
    }

    // MARK: - Private

    private func loadData() {
        Task {
            vaults = await database.loadVaults()
            pages = await database.loadPages()
        }
    }
}

// MARK: - Tab Model

struct PageTab: Identifiable, Equatable {
    let id: UUID
    let pageId: UUID
    var isPinned: Bool
}
