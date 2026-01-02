import Foundation

/// Writing statistics for ADHD-friendly progress feedback
/// Persisted via UserDefaults (not database)
struct WritingStats: Codable, Sendable {
    // MARK: - Session Tracking

    /// When the current writing session started
    var sessionStartTime: Date

    /// Total words written this session
    var sessionWordCount: Int

    // MARK: - Daily Tracking

    /// Words written today (resets at midnight)
    var todayWordCount: Int

    /// The date we're tracking "today" for
    var todayDate: Date

    // MARK: - Streak Tracking

    /// Consecutive days with writing activity
    var currentStreak: Int

    /// Last date user wrote something
    var lastWritingDate: Date?

    /// History of daily word counts (for streak calculation)
    var writingHistory: [String: Int]  // "YYYY-MM-DD": wordCount

    // MARK: - Constants

    /// Daily word goal (hardcoded for now, make configurable later)
    static let dailyGoal = 500

    // MARK: - Initialization

    init() {
        let now = Date()
        self.sessionStartTime = now
        self.sessionWordCount = 0
        self.todayWordCount = 0
        self.todayDate = Calendar.current.startOfDay(for: now)
        self.currentStreak = 0
        self.lastWritingDate = nil
        self.writingHistory = [:]
    }

    // MARK: - Computed Properties

    /// Session duration in seconds
    var sessionDuration: TimeInterval {
        Date().timeIntervalSince(sessionStartTime)
    }

    /// Formatted session duration (e.g., "12m" or "1h 23m")
    var sessionDurationFormatted: String {
        let minutes = Int(sessionDuration / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    /// Progress toward daily goal (0.0 to 1.0)
    var goalProgress: Double {
        min(Double(todayWordCount) / Double(Self.dailyGoal), 1.0)
    }

    /// Percentage string for goal (e.g., "75%")
    var goalProgressPercent: String {
        "\(Int(goalProgress * 100))%"
    }

    /// Words per minute this session
    var wordsPerMinute: Int {
        let minutes = sessionDuration / 60
        guard minutes > 0 else { return 0 }
        return Int(Double(sessionWordCount) / minutes)
    }

    /// Whether daily goal is complete
    var goalComplete: Bool {
        todayWordCount >= Self.dailyGoal
    }

    // MARK: - Mutations

    /// Record words written (call on each save)
    mutating func recordWords(count: Int, previousCount: Int) {
        let wordsAdded = max(0, count - previousCount)

        guard wordsAdded > 0 else { return }

        sessionWordCount += wordsAdded
        todayWordCount += wordsAdded
        lastWritingDate = Date()

        // Update history
        let dateKey = Self.dateKey(for: Date())
        writingHistory[dateKey] = todayWordCount
    }

    /// Start a new session (call on app launch)
    mutating func startNewSession() {
        sessionStartTime = Date()
        sessionWordCount = 0

        // Check if it's a new day
        let today = Calendar.current.startOfDay(for: Date())
        if today != todayDate {
            resetForNewDay()
        }

        calculateStreak()
    }

    /// Reset daily stats (called at midnight or new day detection)
    mutating func resetForNewDay() {
        todayDate = Calendar.current.startOfDay(for: Date())
        todayWordCount = 0
    }

    /// Calculate current streak from history
    mutating func calculateStreak() {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()

        // If we wrote today, start counting from today
        // Otherwise, start from yesterday
        let todayKey = Self.dateKey(for: checkDate)
        if writingHistory[todayKey] == nil || writingHistory[todayKey] == 0 {
            // No writing today yet, check if we wrote yesterday
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                currentStreak = 0
                return
            }
            checkDate = yesterday
        }

        // Count consecutive days with writing
        while true {
            let key = Self.dateKey(for: checkDate)
            if let count = writingHistory[key], count > 0 {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                    break
                }
                checkDate = previousDay
            } else {
                break
            }
        }

        currentStreak = streak
    }

    // MARK: - Helpers

    /// Generate date key for history dictionary
    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - UserDefaults Persistence

extension WritingStats {
    private static let userDefaultsKey = "writingStats"

    /// Save stats to UserDefaults
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        }
    }

    /// Load stats from UserDefaults
    static func load() -> WritingStats {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              var stats = try? JSONDecoder().decode(WritingStats.self, from: data) else {
            return WritingStats()
        }

        // Check if new day and reset if needed
        let today = Calendar.current.startOfDay(for: Date())
        if stats.todayDate != today {
            stats.resetForNewDay()
        }

        stats.calculateStreak()
        return stats
    }

    /// Clear all stats (for testing/reset)
    static func clear() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
