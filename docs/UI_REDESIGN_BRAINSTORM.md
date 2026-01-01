# Scribe UI Redesign - ADHD-Friendly Writing Environment

**Date:** 2025-01-01  
**Status:** 🎨 Design Phase  
**Goal:** Create a distraction-free, ADHD-optimized writing experience

---

## 🎯 Core Design Principles

### 1. Zero Friction (< 3 seconds to start writing)
- App opens directly to editor (no splash screen)
- Last note auto-opens OR quick capture ready
- Sidebar hidden by default (⌘B to toggle)
- No modal dialogs interrupting flow

### 2. One Thing at a Time
- **Single pane focus** by default
- Sidebar only for quick navigation (not always visible)
- Full-screen mode with minimal chrome
- Dimmed/hidden UI elements when writing

### 3. Escape Hatches Everywhere
- ⌘W closes without confirmation (auto-saves)
- ESC exits focus mode
- ⌘K command palette for everything
- All actions keyboard-accessible

### 4. Visible Progress
- Persistent stats in corner (non-intrusive)
- Real-time word count
- Session timer
- Streak indicator with 🔥 emoji

### 5. Sensory-Friendly
- Dark mode by default
- Minimal animations (respect reduced motion)
- Soft colors (no harsh whites)
- Comfortable reading fonts

---

## 🏗️ Layout Architecture

### Layout Modes

#### Mode 1: Focus Mode (Default - ADHD Optimized)
```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                                                            │
│                                                            │
│                   # Note Title                             │
│                                                            │
│                   Your content here...                     │
│                                                            │
│                                                            │
│                                                            │
│                                                            │
│                                                            │
│  ┌──────────────────────────────────────────────────┐     │
│  │ 📝 234 words · ⏱ 12m · 🔥 7 days · ⚡ 15 today  │     │
│  └──────────────────────────────────────────────────┘     │
└────────────────────────────────────────────────────────────┘
```

**Features:**
- No sidebar
- No toolbar
- No tabs
- Just: Title + Content + Stats footer
- All controls via keyboard (⌘K palette)

---

#### Mode 2: Navigator Mode (⌘B toggles)
```
┌────────────┬───────────────────────────────────────────────┐
│ PROJECTS   │  # Note Title                                 │
│            │                                               │
│ 🔬 Research│  Your content here...                         │
│ 📚 Teaching│                                               │
│ 📦 R-Pkg   │                                               │
│            │                                               │
│ RECENT     │                                               │
│ • Daily    │                                               │
│ • Ideas    │                                               │
│ • Todo     │                                               │
│            │                                               │
│ TAGS       │                                               │
│ #thesis    │                                               │
│ #stats     │                                               │
│            │  ┌────────────────────────────────────────┐   │
│            │  │ 📝 234 words · ⏱ 12m · 🔥 7 days     │   │
│            │  └────────────────────────────────────────┘   │
└────────────┴───────────────────────────────────────────────┘
   200px           Flexible width
```

**Features:**
- Collapsible sidebar (200px fixed width)
- Project grouping
- Recent notes (top 10)
- Tag cloud
- Click anywhere in editor → sidebar auto-hides (focus mode)

---

#### Mode 3: Split View Mode (⌘⇧P for preview)
```
┌────────────┬─────────────────────┬──────────────────────────┐
│ PROJECTS   │ # Note Title        │ # Rendered Preview       │
│            │                     │                          │
│ 🔬 Research│ Your **bold** text  │ Your bold text           │
│ 📚 Teaching│                     │                          │
│ 📦 R-Pkg   │ ## Math             │ Math                     │
│            │                     │                          │
│ RECENT     │ $$                  │  β₀ + β₁X + ε            │
│ • Daily    │ \beta_0 + \beta_1 X │ (rendered LaTeX)         │
│ • Ideas    │ + \epsilon          │                          │
│            │ $$                  │                          │
│            │                     │                          │
│            │ [[Wiki Link]]       │ Wiki Link (clickable)    │
│            │                     │                          │
│            │ Stats footer        │ Stats footer             │
└────────────┴─────────────────────┴──────────────────────────┘
```

**Features:**
- Live LaTeX rendering (MathJax/KaTeX)
- Live markdown preview
- Scroll sync between panes
- Click preview → jumps to source

---

## 🎨 Visual Design System

### Color Palette (Dark Mode Default)

```swift
struct ScribeColors {
    // Base
    static let background = Color(hex: "#1e1e1e")      // VSCode dark
    static let surface = Color(hex: "#252526")         // Slightly lighter
    static let border = Color(hex: "#3e3e42")          // Subtle borders
    
    // Text
    static let textPrimary = Color(hex: "#d4d4d4")     // Main text
    static let textSecondary = Color(hex: "#858585")   // Metadata
    static let textTertiary = Color(hex: "#6a6a6a")    // Placeholders
    
    // Accents
    static let accent = Color(hex: "#007acc")          // Blue (links, focus)
    static let success = Color(hex: "#4ec9b0")         // Green (stats)
    static let warning = Color(hex: "#ce9178")         // Orange (warnings)
    static let error = Color(hex: "#f48771")           // Red (errors)
    
    // Project Types
    static let research = Color(hex: "#569cd6")        // Blue
    static let teaching = Color(hex: "#4ec9b0")        // Teal
    static let rPackage = Color(hex: "#dcdcaa")        // Yellow
    static let rDev = Color(hex: "#808080")            // Gray
    
    // Special
    static let streak = Color(hex: "#ff6b35")          // Flame orange
    static let latex = Color(hex: "#b5cea8")           // Math green
}
```

### Typography

```swift
struct ScribeFonts {
    // Editor (monospace for markdown)
    static let editor = Font.custom("SF Mono", size: 16)
    static let editorBold = Font.custom("SF Mono", size: 16).bold()
    
    // Preview (sans-serif for rendered)
    static let preview = Font.system(size: 16, design: .default)
    static let previewHeading1 = Font.system(size: 32, weight: .bold)
    static let previewHeading2 = Font.system(size: 24, weight: .semibold)
    
    // UI Elements
    static let uiBody = Font.system(size: 13)
    static let uiCaption = Font.system(size: 11)
    static let uiTitle = Font.system(size: 14, weight: .semibold)
    
    // Stats
    static let statsLarge = Font.system(size: 36, weight: .bold, design: .rounded)
    static let statsSmall = Font.system(size: 12, weight: .medium, design: .rounded)
}
```

---

## 🧩 Component Breakdown

### 1. Editor Component
```
┌─────────────────────────────────────────────────┐
│ Note Title (inline editable)                    │ ← Large, bold, no border
├─────────────────────────────────────────────────┤
│                                                 │
│ # Heading 1                                     │ ← Auto-styled
│                                                 │
│ Your content with **bold** and *italic*         │
│                                                 │
│ [[Wiki Link]]  ← clickable, underlined          │
│                                                 │
│ #tag #another  ← colored badges                 │
│                                                 │
│ $$                                              │
│ \beta_0 + \beta_1 X + \epsilon                  │ ← Inline preview
│ $$                                              │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Features:**
- Live inline styling (bold, italic, headers)
- Click [[wiki link]] → navigate
- Hover math → show rendered preview
- Auto-save on every keystroke (debounced 1s)
- No scrollbars (macOS natural scrolling)

---

### 2. Sidebar Component
```
┌────────────────────┐
│ Scribe        [+]  │ ← App title + New note
├────────────────────┤
│                    │
│ 🔍 Search...       │ ← ⌘F opens, ESC closes
│                    │
├────────────────────┤
│ PROJECTS      [▼]  │ ← Collapsible sections
│                    │
│ 🔬 Research    (3) │ ← Icon + name + count
│ 📚 Teaching    (7) │
│ 📦 R-Package   (2) │
│ 📁 Inbox      (12) │
│                    │
├────────────────────┤
│ RECENT        [▼]  │
│                    │
│ • 2025-01-01       │ ← Daily note
│ • Ideas & Todo     │
│ • Dissertation     │
│                    │
├────────────────────┤
│ TAGS          [▼]  │
│                    │
│ #thesis        (5) │
│ #statistics    (8) │
│ #todo          (3) │
│                    │
└────────────────────┘
```

**Interactions:**
- Click project → filter notes
- Click tag → filter by tag
- Click recent → open note
- Drag & drop to move notes between projects

---

### 3. Stats Footer (Always Visible)
```
┌──────────────────────────────────────────────────────────────┐
│ 📝 234 words · ⏱ 12m 34s · 🔥 7 days · ⚡ 15 today · 🎯 50% │
└──────────────────────────────────────────────────────────────┘
    ^           ^            ^           ^            ^
  Total      Session      Streak     Today       Goal
  count      timer       counter     count     progress
```

**Design:**
- Fixed to bottom (never scrolls)
- Semi-transparent background (blur effect)
- Color-coded:
  - 📝 Word count: white
  - ⏱ Timer: blue (active) / gray (idle)
  - 🔥 Streak: orange (> 0) / gray (0)
  - ⚡ Today: green (progress)
  - 🎯 Goal: green (>50%) / yellow (25-50%) / red (<25%)

---

### 4. Command Palette (⌘K)
```
┌──────────────────────────────────────────┐
│ ⌘  Search or type a command...           │ ← Large search box
├──────────────────────────────────────────┤
│                                          │
│ 📝 New Note                        ⌘N    │
│ 📅 Daily Note                     ⌘⇧D   │
│ 🔍 Search Notes                    ⌘F    │
│ 🏷️  Add Tag                               │
│ 🔗 Insert Wiki Link               ⌘L    │
│ 📊 View Stats                     ⌘⇧S   │
│ 🎨 Toggle Theme                   ⌘⇧T   │
│ 🧘 Focus Mode                     ⌘⇧F   │
│ ✂️  Export to PDF                        │
│                                          │
└──────────────────────────────────────────┘
```

**Features:**
- Fuzzy search
- Keyboard navigation (↑↓ + Enter)
- Recent commands at top
- Grouped by category
- Shows keyboard shortcuts

---

## 🎬 User Flows

### Flow 1: First Launch (New User)
```
1. App opens
   ↓
2. Show welcome screen (1 second)
   "Welcome to Scribe - Let's create your first note"
   ↓
3. Auto-create "Getting Started" note with tutorial
   ↓
4. Show Focus Mode with inline hints:
   - "Type ⌘K to open command palette"
   - "Type ⌘B to toggle sidebar"
   - "Start writing!"
   ↓
5. Hints fade after 5 seconds
```

---

### Flow 2: Daily Writing Session (Existing User)
```
1. App opens
   ↓
2. Auto-open last note OR daily note (user preference)
   ↓
3. Focus mode (no sidebar)
   ↓
4. User types...
   ↓
5. Stats update in real-time (footer)
   ↓
6. Auto-save every 1 second (debounced)
   ↓
7. User types ⌘W to close
   ↓
8. App closes (no confirmation)
```

---

### Flow 3: Finding a Note (Quick Navigation)
```
1. User in editor
   ↓
2. Press ⌘K (command palette)
   ↓
3. Type note name (fuzzy search)
   ↓
4. Press Enter
   ↓
5. Note opens instantly
   ↓
6. Palette auto-closes
```

---

### Flow 4: Wiki Linking
```
1. User typing in editor
   ↓
2. Types [[ 
   ↓
3. Autocomplete popup appears (inline)
   ├─ Shows matching notes
   └─ Filters as you type
   ↓
4. User selects note (↑↓ + Enter)
   ↓
5. Link inserted: [[Note Title]]
   ↓
6. Link is clickable and underlined
   ↓
7. User clicks → opens linked note
```

---

## 🚀 Technical Implementation Plan

### Phase 1: Basic Editor (Week 1-2)
```swift
// MainView.swift - Focus Mode Only
struct MainView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSidebar = false
    
    var body: some View {
        ZStack {
            ScribeColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if showSidebar {
                    HStack(spacing: 0) {
                        SidebarView()
                            .frame(width: 200)
                        Divider()
                        EditorView()
                    }
                } else {
                    EditorView()
                }
                
                StatsFooter()
                    .frame(height: 32)
            }
        }
        .preferredColorScheme(.dark)
    }
}
```

### Phase 2: Sidebar Navigation (Week 3)
```swift
struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Scribe")
                    .font(ScribeFonts.uiTitle)
                Spacer()
                Button(action: { appState.createNewNote() }) {
                    Image(systemName: "plus")
                }
            }
            .padding()
            
            // Search
            SearchField(text: $searchText)
                .padding(.horizontal)
            
            Divider()
            
            // Project List
            List {
                ProjectSection()
                RecentSection()
                TagSection()
            }
            .listStyle(.sidebar)
        }
        .background(ScribeColors.surface)
    }
}
```

### Phase 3: Live Preview (Week 4-5)
```swift
struct EditorView: View {
    @EnvironmentObject var appState: AppState
    @State private var showPreview = false
    
    var body: some View {
        if showPreview {
            HSplitView {
                MarkdownEditor() // Source
                MarkdownPreview() // Rendered
            }
        } else {
            MarkdownEditor() // Focus mode
        }
    }
}

struct MarkdownPreview: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        WebView(html: renderMarkdown(appState.currentNote.content))
            .background(ScribeColors.background)
    }
    
    func renderMarkdown(_ markdown: String) -> String {
        // Use swift-markdown + MathJax
        // Return HTML string
    }
}
```

---

## 🎯 Success Metrics

### Quantitative
- [ ] **Launch time** < 1 second (cold start)
- [ ] **Note open time** < 100ms
- [ ] **Auto-save lag** < 50ms (imperceptible)
- [ ] **Search results** < 100ms for 10k notes
- [ ] **LaTeX render** < 200ms for complex equations

### Qualitative (User Feedback)
- [ ] "I can focus on writing without distractions"
- [ ] "The stats motivate me to write daily"
- [ ] "Keyboard shortcuts make me feel fast"
- [ ] "LaTeX rendering just works"
- [ ] "It feels native to macOS"

---

## 🎨 Mockups (ASCII Art)

### Focus Mode (Default)
```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                                                            │
│                                                            │
│         Mediating Effects of Physical Activity            │
│                                                            │
│                                                            │
│ ## Introduction                                            │
│                                                            │
│ This study examines the relationship between exercise      │
│ frequency and mental health outcomes. Previous research    │
│ suggests that β = 0.45 (p < .001).                         │
│                                                            │
│ ## Method                                                  │
│                                                            │
│ We analyzed data from N = 1,234 participants using:       │
│                                                            │
│   Y_i = β₀ + β₁X_i + ε_i   [rendered inline]              │
│                                                            │
│                                                            │
│  ┌──────────────────────────────────────────────────┐     │
│  │ 📝 847 words · ⏱ 23m · 🔥 12 days · ⚡ 234 today│     │
│  └──────────────────────────────────────────────────┘     │
└────────────────────────────────────────────────────────────┘
```

### Navigator Mode (⌘B)
```
┌────────────┬───────────────────────────────────────────────┐
│ Scribe [+] │ Mediating Effects of Physical Activity        │
├────────────┤                                               │
│ 🔍 Search  │                                               │
├────────────┤ ## Introduction                               │
│ PROJECTS   │                                               │
│            │ This study examines the relationship...       │
│ 🔬 Research│                                               │
│   • Diss   │ ## Method                                     │
│   • Paper1 │                                               │
│            │ We analyzed data from N = 1,234...            │
│ 📚 Teaching│                                               │
│   • S440   │                                               │
│   • S579   │                                               │
│            │                                               │
│ 📦 R-Pkg   │                                               │
│   • rmed   │                                               │
│            │                                               │
│ RECENT     │                                               │
│ • 2025-01  │  Stats: 847w · 23m · 🔥12 · ⚡234             │
└────────────┴───────────────────────────────────────────────┘
```

---

## 🔧 Implementation Checklist

### Week 1: Foundation
- [ ] Delete old MainView.swift
- [ ] Create new UI component structure
- [ ] Implement ScribeColors + ScribeFonts
- [ ] Build basic EditorView (TextEditor only)
- [ ] Build StatsFooter component

### Week 2: Focus Mode
- [ ] Implement auto-save (debounced)
- [ ] Add title editing (inline)
- [ ] Add stats tracking (real-time)
- [ ] Test keyboard shortcuts
- [ ] Polish animations

### Week 3: Navigation
- [ ] Build SidebarView
- [ ] Implement project filtering
- [ ] Add recent notes list
- [ ] Add tag cloud
- [ ] Add ⌘B toggle animation

### Week 4: Preview
- [ ] Integrate swift-markdown
- [ ] Add WebView for rendering
- [ ] Implement split view
- [ ] Add scroll sync
- [ ] Test with large documents

### Week 5: LaTeX
- [ ] Integrate MathJax/KaTeX
- [ ] Render inline math ($...$)
- [ ] Render block math ($$...$$)
- [ ] Add hover preview
- [ ] Cache rendered equations

### Week 6: Polish
- [ ] Add command palette (⌘K)
- [ ] Implement wiki link autocomplete
- [ ] Add first-launch tutorial
- [ ] Performance optimization
- [ ] User testing

---

## 🎨 Design Inspiration

### Apps to Study
- **Obsidian** - Wiki linking, graph view
- **Typora** - Live markdown preview
- **iA Writer** - Focus mode, distraction-free
- **Ulysses** - Sidebar organization
- **Bear** - Tag system, beautiful UI
- **Craft** - Native macOS feel

### What to Avoid
- ❌ Cluttered toolbars (Notion, Word)
- ❌ Modal dialogs (interrupts flow)
- ❌ Slow rendering (Electron apps)
- ❌ Hidden features (low discoverability)
- ❌ Over-animation (sensory overload)

---

## 💡 Future Enhancements (Post v1.0)

### v1.1 Features
- [ ] Multiple tabs (⌘T for new tab)
- [ ] Backlinks panel (shows notes linking here)
- [ ] Graph view (visual note connections)
- [ ] Export to PDF/Markdown

### v1.2 Features
- [ ] BibTeX integration (Zotero API)
- [ ] Git sync (automatic versioning)
- [ ] Collaboration (real-time editing)
- [ ] Mobile companion app (iOS)

### v2.0 Features
- [ ] Plugin system (user extensions)
- [ ] Custom themes (user-defined colors)
- [ ] Advanced LaTeX (TikZ diagrams)
- [ ] AI writing assistant (Claude API)

---

## 📚 References

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- [Swift Markdown](https://github.com/apple/swift-markdown)
- [MathJax Documentation](https://docs.mathjax.org/)
- [ADHD-Friendly Design Principles](https://adhd-friendly.com/)

---

**Next Action:** Delete old MainView.swift and start implementing Focus Mode (Week 1)
