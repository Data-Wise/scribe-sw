import XCTest
@testable import Scribe

/// Unit tests for ProjectService
final class ProjectServiceTests: XCTestCase {
    
    var projectService: ProjectService!
    
    @MainActor
    override func setUp() async throws {
        projectService = ProjectService(database: DatabaseManager.shared)
    }
    
    // MARK: - Create Tests
    
    @MainActor
    func testCreateProject() async throws {
        let project = try await projectService.create(
            name: "Test Project",
            description: "A test project",
            type: .research
        )
        
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertEqual(project.description, "A test project")
        XCTAssertEqual(project.type, .research)
        XCTAssertFalse(project.id.isEmpty)
        
        // Cleanup
        try await projectService.delete(id: project.id)
    }
    
    @MainActor
    func testCreateProjectWithDifferentTypes() async throws {
        let types: [ProjectType] = [.research, .teaching, .rPackage, .rDev, .generic]
        var createdProjects: [Project] = []
        
        for type in types {
            let project = try await projectService.create(
                name: "Project \(type.displayName)",
                type: type
            )
            XCTAssertEqual(project.type, type)
            createdProjects.append(project)
        }
        
        // Cleanup
        for project in createdProjects {
            try await projectService.delete(id: project.id)
        }
    }
    
    // MARK: - Fetch Tests
    
    @MainActor
    func testFetchProject() async throws {
        let created = try await projectService.create(name: "Fetch Test", type: .teaching)
        
        let fetched = try await projectService.fetch(id: created.id)
        
        XCTAssertEqual(fetched.id, created.id)
        XCTAssertEqual(fetched.name, "Fetch Test")
        XCTAssertEqual(fetched.type, .teaching)
        
        // Cleanup
        try await projectService.delete(id: created.id)
    }
    
    @MainActor
    func testFetchNonExistentProject() async {
        do {
            _ = try await projectService.fetch(id: "non-existent-id")
            XCTFail("Should throw projectNotFound error")
        } catch let error as ScribeError {
            if case .projectNotFound = error {
                // Expected
            } else {
                XCTFail("Expected projectNotFound error, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    @MainActor
    func testFetchAllProjects() async throws {
        let project1 = try await projectService.create(name: "All Test 1", type: .generic)
        let project2 = try await projectService.create(name: "All Test 2", type: .generic)
        
        let projects = try await projectService.fetchAll()
        
        XCTAssertGreaterThanOrEqual(projects.count, 2)
        
        // Cleanup
        try await projectService.delete(id: project1.id)
        try await projectService.delete(id: project2.id)
    }
    
    // MARK: - Update Tests
    
    @MainActor
    func testSaveProject() async throws {
        var project = try await projectService.create(name: "Original Name", type: .generic)
        project.name = "Updated Name"
        project.description = "New description"
        
        try await projectService.save(project)
        
        let fetched = try await projectService.fetch(id: project.id)
        XCTAssertEqual(fetched.name, "Updated Name")
        XCTAssertEqual(fetched.description, "New description")
        
        // Cleanup
        try await projectService.delete(id: project.id)
    }
    
    // MARK: - Delete Tests
    
    @MainActor
    func testDeleteProject() async throws {
        let project = try await projectService.create(name: "To Delete", type: .generic)
        
        try await projectService.delete(id: project.id)
        
        do {
            _ = try await projectService.fetch(id: project.id)
            XCTFail("Should throw projectNotFound after deletion")
        } catch let error as ScribeError {
            if case .projectNotFound = error {
                // Expected
            } else {
                XCTFail("Expected projectNotFound error")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    // MARK: - ProjectType Tests
    
    func testProjectTypeDisplayNames() {
        XCTAssertEqual(ProjectType.research.displayName, "Research")
        XCTAssertEqual(ProjectType.teaching.displayName, "Teaching")
        XCTAssertEqual(ProjectType.rPackage.displayName, "R Package")
        XCTAssertEqual(ProjectType.rDev.displayName, "R Dev")
        XCTAssertEqual(ProjectType.generic.displayName, "Generic")
    }
    
    func testProjectTypeEmojis() {
        XCTAssertEqual(ProjectType.research.emoji, "🔬")
        XCTAssertEqual(ProjectType.teaching.emoji, "📚")
        XCTAssertEqual(ProjectType.rPackage.emoji, "📦")
        XCTAssertEqual(ProjectType.rDev.emoji, "🛠️")
        XCTAssertEqual(ProjectType.generic.emoji, "📁")
    }
    
    func testProjectTypeColors() {
        // Just verify they don't crash
        for type in ProjectType.allCases {
            XCTAssertFalse(type.defaultColor.isEmpty)
            _ = type.swiftuiColor // Should not crash
        }
    }
}
