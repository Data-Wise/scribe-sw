import XCTest
@testable import Scribe

/// Unit tests for ScribeError
final class ScribeErrorTests: XCTestCase {
    
    func testNoteNotFoundError() {
        let error = ScribeError.noteNotFound("test-id")
        
        if case .noteNotFound(let id) = error {
            XCTAssertEqual(id, "test-id")
        } else {
            XCTFail("Wrong error type")
        }
    }
    
    func testProjectNotFoundError() {
        let error = ScribeError.projectNotFound("project-id")
        
        if case .projectNotFound(let id) = error {
            XCTAssertEqual(id, "project-id")
        } else {
            XCTFail("Wrong error type")
        }
    }
    
    func testDatabaseInitializationError() {
        let underlying = NSError(domain: "test", code: 1, userInfo: nil)
        let error = ScribeError.databaseInitializationFailed(underlying)
        
        if case .databaseInitializationFailed(let wrapped) = error {
            XCTAssertEqual((wrapped as NSError).code, 1)
        } else {
            XCTFail("Wrong error type")
        }
    }
    
    func testUnknownError() {
        let underlying = NSError(domain: "unknown", code: 42, userInfo: nil)
        let error = ScribeError.unknown(underlying)
        
        if case .unknown(let wrapped) = error {
            XCTAssertEqual((wrapped as NSError).code, 42)
        } else {
            XCTFail("Wrong error type")
        }
    }
    
    func testErrorDescriptions() {
        let noteError = ScribeError.noteNotFound("id")
        let projectError = ScribeError.projectNotFound("id")
        let dbError = ScribeError.databaseInitializationFailed(NSError(domain: "", code: 0))
        let unknown = ScribeError.unknown(NSError(domain: "", code: 0))
        
        // Just verify they have descriptions (don't crash)
        XCTAssertNotNil(noteError.errorDescription)
        XCTAssertNotNil(projectError.errorDescription)
        XCTAssertNotNil(dbError.errorDescription)
        XCTAssertNotNil(unknown.errorDescription)
    }
    
    func testRecoverySuggestions() {
        let errors: [ScribeError] = [
            .noteNotFound("id"),
            .projectNotFound("id"),
            .emptyTitle,
            .invalidProjectType("test"),
            .duplicateName("test"),
            .fileReadFailed("path"),
            .unknown(NSError(domain: "", code: 0))
        ]
        
        for error in errors {
            XCTAssertNotNil(error.recoverySuggestion)
            XCTAssertNotNil(error.failureReason)
        }
    }
    
    func testEmptyTitleError() {
        let error = ScribeError.emptyTitle
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("empty") ?? false)
    }
    
    func testFileErrors() {
        let readError = ScribeError.fileReadFailed("/path/to/file")
        let writeError = ScribeError.fileWriteFailed("/path/to/file")
        let pathError = ScribeError.invalidPath("/invalid")
        
        XCTAssertNotNil(readError.errorDescription)
        XCTAssertNotNil(writeError.errorDescription)
        XCTAssertNotNil(pathError.errorDescription)
    }
}
