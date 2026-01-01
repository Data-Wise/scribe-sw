import SwiftUI

/// Markdown editor for a single page
struct PageEditor: View {
    let page: Page
    @EnvironmentObject var appState: AppState
    @State private var content: String
    @State private var isFocusMode = false
    @FocusState private var isEditorFocused: Bool

    init(page: Page) {
        self.page = page
        _content = State(initialValue: page.content)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    TextField("Untitled", text: .constant(page.title))
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
                            var updatedPage = page
                            updatedPage.content = newValue
                            appState.savePage(updatedPage)
                        }
                }
            }
            .background(Color(.textBackgroundColor))
        }
        .overlay(alignment: .bottom) {
            // Status bar
            EditorStatusBar(page: page, content: content)
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
    let page: Page
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
            Text("Updated \(page.updatedAt.formatted(.relative(presentation: .named)))")
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
    PageEditor(page: Page(title: "Test Page", content: "Hello world"))
        .environmentObject(AppState())
}
