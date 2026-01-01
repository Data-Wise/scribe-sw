import Foundation
import GRDB

/// Thread-safe database manager using actor isolation
/// All database operations go through this actor
actor DatabaseManager {
    // MARK: - Singleton
    
    static let shared = DatabaseManager()
    
    // MARK: - Properties
    
    private let dbQueue: DatabaseQueue
    private let migrator: DatabaseMigrator
    
    // MARK: - Initialization
    
    init() {
        do {
            // Setup database directory
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
            
            // Configure GRDB
            var config = Configuration()
            config.prepareDatabase { db in
                db.trace { print("[SQL] \($0)") }
            }
            
            // Create database queue
            self.dbQueue = try DatabaseQueue(path: dbPath.path, configuration: config)
            self.migrator = Self.createMigrator()
            
            // Run migrations
            try migrator.migrate(dbQueue)
            
            print("[DB] Initialized at: \(dbPath.path)")
        } catch {
            fatalError("Failed to initialize database: \(error)")
        }
    }
    
    // MARK: - Migrations
    
    private static func createMigrator() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        // Migration v1: Core schema
        migrator.registerMigration("v1_core_schema") { db in
            // Projects table
            try db.create(table: "projects") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("type", .text).notNull()
                    .check { ["research", "teaching", "r-package", "r-dev", "generic"].contains($0) }
                t.column("color", .text)
                t.column("icon", .text)
                t.column("settings", .text)
                t.column("created_at", .integer).notNull()
                t.column("updated_at", .integer).notNull()
            }
            
            // Notes table
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
            
            // Indexes
            try db.create(index: "idx_notes_project", on: "notes", columns: ["project_id"])
            try db.create(index: "idx_notes_updated", on: "notes", columns: ["updated_at"])
            try db.create(index: "idx_notes_deleted", on: "notes", columns: ["deleted_at"])
        }
        
        // Migration v2: Links & Tags
        migrator.registerMigration("v2_links_tags") { db in
            // Links table
            try db.create(table: "links") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("source_note_id", .text).notNull()
                    .references("notes", onDelete: .cascade)
                t.column("target_note_id", .text).notNull()
                    .references("notes", onDelete: .cascade)
                t.column("link_type", .text).notNull().defaults(to: "wiki")
                    .check { ["wiki", "cite", "embed"].contains($0) }
                t.column("created_at", .integer).notNull()
                t.uniqueKey(["source_note_id", "target_note_id", "link_type"])
            }
            
            // Indexes
            try db.create(index: "idx_links_source", on: "links", columns: ["source_note_id"])
            try db.create(index: "idx_links_target", on: "links", columns: ["target_note_id"])
        }
        
        // Migration v3: Full-text search
        migrator.registerMigration("v3_fts") { db in
            // Create FTS5 virtual table
            try db.create(virtualTable: "notes_fts", using: FTS5()) { t in
                t.column("note_id")
                t.column("title")
                t.column("content")
            }
            
            // Triggers to keep FTS in sync
            try db.execute(sql: """
                CREATE TRIGGER notes_ai AFTER INSERT ON notes BEGIN
                    INSERT INTO notes_fts(note_id, title, content)
                    VALUES (new.id, new.title, new.content);
                END
                """)
            
            try db.execute(sql: """
                CREATE TRIGGER notes_au AFTER UPDATE ON notes BEGIN
                    UPDATE notes_fts
                    SET title = new.title, content = new.content
                    WHERE note_id = old.id;
                END
                """)
            
            try db.execute(sql: """
                CREATE TRIGGER notes_ad AFTER DELETE ON notes BEGIN
                    DELETE FROM notes_fts WHERE note_id = old.id;
                END
                """)
        }
        
        // Migration v4: Add word_count column
        migrator.registerMigration("v4_word_count") { db in
            // Add word_count column if not exists
            try db.alter(table: "notes") { t in
                t.add(column: "word_count", .integer).defaults(to: 0)
            }
            
            // Backfill word_count for existing notes
            // Note: This is a simple word count, can be refined later
            try db.execute(sql: """
                UPDATE notes
                SET word_count = length(trim(content, ' ,.')) - length(replace(trim(content, ' ,.'), ' ', '')) + 1
                WHERE word_count = 0 OR word_count IS NULL
                """)
            
            // Create index for sorting by word count
            try db.create(index: "idx_notes_word_count", on: "notes", columns: ["word_count"])
        }
        
        // Migration v5: Add tags table
        migrator.registerMigration("v5_tags_table") { db in
            try db.create(table: "tags") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull().unique()
                t.column("color", .text)
                t.column("created_at", .integer).notNull()
                
                t.check(sql: "name GLOB '#*'")
            }
            
            // Create index with NOCASE collation using raw SQL
            try db.execute(sql: "CREATE INDEX idx_tags_name ON tags(name COLLATE NOCASE)")
        }
        
        return migrator
    }
    
    // MARK: - Projects
    
    func fetchProjects() throws -> [Project] {
        try dbQueue.read { db in
            try Project
                .order(Project.Columns.name)
                .fetchAll(db)
        }
    }
    
    func fetchProject(id: String) throws -> Project? {
        try dbQueue.read { db in
            try Project.fetchOne(db, key: id)
        }
    }
    
    func saveProject(_ project: Project) throws {
        try dbQueue.write { db in
            try project.save(db)
        }
    }
    
    func deleteProject(id: String) throws {
        try dbQueue.write { db in
            try Project.deleteOne(db, key: id)
        }
    }
    
    // MARK: - Notes
    
    func fetchNotes(
        projectId: String? = nil,
        includeDeleted: Bool = false,
        limit: Int? = nil,
        offset: Int = 0
    ) throws -> [Note] {
        try dbQueue.read { db in
            var query = Note.all()
            
            if !includeDeleted {
                query = query.filter(Note.Columns.deletedAt == nil)
            }
            
            if let projectId {
                query = query.filter(Note.Columns.projectId == projectId)
            }
            
            var orderedQuery = query.order(Note.Columns.updatedAt.desc)
            
            if let limit = limit {
                orderedQuery = orderedQuery.limit(limit, offset: offset)
            }
            
            return try orderedQuery.fetchAll(db)
        }
    }
    
    func fetchNote(id: String) throws -> Note? {
        try dbQueue.read { db in
            try Note.fetchOne(db, key: id)
        }
    }
    
    func saveNote(_ note: Note) throws {
        try dbQueue.write { db in
            try note.save(db)
        }
    }
    
    func deleteNote(id: String, permanent: Bool = false) throws {
        try dbQueue.write { db in
            if permanent {
                try Note.deleteOne(db, key: id)
            } else {
                // Soft delete
                try db.execute(
                    sql: "UPDATE notes SET deleted_at = ? WHERE id = ?",
                    arguments: [Date().unixTimestamp, id]
                )
            }
        }
    }
    
    // MARK: - Search
    
    func searchNotes(query: String, projectId: String? = nil) throws -> [Note] {
        try dbQueue.read { db in
            let pattern = FTS5Pattern(matchingAllTokensIn: query)
            
            // Get matching note IDs from FTS
            let noteIds = try String.fetchAll(db,
                sql: "SELECT note_id FROM notes_fts WHERE notes_fts MATCH ?",
                arguments: [pattern])
            
            // Fetch full notes
            var noteQuery = Note
                .filter(noteIds.contains(Note.Columns.id))
                .filter(Note.Columns.deletedAt == nil)
            
            if let projectId {
                noteQuery = noteQuery.filter(Note.Columns.projectId == projectId)
            }
            
            return try noteQuery.fetchAll(db)
        }
    }
    
    // MARK: - Links
    
    func fetchBacklinks(for noteId: String) throws -> [Note] {
        try dbQueue.read { db in
            try Note.fetchAll(db,
                sql: """
                SELECT n.* FROM notes n
                JOIN links l ON n.id = l.source_note_id
                WHERE l.target_note_id = ? 
                  AND l.link_type = 'wiki'
                  AND n.deleted_at IS NULL
                ORDER BY l.created_at DESC
                """,
                arguments: [noteId])
        }
    }
    
    func saveLink(sourceId: String, targetId: String, type: String = "wiki") throws {
        try dbQueue.write { db in
            try db.execute(
                sql: """
                INSERT OR IGNORE INTO links (source_note_id, target_note_id, link_type, created_at)
                VALUES (?, ?, ?, ?)
                """,
                arguments: [sourceId, targetId, type, Date().unixTimestamp]
            )
        }
    }
    
    func deleteLinks(for noteId: String) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "DELETE FROM links WHERE source_note_id = ? OR target_note_id = ?",
                arguments: [noteId, noteId]
            )
        }
    }
    
    // MARK: - Statistics
    
    func noteCount(projectId: String? = nil) throws -> Int {
        try dbQueue.read { db in
            var query = Note.filter(Note.Columns.deletedAt == nil)
            
            if let projectId {
                query = query.filter(Note.Columns.projectId == projectId)
            }
            
            return try query.fetchCount(db)
        }
    }
    
    func totalWordCount(projectId: String? = nil) throws -> Int {
        try dbQueue.read { db in
            var request = Note
                .select(sql: "SUM(word_count)")
                .filter(Note.Columns.deletedAt == nil)
            
            if let projectId {
                request = request.filter(Note.Columns.projectId == projectId)
            }
            
            return try Int.fetchOne(db, request) ?? 0
        }
    }
}
