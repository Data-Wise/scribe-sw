# Database Schema

**Database:** SQLite
**Wrapper:** GRDB.swift
**Location:** `~/Library/Application Support/Scribe/scribe.sqlite`
**Compatibility:** Matches Tauri version for potential sync

---

## Overview

Scribe uses SQLite with 9 migrations for data persistence. The schema is designed to be compatible with the Tauri/React version for potential sync capabilities.

**Key Features:**
- Soft deletes (deleted_at column)
- Full-text search (FTS5)
- Foreign key constraints
- Composite indexes for performance
- JSON properties for flexible metadata

---

## Tables

### notes

Core notes table with markdown content.

```sql
CREATE TABLE notes (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    title TEXT NOT NULL,
    content TEXT DEFAULT '',
    folder TEXT DEFAULT 'inbox',
    project_id TEXT REFERENCES projects(id) ON DELETE SET NULL,
    properties TEXT,  -- JSON blob for frontmatter
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    updated_at INTEGER DEFAULT (strftime('%s', 'now')),
    deleted_at INTEGER NULL  -- Soft delete
);

CREATE INDEX idx_notes_folder ON notes(folder);
CREATE INDEX idx_notes_project ON notes(project_id);
CREATE INDEX idx_notes_updated ON notes(updated_at DESC);
CREATE INDEX idx_notes_deleted ON notes(deleted_at);
```

**GRDB Model:**
```swift
struct Note: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var title: String
    var content: String
    var folder: String
    var projectId: String?
    var properties: String?  // JSON
    var createdAt: Int64
    var updatedAt: Int64
    var deletedAt: Int64?

    static let databaseTableName = "notes"

    enum CodingKeys: String, CodingKey {
        case id, title, content, folder
        case projectId = "project_id"
        case properties
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
```

---

### projects

Project organization (5 types).

```sql
CREATE TABLE projects (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    name TEXT NOT NULL,
    description TEXT,
    type TEXT CHECK(type IN ('research', 'teaching', 'r-package', 'r-dev', 'generic')) DEFAULT 'generic',
    color TEXT,
    settings TEXT,  -- JSON blob
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    updated_at INTEGER DEFAULT (strftime('%s', 'now'))
);

CREATE INDEX idx_projects_name ON projects(name);
CREATE INDEX idx_projects_type ON projects(type);
```

**GRDB Model:**
```swift
enum ProjectType: String, Codable {
    case research
    case teaching
    case rPackage = "r-package"
    case rDev = "r-dev"
    case generic
}

struct Project: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var description: String?
    var type: ProjectType
    var color: String?
    var settings: String?  // JSON
    var createdAt: Int64
    var updatedAt: Int64

    static let databaseTableName = "projects"

    enum CodingKeys: String, CodingKey {
        case id, name, description, type, color, settings
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

---

### tags

Tag definitions with optional color.

```sql
CREATE TABLE tags (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    name TEXT NOT NULL UNIQUE COLLATE NOCASE,
    color TEXT,
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    UNIQUE(name COLLATE NOCASE)
);

CREATE INDEX idx_tags_name ON tags(name COLLATE NOCASE);
```

**GRDB Model:**
```swift
struct Tag: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var color: String?
    var createdAt: Int64

    static let databaseTableName = "tags"

    enum CodingKeys: String, CodingKey {
        case id, name, color
        case createdAt = "created_at"
    }
}
```

---

### note_tags

Many-to-many junction table for note-tag relationships.

```sql
CREATE TABLE note_tags (
    note_id TEXT NOT NULL,
    tag_id TEXT NOT NULL,
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    PRIMARY KEY (note_id, tag_id),
    FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

CREATE INDEX idx_note_tags_note ON note_tags(note_id);
CREATE INDEX idx_note_tags_tag ON note_tags(tag_id);
```

---

### links

Wiki-style bidirectional links between notes.

```sql
CREATE TABLE links (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_note_id TEXT NOT NULL,
    target_note_id TEXT NOT NULL,
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    FOREIGN KEY (source_note_id) REFERENCES notes(id) ON DELETE CASCADE,
    FOREIGN KEY (target_note_id) REFERENCES notes(id) ON DELETE CASCADE,
    UNIQUE(source_note_id, target_note_id)
);

CREATE INDEX idx_links_source ON links(source_note_id);
CREATE INDEX idx_links_target ON links(target_note_id);
```

---

### chat_sessions & chat_messages

AI chat history (for Claude/Gemini integration).

```sql
CREATE TABLE chat_sessions (
    id TEXT PRIMARY KEY,
    note_id TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
);

CREATE INDEX idx_chat_sessions_note_id ON chat_sessions(note_id);
CREATE INDEX idx_chat_sessions_updated_at ON chat_sessions(updated_at DESC);

CREATE TABLE chat_messages (
    id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
    content TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    FOREIGN KEY (session_id) REFERENCES chat_sessions(id) ON DELETE CASCADE
);

CREATE INDEX idx_chat_messages_session_id ON chat_messages(session_id);
CREATE INDEX idx_chat_messages_timestamp ON chat_messages(timestamp ASC);
```

---

### notes_fts

Full-text search virtual table (FTS5).

```sql
CREATE VIRTUAL TABLE notes_fts USING fts5(
    note_id UNINDEXED,
    title,
    content,
    properties
);

-- Triggers to keep FTS in sync
CREATE TRIGGER notes_ai AFTER INSERT ON notes BEGIN
    INSERT INTO notes_fts(note_id, title, content, properties)
    VALUES (new.id, new.title, new.content, COALESCE(new.properties, ''));
END;

CREATE TRIGGER notes_ad AFTER DELETE ON notes BEGIN
    DELETE FROM notes_fts WHERE note_id = old.id;
END;

CREATE TRIGGER notes_au AFTER UPDATE ON notes BEGIN
    DELETE FROM notes_fts WHERE note_id = old.id;
    INSERT INTO notes_fts(note_id, title, content, properties)
    VALUES (new.id, new.title, new.content, COALESCE(new.properties, ''));
END;
```

**GRDB Query:**
```swift
// Search notes
let pattern = FTS5Pattern(matchingAllTokensIn: "search query")
let noteIds = try dbQueue.read { db in
    try String.fetchAll(db,
        sql: "SELECT note_id FROM notes_fts WHERE notes_fts MATCH ?",
        arguments: [pattern])
}
```

---

## Migration History

| Version | Description |
|---------|-------------|
| 001 | Core tables (notes, tags, folders, FTS) |
| 002 | Links (wiki-style connections) |
| 003 | Refactored tags to standalone table |
| 004 | Projects system |
| 005 | Note properties (JSON frontmatter) |
| 006 | Project settings table |
| 007 | Demo data seeding |
| 008 | Updated FTS to include properties |
| 009 | Chat history tables |

---

## Common Queries

### Get All Notes (Excluding Deleted)

```swift
let notes = try dbQueue.read { db in
    try Note
        .filter(Column("deleted_at") == nil)
        .order(Column("updated_at").desc)
        .fetchAll(db)
}
```

### Get Notes by Project

```swift
let projectNotes = try dbQueue.read { db in
    try Note
        .filter(Column("project_id") == projectId)
        .filter(Column("deleted_at") == nil)
        .fetchAll(db)
}
```

### Full-Text Search

```swift
let pattern = FTS5Pattern(matchingAllTokensIn: query)
let results = try dbQueue.read { db in
    try String.fetchAll(db,
        sql: """
        SELECT n.* FROM notes n
        JOIN notes_fts fts ON n.id = fts.note_id
        WHERE notes_fts MATCH ?
        AND n.deleted_at IS NULL
        ORDER BY rank
        """,
        arguments: [pattern])
}
```

### Get Note with Tags

```swift
struct NoteWithTags {
    let note: Note
    let tags: [Tag]
}

let noteWithTags = try dbQueue.read { db in
    let note = try Note.fetchOne(db, id: noteId)
    let tags = try Tag
        .joining(required: Tag.belongsToMany(Note.self))
        .filter(Column("note_id") == noteId)
        .fetchAll(db)
    return NoteWithTags(note: note, tags: tags)
}
```

---

## Data Types

### Timestamps

- Stored as INTEGER (Unix epoch in seconds)
- Use `Int64` in Swift
- Convert to/from Date:

```swift
extension Date {
    var unixTimestamp: Int64 {
        Int64(timeIntervalSince1970)
    }

    init(unixTimestamp: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
    }
}
```

### JSON Properties

```swift
struct NoteProperties: Codable {
    var author: String?
    var status: String?
    var tags: [String]?
    var customFields: [String: String]?
}

// Encode to JSON string for storage
let properties = NoteProperties(author: "DT", status: "draft")
let json = try JSONEncoder().encode(properties)
let jsonString = String(data: json, encoding: .utf8)

// Decode from JSON string
if let propertiesJSON = note.properties,
   let data = propertiesJSON.data(using: .utf8) {
    let properties = try JSONDecoder().decode(NoteProperties.self, from: data)
}
```

---

## Database Location

- **macOS:** `~/Library/Application Support/Scribe/scribe.sqlite`
- **CLI:** Uses same database file
- **Backup:** Copy `.sqlite`, `.sqlite-shm`, `.sqlite-wal` files

---

## See Also

- [GRDB Documentation](https://github.com/groue/GRDB.swift)
- [SQLite FTS5 Guide](https://www.sqlite.org/fts5.html)
- SWIFT-DEVELOPMENT.md for implementation examples
