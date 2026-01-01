# Implementation Plan - Next Phase

**Date:** 2025-12-31  
**Status:** ✅ Planning Complete - Implementation in Progress

---

## Completed Tasks

### ✅ Phase 1: Foundation (100% Complete)
- [x] All model/design review recommendations
- [x] 71 unit tests created
- [x] Dependency injection implemented
- [x] Performance optimizations (word_count, pagination, debouncing)
- [x] Missing models (Link, Tag, Citation)
- [x] Writing stats with daily diffs
- [x] Structured logging (ScribeLog)
- [x] New UI components (ProjectCardEnhanced)

### ✅ Phase 2: Hybrid Editor (In Progress)
- [x] HybridEditorView created with split pane
- [ ] Improved TextKit editor with markdown support
- [ ] Enhanced WebKit preview with MathJax
- [ ] Debounced sync between editor and preview

---

## Current Implementation Status

### Files Created This Session

**New Components:**
1. `Sources/Scribe/Views/ProjectCardEnhanced.swift` - 180 lines
2. `Sources/Scribe/Views/HybridEditorView.swift` - 161 lines

**Total New Code:** ~340 lines  
**Build Status:** ✅ **SUCCESS** (3.10s)

---

## Next Priority Tasks

### 1. Enhanced TextKit Editor (2-3h)
- [ ] Proper markdown syntax highlighting
- [ ] Auto-indentation
- [ ] Tab/shift-tab for indent/unindent
- [ ] Smart quotes and dashes
- [ ] Code block detection
- [ ] Emoji picker integration

### 2. Improved WebKit Preview (2-3h)
- [ ] Use swift-markdown for proper rendering
- [ ] MathJax for LaTeX equations
- [ ] Code syntax highlighting in preview
- [ ] Image preview from local paths
- [ ] Dark mode support in preview
- [ ] Responsive preview (scroll sync)

### 3. Editor-Preview Sync (1-2h)
- [ ] Debounced preview updates (500ms)
- [ ] Scroll position sync
- [ ] Preserve cursor in preview
- [ ] Handle large documents efficiently

### 4. Focus Mode Enhancement (1-2h)
- [ ] Hide sidebar on start typing
- [ ] Show sidebar when focus mode deactivated
- [ ] Optional distraction-free indicators
- [ ] Timer/word count emphasis

### 5. Editor Tabs (2-3h)
- [ ] Tab bar in editor
- [ ] Tab context menu (close, close all, move)
- [ ] Tab limit (max 5 tabs)
- [ ] Unsaved changes indicator

### 6. Wiki Link Autocomplete (3-4h)
- [ ] Detect `[[` pattern
- [ ] Show completion popup
- [ ] Filter by matching notes
- [ ] Tab/arrow navigation
- [ ] Create new note from autocomplete

### 7. Citation Management (2-3h)
- [ ] `@cite` syntax highlighting
- [ ] Citation autocomplete from .bib file
- [ ] Insert formatted citations (APA, Chicago)
- [ ] Bibliography generation

---

## Implementation Order

### Sprint 1: Editor Polish (8-10h total)

**Task 1:** Enhanced TextKit Editor
- Add markdown syntax highlighting
- Implement auto-indentation
- Add keyboard shortcuts for formatting
- Estimated: 2-3h

**Task 2:** Improved Preview
- Use swift-markdown library
- Add MathJax for LaTeX
- Dark mode in preview
- Estimated: 2-3h

**Task 3:** Sync & Performance
- Debounced updates
- Scroll sync
- Estimated: 1-2h

### Sprint 2: Navigation (6-8h total)

**Task 4:** Editor Tabs
- Tab bar
- Context menu
- Tab limits
- Estimated: 2-3h

**Task 5:** Focus Mode
- Auto-hide sidebar
- Distraction indicators
- Estimated: 1-2h

### Sprint 3: Advanced Features (8-10h total)

**Task 6:** Wiki Links
- Autocomplete
- Link creation
- Estimated: 3-4h

**Task 7:** Citations
- `@cite` syntax
- Bibliography
- Estimated: 2-3h

---

## Testing Strategy

### Unit Tests Needed

```swift
// TextKitEditorTests
@Test("Markdown bold formatting")
func testBoldFormatting() { }

@Test("Auto-indentation on newline")
func testAutoIndent() { }

// PreviewTests
@Test("MathJax renders correctly")
func testMathJaxRendering() { }

@Test("Dark mode in preview")
func testDarkModePreview() { }

// SyncTests
@Test("Preview updates on debounce")
func testPreviewDebounce() { }
```

### Integration Tests Needed

```swift
// EditorWorkflowTests
@Test("Create note, type, save")
func testCreateTypeSave() async throws { }

@Test("Focus mode hides sidebar")
func testFocusModeBehavior() async throws { }

@Test("Wiki link autocomplete")
func testWikiLinkAutocomplete() async throws { }
```

---

## Integration Steps

### Step 1: Update ContentView
```swift
// Replace NoteEditorView with HybridEditorView
NoteEditorView(note: currentNote)
// →
HybridEditorView()
```

### Step 2: Update VaultSidebar
```swift
// Use ProjectCardEnhanced
ForEach(appState.projects) { project in
    ProjectCardEnhanced(project: project)
}
```

### Step 3: Add Settings for Editor
- Tab limit setting
- Focus mode behavior
- Sync debounce time

---

## Performance Targets

| Metric | Target | Status |
|--------|--------|--------|
| Editor responsiveness | <16ms | Not tested |
| Preview render time | <200ms | Not tested |
| Sync latency | <500ms | Debounced |
| Large file handling | 100KB+ | Not tested |

---

## Dependencies Needed

```swift
// Add to Package.swift if not present
.package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
```

---

## Success Criteria

### Sprint 1 Complete When:
- [ ] Editor has syntax highlighting
- [ ] Preview uses swift-markdown
- [ ] MathJax renders equations
- [ ] Sync works smoothly
- [ ] All tests pass

### Sprint 2 Complete When:
- [ ] Tabs work correctly
- [ ] Focus mode hides sidebar
- [ ] Context menu works
- [ ] All tests pass

### Sprint 3 Complete When:
- [ ] Wiki link autocomplete works
- [ ] Citations insert correctly
- [ ] Bibliography generates
- [ ] All tests pass

---

## Known Issues to Address

1. **TextKit Selection API** - Need proper NSViewRepresentable wrapper
2. **MathJax Performance** - Cache rendered equations
3. **Preview Scroll Sync** - Complex, needs proper anchor tracking
4. **Large Documents** - May need chunking for preview
5. **Memory Usage** - WebView can consume memory, consider recycling

---

## Next Immediate Action

**Start with Task 1:** Enhanced TextKit Editor

Implementation steps:
1. Create `TextKitEditor.swift` NSViewRepresentable
2. Add syntax highlighting using NSTextStorage
3. Implement auto-indentation logic
4. Add keyboard shortcuts (Cmd+B, Cmd+I, etc.)

Estimated time: 2-3 hours

---

**Ready to proceed?** ✅ YES
