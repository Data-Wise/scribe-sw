import SwiftUI
import AppKit

/// ADHD-friendly error/warning dialog
/// - Auto-dismisses after 30 seconds
/// - Copy to clipboard button for easy bug reporting
/// - Clear OK button for immediate dismissal
struct ErrorDialog: View {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let level: Level
    
    /// Countdown timer for auto-dismiss
    @State private var secondsRemaining: Int = 30
    @State private var timer: Timer?
    
    enum Level {
        case warning
        case error
        
        var color: Color {
            switch self {
            case .warning: return ScribeColors.warning
            case .error: return ScribeColors.error
            }
        }
        
        var icon: String {
            switch self {
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.octagon.fill"
            }
        }
        
        var label: String {
            switch self {
            case .warning: return "Warning"
            case .error: return "Error"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ScribeSpacing.md) {
            // Header
            HStack(spacing: ScribeSpacing.sm) {
                Image(systemName: level.icon)
                    .font(.system(size: 20))
                    .foregroundColor(level.color)
                
                Text(title)
                    .font(ScribeFonts.uiTitle)
                    .foregroundColor(ScribeColors.textPrimary)
                
                Spacer()
                
                // Countdown badge
                Text("\(secondsRemaining)s")
                    .font(ScribeFonts.uiCaption)
                    .foregroundColor(ScribeColors.textTertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(ScribeColors.border.opacity(0.5))
                    .cornerRadius(4)
            }
            
            // Message
            ScrollView {
                Text(message)
                    .font(ScribeFonts.uiBody)
                    .foregroundColor(ScribeColors.textSecondary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 150)
            
            // Buttons
            HStack(spacing: ScribeSpacing.sm) {
                Button(action: copyToClipboard) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy")
                    }
                }
                .buttonStyle(.bordered)
                .tint(ScribeColors.textSecondary)
                
                Spacer()
                
                Button("OK") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(level.color)
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding(ScribeSpacing.lg)
        .frame(width: 400)
        .background(ScribeColors.surface)
        .cornerRadius(ScribeLayout.cornerRadius)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Actions
    
    private func copyToClipboard() {
        let fullText = """
        [\(level.label.uppercased())] \(title)
        
        \(message)
        
        ---
        Scribe v0.1.0-dev | \(Date())
        """
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(fullText, forType: .string)
    }
    
    private func dismiss() {
        stopTimer()
        withAnimation(.easeOut(duration: 0.2)) {
            isPresented = false
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                dismiss()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - View Extension for Easy Use

extension View {
    /// Show error dialog overlay
    func errorDialog(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        level: ErrorDialog.Level = .error
    ) -> some View {
        self.overlay {
            if isPresented.wrappedValue {
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // Don't dismiss on background tap - too easy to lose
                        }
                    
                    ErrorDialog(
                        isPresented: isPresented,
                        title: title,
                        message: message,
                        level: level
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                .animation(.spring(response: 0.3), value: isPresented.wrappedValue)
            }
        }
    }
}

// MARK: - Preview

#Preview("Error Dialog") {
    ZStack {
        Color(ScribeColors.background)
        
        ErrorDialog(
            isPresented: .constant(true),
            title: "Database Error",
            message: "Failed to save note: SQLite error 19 - UNIQUE constraint failed: notes.id\n\nThis usually happens when trying to create a note with a duplicate ID. Please try again.",
            level: .error
        )
    }
}

#Preview("Warning Dialog") {
    ZStack {
        Color(ScribeColors.background)
        
        ErrorDialog(
            isPresented: .constant(true),
            title: "Sync Warning",
            message: "Unable to reach sync server. Your changes will be saved locally.",
            level: .warning
        )
    }
}
