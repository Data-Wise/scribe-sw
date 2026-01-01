# TODO - Scribe SwiftUI

Tasks and next steps for the Scribe SwiftUI project.

**Updated:** 2026-01-01
**Version:** 0.1.0-dev (Active Rebuild)

---

## CURRENT FOCUS: Phase 2.5 - UI Polish ⭐

**Timeline:** Week 2 (Jan 1-7, 2026)
**Goal:** Professional sidebar interactions, Editor tabs, and Mission Control dashboard

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

**See:** `docs/development/REBUILD_PLAN_2026.md` for full details

---

## Immediate (This Week)

### Phase 2.5: Sidebar Polish (Days 8-10)

- [ ] Right-click context menus
  - [ ] Note context menu (Rename, Move, Delete)
  - [ ] Project context menu (New Note, Rename, Delete)
  - [ ] Sidebar background menu (New Note, New Project)
- [ ] Drag-and-drop
  - [ ] Drag note to project (move)
  - [ ] Drag note to reorder
  - [ ] Visual feedback (ghost, highlights)
- [ ] Inline editing
  - [ ] Double-click empty space → create note
  - [ ] Rename note in place
- [ ] Additional keyboard shortcuts
  - [ ] ⌘R (rename), ⌘⌫ (delete), ⌘D (duplicate)
  - [ ] ↑/↓ (navigate), ⌘↑/↓ (reorder)
- [ ] Visual polish
  - [ ] Hover states, selection highlighting
  - [ ] 150ms animations
  - [ ] Loading skeletons

### Day 3-4: Enhanced Editor

- [ ] Add markdown awareness to EditorView
  - [ ] Detect **bold**, *italic* as you type
  - [ ] Detect [[wiki links]]
  - [ ] Detect #tags
  - [ ] Visual indicators (no full rendering)
- [ ] Improve auto-save implementation
  - [ ] 1 second debounce (cancel previous tasks)
  - [ ] Visual indicator when saving
  - [ ] Update word count on every change
- [ ] Remove toolbar from MainView
  - [ ] Delete .toolbar {} block
  - [ ] Keyboard-only sidebar toggle
- [ ] Add keyboard shortcut handlers
  - [ ] ⌘B → Toggle sidebar with animation
  - [ ] ⌘N → Create new note
  - [ ] ⌘W → Close window (no save prompt)

### Day 5-7: Polish & Testing

- [ ] Add .commands {} menu items
- [ ] Test session persistence (UserDefaults)
- [ ] Test streak calculation (write 2 days, skip 1 day)
- [ ] Test auto-save (type, wait 1s, verify saved)
- [ ] Test keyboard shortcuts (all work smoothly)
- [ ] Verify stats update in real-time
- [ ] Performance check (no UI jank)

---

## Next Week (Phase 2)

### Day 8-9: Sidebar Structure

- [ ] Create `Sources/Scribe/Views/Components/Sidebar/SidebarView.swift`
- [ ] Create `Sources/Scribe/Views/Components/Sidebar/ProjectSection.swift`
- [ ] Create `Sources/Scribe/Views/Components/Sidebar/RecentSection.swift`
- [ ] Add search field to sidebar
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
