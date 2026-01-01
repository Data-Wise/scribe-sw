# Scribe SwiftUI - Development Roadmap

**Vision:** ADHD-friendly distraction-free writing app (Obsidian + Overleaf for macOS)
**Target Users:** Statistics professors & researchers
**Platform:** macOS 14+ (SwiftUI native)
**Last Updated:** January 1, 2026

---

## Phase 1: Enhanced Focus Mode (Week 1 - Jan 1-7, 2026) ✅

### Goal

Working distraction-free editor with live 5-metric stats and auto-save

### Timeline

**Start:** January 1, 2026  
**End:** January 7, 2026  
**Duration:** 1 week  
**Status:** ✅ Complete

### Completed Tasks

- [x] WritingStats model (session, streak, goals)
- [x] Stats tracking in AppState
- [x] StatsFooter with 5 metrics (word, timer, streak, today, goal)
- [x] Keyboard shortcuts (⌘N, ⌘[, ⌘])
- [x] Error dialog with auto-dismiss
- [x] Session persistence (UserDefaults)
- [x] 114 tests passing

### Success Criteria

- ✅ App opens to clean editor
- ✅ Stats footer shows all 5 metrics (updating in real-time)
- ✅ Auto-save works seamlessly
- ✅ Keyboard shortcuts work
- ✅ Stats persist across launches

### Metrics

**Complexity:** Medium  
**Risk:** Low  
**Confidence:** 95%

---

## Phase 2: Navigator Mode (Week 2 - Jan 8-14, 2026) ✅

### Goal

Sidebar with project organization, note selection, seamless navigation

### Timeline

**Start:** January 1, 2026  
**End:** January 7, 2026  
**Duration:** 1 week  
**Status:** ✅ Complete

### Completed Tasks

- [x] SidebarView component
- [x] ProjectSection with collapsible projects
- [x] NoteRow with selection state
- [x] RightSidebarView with tabs (Properties, Outline, Backlinks)
- [x] Project filtering (selectedProjectId)
- [x] Note selection (loads in editor)
- [x] Sidebar animations (150ms ease-in-out)
- [x] 122 tests passing

### Success Criteria

- ✅ Sidebar has projects + notes
- ✅ Projects show icons based on type
- ✅ Click project → Filters notes
- ✅ Click note → Loads in editor
- ✅ Sidebar toggles smoothly (⌘[, ⌘])
- ✅ Right sidebar shows properties, outline, backlinks

### Metrics

**Complexity:** Medium  
**Risk:** Low  
**Confidence:** 90%

---

## Phase 2.5: UI Polish (Week 2 - Jan 8-10, 2026) 🚧

### Goal

Professional interactions (context menus, drag-drop) and Editor enhancements (tabs, breadcrumbs)

### Timeline

**Start:** January 8, 2026  
**End:** January 10, 2026  
**Duration:** 3 days  
**Status:** 🚧 Planned

### Tasks

**Day 1: Context Menus & Sidebar**

- [ ] Right-click context menus for Notes, Projects, and Background
- [ ] Drag-and-drop handling for moving and reordering
- [ ] Inline note creation and renaming
- [ ] Wire menu actions to AppState

**Day 2: Editor Tabs & Header**

- [ ] Implement Gradient Tab Bar
- [ ] Add Pinned Mission Control tab as home base
- [ ] Add Breadcrumbs navigation bar
- [ ] Move Session timer/stats to top-bar integration
- [ ] Keyboard shortcuts for tab switching (⌘1-9)

**Day 3: Markdown & Visual Polish**

- [ ] Basic Markdown syntax highlighting (Bold, Italic, Links)
- [ ] Visual design alignment (Inter/SF Pro, spacing)
- [ ] Hover states, selection polish, and smooth 150ms animations
- [ ] Loading skeletons for async operations

### Success Criteria

- ✅ Right-click note shows comprehensive context menu
- ✅ Drag-and-drop moves notes between projects seamlessly
- ✅ Editor features functional tabs with gradient accents
- ✅ Breadcrumbs show current file location
- ✅ Basic markdown characters are highlighted in editor
- ✅ All new keyboard shortcuts (⌘R, ⌘⌫, ⌘D, ⌘1-9) work

### Metrics

**Complexity:** Medium  
**Risk:** Low  
**Confidence:** 85%

---

## Phase 3: Markdown Preview (Week 3-4 - OPTIONAL) 🔮

### Goal

Split view with live markdown rendering

### Status

**Deferred** until Phases 1-2 complete

### Tasks

- [ ] Create PreviewPane component (WebView)
- [ ] Integrate swift-markdown (markdown → HTML)
- [ ] Add ⌘P toggle for split view
- [ ] Scroll sync between source/preview
- [ ] Custom CSS for rendered output

### Timeline

**Duration:** 5-7 days  
**Complexity:** Medium-High  
**Risk:** Medium (WebView integration)  
**Confidence:** 80%

---

## Phase 4: LaTeX Rendering (Week 5+ - DEFERRED) 🔮

### Goal

Live LaTeX equation rendering in preview pane

### Status

**Deferred** per user decision (after core features work)

### Tasks

- [ ] Integrate MathJax in WebView
- [ ] Detect `$...$` and `$$...$$` syntax
- [ ] Render inline math
- [ ] Render display math blocks
- [ ] Equation caching for performance

### Timeline

**Duration:** 7-10 days  
**Complexity:** High  
**Risk:** High (complex integration)  
**Confidence:** 70%

---

## Future Enhancements (v1.1+) 💡

### v1.1 Features (Post-Launch Polish)

- [ ] Backlinks panel (see note connections)
- [ ] Graph view (visual note network)
- [ ] Export (PDF, Markdown, HTML)
- [ ] Multiple tabs (⌘T for new tab)
- [ ] Note templates
- [ ] Quick capture window (global hotkey)

### v1.2 Features (Advanced Integration)

- [ ] BibTeX integration (Zotero API)
- [ ] Git sync (automatic versioning)
- [ ] Diagram support (Mermaid, TikZ)
- [ ] Command palette (⌘K)
- [ ] Tag management system
- [ ] Daily note automation

### v2.0 Features (Extensibility)

- [ ] Plugin system (user extensions)
- [ ] Custom themes (user-defined colors)
- [ ] AI writing assistant (Claude API)
- [ ] Collaborative editing (real-time)
- [ ] Mobile companion app (iOS)
- [ ] Cloud sync (iCloud/Dropbox)
- [ ] Advanced LaTeX (TikZ diagrams, custom macros)

---

## Success Metrics

### Quantitative Goals

| Metric | Target | Current |
|--------|--------|---------|
| Launch time | < 1 second (cold start) | TBD |
| Note open time | < 100ms | TBD |
| Auto-save lag | < 50ms (imperceptible) | TBD |
| Search results | < 100ms for 10k notes | TBD |
| LaTeX render | < 200ms for complex equations | N/A |

### Qualitative Goals (User Feedback)

- "I can focus on writing without distractions"
- "The stats motivate me to write daily"
- "Keyboard shortcuts make me feel fast"
- "LaTeX rendering just works"
- "It feels native to macOS"

---

## Technical Debt & Maintenance

### Testing

- [ ] Re-enable test target (migrate to XCTest)
- [ ] Add UI tests (XCTest UI)
- [ ] Add integration tests
- [ ] Target: 80%+ coverage

### Documentation

- [ ] User guide (getting started)
- [ ] Keyboard shortcuts reference
- [ ] Markdown syntax guide
- [ ] API documentation
- [ ] Video tutorials

### Distribution

- [ ] Create .app bundle
- [ ] Add to Homebrew tap (brew install scribe)
- [ ] GitHub release workflow
- [ ] Version bump automation
- [ ] Update notifications

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Scope creep | High | Medium | Stick to phases, defer features |
| SwiftUI bugs | Medium | Low | Test on multiple macOS versions |
| Performance issues | Medium | Low | Profile early, optimize incrementally |
| LaTeX complexity | High | Medium | Start simple, iterate gradually |
| User adoption | Medium | Medium | Focus on ADHD-friendly UX |

---

## Timeline Summary

| Phase | Duration | Start | End | Status |
|-------|----------|-------|-----|--------|
| **Phase 1: Focus Mode** | 1 week | Jan 1 | Jan 7 | ✅ Complete |
| **Phase 2: Navigator** | 1 week | Jan 1 | Jan 7 | ✅ Complete |
| **Phase 2.5: Sidebar Polish** | 3 days | Jan 8 | Jan 10 | 🚧 In Progress |
| **Phase 3: Preview** | 1 week | TBD | TBD | 🔮 Deferred |
| **Phase 4: LaTeX** | 2 weeks | TBD | TBD | 🔮 Deferred |

**Total Committed:** 2 weeks (Phases 1-2)  
**Total Vision:** 8-10 weeks (all phases)

---

## Resources

### Documentation

- **Product Requirements:** `docs/PRODUCT_REQUIREMENTS.md`
- **UI Design:** `docs/UI_REDESIGN_BRAINSTORM.md`
- **Architecture:** `docs/development/ARCHITECTURE.md`
- **Implementation Plan:** `docs/development/REBUILD_PLAN_2026.md`
- **Database Schema:** `docs/reference/database-schema.md`

### Dependencies

- **GRDB.swift** - SQLite wrapper ([GitHub](https://github.com/groue/GRDB.swift))
- **swift-markdown** - Markdown parsing ([GitHub](https://github.com/apple/swift-markdown))
- **KeyboardShortcuts** - Global hotkeys ([GitHub](https://github.com/sindresorhus/KeyboardShortcuts))

### External References

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [GRDB Documentation](https://github.com/groue/GRDB.swift)
- [Swift Markdown](https://github.com/apple/swift-markdown)
- [ADHD-Friendly Design](https://adhd-friendly.com/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)

---

## Progress Tracking

### Completed Milestones

- ✅ Backend architecture (DatabaseManager, Services, Models)
- ✅ Design system (colors, fonts, spacing)
- ✅ Phase 1: Enhanced Focus Mode (WritingStats, StatsFooter, keyboard shortcuts)
- ✅ Phase 2: Navigator Mode (Left/Right sidebars, note selection)
- ✅ 122 tests passing

### In Progress

- 🚧 Phase 2.5: Sidebar Polish (context menus, drag-drop)

### Upcoming

- 📅 Phase 3: Markdown Preview (split view)
- 🔮 Phase 4: LaTeX Rendering (MathJax)

---

**Last Updated:** January 1, 2026  
**Next Review:** January 7, 2026 (end of Phase 1)
