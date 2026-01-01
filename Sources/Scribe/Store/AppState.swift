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
    @Published var notes: [Note] = [] {
        didSet {
            updateTagCounts()
        }
    }
    @Published var tagCounts: [String: Int] = [:]
    @Published var writingStats = WritingStats()
    @Published var isLoading = false
    @Published var error: ScribeError?
    @Published var citations: [Citation] = []
    
    // MARK: - Search State
    @Published var showCommandPalette = false
    @Published var searchQuery = ""
    @Published var searchResults: [Note] = []

    // MARK: - Services
    
    private let noteService: NoteService
    private let projectService: ProjectService
    private let searchDebouncer = Debouncer(delay: 0.3)
    private let linkUpdateDebouncer = Debouncer(delay: 1.0)
    
    init(
        noteService: NoteService,
        projectService: ProjectService
    ) {
        self.noteService = noteService
        self.projectService = projectService
        
        Task {
            await loadData()
            await loadCitations()
        }
    }

    // MARK: - Data Loading
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let projectsTask = projectService.fetchAll()
            async let notesTask = noteService.fetchAll(limit: 100, offset: 0)  // Initial batch
            
            projects = try await projectsTask
            notes = try await notesTask
            
            await ensureInbox()
            
            // Debug: Auto-open first note to trigger LexicalEditor initialization
            if let firstNote = notes.first {
                print("DEBUG: Auto-opening note '\(firstNote.title)'")
                openNote(firstNote)
            }
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
        }
    }
    
    func loadMoreNotes() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let moreNotes = try await noteService.fetchAll(
                projectId: selectedProjectId,
                includeDeleted: false,
                limit: 50,
                offset: notes.count
            )
            
            notes.append(contentsOf: moreNotes)
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
        }
    }
    
    func loadCitations() async {
        // For development, try Documents/Scribe/global.bib
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let bibPath = homeDir.appendingPathComponent("Documents/Scribe/global.bib").path
        
        if FileManager.default.fileExists(atPath: bibPath) {
            do {
                self.citations = try BibTeXService.shared.loadFromPath(bibPath)
            } catch {
                print("Failed to load citations: \(error)")
            }
        }
    }
    
    private func ensureInbox() async {
        // Check if an "Inbox" project already exists by name or stable ID
        if projects.contains(where: { $0.id == "system-inbox" || $0.name == "Inbox" }) {
            return
        }
        
        do {
            _ = try await projectService.create(
                name: "Inbox",
                description: "Quick capture zone",
                type: .generic
            )
            // Re-fetch projects to update local state
            projects = try await projectService.fetchAll()
        } catch {
            print("Failed to ensure inbox: \(error)")
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
                // Get old note for diff calculation
                let oldWordCount = notes.first(where: { $0.id == note.id })?.wordCount ?? 0
                
                try await noteService.save(note)
                
                // Update local state
                if let index = notes.firstIndex(where: { $0.id == note.id }) {
                    notes[index] = note
                }
                
                updateWritingStats(wordDiff: note.wordCount - oldWordCount)
                
                // Debounced link extraction
                await linkUpdateDebouncer.debounce {
                    try? await self.noteService.updateLinks(for: note)
                }
            } catch {
                self.error = error as? ScribeError ?? .unknown(error)
            }
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
            updateWritingStats(wordDiff: note.wordCount)
            return note
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
            throw error
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
    
    func searchNotes(query: String) async {
        self.searchQuery = query
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.searchResults = []
            return
        }
        
        await searchDebouncer.debounce {
            do {
                self.searchResults = try await self.noteService.search(query: self.searchQuery, projectId: self.selectedProjectId)
            } catch {
                self.error = error as? ScribeError ?? .unknown(error)
                self.searchResults = []
            }
        }
    }

    var uniqueTags: [String] {
        Array(tagCounts.keys).sorted()
    }
    
    // MARK: - Links
    
    func backlinks(for noteId: String) async -> [Note] {
        do {
            return try await noteService.backlinks(for: noteId)
        } catch {
            self.error = error as? ScribeError ?? .unknown(error)
            return []
        }
    }

    private func updateTagCounts() {
        var counts: [String: Int] = [:]
        for note in notes {
            for tag in note.tags {
                counts[tag, default: 0] += 1
            }
        }
        self.tagCounts = counts
    }
    
    private func updateWritingStats(wordDiff: Int) {
        guard wordDiff > 0 else { return }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Handle streak
        if let lastWrite = writingStats.lastWriteDate {
            if calendar.isDateInYesterday(lastWrite) {
                writingStats.streak += 1
                // Shift today's words to yesterday
                writingStats.wordsYesterday = writingStats.wordsToday
                writingStats.wordsToday = 0
            } else if !calendar.isDateInToday(lastWrite) {
                writingStats.streak = 1
                // Reset if longer streak break
                writingStats.wordsToday = 0
            }
        } else {
            writingStats.streak = 1
        }
        
        writingStats.lastWriteDate = now
        
        // Update words today
        writingStats.wordsToday += wordDiff
        writingStats.currentSessionWords += wordDiff
        
        // Update weekly stats (0 = Monday, 6 = Sunday)
        let weekday = calendar.component(.weekday, from: now) - 2  // Convert to 0-6
        let safeWeekday = max(0, min(6, weekday))
        writingStats.wordsThisWeek[safeWeekday] += wordDiff
    }

    // MARK: - Academic Workflow

    func filteredCitations(query: String) -> [Citation] {
        guard !query.isEmpty else { return citations }
        let lowQuery = query.lowercased()
        return citations.filter { 
            $0.id.lowercased().contains(lowQuery) || 
            $0.title.lowercased().contains(lowQuery) ||
            $0.author.lowercased().contains(lowQuery)
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
    var wordsYesterday: Int = 0
    var wordsThisWeek: [Int] = [0, 0, 0, 0, 0, 0, 0]  // Mon-Sun
    var sessionStart: Date? = Date()
    var weeklyGoal: Int = 5000
    var lastWriteDate: Date?
    var currentSessionWords: Int = 0
    
    var sessionDuration: TimeInterval {
        guard let start = sessionStart else { return 0 }
        return Date().timeIntervalSince(start)
    }
    
    var weeklyTotal: Int {
        wordsThisWeek.reduce(0, +)
    }
    
    var weeklyProgress: Double {
        Double(weeklyTotal) / Double(weeklyGoal)
    }
}
