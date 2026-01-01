import Foundation

/// Debounce utility for throttling operations
@MainActor
final class Debouncer {
    private var task: Task<Void, Never>?
    private let delay: TimeInterval
    
    init(delay: TimeInterval = 0.3) {
        self.delay = delay
    }
    
    func debounce(_ action: @escaping () async -> Void) {
        task?.cancel()
        
        task = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            
            await action()
        }
    }
    
    func cancel() {
        task?.cancel()
        task = nil
    }
}
