# Quick Start Guide

Get up and running with Scribe SwiftUI in 5 minutes.

---

## Prerequisites

- macOS 14+ (Sonoma or later)
- Xcode 15.2+ (for Swift 5.9+)
- Basic familiarity with terminal

---

## Installation

### 1. Verify Location

```bash
cd ~/projects/dev-tools/scribe-sw
pwd
# Should output: /Users/dt/projects/dev-tools/scribe-sw
```

### 2. Build the Project

```bash
swift build
```

**First build takes ~2-5 minutes** (downloading dependencies: GRDB, swift-markdown, KeyboardShortcuts)

### 3. Run the App

```bash
swift run
```

---

## Quick Tour

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘N | New Page |
| ⌘D | Daily Note |
| ⌘⇧C | Quick Capture |
| ⌘[ | Toggle Sidebar |
| ⌘1 | Source Mode |
| ⌘2 | Live Preview |
| ⌘3 | Reading Mode |
| ⌘E | Cycle Editor Modes |
| ⌘F | Search |
| ⌘? | Keyboard Shortcuts |

### CLI Access

```bash
# Source the CLI
source ~/projects/dev-tools/scribe-sw/cli/scribe.zsh

# Create a note
scribe new "My First Note"

# Open daily note
scribe daily

# Search
scribe search "query"
```

---

## Next Steps

- Read [development/swift-guide.md](development/swift-guide.md) for development guide
- Read [reference/database-schema.md](reference/database-schema.md) for database structure
- Check [contributing.md](contributing.md) to contribute

---

## Troubleshooting

### Build fails with "no such module 'GRDB'"

**Solution:** Clean and rebuild

```bash
rm -rf .build
swift build
```

### App crashes on launch

**Solution:** Check Xcode version

```bash
swift --version
# Should be Swift 5.9 or later
```

Upgrade Xcode if needed: App Store → Xcode

### Database not created

**Solution:** First run creates database at:

```
~/Library/Application Support/Scribe/scribe.sqlite
```

Check if directory exists:

```bash
ls -la ~/Library/Application\ Support/Scribe/
```

---

## Help

For more help, see:

- [GitHub Issues](https://github.com/Data-Wise/scribe-native/issues) (when created)
- [Main Scribe Repo](https://github.com/Data-Wise/scribe)
