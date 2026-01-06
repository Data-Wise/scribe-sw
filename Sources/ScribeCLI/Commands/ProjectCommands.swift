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
            let id = project.id.prefix(8)
            print("  [\(id)] \(project.type.emoji) \(project.name)")
            if let desc = project.description {
                print("          \(desc)")
            }
        }
    }
    
    @MainActor
    static func create(_ service: ProjectService, args: [String]) async throws {
        guard !args.isEmpty else {
            print("❌ Usage: scribe-cli project create <name> [type]")
            print("   Types: research, teaching, r-package, r-dev, generic")
            return
        }
        
        let name = args[0]
        let typeString = args.count > 1 ? args[1] : "generic"
        
        let type: ProjectType
        switch typeString.lowercased() {
        case "research": type = .research
        case "teaching": type = .teaching
        case "r-package", "rpackage": type = .rPackage
        case "r-dev", "rdev": type = .rDev
        case "generic": type = .generic
        default:
            print("❌ Invalid project type: \(typeString)")
            print("   Valid types: research, teaching, r-package, r-dev, generic")
            return
        }
        
        let project = try await service.create(name: name, description: nil, type: type)
        print("✅ Created project: \(project.name) (\(project.type.emoji))")
    }
}
