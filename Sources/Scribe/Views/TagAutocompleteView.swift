import SwiftUI

/// Tag autocomplete view
struct TagAutocompleteView: View {
    let tags: [String]
    let onSelect: (String) -> Void
    @State private var selectedIndex = 0
    
    var body: some View {
        if !tags.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(tags.prefix(10).enumerated()), id: \.offset) { index, tag in
                    Button {
                        onSelect(tag)
                    } label: {
                        HStack {
                            Text(tag)
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(index == selectedIndex ? Color.accentColor.opacity(0.1) : Color.clear)
                    .cornerRadius(6)
                    .buttonStyle(.plain)
                    
                    if index < min(9, tags.count - 1) {
                        Divider()
                    }
                }
            }
            .padding(8)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .shadow(radius: 8)
            .frame(width: 200)
        }
    }
}

/// Helper to detect tag context
struct TagContext {
    let range: Range<String.Index>
    let query: String
    
    static func detect(in text: String, at position: String.Index) -> TagContext? {
        // Find the last # before cursor
        guard let startRange = text[..<position].range(of: "#", options: .backwards) else {
            return nil
        }
        
        // Ensure there's no space between # and cursor
        let textBetween = text[startRange.upperBound..<position]
        if textBetween.contains(" ") || textBetween.contains("\n") {
            return nil
        }
        
        // Extract query
        let query = String(textBetween)
        
        return TagContext(
            range: startRange.upperBound..<position,
            query: query
        )
    }
}
