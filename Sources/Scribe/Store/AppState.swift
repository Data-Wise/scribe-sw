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
    @Published var selectedProjectId: String?
    @Published var selectedNoteId: String?
    @Published var openTabs: [NoteTab] = []
    @Published var activeTabId: UUID?

    // MARK: - Data
    @Published var projects: [Project] = []
    @Published var notes: [Note] = []

    // MARK: - Services
    private let database: DatabaseService

    init() {
        self.database = DatabaseService()
        loadData()
    }

    // MARK: - Actions

    func createNewNote() {
        let note = Note(
            id: UUID().uuidString.lowercased(),
            title: "Untitled",
            content: "",
            folder: "inbox",
            projectId: selectedProjectId
        )
        notes.append(note)
        openNote(note)
    }

    func openDailyNote() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Find existing daily note
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let title = formatter.string(from: today)
        
        if let existing = notes.first(where: { $0.title == title && $0.folder == "daily" }) {
            openNote(existing)
            return
        }
        
        // Create new daily note
        let note = Note(
            id: UUID().uuidString.lowercased(),
            title: title,
            content: "# \(title)\n\n",
            folder: "daily",
            projectId: selectedProjectId
        )
        notes.append(note)
        openNote(note)
    }

    func openNote(_ note: Note) {
        // Add to tabs if not already open
        if !openTabs.contains(where: { $0.noteId == note.id }) {
            let tab = NoteTab(id: UUID(), noteId: note.id, isPinned: false)
            openTabs.append(tab)
        }
        activeTabId = openTabs.first(where: { $0.noteId == note.id })?.id
        selectedNoteId = note.id
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
            selectedNoteId = openTabs.last.flatMap { tab in
                notes.first(where: { $0.id == tab.noteId })?.id
            }
        }
    }

    func saveNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updated = note
            updated.updatedAt = Int64(Date().timeIntervalSince1970)
            notes[index] = updated
            database.saveNote(updated)
        }
    }

    // MARK: - Private

    private func loadData() {
        Task {
            projects = await database.loadProjects()
            notes = await database.loadNotes()
        }
    }
}

// MARK: - Tab Model

struct NoteTab: Identifiable, Equatable {
    let id: UUID
    let noteId: String
    var isPinned: Bool
}
