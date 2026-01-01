import SwiftUI

/// Wiki link autocomplete popup
struct WikiLinkAutocomplete: View {
    @EnvironmentObject var appState: AppState
    let suggestions: [WikiLinkSuggestion]
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("Search notes")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
            
            Divider()
                .padding(.horizontal)
            
            // Results list
            if !suggestions.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                            SuggestionRow(
                                suggestion: suggestion,
                                isSelected: selectedIndex == index,
                                onSelect: {
                                    insertWikiLink(suggestion.title)
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
            selectedIndex = 0
        }
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
        
        // Find current note
        guard let currentNote = appState.notes.first(where: { $0.id == appState.selectedNoteId }) else {
            return
        }

        var updated = currentNote
        updated.content = link + updated.content
        Task {
            appState.saveNote(updated)
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
