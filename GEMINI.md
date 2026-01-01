# GEMINI.md

> **AI Assistant Knowledge Base for Scribe Swift (Scribe-SW)**

---

## 🎯 Project Identity

**Scribe Swift** is the "Native Plus" evolution of the Scribe project. It is a premium, distraction-free writing environment for macOS, built from the ground up with **SwiftUI** and the **Lexical JS engine**.

- **Goal**: Zero-friction, high-performance writing for researchers (specifically Statistics/Causal Inference).
- **Philisophy**: ADHD-friendly design that minimizes mental load.

---

## 🧠 ADHD Design Principles

1. **Zero Friction**: < 2s startup, active note auto-saves, instant typing.
2. **One Thing at a Time**: Focus on a single note. Sidebars and headers are collapsible.
3. **Native Focus Mode (⌘⇧F)**: Instantly strips the UI to just the text with serif typography.
4. **Visible Progress**: Real-time word counts and status indicators.
5. **Quick Capture (⌘⇧C)**: Fast entry point for ideas without breaking flow.

---

## 🚀 Key Achievements (December 2025)

### 1. CodeMirror 5 Hybrid Engine

- **Mode**: Unified Edit/Split (⌘1/⌘2).
- **Tech**: CodeMirror 5 running in a secure `WKWebView` with native Swift sync.
- **Goal**: Perfect visual alignment with the native Markdown preview.

### 2. Academic Citations (@cite)

- **Indexing**: Automatically watches `~/Documents/Scribe/global.bib`.
- **Trigger**: Type `@` to initiate fuzzy search for BibTeX keys.
- **Service**: 100% thread-safe `BibTeXService`.

### 3. Native Focus Mode

- **Shortcut**: `⌘⇧F`.
- **Experience**: Hides all sidebars and chrome with spring animations.

### 4. Verification & Quality

- **UI Tests**: XCUITest suite covering navigation, mode switching, and sidebar toggling.
- **Memory**: Optimized Swift 6 `@Observable` models.

---

## 📐 Technical Architecture (Locked)

| Layer | Technology |
|-------|------------|
| **UI** | SwiftUI (macOS 14+) |
| **Logic** | Swift 6 / AppState (@Observable) |
| **Engine** | CodeMirror 5 (via WKWebView) |
| **Database** | SQLite via GRDB.swift |
| **Markdown** | swift-markdown |

---

## 📁 Key Documentation

- [ARCHITECTURE.md](file:///Users/dt/projects/dev-tools/scribe-sw/docs/development/ARCHITECTURE.md)
- [KNOWLEDGE.md](file:///Users/dt/projects/dev-tools/scribe-sw/.claude/KNOWLEDGE.md)
- [walkthrough.md](file:///Users/dt/.gemini/antigravity/brain/bd33520a-e8a5-4c26-971e-c35a262ed3f3/walkthrough.md)

---

## 🛠️ Build & Run

```bash
swift build
swift run
```

*Updated: 2025-12-31*
