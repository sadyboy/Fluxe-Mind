import SwiftUI
import CoreData

/// "Observatory" — statistics and performance history
struct StatsView: View {
    @EnvironmentObject var gameState: GameState
    @State private var logs: [NSManagedObject] = []

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Observatory")
                    .font(FLFont.display(28))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)

                overviewCards
                weeklyActivity
                recentActivity
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .onAppear { logs = CoreDataStack.shared.fetchLogs() }
    }

    // MARK: - Overview Cards

    private var overviewCards: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            statsCard(icon: "star.fill", title: "Total XP", value: "\(gameState.totalXP)", color: FLColor.moltenGold)
            statsCard(icon: "flame.fill", title: "Streak", value: "\(gameState.streakCount)d", color: FLColor.warmEmber)
            statsCard(icon: "book.closed.fill", title: "Sessions", value: "\(gameState.totalSessions)", color: FLColor.biolumCyan)
            statsCard(icon: "trophy.fill", title: "Level", value: gameState.currentLevelName, color: FLColor.biolumViolet)
        }
    }

    private func statsCard(icon: String, title: String, value: String, color: Color) -> some View {
        GlassmorphicCard {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    Spacer()
                }
                Text(value)
                    .font(FLFont.display(22))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(title)
                    .font(FLFont.body(11))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
        }
    }

    // MARK: - Weekly Activity

    private var weeklyActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(FLFont.display(18))
                .foregroundColor(.white)

            GlassmorphicCard {
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(0..<7, id: \.self) { dayOffset in
                        let dayLogs = logsForDayOffset(dayOffset)
                        let count = dayLogs.count
                        let maxHeight: CGFloat = 80
                        let barHeight = count > 0 ? max(12, maxHeight * CGFloat(min(count, 5)) / 5.0) : 4

                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(count > 0 ? FLColor.biolumGradient : LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                                .frame(width: 24, height: barHeight)

                            Text(dayLabel(dayOffset))
                                .font(FLFont.body(9))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(16)
            }
        }
    }

    private func logsForDayOffset(_ offset: Int) -> [NSManagedObject] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let targetDay = calendar.date(byAdding: .day, value: -(6 - offset), to: today) else { return [] }
        let nextDay = calendar.date(byAdding: .day, value: 1, to: targetDay)!

        return logs.filter { log in
            guard let date = log.value(forKey: "date") as? Date else { return false }
            return date >= targetDay && date < nextDay
        }
    }

    private func dayLabel(_ offset: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        guard let date = calendar.date(byAdding: .day, value: -(6 - offset), to: today) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(2))
    }

    // MARK: - Recent Activity

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(FLFont.display(18))
                .foregroundColor(.white)

            if logs.isEmpty {
                GlassmorphicCard {
                    HStack(spacing: 12) {
                        Image(systemName: "chart.bar")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.3))
                        Text("Complete lessons and quizzes to see your activity here")
                            .font(FLFont.body(13))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(16)
                }
            } else {
                ForEach(logs.prefix(10), id: \.objectID) { log in
                    logRow(log)
                }
            }
        }
    }

    private func logRow(_ log: NSManagedObject) -> some View {
        let category = log.value(forKey: "category") as? String ?? "unknown"
        let score = log.value(forKey: "score") as? Int16 ?? 0
        let maxScore = log.value(forKey: "maxScore") as? Int16 ?? 0
        let xp = log.value(forKey: "xp") as? Int32 ?? 0
        let date = log.value(forKey: "date") as? Date ?? Date()

        let icon = category == "quiz" ? "checkmark.circle.fill" :
                   category == "gauntlet" ? "bolt.fill" :
                   category == "flashcard" ? "rectangle.on.rectangle.angled" : "book.fill"
        let color = category == "quiz" ? FLColor.biolumGreen :
                    category == "gauntlet" ? FLColor.biolumViolet :
                    category == "flashcard" ? FLColor.moltenGold : FLColor.biolumCyan

        return GlassmorphicCard(topRightCut: 12, bottomLeftCut: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.capitalized)
                        .font(FLFont.body(14))
                        .foregroundColor(.white)
                    Text(formatDate(date))
                        .font(FLFont.body(11))
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    if maxScore > 0 {
                        Text("\(score)/\(maxScore)")
                            .font(FLFont.mono(14))
                            .foregroundColor(.white)
                    }
                    Text("+\(xp) XP")
                        .font(FLFont.mono(11))
                        .foregroundColor(FLColor.moltenGold)
                }
            }
            .padding(12)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
