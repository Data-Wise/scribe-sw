# TODO - Scribe SwiftUI

Tasks and next steps for Scribe SwiftUI project.

**Updated:** 2026-01-01
**Version:** 0.1.0-dev (Active Rebuild)

---

## CURRENT FOCUS: Phase 2.5 - Drag-and-Drop Complete ⭐

**Timeline:** Week 2 (Jan 8-10, 2026)
**Goal:** Professional sidebar interactions and drag-and-drop for notes

### Completed ✅

**Phase 1 (Week 1):**

- [x] WritingStats model
- [x] StatsFooter with 5 metrics
- [x] Focus Mode layout
- [x] Keyboard shortcuts (⌘N, ⌘[, ⌘])
- [x] Error dialog with auto-dismiss
- [x] Session persistence
- [x] 114 tests passing

**Phase 2 (Week 1-2):**

- [x] Left Sidebar (SidebarView, ProjectSection, NoteRow)
- [x] Right Sidebar (Properties, Outline, Backlinks)
- [x] Note selection from sidebar
- [x] Project filtering
- [x] Sidebar animations (150ms ease-in-out)
- [x] 122 tests passing

**Phase 2.5 (Week 2):**

- [x] Editor area polish (markdown-aware, improved title handling)
- [x] Sidebar enhancements (context menus, drag-drop, inline editing)
- [x] **Drag-and-drop for notes** (Session 2, Jan 1, 2026)
  - [x] Add .onDrag to NoteRow for drag functionality
  - [x] Add .onDrop to ProjectSection for drop targets
  - [x] Add .onDrop to UncategorizedSection
  - [x] Add moveNote method to AppState (async, uses NoteService)
  - [x] Visual feedback: drop targets highlight with accent color
  - [x] Skip moves if note already in target project
  - [x] Support moving notes to/from Uncategorized section
  - [x] All 141 tests passing

**Phase 3 (Session 1):**

- [x] Test suite enhanced from 121 to 168 tests (+39%)
- [x] EdgeCaseTests.swift (47 new tests)
- [x] Enhanced WritingStatsTests (streak edge cases)
- [x] Enhanced NoteModelTests (word count, timestamps, soft delete, Codable)
- [x] Enhanced ProjectModelTests (computed properties, type properties)
- [x] Enhanced E2EWorkflowTests (multi-note, wiki links, full-day workflows)
- [x] Fixed AppStateTests (removed deprecated sessionTimerTick)
- [x] Fixed timer focus issue (moved to local @State in StatsFooter)
- [x] Fixed Resources reference in Package.swift
- [x] Xcode project properly configured (both targets visible)
- [x] Bundle identifier configured (com.datawise.Scribe)
- [x] Created TEST_COVERAGE_SUMMARY.md
- [x] All 168 tests passing (0 failures)
- [x] Build: Clean (0 errors, 0 warnings, ~14s)
- [x] NoteRow simplified (removed complex context menu for cleaner implementation)

**Critical Fixes:**

- [x] Timer no longer steals keyboard focus
- [x] App typing works correctly
- [x] Session timer updates live without UI disruption

**See:** `docs/development/REBUILD_PLAN_2026.md` and `TEST_COVERAGE_SUMMARY.md` for full details

---

## Immediate (Next Week)

### Phase 4: Advanced Features (Future)

- [x] Left Sidebar enhancements (drag-drop) ✅ COMPLETE
- [ ] **Editor Area Polish**
  - [ ] Implement Tab Bar with gradient accent
  - [ ] Add Pinned Mission Control tab (⌘1)
  - [ ] Add Breadcrumbs (Project > Title)
  - [ ] Implement basic markdown syntax highlighting
  - [ ] Move session timer to top bar/header
- [ ] Additional keyboard shortcuts (⌘R, ⌘⌫, ⌘D, ⌘1-9)
- [ ] Visual polish (Inter font, animations, skeletons)

---

## Future Phases

### Phase 3: Markdown Preview

- [ ] Create PreviewPane component (WebView)
- [ ] Integrate swift-markdown
- [ ] Add ⌘P toggle for split view

### Phase 4: LaTeX Rendering

- [ ] Integrate MathJax in WebView
- [ ] Detect `$` and `$$` syntax
- [ ] Render math blocks
- [ ] Wire up to MainView

### Day 10-11: Navigation Logic

- [ ] Add selectedProjectId to AppState
- [ ] Add filteredNotes computed property
- [ ] Implement project filtering (click project → filter)
- [ ] Implement note selection (click note → load editor)
- [ ] Implement search (instant filter by title/content)

### Day 12-14: Animations & Polish

- [ ] Smooth sidebar toggle (0.2s easeInOut)
- [ ] Auto-hide sidebar on editor click
- [ ] Hover states on sidebar items
- [ ] Selected note highlighting
- [ ] Project icons (🔬 📚 📦 based on ProjectType)
- [ ] Visual polish pass

---

## Future Phases (Deferred)

### Phase 3: Markdown Preview (Week 3-4)

- [ ] Create PreviewPane component
- [ ] Integrate swift-markdown (markdown → HTML)
- [ ] Add WebView for rendering
- [ ] Add ⌘P toggle for split view
- [ ] Implement scroll sync
- [ ] Custom CSS for preview styling

### Phase 4: LaTeX Rendering (Week 5+)

- [ ] Integrate MathJax in WebView
- [ ] Detect $...$ and $$...$$ syntax
- [ ] Render inline math
- [ ] Render display math blocks
- [ ] Equation caching for performance
- [ ] Error handling for invalid LaTeX

---

## Technical Debt

### Testing

- [ ] Re-enable test target (migrate Swift Testing → XCTest)
- [ ] Add unit tests for WritingStats
- [ ] Add unit tests for streak calculation
- [ ] Add UI tests (XCTest UI)
- [ ] Target: 80%+ coverage

### Documentation

- [ ] Add inline code comments
- [ ] Document WritingStats model
- [ ] Document stats calculation logic
- [ ] User guide (getting started)
- [ ] Keyboard shortcuts reference card

### Performance

- [ ] Profile app launch time (target < 1s)
- [ ] Profile note open time (target < 100ms)
- [ ] Profile auto-save (target < 50ms lag)
- [ ] Optimize large note lists (pagination)

---

## Distribution (v1.0+)

- [ ] Create .app bundle
- [ ] Add app icon
- [ ] Create Info.plist
- [ ] Add to Homebrew tap
- [ ] Create GitHub release workflow
- [ ] Automated version bumping
- [ ] Release notes generation

---

## Documentation Cleanup

- [x] ✅ Delete 6 outdated planning docs
- [x] ✅ Create .STATUS file
- [x] ✅ Create ROADMAP.md
- [x] ✅ Create CLAUDE.md
- [ ] Create TODO.md (this file)
- [ ] Update CURRENT_STATUS.md
- [ ] Create docs/development/REBUILD_PLAN_2026.md

---

## Community (Post-Release)

- [ ] GitHub repository (public)
- [ ] Issue templates
- [ ] PR template
- [ ] Contributing guide
- [ ] Code of conduct

---

## Long-term Ideas (v2.0+)

See `docs/PRODUCT_REQUIREMENTS.md` for full vision:

- Plugin system (user extensions)
- Custom themes (user colors/fonts)
- AI writing assistant (Claude API integration)
- Collaborative editing (real-time)
- Mobile companion app (iOS)
- Cloud sync (iCloud/Dropbox)
- Advanced LaTeX (TikZ diagrams)

---

**Next Action:** Execute Phase 1, Day 1 tasks (create WritingStats model)
