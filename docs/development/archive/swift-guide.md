# Swift Development Guide

> Beginner-friendly guide to developing Scribe with SwiftUI

**Audience:** Python/R developers learning Swift
**Prerequisites:** Xcode 15.2+, macOS 14+
**Estimated Learning Time:** 2-4 hours for basics

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Swift Basics for Python/R Developers](#swift-basics)
3. [SwiftUI Concepts](#swiftui-concepts)
4. [Project Structure](#project-structure)
5. [Common Tasks](#common-tasks)
6. [Testing](#testing)
7. [Debugging](#debugging)
8. [Resources](#resources)

---

## Prerequisites

### Install Xcode

```bash
# Check if Xcode is installed
xcode-select -p

# If not, install from App Store
# Then select command line tools
sudo xcode-select --switch /Applications/Xcode.app
```

### Verify Swift Version

```bash
swift --version
# Should be Swift 5.9+ (Xcode 15.2+)
```

### Open Project

```bash
cd ~/projects/dev-tools/scribe-sw/Scribe
open Package.swift  # Opens in Xcode
```

---

## Swift Basics

### Key Differences from Python/R

| Concept | Python/R | Swift |
|---------|----------|-------|
| **Types** | Dynamic | Static (type-safe) |
| **Syntax** | Indentation | Braces `{}` |
| **Variables** | `x = 5` | `let x = 5` (immutable)<br>`var y = 10` (mutable) |
| **Functions** | `def foo():` | `func foo() {}` |
| **Classes** | `class Foo:` | `struct Foo {}` (preferred)<br>`class Bar {}` |
| **Nil** | `None` | `nil` (must be Optional) |

### Immutability by Default

```swift
let x = 5        // Immutable (like R's assignment)
x = 10           // ERROR: Cannot assign to immutable

var y = 5        // Mutable
y = 10           // OK
```

### Type Inference

```swift
let name = "Scribe"          // Inferred as String
let count = 42               // Inferred as Int
let items: [String] = []     // Explicit type annotation
```

### Optionals (Handling nil)

```swift
var title: String? = nil     // Optional String (can be nil)
var title: String = nil      // ERROR: String cannot be nil

// Unwrapping optionals
if let unwrapped = title {
    print(unwrapped)         // Safe: only if not nil
}

// Nil coalescing
let displayTitle = title ?? "Untitled"  // Default if nil
```

### Functions

```swift
// Python:
// def greet(name, times=1):
//     return f"Hello {name}" * times

// Swift:
func greet(name: String, times: Int = 1) -> String {
    return String(repeating: "Hello \(name)", count: times)
}

let message = greet(name: "World")
```

### Structs vs Classes

**Use `struct` (value type) by default:**

```swift
struct Page {
    let id: String
    var title: String
    var content: String
}

var page1 = Page(id: "1", title: "Note", content: "Text")
var page2 = page1  // COPY (not reference)
page2.title = "Different"  // page1.title unchanged
```

**Use `class` (reference type) only when needed:**

```swift
class AppState: ObservableObject {
    @Published var selectedPage: Page?
    // Shared mutable state
}
```

---

## SwiftUI Concepts

### Declarative UI

**Python (imperative):**
```python
label = QLabel("Hello")
label.setText("World")  # Mutate state
```

**SwiftUI (declarative):**
```swift
Text(title)  // UI is function of state
// When `title` changes, UI auto-updates
```

### View Protocol

Every view conforms to `View`:

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
```

### State Management

#### `@State` - Local view state

```swift
struct EditorView: View {
    @State private var content: String = ""

    var body: some View {
        TextEditor(text: $content)  // $ = binding
    }
}
```

#### `@Published` - Observable state

```swift
class AppState: ObservableObject {
    @Published var notes: [Note] = []
    // When notes changes, views re-render
}
```

#### `@StateObject` / `@ObservedObject` - Observing changes

```swift
struct ContentView: View {
    @StateObject private var appState = AppState()  // Create once

    var body: some View {
        NotesList(notes: appState.notes)
            .environmentObject(appState)  // Share with children
    }
}

struct NotesList: View {
    @EnvironmentObject var appState: AppState  // Access parent's state
    let notes: [Note]

    var body: some View {
        List(notes) { note in
            Text(note.title)
        }
    }
}
```

### Modifiers (Chainable)

```swift
Text("Hello")
    .font(.headline)
    .foregroundColor(.blue)
    .padding()
    .background(Color.gray.opacity(0.1))
    .cornerRadius(8)
```

---

## Project Structure

```
Scribe/
├── Package.swift              # Dependencies
├── Sources/Scribe/
│   ├── ScribeApp.swift        # @main entry point
│   │
│   ├── Models/                # Data structures
│   │   ├── Vault.swift        # struct Vault
│   │   └── Page.swift         # struct Page
│   │
│   ├── Views/                 # UI components
│   │   ├── ContentView.swift  # Main layout
│   │   ├── VaultSidebar.swift # Left navigation
│   │   └── PageEditor.swift   # Markdown editor
│   │
│   ├── Store/                 # State management
│   │   └── AppState.swift     # class AppState: ObservableObject
│   │
│   └── Services/              # Business logic
│       └── DatabaseService.swift  # GRDB wrapper
│
└── Tests/
    └── ScribeTests/
        └── ScribeTests.swift  # Unit tests
```

### File Naming Conventions

- **Views:** `PageEditorView.swift` or `PageEditor.swift`
- **Models:** `Page.swift`, `Vault.swift`
- **Services:** `DatabaseService.swift`, `AIService.swift`
- **Extensions:** `String+Extensions.swift`

---

## Common Tasks

### Add a New Model

```swift
// Sources/Scribe/Models/Tag.swift
struct Tag: Identifiable, Codable {
    let id: UUID
    var name: String
    var color: String
}
```

### Add a New View

```swift
// Sources/Scribe/Views/TagBadge.swift
import SwiftUI

struct TagBadge: View {
    let tag: Tag

    var body: some View {
        Text(tag.name)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: tag.color))
            .cornerRadius(4)
    }
}

#Preview {
    TagBadge(tag: Tag(id: UUID(), name: "Swift", color: "#007AFF"))
}
```

### Access Database

```swift
// Sources/Scribe/Services/DatabaseService.swift
import GRDB

class DatabaseService {
    private let dbQueue: DatabaseQueue

    init() throws {
        let fileManager = FileManager.default
        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dbPath = appSupport.appendingPathComponent("Scribe/scribe.sqlite").path
        dbQueue = try DatabaseQueue(path: dbPath)
    }

    func fetchNotes() throws -> [Note] {
        try dbQueue.read { db in
            try Note
                .filter(Column("deleted_at") == nil)
                .order(Column("updated_at").desc)
                .fetchAll(db)
        }
    }

    func saveNote(_ note: Note) throws {
        try dbQueue.write { db in
            try note.save(db)
        }
    }
}
```

### Add to AppState

```swift
// Sources/Scribe/Store/AppState.swift
class AppState: ObservableObject {
    @Published var notes: [Note] = []
    @Published var selectedNote: Note?

    private let db: DatabaseService

    init() {
        self.db = try! DatabaseService()
        loadNotes()
    }

    func loadNotes() {
        notes = (try? db.fetchNotes()) ?? []
    }

    func createNote(title: String) {
        let note = Note(id: UUID(), title: title, content: "")
        try? db.saveNote(note)
        loadNotes()
    }
}
```

### Add Keyboard Shortcut

```swift
// In ScribeApp.swift
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let quickCapture = Self("quickCapture")
    static let dailyNote = Self("dailyNote")
}

// Register in ScribeApp
.onAppear {
    KeyboardShortcuts.onKeyDown(for: .quickCapture) {
        appState.showQuickCapture = true
    }
}
```

---

## Testing

### Unit Test Example

```swift
// Tests/ScribeTests/NoteTests.swift
import XCTest
@testable import Scribe

final class NoteTests: XCTestCase {
    func testWordCount() {
        let note = Note(
            id: UUID(),
            title: "Test",
            content: "Hello world from Swift"
        )

        XCTAssertEqual(note.wordCount, 4)
    }

    func testPreview() {
        let note = Note(
            id: UUID(),
            title: "Long Note",
            content: String(repeating: "A", count: 300)
        )

        XCTAssertEqual(note.preview.count, 200)
        XCTAssertTrue(note.preview.hasSuffix("..."))
    }
}
```

### Run Tests

```bash
cd Scribe
swift test

# Or in Xcode: ⌘U
```

---

## Debugging

### Print Debugging

```swift
print("Note ID: \(note.id)")
print("Notes count: \(notes.count)")

// Formatted debug output
dump(note)  // Shows all properties
```

### Xcode Breakpoints

1. Click line number gutter → breakpoint
2. Run in debug mode (⌘R)
3. Inspect variables in bottom panel
4. Step over: F6, Step into: F7

### View Hierarchy

In Xcode preview or running app:
- Click "Debug View Hierarchy" button (3D icon)
- Inspect view tree and constraints

---

## Resources

### Official Documentation

- [Swift Book](https://docs.swift.org/swift-book/) - Complete language guide
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui) - Apple's official tutorials
- [GRDB Documentation](https://github.com/groue/GRDB.swift) - SQLite wrapper

### Recommended Learning Path

1. **Week 1:** Swift basics (types, optionals, functions, structs)
2. **Week 2:** SwiftUI basics (Views, State, Lists)
3. **Week 3:** GRDB (database queries, models)
4. **Week 4:** Combine (reactive programming, @Published)

### Quick References

- [Swift Cheat Sheet](https://koenig-media.raywenderlich.com/uploads/2020/12/RW-Swift-5.1-Cheatsheet-1.0.pdf)
- [SwiftUI Cheat Sheet](https://fuckingswiftui.com/)
- [GRDB Cheat Sheet](https://github.com/groue/GRDB.swift/blob/master/Documentation/GoodPracticesForDesigningRecordTypes.md)

### Community

- [Swift Forums](https://forums.swift.org/)
- [r/swift](https://reddit.com/r/swift)
- [r/SwiftUI](https://reddit.com/r/SwiftUI)

---

## Tips for Python/R Developers

1. **Think immutability first** - Use `let` by default, `var` only when needed
2. **Embrace optionals** - Better than None checks, compiler-enforced
3. **Use structs** - Value semantics avoid many bugs
4. **Type annotations help** - IDE autocomplete is much better
5. **Preview canvas** - Instant UI feedback, no need to run app
6. **Playgrounds** - Quick experiments without full project

---

## Next Steps

1. Read DATABASE-SCHEMA.md for schema reference
2. Explore Sources/Scribe/ directory
3. Try modifying a View in Xcode
4. Run tests with `swift test`
5. Read Apple's SwiftUI tutorials

---

**Happy Coding!** 🎉

For questions, see [CONTRIBUTING.md](CONTRIBUTING.md) or open an issue.
