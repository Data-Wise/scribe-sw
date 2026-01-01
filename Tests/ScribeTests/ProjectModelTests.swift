import XCTest
import SwiftUI
@testable import Scribe

/// Unit tests for Project model
final class ProjectModelTests: XCTestCase {
    
    // MARK: - Model Creation
    
    func testProjectDefaultValues() {
        let project = Project(name: "Test")
        
        XCTAssertFalse(project.id.isEmpty)
        XCTAssertEqual(project.name, "Test")
        XCTAssertNil(project.description)
        XCTAssertEqual(project.type, .generic)
        XCTAssertNil(project.color)
        XCTAssertNil(project.icon)
    }
    
    func testProjectWithAllProperties() {
        let settings = ProjectSettings(
            bibliography: "refs.bib",
            citationStyle: "apa",
            exportTemplate: "default",
            aiContext: "Research project"
        )
        
        let project = Project(
            name: "Full Project",
            description: "A complete project",
            type: .research,
            color: "#FF0000",
            icon: "book",
            settings: settings
        )
        
        XCTAssertEqual(project.name, "Full Project")
        XCTAssertEqual(project.description, "A complete project")
        XCTAssertEqual(project.type, .research)
        XCTAssertEqual(project.color, "#FF0000")
        XCTAssertEqual(project.icon, "book")
        XCTAssertEqual(project.settings?.bibliography, "refs.bib")
        XCTAssertEqual(project.settings?.citationStyle, "apa")
    }
    
    // MARK: - ProjectSettings
    
    func testProjectSettingsDefaults() {
        let settings = ProjectSettings()
        
        XCTAssertNil(settings.bibliography)
        XCTAssertEqual(settings.citationStyle, "apa")
        XCTAssertEqual(settings.defaultFolder, "inbox")
    }
    
    func testProjectSettingsCodable() throws {
        let settings = ProjectSettings(
            bibliography: "test.bib",
            citationStyle: "chicago",
            exportTemplate: "article",
            aiContext: "AI context",
            defaultFolder: "drafts"
        )
        
        let encoded = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(ProjectSettings.self, from: encoded)
        
        XCTAssertEqual(decoded.bibliography, "test.bib")
        XCTAssertEqual(decoded.citationStyle, "chicago")
        XCTAssertEqual(decoded.exportTemplate, "article")
        XCTAssertEqual(decoded.aiContext, "AI context")
        XCTAssertEqual(decoded.defaultFolder, "drafts")
    }
    
    // MARK: - ProjectType
    
    func testAllProjectTypes() {
        let allTypes = ProjectType.allCases
        
        XCTAssertEqual(allTypes.count, 5)
        XCTAssertTrue(allTypes.contains(.research))
        XCTAssertTrue(allTypes.contains(.teaching))
        XCTAssertTrue(allTypes.contains(.rPackage))
        XCTAssertTrue(allTypes.contains(.rDev))
        XCTAssertTrue(allTypes.contains(.generic))
    }
    
    func testProjectTypeCodable() throws {
        for type in ProjectType.allCases {
            let encoded = try JSONEncoder().encode(type)
            let decoded = try JSONDecoder().decode(ProjectType.self, from: encoded)
            XCTAssertEqual(type, decoded)
        }
    }
    
    // MARK: - Coding Keys
    
    func testProjectCodingKeys() {
        XCTAssertEqual(Project.CodingKeys.createdAt.rawValue, "created_at")
        XCTAssertEqual(Project.CodingKeys.updatedAt.rawValue, "updated_at")
    }
    
    // MARK: - Color Extension
    
    func testProjectTypeSwiftUIColor() {
        for type in ProjectType.allCases {
            let color = type.swiftuiColor
            // Just verify it doesn't crash and returns a color
            XCTAssertNotNil(color)
        }
    }
    
    func testHexColorInitialization() {
        let red = Color(hex: "#FF0000")
        let green = Color(hex: "#00FF00")
        let blue = Color(hex: "#0000FF")
        
        // Verify colors are created without crashing
        XCTAssertNotNil(red)
        XCTAssertNotNil(green)
        XCTAssertNotNil(blue)
    }
    
    func testHexColorWithoutHash() {
        let color = Color(hex: "FF0000")
        XCTAssertNotNil(color)
    }
}
