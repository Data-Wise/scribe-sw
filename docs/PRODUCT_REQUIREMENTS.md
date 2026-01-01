# Product Requirements: Scribe Native

**Vision:** Obsidian + Overleaf for macOS  
**Target:** Statistics professors & researchers (ADHD-friendly)  
**Stack:** SwiftUI + WebKit hybrid

---

## Core Value Proposition

**"Write markdown and LaTeX with live preview, zero friction, native macOS performance"**

Unlike:

- **Obsidian:** No native LaTeX rendering
- **Overleaf:** No offline, no markdown wiki links
- **Typora:** No projects, no LaTeX autocomplete
- **Notion:** Proprietary, slow, online-only

---

## Feature Matrix

### Must Have (v1.0)

| Feature | Description | Obsidian | Overleaf | Scribe |
|---------|-------------|----------|----------|--------|
| **Live Markdown Preview** | WYSIWYG editing | ✅ | ❌ | ✅ |
| **Live LaTeX Rendering** | Real-time math | ❌ | ✅ | ✅ |
| **Wiki Links** | `[[Note]]` linking | ✅ | ❌ | ✅ |
| **Projects** | Organize by research | ❌ | ✅ | ✅ |
| **Offline First** | No internet needed | ✅ | ❌ | ✅ |
| **Native macOS** | System integration | ❌ | ❌ | ✅ |
| **ADHD Features** | Word count, streaks | ❌ | ❌ | ✅ |

### Nice to Have (v2.0)

- [ ] Bibliography management (BibTeX)
- [ ] Git sync
- [ ] Collaborative editing
- [ ] PDF export with LaTeX
- [ ] Diagram rendering (Mermaid, TikZ)

---

## Editor Specification

### Dual-Pane Layout

```
┌─────────────────────────────────────────────────┐
│  Scribe - Research Notes          [⌘⇧C] [⌘D]   │
├──────────┬──────────────────────────────────────┤
│          │  # Introduction                      │
│ Projects │                                       │
│  ├─ 📊   │  This study examines...              │
│  │  Diss │                                       │
│  ├─ 📚   │  ## Method                           │
│  │  Teach│                                       │
│  └─ 📦   │  We used $\beta = 0.05$ with the     │
│     R-Pkg│  following model:                    │
│          │                                       │
│ Notes    │  $$                                   │
│  • Daily │  Y_i = \beta_0 + \beta_1 X_i +       │
│  • Ideas │      \epsilon_i                       │
│          │  $$                                   │
└──────────┴──────────────────────────────────────┘
   Sidebar       Editor (live preview)
```

### Editor Features

#### 1. Markdown Editing

**Source mode:**

```markdown
# Heading 1
## Heading 2

- Bullet list
- [[Wiki Link]]
- #tag

**bold** *italic* `code`

> Blockquote
```

**Live Preview mode:**

- Headers render with size/weight
- Lists auto-indent
- Links are clickable
- Tags are colored badges
- Code has syntax highlighting

**Implementation:**

```swift
import Ink
import Splash  // Syntax highlighting

struct MarkdownEditor: NSViewRepresentable {
    @Binding var text: String
    
    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        
        // Live markdown styling
        textView.layoutManager?.delegate = MarkdownLayoutDelegate()
        
        return textView
    }
}
```

#### 2. LaTeX Math Rendering

**Inline math:** `$\alpha = 0.05$` → α = 0.05  
**Block math:**

```latex
$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$
```

**Renders to:**
<img src="data:image/svg+xml;base64,..." alt="rendered equation">

**Implementation:**

```swift
import WebKit

struct MathPreview: NSViewRepresentable {
    let latex: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
        </head>
        <body>
            <div id="math">\\[\(latex)\\]</div>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }
}
```

#### 3. Wiki Links & Autocomplete

**Syntax:** `[[Note Title]]`

**Behavior:**

1. Type `[[`
2. Autocomplete popup appears
3. Filter as you type
4. Select note → creates link
5. Click link → opens note

**Implementation:**

```swift
class WikiLinkAutocomplete: NSObject, NSTextViewDelegate {
    func textView(_ textView: NSTextView, 
                  shouldChangeTextIn range: NSRange,
                  replacementString text: String) -> Bool {
        
        if text == "[" && textView.string[range.location - 1] == "[" {
            showAutocomplete(at: range.location)
        }
        
        return true
    }
    
    func showAutocomplete(at position: Int) {
        let popover = NSPopover()
        popover.contentViewController = NoteSearchViewController()
        popover.show(relativeTo: bounds, of: textView, preferredEdge: .maxY)
    }
}
```

---

## Data Model

### Note Structure

```swift
struct Note: Codable, Identifiable {
    let id: String
    var title: String
    var content: String  // Raw markdown + LaTeX
    var projectId: String?
    
    // Parsed metadata
    var wikiLinks: [String]  // [[Note]] references
    var tags: [String]       // #tag mentions
    var equations: [String]  // LaTeX blocks
    
    // Computed
    var wordCount: Int
    var equationCount: Int
    var backlinks: [String]  // Notes linking to this
    
    var createdAt: Date
    var updatedAt: Date
}
```

### Storage

**Format:** Markdown files + SQLite index

```
~/Library/Application Support/Scribe/
├── notes/
│   ├── abc123.md          # Raw markdown
│   ├── def456.md
│   └── ...
└── scribe.sqlite           # Metadata, FTS, links
```

**Why hybrid?**

- ✅ Markdown files: Git-friendly, portable, human-readable
- ✅ SQLite: Fast search, relationship queries
- ✅ Best of both worlds

---

## Technical Architecture

### Layer Diagram

```
┌────────────────────────────────────────┐
│          SwiftUI Views                 │
│  (ContentView, EditorView, Sidebar)    │
└────────────────┬───────────────────────┘
                 │
┌────────────────▼───────────────────────┐
│         AppState (ObservableObject)    │
│  - Current note, project               │
│  - Editor state (mode, cursor)         │
└────────────────┬───────────────────────┘
                 │
┌────────────────▼───────────────────────┐
│     Use Cases / Interactors            │
│  - CreateNoteUseCase                   │
│  - RenderMarkdownUseCase               │
│  - ParseLatexUseCase                   │
└──────┬─────────┬─────────────┬─────────┘
       │         │             │
┌──────▼────┐ ┌──▼──────┐ ┌───▼─────────┐
│NoteRepo   │ │Markdown │ │ LaTeX       │
│           │ │Parser   │ │ Renderer    │
└──────┬────┘ └─────────┘ └─────────────┘
       │
┌──────▼────────────────────────────────┐
│  Data Layer                           │
│  - FileManager (markdown files)       │
│  - GRDB (SQLite index)                │
└───────────────────────────────────────┘
```

### Key Components

#### 1. MarkdownParser

```swift
protocol MarkdownParser {
    func parse(_ markdown: String) -> Document
    func extractWikiLinks(_ markdown: String) -> [String]
    func extractTags(_ markdown: String) -> [String]
}

class SwiftMarkdownParser: MarkdownParser {
    func parse(_ markdown: String) -> Document {
        return Document(parsing: markdown)
    }
}
```

#### 2. LaTeXRenderer

```swift
protocol LaTeXRenderer {
    func render(_ latex: String) async -> NSImage?
}

actor WebKitLatexRenderer: LaTeXRenderer {
    func render(_ latex: String) async -> NSImage? {
        // Use WKWebView with MathJax
        // Render to image or PDF
    }
}
```

#### 3. EditorCoordinator

```swift
@MainActor
class EditorCoordinator: ObservableObject {
    @Published var content: String = ""
    @Published var mode: EditorMode = .livePreview
    @Published var cursorPosition: Int = 0
    
    var renderedHTML: String {
        markdownParser.parse(content).toHTML()
    }
    
    func insertWikiLink(_ title: String) {
        let link = "[[\(title)]]"
        // Insert at cursor
    }
}
```

---

## Performance Requirements

### Must Support

| Metric | Target | Critical For |
|--------|--------|--------------|
| File size | Up to 1MB | Dissertations |
| LaTeX equations | 100+ per doc | Math papers |
| Live preview lag | < 50ms | Smooth typing |
| Search results | < 100ms | 10k+ notes |
| Wiki link autocomplete | < 30ms | Responsiveness |

### Optimization Strategies

1. **Incremental Parsing**
   - Only re-parse changed paragraphs
   - Cache rendered LaTeX as images

2. **Lazy Loading**
   - Render equations on-demand
   - Virtual scrolling for long docs

3. **Background Processing**
   - Parse LaTeX in background actor
   - Update FTS index async

---

## ADHD-Specific Features

### 1. Focus Mode

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│     # Current Paragraph             │
│                                     │
│     Everything else dimmed/hidden   │
│                                     │
│                                     │
│          [200 words today]          │
└─────────────────────────────────────┘
```

### 2. Writing Stats Widget

```swift
struct WritingStatsView: View {
    @ObservedObject var stats: WritingStats
    
    var body: some View {
        VStack {
            Text("\(stats.wordsToday)")
                .font(.system(size: 48, weight: .bold))
            
            ProgressView(value: Double(stats.wordsToday), 
                        total: Double(stats.dailyGoal))
            
            HStack {
                Label("\(stats.currentStreak) days", systemImage: "flame.fill")
                Label("\(stats.equationsWritten) eqs", systemImage: "function")
            }
        }
    }
}
```

### 3. Quick Capture (⌘⇧C)

Global hotkey → floating window → type → auto-saves to inbox

---

## Development Roadmap

### Phase 1: Foundation (Current)

- [x] Project structure
- [x] Documentation
- [ ] Fix architecture issues
- [ ] Implement database layer

### Phase 2: Editor MVP (4-6 weeks)

- [ ] Basic markdown editor
- [ ] Live preview (HTML)
- [ ] File-based storage
- [ ] Wiki link parsing

### Phase 3: LaTeX (3-4 weeks)

- [ ] MathJax integration
- [ ] Inline math rendering
- [ ] Block equations
- [ ] Equation autocomplete

### Phase 4: Polish (2-3 weeks)

- [ ] Syntax highlighting
- [ ] Theme system
- [ ] ADHD features
- [ ] Performance optimization

---

## Success Criteria

**v1.0 Launch:**

- ✅ Write markdown with live preview
- ✅ Write LaTeX equations that render in real-time
- ✅ Create wiki-linked notes
- ✅ Organize by research project
- ✅ Full-text search < 100ms
- ✅ Works offline
- ✅ Native macOS (menu bar, shortcuts, Spotlight)

**User Feedback Target:**

- "Feels like Obsidian but renders my equations"
- "Finally, Overleaf that works offline"
- "ADHD-friendly writing environment"

---

## Open Questions

1. **Bibliography management?** BibTeX integration? Zotero API?
2. **PDF export?** LaTeX → PDF via pandoc?
3. **Diagram support?** Mermaid, TikZ, graphviz?
4. **Version control?** Git integration or built-in?
5. **Sync?** iCloud, Dropbox, or custom?

---

**This is the TRUE vision. Architecture must support this.**
