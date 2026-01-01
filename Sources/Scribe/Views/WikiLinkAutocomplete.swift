import SwiftUI

/// Wiki link autocomplete popup
struct WikiLinkAutocomplete: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    @State private var selectedIndex: Int = 0
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search input
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                TextField("Search notes", text: text)
                    .focused($isFocused)
                    .textFieldStyle(.plain)
                    .onChange(of: text) { _, _ in
                        selectedIndex = 0
                    }
            }
            .padding(12)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
            
            Divider()
                .padding(.horizontal)
            
            // Results list
            if !filteredSuggestions.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(Array(filteredSuggestions.enumerated()), id: \.offset) { index, suggestion in
                            SuggestionRow(
                                suggestion: suggestion,
                                isSelected: selectedIndex == index,
                                onSelect: {
                                    insertWikiLink(suggestion.title)
                                    isPresented = false
                                }
                            )
                            .onTapGesture {
                                selectedIndex = index
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 300)
            } else {
                emptyState
            }
        }
        .padding(16)
        .frame(width: 400)
        .background(Color(.windowBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            isFocused = true
        }
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                selectedIndex = 0
            }
        }
    }
    
    private var filteredSuggestions: [WikiLinkSuggestion] {
        appState.notes
            .filter { !$0.isDeleted }
            .map { note in
                WikiLinkSuggestion(title: note.title, preview: note.preview, type: .note, noteId: note.id)
            }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "link")
                .font(.largeTitle)
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No matching notes")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func insertWikiLink(_ title: String) {
        guard let note = appState.notes.first(where: { $0.title == title })?.id else { return }
        
        let link = "[[\(title)]](\(note.id))"
        
        // Trigger save through AppState
        if let currentNote = appState.selectedNote {
            var updated = currentNote
            updated.content = link + currentNote.content
            
            Task {
                await appState.saveNote(updated)
            }
        }
    }
}

// MARK: - Supporting Types

struct WikiLinkSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let preview: String
    let type: SuggestionType
    let noteId: String
    
    enum SuggestionType {
        case note
        case project
        case tag
    }
}

// MARK: - Helper Views

struct SuggestionRow: View {
    let suggestion: WikiLinkSuggestion
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: suggestion.type.icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.title)
                        .font(.body)
                        .foregroundColor(isSelected ? .accentColor : .primary)
                        .lineLimit(1)
                    
                    if !suggestion.preview.isEmpty {
                        Text(suggestion.preview)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Keyboard shortcut
                if suggestion.type == .note {
                    Text("Enter")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

extension WikiLinkSuggestion.SuggestionType {
    var icon: String {
        switch self {
        case .note: return "doc.text"
        case .project: return "folder"
        case .tag: return "tag"
        }
    }
}

#Preview {
    WikiLinkAutocomplete(
        isPresented: .constant(true),
        text: .constant("")
    )
    .environmentObject(
        AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
    )
    .frame(width: 1200, height: 800)
}

            }
            .padding(12)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
            
            Divider()
                .padding(.horizontal)
            
            // Results list
            if !filteredSuggestions.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(Array(filteredSuggestions.enumerated()), id: \.offset) { index, suggestion in
                            SuggestionRow(
                                suggestion: suggestion,
                                isSelected: selectedIndex == index,
                                onSelect: {
                                    insertWikiLink(suggestion.title)
                                    isPresented = false
                                }
                            )
                            .onTapGesture {
                                selectedIndex = index
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 300)
            } else {
                emptyState
            }
        }
        .padding(16)
        .frame(width: 400)
        .background(Color(.windowBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            isFocused = true
        }
                .onChange(of: isPresented) { _, newValue in
                    if newValue {
                        selectedIndex = 0
                        text.wrappedValue = ""
                    }
                }
    }
    
    private var filteredSuggestions: [WikiLinkSuggestion] {
        appState.notes
            .filter { !$0.isDeleted }
            .map { note in
                WikiLinkSuggestion(title: note.title, preview: note.preview, type: .note, noteId: note.id)
            }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "link")
                .font(.largeTitle)
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No matching notes")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func insertWikiLink(_ title: String) {
        guard let noteId = appState.notes.first(where: { $0.title == title })?.id else { return }
        
        let link = "[[\(title)]](\(noteId))"
        
        // Trigger save through AppState
        if let currentNote = appState.selectedNote {
            var updated = currentNote
            updated.content = link + currentNote.content
            Task {
                await appState.saveNote(updated)
            }
        }
    }
}

// MARK: - Supporting Types

struct WikiLinkSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let preview: String
    let type: SuggestionType
    let noteId: String
    
    enum SuggestionType {
        case note
        case project
        case tag
    }
}

// MARK: - Helper Views

struct SuggestionRow: View {
    let suggestion: WikiLinkSuggestion
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: suggestion.type.icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.title)
                        .font(.body)
                        .foregroundColor(isSelected ? .accentColor : .primary)
                        .lineLimit(1)
                    
                    if !suggestion.preview.isEmpty {
                        Text(suggestion.preview)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Keyboard shortcut
                if suggestion.type == .note {
                    Text("Enter")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

extension WikiLinkSuggestion.SuggestionType {
    var icon: String {
        switch self {
        case .note: return "doc.text"
        case .project: return "folder"
        case .tag: return "tag"
        }
    }
}

#Preview {
    WikiLinkAutocomplete(
        isPresented: .constant(true)
    )
    .environmentObject(
        AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
    )
    .frame(width: 1200, height: 800)
}
