# Migrating from SPM to Xcode Project

## Why This Is Necessary

Swift Package Manager `.executable` targets are designed for **command-line tools**, not GUI applications. 

Your app needs:
- ✅ Proper code signing
- ✅ Entitlements for keyboard shortcuts
- ✅ Menu bar integration
- ✅ Spotlight indexing
- ✅ Proper bundle identifier
- ✅ App icon and resources

**None of these work properly with SPM executables.**

## Migration Steps

### 1. Create New Xcode Project

```bash
# Open Xcode
open -a Xcode
```

In Xcode:
1. File → New → Project
2. Select **macOS** → **App**
3. Settings:
   - **Product Name:** Scribe
   - **Team:** Your team (or None for development)
   - **Organization Identifier:** com.datawise
   - **Bundle Identifier:** com.datawise.scribe
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** None (we're using GRDB)
4. Save in: `~/projects/dev-tools/scribe-sw/ScribeXcode/`

### 2. Add Package Dependencies

In the new Xcode project:

1. Select project in navigator
2. Go to **Package Dependencies** tab
3. Click **+** and add:
   - `https://github.com/apple/swift-markdown.git` (main branch)
   - `https://github.com/groue/GRDB.swift.git` (6.24.0)
   - `https://github.com/sindresorhus/KeyboardShortcuts.git` (1.16.0)

### 3. Copy Your Source Files

```bash
# From your current SPM project
cd ~/projects/dev-tools/scribe-sw

# Copy all Swift files to new Xcode project
cp -r Sources/Scribe/*.swift ScribeXcode/Scribe/
```

Or drag files in Xcode:
- Delete the default `ContentView.swift` and `ScribeApp.swift`
- Drag your Swift files from Finder into Xcode navigator

### 4. Configure Entitlements

In Xcode project settings:
1. Select target → **Signing & Capabilities**
2. Click **+ Capability**
3. Add these as needed:
   - **Hardened Runtime** (for distribution)
   - **App Sandbox** (optional, but recommended for Mac App Store)
   - If using App Sandbox, enable:
     - File Access → User Selected Files (Read/Write)
     - App Data → Downloads Folder (if needed)

### 5. Run and Test

Press **⌘R** to build and run. The app should now:
- ✅ Launch without being killed
- ✅ Have a proper bundle identifier
- ✅ Support keyboard shortcuts properly
- ✅ Appear in Activity Monitor correctly
- ✅ Be ready for eventual App Store submission

## Keeping SPM for Libraries

You can still use `Package.swift` for **library code** and dependencies. Many developers use:
- **Xcode project** for the app target
- **Swift Package** for shared business logic

## Alternative: Keep SPM + Use build-app.sh

If you really want to avoid Xcode:
1. Use the `build-app.sh` script I created
2. Run `./build-app.sh` to create proper .app bundle
3. Open with `open .build/debug/Scribe.app`

But this is **not recommended** for the features you need (menu bar, global shortcuts, etc).

## Bottom Line

**For your use case, an Xcode project is the right tool.** SPM is fantastic for libraries and CLI tools, but SwiftUI GUI apps with system integration need proper app bundling.
