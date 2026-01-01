import Foundation
import GRDB

/// SQLite database service using GRDB
/// Schema matches browser version for potential sync compatibility
final class DatabaseService {
    private var dbPool: DatabasePool?

    init() {
        setupDatabase()
    }

    // MARK: - Setup

    private func setupDatabase() {
        do {
            let fileManager = FileManager.default
            let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let dbDir = appSupport.appendingPathComponent("Scribe", isDirectory: true)

            try fileManager.createDirectory(at: dbDir, withIntermediateDirectories: true)

            let dbPath = dbDir.appendingPathComponent("scribe.sqlite")

            var config = Configuration()
            config.foreignKeysEnabled = true

            dbPool = try DatabasePool(path: dbPath.path, configuration: config)

            try createTables()
        } catch {
            print("Database setup failed: \(error)")
        }
    }

    private func createTables() throws {
        try dbPool?.write { db in
            // Vaults table (matches browser Projects)
            try db.create(table: "vaults", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("color", .text).defaults(to: "#3b82f6")
                t.column("icon", .text)
                t.column("type", .text).defaults(to: "generic")
                t.column("created_at", .integer).notNull()
                t.column("updated_at", .integer).notNull()
            }

            // Pages table (matches browser Notes)
            try db.create(table: "pages", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("vault_id", .text).references("vaults", onDelete: .setNull)
                t.column("title", .text).notNull().defaults(to: "Untitled")
                t.column("content", .text).defaults(to: "")
                t.column("is_daily", .boolean).defaults(to: false)
                t.column("is_favorite", .boolean).defaults(to: false)
                t.column("created_at", .integer).notNull()
                t.column("updated_at", .integer).notNull()
                t.column("deleted_at", .integer)
            }

            // Tags table
            try db.create(table: "tags", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull().unique()
                t.column("color", .text)
            }

            // Page-Tags junction table
            try db.create(table: "page_tags", ifNotExists: true) { t in
                t.column("page_id", .text).notNull().references("pages", onDelete: .cascade)
                t.column("tag_id", .text).notNull().references("tags", onDelete: .cascade)
                t.primaryKey(["page_id", "tag_id"])
            }

            // Create indexes
            try db.create(index: "idx_pages_vault", on: "pages", columns: ["vault_id"], ifNotExists: true)
            try db.create(index: "idx_pages_updated", on: "pages", columns: ["updated_at"], ifNotExists: true)
            try db.create(index: "idx_pages_daily", on: "pages", columns: ["is_daily", "created_at"], ifNotExists: true)
        }
    }

    // MARK: - Vaults

    func loadVaults() async -> [Vault] {
        do {
            return try await dbPool?.read { db in
                try Row.fetchAll(db, sql: "SELECT * FROM vaults ORDER BY name")
                    .map { row in
                        Vault(
                            id: UUID(uuidString: row["id"]) ?? UUID(),
                            name: row["name"],
                            color: row["color"],
                            icon: row["icon"],
                            type: VaultType(rawValue: row["type"]) ?? .generic,
                            createdAt: Date(timeIntervalSince1970: TimeInterval(row["created_at"] as Int)),
                            updatedAt: Date(timeIntervalSince1970: TimeInterval(row["updated_at"] as Int))
                        )
                    }
            } ?? []
        } catch {
            print("Failed to load vaults: \(error)")
            return []
        }
    }

    func saveVault(_ vault: Vault) {
        do {
            try dbPool?.write { db in
                try db.execute(
                    sql: """
                    INSERT OR REPLACE INTO vaults (id, name, color, icon, type, created_at, updated_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    arguments: [
                        vault.id.uuidString,
                        vault.name,
                        vault.color,
                        vault.icon,
                        vault.type.rawValue,
                        Int(vault.createdAt.timeIntervalSince1970),
                        Int(vault.updatedAt.timeIntervalSince1970)
                    ]
                )
            }
        } catch {
            print("Failed to save vault: \(error)")
        }
    }

    // MARK: - Pages

    func loadPages() async -> [Page] {
        do {
            return try await dbPool?.read { db in
                try Row.fetchAll(db, sql: """
                    SELECT p.*, GROUP_CONCAT(t.name) as tags
                    FROM pages p
                    LEFT JOIN page_tags pt ON p.id = pt.page_id
                    LEFT JOIN tags t ON pt.tag_id = t.id
                    GROUP BY p.id
                    ORDER BY p.updated_at DESC
                """)
                .map { row in
                    let tagsString: String? = row["tags"]
                    let tags = tagsString?.components(separatedBy: ",") ?? []

                    return Page(
                        id: UUID(uuidString: row["id"]) ?? UUID(),
                        vaultId: (row["vault_id"] as String?).flatMap { UUID(uuidString: $0) },
                        title: row["title"],
                        content: row["content"],
                        createdAt: Date(timeIntervalSince1970: TimeInterval(row["created_at"] as Int)),
                        updatedAt: Date(timeIntervalSince1970: TimeInterval(row["updated_at"] as Int)),
                        isDaily: row["is_daily"],
                        isFavorite: row["is_favorite"],
                        tags: tags,
                        deletedAt: (row["deleted_at"] as Int?).map { Date(timeIntervalSince1970: TimeInterval($0)) }
                    )
                }
            } ?? []
        } catch {
            print("Failed to load pages: \(error)")
            return []
        }
    }

    func savePage(_ page: Page) {
        do {
            try dbPool?.write { db in
                try db.execute(
                    sql: """
                    INSERT OR REPLACE INTO pages
                    (id, vault_id, title, content, is_daily, is_favorite, created_at, updated_at, deleted_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    arguments: [
                        page.id.uuidString,
                        page.vaultId?.uuidString,
                        page.title,
                        page.content,
                        page.isDaily,
                        page.isFavorite,
                        Int(page.createdAt.timeIntervalSince1970),
                        Int(page.updatedAt.timeIntervalSince1970),
                        page.deletedAt.map { Int($0.timeIntervalSince1970) }
                    ]
                )
            }
        } catch {
            print("Failed to save page: \(error)")
        }
    }

    func deletePage(_ pageId: UUID, permanent: Bool = false) {
        do {
            try dbPool?.write { db in
                if permanent {
                    try db.execute(sql: "DELETE FROM pages WHERE id = ?", arguments: [pageId.uuidString])
                } else {
                    try db.execute(
                        sql: "UPDATE pages SET deleted_at = ? WHERE id = ?",
                        arguments: [Int(Date().timeIntervalSince1970), pageId.uuidString]
                    )
                }
            }
        } catch {
            print("Failed to delete page: \(error)")
        }
    }
}
