import Foundation

/// Service for project operations
@MainActor
final class ProjectService {
    // MARK: - Singleton
    
    static let shared = ProjectService()
    
    // MARK: - Dependencies
    
    private let database: DatabaseManager
    
    init(database: DatabaseManager = .shared) {
        self.database = database
    }
    
    // MARK: - CRUD Operations
    
    func fetch(id: String) async throws -> Project {
        guard let project = try await database.fetchProject(id: id) else {
            throw ScribeError.projectNotFound(id)
        }
        return project
    }
    
    func fetchAll() async throws -> [Project] {
        try await database.fetchProjects()
    }
    
    func create(
        name: String,
        description: String? = nil,
        type: ProjectType,
        color: String? = nil,
        icon: String? = nil,
        settings: ProjectSettings? = nil
    ) async throws -> Project {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ScribeError.emptyTitle
        }
        
        // Check for duplicate names
        let existing = try await fetchAll()
        if existing.contains(where: { $0.name == name }) {
            throw ScribeError.duplicateName(name)
        }
        
        let project = Project(
            name: name,
            description: description,
            type: type,
            color: color ?? type.defaultColor,
            icon: icon,
            settings: settings
        )
        
        try await database.saveProject(project)
        return project
    }
    
    func save(_ project: Project) async throws {
        var updated = project
        updated.updatedAt = Date().unixTimestamp
        try await database.saveProject(updated)
    }
    
    func delete(id: String) async throws {
        try await database.deleteProject(id: id)
    }
    
    // MARK: - Settings
    
    func updateSettings(_ settings: ProjectSettings, for projectId: String) async throws {
        var project = try await fetch(id: projectId)
        project.settings = settings
        try await save(project)
    }
    
    // MARK: - Statistics
    
    func noteCount(for projectId: String) async throws -> Int {
        try await database.noteCount(projectId: projectId)
    }
    
    func wordCount(for projectId: String) async throws -> Int {
        try await database.totalWordCount(projectId: projectId)
    }
}
