import SwiftUI

/// App settings window
struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            EditorSettingsView()
                .tabItem {
                    Label("Editor", systemImage: "pencil")
                }

            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }

            KeyboardSettingsView()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - General Settings

private struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true
    @AppStorage("defaultVault") private var defaultVault = ""

    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                Toggle("Show menu bar icon", isOn: $showMenuBarIcon)
            }

            Section("Defaults") {
                Picker("Default vault", selection: $defaultVault) {
                    Text("Inbox").tag("")
                    // TODO: Add vaults
                }
            }

            Section("Data") {
                HStack {
                    Text("Database location")
                    Spacer()
                    Text("~/Library/Application Support/Scribe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button("Reveal in Finder") {
                    // TODO: Open database location
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Editor Settings

private struct EditorSettingsView: View {
    @AppStorage("editorFontSize") private var editorFontSize = 16.0
    @AppStorage("editorLineHeight") private var editorLineHeight = 1.6
    @AppStorage("editorFontFamily") private var editorFontFamily = "System"
    @AppStorage("autoSave") private var autoSave = true
    @AppStorage("autoSaveInterval") private var autoSaveInterval = 30

    var body: some View {
        Form {
            Section("Typography") {
                Picker("Font", selection: $editorFontFamily) {
                    Text("System").tag("System")
                    Text("SF Mono").tag("SF Mono")
                    Text("Menlo").tag("Menlo")
                    Text("Monaco").tag("Monaco")
                }

                HStack {
                    Text("Font size")
                    Spacer()
                    Slider(value: $editorFontSize, in: 12...24, step: 1) {
                        Text("Font size")
                    }
                    .frame(width: 150)
                    Text("\(Int(editorFontSize))pt")
                        .monospacedDigit()
                        .frame(width: 40)
                }

                HStack {
                    Text("Line height")
                    Spacer()
                    Slider(value: $editorLineHeight, in: 1.2...2.0, step: 0.1) {
                        Text("Line height")
                    }
                    .frame(width: 150)
                    Text(String(format: "%.1f", editorLineHeight))
                        .monospacedDigit()
                        .frame(width: 40)
                }
            }

            Section("Saving") {
                Toggle("Auto-save", isOn: $autoSave)

                if autoSave {
                    Picker("Auto-save interval", selection: $autoSaveInterval) {
                        Text("10 seconds").tag(10)
                        Text("30 seconds").tag(30)
                        Text("1 minute").tag(60)
                        Text("5 minutes").tag(300)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Appearance Settings

private struct AppearanceSettingsView: View {
    @AppStorage("appearance") private var appearance = "system"
    @AppStorage("accentColor") private var accentColor = "blue"

    var body: some View {
        Form {
            Section("Theme") {
                Picker("Appearance", selection: $appearance) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
            }

            Section("Colors") {
                Picker("Accent color", selection: $accentColor) {
                    HStack {
                        Circle().fill(.blue).frame(width: 12, height: 12)
                        Text("Blue")
                    }.tag("blue")
                    HStack {
                        Circle().fill(.purple).frame(width: 12, height: 12)
                        Text("Purple")
                    }.tag("purple")
                    HStack {
                        Circle().fill(.green).frame(width: 12, height: 12)
                        Text("Green")
                    }.tag("green")
                    HStack {
                        Circle().fill(.orange).frame(width: 12, height: 12)
                        Text("Orange")
                    }.tag("orange")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Keyboard Settings

private struct KeyboardSettingsView: View {
    var body: some View {
        Form {
            Section("Global Shortcuts") {
                ShortcutRow(name: "Quick Capture", shortcut: "⌘⇧C")
                ShortcutRow(name: "Daily Note", shortcut: "⌘⇧D")
                ShortcutRow(name: "Show/Hide Scribe", shortcut: "⌃⌘S")
            }

            Section("Editor") {
                ShortcutRow(name: "New Page", shortcut: "⌘N")
                ShortcutRow(name: "Toggle Sidebar", shortcut: "⌘[")
                ShortcutRow(name: "Focus Mode", shortcut: "⌘⇧F")
                ShortcutRow(name: "Save", shortcut: "⌘S")
            }

            Section("Navigation") {
                ShortcutRow(name: "Go to Page...", shortcut: "⌘P")
                ShortcutRow(name: "Previous Tab", shortcut: "⌃⇧⇥")
                ShortcutRow(name: "Next Tab", shortcut: "⌃⇥")
                ShortcutRow(name: "Close Tab", shortcut: "⌘W")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

private struct ShortcutRow: View {
    let name: String
    let shortcut: String

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text(shortcut)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(4)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
