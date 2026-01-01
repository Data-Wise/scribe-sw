import XCTest
@testable import Scribe

/// Unit tests for ErrorDialog feature
final class ErrorDialogTests: XCTestCase {
    
    // MARK: - AppState Error Dialog Tests
    
    @MainActor
    func testErrorDialogInitiallyHidden() async {
        let appState = createAppState()
        XCTAssertFalse(appState.showErrorDialog, "Error dialog should be hidden by default")
    }
    
    @MainActor
    func testShowError() async {
        let appState = createAppState()
        
        appState.showError(title: "Test Error", message: "Something went wrong")
        
        XCTAssertTrue(appState.showErrorDialog, "Error dialog should be shown")
        XCTAssertEqual(appState.errorTitle, "Test Error")
        XCTAssertEqual(appState.errorMessage, "Something went wrong")
        XCTAssertEqual(appState.errorLevel, .error)
    }
    
    @MainActor
    func testShowWarning() async {
        let appState = createAppState()
        
        appState.showError(title: "Test Warning", message: "Be careful", level: .warning)
        
        XCTAssertTrue(appState.showErrorDialog, "Error dialog should be shown")
        XCTAssertEqual(appState.errorLevel, .warning)
    }
    
    @MainActor
    func testDismissErrorDialog() async {
        let appState = createAppState()
        
        appState.showError(title: "Error", message: "Test")
        XCTAssertTrue(appState.showErrorDialog)
        
        appState.showErrorDialog = false
        XCTAssertFalse(appState.showErrorDialog, "Error dialog should be dismissable")
    }
    
    // MARK: - Helpers
    
    @MainActor
    private func createAppState() -> AppState {
        return AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
    }
}
