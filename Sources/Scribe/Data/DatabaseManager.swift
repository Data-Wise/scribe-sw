import Foundation
import GRDB

/// Clean, simple database manager using GRDB
/// Thread-safe via actor isolation
actor DatabaseManager {
    // MARK: - Singleton
    
    static let shared = DatabaseManager()
    
    // MARK: - Properties
    
    private let dbQueue: DatabaseQueue
    
    // MARK: - Initialization
    
    private init() {
        print("[DatabaseManager] Starting initialization...")
        do {
            // Setup database directory
            print("[DatabaseManager] Setting up app directory...")
            let fileManager = FileManager.default
            let appSupport = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            
            let dbDirectory = appSupport.appendingPathComponent("Scribe")
            print("[DatabaseManager] Creating database directory: \(dbDirectory.path)")
            try fileManager.createDirectory(at: dbDirectory, withIntermediateDirectories: true)
            
            let dbPath = dbDirectory.appendingPathComponent("scribe.sqlite")
            
            // Create database queue
            print("[DatabaseManager] Creating database queue...")
            self.dbQueue = try DatabaseQueue(path: dbPath.path)
            
            // Run migrations
            print("[DatabaseManager] Running migrations...")
            try Self.runMigrations(dbQueue)
            
            print("[DB] Initialized at: \(dbPath.path)")
        } catch {
            print("[DatabaseManager] FATAL ERROR: \(error)")
            fatalError("Failed to initialize database: \(error)")
        }
    }
    
    // MARK: - Migrations
    
    private static func runMigrations(_ db: DatabaseQueue) throws {
        var migrator = DatabaseMigrator()
        
        // Migration v1: Core schema
        migrator.registerMigration("v1_core_schema") { db in
            // Projects table
            try db.create(table: "projects") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("type", .text).notNull()
                t.column("created_at", .integer).notNull()
                t.column("updated_at", .integer).notNull()
            }
            
            // Notes table
            try db.create(table: "notes") { t in
                t.primaryKey("id", .text)
                t.column("project_id", .text).references("projects", onDelete: .setNull)
                t.column("title", .text).notNull()
                t.column("content", .text).notNull().defaults(to: "")
                t.column("word_count", .integer).notNull().defaults(to: 0)
                t.column("created_at", .integer).notNull()
                t.column("updated_at", .integer).notNull()
                t.column("deleted_at", .integer)
            }
            
            // Indexes
            try db.create(index: "idx_notes_project", on: "notes", columns: ["project_id"])
            try db.create(index: "idx_notes_updated", on: "notes", columns: ["updated_at"])
        }
        
        // Migration v2: Full-text search
        migrator.registerMigration("v2_fts") { db in
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

        // Migration v3: Add missing project columns
        migrator.registerMigration("v3_project_fields") { db in
            try db.alter(table: "projects") { t in
                t.add(column: "color", .text)
                t.add(column: "icon", .text)
                t.add(column: "settings", .text)
            }
        }

        try migrator.migrate(db)
    }
    
    // MARK: - Projects
    
    func fetchProjects() throws -> [Project] {
        try dbQueue.read { db in
            try Project.order(Column("name")).fetchAll(db)
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
        _ = try dbQueue.write { db in
            try Project.deleteOne(db, key: id)
        }
    }
    
    // MARK: - Notes
    
    func fetchNotes(
        projectId: String? = nil,
        limit: Int? = nil,
        offset: Int = 0
    ) throws -> [Note] {
        try dbQueue.read { db in
            var query = Note.filter(Column("deleted_at") == nil)
            
            if let projectId {
                query = query.filter(Column("project_id") == projectId)
            }
            
            query = query.order(Column("updated_at").desc)
            
            if let limit {
                query = query.limit(limit, offset: offset)
            }
            
            return try query.fetchAll(db)
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
    
    func deleteNote(id: String) throws {
        try dbQueue.write { db in
            // Soft delete
            try db.execute(
                sql: "UPDATE notes SET deleted_at = ? WHERE id = ?",
                arguments: [Date().unixTimestamp, id]
            )
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
                .filter(noteIds.contains(Column("id")))
                .filter(Column("deleted_at") == nil)
            
            if let projectId {
                noteQuery = noteQuery.filter(Column("project_id") == projectId)
            }
            
            return try noteQuery.fetchAll(db)
        }
    }
    
    // MARK: - Statistics
    
    func noteCount(projectId: String? = nil) throws -> Int {
        try dbQueue.read { db in
            var query = Note.filter(Column("deleted_at") == nil)
            
            if let projectId {
                query = query.filter(Column("project_id") == projectId)
            }
            
            return try query.fetchCount(db)
        }
    }
    
    func totalWordCount(projectId: String? = nil) throws -> Int {
        try dbQueue.read { db in
            var sql = "SELECT SUM(word_count) FROM notes WHERE deleted_at IS NULL"
            
            if let projectId {
                sql += " AND project_id = ?"
                return try Int.fetchOne(db, sql: sql, arguments: [projectId]) ?? 0
            } else {
                return try Int.fetchOne(db, sql: sql) ?? 0
            }
        }
    }
}
