import SwiftUI

struct CitationAutocomplete: View {
    let citations: [Citation]
    let onSelect: (Citation) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Citations")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if citations.isEmpty {
                        Text("No matching citations")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(10)
                    } else {
                        ForEach(citations) { citation in
                            Button(action: { onSelect(citation) }) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(citation.id)
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    Text(citation.title)
                                        .font(.system(size: 12))
                                        .lineLimit(1)
                                    Text(citation.subtitle)
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            Divider()
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .frame(width: 300)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
