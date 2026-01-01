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
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
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
            } catch {
                self.error = error as? ScribeError ?? .unknown(error)
            }
        }
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
}

// MARK: - Tab Model

struct NoteTab: Identifiable, Equatable {
    let id: UUID
    let noteId: String
    var isPinned: Bool
}
