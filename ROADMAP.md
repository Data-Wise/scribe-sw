# Scribe SwiftUI - Development Roadmap

**Vision:** ADHD-friendly distraction-free writing app (Obsidian + Overleaf for macOS)
**Target Users:** Statistics professors & researchers
**Platform:** macOS 14+ (SwiftUI native)
**Last Updated:** January 1, 2026

---

## Phase 1: Enhanced Focus Mode (Week 1 - Jan 1-7, 2026) 🚧

### Goal
Working distraction-free editor with live 5-metric stats and auto-save

### Timeline
**Start:** January 1, 2026  
**End:** January 7, 2026  
**Duration:** 1 week (5-7 days)  
**Status:** 🚧 In Progress

### Tasks

**Day 1-2: Stats Foundation**
- [ ] Create WritingStats model (session, streak, goals)
- [ ] Add stats tracking to AppState
- [ ] Rebuild StatsFooter with 5 metrics
  - 📝 Current note word count
  - ⏱ Session timer (live updating)
  - 🔥 Streak counter (consecutive days)
  - ⚡ Today's word count
  - 🎯 Daily goal progress bar

**Day 3-4: Enhanced Editor**
- [ ] Add markdown awareness (highlight **bold**, *italic*, [[links]], #tags)
- [ ] Improve auto-save (1s debounce, visual indicator)
- [ ] Remove toolbar chrome (zero UI, keyboard-only)
- [ ] Word count calculation on every change

**Day 5-7: Polish & Shortcuts**
- [ ] Implement keyboard shortcuts (⌘B, ⌘N, ⌘W)
- [ ] Session persistence (UserDefaults)
- [ ] Streak calculation logic
- [ ] Testing & refinement

### Success Criteria
- ✅ App opens to clean editor (no toolbar)
- ✅ Stats footer shows all 5 metrics (updating in real-time)
- ✅ Auto-save works seamlessly (1s debounce)
- ✅ Keyboard shortcuts work (⌘B toggles, ⌘N creates, ⌘W closes)
- ✅ Stats persist across launches
- ✅ Streak calculates correctly

### Metrics
**Complexity:** Medium  
**Risk:** Low (building on solid backend)  
**Confidence:** 95%

---

## Phase 2: Navigator Mode (Week 2 - Jan 8-14, 2026) 📅

### Goal
Sidebar with project organization, recent notes, seamless navigation

### Timeline
**Start:** January 8, 2026  
**End:** January 14, 2026  
**Duration:** 1 week (5-7 days)  
**Status:** 📅 Planned

### Tasks

**Day 1-2: Sidebar Structure**
- [ ] Create SidebarView component
- [ ] Create ProjectSection (icons per ProjectType)
- [ ] Create RecentSection (last 10 notes)
- [ ] Add search field (instant filter)

**Day 3-4: Navigation Logic**
- [ ] Project filtering (selectedProjectId in AppState)
- [ ] Note selection (loads in editor)
- [ ] Search implementation (title + content filter)
- [ ] Wire up all interactions

**Day 5-7: Animations & Polish**
- [ ] Smooth sidebar toggle animation (0.2s easing)
- [ ] Auto-hide on editor click
- [ ] Hover states on sidebar items
- [ ] Selected note highlighting
- [ ] Visual polish (icons, colors, dividers)

### Success Criteria
- ✅ Sidebar has PROJECTS + RECENT sections
- ✅ Projects show icons (🔬 📚 📦) based on type
- ✅ Click project → Filters notes
- ✅ Click note → Loads in editor
- ✅ Search filters notes instantly
- ✅ Sidebar toggles smoothly (⌘B)
- ✅ Auto-hides when editing

### Metrics
**Complexity:** Medium  
**Risk:** Low (straightforward SwiftUI)  
**Confidence:** 90%

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
| **Phase 1: Focus Mode** | 1 week | Jan 1 | Jan 7 | 🚧 In Progress |
| **Phase 2: Navigator** | 1 week | Jan 8 | Jan 14 | 📅 Planned |
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
- ✅ Basic UI structure (MainView, EditorView, StatsFooter)
- ✅ Documentation suite (.STATUS, ROADMAP, CLAUDE, TODO)

### In Progress
- 🚧 Phase 1: Enhanced Focus Mode (Week 1)

### Upcoming
- 📅 Phase 2: Navigator Mode (Week 2)

---

**Last Updated:** January 1, 2026  
**Next Review:** January 7, 2026 (end of Phase 1)
