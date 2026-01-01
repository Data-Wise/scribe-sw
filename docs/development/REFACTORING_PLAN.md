# Refactoring Implementation Plan

**Priority:** CRITICAL  
**Est. Time:** 40-60 hours  
**Blocking:** All feature development

---

## Overview

This plan addresses the critical issues identified in `ARCHITECTURE_REVIEW.md` through systematic refactoring.

---

## Phase 1: Schema Alignment (8-12 hours)

### Step 1.1: Rename Models (4h)

**Files to modify:**

- `Sources/Scribe/Models/Page.swift` → `Note.swift`
- `Sources/Scribe/Models/Vault.swift` → `Project.swift`

**Changes:**

```swift
// Before
struct Page { ... }
struct Vault { ... }

// After  
struct Note: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var title: String
    var content: String
    var projectId: String?
    // ... match database-schema.md exactly
    
    static let databaseTableName = "notes"
}

struct Project: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var type: ProjectType
    // ... match database-schema.md
    
    static let databaseTableName = "projects"
}
```

**Search and replace:**

```bash
# Find all references
rg "Page" --type swift
rg "Vault" --type swift

# Update systematically:
# AppState: pages → notes, vaults → projects
# Views: Change all property names
# DatabaseService: Update method names
```

### Step 1.2: Add Missing Models (2h)

Create models matching schema:

- `Sources/Scribe/Models/Tag.swift`
- `Sources/Scribe/Models/Link.swift`
- `Sources/Scribe/Models/ChatSession.swift`
- `Sources/Scribe/Models/ChatMessage.swift`

### Step 1.3: Update AppState (2h)

```swift
@MainActor
final class AppState: ObservableObject {
    // Rename all properties
    @Published var notes: [Note] = []
    @Published var projects: [Project] = []
    @Published var selectedProjectId: String?
    @Published var selectedNoteId: String?
    
    // Add error handling
    @Published var error: ScribeError?
    @Published var isLoading = false
}
```

---

## Phase 2: Database Layer (12-16 hours)

### Step 2.1: Create Error Types (1h)

```swift
// Sources/Scribe/Core/ScribeError.swift
enum ScribeError: Error, LocalizedError {
    case databaseConnectionFailed
    case databaseMigrationFailed(underlying: Error)
    case noteNotFound(String)
    case projectNotFound(String)
    case invalidData
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .databaseConnectionFailed:
            return "Failed to connect to database"
        case .databaseMigrationFailed(let error):
            return "Database migration failed: \\(error.localizedDescription)"
        case .noteNotFound(let id):
            return "Note not found: \\(id)"
        case .projectNotFound(let id):
            return "Project not found: \\(id)"
        case .invalidData:
            return "Invalid data format"
        case .permissionDenied:
            return "Permission denied"
        }
    }
}
```

### Step 2.2: Implement Migrations (4h)

```swift
// Sources/Scribe/Database/Migrations.swift
import GRDB

struct Migrations {
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        // Migration 001: Core tables
        migrator.registerMigration("001_core_tables") { db in
            try db.create(table: "notes") { t in
                t.primaryKey("id", .text)
                t.column("title", .text).notNull()
                t.column("content", .text).defaults(to: "")
                t.column("folder", .text).defaults(to: "inbox")
                t.column("project_id", .text)
                    .references("projects", onDelete: .setNull)
                t.column("properties", .text)
                t.column("created_at", .integer).notNull()
                t.column("updated_at", .integer).notNull()
                t.column("deleted_at", .integer)
            }
            
            try db.create(table: "projects") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("type", .text).notNull()
                    .check(sql: "type IN ('research', 'teaching', 'r-package', 'r-dev', 'generic')")
                t.column("color", .text)
                t.column("settings", .text)
                t.column("created_at", .integer).notNull()
                t.column("updated_at", .integer).notNull()
            }
            
            // Indexes
            try db.create(index: "idx_notes_project", on: "notes", columns: ["project_id"])
            try db.create(index: "idx_notes_updated", on: "notes", columns: ["updated_at"])
        }
        
        // Migration 002: Tags
        migrator.registerMigration("002_tags") { db in
            try db.create(table: "tags") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull().unique()
                t.column("color", .text)
                t.column("created_at", .integer).notNull()
            }
            
            try db.create(table: "note_tags") { t in
                t.column("note_id", .text).notNull()
                    .references("notes", onDelete: .cascade)
                t.column("tag_id", .text).notNull()
                    .references("tags", onDelete: .cascade)
                t.column("created_at", .integer).notNull()
                t.primaryKey(["note_id", "tag_id"])
            }
        }
        
        // Migration 003: Links
        migrator.registerMigration("003_links") { db in
            try db.create(table: "links") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("source_note_id", .text).notNull()
                    .references("notes", onDelete: .cascade)
                t.column("target_note_id", .text).notNull()
                    .references("notes", onDelete: .cascade)
                t.column("created_at", .integer).notNull()
                t.uniqueKey(["source_note_id", "target_note_id"])
            }
        }
        
        // Migration 004: FTS5
        migrator.registerMigration("004_fts5") { db in
            try db.create(virtualTable: "notes_fts", using: FTS5()) { t in
                t.column("note_id")
                t.column("title")
                t.column("content")
                t.column("properties")
            }
            
            // Triggers
            try db.execute(sql: """
                CREATE TRIGGER notes_ai AFTER INSERT ON notes BEGIN
                    INSERT INTO notes_fts(note_id, title, content, properties)
                    VALUES (new.id, new.title, new.content, COALESCE(new.properties, ''));
                END
                """)
        }
        
        return migrator
    }
}
```

### Step 2.3: Rewrite DatabaseService (7h)

```swift
// Sources/Scribe/Database/DatabaseService.swift
import Foundation
import GRDB

actor DatabaseService {
    private let dbQueue: DatabaseQueue
    
    init() throws {
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
            db.trace { print("SQL: \\($0)") }
        }
        
        dbQueue = try DatabaseQueue(path: dbPath.path, configuration: config)
        try Migrations.migrator.migrate(dbQueue)
    }
    
    // MARK: - Notes
    
    func fetchNotes(projectId: String? = nil) throws -> [Note] {
        try dbQueue.read { db in
            var query = Note.filter(Column("deleted_at") == nil)
            
            if let projectId {
                query = query.filter(Column("project_id") == projectId)
            }
            
            return try query
                .order(Column("updated_at").desc)
                .fetchAll(db)
        }
    }
    
    func fetchNote(id: String) throws -> Note? {
        try dbQueue.read { db in
            try Note.fetchOne(db, key: id)
        }
    }
    
    func saveNote(_ note: Note) throws {
        try dbQueue.write { db in
            var mutableNote = note
            mutableNote.updatedAt = Int64(Date().timeIntervalSince1970)
            try mutableNote.save(db)
        }
    }
    
    func deleteNote(id: String, permanent: Bool = false) throws {
        try dbQueue.write { db in
            if permanent {
                try Note.deleteOne(db, key: id)
            } else {
                try db.execute(
                    sql: "UPDATE notes SET deleted_at = ? WHERE id = ?",
                    arguments: [Int64(Date().timeIntervalSince1970), id]
                )
            }
        }
    }
    
    // MARK: - Search
    
    func searchNotes(query: String) throws -> [Note] {
        try dbQueue.read { db in
            let pattern = FTS5Pattern(matchingAllTokensIn: query)
            let noteIds = try String.fetchAll(db,
                sql: """
                    SELECT note_id FROM notes_fts 
                    WHERE notes_fts MATCH ?
                    """,
                arguments: [pattern])
            
            return try Note
                .filter(noteIds.contains(Column("id")))
                .filter(Column("deleted_at") == nil)
                .order(sql: "rank")
                .fetchAll(db)
        }
    }
}
```

---

## Phase 3: Architecture Patterns (12-16 hours)

### Step 3.1: Repository Protocol (2h)

```swift
// Sources/Scribe/Domain/Repositories/NoteRepository.swift
protocol NoteRepository {
    func fetchAll(projectId: String?) async throws -> [Note]
    func fetch(id: String) async throws -> Note?
    func save(_ note: Note) async throws
    func delete(id: String, permanent: Bool) async throws
    func search(query: String) async throws -> [Note]
}

// Sources/Scribe/Data/Repositories/GRDBNoteRepository.swift
actor GRDBNoteRepository: NoteRepository {
    private let db: DatabaseService
    
    init(database: DatabaseService) {
        self.db = database
    }
    
    func fetchAll(projectId: String? = nil) async throws -> [Note] {
        try await db.fetchNotes(projectId: projectId)
    }
    
    func fetch(id: String) async throws -> Note? {
        try await db.fetchNote(id: id)
    }
    
    func save(_ note: Note) async throws {
        try await db.saveNote(note)
    }
    
    func delete(id: String, permanent: Bool = false) async throws {
        try await db.deleteNote(id: id, permanent: permanent)
    }
    
    func search(query: String) async throws -> [Note] {
        try await db.searchNotes(query: query)
    }
}
```

### Step 3.2: Dependency Container (3h)

```swift
// Sources/Scribe/Core/DependencyContainer.swift
@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()
    
    private(set) lazy var database: DatabaseService = {
        do {
            return try DatabaseService()
        } catch {
            fatalError("Failed to initialize database: \\(error)")
        }
    }()
    
    private(set) lazy var noteRepository: NoteRepository = {
        GRDBNoteRepository(database: database)
    }()
    
    private(set) lazy var projectRepository: ProjectRepository = {
        GRDBProjectRepository(database: database)
    }()
    
    private(set) lazy var appState: AppState = {
        AppState(
            noteRepository: noteRepository,
            projectRepository: projectRepository
        )
    }()
}
```

### Step 3.3: Refactor AppState (7h)

```swift
@MainActor
final class AppState: ObservableObject {
    @Published var notes: [Note] = []
    @Published var projects: [Project] = []
    @Published var selectedProjectId: String?
    @Published var selectedNoteId: String?
    @Published var error: ScribeError?
    @Published var isLoading = false
    
    private let noteRepository: NoteRepository
    private let projectRepository: ProjectRepository
    
    init(
        noteRepository: NoteRepository,
        projectRepository: ProjectRepository
    ) {
        self.noteRepository = noteRepository
        self.projectRepository = projectRepository
        
        Task { await loadData() }
    }
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let notesTask = noteRepository.fetchAll(projectId: selectedProjectId)
            async let projectsTask = projectRepository.fetchAll()
            
            notes = try await notesTask
            projects = try await projectsTask
        } catch {
            self.error = error as? ScribeError ?? .invalidData
        }
    }
    
    func createNote(title: String) async {
        let note = Note(
            id: UUID().uuidString.lowercased(),
            title: title,
            content: "",
            projectId: selectedProjectId,
            createdAt: Int64(Date().timeIntervalSince1970),
            updatedAt: Int64(Date().timeIntervalSince1970)
        )
        
        do {
            try await noteRepository.save(note)
            await loadData()
        } catch {
            self.error = error as? ScribeError ?? .invalidData
        }
    }
}
```

---

## Phase 4: Testing Infrastructure (8-12 hours)

### Step 4.1: Mock Repositories (3h)

```swift
// Tests/ScribeTests/Mocks/MockNoteRepository.swift
actor MockNoteRepository: NoteRepository {
    var notesToReturn: [Note] = []
    var noteToReturn: Note?
    var saveWasCalled = false
    var deleteWasCalled = false
    var searchQuery: String?
    
    func fetchAll(projectId: String?) async throws -> [Note] {
        notesToReturn.filter { note in
            projectId == nil || note.projectId == projectId
        }
    }
    
    func fetch(id: String) async throws -> Note? {
        noteToReturn
    }
    
    func save(_ note: Note) async throws {
        saveWasCalled = true
    }
    
    func delete(id: String, permanent: Bool) async throws {
        deleteWasCalled = true
    }
    
    func search(query: String) async throws -> [Note] {
        searchQuery = query
        return notesToReturn
    }
}
```

### Step 4.2: Unit Tests (5h)

```swift
// Tests/ScribeTests/AppStateTests.swift
import Testing
@testable import Scribe

@Suite("AppState Tests")
struct AppStateTests {
    @Test("Create note saves to repository")
    func testCreateNote() async throws {
        let mockRepo = MockNoteRepository()
        let state = AppState(
            noteRepository: mockRepo,
            projectRepository: MockProjectRepository()
        )
        
        await state.createNote(title: "Test Note")
        
        #expect(await mockRepo.saveWasCalled == true)
    }
    
    @Test("Load data fetches from repository")
    func testLoadData() async throws {
        let mockRepo = MockNoteRepository()
        await mockRepo.setNotesToReturn([
            Note(id: "1", title: "Note 1", ...)
        ])
        
        let state = AppState(
            noteRepository: mockRepo,
            projectRepository: MockProjectRepository()
        )
        
        await state.loadData()
        
        #expect(state.notes.count == 1)
        #expect(state.notes[0].title == "Note 1")
    }
}
```

---

## Phase 5: Documentation (4-6 hours)

### Step 5.1: Architecture Diagrams (2h)

Create `docs/development/ARCHITECTURE.md` with:

- Component diagram
- Data flow diagram
- Dependency graph

### Step 5.2: Code Examples (2h)

Update docs with real code:

- `docs/development/swift-guide.md`
- `docs/reference/database-schema.md`

### Step 5.3: Migration Guide (2h)

Document breaking changes:

- `docs/development/MIGRATION.md`

---

## Validation Checklist

After refactoring:

- [ ] All models match `database-schema.md`
- [ ] `swift build` succeeds
- [ ] `swift test` passes
- [ ] No compiler warnings
- [ ] Database migrations run successfully
- [ ] Can create/read/update/delete notes
- [ ] Full-text search works
- [ ] Error handling tested
- [ ] Mock repositories work in tests

---

## Timeline

| Phase | Hours | Days @ 4h/day |
|-------|-------|---------------|
| Phase 1: Schema Alignment | 8-12 | 2-3 |
| Phase 2: Database Layer | 12-16 | 3-4 |
| Phase 3: Architecture | 12-16 | 3-4 |
| Phase 4: Testing | 8-12 | 2-3 |
| Phase 5: Documentation | 4-6 | 1-2 |
| **Total** | **44-62** | **11-16** |

---

## Risk Mitigation

1. **Create branch:** `git checkout -b refactor/architecture`
2. **Small commits:** Commit after each step
3. **Run tests frequently:** After each file change
4. **Keep builds green:** Never commit broken code
5. **Document decisions:** Update ARCHITECTURE.md as you go

---

**Start with Phase 1, Step 1.1 first.**
