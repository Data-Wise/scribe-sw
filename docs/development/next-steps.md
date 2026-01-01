# Next Steps

**Status:** Folder structure created, documentation complete
**Last Updated:** 2025-12-31

---

## Current Status

✅ **Phase 1: Folder Setup - COMPLETE**

- [x] Directory structure created
- [x] Essential documentation written
  - [x] README.md
  - [x] QUICKSTART.md
  - [x] PROJECT-OVERVIEW.md
  - [x] DATABASE-SCHEMA.md
  - [x] SWIFT-DEVELOPMENT.md
  - [x] LICENSE
  - [x] CONTRIBUTING.md
  - [x] .gitignore
  - [x] NEXT-STEPS.md (this file)

**Location:** `~/projects/dev-tools/scribe-sw/`

---

## Phase 2: Copy Existing Code

### From Worktree (`~/.git-worktrees/scribe/swiftui-native/`)

1. **Copy Swift Package**

```bash
cd ~/projects/dev-tools/scribe-sw
cp ~/.git-worktrees/scribe/swiftui-native/Scribe/Package.{swift,resolved} Scribe/
cp -R ~/.git-worktrees/scribe/swiftui-native/Scribe/Sources/Scribe Scribe/Sources/
cp -R ~/.git-worktrees/scribe/swiftui-native/Scribe/Tests/ScribeTests Scribe/Tests/
```

**Expected:** 13 Swift files, Package.swift with GRDB/swift-markdown/KeyboardShortcuts

2. **Copy CLI Tools**

```bash
cp -R ~/.git-worktrees/scribe/swiftui-native/cli/ .
```

**Expected:** scribe.zsh, install.sh, README.md

3. **Copy Additional Docs** (optional)

```bash
# Copy planning/reference docs
cp -R ~/.git-worktrees/scribe/swiftui-native/docs/{planning,reference} docs/
```

---

## Phase 3: Initialize Git

```bash
cd ~/projects/dev-tools/scribe-sw

git init
git add .
git commit -m "Initial commit: Scribe SwiftUI Native

Standalone SwiftUI project for macOS.

Features:
- SwiftUI app (13 Swift files)
- GRDB database
- CLI tools
- Comprehensive documentation

Stack: SwiftUI + GRDB + swift-markdown + KeyboardShortcuts"
```

---

## Phase 4: Create GitHub Repository

```bash
# Create repo (requires gh CLI)
gh repo create Data-Wise/scribe-native \
  --public \
  --source=. \
  --description="ADHD-friendly distraction-free writer (SwiftUI Native)" \
  --remote=origin

# Push
git push -u origin main

# Add topics
gh repo edit Data-Wise/scribe-native \
  --add-topic swift \
  --add-topic swiftui \
  --add-topic macos \
  --add-topic adhd \
  --add-topic writing
```

---

## Phase 5: Verify Build

```bash
cd ~/projects/dev-tools/scribe-sw/Scribe

# Clean build
rm -rf .build
swift build

# Run tests
swift test

# Should succeed and download dependencies
```

---

## Phase 6: Development (Future)

### Immediate Tasks

1. **Implement Core Views**
   - VaultSidebar (project navigation)
   - PageEditor (markdown editing)
   - MissionControlView (dashboard)

2. **Database Integration**
   - Implement DatabaseService methods
   - Add GRDB migrations
   - Test CRUD operations

3. **State Management**
   - Wire up AppState to views
   - Add @Published properties
   - Connect keyboard shortcuts

### Medium-Term Tasks

1. **Native Features**
   - Menu bar extra
   - Global keyboard shortcuts (⌘⇧C, ⌘⇧D)
   - Quick capture window

2. **Markdown Features**
   - Syntax highlighting
   - Live preview mode
   - Wiki link autocomplete

3. **Search**
   - FTS5 full-text search
   - Scope filtering (All/Project)
   - Keyboard navigation

### Long-Term Tasks

1. **Advanced Features**
   - Spotlight indexing
   - Widgets
   - Share extensions
   - AI integration (CLI-based)

2. **Polish**
   - Themes
   - Animations
   - Accessibility
   - Performance optimization

---

## Documentation TODO

### Still Needed

- [ ] API.md (internal API reference)
- [ ] ARCHITECTURE.md (system design)
- [ ] TESTING.md (testing guide)
- [ ] DEPLOYMENT.md (build/release process)

### Can Copy Later

From worktree:
- docs/planning/ (sprint plans)
- docs/guide/ (user guides)
- docs/reference/ (technical reference)

---

## Resources

### For Next Steps

- **SWIFT-DEVELOPMENT.md** - Learn Swift/SwiftUI basics
- **DATABASE-SCHEMA.md** - Database structure reference
- **Implementation Plan** - `~/.claude/plans/hazy-zooming-key.md`

### External

- [GRDB Documentation](https://github.com/groue/GRDB.swift)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Swift Book](https://docs.swift.org/swift-book/)

---

## Questions?

- See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- Check [PROJECT-OVERVIEW.md](PROJECT-OVERVIEW.md) for project context
- Read [QUICKSTART.md](QUICKSTART.md) for quick setup

---

## Notes

- **Database Compatibility:** Schema matches Tauri version for potential sync
- **Orphan Branch:** No git history connection to main scribe repo
- **Native Focus:** Prioritize macOS-specific features
- **ADHD Principles:** All decisions filter through these first

---

**Ready to proceed with Phase 2!**

See full implementation plan: `~/.claude/plans/hazy-zooming-key.md`
