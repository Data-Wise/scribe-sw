# Project Overview: Scribe SwiftUI Native

**Created:** 2025-12-31
**Location:** `~/projects/dev-tools/scribe-sw/`
**Purpose:** Standalone native SwiftUI version of Scribe for macOS

---

## What is This Folder?

This is the **scribe-sw** (Scribe SwiftUI) project - a from-scratch native macOS application built with SwiftUI.

### Relationship to Other Scribe Projects

| Project | Location | Stack | Status |
|---------|----------|-------|--------|
| **scribe-sw** (this) | `~/projects/dev-tools/scribe-sw/` | SwiftUI + Swift | 🚧 Development |
| scribe | `~/projects/dev-tools/scribe/` | React + Tauri | ✅ Active (v1.8.0) |

**These are separate projects** - not worktrees, not branches of each other.

---

## Directory Structure

```
scribe-sw/
├── Scribe/                    # Swift Package Manager project
│   ├── Package.swift          # Dependencies (GRDB, swift-markdown, etc.)
│   ├── Sources/Scribe/        # SwiftUI source code (to be added)
│   └── Tests/ScribeTests/     # Unit tests (to be added)
│
├── cli/                       # Terminal CLI tools (to be copied)
│   └── scribe.zsh            # Main CLI script
│
├── docs/                      # Documentation
│   ├── guide/                # User guides
│   ├── planning/             # Development planning
│   ├── reference/            # Technical reference
│   ├── development/          # Dev documentation
│   └── user/                 # End-user docs
│
├── .github/workflows/        # CI/CD (to be added)
│
├── README.md                 # Main project README
├── QUICKSTART.md             # 5-minute setup guide
├── PROJECT-OVERVIEW.md       # This file
└── (more docs to be added)
```

---

## Current Status

**Phase:** Initial Setup
**Progress:** Folder structure created, basic documentation in place

### What Exists
- ✅ Directory structure
- ✅ README.md
- ✅ QUICKSTART.md
- ✅ PROJECT-OVERVIEW.md

### What's Planned
- ⬜ Swift source code (13 files from worktree)
- ⬜ CLI tools (scribe.zsh)
- ⬜ Complete documentation
- ⬜ Git repository initialization
- ⬜ GitHub repository (Data-Wise/scribe-native)

---

## Development Approach

### 1. **Orphan Branch Strategy**
- Fresh git repository, no shared history with main scribe repo
- Clean separation from Tauri/React version
- Independent development path

### 2. **Database Compatibility**
- Same SQLite schema as Tauri version
- Enables potential sync between apps
- GRDB wrapper for Swift

### 3. **Native macOS Features**
- Menu bar integration
- Global keyboard shortcuts (⌘⇧C, ⌘⇧D)
- Spotlight indexing
- Widgets
- Share extensions
- Handoff support

---

## Source Material

Code and documentation will be copied/adapted from:
- `/Users/dt/.git-worktrees/scribe/swiftui-native/` (SwiftUI scaffold)
- `~/projects/dev-tools/scribe/` (database schema reference)

---

## Next Steps

See implementation plan at: `~/.claude/plans/hazy-zooming-key.md`

**Immediate:**
1. Copy Swift code from worktree
2. Copy CLI tools
3. Copy/adapt documentation
4. Initialize git
5. Create GitHub repository

**Later:**
1. Implement core features
2. Add native macOS integrations
3. Testing
4. Beta release

---

## Key Principles (ADHD-Friendly)

1. **Zero Friction** - < 3 seconds to start writing
2. **One Thing at a Time** - Single note focus
3. **Escape Hatches** - ⌘W closes, auto-saves
4. **Visible Progress** - Word count, streak, timer
5. **Sensory-Friendly** - Dark mode default
6. **Quick Wins** - Celebrate milestones

---

## Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| UI | SwiftUI | Native macOS interface |
| State | ObservableObject | Reactive state management |
| Database | GRDB | SQLite wrapper for Swift |
| Markdown | swift-markdown | Apple's markdown parser |
| Shortcuts | KeyboardShortcuts | Global hotkey support |
| AI | CLI binaries | No API keys (claude, gemini) |

---

## Contact & Resources

- **Main Scribe:** https://github.com/Data-Wise/scribe
- **Future Repo:** https://github.com/Data-Wise/scribe-native (to be created)
- **Documentation:** See `docs/` directory

---

**Last Updated:** 2025-12-31
