# TODO - Scribe SwiftUI

Tasks and next steps for Scribe SwiftUI project.

**Updated:** 2026-01-01
**Version:** 0.1.0-dev (Active Rebuild)

---

## CURRENT FOCUS: Phase 3 - Comprehensive Testing Complete ⭐

**Timeline:** Week 1 (Jan 1, 2026)
**Goal:** Enhanced test coverage with edge cases, E2E workflows, and data integrity tests

### Completed ✅

**Phase 1 (Week 1):**

- [x] WritingStats model
- [x] StatsFooter with 5 metrics
- [x] Focus Mode layout
- [x] Keyboard shortcuts (⌘N, ⌘[, ⌘])
- [x] Error dialog with auto-dismiss
- [x] Session persistence
- [x] 114 tests passing

**Phase 2 (Week 1):**

- [x] Left Sidebar (SidebarView, ProjectSection, NoteRow)
- [x] Right Sidebar (Properties, Outline, Backlinks)
- [x] Note selection from sidebar
- [x] Project filtering
- [x] Sidebar tests (122 total tests)

**Phase 3 (Session 1 - Today):**

- [x] Test suite enhanced from 121 to 168 tests (+39%)
- [x] EdgeCaseTests.swift (47 new tests)
  - Database persistence and empty operations
  - Unicode support (Chinese, Spanish, French, emoji, math symbols)
  - Very long content (10,000 words)
  - Project type validation (all 5 types)
  - Search edge cases (Unicode, case-insensitive)
  - Writing stats edge cases (rapid changes, long sessions, daily resets)
  - Error handling (all error types)
  - Concurrent operations (simultaneous note creation)
  - Data integrity (ID uniqueness)
- [x] Enhanced WritingStatsTests (streak edge cases)
- [x] Enhanced NoteModelTests (word count, timestamps, soft delete, Codable)
- [x] Enhanced ProjectModelTests (computed properties, type properties)
- [x] Enhanced E2EWorkflowTests (multi-note, wiki links, full-day workflows)
- [x] Fixed AppStateTests (removed deprecated sessionTimerTick)
- [x] Fixed timer focus issue (moved to local @State in StatsFooter)
- [x] Fixed Resources reference in Package.swift
- [x] Xcode project properly configured (both targets visible)
- [x] Bundle identifier configured (com.datawise.Scribe)
- [x] Build: Clean (0 errors, 0 warnings)
- [x] All 168 tests passing (14.2s)

**Critical Fixes:**

- [x] Timer no longer steals keyboard focus
- [x] App typing works correctly
- [x] Session timer updates live without UI disruption
- [x] Xcode project includes both Scribe and ScribeTests targets

**See:** `docs/development/REBUILD_PLAN_2026.md` and `TEST_COVERAGE_SUMMARY.md` for full details

---

## Immediate (Next Week)

### Phase 4: Advanced Features (Future)

- [ ] Left Sidebar enhancements (menus, drag-drop, inline edit)
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
