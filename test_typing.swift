import SwiftUI

@main
struct TestTypingApp: App {
    var body: some Scene {
        WindowGroup {
            TestTypingView()
        }
    }
}

struct TestTypingView: View {
    @State private var text = ""

    var body: some View {
        VStack {
            Text("Test Typing")
                .font(.largeTitle)

            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .frame(height: 200)
                .padding()

            Text("Typed: \(text.count) characters")
                .foregroundColor(.secondary)
        }
        .frame(width: 600, height: 400)
    }
}
