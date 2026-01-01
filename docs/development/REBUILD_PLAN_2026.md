# Scribe SwiftUI - Comprehensive Rebuild Plan 2026

**Document Created:** January 1, 2026  
**Status:** Fresh start - Old frontend deleted, backend preserved  
**Target:** Working ADHD-friendly writing app in 2 weeks

---

## Table of Contents

1. [Current State](#current-state)
2. [Architecture Overview](#architecture-overview)
3. [Phase 1: Enhanced Focus Mode (Week 1)](#phase-1-enhanced-focus-mode-week-1)
4. [Phase 2: Navigator Mode (Week 2)](#phase-2-navigator-mode-week-2)
5. [Phase 3: Markdown Preview (Deferred)](#phase-3-markdown-preview-deferred)
6. [Phase 4: Advanced Features (Future)](#phase-4-advanced-features-future)
7. [Implementation Guidelines](#implementation-guidelines)
8. [Testing Strategy](#testing-strategy)

---

## Current State

### What We Have (Backend - 100% Complete)

**Total:** 10 Swift files, 1137 lines of clean code

```
Sources/Scribe/
├── Data/
│   └── DatabaseManager.swift          (240 lines) ✅ KEEP - Actor-based GRDB wrapper
├── Domain/Services/
│   ├── NoteService.swift              (100 lines) ✅ KEEP - Async CRUD operations
│   └── ProjectService.swift           (60 lines) ✅ KEEP - Project management
├── Models/
│   ├── Note.swift                     (70 lines) ✅ KEEP - Note model
│   ├── Project.swift                  (150 lines) ✅ KEEP - Project model
│   └── ScribeError.swift              ✅ KEEP - Error types
├── Store/
│   └── AppState.swift                 (156 lines) ✅ KEEP (will enhance)
├── Views/
│   ├── DesignSystem.swift             (180 lines) ✅ KEEP - Colors/fonts/spacing
│   └── MainView.swift                 (27 lines) 🚧 MINIMAL PLACEHOLDER
└── ScribeApp.swift                    (19 lines) ✅ KEEP - App entry point
```

**Backend Features (All Working):**
- ✅ Actor-based DatabaseManager (thread-safe)
- ✅ GRDB migrations (v1: core schema, v2: FTS5)
- ✅ Full-text search (SQLite FTS5)
- ✅ Async/await throughout
- ✅ Clean error handling (ScribeError enum)
- ✅ Word count tracking
- ✅ Project organization (Research, Teaching, R Packages)

**What We Deleted (Old Frontend):**
- ❌ Old MainView.swift (toolbar-heavy, not ADHD-friendly)
- ❌ Old EditorView.swift (basic, no markdown awareness)
- ❌ Old StatsFooter.swift (only 2 metrics, not live)
- ❌ Resources/codemirror/ (unused)
- ❌ Resources/lexical/ (unused)

**Build Status:**
```bash
Build complete! (~3s)
✅ 0 errors
✅ 0 warnings
✅ Clean slate for Phase 1
```

---

## Architecture Overview

### Data Flow (Already Implemented)

```
┌─────────────────────────────────────────────────┐
│ UI Layer (SwiftUI)                              │
│  ├─ MainView (container)                        │
│  ├─ EditorView (focus mode)                     │
│  ├─ StatsFooter (5 metrics)                     │
│  └─ SidebarView (navigator mode)                │
│           ↕                                      │
│  @EnvironmentObject AppState                    │
└─────────────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────────────┐
│ State Layer (@MainActor)                        │
│  AppState (ObservableObject)                    │
│   ├─ @Published notes: [Note]                   │
│   ├─ @Published projects: [Project]             │
│   ├─ @Published selectedNoteId: String?         │
│   ├─ @Published writingStats: WritingStats      │ ← NEW (Phase 1)
│   ├─ @Published isLoading: Bool                 │
│   └─ @Published error: ScribeError?             │
└─────────────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────────────┐
│ Service Layer                                   │
│  ├─ NoteService (async CRUD)                    │
│  └─ ProjectService (async CRUD)                 │
└─────────────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────────────┐
│ Data Layer (Actor)                              │
│  DatabaseManager (singleton)                    │
│   └─ GRDB + SQLite                              │
│      ├─ notes table                             │
│      ├─ projects table                          │
│      └─ notes_fts (full-text search)            │
└─────────────────────────────────────────────────┘
```

### Key Patterns (Follow These)

**1. View → AppState → Service → DatabaseManager**
```swift
// ✅ Correct pattern
Button("Save") {
    Task {
        await appState.saveNote(note)  // AppState → Service → DatabaseManager
    }
}

// ❌ Wrong pattern
Button("Save") {
    Task {
        try await DatabaseManager.shared.save(note)  // Bypass services!
    }
}
```

**2. Always use @MainActor for UI state**
```swift
@MainActor
class AppState: ObservableObject {
    @Published var notes: [Note] = []
    // All UI updates happen on main thread
}
```

**3. Always use async/await for data operations**
```swift
// ✅ Correct
let notes = try await noteService.fetchAll()

// ❌ Wrong (blocking)
let notes = noteService.fetchAllSync()  // Don't create sync versions!
```

---

## Phase 1: Enhanced Focus Mode (Week 1)

### Goal
Working distraction-free editor with live 5-metric stats and auto-save

### Timeline
- **Start:** January 1, 2026 (Today)
- **End:** January 7, 2026
- **Duration:** 7 days
- **Effort:** ~2-3 hours/day

### Success Criteria
- ✅ App opens to clean editor (no toolbar, no chrome)
- ✅ Stats footer shows all 5 metrics (updating every 1s)
- ✅ Auto-save works seamlessly (1s debounce)
- ✅ Keyboard shortcuts work (⌘B, ⌘N, ⌘W)
- ✅ Stats persist across launches (UserDefaults)
- ✅ Streak calculation works (consecutive days)

---

### Day 1-2: Stats Foundation

#### Task 1.1: Create WritingStats Model

**File:** `Sources/Scribe/Models/WritingStats.swift` (NEW)

**Requirements:**
```swift
struct WritingStats: Codable, Sendable {
    // Session tracking (resets on app relaunch)
    var sessionStartTime: Date
    var sessionWordCount: Int
    
    // Persistent tracking (saved to UserDefaults)
    var todayDate: Date          // Date of today (midnight)
    var todayWordCount: Int      // Total words written today
    var currentStreak: Int       // Consecutive days with writing
    var lastWritingDate: Date    // Last date user wrote anything
    
    // Settings (future: make user-configurable)
    let dailyGoal: Int = 500     // Words per day goal
    
    // Computed properties
    var sessionDuration: TimeInterval {
        Date().timeIntervalSince(sessionStartTime)
    }
    
    var sessionDurationFormatted: String {
        let minutes = Int(sessionDuration) / 60
        let seconds = Int(sessionDuration) % 60
        return String(format: "%dm %02ds", minutes, seconds)
    }
    
    var goalProgress: Double {
        min(Double(todayWordCount) / Double(dailyGoal), 1.0)
    }
    
    // Initialize with defaults
    static func `default`() -> WritingStats {
        WritingStats(
            sessionStartTime: Date(),
            sessionWordCount: 0,
            todayDate: Calendar.current.startOfDay(for: Date()),
            todayWordCount: 0,
            currentStreak: 0,
            lastWritingDate: Date()
        )
    }
}
```

**Implementation Time:** 30 minutes

---

#### Task 1.2: Update AppState with Stats Tracking

**File:** `Sources/Scribe/Store/AppState.swift` (MODIFY)

**Changes:**
```swift
@MainActor
class AppState: ObservableObject {
    // ... existing properties ...
    
    // NEW: Writing stats tracking
    @Published var writingStats: WritingStats = .default()
    
    // NEW: Timer for live stats updates
    private var statsTimer: Timer?
    
    // ... existing init ...
    
    init(noteService: NoteService, projectService: ProjectService) {
        // ... existing initialization ...
        
        // Load stats from UserDefaults
        loadStats()
        
        // Start timer for live updates (every 1s)
        startStatsTimer()
    }
    
    deinit {
        statsTimer?.invalidate()
    }
    
    // MARK: - Stats Management
    
    func loadStats() {
        guard let data = UserDefaults.standard.data(forKey: "writingStats"),
              let stats = try? JSONDecoder().decode(WritingStats.self, from: data) else {
            writingStats = .default()
            return
        }
        
        writingStats = stats
        
        // Check if it's a new day
        if !Calendar.current.isDateInToday(stats.todayDate) {
            resetDailyStats()
        }
        
        calculateStreak()
    }
    
    func saveStats() {
        guard let data = try? JSONEncoder().encode(writingStats) else { return }
        UserDefaults.standard.set(data, forKey: "writingStats")
    }
    
    func resetDailyStats() {
        writingStats.todayDate = Calendar.current.startOfDay(for: Date())
        writingStats.todayWordCount = 0
        saveStats()
    }
    
    func calculateStreak() {
        let calendar = Calendar.current
        let today = Date()
        let lastWrite = writingStats.lastWritingDate
        
        if calendar.isDateInToday(lastWrite) {
            // Same day, keep streak
            return
        } else if calendar.isDateInYesterday(lastWrite) {
            // Consecutive day, increment
            writingStats.currentStreak += 1
        } else {
            // Broke streak
            writingStats.currentStreak = 0
        }
        
        saveStats()
    }
    
    func updateWordCount(for noteId: String, newCount: Int) {
        guard let note = notes.first(where: { $0.id == noteId }),
              newCount > note.wordCount else { return }
        
        let delta = newCount - note.wordCount
        
        // Update session stats
        writingStats.sessionWordCount += delta
        
        // Update daily stats
        if Calendar.current.isDateInToday(writingStats.todayDate) {
            writingStats.todayWordCount += delta
        } else {
            // New day - reset
            resetDailyStats()
            writingStats.todayWordCount = delta
        }
        
        // Update last writing date
        writingStats.lastWritingDate = Date()
        calculateStreak()
        
        saveStats()
    }
    
    private func startStatsTimer() {
        statsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // Force UI update every 1s (for session timer)
            self.objectWillChange.send()
        }
    }
}
```

**Implementation Time:** 1 hour

---

#### Task 1.3: Rebuild StatsFooter with 5 Metrics

**File:** `Sources/Scribe/Views/StatsFooter.swift` (CREATE NEW)

**Design:**
```
┌──────────────────────────────────────────────────────────────┐
│  📝 234 words · ⏱ 12m 34s · 🔥 7 days · ⚡ 1,243 · 🎯 ████░ 50% │
└──────────────────────────────────────────────────────────────┘
```

**Implementation:**
```swift
import SwiftUI

struct StatsFooter: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: ScribeSpacing.md) {
            // 1. Current note word count
            StatItem(
                icon: "📝",
                value: "\(currentNoteWordCount) words"
            )
            
            Divider()
                .frame(height: 16)
                .foregroundColor(ScribeColors.border)
            
            // 2. Session timer (live)
            StatItem(
                icon: "⏱",
                value: appState.writingStats.sessionDurationFormatted
            )
            
            Divider()
                .frame(height: 16)
                .foregroundColor(ScribeColors.border)
            
            // 3. Streak counter
            StatItem(
                icon: "🔥",
                value: "\(appState.writingStats.currentStreak) days"
            )
            
            Divider()
                .frame(height: 16)
                .foregroundColor(ScribeColors.border)
            
            // 4. Today's word count
            StatItem(
                icon: "⚡",
                value: "\(appState.writingStats.todayWordCount)"
            )
            
            Divider()
                .frame(height: 16)
                .foregroundColor(ScribeColors.border)
            
            // 5. Goal progress
            GoalProgress(
                current: appState.writingStats.todayWordCount,
                goal: appState.writingStats.dailyGoal
            )
        }
        .padding(.horizontal, ScribeSpacing.md)
        .padding(.vertical, ScribeSpacing.sm)
        .frame(height: 32)
        .background(ScribeColors.surface)
        .border(ScribeColors.border, width: 1)
    }
    
    private var currentNoteWordCount: Int {
        guard let noteId = appState.selectedNoteId,
              let note = appState.notes.first(where: { $0.id == noteId }) else {
            return 0
        }
        return note.wordCount
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(ScribeFonts.statsSmall)
            Text(value)
                .font(ScribeFonts.statsSmall)
                .foregroundColor(ScribeColors.textSecondary)
        }
    }
}

struct GoalProgress: View {
    let current: Int
    let goal: Int
    
    var progress: Double {
        min(Double(current) / Double(goal), 1.0)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text("🎯")
                .font(ScribeFonts.statsSmall)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(ScribeColors.border)
                        .frame(width: 60, height: 8)
                        .cornerRadius(4)
                    
                    // Progress
                    Rectangle()
                        .fill(ScribeColors.success)
                        .frame(width: 60 * progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(width: 60, height: 8)
            
            Text("\(Int(progress * 100))%")
                .font(ScribeFonts.statsSmall)
                .foregroundColor(ScribeColors.textSecondary)
                .frame(width: 36, alignment: .trailing)
        }
    }
}

#Preview {
    StatsFooter()
        .environmentObject(AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        ))
}
```

**Implementation Time:** 1 hour

---

### Day 3-4: Enhanced Editor

#### Task 2.1: Create EditorView with Auto-Save

**File:** `Sources/Scribe/Views/EditorView.swift` (CREATE NEW)

**Requirements:**
- Clean, minimal editor (just title + content)
- Auto-save with 1s debounce
- Word count calculation on every change
- Auto-focus on load

**Implementation:**
```swift
import SwiftUI

struct EditorView: View {
    @EnvironmentObject var appState: AppState
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var saveTask: Task<Void, Never>?
    
    var body: some View {
        VStack(spacing: 0) {
            // Title field
            TextField("Untitled", text: $title)
                .font(ScribeFonts.noteTitle)
                .foregroundColor(ScribeColors.textPrimary)
                .textFieldStyle(.plain)
                .padding(.horizontal, ScribeSpacing.xxl)
                .padding(.top, ScribeSpacing.xl)
                .padding(.bottom, ScribeSpacing.md)
                .onChange(of: title) { _, newValue in
                    scheduleAutoSave()
                }
            
            Divider()
                .background(ScribeColors.border)
            
            // Content editor
            TextEditor(text: $content)
                .font(ScribeFonts.editor)
                .foregroundColor(ScribeColors.textPrimary)
                .scrollContentBackground(.hidden)
                .background(ScribeColors.background)
                .padding(.horizontal, ScribeSpacing.xxl)
                .padding(.vertical, ScribeSpacing.lg)
                .onChange(of: content) { _, newValue in
                    updateWordCount(newValue)
                    scheduleAutoSave()
                }
        }
        .background(ScribeColors.background)
        .onAppear {
            loadCurrentNote()
        }
    }
    
    private func loadCurrentNote() {
        guard let noteId = appState.selectedNoteId,
              let note = appState.notes.first(where: { $0.id == noteId }) else {
            title = ""
            content = ""
            return
        }
        
        title = note.title
        content = note.content
    }
    
    private func updateWordCount(_ text: String) {
        let words = text.split(separator: " ").count
        
        guard let noteId = appState.selectedNoteId else { return }
        appState.updateWordCount(for: noteId, newCount: words)
    }
    
    private func scheduleAutoSave() {
        // Cancel previous save task
        saveTask?.cancel()
        
        // Schedule new save after 1s debounce
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            guard !Task.isCancelled else { return }
            await saveCurrentNote()
        }
    }
    
    private func saveCurrentNote() async {
        guard let noteId = appState.selectedNoteId else { return }
        
        // Update note
        var note = appState.notes.first { $0.id == noteId } ?? Note(
            id: noteId,
            projectId: nil,
            title: title,
            content: content
        )
        
        note.title = title
        note.content = content
        note.wordCount = content.split(separator: " ").count
        note.updatedAt = Date()
        
        await appState.saveNote(note)
    }
}

#Preview {
    EditorView()
        .environmentObject(AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        ))
}
```

**Implementation Time:** 1.5 hours

---

#### Task 2.2: Update MainView with Keyboard Shortcuts

**File:** `Sources/Scribe/Views/MainView.swift` (REPLACE)

**Design:**
```
┌────────────────────────────────────┐
│                                    │
│     Untitled                       │
│                                    │
│     [Content here...]              │
│                                    │
│  📝234w·⏱12m·🔥7d·⚡15·🎯50%      │
└────────────────────────────────────┘

Focus Mode (default)
No sidebar, no toolbar
Just: Editor + Stats footer
```

**Implementation:**
```swift
import SwiftUI
import KeyboardShortcuts

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSidebar = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Editor (full screen)
            EditorView()
            
            // Stats footer (always visible)
            StatsFooter()
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(ScribeColors.background)
        .onAppear {
            setupKeyboardShortcuts()
        }
    }
    
    private func setupKeyboardShortcuts() {
        // ⌘B - Toggle sidebar (Phase 2)
        KeyboardShortcuts.onKeyDown(for: .toggleSidebar) {
            showSidebar.toggle()
        }
        
        // ⌘N - New note
        KeyboardShortcuts.onKeyDown(for: .newNote) {
            Task {
                await appState.createNewNote()
            }
        }
        
        // ⌘W - Close window (macOS handles this, but we can clean up)
        KeyboardShortcuts.onKeyDown(for: .closeWindow) {
            // Auto-save happens automatically via debounce
            // Just let macOS close the window
        }
    }
}

// MARK: - Keyboard Shortcut Extensions

extension KeyboardShortcuts.Name {
    static let toggleSidebar = Self("toggleSidebar", default: .init(.b, modifiers: [.command]))
    static let newNote = Self("newNote", default: .init(.n, modifiers: [.command]))
    static let closeWindow = Self("closeWindow", default: .init(.w, modifiers: [.command]))
}

#Preview {
    MainView()
        .environmentObject(AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        ))
}
```

**Implementation Time:** 1 hour

---

### Day 5-7: Testing & Polish

#### Task 3.1: Testing Checklist

**Manual Testing:**
- [ ] App launches without errors
- [ ] Editor shows and accepts input
- [ ] Title field works
- [ ] Content field works
- [ ] Stats footer appears at bottom
- [ ] Word count updates on typing
- [ ] Session timer increments every second
- [ ] Streak persists across launches
- [ ] Today's word count persists across launches
- [ ] Goal progress bar shows correct percentage
- [ ] Auto-save works (1s after typing stops)
- [ ] ⌘B does nothing yet (Phase 2)
- [ ] ⌘N creates new note
- [ ] ⌘W closes window without prompt
- [ ] App reopens to last note
- [ ] Stats persist after quit/relaunch

**Performance Testing:**
- [ ] Typing feels instant (< 50ms lag)
- [ ] Stats updates don't cause UI lag
- [ ] Auto-save doesn't block UI
- [ ] App uses < 100MB RAM
- [ ] Build time < 30s

**Edge Cases:**
- [ ] Empty note (0 words)
- [ ] Very long note (> 10,000 words)
- [ ] Special characters in title
- [ ] Emoji in content
- [ ] Multiple spaces between words
- [ ] New day rollover (streak calculation)

**Implementation Time:** 3 hours

---

#### Task 3.2: Refinements

**Based on testing, refine:**
- [ ] Font sizes (if too small/large)
- [ ] Spacing (if cramped/too spacious)
- [ ] Colors (if hard to read)
- [ ] Auto-save timing (if too aggressive/slow)
- [ ] Stats update frequency (if too fast/slow)

**Implementation Time:** 2 hours

---

### Phase 1 Completion Criteria

**Deliverables:**
- ✅ WritingStats.swift created and working
- ✅ AppState.swift enhanced with stats tracking
- ✅ StatsFooter.swift shows all 5 metrics
- ✅ EditorView.swift with auto-save
- ✅ MainView.swift with keyboard shortcuts
- ✅ All manual tests pass
- ✅ Build is clean (0 warnings, 0 errors)
- ✅ Performance is good (< 50ms lag, < 30s build)

**Success Metrics:**
- Time to start writing: < 3 seconds (open app → start typing)
- Auto-save delay: 1 second
- Stats update frequency: 1 second
- Memory usage: < 100MB
- Build time: < 30 seconds

---

## Phase 2: Navigator Mode (Week 2)

### Goal
Sidebar with project organization and recent notes

### Timeline
- **Start:** January 8, 2026
- **End:** January 14, 2026
- **Duration:** 7 days
- **Effort:** ~2-3 hours/day

### Tasks Overview

**Day 1-2: Sidebar Foundation**
- Create SidebarView component
- Add toggle animation (⌘B)
- Auto-hide on editor click

**Day 3-4: Project Section**
- ProjectSection component with icons (🔬📚📦)
- Click to filter notes by project
- Expand/collapse groups

**Day 5-6: Recent Notes Section**
- RecentSection component (last 10 notes)
- Click to open note
- Search field (instant filter)

**Day 7: Polish**
- Smooth animations (0.2s easing)
- Hover states
- Selected item highlighting
- Testing

**Detailed implementation plan in Phase 2 section below...**

---

## Phase 3: Markdown Preview (Deferred)

**Status:** Deferred until Phases 1-2 complete  
**Reason:** Focus on core ADHD-friendly features first  
**Timeline:** TBD (after Phase 2 working)

### Features
- Split view (source | preview)
- Live markdown rendering (swift-markdown)
- Scroll sync
- ⌘P toggle

---

## Phase 4: Advanced Features (Future)

**Status:** Future work  
**Timeline:** After Phase 3

### Features
- LaTeX rendering (MathJax/KaTeX)
- Wiki links `[[...]]` with autocomplete
- Command palette (⌘K)
- Tags system
- Export (PDF, HTML, Markdown)
- Themes (custom color schemes)
- iCloud sync

---

## Implementation Guidelines

### Code Standards

**1. Keep Backend Untouched**
```swift
// ❌ Do NOT modify these files
DatabaseManager.swift
NoteService.swift
ProjectService.swift
Note.swift
Project.swift
ScribeError.swift
```

**2. Always Use Services**
```swift
// ✅ Correct
await appState.saveNote(note)  // AppState → Service → Database

// ❌ Wrong
await DatabaseManager.shared.save(note)  // Bypass services!
```

**3. Use @MainActor for UI State**
```swift
@MainActor
class AppState: ObservableObject {
    @Published var notes: [Note] = []
}
```

**4. Use async/await Everywhere**
```swift
// ✅ Correct
let notes = try await noteService.fetchAll()

// ❌ Wrong
let notes = noteService.fetchAllSync()  // No sync methods!
```

**5. Handle Errors Gracefully**
```swift
do {
    let notes = try await noteService.fetchAll()
} catch let error as ScribeError {
    appState.error = error
} catch {
    appState.error = .unknown(error)
}
```

### ADHD Design Principles

**Every feature must pass this filter:**

1. **Zero Friction** (< 3 seconds to start writing)
   - App opens directly to editor
   - No splash screens, no setup wizards
   - Auto-focus on launch
   - Auto-save (never ask)

2. **One Thing at a Time**
   - Single pane focus mode (default)
   - Minimal UI chrome
   - No tabs
   - Full-screen encouraged

3. **Escape Hatches Everywhere**
   - ⌘W closes without confirmation
   - ESC exits modes
   - ⌘B toggles sidebar (quick exit)
   - All actions keyboard-accessible

4. **Visible Progress**
   - Stats footer always visible
   - Real-time updates (every 1s)
   - Streak tracking
   - Goal progress bar

5. **Sensory-Friendly**
   - Dark mode by default
   - Minimal animations
   - Soft colors (no harsh whites)
   - Comfortable fonts

### Design System Usage

**Always use DesignSystem constants:**

```swift
// Colors
background: ScribeColors.background
text: ScribeColors.textPrimary
accent: ScribeColors.accent
success: ScribeColors.success

// Fonts
editor: ScribeFonts.editor
title: ScribeFonts.noteTitle
stats: ScribeFonts.statsSmall

// Spacing
tight: ScribeSpacing.xs
normal: ScribeSpacing.md
wide: ScribeSpacing.xl
```

---

## Testing Strategy

### Manual Testing (Each Phase)

**Functional Testing:**
- [ ] All features work as specified
- [ ] No crashes or hangs
- [ ] Data persists correctly
- [ ] Keyboard shortcuts work
- [ ] Auto-save doesn't lose data

**Performance Testing:**
- [ ] Typing feels instant (< 50ms)
- [ ] UI updates don't lag
- [ ] Build time < 30s
- [ ] Memory < 100MB
- [ ] CPU idle when not typing

**ADHD Testing:**
- [ ] Can start writing in < 3 seconds
- [ ] No UI distractions
- [ ] Stats are visible and motivating
- [ ] Escape hatches work (⌘W, ⌘B)
- [ ] Colors are comfortable (dark mode)

### Automated Testing (Future)

**After Phase 2, migrate to XCTest:**
```swift
import XCTest
@testable import Scribe

final class NoteServiceTests: XCTestCase {
    func testFetchNote() async throws {
        let service = NoteService(database: MockDatabaseManager())
        let note = try await service.fetch(id: "test-1")
        XCTAssertEqual(note.title, "Test Note")
    }
}
```

---

## Phase 2 Detailed Plan (Navigator Mode)

### Day 1-2: Sidebar Foundation

#### Task 1: Create SidebarView Component

**File:** `Sources/Scribe/Views/Components/Sidebar/SidebarView.swift` (CREATE)

**Design:**
```
┌────────┐
│PROJECTS│
│🔬Research
│📚Teaching
│📦R Packages
│        │
│RECENT  │
│•Note 1 │
│•Note 2 │
│•Note 3 │
└────────┘
```

**Implementation:**
```swift
import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Search field
            SearchField(text: $searchText)
                .padding(ScribeSpacing.sm)
            
            Divider()
                .background(ScribeColors.border)
            
            // Scrollable content
            ScrollView {
                VStack(spacing: ScribeSpacing.md) {
                    ProjectSection()
                    RecentSection()
                }
                .padding(ScribeSpacing.sm)
            }
        }
        .frame(width: 200)
        .background(ScribeColors.surface)
        .border(ScribeColors.border, width: 1)
    }
}
```

**Implementation Time:** 1 hour

---

#### Task 2: Update MainView with Sidebar Toggle

**File:** `Sources/Scribe/Views/MainView.swift` (MODIFY)

**Changes:**
```swift
struct MainView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSidebar = false  // Default: hidden (Focus Mode)
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar (conditional)
            if showSidebar {
                SidebarView()
                    .transition(.move(edge: .leading))
            }
            
            // Editor (main area)
            VStack(spacing: 0) {
                EditorView()
                StatsFooter()
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(ScribeColors.background)
        .onAppear {
            setupKeyboardShortcuts()
        }
    }
    
    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyDown(for: .toggleSidebar) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showSidebar.toggle()
            }
        }
        
        // ... other shortcuts ...
    }
}
```

**Implementation Time:** 30 minutes

---

### Day 3-4: Project Section

#### Task 3: Create ProjectSection Component

**File:** `Sources/Scribe/Views/Components/Sidebar/ProjectSection.swift` (CREATE)

**Design:**
```
PROJECTS
🔬 Research       (12)
📚 Teaching        (8)
📦 R Packages      (5)
```

**Implementation:**
```swift
import SwiftUI

struct ProjectSection: View {
    @EnvironmentObject var appState: AppState
    @State private var expandedProjects: Set<String> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: ScribeSpacing.xs) {
            // Section header
            Text("PROJECTS")
                .font(ScribeFonts.uiCaption)
                .foregroundColor(ScribeColors.textTertiary)
                .padding(.horizontal, ScribeSpacing.sm)
            
            // Project list
            ForEach(appState.projects) { project in
                ProjectRow(
                    project: project,
                    noteCount: appState.notes.filter { $0.projectId == project.id }.count,
                    isExpanded: expandedProjects.contains(project.id)
                )
                .onTapGesture {
                    filterByProject(project)
                }
            }
        }
    }
    
    private func filterByProject(_ project: Project) {
        // Filter notes by project
        appState.filteredProjectId = project.id
    }
}

struct ProjectRow: View {
    let project: Project
    let noteCount: Int
    let isExpanded: Bool
    
    var body: some View {
        HStack {
            Text(project.icon)
                .font(.system(size: 14))
            
            Text(project.name)
                .font(ScribeFonts.uiBody)
                .foregroundColor(ScribeColors.textPrimary)
            
            Spacer()
            
            Text("\(noteCount)")
                .font(ScribeFonts.uiCaption)
                .foregroundColor(ScribeColors.textSecondary)
        }
        .padding(.horizontal, ScribeSpacing.sm)
        .padding(.vertical, ScribeSpacing.xs)
        .background(isExpanded ? ScribeColors.accent.opacity(0.1) : Color.clear)
        .cornerRadius(4)
    }
}
```

**Implementation Time:** 2 hours

---

### Day 5-6: Recent Notes Section

#### Task 4: Create RecentSection Component

**File:** `Sources/Scribe/Views/Components/Sidebar/RecentSection.swift` (CREATE)

**Design:**
```
RECENT
• Statistical Power Analysis
• Causal Inference Notes
• R Package Planning
```

**Implementation:**
```swift
import SwiftUI

struct RecentSection: View {
    @EnvironmentObject var appState: AppState
    
    var recentNotes: [Note] {
        Array(appState.notes
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(10))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ScribeSpacing.xs) {
            // Section header
            Text("RECENT")
                .font(ScribeFonts.uiCaption)
                .foregroundColor(ScribeColors.textTertiary)
                .padding(.horizontal, ScribeSpacing.sm)
            
            // Recent notes list
            ForEach(recentNotes) { note in
                NoteRow(
                    note: note,
                    isSelected: appState.selectedNoteId == note.id
                )
                .onTapGesture {
                    selectNote(note)
                }
            }
        }
    }
    
    private func selectNote(_ note: Note) {
        appState.selectedNoteId = note.id
    }
}

struct NoteRow: View {
    let note: Note
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text("•")
                .font(ScribeFonts.uiBody)
                .foregroundColor(ScribeColors.textSecondary)
            
            Text(note.title.isEmpty ? "Untitled" : note.title)
                .font(ScribeFonts.uiBody)
                .foregroundColor(isSelected ? ScribeColors.accent : ScribeColors.textPrimary)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.horizontal, ScribeSpacing.sm)
        .padding(.vertical, ScribeSpacing.xs)
        .background(isSelected ? ScribeColors.accent.opacity(0.1) : Color.clear)
        .cornerRadius(4)
    }
}
```

**Implementation Time:** 2 hours

---

### Day 7: Polish & Testing

#### Task 5: Refinements

**Polish checklist:**
- [ ] Smooth animations (0.2s easing)
- [ ] Hover states (subtle highlight)
- [ ] Selected item highlighting (accent color)
- [ ] Auto-hide sidebar on editor click
- [ ] Search field works (instant filter)
- [ ] Keyboard navigation (arrow keys)

**Implementation Time:** 3 hours

---

## Timeline Summary

| Phase | Duration | Start | End | Deliverable |
|-------|----------|-------|-----|-------------|
| Phase 1 | 1 week | Jan 1 | Jan 7 | Enhanced Focus Mode |
| Phase 2 | 1 week | Jan 8 | Jan 14 | Navigator Mode |
| Phase 3 | TBD | TBD | TBD | Markdown Preview |
| Phase 4 | TBD | TBD | TBD | Advanced Features |

**Total:** 2 weeks for working ADHD-friendly writing app

---

## Success Metrics

### Phase 1 Success
- ✅ App opens to clean editor (< 3s)
- ✅ Stats show all 5 metrics (live updates)
- ✅ Auto-save works (1s debounce)
- ✅ Stats persist (UserDefaults)
- ✅ Build clean (0 warnings, 0 errors)

### Phase 2 Success
- ✅ Sidebar toggles smoothly (⌘B)
- ✅ Projects show with icons
- ✅ Recent notes clickable
- ✅ Search works (instant filter)
- ✅ All animations smooth (0.2s)

### Overall Success
- ✅ ADHD-friendly (zero friction, visible progress)
- ✅ Performant (< 50ms lag, < 100MB RAM)
- ✅ Reliable (auto-save, data persistence)
- ✅ Maintainable (clean code, documented)

---

**Document Version:** 1.0  
**Last Updated:** January 1, 2026  
**Status:** Ready for Phase 1 implementation
