# CLAUDE.md

This file provides guidance to Claude Code/OpenCode when working with the Scribe SwiftUI project.

## Project Overview

**Scribe SwiftUI** - ADHD-friendly distraction-free writing app for macOS researchers.

**What it does:**
- Distraction-free markdown + LaTeX writing environment
- Project-based note organization (Research, Teaching, R Packages)
- Live writing stats (word count, timer, streak, daily goals)
- Wiki-style linking between notes (`[[Note Title]]`)
- Native macOS app (SwiftUI) with zero friction workflows

**Tech Stack:**
- **Language:** Swift 5.9+ (Swift 6 ready)
- **UI Framework:** SwiftUI
- **Database:** GRDB (SQLite wrapper)
- **Markdown:** swift-markdown
- **Platform:** macOS 14+ (Sonoma)

---

## Current Version: 0.1.0-dev (Jan 1, 2026)

### Status: Active Rebuild (Phases 1-2)

**Build Status:** ✅ Clean (0 warnings, 0 errors, ~25s)

**Backend (100% Complete):**
- DatabaseManager (Actor-based, thread-safe)
- NoteService, ProjectService (async/await CRUD)
- Models (Note, Project with full GRDB integration)
- AppState (ObservableObject for UI state)

**Frontend (40% Complete - Rebuilding):**
- DesignSystem ✅ (VSCode-inspired dark theme)
- Basic editor, stats, sidebar (being enhanced)

**Current Focus:** Phase 1 - Enhanced Focus Mode (Week 1)

---

## Quick Reference

### Installation & Build

```bash
# Clone (not yet public)
cd ~/projects/dev-tools/scribe-sw

# Clean build
rm -rf .build
swift build

# Run in Xcode (shows GUI)
open Package.swift -a Xcode
# Press ⌘R

# Check for errors
swift build 2>&1 | grep -i "error\|warning"

# Verify no Testing framework
otool -L .build/arm64-apple-macosx/debug/Scribe | grep Testing
# Should return nothing
```

### Essential Commands

```bash
# Development
swift build                      # Build project
open Package.swift -a Xcode      # Open in Xcode
swift package clean              # Clean build artifacts

# Database
ls ~/Library/Application\ Support/Scribe/
# Should show: scribe.sqlite

# Docs
open docs/development/REBUILD_PLAN_2026.md
open docs/PRODUCT_REQUIREMENTS.md
open docs/UI_REDESIGN_BRAINSTORM.md
```

---

## Project Structure

```
scribe-sw/
├── Sources/Scribe/
│   ├── Data/
│   │   └── DatabaseManager.swift          # Actor, GRDB wrapper (240 lines)
│   ├── Domain/Services/
│   │   ├── NoteService.swift              # CRUD operations (100 lines)
│   │   └── ProjectService.swift           # Project mgmt (60 lines)
│   ├── Models/
│   │   ├── Note.swift                     # Note model (70 lines)
│   │   ├── Project.swift                  # Project model (150 lines)
│   │   ├── ScribeError.swift              # Error types
│   │   └── WritingStats.swift             # ✨ NEW (Phase 1)
│   ├── Store/
│   │   └── AppState.swift                 # UI state (@MainActor, 156 lines)
│   └── Views/
│       ├── ScribeApp.swift                # Entry point
│       ├── DesignSystem.swift             # Colors, fonts, spacing
│       ├── MainView.swift                 # Root view
│       ├── EditorView.swift               # Markdown editor
│       ├── StatsFooter.swift              # Stats display
│       └── Components/                    # ✨ NEW (Phase 2)
│           └── Sidebar/                   # Sidebar components
├── Tests/                                 # Disabled (old Swift Testing)
├── docs/
│   ├── PRODUCT_REQUIREMENTS.md            # Vision document
│   ├── UI_REDESIGN_BRAINSTORM.md          # UI specifications
│   ├── KEYBOARD_SHORTCUTS.md              # Shortcuts reference
│   ├── development/
│   │   ├── ARCHITECTURE.md                # Technical architecture
│   │   └── REBUILD_PLAN_2026.md           # Implementation plan
│   └── reference/
│       └── database-schema.md             # Database structure
├── .STATUS                                # Project metadata
├── ROADMAP.md                             # Phased timeline
├── CLAUDE.md                              # This file
├── TODO.md                                # Task tracking
├── CURRENT_STATUS.md                      # Current state
└── Package.swift                          # SPM config
```

### Key Paths

| Path | Purpose |
|------|---------|
| `~/Library/Application Support/Scribe/` | App data directory |
| `~/Library/Application Support/Scribe/scribe.sqlite` | Database file |
| `~/.claude/settings.json` | Claude Code config (if using) |

---

## Development Guidelines

### Architecture Principles

1. **Keep Backend Untouched** - Database, services, models are solid
2. **Clean SwiftUI** - No business logic in views
3. **Actor-based Data Layer** - Thread-safe database access
4. **@MainActor for UI** - All view models on main thread
5. **Modern Swift** - async/await, actors, Sendable
6. **ADHD-Friendly First** - All decisions filter through ADHD principles

### Code Style

**Naming Conventions:**
```swift
// Types: PascalCase
struct Note { }
class AppState { }
enum ProjectType { }

// Properties: camelCase
var selectedNoteId: String?
var isLoading: Bool

// Functions: camelCase with verb
func fetchNotes() async throws
func saveNote(_ note: Note) async
func calculateWordCount(_ text: String) -> Int
```

**SwiftUI Patterns:**
```swift
// Use @EnvironmentObject for AppState
@EnvironmentObject var appState: AppState

// Use @State for local UI state
@State private var showSidebar = false
@State private var searchText = ""

// Use computed properties for derived data
private var currentNote: Note? {
    guard let noteId = appState.selectedNoteId else { return nil }
    return appState.notes.first { $0.id == noteId }
}

// Use Task for async operations from sync context
Button("Save") {
    Task {
        await appState.saveNote(note)
    }
}
```

**Database Patterns:**
```swift
// ✅ Always use services, never access DatabaseManager directly
let notes = try await noteService.fetchAll()
try await noteService.save(note)
let results = try await noteService.search(query: "statistics")

// ✅ All database operations are async
do {
    let notes = try await noteService.fetchAll()
} catch {
    // Handle ScribeError
    appState.error = error as? ScribeError ?? .unknown(error)
}

// ❌ Don't do this (bypass services)
let db = DatabaseManager.shared
let notes = try await db.fetchNotes()  // Wrong!
```

### Testing

**Current Status:** Tests disabled (old Swift Testing framework incompatible)

**Future:** Migrate to XCTest
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

## Phase 1 Implementation (Week 1 - IN PROGRESS)

### Current Tasks (Jan 1-7, 2026)

**Day 1-2: Stats Foundation** 🚧 Current
- [ ] Create `WritingStats.swift` model
- [ ] Add stats tracking to `AppState.swift`
- [ ] Rebuild `StatsFooter.swift` with 5 metrics
- [ ] Session timer (live updating every 1s)
- [ ] Streak calculation (consecutive writing days)

**Day 3-4: Enhanced Editor**
- [ ] Add markdown awareness to `EditorView.swift`
- [ ] Improve auto-save (1s debounce)
- [ ] Remove toolbar from `MainView.swift`
- [ ] Add keyboard shortcuts

**Day 5-7: Polish**
- [ ] Session persistence (UserDefaults)
- [ ] Testing checklist
- [ ] Refinement

### Implementation Notes

**Stats Persistence (UserDefaults):**
```swift
// Save to UserDefaults
func saveStats() {
    if let data = try? JSONEncoder().encode(writingStats) {
        UserDefaults.standard.set(data, forKey: "writingStats")
    }
}

// Load from UserDefaults
func loadStats() {
    guard let data = UserDefaults.standard.data(forKey: "writingStats"),
          let stats = try? JSONDecoder().decode(WritingStats.self, from: data) else {
        return
    }
    self.writingStats = stats
    
    // Check if new day
    if !Calendar.current.isDateInToday(stats.todayDate) {
        resetDailyStats()
    }
    
    calculateStreak()
}
```

**Streak Calculation Logic:**
```swift
// Rule: Any writing counts (1+ words)
// Consecutive days increment streak
// Skip a day → streak resets to 0

func calculateStreak() {
    let calendar = Calendar.current
    let today = Date()
    let lastWrite = writingStats.lastWritingDate
    
    if calendar.isDateInToday(lastWrite) {
        // Same day, keep streak
    } else if calendar.isDateInYesterday(lastWrite) {
        // Consecutive day, increment
        writingStats.currentStreak += 1
    } else {
        // Broke streak
        writingStats.currentStreak = 0
    }
}
```

**Daily Goal:**
```swift
// Hardcoded: 500 words (make user-configurable later)
let dailyGoal = 500

// Goal progress (0.0 to 1.0)
var goalProgress: Double {
    min(Double(todayWordCount) / Double(dailyGoal), 1.0)
}
```

---

## Phase 2 Implementation (Week 2 - PLANNED)

### Tasks (Jan 8-14, 2026)

**Sidebar Components:**
- [ ] `SidebarView.swift` - Main sidebar container
- [ ] `ProjectSection.swift` - Project grouping with icons
- [ ] `RecentSection.swift` - Last 10 notes
- [ ] Search field (instant title/content filter)

**Navigation:**
- [ ] Project filtering (click project → filter notes)
- [ ] Note selection (click note → load in editor)
- [ ] Auto-hide sidebar on editor click

**Polish:**
- [ ] Smooth animations (0.2s easing)
- [ ] Hover states
- [ ] Selected item highlighting

---

## Design System

### Colors (VSCode Dark Theme)

```swift
// From DesignSystem.swift
background:      #1e1e1e    // Main window
surface:         #252526    // Sidebar, panels
border:          #3e3e42    // Subtle borders
textPrimary:     #d4d4d4    // Main text
textSecondary:   #858585    // Metadata
textTertiary:    #6a6a6a    // Placeholders
accent:          #007acc    // Links, focus
success:         #4ec9b0    // Stats, positive
warning:         #ce9178    // Orange
error:           #f48771    // Red
streak:          #ff6b35    // Flame emoji color
latex:           #b5cea8    // Math green

// Project colors
research:        #569cd6    // Blue - 🔬
teaching:        #4ec9b0    // Teal - 📚
rPackage:        #dcdcaa    // Yellow - 📦
```

### Typography

```swift
// Editor (monospace for markdown)
editor:          SF Mono 16pt

// Preview (sans-serif for rendered)
preview:         San Francisco 16pt
previewH1:       San Francisco 32pt bold
previewH2:       San Francisco 24pt semibold

// UI elements
uiBody:          System 13pt
uiCaption:       System 11pt
uiTitle:         System 14pt semibold
noteTitle:       System 24pt bold

// Stats
statsLarge:      Rounded 36pt bold
statsMedium:     Rounded 18pt semibold
statsSmall:      Rounded 12pt medium
```

### Spacing

```swift
xs:    4px   // Tight spacing
sm:    8px   // Small padding
md:   16px   // Standard spacing
lg:   24px   // Large gaps
xl:   32px   // Section spacing
xxl:  48px   // Editor padding
```

### Layout Constants

```swift
sidebarWidth:       200px   // Fixed sidebar
statsFooterHeight:  32px    // Fixed footer
minWindowWidth:     800px
minWindowHeight:    600px
cornerRadius:       8px
```

---

## ADHD-Friendly Design Principles

### Core Principles (Non-Negotiable)

1. **Zero Friction** (< 3 seconds to start writing)
   - App opens directly to editor
   - No splash screens, no setup wizards
   - Sidebar hidden by default
   - Auto-focus on launch
   - Auto-save (never ask)

2. **One Thing at a Time**
   - Single pane focus mode (default)
   - Minimal UI chrome
   - No tabs by default
   - Full-screen encouraged

3. **Escape Hatches Everywhere**
   - ⌘W closes without confirmation (auto-saves)
   - ESC exits modes
   - ⌘B toggles sidebar (quick exit)
   - All actions keyboard-accessible

4. **Visible Progress**
   - Stats footer always visible
   - Real-time updates (every 1s)
   - Streak tracking for motivation
   - Goal progress bar (visual feedback)

5. **Sensory-Friendly**
   - Dark mode by default (easier on eyes)
   - Minimal animations (respect reduced motion)
   - Soft colors (no harsh whites: #ffffff → #d4d4d4)
   - Comfortable fonts (SF Mono, not Courier)

### UI Modes

**Mode 1: Focus Mode (Default)**
```
┌────────────────────────────────────┐
│                                    │
│     Untitled                       │
│                                    │
│     [Content here...]              │
│                                    │
│  📝234w·⏱12m·🔥7d·⚡15·🎯50%      │
└────────────────────────────────────┘

No sidebar, no toolbar, no tabs
Just: Title + Content + Stats footer
All controls via keyboard
Zero UI chrome
```

**Mode 2: Navigator Mode (⌘B)**
```
┌────────┬───────────────────────────┐
│PROJECTS│  Untitled                 │
│🔬Research                          │
│📚Teaching  [Content...]           │
│RECENT  │                           │
│•Note 1 │  Stats footer             │
└────────┴───────────────────────────┘

Sidebar (200px) | Editor
PROJECTS section + RECENT section
Click to navigate, auto-hide on edit
```

**Mode 3: Split View (⌘P - Future)**
```
┌────────┬──────────┬───────────────┐
│PROJECTS│ Source   │ Preview       │
│        │ Markdown │ Rendered HTML │
│        │          │               │
└────────┴──────────┴───────────────┘

Source pane | Preview pane
Live markdown + LaTeX rendering
Scroll sync
```

---

## Keyboard Shortcuts

### Implemented
| Shortcut | Action |
|----------|--------|
| ⌘B | Toggle sidebar |
| ⌘N | New note |
| ⌘W | Close window (no prompt) |

### Planned (Phase 2+)
| Shortcut | Action |
|----------|--------|
| ⌘P | Toggle preview (Phase 3) |
| ⌘K | Command palette (Phase 4) |
| ⌘F | Search notes |
| ⌘D | Daily note |
| ⌘L | Insert wiki link |
| ⌘/ | Show shortcuts help |

---

## Common Tasks

### Adding a New View Component

1. **Create file** in `Sources/Scribe/Views/Components/`
2. **Define SwiftUI view** struct
3. **Add @EnvironmentObject** if needs AppState
4. **Use DesignSystem constants** (colors, fonts, spacing)
5. **Add to parent view**
6. **Test in Xcode** (⌘R)

Example:
```swift
// Sources/Scribe/Views/Components/Stats/SessionTimer.swift
import SwiftUI

struct SessionTimer: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Text(appState.writingStats.sessionDurationFormatted)
            .font(ScribeFonts.statsSmall)
            .foregroundColor(ScribeColors.accent)
    }
}
```

### Adding a New Model

1. **Create file** in `Sources/Scribe/Models/`
2. **Make it Codable, Identifiable, Sendable**
3. **If persisted:** add FetchableRecord, PersistableRecord
4. **Update DatabaseManager migration** if needed
5. **Add service methods** if CRUD needed

### Updating AppState

1. **Add @Published property** for UI updates
2. **Add async methods** for data operations
3. **Use services** (NoteService, ProjectService)
4. **Handle errors** with ScribeError
5. **Save state** to UserDefaults if needed

---

## Dependencies

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
    .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.24.0"),
    .package(url: "https://github.com/sindresorhus/KeyboardShortcuts.git", from: "1.16.0"),
]
```

**Why these dependencies?**
- **swift-markdown:** Apple's official markdown parser (clean, well-maintained)
- **GRDB:** Best SQLite wrapper for Swift (thread-safe, FTS5 support)
- **KeyboardShortcuts:** Simple global hotkey registration (native macOS)

---

## CI/CD

**Status:** Not yet set up (local development only)

**Planned:**
- GitHub Actions for testing
- Automated release workflow
- Homebrew formula updates
- GitHub Pages for docs

---

## Error Handling

### ScribeError Types

```swift
enum ScribeError: LocalizedError {
    case databaseError(String)
    case noteNotFound(String)
    case projectNotFound(String)
    case invalidInput(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .databaseError(let message):
            return "Database error: \(message)"
        case .noteNotFound(let id):
            return "Note not found: \(id)"
        case .projectNotFound(let id):
            return "Project not found: \(id)"
        case .invalidInput(let message):
            return message
        case .unknown(let error):
            return "Unexpected error: \(error.localizedDescription)"
        }
    }
}
```

### Error Handling Pattern

```swift
// In AppState or Services
do {
    let notes = try await noteService.fetchAll()
    self.notes = notes
} catch let error as ScribeError {
    self.error = error
} catch {
    self.error = .unknown(error)
}

// In Views
if let error = appState.error {
    Text(error.localizedDescription)
        .foregroundColor(ScribeColors.error)
}
```

---

## Links

- **Vision:** `docs/PRODUCT_REQUIREMENTS.md`
- **UI Design:** `docs/UI_REDESIGN_BRAINSTORM.md`
- **Architecture:** `docs/development/ARCHITECTURE.md`
- **Implementation Plan:** `docs/development/REBUILD_PLAN_2026.md`
- **Database Schema:** `docs/reference/database-schema.md`
- **Keyboard Shortcuts:** `docs/KEYBOARD_SHORTCUTS.md`

---

## Notes for Claude

### When Implementing Features

1. **Read the plan first** - Check `docs/development/REBUILD_PLAN_2026.md`
2. **Follow phase order** - Don't skip ahead (Phase 1 → Phase 2 → ...)
3. **Keep backend untouched** - Database layer is solid, don't modify
4. **Use existing patterns** - AppState → Services → DatabaseManager
5. **Test in Xcode** - `open Package.swift -a Xcode` then ⌘R
6. **ADHD principles first** - Filter all decisions through ADHD-friendly lens

### When Stuck

1. Check **PRODUCT_REQUIREMENTS.md** for vision clarity
2. Check **UI_REDESIGN_BRAINSTORM.md** for UI specs
3. Check **ARCHITECTURE.md** for technical patterns
4. Check **REBUILD_PLAN_2026.md** for implementation details
5. **Ask user for clarification** (don't guess or assume)

### Code Quality Standards

- ✅ Use modern Swift (async/await, actors, not callbacks)
- ✅ Keep views simple (no business logic, just presentation)
- ✅ Add comments for complex logic (streak calculation, word count)
- ✅ Use descriptive variable names (`currentNote` not `n`)
- ✅ Handle errors gracefully (don't crash, show user-friendly messages)
- ✅ Respect ADHD principles (zero friction, escape hatches, visible progress)

### Testing Checklist (Before Marking Complete)

- [ ] Builds without warnings or errors
- [ ] Runs in Xcode (GUI appears)
- [ ] Feature works as specified
- [ ] No regressions (existing features still work)
- [ ] Keyboard shortcuts work
- [ ] Auto-save works
- [ ] Stats update correctly
- [ ] No performance issues (< 50ms lag)

---

**Last Updated:** January 1, 2026  
**Current Phase:** Phase 1 - Enhanced Focus Mode (Week 1)  
**Next Review:** January 7, 2026
