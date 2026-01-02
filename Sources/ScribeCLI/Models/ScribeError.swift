import Foundation

/// Errors that can occur in Scribe
enum ScribeError: LocalizedError, Sendable {
    // MARK: - Database Errors
    case databaseInitializationFailed(Error)
    case databaseMigrationFailed(Error)
    case noteNotFound(String)
    case projectNotFound(String)
    case invalidData(String)
    
    // MARK: - File System Errors
    case fileReadFailed(String)
    case fileWriteFailed(String)
    case invalidPath(String)
    
    // MARK: - Parsing Errors
    case markdownParsingFailed(String)
    case invalidJSON(String)
    
    // MARK: - User Input Errors
    case emptyTitle
    case invalidProjectType(String)
    case duplicateName(String)
    
    // MARK: - Unknown
    case unknown(Error)
    
    // MARK: - LocalizedError Conformance
    
    var errorDescription: String? {
        switch self {
        case .databaseInitializationFailed(let error):
            return "Failed to initialize database: \(error.localizedDescription)"
        case .databaseMigrationFailed(let error):
            return "Database migration failed: \(error.localizedDescription)"
        case .noteNotFound(let id):
            return "Note not found: \(id)"
        case .projectNotFound(let id):
            return "Project not found: \(id)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
            
        case .fileReadFailed(let path):
            return "Failed to read file: \(path)"
        case .fileWriteFailed(let path):
            return "Failed to write file: \(path)"
        case .invalidPath(let path):
            return "Invalid file path: \(path)"
            
        case .markdownParsingFailed(let message):
            return "Markdown parsing failed: \(message)"
        case .invalidJSON(let message):
            return "Invalid JSON: \(message)"
            
        case .emptyTitle:
            return "Title cannot be empty"
        case .invalidProjectType(let type):
            return "Invalid project type: \(type)"
        case .duplicateName(let name):
            return "A project with this name already exists: \(name)"
            
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .databaseInitializationFailed, .databaseMigrationFailed:
            return "Please restart the app. If the problem persists, you may need to reset your database."
        case .noteNotFound, .projectNotFound:
            return "The item may have been deleted. Try refreshing the list."
        case .invalidData:
            return "The data may be corrupted. Try reloading or contact support."
            
        case .fileReadFailed, .fileWriteFailed:
            return "Check file permissions and available disk space."
        case .invalidPath:
            return "Verify the file path and try again."
            
        case .markdownParsingFailed:
            return "Check your markdown syntax and try again."
        case .invalidJSON:
            return "The metadata format is invalid. Try resetting the note properties."
            
        case .emptyTitle:
            return "Please enter a title for your note or project."
        case .invalidProjectType:
            return "Please select a valid project type."
        case .duplicateName:
            return "Choose a different name."
            
        case .unknown:
            return "Try restarting the app or contact support if the problem persists."
        }
    }
    
    var failureReason: String? {
        switch self {
        case .databaseInitializationFailed:
            return "Could not create or open the database file."
        case .databaseMigrationFailed:
            return "Failed to upgrade database schema."
        case .noteNotFound, .projectNotFound:
            return "The requested item does not exist in the database."
        case .invalidData:
            return "Data validation failed."
            
        case .fileReadFailed:
            return "Unable to access the file for reading."
        case .fileWriteFailed:
            return "Unable to write to the file."
        case .invalidPath:
            return "The specified path does not exist or is inaccessible."
            
        case .markdownParsingFailed:
            return "The markdown content could not be parsed."
        case .invalidJSON:
            return "JSON decoding failed."
            
        case .emptyTitle:
            return "Title is required."
        case .invalidProjectType:
            return "Unrecognized project type."
        case .duplicateName:
            return "Name must be unique."
            
        case .unknown:
            return "An unexpected condition occurred."
        }
    }
}

// MARK: - Result Type Helpers

extension Result where Failure == ScribeError {
    /// Convenience initializer for catching errors
    init(catching body: () throws -> Success) {
        do {
            self = .success(try body())
        } catch let error as ScribeError {
            self = .failure(error)
        } catch {
            self = .failure(.unknown(error))
        }
    }
}
