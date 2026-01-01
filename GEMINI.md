# GEMINI.md

> **AI Assistant Knowledge Base for Scribe Swift**

---

## 🎯 Project Identity

**Scribe Swift** is a pure-native ADHD-friendly distraction-free writing app for macOS, built with **SwiftUI** and **GRDB**.

- **Goal**: Zero-friction writing for researchers and ADHD users
- **Philosophy**: Minimal cognitive load, maximal focus
- **Version**: 0.1.0-dev (Active Rebuild)
- **Platform**: macOS 14+ (Sonoma)

---

## 🧠 ADHD Design Principles

1. **Zero Friction**: < 3 seconds to start writing
2. **One Thing at a Time**: Single note, Focus Mode default
3. **Escape Hatches**: ⌘W closes without prompt (auto-save)
4. **Visible Progress**: Stats footer with 5 metrics
5. **Sensory-Friendly**: Dark mode default, soft colors

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      SwiftUI Views                       │
│  MainView → EditorView + StatsFooter                    │
├─────────────────────────────────────────────────────────┤
│                    AppState (@MainActor)                 │
│  @Published: notes, projects, selectedNoteId, stats     │
├─────────────────────────────────────────────────────────┤
│                      Services Layer                      │
│  NoteService, ProjectService (async/await CRUD)         │
├─────────────────────────────────────────────────────────┤
│                   DatabaseManager (Actor)                │
│  GRDB wrapper, thread-safe, SQLite + FTS5               │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Source Structure

```
Sources/Scribe/
├── ScribeApp.swift           # @main entry point
├── Data/
│   └── DatabaseManager.swift # Actor-based GRDB (245 lines)
├── Domain/Services/
│   ├── NoteService.swift     # Note CRUD (107 lines)
│   └── ProjectService.swift  # Project CRUD (56 lines)
├── Models/
│   ├── Note.swift            # Note model + GRDB (70 lines)
│   ├── Project.swift         # Project + ProjectType (231 lines)
│   ├── ScribeError.swift     # Error types
│   └── WritingStats.swift    # Session/streak tracking (209 lines)
├── Store/
│   └── AppState.swift        # UI state management (197 lines)
└── Views/
    ├── DesignSystem.swift    # Colors, fonts, spacing (92 lines)
    ├── MainView.swift        # Root layout (51 lines)
    ├── EditorView.swift      # Markdown editor (119 lines)
    └── StatsFooter.swift     # 5-metric footer (147 lines)
```

**Total**: ~12 files, ~1,500 lines

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **UI** | SwiftUI (macOS 14+) |
| **Database** | GRDB 6.24+ (SQLite + FTS5) |
| **Markdown** | swift-markdown |
| **Shortcuts** | KeyboardShortcuts |
| **Concurrency** | async/await, Actors, Sendable |

---

## 🎨 Design System

**Colors** (VSCode Dark):

- `background`: #1e1e1e
- `surface`: #252526
- `textPrimary`: #d4d4d4
- `accent`: #007acc
- `streak`: #ff6b35

**Typography**:

- Editor: SF Mono 16pt
- Title: System 24pt bold
- Stats: Rounded 12pt medium

---

## 📊 Current Status

**Backend**: 100% complete ✅

- DatabaseManager (Actor, GRDB, FTS5)
- NoteService, ProjectService
- Models with GRDB conformance

**Frontend**: 40% complete 🚧

- DesignSystem ✅
- Focus Mode layout ✅
- WritingStats + StatsFooter ✅
- Keyboard shortcuts ❌
- Sidebar (Phase 2) ❌

---

## 🗓️ Roadmap

| Phase | Focus | Status |
|-------|-------|--------|
| 1 | Focus Mode + Stats | In Progress |
| 2 | Sidebar + Navigation | Planned |
| 3 | Markdown Preview | Deferred |
| 4 | LaTeX Rendering | Deferred |

---

## 🔧 Quick Commands

```bash
# Build
swift build

# Run (Xcode GUI)
open Package.swift -a Xcode  # then ⌘R

# Clean
swift package clean

# Database location
~/Library/Application Support/Scribe/scribe.sqlite
```

---

## ⚠️ Key Constraints

1. **Keep backend untouched** - Data layer is solid
2. **@MainActor for UI** - All view code on main thread
3. **Services only** - Never access DatabaseManager directly
4. **Tests disabled** - Swift Testing incompatible, needs XCTest migration

---

## 📚 Key Docs

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Full dev guide (700 lines) |
| `.STATUS` | Project metadata |
| `TODO.md` | Task checklist |
| `ROADMAP.md` | Timeline |
| `docs/PRODUCT_REQUIREMENTS.md` | Vision |
| `docs/development/REBUILD_PLAN_2026.md` | Implementation plan |

---

*Updated: 2026-01-01*
