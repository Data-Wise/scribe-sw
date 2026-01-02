import Foundation

/// Clean project service - simple CRUD operations
@MainActor
final class ProjectService {
    private let database: DatabaseManager
    
    init(database: DatabaseManager) {
        self.database = database
    }
    
    // MARK: - Fetch
    
    func fetchAll() async throws -> [Project] {
        try await database.fetchProjects()
    }
    
    func fetch(id: String) async throws -> Project {
        guard let project = try await database.fetchProject(id: id) else {
            throw ScribeError.projectNotFound(id)
        }
        return project
    }
    
    // MARK: - Create
    
    func create(
        name: String,
        description: String? = nil,
        type: ProjectType = .generic
    ) async throws -> Project {
        let project = Project(
            name: name,
            description: description,
            type: type
        )
        
        try await database.saveProject(project)
        return project
    }
    
    // MARK: - Update
    
    func save(_ project: Project) async throws {
        var updated = project
        updated.updatedAt = Date().unixTimestamp
        try await database.saveProject(updated)
    }
    
    // MARK: - Delete
    
    func delete(id: String) async throws {
        try await database.deleteProject(id: id)
    }
}
