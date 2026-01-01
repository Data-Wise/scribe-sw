import SwiftUI

/// Markdown editor for a single note
struct NoteEditorView: View {
    let note: Note
    @EnvironmentObject var appState: AppState
    @State private var content: String
    @State private var isFocusMode = false
    @FocusState private var isEditorFocused: Bool
    
    init(note: Note) {
        self.note = note
        _content = State(initialValue: note.content)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    TextField("Untitled", text: .constant(note.title))
                        .font(.system(size: 28, weight: .bold))
                        .textFieldStyle(.plain)
                        .padding(.horizontal, editorPadding(geometry))
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                    
                    // Editor
                    TextEditor(text: $content)
                        .font(.system(size: 16, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, editorPadding(geometry))
                        .focused($isEditorFocused)
                        .frame(minHeight: geometry.size.height - 200)
                        .onChange(of: content) { _, newValue in
                            var updatedNote = note
                            updatedNote.content = newValue
                            appState.saveNote(updatedNote)
                        }
                }
            }
            .background(Color(.textBackgroundColor))
        }
        .overlay(alignment: .bottom) {
            // Status bar
            EditorStatusBar(note: note, content: content)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { isFocusMode.toggle() }) {
                    Image(systemName: isFocusMode ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                }
                .help("Focus mode (⌘⇧F)")
            }
        }
        .onAppear {
            isEditorFocused = true
        }
    }
    
    private func editorPadding(_ geometry: GeometryProxy) -> CGFloat {
        let idealWidth: CGFloat = 700
        let minPadding: CGFloat = 40
        let availableWidth = geometry.size.width
        
        if availableWidth <= idealWidth + (minPadding * 2) {
            return minPadding
        }
        
        return (availableWidth - idealWidth) / 2
    }
}

// MARK: - Status Bar

private struct EditorStatusBar: View {
    let note: Note
    let content: String
    
    var body: some View {
        HStack {
            // Word count
            Label("\(wordCount) words", systemImage: "textformat")
            
            Divider()
                .frame(height: 12)
            
            // Character count
            Text("\(content.count) chars")
            
            Spacer()
            
            // Last updated
            Text("Updated \(note.modifiedDate.formatted(.relative(presentation: .named)))")
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
    
    private var wordCount: Int {
        content.split(separator: " ").count
    }
}

#Preview {
    NoteEditorView(note: Note(title: "Test Note", content: "Hello world"))
        .environmentObject(AppState())
}
