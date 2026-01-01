# Scribe SwiftUI Native

> ADHD-friendly distraction-free writer for macOS (SwiftUI)

**Status:** 🚧 In Development
**Platform:** macOS 14+ (Sonoma)
**Language:** Swift 5.9+
**License:** MIT

---

## Overview

This is the **native SwiftUI version** of Scribe, designed specifically for macOS users who want a truly native experience with menu bar integration, global keyboard shortcuts, and deep system integration.

**Related Projects:**

- [scribe](https://github.com/Data-Wise/scribe) - Tauri/React version (cross-platform)

---

## Why SwiftUI?

- **Native Performance** - True macOS app, not wrapped webview
- **Menu Bar Integration** - Quick access from anywhere
- **Global Shortcuts** - ⌘⇧C for quick capture, works system-wide
- **Spotlight Search** - Index notes for system-wide search
- **Widgets** - Word count, streak tracker on desktop
- **Smaller Size** - ~10MB vs ~100MB for Tauri version

---

## Features

- **Projects** - Organize notes into 5 project types (Research, Teaching, R-Package, R-Dev, Generic)
- **Markdown Editor** - Three modes (Source / Live Preview / Reading)
- **Wiki Links** - `[[Note Title]]` with autocomplete
- **Tags** - `#tag` with colored badges
- **Daily Notes** - Auto-create with templates
- **Quick Capture** - Global hotkey (⌘⇧C) for instant note-taking
- **AI Integration** - CLI-based (Claude, Gemini) - no API keys needed
- **Full-Text Search** - Fast SQLite FTS5 search

---

## Quick Start

```bash
cd ~/projects/dev-tools/scribe-sw

# Build
swift build

# Run
swift run

# Open in Xcode
open Package.swift
```

---

## Project Structure

```
scribe-sw/
├── Package.swift        # Swift Package Manager manifest
├── Sources/Scribe/      # SwiftUI app source
├── Tests/               # Unit tests
├── cli/                 # Terminal CLI (scribe.zsh)
├── docs/                # Documentation
└── README.md            # This file
```

---

## Documentation

See `docs/` directory for:

- **[getting-started.md](docs/getting-started.md)** - 5-minute setup guide
- **[development/swift-guide.md](docs/development/swift-guide.md)** - Beginner's guide to Swift/SwiftUI
- **[reference/database-schema.md](docs/reference/database-schema.md)** - SQLite schema reference
- **[contributing.md](docs/contributing.md)** - How to contribute

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| UI | SwiftUI (macOS 14+) |
| State | ObservableObject + @Published |
| Database | GRDB (SQLite wrapper) |
| Markdown | swift-markdown (Apple) |
| Shortcuts | KeyboardShortcuts |
| AI | CLI only (claude, gemini binaries) |

---

## ADHD Design Principles

1. **Zero Friction** - < 3 seconds to start writing
2. **One Thing at a Time** - Single note focus
3. **Escape Hatches** - ⌘W closes, auto-saves
4. **Visible Progress** - Word count, streak, timer
5. **Sensory-Friendly** - Dark mode, minimal animations
6. **Quick Wins** - Milestone celebrations

---

## Development Status

🚧 **Phase 1: Scaffolding** (Current)

- Basic Swift package structure
- Directory layout
- Documentation framework

📋 **Phase 2: Core Implementation** (Next)

- SwiftUI views
- GRDB database
- Basic editor functionality

---

## License

MIT © 2025 Data-Wise

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

**Location:** `~/projects/dev-tools/scribe-sw/`
**Repository:** (To be created at `github.com/Data-Wise/scribe-native`)
