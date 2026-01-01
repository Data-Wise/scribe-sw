import Foundation
import OSLog
import os

/// Structured logging for Scribe
enum ScribeLog {
    static let app = OSLog(subsystem: "com.data-wise.scribe", category: "App")
    static let database = OSLog(subsystem: "com.data-wise.scribe", category: "Database")
    static let ui = OSLog(subsystem: "com.data-wise.scribe", category: "UI")
    static let network = OSLog(subsystem: "com.data-wise.scribe", category: "Network")
    static let performance = OSLog(subsystem: "com.data-wise.scribe", category: "Performance")
    
    // MARK: - App Lifecycle
    
    static func appStart() {
        os_log(.info, log: app, "Scribe started")
    }
    
    static func appQuit() {
        os_log(.info, log: app, "Scribe quit")
    }
    
    // MARK: - Database
    
    static func databaseInitialized(at path: String) {
        os_log(.info, log: database, "Database initialized at %@", path)
    }
    
    static func migrationStarted(version: String) {
        os_log(.info, log: database, "Starting migration %@", version)
    }
    
    static func migrationCompleted(version: String) {
        os_log(.info, log: database, "Migration %@ completed", version)
    }
    
    static func databaseError(_ error: Error) {
        os_log(.error, log: database, "Database error: %@", error.localizedDescription)
    }
    
    // MARK: - Notes
    
    static func noteCreated(id: String, title: String) {
        os_log(.debug, log: app, "Note created: %@ (%@)", title, id)
    }
    
    static func noteUpdated(id: String, wordCount: Int) {
        os_log(.debug, log: app, "Note updated: %@ (%d words)", id, wordCount)
    }
    
    static func noteDeleted(id: String) {
        os_log(.debug, log: app, "Note deleted: %@", id)
    }
    
    // MARK: - Search
    
    static func searchPerformed(query: String, resultCount: Int) {
        os_log(.debug, log: performance, "Search '%@' returned %d results", query, resultCount)
    }
    
    static func searchError(query: String, error: Error) {
        os_log(.error, log: app, "Search failed for '%@': %@", query, error.localizedDescription)
    }
    
    // MARK: - UI
    
    static func viewOpened(viewName: String) {
        os_log(.debug, log: ui, "View opened: %@", viewName)
    }
    
    static func uiAction(actionName: String) {
        os_log(.debug, log: ui, "UI action: %@", actionName)
    }
    
    // MARK: - Performance
    
    static func measure<T>(name: String, block: () throws -> T) rethrows -> T {
        let start = Date()
        let result = try block()
        let duration = Date().timeIntervalSince(start)
        #if DEBUG
        print("⏱️ %@ took %.3f seconds", name, duration)
        #endif
        return result
    }
    
    static func measureAsync<T>(name: String, block: () async throws -> T) async rethrows -> T {
        let start = Date()
        let result = try await block()
        let duration = Date().timeIntervalSince(start)
        #if DEBUG
        print("⏱️ %@ took %.3f seconds (async)", name, duration)
        #endif
        return result
    }
}
