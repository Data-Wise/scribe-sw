import SwiftUI
import WebKit

struct LexicalEditorView: View {
    @Binding var content: String
    @State private var isReady = false
    
    var body: some View {
        LexicalWebView(content: $content, isReady: $isReady)
            .background(Color(.textBackgroundColor))
    }
}

private struct LexicalWebView: NSViewRepresentable {
    @Binding var content: String
    @Binding var isReady: Bool
    
    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        
        // Register the bridge
        controller.add(context.coordinator, name: "scribeBridge")
        controller.add(context.coordinator, name: "consoleLog")
        config.userContentController = controller
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        // Load the local HTML file
        let url: URL
        if let moduleUrl = Bundle.module.url(forResource: "index", withExtension: "html", subdirectory: "lexical") {
            url = moduleUrl
        } else {
            // Fallback for development if Bundle.module is not available or fails
            url = URL(fileURLWithPath: "/Users/dt/projects/dev-tools/scribe-sw/Resources/lexical/index.html")
        }
        
        print("LexicalEditor: [v3] Loading URL: \(url.path)")
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Sync Swift -> JS (only if ready and content changed externally)
        if isReady && context.coordinator.lastSentContent != content {
            context.coordinator.lastSentContent = content
            let js = "window.setMarkdown(`\(LexicalWebView.escapeForJS(content))`);"
            nsView.evaluateJavaScript(js)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: LexicalWebView
        var lastSentContent: String = ""
        
        init(_ parent: LexicalWebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "consoleLog" {
                print("JS Console: \(message.body)")
                return
            }
            
            guard let dict = message.body as? [String: Any],
                  let type = dict["type"] as? String else { return }
            
            print("LexicalEditor: Received message of type \(type)")
            
            switch type {
            case "EDITOR_READY":
                parent.isReady = true
                print("LexicalEditor: Editor ready, sending initial content")
                // Send initial content
                let js = "window.setMarkdown(`\(LexicalWebView.escapeForJS(parent.content))`);"
                message.webView?.evaluateJavaScript(js)
            case "UPDATE_CONTENT":
                if let newContent = dict["content"] as? String {
                    lastSentContent = newContent
                    parent.content = newContent
                }
            default:
                break
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("LexicalEditor: WebView did finish navigation")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("LexicalEditor: WebView failed navigation: \(error.localizedDescription)")
        }
    }
    
    static func escapeForJS(_ string: String) -> String {
        string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")
    }
}
