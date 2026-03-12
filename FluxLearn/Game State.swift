import SwiftUI
import Combine
import AudioToolbox

struct LessonState: Codable, Identifiable {
    let id: Int
    var isCompleted: Bool
    var isLocked: Bool
}

struct AchievementProgress: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let rarity: AchievementRarity
    var isUnlocked: Bool
    var progress: Double
}

enum AchievementRarity: String, Codable {
    case common, rare, legendary
    var color: Color {
        switch self {
        case .common: return .gray
        case .rare: return Color(red: 0.3, green: 0.5, blue: 1.0)
        case .legendary: return Color(red: 1.0, green: 0.85, blue: 0.3)
        }
    }
    var glow: Color {
        switch self {
        case .common: return .gray.opacity(0.4)
        case .rare: return Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.6)
        case .legendary: return Color(red: 1.0, green: 0.85, blue: 0.3).opacity(0.7)
        }
    }
}

class GameState: ObservableObject {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("totalXP") var totalXP: Int = 0
    @AppStorage("currentLevel") var currentLevel: Int = 0
    @AppStorage("streakCount") var streakCount: Int = 0
    @AppStorage("longestStreak") var longestStreak: Int = 0
    @AppStorage("lastActiveDate") var lastActiveDate: Double = 0
    @AppStorage("dailyGoalMinutes") var dailyGoalMinutes: Int = 10
    @AppStorage("skillTier") var skillTier: Int = 0
    @AppStorage("hiddenThemeUnlocked") var hiddenThemeUnlocked: Bool = false
    @AppStorage("streakFreezeActive") var streakFreezeActive: Bool = false
    @AppStorage("totalSessions") var totalSessions: Int = 0
    @AppStorage("avatarIndex") var avatarIndex: Int = 0
    @AppStorage("daysPerWeekGoal") var daysPerWeekGoal: Int = 5
    @AppStorage("profileTapCount") var profileTapCount: Int = 0
    @AppStorage("gauntletRuns") var gauntletRuns: Int = 0
    @AppStorage("gauntletBestScore") var gauntletBestScore: Int = 0
    @AppStorage("gauntletTotalCorrect") var gauntletTotalCorrect: Int = 0
    @AppStorage("gauntletTotalAnswered") var gauntletTotalAnswered: Int = 0
    @AppStorage("flashcardSessions") var flashcardSessions: Int = 0
    @AppStorage("flashcardTotalReviewed") var flashcardTotalReviewed: Int = 0

    @Published var showLevelUp = false
    @Published var newLevelName = ""
    @Published var showConfetti = false

    static let levelNames = [
        "Novice", "Apprentice", "Scholar", "Adept", "Expert",
        "Master", "Champion", "Legend", "Grandmaster", "Sage"
    ]
    static let thresholds = [0, 150, 350, 650, 1100, 1800, 2800, 4200, 6200, 10000]

    var currentLevelName: String {
        guard currentLevel < Self.levelNames.count else { return "Sage" }
        return Self.levelNames[currentLevel]
    }

    var xpToNextLevel: Int {
        let nextIdx = min(currentLevel + 1, Self.thresholds.count - 1)
        return max(0, Self.thresholds[nextIdx] - totalXP)
    }

    var levelProgress: Double {
        let currentThreshold = Self.thresholds[min(currentLevel, Self.thresholds.count - 1)]
        let nextThreshold = Self.thresholds[min(currentLevel + 1, Self.thresholds.count - 1)]
        let range = nextThreshold - currentThreshold
        guard range > 0 else { return 1.0 }
        return Double(totalXP - currentThreshold) / Double(range)
    }

    var streakTemperature: StreakTemp {
        switch streakCount {
        case 0...6: return .cold
        case 7...29: return .warm
        case 30...99: return .hot
        default: return .molten
        }
    }

    enum StreakTemp {
        case cold, warm, hot, molten
        var colors: [Color] {
            switch self {
            case .cold: return [Color(red: 0.4, green: 0.7, blue: 1.0), Color(red: 0.6, green: 0.85, blue: 1.0)]
            case .warm: return [Color(red: 0.95, green: 0.6, blue: 0.15), Color(red: 0.95, green: 0.45, blue: 0.15)]
            case .hot: return [Color(red: 1.0, green: 0.3, blue: 0.1), Color(red: 0.95, green: 0.15, blue: 0.05)]
            case .molten: return [Color(red: 1.0, green: 0.95, blue: 0.6), Color(red: 1.0, green: 0.85, blue: 0.3)]
            }
        }
        var icon: String {
            switch self {
            case .cold: return "snowflake"
            case .warm: return "flame"
            case .hot: return "flame.fill"
            case .molten: return "sparkles"
            }
        }
    }

    var lessonStates: [LessonState] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "lessonStates"),
                  let decoded = try? JSONDecoder().decode([LessonState].self, from: data)
            else { return Self.defaultLessonStates() }
            return decoded
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "lessonStates")
            }
            objectWillChange.send()
        }
    }

    var achievements: [AchievementProgress] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "achievements"),
                  let decoded = try? JSONDecoder().decode([AchievementProgress].self, from: data)
            else { return Self.defaultAchievements() }
            return decoded
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "achievements")
            }
            objectWillChange.send()
        }
    }

    func addXP(_ amount: Int) {
        totalXP += amount
        checkLevelUp()
    }

    func checkLevelUp() {
        var lvl = 0
        for i in 0..<Self.thresholds.count {
            if totalXP >= Self.thresholds[i] { lvl = i }
        }
        if lvl > currentLevel {
            currentLevel = lvl
            newLevelName = Self.levelNames[min(lvl, Self.levelNames.count - 1)]
            showLevelUp = true
            showConfetti = true
            HapticEngine.notification(.success)
            HapticEngine.impact(.heavy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { HapticEngine.impact(.heavy) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { HapticEngine.impact(.heavy) }
            AudioServicesPlaySystemSound(1016)
        }
    }

    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDate = Date(timeIntervalSince1970: lastActiveDate)
        let lastDay = calendar.startOfDay(for: lastDate)
        let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

        if diff == 1 {
            streakCount += 1
        } else if diff > 1 {
            if streakFreezeActive && diff == 2 {
                streakFreezeActive = false
            } else {
                streakCount = 1
            }
        } else if diff == 0 {
            return
        }

        longestStreak = max(longestStreak, streakCount)
        lastActiveDate = today.timeIntervalSince1970
        addXP(5)

        if streakCount == 3 { addXP(50) }
        if streakCount == 10 { addXP(250) }
        if streakCount == 30 { addXP(600) }

        if currentLevel >= 4 && !streakFreezeActive {
            streakFreezeActive = true
        }

        // Auto-unlock achievements on daily login
        checkAutoAchievements()
    }

    func checkAutoAchievements() {
        var achs = achievements
        var changed = false

        // Daily login
        if let idx = achs.firstIndex(where: { $0.id == "daily_login" && !$0.isUnlocked }) {
            achs[idx].isUnlocked = true
            achs[idx].progress = 1.0
            changed = true
        }

        // 7-day streak
        if streakCount >= 7, let idx = achs.firstIndex(where: { $0.id == "week_streak" && !$0.isUnlocked }) {
            achs[idx].isUnlocked = true
            achs[idx].progress = 1.0
            changed = true
            HapticEngine.notification(.success)
        }

        // 1000 XP milestone
        if totalXP >= 1000, let idx = achs.firstIndex(where: { $0.id == "thousand_xp" && !$0.isUnlocked }) {
            achs[idx].isUnlocked = true
            achs[idx].progress = 1.0
            changed = true
            HapticEngine.notification(.success)
        }

        // All beginner lessons completed (IDs 0–4)
        let beginnerIDs = [0, 1, 2, 3, 4]
        let states = lessonStates
        let allBeginnerDone = beginnerIDs.allSatisfy { id in
            id < states.count && states[id].isCompleted
        }
        if allBeginnerDone, let idx = achs.firstIndex(where: { $0.id == "all_beginner" && !$0.isUnlocked }) {
            achs[idx].isUnlocked = true
            achs[idx].progress = 1.0
            changed = true
            HapticEngine.notification(.success)
        }

        // 5 quizzes (track via totalSessions as proxy — each lesson completion = 1 session)
        if totalSessions >= 5, let idx = achs.firstIndex(where: { $0.id == "five_quizzes" && !$0.isUnlocked }) {
            achs[idx].isUnlocked = true
            achs[idx].progress = 1.0
            changed = true
            HapticEngine.notification(.success)
        }

        // Update progress for incomplete achievements
        if let idx = achs.firstIndex(where: { $0.id == "week_streak" && !$0.isUnlocked }) {
            achs[idx].progress = min(1.0, Double(streakCount) / 7.0)
            changed = true
        }
        if let idx = achs.firstIndex(where: { $0.id == "thousand_xp" && !$0.isUnlocked }) {
            achs[idx].progress = min(1.0, Double(totalXP) / 1000.0)
            changed = true
        }
        if let idx = achs.firstIndex(where: { $0.id == "five_quizzes" && !$0.isUnlocked }) {
            achs[idx].progress = min(1.0, Double(totalSessions) / 5.0)
            changed = true
        }

        // Flashcard achievements
        if flashcardTotalReviewed >= 50, let idx = achs.firstIndex(where: { $0.id == "lexicon_apprentice" && !$0.isUnlocked }) {
            achs[idx].isUnlocked = true
            achs[idx].progress = 1.0
            changed = true
            HapticEngine.notification(.success)
        }
        if flashcardSessions >= 10, let idx = achs.firstIndex(where: { $0.id == "memory_master" && !$0.isUnlocked }) {
            achs[idx].isUnlocked = true
            achs[idx].progress = 1.0
            changed = true
            HapticEngine.notification(.success)
        }
        if flashcardTotalReviewed >= 200, let idx = achs.firstIndex(where: { $0.id == "walking_encyclopedia" && !$0.isUnlocked }) {
            achs[idx].isUnlocked = true
            achs[idx].progress = 1.0
            changed = true
            HapticEngine.notification(.success)
        }

        // Flashcard progress tracking
        if let idx = achs.firstIndex(where: { $0.id == "lexicon_apprentice" && !$0.isUnlocked }) {
            achs[idx].progress = min(1.0, Double(flashcardTotalReviewed) / 50.0)
            changed = true
        }
        if let idx = achs.firstIndex(where: { $0.id == "memory_master" && !$0.isUnlocked }) {
            achs[idx].progress = min(1.0, Double(flashcardSessions) / 10.0)
            changed = true
        }
        if let idx = achs.firstIndex(where: { $0.id == "walking_encyclopedia" && !$0.isUnlocked }) {
            achs[idx].progress = min(1.0, Double(flashcardTotalReviewed) / 200.0)
            changed = true
        }

        if changed {
            achievements = achs
        }
    }

    func completeLesson(_ id: Int) {
        var states = lessonStates
        guard id < states.count, !states[id].isCompleted else { return }
        states[id].isCompleted = true
        if id + 1 < states.count {
            states[id + 1].isLocked = false
        }
        lessonStates = states
        addXP(100)
        totalSessions += 1
        CoreDataStack.shared.saveLog(category: "lesson", score: 1, maxScore: 1, xp: 100, seconds: 0)
    }

    func handleProfileTap() {
        profileTapCount += 1
        if profileTapCount >= 7 && !hiddenThemeUnlocked {
            hiddenThemeUnlocked = true
            var achs = achievements
            if let idx = achs.firstIndex(where: { $0.id == "easter_egg" }) {
                achs[idx].isUnlocked = true
                achs[idx].progress = 1.0
            }
            achievements = achs
            HapticEngine.notification(.success)
        }
    }

    static func defaultLessonStates() -> [LessonState] {
        (0..<14).map { LessonState(id: $0, isCompleted: false, isLocked: $0 != 0) }
    }

    static func defaultAchievements() -> [AchievementProgress] {
        [
            AchievementProgress(id: "first_lesson", title: "First Tick", description: "Complete your first lesson", rarity: .common, isUnlocked: false, progress: 0),
            AchievementProgress(id: "five_quizzes", title: "Quiz Adept", description: "Complete 5 quizzes", rarity: .common, isUnlocked: false, progress: 0),
            AchievementProgress(id: "daily_login", title: "Timekeeper", description: "Log in today", rarity: .common, isUnlocked: false, progress: 0),
            AchievementProgress(id: "share_score", title: "Herald", description: "Share your score", rarity: .common, isUnlocked: false, progress: 0),
            AchievementProgress(id: "week_streak", title: "Temporal Flow", description: "7-day streak", rarity: .rare, isUnlocked: false, progress: 0),
            AchievementProgress(id: "all_beginner", title: "Clockwork Mind", description: "Complete all beginner lessons", rarity: .rare, isUnlocked: false, progress: 0),
            AchievementProgress(id: "perfect_quiz", title: "Chronos Precision", description: "100% on a quiz", rarity: .rare, isUnlocked: false, progress: 0),
            AchievementProgress(id: "thousand_xp", title: "Millennium", description: "Earn 1000 XP", rarity: .rare, isUnlocked: false, progress: 0),
            AchievementProgress(id: "perfect_gauntlet", title: "Flawless Run", description: "Score 100% on a Gauntlet", rarity: .rare, isUnlocked: false, progress: 0),
            AchievementProgress(id: "gauntlet_veteran", title: "Gauntlet Veteran", description: "Complete 10 Gauntlet runs", rarity: .rare, isUnlocked: false, progress: 0),
            AchievementProgress(id: "extreme_survivor", title: "Extreme Survivor", description: "Survive an Extreme Gauntlet", rarity: .legendary, isUnlocked: false, progress: 0),
            AchievementProgress(id: "lexicon_apprentice", title: "Lexicon Apprentice", description: "Review 50 flashcards", rarity: .common, isUnlocked: false, progress: 0),
            AchievementProgress(id: "memory_master", title: "Memory Master", description: "Complete 10 flashcard sessions", rarity: .rare, isUnlocked: false, progress: 0),
            AchievementProgress(id: "walking_encyclopedia", title: "Walking Encyclopedia", description: "Review 200 flashcards", rarity: .legendary, isUnlocked: false, progress: 0),
            AchievementProgress(id: "easter_egg", title: "Abyssal Secret", description: "Discover the hidden realm", rarity: .legendary, isUnlocked: false, progress: 0),
        ]
    }
}
