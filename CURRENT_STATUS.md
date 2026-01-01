# Scribe - Current Status

**Last Updated:** January 1, 2026  
**Version:** 0.1.0-dev  
**Build Status:** ✅ Clean (0 warnings, 0 errors, ~25s)

---

## Quick Summary

**What:** ADHD-friendly distraction-free writing app for macOS researchers  
**Tech:** SwiftUI + GRDB (SQLite) + swift-markdown  
**Platform:** macOS 14+ (Sonoma)  
**Status:** Active development - Rebuilding frontend to match vision

---

## Current State

### Backend (100% Complete - Do NOT Modify)
✅ **DatabaseManager.swift** (240 lines) - Actor-based, thread-safe GRDB wrapper  
✅ **NoteService.swift** (100 lines) - Async CRUD for notes  
✅ **ProjectService.swift** (60 lines) - Async CRUD for projects  
✅ **Models/** (Note, Project, ScribeError) - Clean, Codable, Sendable  
✅ **AppState.swift** (156 lines) - @MainActor state management

**Total Backend:** 620 lines of solid, modern Swift code

### Frontend (40% Complete - Being Enhanced)
🚧 **MainView.swift** - Basic structure, needs toolbar removal  
🚧 **EditorView.swift** - Works, needs markdown awareness + improved auto-save  
🚧 **StatsFooter.swift** - Basic 2 metrics, needs rebuild to 5 metrics  
✅ **DesignSystem.swift** - Complete (VSCode dark theme colors/fonts/spacing)

**Total Frontend:** 942 lines (being rebuilt/enhanced)

### Build Health
```bash
Build complete! (~25s)
✅ 0 errors
✅ 0 warnings
✅ 12 Swift files
✅ 1562 total lines
```

---

## What Works Right Now

### Core Features (Implemented)
- ✅ Focus mode by default (sidebar hidden)
- ✅ Dark mode enforced (ADHD-friendly)
- ✅ Auto-focus on editor (zero friction)
- ✅ Auto-save (debounced)
- ✅ Basic word count (2 metrics: current note, total notes)
- ✅ Sidebar toggle (⌘B)
- ✅ Database persistence (GRDB + SQLite)
- ✅ Full-text search (FTS5)
- ✅ Project organization (Research, Teaching, R Packages)

### What's Missing (Being Built)
- ❌ Enhanced stats (5 metrics: word count, timer, streak, today, goal)
- ❌ Markdown awareness (syntax highlighting, link detection)
- ❌ Improved auto-save (1s debounce, visual indicator)
- ❌ Project-based sidebar (projects section + recent notes)
- ❌ Keyboard shortcuts (⌘N, ⌘D, ⌘L, ⌘F)
- ❌ Session persistence (UserDefaults)
- ❌ Streak calculation (consecutive writing days)

---

## Current Focus: Phase 1 (Week 1)

### Goal
Enhanced Focus Mode with live 5-metric stats and improved editor

### Timeline
**Start:** January 1, 2026  
**End:** January 7, 2026  
**Status:** 🚧 Day 1 - Stats Foundation

### This Week's Tasks
1. **Stats Foundation** (Day 1-2) - Create WritingStats model, rebuild StatsFooter
2. **Enhanced Editor** (Day 3-4) - Markdown awareness, improved auto-save
3. **Polish** (Day 5-7) - Keyboard shortcuts, session persistence, testing

### Next Week: Phase 2 (Navigator Mode)
- Project-based sidebar with icons
- Recent notes section
- Search functionality
- Smooth animations

---

## ADHD Design Principles (Non-Negotiable)

1. **Zero Friction** - App opens directly to editor (< 3 seconds to write)
2. **One Thing at a Time** - Single pane focus mode (default)
3. **Escape Hatches** - ⌘W closes without prompt (auto-saves)
4. **Visible Progress** - Stats always visible, updating in real-time
5. **Sensory-Friendly** - Dark mode, minimal animations, soft colors

---

## File Structure

```
Sources/Scribe/
├── Data/
│   └── DatabaseManager.swift          (240 lines) ✅ Complete
├── Domain/Services/
│   ├── NoteService.swift              (100 lines) ✅ Complete
│   └── ProjectService.swift           (60 lines) ✅ Complete
├── Models/
│   ├── Note.swift                     (70 lines) ✅ Complete
│   ├── Project.swift                  (150 lines) ✅ Complete
│   ├── ScribeError.swift              ✅ Complete
│   └── WritingStats.swift             🚧 TO CREATE (Phase 1)
├── Store/
│   └── AppState.swift                 (156 lines) 🚧 TO ENHANCE
└── Views/
    ├── ScribeApp.swift                ✅ Complete
    ├── DesignSystem.swift             ✅ Complete
    ├── MainView.swift                 🚧 TO MODIFY (remove toolbar)
    ├── EditorView.swift               🚧 TO ENHANCE (markdown awareness)
    ├── StatsFooter.swift              🚧 TO REBUILD (5 metrics)
    └── Components/                    🚧 TO CREATE (Phase 2)
        └── Sidebar/                   (SidebarView, ProjectSection, RecentSection)
```

---

## Key Documentation

**Essential Files:**
- `CLAUDE.md` - Complete guide for AI assistants (450+ lines)
- `ROADMAP.md` - Phased implementation timeline (420+ lines)
- `TODO.md` - Detailed task tracking (230+ lines)
- `.STATUS` - Project metadata (90 lines)
- `docs/PRODUCT_REQUIREMENTS.md` - Complete vision (Obsidian + Overleaf)
- `docs/UI_REDESIGN_BRAINSTORM.md` - UI specifications with ASCII mockups
- `docs/development/ARCHITECTURE.md` - Technical architecture (actors, async/await)
- `docs/development/REBUILD_PLAN_2026.md` - Implementation details (TO BE CREATED)

---

## How to Run

### Xcode (Recommended - Shows GUI)
```bash
cd ~/projects/dev-tools/scribe-sw
open Package.swift -a Xcode
# Press ⌘R to run
```

### Command Line (Build Only)
```bash
swift build
# Note: GUI only works when run from Xcode
```

### Database Location
```bash
~/Library/Application Support/Scribe/scribe.sqlite
```

---

## Dependencies

```swift
dependencies: [
    .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
    .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.24.0"),
    .package(url: "https://github.com/sindresorhus/KeyboardShortcuts.git", from: "1.16.0"),
]
```

---

## Known Issues

### Tests Disabled
- Old tests used Swift Testing framework (incompatible with Swift 5.9)
- Will migrate to XCTest in future
- Test target commented out in Package.swift

### GUI from CLI
- SwiftUI apps built with SPM don't show GUI from command line
- Must run from Xcode to see window
- Not a bug - expected SwiftUI behavior

---

## Next Steps

### Immediate (This Session)
1. ✅ Update CURRENT_STATUS.md (this file)
2. ⏳ Create docs/development/REBUILD_PLAN_2026.md
3. ⏳ Verify all documentation files

### Phase 1 Implementation (Week 1)
1. Create `WritingStats.swift` model
2. Update `AppState.swift` with stats tracking
3. Rebuild `StatsFooter.swift` with 5 metrics
4. Enhance `EditorView.swift` with markdown awareness
5. Add keyboard shortcuts to `MainView.swift`

---

**Summary:** Backend is solid (100% complete). Frontend is being rebuilt to match ADHD-friendly vision. Phase 1 (Enhanced Focus Mode) starts this week.
