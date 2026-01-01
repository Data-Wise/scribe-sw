import SwiftUI
import WebKit

/// Hybrid editor with source/preview split view
struct HybridEditorView: View {
    let note: Note
    @EnvironmentObject var appState: AppState
    
    @State private var content: String
    @State private var title: String
    @State private var showPreview = true
    @State private var showRightSidebar = true
    @State private var splitRatio: CGFloat = 0.5
    @FocusState private var isEditorFocused: Bool
    
    init(note: Note) {
        self.note = note
        _content = State(initialValue: note.content)
        _title = State(initialValue: note.title)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Main editor
            VStack(spacing: 0) {
                // Title bar
                TitleBar(title: $title, note: note)
                
                Divider()
                
                // Editor content
                GeometryReader { geometry in
                    if showPreview {
                        // Split view: Source + Preview
                        HSplitView {
                            SourceEditor(content: $content, isEditorFocused: $isEditorFocused)
                                .frame(minWidth: 300)
                            
                            MarkdownPreview(content: content)
                                .frame(minWidth: 300)
                        }
                    } else {
                        // Source only
                        SourceEditor(content: $content, isEditorFocused: $isEditorFocused)
                    }
                }
                
                Divider()
                
                // Status bar
                StatusBar(note: note, content: content, wordCount: wordCount)
            }
            
            // Right sidebar
            if showRightSidebar {
                Divider()
                RightSidebar(note: note)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showPreview.toggle()
                } label: {
                    Image(systemName: showPreview ? "eye.fill" : "eye.slash")
                }
                .help("Toggle Preview (⌘P)")
                .keyboardShortcut("p", modifiers: .command)
                
                Button {
                    showRightSidebar.toggle()
                } label: {
                    Image(systemName: "sidebar.right")
                }
                .help("Toggle Sidebar (⌘⌥R)")
                .keyboardShortcut("r", modifiers: [.command, .option])
                
                Menu {
                    Button("Bold", action: { insertMarkdown("**", "**") })
                        .keyboardShortcut("b", modifiers: .command)
                    Button("Italic", action: { insertMarkdown("*", "*") })
                        .keyboardShortcut("i", modifiers: .command)
                    Button("Code", action: { insertMarkdown("`", "`") })
                        .keyboardShortcut("e", modifiers: .command)
                    Divider()
                    Button("Heading 1", action: { insertMarkdown("# ", "") })
                    Button("Heading 2", action: { insertMarkdown("## ", "") })
                    Button("Heading 3", action: { insertMarkdown("### ", "") })
                    Divider()
                    Button("Inline Math", action: { insertMarkdown("$", "$") })
                    Button("Display Math", action: { insertMarkdown("$$\n", "\n$$") })
                } label: {
                    Image(systemName: "textformat")
                }
                .help("Formatting")
            }
        }
        .onChange(of: content) { _, newValue in
            saveNote()
        }
        .onChange(of: title) { _, newValue in
            saveNote()
        }
        .onAppear {
            isEditorFocused = true
        }
    }
    
    private var wordCount: Int {
        content.split(separator: " ").count
    }
    
    private func saveNote() {
        var updatedNote = note
        updatedNote.title = title
        updatedNote.content = content
        appState.saveNote(updatedNote)
    }
    
    private func insertMarkdown(_ prefix: String, _ suffix: String) {
        content += prefix + suffix
    }
}

// MARK: - Title Bar

private struct TitleBar: View {
    @Binding var title: String
    let note: Note
    
    var body: some View {
        HStack {
            TextField("Untitled", text: $title)
                .font(.system(size: 24, weight: .bold))
                .textFieldStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            
            Spacer()
            
            // Note metadata
            VStack(alignment: .trailing, spacing: 4) {
                if !note.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(note.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Text(note.modifiedDate.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.trailing, 20)
        }
        .background(Color(.windowBackgroundColor))
    }
}

// MARK: - Source Editor

private struct SourceEditor: View {
    @Binding var content: String
    var isEditorFocused: FocusState<Bool>.Binding
    
    var body: some View {
        TextEditor(text: $content)
            .font(.system(size: 15, design: .monospaced))
            .scrollContentBackground(.hidden)
            .padding(20)
            .focused(isEditorFocused)
            .background(Color(.textBackgroundColor))
    }
}

// MARK: - Markdown Preview

private struct MarkdownPreview: View {
    let content: String
    
    var body: some View {
        WebView(html: renderedHTML)
            .background(Color(.textBackgroundColor))
    }
    
    private var renderedHTML: String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
            <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                    line-height: 1.6;
                    padding: 20px;
                    max-width: 800px;
                    margin: 0 auto;
                    color: #333;
                }
                @media (prefers-color-scheme: dark) {
                    body {
                        background-color: #1e1e1e;
                        color: #e0e0e0;
                    }
                    a { color: #58a6ff; }
                    code {
                        background-color: #2d2d2d;
                        color: #e0e0e0;
                    }
                }
                code {
                    background-color: #f5f5f5;
                    padding: 2px 6px;
                    border-radius: 3px;
                    font-family: "SF Mono", Monaco, monospace;
                    font-size: 0.9em;
                }
                pre {
                    background-color: #f5f5f5;
                    padding: 16px;
                    border-radius: 6px;
                    overflow-x: auto;
                }
                @media (prefers-color-scheme: dark) {
                    pre { background-color: #2d2d2d; }
                }
                blockquote {
                    border-left: 4px solid #ddd;
                    margin-left: 0;
                    padding-left: 16px;
                    color: #666;
                }
                h1, h2, h3, h4, h5, h6 {
                    margin-top: 24px;
                    margin-bottom: 16px;
                    font-weight: 600;
                }
                a {
                    color: #0969da;
                    text-decoration: none;
                }
                a:hover {
                    text-decoration: underline;
                }
            </style>
        </head>
        <body>
            <div id="content"></div>
            <script>
                const markdown = `\(escapeForJS(content))`;
                
                // Configure marked for GFM
                marked.setOptions({
                    gfm: true,
                    breaks: true
                });
                
                // Render markdown
                document.getElementById('content').innerHTML = marked.parse(markdown);
                
                // Render math
                MathJax.typesetPromise();
            </script>
        </body>
        </html>
        """
    }
    
    private func escapeForJS(_ string: String) -> String {
        string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")
    }
}

// MARK: - WebView

private struct WebView: NSViewRepresentable {
    let html: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground") // Transparent background
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(html, baseURL: nil)
    }
}

// MARK: - Status Bar

private struct StatusBar: View {
    let note: Note
    let content: String
    let wordCount: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Label("\(wordCount) words", systemImage: "textformat")
            Divider().frame(height: 12)
            Text("\(content.count) characters")
            Divider().frame(height: 12)
            Text("\(content.components(separatedBy: .newlines).count) lines")
            
            Spacer()
            
            if !note.tags.isEmpty {
                Text("\(note.tags.count) tags")
                Divider().frame(height: 12)
            }
            
            Text("Updated \(note.modifiedDate.formatted(.relative(presentation: .named)))")
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    HybridEditorView(note: Note(
        title: "Sample Note",
        content: """
        # Welcome to Scribe
        
        This is a **hybrid editor** with live preview.
        
        ## Math Support
        
        Inline math: $E = mc^2$
        
        Display math:
        $$
        \\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}
        $$
        
        ## Code
        
        ```swift
        func hello() {
            print("Hello, World!")
        }
        ```
        
        ## Links
        
        - [[Another Note]]
        - [External Link](https://example.com)
        """
    ))
    .environmentObject(AppState())
    .frame(width: 1000, height: 700)
}
