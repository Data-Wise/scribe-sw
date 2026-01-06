# TODO - Scribe SwiftUI

Tasks and next steps for Scribe SwiftUI project.

**Updated:** 2026-01-05
**Version:** 0.3.0-cli (CLI Development)

---

## CURRENT FOCUS: CLI Phase 3 - Wiki Links ⭐

**Timeline:** Week 4 (Jan 6-12, 2026)
**Goal:** Add `[[Note Title]]` linking between notes

### Completed ✅

**CLI Phase 0 (Jan 2, 2026):**

- [x] Multi-vault infrastructure
- [x] Hybrid config system (vault.json + cli.json)
- [x] 6 vault commands (create, list, switch, context, info, delete)
- [x] Context-aware command routing
- [x] Comprehensive testing (unit + E2E)

**CLI Phase 1 (Jan 5, 2026):**

- [x] Quick capture (scribe-cli quick)
- [x] Inbox management (list, move)
- [x] Project creation with types
- [x] Enhanced project list (IDs + emojis)
- [x] 34 unit tests + 21 E2E tests
- [x] Dogfooding test

**CLI Phase 2 (Jan 5, 2026):**

- [x] Tag parsing from #hashtags
- [x] Tags commands (list, search, stats)
- [x] Enhanced search with filters (--tag, --project, --title-only)
- [x] 18 new tests (8 model + 10 commands)
- [x] E2E test (15 scenarios)
- [x] Dogfooding test (non-interactive)

**SwiftUI App (Deferred):**

- [x] WritingStats model
- [x] StatsFooter with 5 metrics
- [x] Focus Mode layout
- [x] Left/Right Sidebars
- [x] Drag-and-drop for notes
- [x] 168 tests passing
- ⚠️ **BLOCKED:** App hangs on startup (P0)

---

## Immediate (Next Week)

### Phase 3: Wiki Links (Week 4)

- [ ] Parse `[[Note Title]]` from content
- [ ] Add `links` computed property to Note model
- [ ] Create LinksCommands.swift (list, backlinks)
- [ ] Add note navigation commands
- [ ] Enhance search to find linked notes
- [ ] Create 20+ tests (model + commands + E2E)
- [ ] Dogfooding test

---

## Future Phases

### Phase 4: Metadata & Polish (Week 5)

- [ ] YAML frontmatter parsing
- [ ] Metadata commands
- [ ] Note templates
- [ ] Bulk operations
- [ ] Performance optimization

### Phase 5: Advanced Features (Future)

- [ ] Daily notes automation
- [ ] Note export (Markdown, PDF)
- [ ] Statistics dashboard
- [ ] Search improvements
- [ ] CLI polish and UX

---

## SwiftUI App (Deferred Until CLI Complete)

**Critical Blocker:** App hangs on startup
**Strategy:** Complete CLI backend first, then return to SwiftUI

**When Unblocked:**

- [ ] Debug and fix app hang
- [ ] Test drag-and-drop functionality
- [ ] Editor area polish (tabs, breadcrumbs)
- [ ] Markdown preview
- [ ] LaTeX rendering

---

## Technical Debt

- [ ] Add more error handling in CLI commands
- [ ] Improve CLI help text formatting
- [ ] Add command aliases
- [ ] Performance profiling for large vaults
- [ ] Documentation improvements

---

**See:** `ROADMAP.md` for detailed timeline and `GEMINI.md` for AI assistant context
