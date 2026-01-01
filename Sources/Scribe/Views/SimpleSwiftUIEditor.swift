import SwiftUI

struct SimpleSwiftUIEditor: View {
    @Binding var content: String

    var body: some View {
        TextEditor(text: $content)
            .font(.system(.body, design: .monospaced))
            .lineSpacing(4)
            .padding(16)
            .background(Color(.textBackgroundColor))
    }
}
