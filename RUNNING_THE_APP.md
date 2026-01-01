# Running Scribe - Quick Start Guide

**Last Updated:** 2025-01-01  
**Status:** ✅ UI Complete, Ready to Run in Xcode

---

## 🚀 How to Run the App

### Method 1: Using Xcode (Recommended)

1. **Open the project:**
   ```bash
   open Package.swift -a Xcode
   ```

2. **Wait for indexing** (first time only, ~30 seconds)

3. **Press ⌘R** to build and run

4. **The app window will appear** with Focus Mode!

### Method 2: Command Line (No GUI - for background processes only)

```bash
swift run
```
⚠️ **Note:** This runs headless and won't show a window. Use Xcode instead for GUI.

---

## ✅ What You'll See

When you run the app in Xcode, you'll see:

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                                                            │
│                       Untitled                             │
│                                                            │
│                   Start typing here...                     │
│                                                            │
│                                                            │
│                                                            │
│                                                            │
│                                                            │
│  ┌──────────────────────────────────────────────────┐     │
│  │ 📝 0 words · ⏱ 0m · 🔥 0 days · ⚡ 0 today      │     │
│  └──────────────────────────────────────────────────┘     │
└────────────────────────────────────────────────────────────┘
```

### Features Available Now:
- ✅ **Dark mode** - ADHD-friendly colors
- ✅ **Auto-focus** - Cursor ready to type
- ✅ **Auto-save** - Saves every 1 second (debounced)
- ✅ **Stats footer** - Live word count, timer, streak
- ✅ **Sidebar toggle** - Press ⌘B to show/hide notes

---

## 🎯 Quick Actions

| Keyboard Shortcut | Action |
|-------------------|--------|
| **⌘N** | Create new note |
| **⌘B** | Toggle sidebar |
| **⌘W** | Close window (auto-saves) |
| **⌘Q** | Quit app |

---

## 📁 Project Structure (Clean)

```
scribe-sw/
├── Sources/Scribe/
│   ├── Views/              ✅ NEW - Clean UI
│   │   ├── DesignSystem.swift
│   │   ├── EditorView.swift
│   │   ├── StatsFooter.swift
│   │   └── MainView.swift
│   ├── Store/
│   │   └── AppState.swift
│   ├── Domain/Services/
│   ├── Data/
│   ├── Models/
│   └── Utils/
├── docs/
│   └── UI_REDESIGN_BRAINSTORM.md
├── Package.swift
└── README.md
```

---

## 🐛 Troubleshooting

### App doesn't show a window
**Solution:** Make sure you're running from Xcode (⌘R), not `swift run`

### Build errors
```bash
# Clean build
rm -rf .build
swift build
```

### Database errors
```bash
# Reset database
rm -rf ~/Library/Application\ Support/Scribe/
# Restart app - it will recreate
```

### Xcode indexing stuck
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/Scribe-*
# Reopen in Xcode
```

---

## 📊 Current Status

### ✅ Completed
- [x] Clean UI redesign (4 new files)
- [x] ADHD-friendly Focus Mode
- [x] Stats footer with live updates
- [x] Auto-save functionality
- [x] Dark mode default
- [x] Database layer (GRDB + SQLite)
- [x] Service layer (NoteService, ProjectService)
- [x] AppState management

### 🚧 Next Features (Planned)
- [ ] Markdown live preview
- [ ] LaTeX rendering (MathJax)
- [ ] Wiki link autocomplete
- [ ] Command palette (⌘K)
- [ ] Enhanced sidebar (projects, tags)
- [ ] Search functionality

---

## 📚 Documentation

- **UI Design:** `docs/UI_REDESIGN_BRAINSTORM.md`
- **Implementation:** `UI_REDESIGN_COMPLETE.md`
- **Product Requirements:** `docs/PRODUCT_REQUIREMENTS.md`
- **Architecture:** `docs/development/ARCHITECTURE.md`

---

## 🎨 Design Principles

1. **Zero Friction** - < 3 seconds to start writing
2. **One Thing at a Time** - Focus Mode default
3. **Escape Hatches** - Auto-save, ⌘W closes
4. **Visible Progress** - Stats footer always visible
5. **Sensory-Friendly** - Dark mode, comfortable fonts

---

## 🔧 Development

### Build from scratch
```bash
rm -rf .build
swift build
```

### Run tests (when implemented)
```bash
swift test
```

### Format code
```bash
swift format --in-place Sources/
```

---

## 📝 Next Steps

1. **Run in Xcode** (⌘R)
2. **Test the Focus Mode** experience
3. **Create some notes** to test auto-save
4. **Toggle sidebar** (⌘B) to see note list
5. **Report any bugs** or UI issues

---

**Happy Writing! 📝**
