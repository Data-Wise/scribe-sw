# CLAUDE.md

> **AI Assistant Knowledge Base for Scribe Swift (Claude Code Edition)**

---

## Project Overview

**Scribe Swift** - ADHD-friendly distraction-free writing app for macOS researchers.

**Current Focus:** CLI-First Development (SwiftUI deferred due to input focus bugs)

**Version:** 0.2.0-cli  
**Platform:** macOS 14+ (Sonoma)  
**Updated:** January 2, 2026

---

## Strategic Pivot: CLI-First

**Why:** Persistent SwiftUI input focus issues blocked GUI progress.  
**Approach:** Build robust CLI backend first, GUI later.  
**Status:** Phase 0 complete, 50% of CLI backend done.

---

## Phase 0: Multi-Vault System ✅ COMPLETE

**Delivered (Jan 2, 2026):**

- Hybrid config system (vault.json + cli.json)
- 6 vault commands (create, list, switch, context, info, delete)
- Context-aware vault detection
- Comprehensive tests (unit + E2E, 35+ tests)
- User guide (VAULT_GUIDE.md)

**Architecture:**

```
~/.config/scribe/.scribe-cli/
├── config.json                 # Global: tracks all vaults
└── vaults/
    └── {name}-cli.sqlite       # Per-vault databases

{vault-root}/.scribe/
├── vault.json                  # Shared (CLI + GUI)
└── cli.json                    # CLI-specific
```

---

## Quick Reference

### Build & Run

```bash
# CLI build
swift build --product scribe-cli

# Run CLI
.build/debug/scribe-cli help

# Vault commands
.build/debug/scribe-cli vault create teaching ~/Documents/teaching
.build/debug/scribe-cli vault list
.build/debug/scribe-cli vault switch research

# Tests
bash Tests/test-phase-0-e2e.sh
swift test  # Unit tests
```

### Project Structure

```
scribe-sw/
├── Sources/
│   ├── Scribe/                       # SwiftUI (deferred)
│   │   ├── Data/DatabaseManager      # Backend models
│   │   ├── Domain/Services/
│   │   ├── Models/
│   │   └── Views/
│   └── ScribeCLI/                     # CLI (active)
│       ├── Commands/
│       │   ├── NoteCommands.swift
│       │   ├── VaultCommands.swift    # ✅ Phase 0
│       │   ├── ProjectCommands.swift
│       │   └── SearchCommands.swift
│       ├── Config/                    # ✅ Phase 0
│       │   ├── GlobalConfig.swift
│       │   ├── VaultConfig.swift
│       │   └── ConfigService.swift
│       ├── Utils/EditorLauncher.swift
│       ├── Data/                      # Shared backend
│       ├── Models/
│       └── Services/
├── Tests/
│   ├── ScribeCLITests/               # Unit tests
│   └── test-phase-0-e2e.sh           # E2E tests
└── docs/
    ├── VAULT_GUIDE.md                 # User guide
    └── PHASE_0_COMPLETE.md            # Completion report
```

---

## Development Guidelines

### CLI Development Focus

1. **Build feature-complete backend** via CLI
2. **Test thoroughly** (unit + E2E for each phase)
3. **Document everything** (user guides + completion reports)
4. **Defer GUI** until backend solid

### Architecture Principles

1. **Keep backend clean** - Shared between CLI and future GUI
2. **Actor-based data** - DatabaseManager is thread-safe
3. **@MainActor for services** - All async/await
4. **Tests required** - Each phase needs unit + E2E tests
5. **User guides required** - Each phase needs documentation

### Code Patterns

**CLI Commands:**

```swift
enum VaultCommands {
    @MainActor
    static func create(name: String, path: String?, type: String?) async throws {
        var config = try ConfigService.shared.loadGlobalConfig()
        // ... implementation
        try ConfigService.shared.saveGlobalConfig(config)
        print("✅ Created vault '\(name)'")
    }
}
```

**Config Management:**

```swift
let config = try ConfigService.shared.loadGlobalConfig()
let vaultConfig = try ConfigService.shared.loadVaultConfig(from: vaultDir)
```

**Testing:**

```swift
// Unit tests (XCTest)
final class VaultConfigTests: XCTestCase {
    func testGlobalConfigEncoding() throws { }
}

// E2E tests (Bash)
test_command "create vault" $CLI vault create teaching /tmp/teaching
test_file_exists "config created" ~/.config/scribe/.scribe-cli/config.json
```

---

## Roadmap

| Phase | Focus | Status | Docs |
|-------|-------|--------|------|
| 0 | Multi-vault Config | ✅ Complete | VAULT_GUIDE.md |
| 1 | Inbox + Projects | 📅 Next | - |
| 2 | Tags (#hashtags) | 📅 Week 3 | - |
| 3 | Wiki Links ([[links]]) | 📅 Week 4 | - |
| 4 | Metadata + Polish | 📅 Week 5 | - |

---

## Key Files

| File | Purpose |
|------|---------|
| **GEMINI.md** | Primary knowledge base |
| **VAULT_GUIDE.md** | User guide for vaults |
| **PHASE_0_COMPLETE.md** | Phase 0 summary |
| **ROADMAP.md** | Full timeline |
| **.STATUS** | Project metadata |

---

## ADHD Design Principles

1. **Zero Friction** - < 3 seconds to write
2. **One Thing at a Time** - Single note focus
3. **Escape Hatches** - No confirmation dialogs
4. **Visible Progress** - Stats always visible
5. **Sensory-Friendly** - Dark mode, soft colors

---

## Testing Requirements

Each phase must have:

1. **Unit Tests** - XCTest for models/services
2. **E2E Tests** - Bash scripts for workflows
3. **Manual Testing** - Real-world usage
4. **User Guide** - Comprehensive documentation

Example (Phase 0):

- Unit: 2 test files
- E2E: 35+ scenarios
- Manual: Vault creation/switching
- Docs: VAULT_GUIDE.md

---

## When Working with This Project

### Before Starting

1. Read `GEMINI.md` for full context
2. Check `ROADMAP.md` for current phase
3. Review `.STATUS` for latest state

### When Implementing

1. Follow phase order (don't skip)
2. Keep backend shared (CLI + GUI compatible)
3. Write tests first (TDD where possible)
4. Document as you go
5. Create user guides

### When Stuck

1. Check `VAULT_GUIDE.md` for examples
2. Check `PHASE_0_COMPLETE.md` for patterns
3. Check `testing_strategy.md` for test structure
4. Ask user for clarification

---

**Last Updated:** January 2, 2026  
**Current Phase:** Phase 0 Complete → Phase 1 Next  
**Key Achievement:** Multi-vault CLI infrastructure working
