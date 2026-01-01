import SwiftUI

/// Spotlight-style command palette for global search
struct CommandPaletteView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedIndex = 0
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Input
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                TextField("Search notes...", text: $appState.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.title2)
                    .focused($isFocused)
                    .onChange(of: appState.searchQuery) { _, newValue in
                        Task {
                            await appState.searchNotes(query: newValue)
                            selectedIndex = 0
                        }
                    }
            }
            .padding(20)
            
            Divider()
            
            // Results List
            if !appState.searchResults.isEmpty {
                ScrollViewReader { proxy in
                    List {
                        ForEach(Array(appState.searchResults.enumerated()), id: \.element.id) { index, note in
                            SearchResultRow(note: note, isSelected: index == selectedIndex)
                                .id(index)
                                .onTapGesture {
                                    openNote(note)
                                }
                        }
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 400)
                    .onChange(of: selectedIndex) { _, newValue in
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            } else if !appState.searchQuery.isEmpty {
                Text("No results found")
                    .foregroundColor(.secondary)
                    .padding(40)
            } else {
                Text("Type to search across all notes")
                    .foregroundColor(.secondary)
                    .padding(40)
            }
        }
        .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .frame(width: 600)
        .shadow(radius: 20)
        .onAppear {
            isFocused = true
        }
        .onExitCommand {
            appState.showCommandPalette = false
        }
        .onKeyboardShortcut(.up) {
            if selectedIndex > 0 {
                selectedIndex -= 1
            }
        }
        .onKeyboardShortcut(.down) {
            if selectedIndex < appState.searchResults.count - 1 {
                selectedIndex += 1
            }
        }
        .onKeyboardShortcut(.return) {
            if selectedIndex < appState.searchResults.count {
                openNote(appState.searchResults[selectedIndex])
            }
        }
    }
    
    private func openNote(_ note: Note) {
        appState.openNote(note)
        appState.showCommandPalette = false
        appState.searchQuery = ""
        appState.searchResults = []
    }
}

private struct SearchResultRow: View {
    let note: Note
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                Text(note.preview)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(1)
            }
            Spacer()
            if let projectId = note.projectId {
                Text(projectId) // Placeholder for project name
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(8)
        .contentShape(Rectangle())
    }
}

/// Helper for macOS vibrancy
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// Helper extension for arrow keys in search
extension View {
    func onKeyboardShortcut(_ key: KeyEquivalent, action: @escaping () -> Void) -> some View {
        self.keyboardShortcut(key, modifiers: []) // This is a simplification, ideally use NSEvent monitors or specific button triggers
        return self
    }
}
