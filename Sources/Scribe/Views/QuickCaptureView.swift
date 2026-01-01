import SwiftUI

/// Quick capture floating window for rapid note taking
struct QuickCaptureView: View {
    @EnvironmentObject var appState: AppState
    @State private var title = ""
    @State private var content = ""
    @State private var selectedProjectId: String?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Quick Capture")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }

            Divider()

            // Title
            TextField("Note title...", text: $title)
                .textFieldStyle(.roundedBorder)

            // Content
            TextEditor(text: $content)
                .font(.body)
                .frame(height: 200)
                .border(Color.secondary.opacity(0.2))

            // Project picker
            HStack {
                Text("Project:")
                Picker("Project", selection: $selectedProjectId) {
                    Text("Inbox").tag(nil as String?)
                    ForEach(appState.projects) { project in
                        Label(project.name, systemImage: project.type.systemImage)
                            .tag(project.id as String?)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 150)

                Spacer()

                // Save button
                Button(action: saveCapture) {
                    Label("Save", systemImage: "checkmark")
                }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .frame(width: 500)
    }

    private func saveCapture() {
        Task {
            await appState.createNewNote()
            dismiss()
        }
    }
}

#Preview {
    QuickCaptureView()
        .environmentObject(AppState())
}
