import SwiftUI
import Combine

/// Central app state management
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
    @Published var writingStats = WritingStats()
    @Published var isLoading = false
    @Published var error: ScribeError?

    // MARK: - Services
    
    private let noteService: NoteService
    private let projectService: ProjectService
    
    init(
        noteService: NoteService = .shared,
        projectService: ProjectService = .shared
    ) {
        self.noteService = noteService
        self.projectService = projectService
        
        Task {
            await loadData()
        }
    }

    // MARK: - Data Loading
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let projectsTask = projectService.fetchAll()
            async let notesTask = noteService.fetchAll()
            
            projects = try await projectsTask
            notes = try await notesTask
            
            await ensureInbox()
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
        }
    }
    
    private func ensureInbox() async {
        let inboxId = "system-inbox"
        if !projects.contains(where: { $0.id == inboxId }) {
            do {
                let inbox = try await projectService.create(
                    name: "Inbox",
                    description: "Quick capture zone",
                    type: .generic
                )
                // Note: projectService.create generates a new UUID, 
                // but for the system inbox we might want a stable ID or just check by name.
                // Let's just use the name for now if ID is dynamic, 
                // or refactor service to allow passing ID.
            } catch {
                print("Failed to ensure inbox: \(error)")
            }
        }
    }

    // MARK: - Note Actions

    func createNewNote() async {
        do {
            let note = try await noteService.create(
                title: "Untitled",
                content: "",
                projectId: selectedProjectId,
                folder: "inbox"
            )
            notes.append(note)
            openNote(note)
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
        }
    }

    func openDailyNote() async {
        do {
            let note = try await noteService.createDailyNote(
                for: Date(),
                projectId: selectedProjectId
            )
            
            // Update local state if not already present
            if !notes.contains(where: { $0.id == note.id }) {
                notes.append(note)
            }
            
            openNote(note)
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
        }
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
        guard let index = openTabs.firstIndex(where: { $0.id == tabId }) else {
            return
        }

        openTabs.remove(at: index)

        // Select adjacent tab if closing active
        if activeTabId == tabId {
            activeTabId = openTabs.last?.id
            selectedNoteId = openTabs.last?.noteId
        }
    }

    func saveNote(_ note: Note) {
        Task {
            do {
                try await noteService.save(note)
                
                // Update local state
                if let index = notes.firstIndex(where: { $0.id == note.id }) {
                    notes[index] = note
                }
                
                updateWritingStats()
            } catch {
                self.error = error as? ScribeError ?? .unknown(error)
            }
        }
    }
    
    private func updateWritingStats() {
        let now = Date()
        let calendar = Calendar.current
        
        // Handle streak
        if let lastWrite = writingStats.lastWriteDate {
            if calendar.isDateInYesterday(lastWrite) {
                writingStats.streak += 1
            } else if !calendar.isDateInToday(lastWrite) {
                writingStats.streak = 1
            }
        } else {
            writingStats.streak = 1
        }
        
        writingStats.lastWriteDate = now
        
        // Update words today
        // Note: This is an approximation for now. 
        // A better way would be tracking diffs, but let's start simple.
        let totalWords = notes.reduce(0) { $0 + $1.wordCount }
        writingStats.wordsToday = totalWords // Temporary logic: total words as a proxy
    }
    
    func deleteNote(_ noteId: String) async {
        do {
            try await noteService.delete(id: noteId)
            notes.removeAll { $0.id == noteId }
            
            // Close tab if open
            if let tabId = openTabs.first(where: { $0.noteId == noteId })?.id {
                closeTab(tabId)
            }
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
        }
    }
    
    // MARK: - Project Actions
    
    func createProject(name: String, type: ProjectType) async {
        do {
            let project = try await projectService.create(
                name: name,
                description: nil,
                type: type
            )
            projects.append(project)
            selectedProjectId = project.id
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
        }
    }
    
    func deleteProject(_ projectId: String) async {
        do {
            try await projectService.delete(id: projectId)
            projects.removeAll { $0.id == projectId }
            
            if selectedProjectId == projectId {
                selectedProjectId = nil
            }
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
        }
    }
    
    // MARK: - Search
    
    func searchNotes(query: String) async -> [Note] {
        do {
            return try await noteService.search(query: query, projectId: selectedProjectId)
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
            return []
        }
    }
    
    func createQuickCaptureNote(title: String, content: String, projectId: String?) async throws -> Note {
        do {
            let note = try await noteService.create(
                title: title,
                content: content,
                projectId: projectId ?? projects.first(where: { $0.name == "Inbox" })?.id,
                folder: "inbox"
            )
            notes.append(note)
            updateWritingStats()
            return note
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
            throw error
        }
    }
}

// MARK: - Tab Model

struct NoteTab: Identifiable, Equatable {
    let id: UUID
    let noteId: String
    var isPinned: Bool
}

struct WritingStats: Codable, Sendable {
    var streak: Int = 0
    var wordsToday: Int = 0
    var sessionStart: Date? = Date()
    var weeklyGoal: Int = 5000 // Default goal
    var lastWriteDate: Date?
    
    var sessionDuration: TimeInterval {
        guard let start = sessionStart else { return 0 }
        return Date().timeIntervalSince(start)
    }
}
