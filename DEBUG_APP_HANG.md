# App Hanging Issue Debug Log

**Date:** January 1, 2026
**Status:** CRITICAL - App hangs on startup

## Issue Description

The macOS app hangs immediately on startup. The window appears but becomes unresponsive.

**Symptoms:**
- App window appears
- UI freezes (beachball)
- Keyboard shortcuts don't work (⌘N, ⌘[, ⌘])
- Cannot type in editor
- No responsiveness to clicks

## Timeline of Debugging Attempts

### Attempt 1: Initial Drag-and-Drop Implementation ✅
- Added `.onDrag` to NoteRow
- Added `.onDrop` to ProjectSection and UncategorizedSection
- Added `moveNote()` method to AppState
- Used `Task { @MainActor in }` pattern

**Result:** App hangs immediately on startup

### Attempt 2: Remove Drag-and-Drop ✅
- Commented out all drag-and-drop code
- Simplified to basic functionality

**Result:** Still hangs

### Attempt 3: Fix Timer Refresh Pattern ✅
- Removed `sessionTimerTick` from AppState
- Moved timer to local `@State` in StatsFooter
- Used hidden Text pattern for timer updates
- Removed one test (testSessionTimerTickIncrementsOverTime)

**Result:** Still hangs

### Attempt 4: Add Debug Logging ✅
- Added print statements to DatabaseManager.init()
- Added print statements to AppState.init()
- Added print statements to ScribeApp.init()

**Result:** Still hangs, no console output visible (can't get logs from user)

### Attempt 5: Remove Task from AppState.init ✅
- Removed `Task { await loadData() }` from init
- Moved loadData() to MainView.onAppear()
- Added projects.isEmpty check before loading

**Result:** Still hangs

### Attempt 6: Remove @MainActor from Services ✅
- Removed `@MainActor` from NoteService
- Removed `@MainActor` from ProjectService
- Services now inherit actor context from callers

**Result:** Still hangs

### Attempt 7: Remove Timer from StatsFooter ✅
- Removed `@State private var currentTime = Date()`
- Removed `.onReceive(Timer.publish(...))` modifier
- Simplified to static display (no live updates)

**Result:** Still hangs

## Current State

**Build Status:** ✅ Compiles successfully
**Test Status:** ✅ 140 tests passing
**Run Status:** ❌ Hangs on startup

**Files Modified:**
- ScribeApp.swift
- AppState.swift
- NoteService.swift
- ProjectService.swift
- StatsFooter.swift
- DatabaseManager.swift
- MainView.swift

## Potential Root Causes

### 1. SwiftUI @StateObject Initialization Issue
- Problem: `@StateObject` calls init synchronously
- Services might be initializing before main actor ready
- DatabaseManager actor might cause deadlock

### 2. DatabaseManager Actor Isolation
- Problem: `DatabaseManager` is an `actor`
- Services call it from various contexts
- Possible deadlock if called before fully initialized

### 3. WritingStats.load() Issue
- Problem: `UserDefaults` access in init
- Might be blocking main thread
- JSON decoding could hang on corrupted data

### 4. System-Specific Issue
- Problem: macOS version compatibility
- SwiftUI version issue
- Xcode/Swift runtime issue

## Questions for User

**1. macOS Version:** _____
**2. Xcode Version:** _____
**3. Mac Model:** _____
**4. When does hang happen?**
   - [ ] Window never appears
   - [ ] Window appears, then freezes immediately
   - [ ] Window appears, works for a few seconds, then freezes
   - [ ] Window appears but never becomes responsive

**5. What do you see?**
   - [ ] Spinning beachball
   - [ ] Frozen window (cursor works, UI doesn't)
   - [ ] Cursor doesn't move at all
   - [ ] Other: _____

**6. Console Output:**
   Last 10 lines from Xcode Debug Area (⌘⇧Y):
   ```
   [PASTE HERE]
   ```

## Next Steps to Try

### Option A: Minimal Reproduction
Create a minimal SwiftUI app with just:
- Text("Hello World")
- No database, no services, no state

**Purpose:** Determine if it's SwiftUI/Environment issue vs. Scribe code issue

### Option B: Database-Free Version
Comment out all database calls:
- Don't initialize DatabaseManager
- Don't load notes/projects
- Use hardcoded mock data

**Purpose:** Determine if it's database actor isolation issue

### Option C: WritingStats-Free Version
Comment out WritingStats.load() and WritingStats.init():
- Don't load from UserDefaults
- Don't calculate streak
- Use hardcoded stats

**Purpose:** Determine if it's UserDefaults/JSON blocking main thread

### Option D: Xcode Fresh Build
1. Clean build folder: `rm -rf .build`
2. Delete derived data: Xcode → Settings → Locations → Derived Data
3. Rebuild from scratch

**Purpose:** Determine if it's cached build artifact issue

### Option E: Run from Command Line
Instead of running from Xcode, run executable directly:
```bash
.build/debug/Scribe
```

**Purpose:** Determine if it's Xcode debugger issue

## Commits Related to Issue

1. `feat(drag-drop): implement drag-and-drop` - Added drag-drop, first hang
2. `fix(drag-drop): prevent UI hang` - Changed Task to DispatchQueue
3. `fix(timer): remove AppState timer` - Moved timer to local @State
4. `fix(init): remove @MainActor` - Removed @MainActor from services
5. `fix(timer): remove timer entirely` - Removed all timer code

## Technical Details

### DatabaseManager.init()
```swift
private init() {
    // Creates DatabaseQueue
    // Runs migrations
    // All inside do-catch
    // Has fatalError on error
}
```

### AppState.init()
```swift
init(noteService: NoteService, projectService: ProjectService) {
    self.noteService = noteService
    self.projectService = projectService

    // Loads from UserDefaults
    self.writingStats = WritingStats.load()
    writingStats.startNewSession()

    // NO async Task here (removed)
}
```

### MainView.onAppear()
```swift
.onAppear {
    Task {
        // Loads data from database
        if appState.projects.isEmpty {
            await appState.loadData()
        }

        // Creates initial note
        if appState.notes.isEmpty {
            await appState.createNewNote()
        }
    }
}
```

## Conclusion

The issue is likely in the initialization chain:
`ScribeApp.init()` → `AppState.init()` → `WritingStats.load()` OR `@StateObject` mechanism

**Most Likely Causes (in order):**
1. `@StateObject` initialization deadlock
2. `WritingStats.load()` blocking on UserDefaults
3. DatabaseManager actor isolation
4. macOS version incompatibility

**Need user feedback to determine which path to pursue.**
