import Testing
@testable import Scribe
import Foundation

@Suite("Utility Tests")
struct UtilityTests {
    @Test("Debouncer basic operation")
    @MainActor
    func debouncerBasic() async throws {
        let debouncer = Debouncer(delay: 0.1)
        var executed = false
        
        debouncer.debounce {
            executed = true
        }
        
        // Should not execute immediately
        #expect(executed == false)
        
        // Wait for debounce delay
        try await Task.sleep(nanoseconds: 150_000_000) // 150ms
        
        #expect(executed == true)
    }
    
    @Test("Debouncer cancels previous task")
    @MainActor
    func debouncerCancel() async throws {
        let debouncer = Debouncer(delay: 0.1)
        var count = 0
        
        // Trigger multiple times rapidly
        debouncer.debounce { count += 1 }
        debouncer.debounce { count += 1 }
        debouncer.debounce { count += 1 }
        
        try await Task.sleep(nanoseconds: 150_000_000)
        
        // Only last execution should run
        #expect(count == 1)
    }
    
    @Test("WritingStats initialization")
    func writingStatsInit() {
        let stats = WritingStats()
        
        #expect(stats.streak == 0)
        #expect(stats.wordsToday == 0)
        #expect(stats.weeklyGoal == 5000)
        #expect(stats.sessionStart != nil)
    }
    
    @Test("WritingStats weekly total calculation")
    func writingStatsWeeklyTotal() {
        var stats = WritingStats()
        stats.wordsThisWeek = [100, 200, 150, 180, 220, 190, 160]
        
        #expect(stats.weeklyTotal == 1200)
    }
    
    @Test("WritingStats weekly progress calculation")
    func writingStatsWeeklyProgress() {
        var stats = WritingStats()
        stats.weeklyGoal = 5000
        stats.wordsThisWeek = [100, 200, 150, 180, 220, 190, 160]
        
        #expect(abs(stats.weeklyProgress - 0.24) < 0.01) // 1200/5000 = 0.24
    }
    
    @Test("NoteTab equality")
    func noteTabEquality() {
        let tab1 = NoteTab(id: UUID(), noteId: "note-1", isPinned: false)
        let tab2 = NoteTab(id: tab1.id, noteId: "note-1", isPinned: false)
        
        #expect(tab1 == tab2)
    }
    
    @Test("NoteTab inequality")
    func noteTabInequality() {
        let tab1 = NoteTab(id: UUID(), noteId: "note-1", isPinned: false)
        let tab2 = NoteTab(id: UUID(), noteId: "note-2", isPinned: false)
        
        #expect(tab1 != tab2)
    }
    
    @Test("ScribeError descriptions")
    func scribeErrorDescriptions() {
        let noteNotFound = ScribeError.noteNotFound("test-id")
        #expect(noteNotFound.errorDescription?.contains("test-id") == true)
        
        let emptyTitle = ScribeError.emptyTitle
        #expect(emptyTitle.errorDescription?.contains("Title") == true)
        
        let duplicate = ScribeError.duplicateName("Test")
        #expect(duplicate.errorDescription?.contains("Test") == true)
    }
    
    @Test("ScribeError recovery suggestions")
    func scribeErrorRecovery() {
        let emptyTitle = ScribeError.emptyTitle
        #expect(emptyTitle.recoverySuggestion?.contains("title") == true)
        
        let duplicate = ScribeError.duplicateName("Test")
        #expect(duplicate.recoverySuggestion?.contains("different") == true)
    }
}
