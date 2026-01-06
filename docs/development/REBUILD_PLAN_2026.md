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

## Phase 2.5: UI Polish (Week 2) ✅ COMPLETE

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

## Phase 3: Comprehensive Testing (Session 1 - Jan 1, 2026) ✅ COMPLETE

### Goal
Enhance test coverage with edge cases, E2E workflows, and data integrity tests

### Timeline
- **Start:** January 1, 2026 (Today)
- **End:** January 1, 2026
- **Duration:** 1 day
- **Effort:** ~4 hours

### Success Criteria
- ✅ Test suite enhanced from 121 to 168 tests (+39%)
- ✅ EdgeCaseTests.swift created with 47 comprehensive tests
- ✅ All models tested with edge cases (Unicode, special chars, concurrency)
- ✅ E2E workflows complete (multi-note, project assignment, wiki links)
- ✅ All 168 tests passing (0 failures)
- ✅ Build clean (0 errors, 0 warnings)
- ✅ Critical bugs fixed (timer focus, Resources reference)

### Tasks Overview

**New Test File:**
- EdgeCaseTests.swift (47 new tests)

**Enhanced Test Files:**
- WritingStatsTests: Streak edge cases (consecutive days, resets, zero-word days)
- NoteModelTests: Word count, timestamps, soft delete, preview edge cases, Codable tests
- ProjectModelTests: Computed properties, ProjectType properties (emoji, color, systemImage), Hashable, Codable tests
- E2EWorkflowTests: Multi-note creation, project assignment, deletion, search, wiki links, full-day workflows
- AppStateTests: Removed deprecated sessionTimerTick test

**Critical Fixes:**
- Timer stealing focus: Moved session timer to local @State in StatsFooter (no AppState publishes)
- Invalid Resources reference: Removed from Package.swift
- Xcode project regeneration: Both Scribe and ScribeTests targets visible

**Test Coverage:**
- ✅ Models (Note, Project, WritingStats, ScribeError)
- ✅ Services (NoteService, ProjectService)
- ✅ Database (GRDB, migrations, FTS)
- ✅ State Management (AppState, error handling)
- ✅ Search (full-text, Unicode, case-insensitive)
- ✅ E2E Workflows (complete user journeys)
- ✅ Edge Cases (Unicode, special chars, concurrency, data integrity)
- ⚠️ UI Views: Limited (SwiftUI private structs not directly testable)

**Test Results:**
```
swift test --enable-code-coverage
✅ 168 tests passing (14.2s)
✅ 0 failures, 0 unexpected errors
✅ Build clean (0 errors, 0 warnings)
```

**Test Files Created/Modified:**
- Tests/ScribeTests/EdgeCaseTests.swift (NEW - 47 tests)
- Tests/ScribeTests/WritingStatsTests.swift (ENHANCED)
- Tests/ScribeTests/NoteModelTests.swift (ENHANCED)
- Tests/ScribeTests/ProjectModelTests.swift (ENHANCED)
- Tests/ScribeTests/E2EWorkflowTests.swift (ENHANCED)
- Tests/ScribeTests/AppStateTests.swift (ENHANCED)

**Test Coverage Summary:**
See `TEST_COVERAGE_SUMMARY.md` for detailed breakdown of all 168 tests across:
- 14 test files
- Unit tests, integration tests, E2E tests, edge cases
- Models, services, database, state management, search

**Files Modified:**
- Package.swift (removed Resources reference)
- Sources/Scribe/Views/StatsFooter.swift (moved timer to local @State)
- Sources/Scribe/Store/AppState.swift (removed session timer)

**Files Created:**
- TEST_COVERAGE_SUMMARY.md (comprehensive test documentation)
- Scribe/Info.plist (bundle identifier: com.datawise.Scribe)

---

## Phase 4: Advanced Features (Future)

### Goal
Tab bar, Mission Control dashboard, advanced markdown features

### Timeline
- **Start:** TBD
- **End:** TBD
- **Duration:** ~2 weeks
- **Effort:** ~2-3 hours/day

### Tasks Overview

**Day 1-3: Tab Bar Foundation**
- Create TabBarView component
- Implement tab state management
- Tab switch animations

**Day 4-6: Mission Control Dashboard**
- MissionControlDashboardView
- Quick stats overview
- Recent projects/notes summary
- Goal progress widgets

**Day 7-10: Advanced Markdown**
- Syntax highlighting (basic)
- Tab bar with gradient accent
- Markdown preview toggle (split view)
- LaTeX rendering integration

**Day 11-14: Polish & Testing**
- Visual polish
- Performance optimization
- Accessibility improvements
- Comprehensive testing

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
