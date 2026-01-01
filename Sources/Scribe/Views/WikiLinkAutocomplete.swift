import SwiftUI

/// Wiki link autocomplete suggestion
struct WikiLinkSuggestion: Identifiable {
    let id: String
    let title: String
    let preview: String
    
    init(note: Note) {
        self.id = note.id
        self.title = note.title
        self.preview = note.preview
    }
}

/// Wiki link autocomplete view
struct WikiLinkAutocomplete: View {
    let suggestions: [WikiLinkSuggestion]
    let onSelect: (WikiLinkSuggestion) -> Void
    @State private var selectedIndex = 0
    
    var body: some View {
        if !suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(suggestions.prefix(5).enumerated()), id: \.element.id) { index, suggestion in
                    Button {
                        onSelect(suggestion)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(suggestion.title)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text(suggestion.preview)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(index == selectedIndex ? Color.accentColor.opacity(0.1) : Color.clear)
                    }
                    .buttonStyle(.plain)
                    
                    if index < min(4, suggestions.count - 1) {
                        Divider()
                    }
                }
            }
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .shadow(radius: 8)
            .frame(width: 300)
        }
    }
}

/// Helper to detect wiki link context
struct WikiLinkContext {
    let range: Range<String.Index>
    let query: String
    
    static func detect(in text: String, at position: String.Index) -> WikiLinkContext? {
        // Find the last [[ before cursor
        guard let text = text as String?,
              let startRange = text[..<position].range(of: "[[", options: .backwards) else {
            return nil
        }
        
        let searchStart = startRange.upperBound
        
        // Check if there's a ]] between [[ and cursor
        let textBetween = text[searchStart..<position]
        if textBetween.contains("]]") {
            return nil
        }
        
        // Extract query
        let query = String(textBetween)
        
        return WikiLinkContext(
            range: searchStart..<position,
            query: query
        )
    }
}

#Preview {
    WikiLinkAutocomplete(
        suggestions: [
            WikiLinkSuggestion(note: Note(title: "Research Methods", content: "Statistical analysis techniques")),
            WikiLinkSuggestion(note: Note(title: "R Development", content: "Package development guide")),
            WikiLinkSuggestion(note: Note(title: "Regression Analysis", content: "Linear and logistic regression"))
        ]
    ) { _ in }
    .frame(width: 300)
    .padding()
}
