import SwiftUI

/// Clean, simple app state management
@MainActor
final class AppState: ObservableObject {
    // MARK: - Published State
    
    @Published var projects: [Project] = []
    @Published var notes: [Note] = []
    @Published var selectedNoteId: String?
    @Published var isLoading = false
    @Published var error: ScribeError?
    
    // MARK: - Services
    
    private let noteService: NoteService
    private let projectService: ProjectService
    
    // MARK: - Initialization
    
    init(noteService: NoteService, projectService: ProjectService) {
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
            async let notesTask = noteService.fetchAll(limit: 100)
            
            projects = try await projectsTask
            notes = try await notesTask
            
            // Ensure Inbox project exists
            await ensureInbox()
            
            // Auto-select first note
            if selectedNoteId == nil, let first = notes.first {
                selectedNoteId = first.id
            }
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
        }
    }
    
    private func ensureInbox() async {
        if projects.contains(where: { $0.name == "Inbox" }) {
            return
        }
        
        do {
            let inbox = try await projectService.create(
                name: "Inbox",
                description: "Quick capture zone",
                type: .generic
            )
            projects.append(inbox)
        } catch {
            print("Failed to create Inbox: \(error)")
        }
    }
    
    // MARK: - Note Actions
    
    func createNewNote() async {
        do {
            let note = try await noteService.create(
                title: "Untitled",
                content: "",
                projectId: nil
            )
            notes.insert(note, at: 0)
            selectedNoteId = note.id
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
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
            
            if selectedNoteId == noteId {
                selectedNoteId = notes.first?.id
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
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
        }
    }
    
    func deleteProject(_ projectId: String) async {
        do {
            try await projectService.delete(id: projectId)
            projects.removeAll { $0.id == projectId }
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
        }
    }
    
    // MARK: - Search
    
    func searchNotes(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        do {
            let results = try await noteService.search(query: query)
            // You could update a @Published searchResults property here
            print("Found \(results.count) notes")
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
        }
    }
}
