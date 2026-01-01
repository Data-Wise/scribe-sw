import SwiftUI
import WebKit

struct CodeMirrorEditorView: View {
    @Binding var content: String
    @State private var isReady = false

    var body: some View {
        CodeMirrorWebView(content: $content, isReady: $isReady)
            .background(Color(.textBackgroundColor))
    }
}

private struct CodeMirrorWebView: NSViewRepresentable {
    @Binding var content: String
    @Binding var isReady: Bool

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()

        // Create preferences
        let preferences = WKPreferences()
        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        preferences.setValue(true, forKey: "developerExtrasEnabled")
        config.preferences = preferences

        // Register bridge
        controller.add(context.coordinator, name: "scribeBridge")
        controller.add(context.coordinator, name: "consoleLog")
        config.userContentController = controller

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground") // Transparent background

        // Load local HTML file
        var url: URL

        // Try Bundle.main first
        if let mainBundleUrl = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "codemirror") {
            url = mainBundleUrl
            print("CodeMirror: Loading from Bundle.main: \(url.path)")
        } else {
            // Get bundle and search manually
            let bundleURL = Bundle.main.bundleURL
            let codemirrorURL = bundleURL.appendingPathComponent("codemirror").appendingPathComponent("index.html")
            if FileManager.default.fileExists(atPath: codemirrorURL.path) {
                url = codemirrorURL
                print("CodeMirror: Loading from bundle path: \(url.path)")
            } else {
                // Last resort - absolute path to build artifact
                url = URL(fileURLWithPath: "/Users/dt/projects/dev-tools/scribe-sw/.build/arm64-apple-macosx/debug/Scribe_Scribe.bundle/codemirror/index.html")
                print("CodeMirror: Loading from absolute build path: \(url.path)")
            }
        }

        print("CodeMirror: Final URL: \(url.path)")
        print("CodeMirror: File exists: \(FileManager.default.fileExists(atPath: url.path))")
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())

        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Sync Swift -> JS (only if ready and content changed externally)
        if isReady && context.coordinator.lastSentContent != content {
            context.coordinator.lastSentContent = content
            let js = "window.setMarkdown(`\(CodeMirrorWebView.escapeForJS(content))`);"
            nsView.evaluateJavaScript(js)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: CodeMirrorWebView
        var lastSentContent: String = ""
        var isReady: Bool = false

        init(_ parent: CodeMirrorWebView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "consoleLog" {
                print("CM6 Console: \(message.body)")
                return
            }

            guard let dict = message.body as? [String: Any],
                  let type = dict["type"] as? String else { return }

            // print("CodeMirror: Received message of type \(type)")

            switch type {
            case "EDITOR_READY":
                DispatchQueue.main.async {
                    self.parent.isReady = true
                    self.isReady = true
                    print("CodeMirror: Editor ready, sending initial content")
                }

                // Send initial content
                let js = "window.setMarkdown(`\(CodeMirrorWebView.escapeForJS(parent.content))`);"
                message.webView?.evaluateJavaScript(js)
                self.lastSentContent = parent.content

            case "UPDATE_CONTENT":
                if let newContent = dict["content"] as? String {
                    // Update Swift binding without triggering a loop
                    if newContent != parent.content {
                        lastSentContent = newContent
                        DispatchQueue.main.async {
                            self.parent.content = newContent
                        }
                    }
                }
            default:
                break
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("CodeMirror: WebView did finish navigation")

            // Check bridge status
            webView.evaluateJavaScript("typeof window.webkit") { result, error in
                if let type = result as? String {
                    print("CodeMirror: window.webkit is \(type)")
                }
                if let error = error {
                    print("CodeMirror: JS Check Error: \(error)")
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("CodeMirror: WebView failed navigation: \(error.localizedDescription)")
        }
    }

    static func escapeForJS(_ string: String) -> String {
        string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")
    }
}
