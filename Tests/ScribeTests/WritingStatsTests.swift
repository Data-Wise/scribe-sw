import XCTest
@testable import Scribe

/// Unit tests for WritingStats model
final class WritingStatsTests: XCTestCase {
    
    // MARK: - Initialization
    
    func testInitialStats() {
        let stats = WritingStats()
        
        XCTAssertEqual(stats.sessionWordCount, 0)
        XCTAssertEqual(stats.todayWordCount, 0)
        XCTAssertEqual(stats.currentStreak, 0)
        XCTAssertNil(stats.lastWritingDate)
    }
    
    // MARK: - Goal Progress
    
    func testGoalProgressZero() {
        let stats = WritingStats()
        XCTAssertEqual(stats.goalProgress, 0.0)
    }
    
    func testGoalProgressPartial() {
        var stats = WritingStats()
        stats.todayWordCount = 250  // Half of 500 goal
        XCTAssertEqual(stats.goalProgress, 0.5, accuracy: 0.01)
    }
    
    func testGoalProgressComplete() {
        var stats = WritingStats()
        stats.todayWordCount = 500
        XCTAssertEqual(stats.goalProgress, 1.0)
    }
    
    func testGoalProgressCapsAtOne() {
        var stats = WritingStats()
        stats.todayWordCount = 1000  // Double the goal
        XCTAssertEqual(stats.goalProgress, 1.0, "Goal progress should cap at 1.0")
    }
    
    // MARK: - Session Duration Formatting
    
    func testSessionDurationFormatMinutes() {
        var stats = WritingStats()
        // Set start time to 5 minutes ago
        stats.sessionStartTime = Date().addingTimeInterval(-300)
        
        let formatted = stats.sessionDurationFormatted
        XCTAssertTrue(formatted.contains("m"), "Should show minutes: \(formatted)")
    }
    
    func testSessionDurationFormatHours() {
        var stats = WritingStats()
        // Set start time to 90 minutes ago
        stats.sessionStartTime = Date().addingTimeInterval(-5400)
        
        let formatted = stats.sessionDurationFormatted
        XCTAssertTrue(formatted.contains("h"), "Should show hours: \(formatted)")
    }
    
    // MARK: - Word Recording
    
    func testRecordWords() {
        var stats = WritingStats()
        
        stats.recordWords(count: 100, previousCount: 0)
        
        XCTAssertEqual(stats.sessionWordCount, 100)
        XCTAssertEqual(stats.todayWordCount, 100)
        XCTAssertNotNil(stats.lastWritingDate)
    }
    
    func testRecordWordsIncremental() {
        var stats = WritingStats()
        
        stats.recordWords(count: 50, previousCount: 0)
        stats.recordWords(count: 100, previousCount: 50)
        
        XCTAssertEqual(stats.sessionWordCount, 100)
        XCTAssertEqual(stats.todayWordCount, 100)
    }
    
    func testRecordWordsIgnoresDecrease() {
        var stats = WritingStats()
        
        stats.recordWords(count: 100, previousCount: 0)
        stats.recordWords(count: 50, previousCount: 100)  // User deleted text
        
        XCTAssertEqual(stats.sessionWordCount, 100, "Should not decrease on deletion")
    }
    
    // MARK: - Streak Calculation
    
    func testStreakStartsAtZero() {
        var stats = WritingStats()
        stats.calculateStreak()
        XCTAssertEqual(stats.currentStreak, 0)
    }
    
    func testStreakAfterWritingToday() {
        var stats = WritingStats()
        let today = WritingStats.dateKey(for: Date())
        stats.writingHistory[today] = 100
        
        stats.calculateStreak()
        XCTAssertEqual(stats.currentStreak, 1)
    }
    
    // MARK: - Persistence
    
    func testSaveAndLoad() {
        var stats = WritingStats()
        stats.todayWordCount = 123
        // Note: streak is recalculated on load based on history, so we test history instead
        let todayKey = WritingStats.dateKey(for: Date())
        stats.writingHistory[todayKey] = 100
        stats.save()
        
        let loaded = WritingStats.load()
        
        XCTAssertEqual(loaded.todayWordCount, 123)
        XCTAssertEqual(loaded.writingHistory[todayKey], 100)
        
        // Clean up
        WritingStats.clear()
    }
}
