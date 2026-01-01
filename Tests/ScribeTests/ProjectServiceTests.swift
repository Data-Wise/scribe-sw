import Testing
@testable import Scribe
import Foundation

@Suite("Project Service Tests")
@MainActor
struct ProjectServiceTests {
    let database: DatabaseManager
    let service: ProjectService
    
    init() async throws {
        database = DatabaseManager.shared
        service = ProjectService(database: database)
    }
    
    @Test("Create project successfully")
    func createProject() async throws {
        let project = try await service.create(
            name: "Test Project",
            description: "A test project",
            type: .research
        )
        
        #expect(project.id.isEmpty == false)
        #expect(project.name == "Test Project")
        #expect(project.type == .research)
        #expect(project.color != nil)
    }
    
    @Test("Create project with empty name throws error")
    func createProjectEmptyName() async throws {
        await #expect(throws: ScribeError.self) {
            try await service.create(name: "", type: .generic)
        }
    }
    
    @Test("Create project with duplicate name throws error")
    func createDuplicateProject() async throws {
        _ = try await service.create(name: "Duplicate", type: .generic)
        
        await #expect(throws: ScribeError.self) {
            try await service.create(name: "Duplicate", type: .research)
        }
    }
    
    @Test("Fetch project by ID")
    func fetchProject() async throws {
        let created = try await service.create(
            name: "Fetch Test",
            type: .teaching
        )
        
        let fetched = try await service.fetch(id: created.id)
        
        #expect(fetched.id == created.id)
        #expect(fetched.name == created.name)
        #expect(fetched.type == created.type)
    }
    
    @Test("Fetch all projects")
    func fetchAllProjects() async throws {
        _ = try await service.create(name: "Project 1", type: .generic)
        _ = try await service.create(name: "Project 2", type: .research)
        _ = try await service.create(name: "Project 3", type: .teaching)
        
        let projects = try await service.fetchAll()
        
        #expect(projects.count >= 3)
    }
    
    @Test("Update project")
    func updateProject() async throws {
        let project = try await service.create(name: "Original", type: .generic)
        
        var updated = project
        updated.name = "Updated"
        updated.description = "New description"
        try await service.save(updated)
        
        let fetched = try await service.fetch(id: project.id)
        #expect(fetched.name == "Updated")
        #expect(fetched.description == "New description")
    }
    
    @Test("Delete project")
    func deleteProject() async throws {
        let project = try await service.create(name: "Delete Me", type: .generic)
        
        try await service.delete(id: project.id)
        
        await #expect(throws: ScribeError.self) {
            try await service.fetch(id: project.id)
        }
    }
    
    @Test("Update project settings")
    func updateProjectSettings() async throws {
        let project = try await service.create(name: "Settings Test", type: .research)
        
        let settings = ProjectSettings(
            bibliography: "/path/to/bib",
            citationStyle: "apa",
            exportTemplate: "default"
        )
        
        try await service.updateSettings(settings, for: project.id)
        
        let fetched = try await service.fetch(id: project.id)
        #expect(fetched.settings?.bibliography == "/path/to/bib")
        #expect(fetched.settings?.citationStyle == "apa")
    }
    
    @Test("Get note count for project")
    func getProjectNoteCount() async throws {
        let project = try await service.create(name: "Notes Test", type: .generic)
        
        // Create notes using database directly
        let note1 = Note(projectId: project.id, title: "Note 1", content: "")
        let note2 = Note(projectId: project.id, title: "Note 2", content: "")
        let note3 = Note(projectId: project.id, title: "Note 3", content: "")
        
        try await database.saveNote(note1)
        try await database.saveNote(note2)
        try await database.saveNote(note3)
        
        let count = try await service.noteCount(for: project.id)
        #expect(count == 3)
    }
}
