# GEMINI.md

> **AI Assistant Knowledge Base for Scribe Swift**

---

## 🎯 Project Identity

**Scribe Swift** is a pure-native ADHD-friendly distraction-free writing app for macOS, built with **SwiftUI** and **GRDB**.

- **Goal**: Zero-friction writing for researchers and ADHD users
- **Philosophy**: Minimal cognitive load, maximal focus
- **Version**: 0.2.0-cli (CLI Development Focus)
- **Platform**: macOS 14+ (Sonoma)

---

## 🧠 ADHD Design Principles

1. **Zero Friction**: < 3 seconds to start writing
2. **One Thing at a Time**: Single note, Focus Mode default
3. **Escape Hatches**: ⌘W closes without prompt (auto-save)
4. **Visible Progress**: Stats footer with 5 metrics
5. **Sensory-Friendly**: Dark mode default, soft colors

---

## 🚀 Current Status: CLI-First Development

**Strategic Pivot:** Due to persistent SwiftUI input focus issues, development has shifted to **CLI-first** approach to build a robust backend.

### Phase 0: Hybrid Config System ✅ COMPLETE (Jan 2, 2026)

**Delivered:**

- Multi-vault infrastructure
- Hybrid config (vault.json + cli.json)
- 6 vault commands (create, list, switch, context, info, delete)
- Context-aware command routing
- Comprehensive testing (unit + E2E)
- User guide (VAULT_GUIDE.md)

**Architecture:**

```
~/.config/scribe/.scribe-cli/
├── config.json                 # Global config
└── vaults/
    └── {name}-cli.sqlite       # Per-vault databases

{vault-root}/.scribe/
├── vault.json                  # Shared (CLI + GUI)
└── cli.json                    # CLI-specific
```

### Phase 1: Inbox & Projects ✅ COMPLETE (Jan 5, 2026)

**Delivered:**

- Quick capture (`scribe-cli quick <content>`)
- Inbox management (`scribe-cli inbox [list|move]`)
- Project creation (`scribe-cli project create <name> [type]`)
- Enhanced project list (IDs + emojis)
- Partial ID matching
- 34 unit tests + 21 E2E tests
- Dogfooding test (real-world workflow)

### Phase 2: Tags & Search ✅ COMPLETE (Jan 5, 2026)

**Delivered:**

- Tag parsing from `#hashtags` in content
- `scribe-cli tags list/search/stats` commands
- Enhanced search with `--tag`, `--project`, `--title-only` filters
- 18 new tests (8 model + 10 commands)
- E2E test (15 scenarios)
- Dogfooding test (non-interactive)

### Next: Phase 3 - Wiki Links (Week 4)

---

## 🏗️ Architecture

### Backend (Solid ✅)

```
DatabaseManager (Actor)
  ↓
Services (NoteService, ProjectService)
  ↓
Models (Note, Project, WritingStats)
```

### CLI (Active Development 🚧)

```
main.swift → CommandRouter
  ↓
Commands/
  ├── NoteCommands
  ├── VaultCommands
  ├── ProjectCommands
  └── SearchCommands
  ↓
Services → DatabaseManager
```

### SwiftUI Frontend (Deferred ⏸️)

- Critical issue: Input focus loss
- Deferred until CLI backend complete

---

## 📁 Source Structure

```
Sources/
├── Scribe/                     # SwiftUI app (deferred)
│   ├── Data/DatabaseManager
│   ├── Domain/Services/
│   ├── Models/
│   ├── Store/AppState
│   └── Views/
└── ScribeCLI/                  # CLI (active)
    ├── Commands/               # 6 command modules
    ├── Config/                 # Phase 0 ✅
    ├── Utils/
    ├── Data/                   # Shared backend
    ├── Models/
    └── Services/

Tests/
├── ScribeTests/                # SwiftUI tests (114 passing)
├── ScribeCLITests/             # CLI unit tests
└── test-phase-0-e2e.sh         # E2E tests
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **CLI** | Swift (main focus) |
| **UI** | SwiftUI (deferred) |
| **Database** | GRDB 6.24+ (SQLite + FTS5) |
| **Markdown** | swift-markdown |
| **Editor** | Micro (CLI integration) |
| **Shortcuts** | KeyboardShortcuts (GUI) |

---

## 🎨 Multi-Vault System

**Vaults** = Independent workspaces

- **teaching** - Course materials
- **research** - Papers, experiments
- **r-pkg** - R package dev
- **dev** - Code notes

Each vault has:

- Own database
- Own projects + inbox
- Independent settings
- No cross-vault linking

**Commands:**

```bash
scribe-cli vault create teaching ~/Documents/teaching teaching
scribe-cli vault list
scribe-cli vault switch research
scribe-cli vault context
```

---

## 📊 Project Status

**Phase 0:** ✅ Complete (Jan 2, 2026)
**Phase 1:** ✅ Complete (Jan 5, 2026)
**Phase 2:** ✅ Complete (Jan 5, 2026)  
**Progress:** 70% backend, 0% GUI
**Build:** ✅ Clean
**Tests:** ✅ 73+ tests passing

**Git Workflow:**

- `main` - Protected, production-ready
- `dev` - Integration branch
- `feature/*` - Active development

---

## 🗓️ Roadmap

| Phase | Focus | Status |
|-------|-------|--------|
| 0 | Multi-vault Config | ✅ Complete (Jan 2) |
| 1 | Inbox + Projects | ✅ Complete (Jan 5) |
| 2 | Tags (#hashtags) | ✅ Complete (Jan 5) |
| 3 | Wiki Links ([[links]]) | 📅 Next |
| 4 | Metadata + Polish | 📅 Week 5 |

---

## 🔧 Quick Commands

```bash
# Build CLI
swift build --product scribe-cli

# Run CLI
.build/debug/scribe-cli help

# Tests
swift test                           # Unit tests
bash Tests/test-phase-0-e2e.sh      # E2E tests

# Database location
~/.config/scribe/.scribe-cli/config.json
~/.config/scribe/.scribe-cli/vaults/
```

---

## ⚠️ Key Constraints

1. **SwiftUI deferred** - Focus on CLI backend first
2. **No GUI work** - Until backend complete
3. **@MainActor for services** - All async/await
4. **Tests required** - Phase completion needs unit + E2E tests
5. **Documentation** - Each phase needs user guide

---

## 📚 Key Docs

| File | Purpose |
|------|---------|
| **PHASE_0_COMPLETE.md** | Phase 0 summary |
| **VAULT_GUIDE.md** | User guide for vaults |
| **ROADMAP.md** | Full development plan |
| **.STATUS** | Current project state |
| **TODO.md** | Task checklist |

---

## 🎓 Testing Strategy

Each phase requires:

1. **Unit Tests** - XCTest for models/services
2. **E2E Tests** - Bash scripts for workflows
3. **Manual Testing** - Real-world usage
4. **Documentation** - User guides

Example (Phase 0):

- Unit: VaultConfigTests, ConfigServiceTests
- E2E: 35+ test scenarios
- Docs: VAULT_GUIDE.md

---

*Updated: 2026-01-05 (Phase 2 Complete)*
