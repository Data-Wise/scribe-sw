import Foundation

/// EditorLauncher handles opening files in external editors
/// Priority: micro > $EDITOR > vim
enum EditorLauncher {
    /// Opens a file in the user's preferred editor
    static func openInEditor(_ filePath: String) throws {
        let editor = findEditor()
        
        print("📝 Opening in \(editor)...")
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [editor, filePath]
        
        // Important: inherit stdin/stdout so editor can interact with terminal
        process.standardInput = FileHandle.standardInput
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw ScribeError.unknown(NSError(domain: "ScribeCLI", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Editor exited with error"]))
        }
    }
    
    /// Finds the best available editor
    /// Priority: micro > $EDITOR > vim
    static func findEditor() -> String {
        if isCommandAvailable("micro") {
            return "micro"
        }
        
        if let editor = ProcessInfo.processInfo.environment["EDITOR"], !editor.isEmpty {
            return editor
        }
        
        return "vim"
    }
    
    /// Checks if a command is available in PATH
    static func isCommandAvailable(_ command: String) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [command]
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        
        try? process.run()
        process.waitUntilExit()
        
        return process.terminationStatus == 0
    }
}
