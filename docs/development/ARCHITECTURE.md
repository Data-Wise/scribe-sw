# Scribe Native - Architecture Design

**Version:** 2.0  
**Swift:** 5.9+ (Swift 6 ready)  
**Paradigm:** Clean Architecture (pragmatic)  
**Concurrency:** Actor-based + async/await

---

## Design Philosophy

### 1. Modern Swift First

- ✅ Swift 6 concurrency model
- ✅ `@Observable` for state (not `ObservableObject`)
- ✅ `actor` for thread-safe database
- ✅ Strong typing, minimal `Any`
- ✅ Value types where possible

### 2. Pragmatic Layering

**Three layers, clean boundaries:**

```
Presentation → Domain → Data
```

**Not five layers with repositories, use cases, etc.** Too complex for a single-developer app.

### 3. Performance Critical

- Lazy loading for large note lists
- Incremental markdown parsing
- Background database operations
- Efficient SwiftUI updates (minimize @Published)

### 4. Error Handling

- Custom error types
- `Result<T, Error>` for fallible operations
- No silent failures
- User-facing error messages

---

## Layer Architecture

### Overview

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  ┌────────────┐      ┌──────────────┐  │
│  │  Views     │ ───▶ │  ViewModels  │  │
│  │ (SwiftUI)  │      │ (@Observable)│  │
│  └────────────┘      └──────┬───────┘  │
└─────────────────────────────┼───────────┘
                              │
┌─────────────────────────────▼───────────┐
│           Domain Layer                  │
│  ┌────────────────────────────────────┐ │
│  │  Models (Note, Project, Link)      │ │
│  │  Services (NoteService, etc.)      │ │
│  └────────────────┬───────────────────┘ │
└─────────────────── │─────────────────────┘
                     │
┌────────────────────▼─────────────────────┐
│          Data Layer                      │
│  ┌──────────────────────────────────────┐│
│  │  DatabaseManager (actor)             ││
│  │  GRDB + SQLite                       ││
│  └──────────────────────────────────────┘│
└──────────────────────────────────────────┘
```

---

## Presentation Layer

### Views (SwiftUI)

**Pure declarative UI. No business logic.**

```swift
struct NoteEditorView: View {
    @Environment(EditorViewModel.self) private var viewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                EditorContent(note: viewModel.currentNote)
            }
        }
        .task {
            await viewModel.loadNote()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            // Error handling
        }
    }
}
```

### ViewModels (@Observable)

**State container + presentation logic.**

Use `@Observable` macro (iOS 17+, macOS 14+) instead of `ObservableObject`:

```swift
import Observation

@Observable
@MainActor
final class EditorViewModel {
    // MARK: - State
    
    private(set) var currentNote: Note?
    private(set) var isLoading = false
    private(set) var showError = false
    private(set) var errorMessage = ""
    
    // MARK: - Dependencies
    
    private let noteService: NoteService
    
    init(noteService: NoteService = .shared) {
        self.noteService = noteService
    }
    
    // MARK: - Actions
    
    func loadNote(id: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            currentNote = try await noteService.fetch(id: id)
        } catch {
            handleError(error)
        }
    }
    
    func saveNote(_ content: String) async {
        guard var note = currentNote else { return }
        
        note.content = content
        note.updatedAt = Date().unixTimestamp
        
        do {
            try await noteService.save(note)
            currentNote = note
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
```

**Benefits of @Observable:**

- Auto-tracks property access (no `@Published` needed)
- Better performance (only re-renders when accessed properties change)
- Cleaner syntax

---

## Domain Layer

### Models (Value Types)

**Immutable data structures.**

```swift
struct Note: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var projectId: String?
    var title: String
    var content: String
    var folder: String
    var metadata: NoteMetadata?
    var createdAt: Int64
    var updatedAt: Int64
    var deletedAt: Int64?
    
    // Computed properties
    var isDeleted: Bool { deletedAt != nil }
    var wordCount: Int { /* ... */ }
    var date: Date { Date(unixTimestamp: createdAt) }
}

struct NoteMetadata: Codable, Hashable, Sendable {
    var tags: [String] = []
    var aliases: [String] = []
    var properties: [String: String] = [:]
    var isDaily: Bool = false
    var isPinned: Bool = false
}

// MARK: - Sendable Conformance
// All models must be Sendable for Swift 6 concurrency
```

### Services (Business Logic)

**Stateless operations on models.**

```swift
import Foundation

@MainActor
final class NoteService {
    static let shared = NoteService()
    
    private let database: DatabaseManager
    
    init(database: DatabaseManager = .shared) {
        self.database = database
    }
    
    // MARK: - CRUD Operations
    
    func fetch(id: String) async throws -> Note {
        try await database.fetchNote(id: id)
    }
    
    func fetchAll(projectId: String? = nil, includeDeleted: Bool = false) async throws -> [Note] {
        try await database.fetchNotes(projectId: projectId, includeDeleted: includeDeleted)
    }
    
    func save(_ note: Note) async throws {
        try await database.saveNote(note)
    }
    
    func delete(id: String, permanent: Bool = false) async throws {
        try await database.deleteNote(id: id, permanent: permanent)
    }
    
    // MARK: - Search
    
    func search(query: String) async throws -> [Note] {
        try await database.searchNotes(query: query)
    }
    
    // MARK: - Links
    
    func backlinks(for noteId: String) async throws -> [Note] {
        try await database.fetchBacklinks(for: noteId)
    }
    
    func extractWikiLinks(from content: String) -> [String] {
        let pattern = #"\[\[([^\]]+)\]\]"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
        
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return String(content[range])
        }
    }
}
```

---

## Data Layer

### DatabaseManager (Actor)

**Thread-safe database access.**

```swift
import Foundation
import GRDB

actor DatabaseManager {
    static let shared = DatabaseManager()
    
    private let dbQueue: DatabaseQueue
    private let migrator: DatabaseMigrator
    
    // MARK: - Initialization
    
    init() {
        do {
            let fileManager = FileManager.default
            let appSupport = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            
            let dbDirectory = appSupport.appendingPathComponent("Scribe")
            try fileManager.createDirectory(at: dbDirectory, withIntermediateDirectories: true)
            
            let dbPath = dbDirectory.appendingPathComponent("scribe.sqlite")
            
            var config = Configuration()
            config.prepareDatabase { db in
                db.trace { print("SQL: \($0)") }
            }
            
            self.dbQueue = try DatabaseQueue(path: dbPath.path, configuration: config)
            self.migrator = Self.createMigrator()
            
            try migrator.migrate(dbQueue)
        } catch {
            fatalError("Failed to initialize database: \(error)")
        }
    }
    
    // MARK: - Migrations
    
    private static func createMigrator() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        // Migration v1: Core schema
        migrator.registerMigration("v1") { db in
            try db.create(table: "projects") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("type", .text).notNull()
                t.column("color", .text)
                t.column("icon", .text)
                t.column("settings", .text)
                t.column("created_at", .integer).notNull()
                t.column("updated_at", .integer).notNull()
            }
            
            try db.create(table: "notes") { t in
                t.primaryKey("id", .text)
                t.column("project_id", .text)
                    .references("projects", onDelete: .setNull)
                t.column("title", .text).notNull()
                t.column("content", .text).notNull().defaults(to: "")
                t.column("folder", .text).notNull().defaults(to: "inbox")
                t.column("metadata", .text)
                t.column("created_at", .integer).notNull()
                t.column("updated_at", .integer).notNull()
                t.column("deleted_at", .integer)
            }
            
            try db.create(index: "idx_notes_project", on: "notes", columns: ["project_id"])
            try db.create(index: "idx_notes_updated", on: "notes", columns: ["updated_at"])
        }
        
        // Migration v2: Links & FTS
        migrator.registerMigration("v2") { db in
            try db.create(table: "links") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("source_note_id", .text).notNull()
                t.column("target_note_id", .text).notNull()
                t.column("link_type", .text).notNull().defaults(to: "wiki")
                t.column("created_at", .integer).notNull()
                t.uniqueKey(["source_note_id", "target_note_id", "link_type"])
            }
            
            try db.create(virtualTable: "notes_fts", using: FTS5()) { t in
                t.column("note_id")
                t.column("title")
                t.column("content")
            }
        }
        
        return migrator
    }
    
    // MARK: - Notes CRUD
    
    func fetchNote(id: String) throws -> Note {
        try dbQueue.read { db in
            try Note.fetchOne(db, key: id) ?? {
                throw DatabaseError.noteNotFound(id)
            }()
        }
    }
    
    func fetchNotes(projectId: String? = nil, includeDeleted: Bool = false) throws -> [Note] {
        try dbQueue.read { db in
            var query = Note.all()
            
            if !includeDeleted {
                query = query.filter(Column("deleted_at") == nil)
            }
            
            if let projectId {
                query = query.filter(Column("project_id") == projectId)
            }
            
            return try query
                .order(Column("updated_at").desc)
                .fetchAll(db)
        }
    }
    
    func saveNote(_ note: Note) throws {
        try dbQueue.write { db in
            try note.save(db)
        }
    }
    
    func deleteNote(id: String, permanent: Bool) throws {
        try dbQueue.write { db in
            if permanent {
                try Note.deleteOne(db, key: id)
            } else {
                try db.execute(
                    sql: "UPDATE notes SET deleted_at = ? WHERE id = ?",
                    arguments: [Date().unixTimestamp, id]
                )
            }
        }
    }
    
    // MARK: - Search
    
    func searchNotes(query: String) throws -> [Note] {
        try dbQueue.read { db in
            let pattern = FTS5Pattern(matchingAllTokensIn: query)
            let noteIds = try String.fetchAll(db,
                sql: "SELECT note_id FROM notes_fts WHERE notes_fts MATCH ?",
                arguments: [pattern])
            
            return try Note
                .filter(noteIds.contains(Column("id")))
                .filter(Column("deleted_at") == nil)
                .fetchAll(db)
        }
    }
    
    // MARK: - Links
    
    func fetchBacklinks(for noteId: String) throws -> [Note] {
        try dbQueue.read { db in
            try Note.fetchAll(db,
                sql: """
                SELECT n.* FROM notes n
                JOIN links l ON n.id = l.source_note_id
                WHERE l.target_note_id = ? AND l.link_type = 'wiki'
                ORDER BY l.created_at DESC
                """,
                arguments: [noteId])
        }
    }
}

// MARK: - Errors

enum DatabaseError: LocalizedError {
    case noteNotFound(String)
    case projectNotFound(String)
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .noteNotFound(let id):
            return "Note not found: \(id)"
        case .projectNotFound(let id):
            return "Project not found: \(id)"
        case .invalidData:
            return "Invalid database data"
        }
    }
}
```

---

## GRDB Integration

### FetchableRecord & PersistableRecord

```swift
extension Note: FetchableRecord, PersistableRecord {
    static let databaseTableName = "notes"
    
    enum Columns {
        static let id = Column("id")
        static let projectId = Column("project_id")
        static let title = Column("title")
        static let content = Column("content")
        static let folder = Column("folder")
        static let metadata = Column("metadata")
        static let createdAt = Column("created_at")
        static let updatedAt = Column("updated_at")
        static let deletedAt = Column("deleted_at")
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, folder, metadata
        case projectId = "project_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// Custom JSON encoding for metadata
extension Note {
    private static let jsonEncoder = JSONEncoder()
    private static let jsonDecoder = JSONDecoder()
    
    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["project_id"] = projectId
        container["title"] = title
        container["content"] = content
        container["folder"] = folder
        container["created_at"] = createdAt
        container["updated_at"] = updatedAt
        container["deleted_at"] = deletedAt
        
        if let metadata {
            let data = try Self.jsonEncoder.encode(metadata)
            container["metadata"] = String(data: data, encoding: .utf8)
        }
    }
}
```

---

## Dependency Injection

### Protocol for Testing

```swift
protocol NoteRepository {
    func fetch(id: String) async throws -> Note
    func fetchAll() async throws -> [Note]
    func save(_ note: Note) async throws
    func delete(id: String) async throws
}

// Production implementation
actor GRDBNoteRepository: NoteRepository {
    private let database: DatabaseManager
    
    init(database: DatabaseManager = .shared) {
        self.database = database
    }
    
    func fetch(id: String) async throws -> Note {
        try await database.fetchNote(id: id)
    }
    
    // ... other methods
}

// Mock for testing
final class MockNoteRepository: NoteRepository {
    var notes: [Note] = []
    
    func fetch(id: String) async throws -> Note {
        notes.first { $0.id == id } ?? {
            throw DatabaseError.noteNotFound(id)
        }()
    }
    
    // ... other methods
}
```

### Dependency Container

```swift
@MainActor
final class Dependencies {
    static let shared = Dependencies()
    
    let noteService: NoteService
    let projectService: ProjectService
    
    private init() {
        self.noteService = NoteService()
        self.projectService = ProjectService()
    }
    
    // For testing
    static func mock(
        noteService: NoteService? = nil,
        projectService: ProjectService? = nil
    ) -> Dependencies {
        Dependencies(
            noteService: noteService ?? NoteService(),
            projectService: projectService ?? ProjectService()
        )
    }
}
```

---

## Error Handling Strategy

### Custom Error Types

```swift
enum ScribeError: LocalizedError {
    case database(DatabaseError)
    case network(URLError)
    case invalidInput(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .database(let error):
            return "Database error: \(error.localizedDescription)"
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidInput(let message):
            return message
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .database:
            return "Please restart the app. Contact support if the problem persists."
        case .network:
            return "Check your internet connection and try again."
        case .invalidInput:
            return "Please check your input and try again."
        case .unknown:
            return "Please try again or restart the app."
        }
    }
}
```

### Result Type Pattern

```swift
extension NoteService {
    func fetchSafely(id: String) async -> Result<Note, ScribeError> {
        do {
            let note = try await fetch(id: id)
            return .success(note)
        } catch let error as DatabaseError {
            return .failure(.database(error))
        } catch {
            return .failure(.unknown(error))
        }
    }
}
```

---

## Testing Strategy

### Unit Tests

```swift
import Testing
@testable import Scribe

@Suite("Note Service Tests")
struct NoteServiceTests {
    @Test("Fetch note by ID")
    func testFetchNote() async throws {
        let mockDB = MockDatabaseManager()
        let service = NoteService(database: mockDB)
        
        let note = Note(id: "test-1", title: "Test Note")
        mockDB.notes = [note]
        
        let fetched = try await service.fetch(id: "test-1")
        #expect(fetched.id == "test-1")
        #expect(fetched.title == "Test Note")
    }
    
    @Test("Search notes")
    func testSearch() async throws {
        let mockDB = MockDatabaseManager()
        let service = NoteService(database: mockDB)
        
        mockDB.notes = [
            Note(id: "1", title: "Swift Programming", content: "Learn Swift"),
            Note(id: "2", title: "Python Guide", content: "Learn Python")
        ]
        
        let results = try await service.search(query: "Swift")
        #expect(results.count == 1)
        #expect(results.first?.title == "Swift Programming")
    }
}
```

---

## Performance Optimizations

### 1. Lazy Loading

```swift
@Observable
@MainActor
final class NotesListViewModel {
    private(set) var notes: [Note] = []
    private let pageSize = 50
    private var currentPage = 0
    
    func loadMoreIfNeeded(currentItem: Note?) async {
        guard let currentItem,
              let index = notes.firstIndex(where: { $0.id == currentItem.id }),
              index >= notes.count - 10  // Load 10 items before end
        else { return }
        
        await loadNextPage()
    }
    
    private func loadNextPage() async {
        // Fetch next page from database
    }
}
```

### 2. Debounced Search

```swift
import Combine

@Observable
@MainActor
final class SearchViewModel {
    var searchText = "" {
        didSet { scheduleSearch() }
    }
    private(set) var results: [Note] = []
    
    private var searchTask: Task<Void, Never>?
    
    private func scheduleSearch() {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))  // Debounce
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }
}
```

---

## Swift 6 Concurrency Safety

### Sendable Types

```swift
// All data models must be Sendable
struct Note: Sendable { /* ... */ }
struct Project: Sendable { /* ... */ }

// Actors are inherently thread-safe
actor DatabaseManager { /* ... */ }

// MainActor for UI
@MainActor
final class EditorViewModel { /* ... */ }
```

### No Data Races

```swift
// ❌ Wrong: Shared mutable state
class BadService {
    var cache: [String: Note] = [:]  // Data race!
}

// ✅ Correct: Actor-isolated state
actor GoodService {
    private var cache: [String: Note] = [:]  // Safe
}

// ✅ Correct: Immutable state
@MainActor
final class ViewModel {
    private(set) var notes: [Note] = []  // Immutable from outside
}
```

---

## Summary: Architecture Principles

1. **Three clean layers** - Presentation, Domain, Data
2. **Modern Swift** - @Observable, actors, async/await
3. **Value types** - Structs for models, Sendable conformance
4. **Protocol-oriented** - Only where needed for testing
5. **Error handling** - Custom types, Result pattern, user-friendly messages
6. **Performance** - Lazy loading, debouncing, efficient queries
7. **Swift 6 ready** - No data races, proper concurrency

**This architecture is production-ready, testable, and maintainable.**
