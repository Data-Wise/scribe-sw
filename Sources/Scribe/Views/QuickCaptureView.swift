import SwiftUI

/// Quick capture floating window for rapid note taking
struct QuickCaptureView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var selectedVaultId: UUID?
    @FocusState private var isTextFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.orange)
                Text("Quick Capture")
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(.windowBackgroundColor))

            Divider()

            // Text area
            TextEditor(text: $text)
                .font(.system(size: 14))
                .scrollContentBackground(.hidden)
                .padding(12)
                .focused($isTextFocused)

            Divider()

            // Footer
            HStack {
                // Vault picker
                Picker("Vault", selection: $selectedVaultId) {
                    Text("Inbox").tag(nil as UUID?)
                    ForEach(appState.vaults) { vault in
                        Label(vault.name, systemImage: vault.type.icon)
                            .tag(vault.id as UUID?)
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
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(.windowBackgroundColor))
        }
        .frame(width: 400, height: 250)
        .onAppear {
            isTextFocused = true
        }
    }

    private func saveCapture() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        // Extract title from first line
        let lines = trimmedText.components(separatedBy: "\n")
        let title = lines.first?.prefix(50).trimmingCharacters(in: .whitespaces) ?? "Quick Note"

        let page = Page(
            id: UUID(),
            vaultId: selectedVaultId,
            title: String(title),
            content: trimmedText,
            createdAt: Date(),
            updatedAt: Date()
        )

        appState.pages.append(page)
        text = ""
        dismiss()
    }
}

#Preview {
    QuickCaptureView()
        .environmentObject(AppState())
}
