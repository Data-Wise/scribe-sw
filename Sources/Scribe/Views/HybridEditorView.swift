import SwiftUI
import WebKit

/// Hybrid editor with source/preview split view
struct HybridEditorView: View {
    enum EditorMode: String, CaseIterable {
        case markdown = "Edit"
        case split = "Split"
        case preview = "Read"
        
        var icon: String {
            switch self {
            case .markdown: return "square.fill.text.grid.1x2"
            case .split: return "square.split.2x1"
            case .preview: return "book"
            }
        }
    }
    
    let note: Note
    @EnvironmentObject var appState: AppState
    
    @State private var content: String
    @State private var title: String
    @AppStorage("editorMode_v2") private var mode: EditorMode = .markdown
    @State private var showRightSidebar = true
    @State private var isFocusMode = false
    @FocusState private var isEditorFocused: Bool
    @State private var cursorPosition: Int = 0
    
    // Autocomplete State
    @State private var showTagAutocomplete = false
    @State private var tagQuery = ""
    @State private var showWikiLinkAutocomplete = false
    @State private var wikiLinkQuery = ""
    @State private var showCitationAutocomplete = false
    @State private var citationQuery = ""
    
    init(note: Note) {
        self.note = note
        _content = State(initialValue: note.content)
        _title = State(initialValue: note.title)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Main editor
            VStack(spacing: 0) {
                if !isFocusMode {
                    // Enhanced Title Bar with Mode Pill
                    TitleBar(title: $title, mode: $mode, note: note)
                    
                    Divider()
                }
                
                // Editor content area
                ZStack(alignment: .topLeading) {
                    Group {
                        switch mode {
                        case .markdown:
                            CodeMirrorEditorView(content: $content)
                                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .opacity))
                        case .split:
                            HStack(spacing: 0) {
                                CodeMirrorEditorView(content: $content)
                                Divider()
                                MarkdownPreview(content: content)
                            }
                            .transition(.opacity)
                        case .preview:
                            MarkdownPreview(content: content)
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: mode)
                    
                    // Autocomplete overlays
                    if showTagAutocomplete {
                        TagAutocompleteView(tags: filteredTags) { tag in
                            insertTag(tag)
                        }
                        .offset(x: 20, y: 20)
                    }
                    
                    if showWikiLinkAutocomplete {
                        WikiLinkAutocomplete(
                            suggestions: filteredSuggestions
                        )
                        .environmentObject(appState)
                        .offset(x: 20, y: 20)
                    }
                    
                    if showCitationAutocomplete {
                        CitationAutocomplete(citations: appState.filteredCitations(query: citationQuery)) { citation in
                            insertCitation(citation.id)
                        }
                        .offset(x: 20, y: 20)
                    }
                }
                
                if !isFocusMode {
                    Divider()
                    
                    // Clustered Status Bar
                    StatusBar(note: note, content: content, wordCount: wordCount)
                }
            }
            
            // Right sidebar
            if showRightSidebar && !isFocusMode {
                Divider()
                RightSidebar(note: note)
                    .accessibilityIdentifier("Right Sidebar")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showRightSidebar.toggle()
                } label: {
                    Image(systemName: "sidebar.right")
                }
                .help("Toggle Sidebar (⌘⌥R)")
                .keyboardShortcut("r", modifiers: [.command, .option])
                
                Button {
                    isFocusMode.toggle()
                } label: {
                    Image(systemName: isFocusMode ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                }
                .help("Focus Mode (⌘⇧F)")
                .keyboardShortcut("f", modifiers: [.command, .shift])
                
                Menu {
                    Button("Bold", action: { insertMarkdown(prefix: "**", suffix: "**") })
                        .keyboardShortcut("b", modifiers: .command)
                    Button("Italic", action: { insertMarkdown(prefix: "*", suffix: "*") })
                        .keyboardShortcut("i", modifiers: .command)
                    Divider()
                    Button("Heading 1", action: { insertMarkdown(prefix: "# ", suffix: "") })
                    Button("Heading 2", action: { insertMarkdown(prefix: "## ", suffix: "") })
                } label: {
                    Image(systemName: "textformat")
                }
                .help("Formatting")
            }
        }
        .background(
            ZStack {
                Button("") { mode = .markdown }.keyboardShortcut("1", modifiers: .command).opacity(0)
                Button("") { mode = .split }.keyboardShortcut("2", modifiers: .command).opacity(0)
                Button("") { mode = .preview }.keyboardShortcut("3", modifiers: .command).opacity(0)
            }
        )
        .onChange(of: content) { _, newValue in
            detectTriggers(in: newValue)
            saveNote()
        }
        .onChange(of: content) { _, newValue in
            // Update cursor position to end on content change
            cursorPosition = newValue.count
        }
        .onChange(of: title) { _, newValue in
            saveNote()
        }
        .onAppear {
            isEditorFocused = true
            cursorPosition = 0
        }
    }
    
    private var wordCount: Int {
        content.split(separator: " ").count
    }
    
    private func detectTriggers(in text: String) {
        // Detect #tag
        if let lastWord = text.components(separatedBy: .whitespacesAndNewlines).last, lastWord.hasPrefix("#") {
            showTagAutocomplete = true
            tagQuery = String(lastWord.dropFirst())
        } else {
            showTagAutocomplete = false
        }
        
        // Detect [[wiki link
        if let lastBracket = text.range(of: "[[", options: .backwards) {
            let afterBracket = text[lastBracket.upperBound...]
            if !afterBracket.contains("]]") && !afterBracket.contains("\n") {
                showWikiLinkAutocomplete = true
                wikiLinkQuery = String(afterBracket)
            } else {
                showWikiLinkAutocomplete = false
            }
        } else {
            showWikiLinkAutocomplete = false
        }
        
        // Detect @cite
        if let lastAt = text.range(of: "@", options: .backwards) {
            let afterAt = text[lastAt.upperBound...]
            if !afterAt.contains(where: { $0.isWhitespace }) {
                showCitationAutocomplete = true
                citationQuery = String(afterAt)
            } else {
                showCitationAutocomplete = false
            }
        } else {
            showCitationAutocomplete = false
        }
    }
    
    private func saveNote() {
        var updatedNote = note
        updatedNote.title = title
        updatedNote.content = content
        appState.saveNote(updatedNote)
    }
    
    private func insertWikiLink(_ title: String) {
        // Find note by title
        guard let note = appState.notes.first(where: { $0.title == title && !$0.isDeleted }) else {
            return
        }
        
        let link = "[[\(title)]](\(note.id))"
        
        // Append link at cursor position (simple append for now)
        content += link
        
        // Trigger save
        if let currentNote = appState.notes.first(where: { $0.id == note.id }) {
            var updated = currentNote
            updated.content = content
            
            Task {
                appState.saveNote(updated)
            }
        }
    }
    
    // Autocomplete Logic
    
    private var filteredTags: [String] {
        appState.uniqueTags.filter { $0.lowercased().contains(tagQuery.lowercased()) || tagQuery.isEmpty }
    }
    
    // MARK: - Supporting Types

    private var filteredSuggestions: [WikiLinkSuggestion] {
        appState.notes.filter {
            $0.title.lowercased().contains(wikiLinkQuery.lowercased()) || wikiLinkQuery.isEmpty
        }.map { note in
            WikiLinkSuggestion(title: note.title, preview: note.preview, type: .note, noteId: note.id)
        }
    }

    private func insertTag(_ tag: String) {
        // Replace #query with tag
        let tagText = tag.hasPrefix("#") ? String(tag.dropFirst()) : tag
        insertText(tagText)
        showTagAutocomplete = false
    }

    private func insertCitation(_ key: String) {
        insertText(key)
        showCitationAutocomplete = false
    }

    private func insertMarkdown(prefix: String, suffix: String) {
        insertText(prefix + suffix)
    }

    private func insertText(_ text: String) {
        // Insert at cursor position
        let safePosition = min(cursorPosition, content.count)
        let index = content.index(content.startIndex, offsetBy: safePosition)
        content.insert(contentsOf: text, at: index)
        cursorPosition = safePosition + text.count
    }
}

// MARK: - Title Bar

private struct TitleBar: View {
    @Binding var title: String
    @Binding var mode: HybridEditorView.EditorMode
    let note: Note
    
    var body: some View {
        HStack {
            TextField("Untitled", text: $title)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .textFieldStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            
            Spacer()
            
            // Mode Pill - ADHD Friendly Segmented Control
            Picker("", selection: $mode) {
                ForEach(HybridEditorView.EditorMode.allCases, id: \.self) { mode in
                    Label(mode.rawValue, systemImage: mode.icon)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 280)
            .background(modeColor.opacity(0.1))
            .cornerRadius(8)
            .padding(.trailing, 20)
        }
        .background(Color(.windowBackgroundColor).opacity(0.5))
    }
    
    private var modeColor: Color {
        switch mode {
        case .markdown: return .blue
        case .split: return .purple
        case .preview: return .green
        }
    }
}

// MARK: - Source Editor View

// SourceEditorView removed

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
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    line-height: 1.5;
                    padding: 30px;
                    max-width: 100%;
                    margin: 0;
                    color: #1a1a1a;
                    font-size: 15px;
                }
                @media (prefers-color-scheme: dark) {
                    body {
                        background-color: #1a1a1a;
                        color: #e0e0e0;
                    }
                    a { color: #58a6ff; }
                }
                h1, h2, h3 { font-family: "New York", serif; font-weight: 700; color: accent; }
                code {
                    background-color: rgba(0,0,0,0.05);
                    padding: 2px 4px;
                    border-radius: 4px;
                    font-family: "SF Mono", monospace;
                    font-size: 0.85em;
                }
                @media (prefers-color-scheme: dark) {
                    code { background-color: rgba(255,255,255,0.1); }
                }
                pre {
                    background-color: rgba(0,0,0,0.03);
                    padding: 16px;
                    border-radius: 8px;
                    overflow-x: auto;
                }
                @media (prefers-color-scheme: dark) {
                    pre { background-color: #2d2d2d; }
                }
            </style>
        </head>
        <body>
            <div id="content"></div>
            <script>
                const markdown = `\(escapeForJS(content))`;
                marked.setOptions({ gfm: true, breaks: true });
                document.getElementById('content').innerHTML = marked.parse(markdown);
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
        webView.setValue(false, forKey: "drawsBackground")
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
        HStack(spacing: 0) {
            // Group 1: Context
            HStack(spacing: 8) {
                Image(systemName: "folder")
                    .font(.caption2)
                Text(note.folder)
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            
            Divider().frame(height: 16)
            
            // Group 2: Metrics (Center)
            Spacer()
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "textformat")
                    Text("\(wordCount) words")
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("\(readTime) min read")
                }
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.primary.opacity(0.8))
            Spacer()
            
            Divider().frame(height: 16)
            
            // Group 3: Status
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Text("🔥")
                    Text("7 day streak")
                }
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                
                Text("Synced")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
        }
        .frame(height: 32)
        .background(.ultraThinMaterial)
    }
    
    private var readTime: Int {
        max(1, wordCount / 200)
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
    .environmentObject(AppState(noteService: NoteService(database: DatabaseManager.shared), projectService: ProjectService(database: DatabaseManager.shared)))
    .frame(width: 1000, height: 700)
}
