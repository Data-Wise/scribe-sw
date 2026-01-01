import SwiftUI
import Combine

/// Distraction-free markdown editor
/// Focus Mode: Just title + content, no chrome
struct EditorView: View {
    @EnvironmentObject var appState: AppState

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var saveTask: Task<Void, Never>?

    // Focus management - use enum to track which field has focus
    enum Field: Hashable {
        case title
        case content
    }
    @FocusState private var focusedField: Field?

    // Debounce delay for auto-save (1 second)
    private let saveDelay: TimeInterval = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title field
            TextField("Untitled", text: $title)
                .font(ScribeFonts.noteTitle)
                .foregroundColor(ScribeColors.textPrimary)
                .textFieldStyle(.plain)
                .focused($focusedField, equals: .title)
                .padding(.horizontal, ScribeSpacing.xxl)
                .padding(.top, ScribeSpacing.lg)
                .padding(.bottom, ScribeSpacing.md)
                .onSubmit {
                    // Move focus to content editor when pressing Enter on title
                    focusedField = .content
                }
                .onChange(of: title) { _, newValue in
                    scheduleAutoSave()
                }

            // Content editor
            TextEditor(text: $content)
                .font(ScribeFonts.editor)
                .foregroundColor(ScribeColors.textPrimary)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, ScribeSpacing.xxl - 5) // Account for TextEditor internal padding
                .focused($focusedField, equals: .content)
                .onChange(of: content) { _, newValue in
                    scheduleAutoSave()
                }

            Spacer(minLength: 0)
        }
        .background(ScribeColors.background)
        .onAppear {
            loadCurrentNote()
            // Auto-focus content editor after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedField = .content
            }
        }
        .onChange(of: appState.selectedNoteId) { _, _ in
            loadCurrentNote()
            // Focus content when switching notes
            focusedField = .content
        }
    }

    // MARK: - Data Operations

    private func loadCurrentNote() {
        guard let noteId = appState.selectedNoteId,
              let note = appState.notes.first(where: { $0.id == noteId }) else {
            title = ""
            content = ""
            return
        }

        title = note.title
        content = note.content
    }

    private func scheduleAutoSave() {
        // Cancel any pending save
        saveTask?.cancel()

        // Schedule new save with debounce
        saveTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(saveDelay * 1_000_000_000))

            guard !Task.isCancelled else { return }

            await saveCurrentNote()
        }
    }

    private func saveCurrentNote() async {
        guard let noteId = appState.selectedNoteId,
              var note = appState.notes.first(where: { $0.id == noteId }) else {
            return
        }

        // Update note with current values
        note.title = title.isEmpty ? "Untitled" : title
        note.content = content
        note.wordCount = calculateWordCount(content)
        note.updatedAt = Date().unixTimestamp

        appState.saveNote(note)
    }

    private func calculateWordCount(_ text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return words.count
    }
}

// MARK: - Preview

#Preview {
    EditorView()
        .frame(width: 800, height: 600)
        .environmentObject(AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        ))
}
