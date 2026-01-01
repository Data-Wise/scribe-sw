# Scribe Native - Project Knowledge

**Last Updated:** 2025-12-31  
**Status:** Phase 1 Complete - Phase 2 Starting

---

## Project Overview

**Scribe Native** is a native macOS markdown + LaTeX editor combining Obsidian-style note-taking with Overleaf-style math rendering. Built with SwiftUI, targeting statistics professors and researchers with ADHD.

**Core Value:** "Write markdown and LaTeX with live preview, zero friction, native macOS performance"

---

## Tech Stack

- **Language:** Swift 5.9+ (Swift 6 ready)
- **UI:** SwiftUI (macOS 14+)
- **Database:** SQLite via GRDB.swift
- **Markdown:** swift-markdown
- **Keyboard:** KeyboardShortcuts
- **Architecture:** Clean architecture (3 layers)
- **Concurrency:** Actor-based + async/await
- **State:** @Observable (not ObservableObject)

---

## Architecture

### Three-Layer Design

```
Presentation (@Observable ViewModels + SwiftUI Views)
    ↓
Domain (Services + Models)
    ↓
Data (actor DatabaseManager + GRDB)
```

### Key Patterns

1. **@Observable** for ViewModels (better performance than ObservableObject)
2. **actor** for DatabaseManager (thread-safe, Swift 6 ready)
3. **Sendable** structs for all models (no data races)
4. **Protocol-oriented** services (testable, mockable)
5. **Result<T, Error>** for error handling

### Thread Safety

- UI updates: `@MainActor`
- Database: `actor DatabaseManager`
- All models: `Sendable`
- No shared mutable state

---

## Database Schema

### Tables

**projects** - 5 types (research, teaching, r-package, r-dev, generic)

```sql
CREATE TABLE projects (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK(type IN (...)),
    color TEXT,
    icon TEXT,
    settings TEXT,  -- JSON
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
```

**notes** - Documents with metadata

```sql
CREATE TABLE notes (
    id TEXT PRIMARY KEY,
    project_id TEXT REFERENCES projects(id),
    title TEXT NOT NULL,
    content TEXT NOT NULL DEFAULT '',
    folder TEXT NOT NULL DEFAULT 'inbox',
    metadata TEXT,  -- JSON: tags, properties, flags
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER  -- Soft delete
);
```

**links** - Wiki-style bidirectional links

```sql
CREATE TABLE links (
    id INTEGER PRIMARY KEY,
    source_note_id TEXT NOT NULL,
    target_note_id TEXT NOT NULL,
    link_type TEXT NOT NULL DEFAULT 'wiki',  -- wiki, cite, embed
    created_at INTEGER NOT NULL
);
```

**notes_fts** - Full-text search (FTS5)

```sql
CREATE VIRTUAL TABLE notes_fts USING fts5(
    note_id, title, content, metadata
);
```

### Indexes

- `idx_notes_project` on `notes(project_id)`
- `idx_notes_updated` on `notes(updated_at)`
- `idx_notes_deleted` on `notes(deleted_at)`
- `idx_links_source` on `links(source_note_id)`
- `idx_links_target` on `links(target_note_id)`

---

## Core Models

### Note

```swift
struct Note: Identifiable, Codable, Hashable, Sendable {
    let id: String                    // UUID
    var projectId: String?
    var title: String
    var content: String               // Markdown + LaTeX
    var folder: String                // inbox, drafts, daily, etc.
    var metadata: NoteMetadata?       // JSON blob
    var createdAt: Int64              // Unix timestamp
    var updatedAt: Int64
    var deletedAt: Int64?             // Soft delete
    
    // Computed
    var isDeleted: Bool { deletedAt != nil }
    var wordCount: Int { /* markdown parsing */ }
    var tags: [String] { metadata?.tags ?? [] }
    var isDaily: Bool { metadata?.isDaily ?? false }
    var isPinned: Bool { metadata?.isPinned ?? false }
}

struct NoteMetadata: Codable, Sendable {
    var tags: [String] = []
    var aliases: [String] = []
    var properties: [String: String] = [:]
    var isDaily: Bool = false
    var isPinned: Bool = false
}
```

### Project

```swift
struct Project: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var name: String
    var description: String?
    var type: ProjectType              // enum
    var color: String?                 // Hex
    var icon: String?                  // SF Symbol
    var settings: ProjectSettings?     // JSON blob
    var createdAt: Int64
    var updatedAt: Int64
}

enum ProjectType: String, Codable {
    case research
    case teaching
    case rPackage = "r-package"
    case rDev = "r-dev"
    case generic
}

struct ProjectSettings: Codable, Sendable {
    var bibliography: String?          // .bib path
    var citationStyle: String?         // apa, chicago, etc.
    var exportTemplate: String?
    var aiContext: String?
    var defaultFolder: String?
}
```

---

## File Structure

```
scribe-sw/
├── Package.swift
├── Sources/Scribe/
│   ├── ScribeApp.swift
│   ├── Models/
│   │   ├── Note.swift
│   │   ├── Project.swift
│   │   ├── Link.swift
│   │   └── ScribeError.swift
│   ├── Data/
│   │   └── DatabaseManager.swift        # actor
│   ├── Domain/
│   │   ├── NoteService.swift
│   │   └── ProjectService.swift
│   ├── Presentation/
│   │   ├── ViewModels/
│   │   │   ├── EditorViewModel.swift
│   │   │   ├── NotesListViewModel.swift
│   │   │   └── ProjectSidebarViewModel.swift
│   │   └── Views/
│   │       ├── ContentView.swift
│   │       ├── NoteEditorView.swift
│   │       ├── ProjectSidebarView.swift
│   │       └── EditorTabsView.swift
│   └── Store/
│       └── AppState.swift               # Global state
├── Tests/ScribeTests/
└── docs/
    ├── development/
    │   ├── ARCHITECTURE.md
    │   ├── IMPLEMENTATION_SUMMARY.md
    │   └── REFACTORING_PLAN.md
    └── reference/
        └── database-schema.md
```

---

## Features (Planned)

### MVP (v0.1)

- [x] Project structure
- [x] Database schema
- [ ] DatabaseManager actor
- [ ] Note/Project CRUD
- [ ] Basic editor (TextKit)
- [ ] Project sidebar
- [ ] Note list

### Core (v0.5)

- [ ] Hybrid editor (TextKit + WebKit)
- [ ] Live LaTeX rendering (MathJax)
- [ ] Wiki links `[[note]]`
- [ ] Tags `#tag`
- [ ] Full-text search (FTS5)
- [ ] Backlinks panel

### Polish (v1.0)

- [ ] Editor tabs
- [ ] Daily notes
- [ ] Quick capture (⌘⇧C)
- [ ] Global hotkey (⌘⇧N)
- [ ] Menu bar integration
- [ ] Themes

### Future (v2.0)

- [ ] Citations `@cite`
- [ ] Export (PDF, Word, LaTeX)
- [ ] AI chat (Claude/Gemini CLI)
- [ ] Spotlight indexing
- [ ] Share extensions

---

## Development Workflow

### Build

```bash
cd /Users/dt/projects/dev-tools/scribe-sw
swift build
```

### Test

```bash
swift test
```

### Run

```bash
swift run
```

### Git Workflow

```bash
# Branch for features
git checkout -b feature/database-manager

# Commit frequently
git add -A
git commit -m "Implement DatabaseManager actor"

# Main branch for stable code
git checkout main
git merge feature/database-manager
```

---

## Current Status

### ✅ Complete

- Project reorganization (SPM standard)
- Architecture design (ARCHITECTURE.md)
- Database schema (database-schema.md)
- Models (Note, Project with Sendable + GRDB)
- Documentation (7 comprehensive files)

### 🔄 In Progress

- DatabaseManager actor
- Service layer
- Error types

### ⬜ To Do

- ViewModels (@Observable)
- SwiftUI Views
- Editor (TextKit + WebKit)
- Tests
- Native features

---

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| **@Observable** | Better performance than ObservableObject |
| **actor DatabaseManager** | Thread-safe, Swift 6 ready |
| **JSON metadata** | Flexible, no schema changes needed |
| **Hybrid editor** | Native TextKit + WebKit for LaTeX |
| **3-layer architecture** | Clean but not over-engineered |
| **Sendable everywhere** | Prevent data races |
| **FTS5** | Fast full-text search |

---

## ADHD Design Principles

1. **Zero Friction** - <3s to start writing
2. **One Thing at a Time** - Single note visible
3. **Escape Hatches** - ⌘W closes, auto-saves
4. **Visible Progress** - Word count always visible
5. **Sensory-Friendly** - Dark mode default
6. **Quick Wins** - Milestone celebrations

---

## Testing Strategy

### Unit Tests

- DatabaseManager operations
- Service layer logic
- Model conversions
- Error handling

### Integration Tests

- Database migrations
- CRUD workflows
- Search functionality
- Link creation

### UI Tests

- Editor functionality
- Keyboard shortcuts
- Project navigation

---

## Performance Targets

| Metric | Target | Critical For |
|--------|--------|--------------|
| **Startup** | <2s | First impression |
| **Search** | <100ms | 10k+ notes |
| **Save** | <50ms | Smooth typing |
| **Note open** | <100ms | Responsiveness |
| **Build time** | <30s | Fast iteration |

---

## Dependencies

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0"),
    .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
    .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "1.0.0")
]
```

### Runtime Requirements

- macOS 14.0+ (Sonoma)
- Swift 5.9+
- Xcode 15+

---

## Documentation

### For Developers

- [ARCHITECTURE.md](file:///Users/dt/projects/dev-tools/scribe-sw/docs/development/ARCHITECTURE.md) - Architecture guide
- [database-schema.md](file:///Users/dt/projects/dev-tools/scribe-sw/docs/reference/database-schema.md) - Database reference
- [IMPLEMENTATION_SUMMARY.md](file:///Users/dt/projects/dev-tools/scribe-sw/docs/development/IMPLEMENTATION_SUMMARY.md) - Progress tracker

### For Users

- [README.md](file:///Users/dt/projects/dev-tools/scribe-sw/README.md) - Project overview
- [getting-started.md](file:///Users/dt/projects/dev-tools/scribe-sw/docs/getting-started.md) - Installation guide

---

## Common Commands

```bash
# Build
swift build

# Test
swift test

# Run
swift run

# Format
swift-format -i -r Sources/

# Lint (if using SwiftLint)
swiftlint

# Clean
rm -rf .build
swift package clean

# Update dependencies
swift package update

# Generate Xcode project
swift package generate-xcodeproj
```

---

## Troubleshooting

### Build fails with GRDB errors

- Check Package.swift has correct GRDB version
- Run `swift package update`
- Clean build: `rm -rf .build`

### Database errors

- Check `~/Library/Application Support/Scribe/scribe.sqlite`
- Migrations in DatabaseManager.createMigrator()
- Enable SQL tracing in DatabaseManager init

### SwiftUI preview crashes

- Ensure @MainActor on ViewModels
- Check for retain cycles in closures
- Use `#Preview` macro (macOS 14+)

---

## Next Immediate Steps

1. **Create DatabaseManager actor** (4h)
2. **Add ScribeError types** (1h)
3. **Implement NoteService** (3h)
4. **Implement ProjectService** (2h)
5. **Write unit tests** (4h)

**Total Phase 2:** 14h

---

**This knowledge base will evolve as development progresses.**
