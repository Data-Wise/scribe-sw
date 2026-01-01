# Contributing to Scribe SwiftUI

Thank you for your interest in contributing to Scribe! This guide will help you get started.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [ADHD Design Principles](#adhd-design-principles)
5. [Code Style](#code-style)
6. [Testing](#testing)
7. [Pull Request Process](#pull-request-process)
8. [Questions](#questions)

---

## Code of Conduct

Be respectful, inclusive, and constructive. We're all here to build something helpful.

---

## Getting Started

### Prerequisites

- macOS 14+ (Sonoma)
- Xcode 15.2+
- Basic Swift/SwiftUI knowledge (see [SWIFT-DEVELOPMENT.md](SWIFT-DEVELOPMENT.md))

### Setup

```bash
# Clone repository (once GitHub repo is created)
git clone https://github.com/Data-Wise/scribe-native.git
cd scribe-native

# Build
cd Scribe
swift build

# Run tests
swift test

# Open in Xcode
open Package.swift
```

---

## Development Workflow

### 1. Check Scope

**Before adding any feature, ask:**

- ✅ Does it help ADHD focus?
- ✅ Is it a native macOS-only feature?
- ❌ Does it require API keys? (Reject)
- ❌ Does it add UI clutter? (Reconsider)

**See PROJECT-DEFINITION.md for what's in scope.**

### 2. Create Branch

```bash
git checkout -b feat/feature-name
# Or: fix/bug-name, docs/doc-name
```

### 3. Make Changes

- Follow ADHD design principles (see below)
- Write tests for new features
- Update documentation

### 4. Test

```bash
cd Scribe
swift test
swift build  # Ensure no compiler errors
```

### 5. Commit

```bash
git add -A
git commit -m "feat: Add feature description

- Detail 1
- Detail 2

Closes #123"
```

**Commit Message Format:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation only
- `test:` Add/update tests
- `refactor:` Code restructure
- `style:` Formatting only

### 6. Push & PR

```bash
git push origin feat/feature-name

# Create PR
gh pr create --base main --title "feat: Feature name"
```

---

## ADHD Design Principles

**These override all other design decisions.**

### 1. Zero Friction (< 3 seconds to write)

❌ Bad:
```swift
// Multi-step process to create note
showProjectPicker()
  .then { showTemplatePicker() }
  .then { showTitleInput() }
  .then { openEditor() }
```

✅ Good:
```swift
// One keyboard shortcut → editor
KeyboardShortcuts.onKeyDown(for: .quickCapture) {
    createNoteAndFocus()  // Direct to editor
}
```

### 2. One Thing at a Time

❌ Bad:
```swift
// Multiple notes visible
HStack {
    EditorView(note: note1)
    EditorView(note2)
    EditorView(note3)
}
```

✅ Good:
```swift
// Single note focus
EditorView(note: selectedNote)
```

### 3. Escape Hatches (⌘W auto-saves)

❌ Bad:
```swift
.onDisappear {
    if noteHasChanges {
        showAlert("Save changes?")  // Friction!
    }
}
```

✅ Good:
```swift
.onDisappear {
    try? database.saveNote(note)  // Auto-save, no dialog
}
```

### 4. Visible Progress

✅ Always show:
- Word count
- Session timer
- Streak indicator
- Milestone celebrations

### 5. Sensory-Friendly

```swift
// Minimal animations
.animation(.easeInOut(duration: 0.2), value: showSidebar)

// NOT:
.animation(.spring(response: 0.6, dampingFraction: 0.8))  // Too bouncy

// Muted colors
Color.blue.opacity(0.1)  // Subtle backgrounds

// NOT:
Color.red  // Alarming
```

### 6. Quick Wins

```swift
// Celebrate milestones
if wordCount % 100 == 0 && wordCount > 0 {
    showCelebration("🎉 \(wordCount) words!")
}
```

---

## Code Style

### SwiftLint Rules

```yaml
# .swiftlint.yml (to be added)
disabled_rules:
  - trailing_whitespace
  - line_length

opt_in_rules:
  - empty_count
  - explicit_init

line_length: 120
```

### Naming Conventions

```swift
// Types: PascalCase
struct Page {}
class AppState {}
enum ProjectType {}

// Functions/variables: camelCase
func loadNotes() {}
var selectedPage: Page?

// Constants: camelCase
let maxWordCount = 10000

// Private: prefix with _
private var _cachedNotes: [Note] = []
```

### File Organization

```swift
// MARK: - Imports
import SwiftUI
import GRDB

// MARK: - Main Type
struct ContentView: View {

    // MARK: - Properties
    @StateObject private var appState = AppState()

    // MARK: - Body
    var body: some View {
        // ...
    }

    // MARK: - Private Methods
    private func loadData() {
        // ...
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
```

---

## Testing

### What to Test

✅ **Do test:**
- Business logic (word count, search, filtering)
- Data models (encoding/decoding, validation)
- Database operations (CRUD)
- Utility functions

❌ **Don't test:**
- SwiftUI views (use previews instead)
- Third-party libraries (GRDB, etc.)

### Test Example

```swift
import XCTest
@testable import Scribe

final class PageTests: XCTestCase {
    func testWordCount() {
        let page = Page(
            id: UUID(),
            title: "Test",
            content: "Hello world"
        )

        XCTAssertEqual(page.wordCount, 2)
    }

    func testPreviewTruncation() {
        let longContent = String(repeating: "A", count: 300)
        let page = Page(id: UUID(), title: "Test", content: longContent)

        XCTAssertEqual(page.preview.count, 200)
        XCTAssertTrue(page.preview.hasSuffix("..."))
    }
}
```

### Run Tests

```bash
cd Scribe
swift test

# In Xcode: ⌘U
```

---

## Pull Request Process

### Checklist

- [ ] Code follows ADHD design principles
- [ ] Tests added/updated
- [ ] Documentation updated (if needed)
- [ ] No compiler warnings
- [ ] Commit messages follow format
- [ ] Branch is up to date with main

### PR Description Template

```markdown
## What

Brief description of change

## Why

Why is this needed? What problem does it solve?

## ADHD Principle Alignment

Which principle does this support?
- [ ] Zero Friction
- [ ] One Thing at a Time
- [ ] Escape Hatches
- [ ] Visible Progress
- [ ] Sensory-Friendly
- [ ] Quick Wins

## Testing

How was this tested?

## Screenshots (if UI change)

[Add screenshots]

## Checklist

- [ ] Tests pass
- [ ] Documentation updated
- [ ] Follows code style
```

### Review Process

1. Automated checks (Swift build, tests)
2. Code review by maintainer
3. Feedback addressed
4. Merge to main

---

## Questions

### Where to Ask

- **General questions:** Open a [Discussion](https://github.com/Data-Wise/scribe-native/discussions) (when repo created)
- **Bug reports:** Open an [Issue](https://github.com/Data-Wise/scribe-native/issues)
- **Feature requests:** Open an [Issue](https://github.com/Data-Wise/scribe-native/issues) with `[Feature]` prefix

### Documentation

- [README.md](README.md) - Project overview
- [QUICKSTART.md](QUICKSTART.md) - Get started in 5 minutes
- [SWIFT-DEVELOPMENT.md](SWIFT-DEVELOPMENT.md) - Swift/SwiftUI guide
- [DATABASE-SCHEMA.md](DATABASE-SCHEMA.md) - Database reference

---

## Thank You!

Every contribution helps make Scribe more useful for ADHD-friendly writing. 🙏

---

**Maintainers:** @Data-Wise
**License:** MIT
