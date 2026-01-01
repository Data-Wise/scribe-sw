import XCTest
@testable import Scribe

/// Unit tests for AppState
final class AppStateTests: XCTestCase {
    
    // MARK: - Sidebar State Tests
    
    @MainActor
    func testSidebarInitiallyHidden() async {
        let appState = createAppState()
        XCTAssertFalse(appState.showSidebar, "Left sidebar should be hidden by default")
        XCTAssertFalse(appState.showRightSidebar, "Right sidebar should be hidden by default")
    }
    
    @MainActor
    func testToggleLeftSidebar() async {
        let appState = createAppState()
        
        appState.showSidebar.toggle()
        XCTAssertTrue(appState.showSidebar, "Left sidebar should be visible after toggle")
        
        appState.showSidebar.toggle()
        XCTAssertFalse(appState.showSidebar, "Left sidebar should be hidden after second toggle")
    }
    
    @MainActor
    func testToggleRightSidebar() async {
        let appState = createAppState()
        
        appState.showRightSidebar.toggle()
        XCTAssertTrue(appState.showRightSidebar, "Right sidebar should be visible after toggle")
        
        appState.showRightSidebar.toggle()
        XCTAssertFalse(appState.showRightSidebar, "Right sidebar should be hidden after second toggle")
    }
    
    @MainActor
    func testBothSidebarsCanBeOpenSimultaneously() async {
        let appState = createAppState()
        
        appState.showSidebar = true
        appState.showRightSidebar = true
        
        XCTAssertTrue(appState.showSidebar, "Left sidebar should be visible")
        XCTAssertTrue(appState.showRightSidebar, "Right sidebar should be visible")
    }
    
    // MARK: - Note Creation Tests
    
    @MainActor
    func testCreateNewNote() async {
        let appState = createAppState()
        let initialCount = appState.notes.count
        
        await appState.createNewNote()
        
        XCTAssertEqual(appState.notes.count, initialCount + 1, "Should have one more note after creation")
        XCTAssertNotNil(appState.selectedNoteId, "Selected note ID should be set")
    }
    
    // MARK: - Writing Stats Tests
    
    @MainActor
    func testWritingStatsInitialized() async {
        let appState = createAppState()
        
        XCTAssertEqual(appState.writingStats.sessionWordCount, 0, "Session word count should start at 0")
        XCTAssertEqual(appState.writingStats.todayWordCount, 0, "Today word count should start at 0")
    }
    
    @MainActor
    func testSessionTimerTickIncrementsOverTime() async {
        let appState = createAppState()
        let initialTick = appState.sessionTimerTick
        
        // Wait for timer to tick (timer fires every 1 second)
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        XCTAssertGreaterThan(appState.sessionTimerTick, initialTick, "Timer tick should increment")
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
