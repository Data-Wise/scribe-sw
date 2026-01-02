import Foundation

/// Project management commands
enum ProjectCommands {
    @MainActor
    static func list(_ service: ProjectService) async throws {
        let projects = try await service.fetchAll()
        
        if projects.isEmpty {
            print("📁 No projects found")
            return
        }
        
        print("📁 Projects (\(projects.count)):\n")
        for project in projects {
            print("  📦 \(project.name)")
            if let desc = project.description {
                print("     \(desc)")
            }
        }
    }
}
