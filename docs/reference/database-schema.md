# Scribe Native - Database Schema

**Version:** 1.0  
**Engine:** SQLite via GRDB  
**Location:** `~/Library/Application Support/Scribe/scribe.sqlite`

---

## Design Principles

1. **Native-first** - Optimized for Swift/GRDB, not Tauri compatibility
2. **Simple** - Fewer tables, more computed properties
3. **Flexible** - JSON for extensibility
4. **Fast** - Proper indexes, FTS5 search
5. **Safe** - Foreign keys, soft deletes

---

## Core Tables

### projects

Top-level containers (Research, Teaching, etc.)

```sql
CREATE TABLE projects (
    id TEXT PRIMARY KEY,                    -- UUID string
    name TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL                      -- 'research', 'teaching', 'r-package', 'r-dev', 'generic'
        CHECK(type IN ('research', 'teaching', 'r-package', 'r-dev', 'generic')),
    color TEXT,                             -- Hex color (optional)
    icon TEXT,                              -- SF Symbol name
    settings TEXT,                          -- JSON blob for project-specific config
    created_at INTEGER NOT NULL,            -- Unix timestamp
    updated_at INTEGER NOT NULL,
    
    CHECK(length(id) > 0),
    CHECK(length(name) > 0)
);

CREATE INDEX idx_projects_type ON projects(type);
CREATE INDEX idx_projects_updated ON projects(updated_at DESC);
```

**Swift Model:**

```swift
struct Project: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var description: String?
    var type: ProjectType
    var color: String?
    var icon: String?
    var settings: ProjectSettings?  // Decoded from JSON
    var createdAt: Int64
    var updatedAt: Int64
}

enum ProjectType: String, Codable {
    case research, teaching, rPackage = "r-package", rDev = "r-dev", generic
}

struct ProjectSettings: Codable {
    var bibliography: String?
    var citationStyle: String?
    var exportTemplate: String?
    var aiContext: String?
}
```

---

### notes

Individual documents/pages

```sql
CREATE TABLE notes (
    id TEXT PRIMARY KEY,
    project_id TEXT
        REFERENCES projects(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL DEFAULT '',
    folder TEXT NOT NULL DEFAULT 'inbox',   -- Folder within project
    metadata TEXT,                          -- JSON: tags, frontmatter, etc.
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER,                     -- Soft delete
    
    CHECK(length(id) > 0),
    CHECK(length(title) > 0)
);

CREATE INDEX idx_notes_project ON notes(project_id);
CREATE INDEX idx_notes_folder ON notes(folder);
CREATE INDEX idx_notes_updated ON notes(updated_at DESC);
CREATE INDEX idx_notes_deleted ON notes(deleted_at) WHERE deleted_at IS NOT NULL;
```

**Swift Model:**

```swift
struct Note: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var projectId: String?
    var title: String
    var content: String
    var folder: String
    var metadata: NoteMetadata?  // Decoded from JSON
    var createdAt: Int64
    var updatedAt: Int64
    var deletedAt: Int64?
}

struct NoteMetadata: Codable {
    var tags: [String]?
    var aliases: [String]?
    var properties: [String: String]?  // YAML frontmatter
    var isDaily: Bool?
    var isPinned: Bool?
}
```

---

### links

Wiki-style bidirectional links between notes

```sql
CREATE TABLE links (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_note_id TEXT NOT NULL
        REFERENCES notes(id) ON DELETE CASCADE,
    target_note_id TEXT NOT NULL
        REFERENCES notes(id) ON DELETE CASCADE,
    link_type TEXT NOT NULL DEFAULT 'wiki'  -- 'wiki', 'cite', 'embed'
        CHECK(link_type IN ('wiki', 'cite', 'embed')),
    created_at INTEGER NOT NULL,
    
    UNIQUE(source_note_id, target_note_id, link_type)
);

CREATE INDEX idx_links_source ON links(source_note_id);
CREATE INDEX idx_links_target ON links(target_note_id);
CREATE INDEX idx_links_type ON links(link_type);
```

**Swift Model:**

```swift
struct Link: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var sourceNoteId: String
    var targetNoteId: String
    var linkType: LinkType
    var createdAt: Int64
}

enum LinkType: String, Codable {
    case wiki      // [[note]]
    case cite      // @cite
    case embed     // ![[note]]
}
```

---

### tags

Tag definitions (optional colors)

```sql
CREATE TABLE tags (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE COLLATE NOCASE,
    color TEXT,
    created_at INTEGER NOT NULL,
    
    CHECK(name GLOB '#*')  -- Must start with #
);

CREATE INDEX idx_tags_name ON tags(name COLLATE NOCASE);
```

**Swift Model:**

```swift
struct Tag: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String  // Includes #
    var color: String?
    var createdAt: Int64
}
```

**Note:** Tags are stored in `notes.metadata` JSON. This table is for tag definitions and colors.

---

### notes_fts

Full-text search virtual table

```sql
CREATE VIRTUAL TABLE notes_fts USING fts5(
    note_id UNINDEXED,
    title,
    content,
    metadata,
    content='',         -- External content table
    content_rowid='id'
);

-- Triggers to keep FTS in sync
CREATE TRIGGER notes_ai AFTER INSERT ON notes BEGIN
    INSERT INTO notes_fts(rowid, note_id, title, content, metadata)
    VALUES (new.rowid, new.id, new.title, new.content, COALESCE(new.metadata, ''));
END;

CREATE TRIGGER notes_au AFTER UPDATE ON notes BEGIN
    UPDATE notes_fts 
    SET title = new.title, 
        content = new.content, 
        metadata = COALESCE(new.metadata, '')
    WHERE note_id = old.id;
END;

CREATE TRIGGER notes_ad AFTER DELETE ON notes BEGIN
    DELETE FROM notes_fts WHERE note_id = old.id;
END;
```

**Usage:**

```swift
// Search notes
let pattern = FTS5Pattern(matchingAllTokensIn: "mediation analysis")
let noteIds = try db.read { db in
    try String.fetchAll(db,
        sql: "SELECT note_id FROM notes_fts WHERE notes_fts MATCH ?",
        arguments: [pattern])
}
```

---

## Optional Tables (Future)

### citations

Bibliography entries (if not using external .bib files)

```sql
CREATE TABLE citations (
    id TEXT PRIMARY KEY,
    citekey TEXT NOT NULL UNIQUE,  -- @key
    title TEXT,
    authors TEXT,                   -- JSON array
    year INTEGER,
    metadata TEXT,                  -- Complete citation JSON
    created_at INTEGER NOT NULL
);
```

### attachments

File attachments (images, PDFs)

```sql
CREATE TABLE attachments (
    id TEXT PRIMARY KEY,
    note_id TEXT NOT NULL
        REFERENCES notes(id) ON DELETE CASCADE,
    filename TEXT NOT NULL,
    filepath TEXT NOT NULL,         -- Relative to vault
    mime_type TEXT,
    size_bytes INTEGER,
    created_at INTEGER NOT NULL
);
```

---

## Associations (GRDB)

### Project has many Notes

```swift
extension Project {
    static let notes = hasMany(Note.self)
    
    var notes: QueryInterfaceRequest<Note> {
        request(for: Project.notes)
    }
}

extension Note {
    static let project = belongsTo(Project.self)
    
    var project: QueryInterfaceRequest<Project> {
        request(for: Note.project)
    }
}
```

### Note has many Links (outgoing)

```swift
extension Note {
    static let outgoingLinks = hasMany(Link.self, key: "outgoing")
    static let incomingLinks = hasMany(Link.self, key: "incoming")
    
    var backlinks: QueryInterfaceRequest<Note> {
        // Notes linking TO this note
        let linkRequest = Link
            .filter(Column("targetNoteId") == id)
        return Note.joining(required: Note.hasMany(Link.self))
    }
}
```

---

## Migrations

### Migration 1: Core Schema

```swift
migrator.registerMigration("v1") { db in
    try db.create(table: "projects") { t in
        t.primaryKey("id", .text)
        t.column("name", .text).notNull()
        t.column("description", .text)
        t.column("type", .text).notNull()
            .check { $0 in ["research", "teaching", "r-package", "r-dev", "generic"] }
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
```

### Migration 2: Links & Tags

```swift
migrator.registerMigration("v2") { db in
    try db.create(table: "links") { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("source_note_id", .text).notNull()
            .references("notes", onDelete: .cascade)
        t.column("target_note_id", .text).notNull()
            .references("notes", onDelete: .cascade)
        t.column("link_type", .text).notNull().defaults(to: "wiki")
        t.column("created_at", .integer).notNull()
        t.uniqueKey(["source_note_id", "target_note_id", "link_type"])
    }
    
    try db.create(table: "tags") { t in
        t.primaryKey("id", .text)
        t.column("name", .text).notNull().unique()
        t.column("color", .text)
        t.column("created_at", .integer).notNull()
    }
}
```

### Migration 3: Full-Text Search

```swift
migrator.registerMigration("v3") { db in
    try db.create(virtualTable: "notes_fts", using: FTS5()) { t in
        t.column("note_id")
        t.column("title")
        t.column("content")
        t.column("metadata")
    }
    
    // Create triggers
    try db.execute(sql: """
        CREATE TRIGGER notes_ai AFTER INSERT ON notes BEGIN
            INSERT INTO notes_fts(note_id, title, content, metadata)
            VALUES (new.id, new.title, new.content, COALESCE(new.metadata, ''));
        END
        """)
    
    try db.execute(sql: """
        CREATE TRIGGER notes_au AFTER UPDATE ON notes BEGIN
            UPDATE notes_fts 
            SET title = new.title, content = new.content, metadata = COALESCE(new.metadata, '')
            WHERE note_id = old.id;
        END
        """)
    
    try db.execute(sql: """
        CREATE TRIGGER notes_ad AFTER DELETE ON notes BEGIN
            DELETE FROM notes_fts WHERE note_id = old.id;
        END
        """)
}
```

---

## Key Improvements Over Tauri Schema

| Aspect | Tauri | Native | Benefit |
|--------|-------|--------|---------|
| **IDs** | String UUIDs | String UUIDs | ✅ Same, portable |
| **Timestamps** | Unix Int64 | Unix Int64 | ✅ Same, sortable |
| **Tags** | Separate junction table | JSON in metadata | Simpler queries |
| **Properties** | Flat columns | JSON metadata | More flexible |
| **Links** | Basic table | Typed links (wiki/cite/embed) | Better semantics |
| **Search** | FTS5 | FTS5 + better triggers | Faster updates |
| **Foreign Keys** | Enabled | Enabled + CASCADE | Data integrity |

---

## Usage Examples

### Create Note with Tags

```swift
var note = Note(
    title: "Mediation Analysis",
    content: "# Methods\n\nWe analyze...",
    folder: "research",
    projectId: project.id
)

note.metadata = NoteMetadata(
    tags: ["#stats", "#mediation"],
    isDaily: false,
    isPinned: true
)

try db.write { db in
    try note.save(db)
}
```

### Search with FTS5

```swift
let results = try db.read { db in
    let pattern = FTS5Pattern(matchingAllTokensIn: "causal inference")
    let noteIds = try String.fetchAll(db,
        sql: "SELECT note_id FROM notes_fts WHERE notes_fts MATCH ?",
        arguments: [pattern])
    
    return try Note
        .filter(noteIds.contains(Column("id")))
        .filter(Column("deleted_at") == nil)
        .order(Column("updated_at").desc)
        .fetchAll(db)
}
```

### Get Backlinks

```swift
let backlinks = try db.read { db in
    try Note.fetchAll(db,
        sql: """
        SELECT n.* FROM notes n
        JOIN links l ON n.id = l.source_note_id
        WHERE l.target_note_id = ? AND l.link_type = 'wiki'
        ORDER BY l.created_at DESC
        """,
        arguments: [currentNote.id])
}
```

---

**This schema is cleaner, more flexible, and optimized for Swift.**
