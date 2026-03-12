import SwiftUI

/// "Legacy" — profile, achievements, and settings
struct ProfileView: View {
    @EnvironmentObject var gameState: GameState
    @AppStorage("onboardingDone") private var onboardingDone = false
    @State private var showResetAlert = false
    @State private var showGlossary = false

    private let avatarIcons = ["fish.fill", "tortoise.fill", "hare.fill", "ant.fill", "ladybug.fill", "leaf.fill"]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Legacy")
                    .font(FLFont.display(28))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)

                profileCard
                glossarySection
                achievementsSection
                settingsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .fullScreenCover(isPresented: $showGlossary) {
            GlossaryView()
                .environmentObject(gameState)
        }
        .alert("Reset All Progress?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { resetProgress() }
        } message: {
            Text("This will erase all your XP, streaks, lesson progress, and achievements. This cannot be undone.")
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        GlassmorphicCard {
            VStack(spacing: 16) {
                // Avatar & Name
                Button {
                    gameState.handleProfileTap()
                } label: {
                    ZStack {
                        HexagonShape()
                            .fill(FLColor.glassFill)
                            .frame(width: 80, height: 80)
                        HexagonShape()
                            .stroke(FLColor.biolumGradient, lineWidth: 2)
                            .frame(width: 80, height: 80)
                        Image(systemName: currentAvatarIcon)
                            .font(.largeTitle)
                            .foregroundStyle(FLColor.biolumGradient)
                    }
                }
                .buttonStyle(.plain)

                Text(gameState.userName.isEmpty ? "Explorer" : gameState.userName)
                    .font(FLFont.display(22))
                    .foregroundColor(.white)

                Text(gameState.currentLevelName)
                    .font(FLFont.mono(14))
                    .foregroundColor(FLColor.biolumCyan)

                // Stats Row
                HStack(spacing: 24) {
                    profileStat(value: "\(gameState.totalXP)", label: "XP")
                    divider
                    profileStat(value: "\(gameState.streakCount)", label: "Streak")
                    divider
                    profileStat(value: "\(gameState.totalSessions)", label: "Sessions")
                    divider
                    profileStat(value: "\(completedLessons)", label: "Lessons")
                }

                if gameState.hiddenThemeUnlocked {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkle")
                            .foregroundColor(FLColor.moltenGold)
                        Text("Abyssal Theme Unlocked")
                            .font(FLFont.body(12))
                            .foregroundColor(FLColor.moltenGold)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(FLColor.moltenGold.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            .padding(20)
        }
    }

    private var currentAvatarIcon: String {
        let idx = min(gameState.avatarIndex, avatarIcons.count - 1)
        return avatarIcons[max(0, idx)]
    }

    private var completedLessons: Int {
        gameState.lessonStates.filter { $0.isCompleted }.count
    }

    private func profileStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(FLFont.mono(16))
                .foregroundColor(.white)
            Text(label)
                .font(FLFont.body(10))
                .foregroundColor(.white.opacity(0.4))
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(FLColor.glassStroke)
            .frame(width: 1, height: 30)
    }

    // MARK: - Glossary Section

    private var glossarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Knowledge Base")
                .font(FLFont.display(18))
                .foregroundColor(.white)

            Button {
                showGlossary = true
                HapticEngine.impact(.light)
            } label: {
                GlassmorphicCard {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(FLColor.moltenGold.opacity(0.15))
                                .frame(width: 48, height: 48)
                            Image(systemName: "character.book.closed.fill")
                                .font(.title2)
                                .foregroundColor(FLColor.moltenGold)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Glossary & Flashcards")
                                .font(FLFont.body(15))
                                .foregroundColor(.white)
                            HStack(spacing: 12) {
                                Label("\(GlossaryRepository.all.count) terms", systemImage: "text.book.closed")
                                    .font(FLFont.body(11))
                                    .foregroundColor(.white.opacity(0.5))
                                Label("\(gameState.flashcardSessions) sessions", systemImage: "rectangle.on.rectangle.angled")
                                    .font(FLFont.body(11))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .padding(14)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Achievements Section

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(FLFont.display(18))
                .foregroundColor(.white)

            ForEach(gameState.achievements) { ach in
                achievementRow(ach)
            }
        }
    }

    private func achievementRow(_ ach: AchievementProgress) -> some View {
        GlassmorphicCard(topRightCut: 14, bottomLeftCut: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(ach.isUnlocked ? ach.rarity.color.opacity(0.2) : Color.white.opacity(0.05))
                        .frame(width: 44, height: 44)
                    if ach.isUnlocked {
                        Circle()
                            .stroke(ach.rarity.color, lineWidth: 1.5)
                            .frame(width: 44, height: 44)
                    }
                    Image(systemName: ach.isUnlocked ? "trophy.fill" : "lock.fill")
                        .foregroundColor(ach.isUnlocked ? ach.rarity.color : .white.opacity(0.2))
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(ach.title)
                            .font(FLFont.body(15))
                            .foregroundColor(ach.isUnlocked ? .white : .white.opacity(0.4))
                        Text(ach.rarity.rawValue.uppercased())
                            .font(FLFont.body(9))
                            .foregroundColor(ach.rarity.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(ach.rarity.color.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    Text(ach.description)
                        .font(FLFont.body(12))
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()

                if ach.isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(FLColor.biolumGreen)
                }
            }
            .padding(12)
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(FLFont.display(18))
                .foregroundColor(.white)

            GlassmorphicCard {
                VStack(spacing: 0) {
                    settingsRow(icon: "calendar", title: "Weekly Goal", detail: "\(gameState.daysPerWeekGoal) days")
                    Divider().background(FLColor.glassStroke)
                    settingsRow(icon: "bolt.shield", title: "Streak Freeze", detail: gameState.streakFreezeActive ? "Active" : "Inactive")
                    Divider().background(FLColor.glassStroke)
                    settingsRow(icon: "trophy", title: "Longest Streak", detail: "\(gameState.longestStreak) days")
                    Divider().background(FLColor.glassStroke)

                    Button {
                        showResetAlert = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(FLColor.biolumPink)
                            Text("Reset All Progress")
                                .font(FLFont.body(14))
                                .foregroundColor(FLColor.biolumPink)
                            Spacer()
                        }
                        .padding(14)
                    }
                }
            }
        }
    }

    private func settingsRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(FLColor.biolumGradient)
                .frame(width: 24)
            Text(title)
                .font(FLFont.body(14))
                .foregroundColor(.white)
            Spacer()
            Text(detail)
                .font(FLFont.mono(13))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(14)
    }

    // MARK: - Reset

    private func resetProgress() {
        gameState.totalXP = 0
        gameState.currentLevel = 0
        gameState.streakCount = 0
        gameState.longestStreak = 0
        gameState.lastActiveDate = 0
        gameState.totalSessions = 0
        gameState.profileTapCount = 0
        gameState.hiddenThemeUnlocked = false
        gameState.streakFreezeActive = false
        gameState.gauntletRuns = 0
        gameState.gauntletBestScore = 0
        gameState.gauntletTotalCorrect = 0
        gameState.gauntletTotalAnswered = 0
        gameState.flashcardSessions = 0
        gameState.flashcardTotalReviewed = 0
        gameState.lessonStates = GameState.defaultLessonStates()
        gameState.achievements = GameState.defaultAchievements()

        // Clear flashcard states
        UserDefaults.standard.removeObject(forKey: "flashcardStates")

        // Clear CoreData logs
        let allLogs = CoreDataStack.shared.fetchLogs()
        for log in allLogs {
            CoreDataStack.shared.deleteLog(log)
        }

        HapticEngine.notification(.warning)
    }
}
