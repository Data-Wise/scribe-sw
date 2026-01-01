# Updated Architecture Analysis - Based on Scribe Tauri Version

**Date:** 2025-12-31  
**Context:** After reviewing existing Scribe (Tauri) codebase  
**Status:** 🟢 Much better foundation than initially assessed

---

## Key Discoveries

### ✅ What Already Exists (Tauri Version)

1. **HybridEditor** - Custom markdown editor with live preview
2. **KaTeX Integration** - LaTeX math rendering ($ and $$)
3. **Wiki Links** - `[[link]]` with autocomplete
4. **Tags** - `#tag` with autocomplete
5. **Projects** - Research, Teaching, R-Package, R-Dev, Generic
6. **Citations** - `@cite` with Zotero integration
7. **8 Themes** - Visual theme gallery
8. **AI Chat** - Claude + Gemini CLI
9. **Export** - PDF, Word, LaTeX via Pandoc
10. **483 tests passing** - Comprehensive test suite

### 🎯 What You Need for **Native Version**

The SwiftUI version should **replicate** these features natively, NOT reinvent them.

---

## Revised Product Vision

### Scribe Native = Tauri Scribe - 90MB + Native Features

| Feature | Tauri (Current) | SwiftUI (Goal) | Status |
|---------|----------------|----------------|--------|
| **Editor** | HybridEditor (React) | TextKit 2 + WebKit | To implement |
| **Math** | KaTeX (WebView) | MathJax (WebView) | Same approach |
| **Database** | SQLite (Rust) | GRDB (Swift) | ✅ Schema compatible |
| **UI** | React + Tailwind | SwiftUI | Native rewrite |
| **Size** | ~100MB | ~10MB | Major win |
| **Performance** | Good | Excellent | Native advantage |
| **Menu Bar** | Limited | ✅ Native | New feature |
| **Global Hotkeys** | ⌘⇧N only | ✅ All system-wide | New feature |
| **Spotlight** | ❌ No | ✅ Index notes | New feature |

---

## Architecture NOT Needed to Change

### Keep From Review (Still Valid)

1. **Schema Mismatch Issue** - Still critical
   - Tauri uses: `notes`, `projects`
   - Swift code has: `Page`, `Vault`
   - **Must align:** `Note`, `Project` (or `Vault` if renaming)

2. **Dependency Injection** - Still recommended
   - Makes testing possible
   - Enables mocking

3. **Error Handling** - Still missing
   - Add `ScribeError` enum
   - Proper error propagation

### Drop From Review (Over-engineered)

1. ~~Repository Pattern~~ - Overkill for native app
   - Direct `DatabaseService` is fine
   - Just make it an `actor` for safety

2. ~~Use Cases Layer~~ - Unnecessary complexity
   - AppState can call DatabaseService directly
   - SwiftUI binding makes this natural

3. ~~Clean Architecture Layers~~ - Too heavy
   - **Keep it simple:** Views → AppState → DatabaseService → GRDB

---

## Recommended Architecture (Simplified)

```
┌─────────────────────────────────────────┐
│         SwiftUI Views                   │
│  (ContentView, EditorView, Sidebar)     │
└──────────────┬──────────────────────────┘
               │ @Environment
┌──────────────▼──────────────────────────┐
│     AppState (ObservableObject)         │
│  @Published var notes: [Note]           │
│  @Published var projects: [Project]     │
│                                         │
│  func createNote() async throws         │
│  func saveNote(_ note: Note) async throws│
└──────────────┬──────────────────────────┘
               │ async/await
┌──────────────▼──────────────────────────┐
│     DatabaseService (actor)             │
│                                         │
│  func fetchNotes() throws -> [Note]     │
│  func saveNote(_ note: Note) throws     │
│  func searchNotes(_ query: String) throws│
└──────────────┬──────────────────────────┘
               │ GRDB
┌──────────────▼──────────────────────────┐
│        SQLite Database                  │
│  ~/Library/Application Support/Scribe   │
│  scribe.sqlite                          │
└─────────────────────────────────────────┘
```

**Three layers. That's it.**

---

## Editor Implementation Strategy

### Hybrid Approach (Like Tauri Version)

```swift
struct NoteEditorView: View {
    @Binding var content: String
    @State private var mode: EditorMode = .livePreview
    
    var body: some View {
        HSplitView {
            if mode == .source || mode == .livePreview {
                // Left: Native TextKit editor
                MarkdownTextEditor(text: $content)
                    .font(.system(.body, design: .monospaced))
            }
            
            if mode == .livePreview || mode == .reading {
                // Right: WebKit with rendered markdown + LaTeX
                WebKitPreview(markdown: content)
                    .mathJaxEnabled(true)
            }
        }
        .toolbar {
            EditorModeToggle(mode: $mode)
        }
    }
}
```

### Why Hybrid?

✅ **Fast native editing** - TextKit is instant  
✅ **Full LaTeX support** - MathJax in WebKit  
✅ **Battle-tested** - Same as Tauri version  
✅ **Familiar** - Users know this pattern  

---

## Data Model (CORRECTED)

### Match Tauri Schema

```swift
// Sources/Scribe/Models/Note.swift
struct Note: Codable, Identifiable, FetchableRecord, PersistableRecord {
    var id: String  // UUID string
    var title: String
    var content: String  // Raw markdown + LaTeX
    var folder: String  // "inbox", "ideas", etc.
    var projectId: String?
    var properties: String?  // JSON frontmatter
    var createdAt: Int64
    var updatedAt: Int64
    var deletedAt: Int64?
    
    static let databaseTableName = "notes"
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, folder
        case projectId = "project_id"
        case properties
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// Sources/Scribe/Models/Project.swift (or Vault.swift if renaming)
struct Project: Codable, Identifiable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var description: String?
    var type: ProjectType  // research, teaching, r-package, r-dev, generic
    var color: String?
    var settings: String?  // JSON
    var createdAt: Int64
    var updatedAt: Int64
    
    static let databaseTableName = "projects"
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, type, color, settings
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum ProjectType: String, Codable {
    case research
    case teaching
    case rPackage = "r-package"
    case rDev = "r-dev"
    case generic
}
```

---

## UI Design (From Tauri Schematic)

### Obsidian-Style Layout

```
┌─────────────────────────────────────────────────────────┐
│  ⚡ Scribe                        [―] [□] [×]           │
├────────────────┬────────────────────────────┬──────── ───┤
│                │  ┌──────────────────────┐ │            │
│  VAULTS        │  │ 🏠 Mission   📄 Note │ │  RIGHT     │
│  ──────────    │  └──────────────────────┘ │  SIDEBAR   │
│                │  ═══════════════════════  │            │
│  ▼ 📥 Inbox    │                           │ Properties │
│    • Idea 1    │  # Heading                │ Backlinks  │
│                │                           │ Tags       │
│  ▼ 🔬 Research │  Body text...             │            │
│    ▼ 📁 Mediation                           │            │
│      📄 Draft  │  $$                       │            │
│      📄 Methods│  Y_i = \beta_0 + \epsilon │            │
│                │  $$                       │            │
│  ▶ 📚 Teaching │                           │            │
│  ▶ 📝 Personal │                           │            │
│                │                           │            │
├────────────────┤                           │            │
│ 🔥 7 │ 📊 1.2k │  Source ⌘E  1,247 words  │            │
└────────────────┴────────────────────────────┴────────────┘
```

---

## Implementation Roadmap (Revised)

### Phase 1: Foundation (Weeks 1-2)

1. **Fix Schema Alignment**
   - Rename `Page` → `Note`
   - Rename `Vault` → `Project` (keep as Project to match Tauri)
   - Update all references

2. **Implement DatabaseService**
   - Make it an `actor` for thread safety
   - Use GRDB properly with migrations
   - Match Tauri schema exactly

3. **Basic AppState**
   - Simple @Published properties
   - Direct calls to DatabaseService
   - Async/await for safety

### Phase 2: Editor (Weeks 3-4)

1. **Hybrid Editor**
   - Native TextKit for source editing
   - WebKit for preview
   - MathJax for LaTeX
   - Split-pane like Tauri version

2. **Wiki Links & Tags**
   - `[[link]]` autocomplete
   - `#tag` autocomplete
   - Autocomplete popup view

### Phase 3: UI Polish (Weeks 5-6)

1. **Obsidian-Style Sidebar**
   - Collapsible vaults
   - Folder tree
   - Permanent inbox

2. **Editor Tabs**
   - Gradient accent (Style 5 from schematic)
   - Pinned Mission Control
   - Drag to reorder

3. **Native Features**
   - Menu bar extra
   - Global hotkeys (⌘⇧C, ⌘⇧D)
   - Spotlight indexing

### Phase 4: Academic Features (Weeks 7-8)

1. **Citations**
   - `@cite` autocomplete
   - Zotero integration
   - Bibliography panel

2. **Export**
    - Pandoc integration
    - PDF, Word, LaTeX
    - Export dialog

---

## Success Criteria (Aligned with Tauri)

### Feature Parity

- ✅ All tier 1-5 features from PROJECT-DEFINITION.md
- ✅ HybridEditor with live LaTeX
- ✅ Wiki links, tags, citations
- ✅ Projects (5 types)
- ✅ Export (PDF, Word, LaTeX)
- ✅ AI Chat (Claude + Gemini CLI)

### Native Advantages

- ✅ <10MB app size (vs 100MB)
- ✅ True menu bar integration
- ✅ System-wide global hotkeys
- ✅ Spotlight indexing
- ✅ Native widgets (future)

---

## Revised Effort Estimate

| Phase | Features | Hours | Complexity |
|-------|---------|-------|------------|
| **Phase 1** | Schema + DB + AppState | 12-16h | Medium |
| **Phase 2** | Hybrid Editor + Math | 20-24h | High |
| **Phase 3** | UI (Obsidian style) | 16-20h | Medium |
| **Phase 4** | Academic + Export | 12-16h | Medium |
| **Testing** | Unit + Integration | 8-12h | Medium |
| **Total** | Full feature parity | **68-88h** | - |

**Timeline:** 2-3 months @ 4-8h/week

---

## Critical Path

### Week 1: Schema & Database

1. Rename models to match Tauri
2. Implement GRDB migrations
3. Test CRUD operations

### Week 2-3: Editor

1. TextKit source editor
2. WebKit preview
3. MathJax integration
4. Wiki link parsing

### Week 4-5: UI

1. Vault sidebar (Obsidian-style
2. Editor tabs with Mission Control
3. Status bar

### Week 6-7: Features

1. Citations (@cite)
2. Export (Pandoc)
3. AI Chat integration

### Week 8: Polish

1. Global hotkeys
2. Menu bar
3. Spotlight indexing
4. Final testing

---

## Conclusion

### Previous Assessment: **3/10** - Incomplete scaffold

### Current Assessment: **7/10** - Good foundation with clear path

**Why higher score:**

- Have working Tauri version as reference
- Schema is defined and proven
- UI design is documented (schematic)
- 483 tests show commitment to quality
- Clear feature list (not vague requirements)

**What's still needed:**

1. Fix schema mismatch in Swift code
2. Implement proper DatabaseService
3. Build hybrid editor (TextKit + WebKit)
4. Replicate Tauri UI in SwiftUI

**Recommendation:** ✅ **Proceed with development**

This is a **port**, not a greenfield project. Much less risky.

---

**Next step:** Start with Phase 1 (Schema alignment) from REFACTORING_PLAN.md
