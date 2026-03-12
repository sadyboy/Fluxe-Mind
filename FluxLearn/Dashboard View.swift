import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var gameState: GameState
    @State private var quickQuizAnswer: Int? = nil
    @State private var quickQuizRevealed = false
    @State private var dailyFactExpanded = false
    @State private var selectedLesson: Lesson? = nil
    @State private var showGlossary = false

    // MARK: - Daily Fact Data

    private static let dailyFacts: [(fact: String, source: String)] = [
        ("A day on Venus is longer than its year — it takes 243 Earth days to rotate once but only 225 to orbit the Sun.", "Astronomy"),
        ("The oldest known sundial dates back to approximately 1500 BCE in ancient Egypt.", "Lesson: Sundials"),
        ("Cesium-133 oscillates exactly 9,192,631,770 times per second — this is the literal definition of one second.", "Lesson: Atomic Clocks"),
        ("Before 1883, the United States had over 300 different local times, each city setting its own.", "Lesson: Time Zones"),
        ("GPS would accumulate ~10 km of error per day without corrections from atomic clocks.", "Lesson: Atomic Clocks"),
        ("John Harrison's H4 marine chronometer lost only 5.1 seconds over an 81-day voyage in 1762.", "Lesson: Marine Chronometers"),
        ("The Quartz Crisis nearly destroyed the Swiss watch industry when Seiko released the Astron in 1969.", "Lesson: Quartz Oscillators"),
        ("At 90% of the speed of light, time passes at only 43.6% the normal rate due to time dilation.", "Lesson: Einstein & Relativity"),
        ("The Maya '2012 apocalypse' was actually just a baktun rollover — like an odometer resetting to zero.", "Lesson: Calendars"),
        ("Optical lattice clocks are so precise they can detect the gravitational redshift from a 2 cm height change.", "Lesson: Optical Clocks"),
        ("Your body contains a master clock — ~20,000 neurons in the suprachiasmatic nucleus keep your circadian rhythm.", "Lesson: Biological Clocks"),
        ("Candle clocks used metal pins that fell onto plates as the wax melted — one of the first alarm clocks.", "Lesson: Candle Clocks"),
        ("Water clocks (clepsydrae) were humanity's most accurate timekeeper for nearly 3,000 years.", "Lesson: Water Clocks"),
        ("A pendulum exactly 1 meter long swings with a period of almost exactly 2 seconds.", "Lesson: Pendulum"),
        ("The French didn't adopt Greenwich Mean Time until 1911, stubbornly calling it 'Paris Mean Time retarded by 9 minutes 21 seconds.'", "Lesson: Time Zones"),
        ("Chip-scale atomic clocks (CSACs) fit in just 17 cm³ — small enough for a soldier's backpack.", "Lesson: Quantum Clocks"),
        ("Naked mole-rats have a degraded circadian clock, matching their underground lifestyle with no sunlight.", "Lesson: Biological Clocks"),
        ("The Ethiopian calendar has 13 months and is currently 7–8 years behind the Gregorian calendar.", "Lesson: Calendars"),
        ("Christiaan Huygens's pendulum clock improved timekeeping accuracy by 60× over the verge-and-foliot.", "Lesson: Pendulum"),
        ("Quartz watches vibrate at 32,768 Hz — a power of 2 (2¹⁵) — making binary division to 1 Hz trivially simple.", "Lesson: Quartz Oscillators"),
        ("Su Song's water clock tower in 1088 CE China was 12 meters tall, with an armillary sphere and rotating mannequins.", "Lesson: Water Clocks"),
    ]

    // MARK: - Daily Fact Selection

    private var todayFact: (fact: String, source: String) {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % Self.dailyFacts.count
        return Self.dailyFacts[index]
    }

    // MARK: - Quick Quiz Data

    private static let quickQuizPool: [(question: String, options: [String], correctIndex: Int, topic: String)] = [
        ("What is the shadow-casting part of a sundial called?", ["Gnomon", "Foliot", "Balance", "Anchor"], 0, "Sundials"),
        ("What does 'clepsydra' mean?", ["Sun tracker", "Water thief", "Time keeper", "Star gazer"], 1, "Water Clocks"),
        ("How many Hz does a quartz watch crystal vibrate at?", ["1,000", "9,192", "32,768", "100,000"], 2, "Quartz"),
        ("Who built the first pendulum clock?", ["Galileo", "Newton", "Huygens", "Harrison"], 2, "Pendulum"),
        ("What prize did Parliament offer for the Longitude solution?", ["£5,000", "£10,000", "£20,000", "£50,000"], 2, "Marine Chronometers"),
        ("What effect makes quartz timekeeping possible?", ["Photoelectric", "Piezoelectric", "Thermoelectric", "Magnetic"], 1, "Quartz"),
        ("How many local times did the US have before 1883?", ["24", "50", "Over 300", "12"], 2, "Time Zones"),
        ("What brain structure is the master circadian pacemaker?", ["Hippocampus", "SCN", "Pineal gland", "Cerebellum"], 1, "Biological Clocks"),
        ("How many months does the Ethiopian calendar have?", ["12", "13", "14", "10"], 1, "Calendars"),
        ("What element defines the SI second?", ["Rubidium", "Cesium-133", "Strontium", "Thorium"], 1, "Atomic Clocks"),
        ("GPS errors would reach ~? per day without atomic clocks.", ["1 m", "100 m", "1 km", "10 km"], 3, "Atomic Clocks"),
        ("Who discovered pendulum isochronism?", ["Newton", "Galileo", "Huygens", "Kepler"], 1, "Pendulum"),
    ]

    private var todayQuiz: (question: String, options: [String], correctIndex: Int, topic: String) {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % Self.quickQuizPool.count
        return Self.quickQuizPool[index]
    }

    // MARK: - Timeline Milestones

    private static let milestones: [(year: String, event: String, icon: String)] = [
        ("1500 BCE", "Earliest Egyptian sundials", "sun.max.fill"),
        ("1400 BCE", "Egyptian water clocks appear", "drop.fill"),
        ("300 BCE", "Berossus designs the hemicyclium", "sun.dust.fill"),
        ("850 CE", "King Alfred standardizes candle clocks", "flame.fill"),
        ("1088 CE", "Su Song's water clock tower in China", "building.columns.fill"),
        ("1270 CE", "Verge-and-foliot escapement invented", "gearshape.2.fill"),
        ("1583", "Galileo discovers pendulum isochronism", "metronome.fill"),
        ("1656", "Huygens builds first pendulum clock", "clock.fill"),
        ("1759", "Harrison completes H4 chronometer", "safari.fill"),
        ("1884", "Greenwich chosen as Prime Meridian", "globe.americas.fill"),
        ("1927", "First quartz clock built at Bell Labs", "waveform.path"),
        ("1955", "First cesium atomic clock", "atom"),
        ("1967", "SI second defined by cesium", "scalemass.fill"),
        ("1969", "Seiko Astron — first quartz wristwatch", "applewatch"),
        ("2015", "Optical lattice clock detects 2 cm gravity shift", "light.beacon.max.fill"),
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                headerSection
                    .padding(.top, 40)
                xpCard
                streakCard
                dailyFactCard
                quickQuizCard
                glossaryCard
                progressSection
                recentLessonsSection
                timelineMilestonesSection
                achievementsPreview
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back,")
                    .font(FLFont.body(14))
                    .foregroundColor(.white.opacity(0.6))
                Text(gameState.userName.isEmpty ? "Explorer" : gameState.userName)
                    .font(FLFont.display(26))
                    .foregroundColor(.white)
            }
            Spacer()
            ZStack {
                HexagonShape()
                    .fill(FLColor.glassFill)
                    .frame(width: 50, height: 50)
                HexagonShape()
                    .stroke(FLColor.biolumGradient, lineWidth: 1.5)
                    .frame(width: 50, height: 50)
                Image(systemName: avatarIcon)
                    .font(.title3)
                    .foregroundStyle(FLColor.biolumGradient)
            }
        }
    }

    private var avatarIcon: String {
        let icons = ["fish.fill", "tortoise.fill", "hare.fill", "ant.fill", "ladybug.fill", "leaf.fill"]
        let idx = min(gameState.avatarIndex, icons.count - 1)
        return icons[max(0, idx)]
    }

    // MARK: - XP Card

    private var xpCard: some View {
        GlassmorphicCard {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(gameState.currentLevelName)
                            .font(FLFont.display(22))
                            .foregroundColor(.white)
                        Text("Level \(gameState.currentLevel + 1)")
                            .font(FLFont.mono(12))
                            .foregroundColor(FLColor.biolumCyan)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(gameState.totalXP) XP")
                            .font(FLFont.mono(20))
                            .foregroundColor(FLColor.moltenGold)
                        Text("\(gameState.xpToNextLevel) to next level")
                            .font(FLFont.body(11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        ParallelogramShape()
                            .fill(Color.white.opacity(0.1))
                        ParallelogramShape()
                            .fill(FLColor.biolumGradient)
                            .frame(width: geo.size.width * max(0.02, gameState.levelProgress))
                    }
                }
                .frame(height: 8)
            }
            .padding(20)
        }
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        GlassmorphicCard {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gameState.streakTemperature.colors,
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: 56, height: 56)
                    Image(systemName: gameState.streakTemperature.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(gameState.streakCount)-day streak")
                        .font(FLFont.display(18))
                        .foregroundColor(.white)
                    Text("Longest: \(gameState.longestStreak) days")
                        .font(FLFont.body(12))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                if gameState.streakFreezeActive {
                    VStack(spacing: 2) {
                        Image(systemName: "snowflake")
                            .font(.caption)
                            .foregroundColor(FLColor.biolumCyan)
                        Text("Freeze")
                            .font(FLFont.body(9))
                            .foregroundColor(FLColor.biolumCyan)
                    }
                    .padding(8)
                    .background(FLColor.biolumCyan.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(16)
        }
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Progress")
                .font(FLFont.display(18))
                .foregroundColor(.white)

            let states = gameState.lessonStates
            let completed = states.filter { $0.isCompleted }.count
            let total = states.count

            GlassmorphicCard {
                VStack(spacing: 12) {
                    HStack {
                        Text("\(completed) of \(total) lessons completed")
                            .font(FLFont.body(14))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(Int(Double(completed) / Double(max(total, 1)) * 100))%")
                            .font(FLFont.mono(16))
                            .foregroundColor(FLColor.biolumGreen)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [FLColor.biolumCyan, FLColor.biolumGreen],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * max(0.02, CGFloat(completed) / CGFloat(max(total, 1))))
                        }
                    }
                    .frame(height: 6)

                    HStack(spacing: 16) {
                        statBadge(icon: "book.fill", label: "Sessions", value: "\(gameState.totalSessions)")
                        statBadge(icon: "clock.fill", label: "Goal", value: "\(gameState.daysPerWeekGoal)d/wk")
                        statBadge(icon: "star.fill", label: "Tier", value: tierName)
                    }
                }
                .padding(16)
            }
        }
    }

    private var tierName: String {
        switch gameState.skillTier {
        case 0: return "Beginner"
        case 1: return "Intermediate"
        default: return "Expert"
        }
    }

    private func statBadge(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(FLColor.biolumGradient)
            Text(value)
                .font(FLFont.mono(14))
                .foregroundColor(.white)
            Text(label)
                .font(FLFont.body(9))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Recent Lessons

    private var recentLessonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Continue Learning")
                .font(FLFont.display(18))
                .foregroundColor(.white)

            let states = gameState.lessonStates
            let nextUnlocked = states.first(where: { !$0.isCompleted && !$0.isLocked })
            let lessons = LessonRepository.all

            if let next = nextUnlocked, next.id < lessons.count {
                let lesson = lessons[next.id]
                Button {
                    selectedLesson = lesson
                    HapticEngine.impact()
                } label: {
                    GlassmorphicCard(
                        borderGradient: LinearGradient(
                            colors: lesson.gradient,
                            startPoint: .leading, endPoint: .trailing
                        )
                    ) {
                        HStack(spacing: 14) {
                            ZStack {
                                HexagonShape()
                                    .fill(LinearGradient(colors: lesson.gradient, startPoint: .top, endPoint: .bottom))
                                    .frame(width: 50, height: 50)
                                Image(systemName: lesson.icon)
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(lesson.title)
                                    .font(FLFont.body(16))
                                    .foregroundColor(.white)
                                Text(lesson.difficulty.rawValue)
                                    .font(FLFont.body(11))
                                    .foregroundColor(.white.opacity(0.5))
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(16)
                    }
                }
                .fluxButton()
            } else {
                GlassmorphicCard {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title2)
                            .foregroundStyle(FLColor.biolumGradient)
                        Text("All available lessons completed!")
                            .font(FLFont.body(14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(16)
                }
            }
        }
        .fullScreenCover(item: $selectedLesson) { lesson in
            LessonDetailView(lesson: lesson)
                .environmentObject(gameState)
        }
    }

    // MARK: - Glossary Card

    private var glossaryCard: some View {
        Button {
            showGlossary = true
            HapticEngine.impact()
        } label: {
            GlassmorphicCard(
                borderGradient: LinearGradient(
                    colors: [FLColor.biolumViolet, FLColor.biolumPink],
                    startPoint: .leading, endPoint: .trailing
                )
            ) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(FLColor.biolumViolet.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: "character.book.closed.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(colors: [FLColor.biolumViolet, FLColor.biolumPink],
                                               startPoint: .top, endPoint: .bottom)
                            )
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Glossary & Flashcards")
                            .font(FLFont.body(15))
                            .foregroundColor(.white)
                        Text("\(GlossaryRepository.all.count) terms · Spaced repetition")
                            .font(FLFont.mono(10))
                            .foregroundColor(.white.opacity(0.45))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(14)
            }
        }
        .fluxButton()
        .fullScreenCover(isPresented: $showGlossary) {
            GlossaryView()
                .environmentObject(gameState)
        }
    }

    // MARK: - Daily Fact Card

    private var dailyFactCard: some View {
        GlassmorphicCard(
            borderGradient: LinearGradient(
                colors: [FLColor.moltenGold, Color(red: 0.95, green: 0.55, blue: 0.1)],
                startPoint: .leading, endPoint: .trailing
            )
        ) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(FLColor.moltenGold)
                    Text("Daily Fact")
                        .font(FLFont.display(16))
                        .foregroundColor(FLColor.moltenGold)
                    Spacer()
                    Text(todayFact.source)
                        .font(FLFont.mono(9))
                        .foregroundColor(.white.opacity(0.4))
                }

                Text(todayFact.fact)
                    .font(FLFont.body(14))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(dailyFactExpanded ? nil : 3)
                    .animation(.easeInOut(duration: 0.25), value: dailyFactExpanded)

                if todayFact.fact.count > 120 {
                    Button {
                        dailyFactExpanded.toggle()
                    } label: {
                        Text(dailyFactExpanded ? "Show less" : "Read more")
                            .font(FLFont.body(12))
                            .foregroundColor(FLColor.biolumCyan)
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Quick Quiz Card

    private var quickQuizCard: some View {
        let quiz = todayQuiz
        return GlassmorphicCard(
            borderGradient: LinearGradient(
                colors: [FLColor.biolumCyan, FLColor.biolumGreen],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(FLColor.biolumCyan)
                    Text("Quick Quiz")
                        .font(FLFont.display(16))
                        .foregroundColor(FLColor.biolumCyan)
                    Spacer()
                    Text(quiz.topic)
                        .font(FLFont.mono(9))
                        .foregroundColor(.white.opacity(0.4))
                }

                Text(quiz.question)
                    .font(FLFont.body(14))
                    .foregroundColor(.white.opacity(0.9))

                VStack(spacing: 8) {
                    ForEach(0..<quiz.options.count, id: \.self) { idx in
                        Button {
                            guard !quickQuizRevealed else { return }
                            quickQuizAnswer = idx
                            quickQuizRevealed = true
                            if idx == quiz.correctIndex {
                                gameState.addXP(10)
                                HapticEngine.notification(.success)
                            } else {
                                HapticEngine.notification(.error)
                            }
                        } label: {
                            HStack {
                                Text(quiz.options[idx])
                                    .font(FLFont.body(13))
                                    .foregroundColor(.white)
                                Spacer()
                                if quickQuizRevealed && idx == quiz.correctIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(FLColor.biolumGreen)
                                } else if quickQuizRevealed && idx == quickQuizAnswer {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(quickQuizOptionBackground(idx: idx, correctIndex: quiz.correctIndex))
                            )
                        }
                        .disabled(quickQuizRevealed)
                    }
                }

                if quickQuizRevealed {
                    HStack {
                        Image(systemName: quickQuizAnswer == quiz.correctIndex ? "sparkles" : "arrow.clockwise")
                            .foregroundColor(quickQuizAnswer == quiz.correctIndex ? FLColor.moltenGold : FLColor.biolumCyan)
                        Text(quickQuizAnswer == quiz.correctIndex ? "+10 XP — Nice!" : "Come back tomorrow for a new question!")
                            .font(FLFont.body(12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 4)
                }
            }
            .padding(16)
        }
    }

    private func quickQuizOptionBackground(idx: Int, correctIndex: Int) -> Color {
        guard quickQuizRevealed else {
            return Color.white.opacity(0.06)
        }
        if idx == correctIndex {
            return FLColor.biolumGreen.opacity(0.2)
        }
        if idx == quickQuizAnswer {
            return Color.red.opacity(0.15)
        }
        return Color.white.opacity(0.03)
    }

    // MARK: - Timeline Milestones

    private var timelineMilestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(FLColor.biolumGradient)
                Text("Did You Know?")
                    .font(FLFont.display(18))
                    .foregroundColor(.white)
            }

            Text("Key milestones in the history of timekeeping")
                .font(FLFont.body(12))
                .foregroundColor(.white.opacity(0.45))

            VStack(spacing: 0) {
                ForEach(Array(Self.milestones.enumerated()), id: \.offset) { index, milestone in
                    HStack(alignment: .top, spacing: 12) {
                        // Timeline line + dot
                        VStack(spacing: 0) {
                            if index > 0 {
                                Rectangle()
                                    .fill(FLColor.biolumCyan.opacity(0.3))
                                    .frame(width: 2, height: 12)
                            } else {
                                Spacer().frame(width: 2, height: 12)
                            }
                            Circle()
                                .fill(FLColor.biolumCyan)
                                .frame(width: 8, height: 8)
                            if index < Self.milestones.count - 1 {
                                Rectangle()
                                    .fill(FLColor.biolumCyan.opacity(0.3))
                                    .frame(width: 2)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .frame(width: 12)

                        HStack(spacing: 10) {
                            Image(systemName: milestone.icon)
                                .font(.caption2)
                                .foregroundStyle(FLColor.biolumGradient)
                                .frame(width: 20)

                            Text(milestone.year)
                                .font(FLFont.mono(11))
                                .foregroundColor(FLColor.biolumCyan)
                                .frame(width: 65, alignment: .leading)

                            Text(milestone.event)
                                .font(FLFont.body(12))
                                .foregroundColor(.white.opacity(0.75))
                                .lineLimit(2)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(FLColor.glassFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(FLColor.biolumCyan.opacity(0.15), lineWidth: 1)
            )
        }
    }

    // MARK: - Achievements Preview

    private var achievementsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(FLFont.display(18))
                .foregroundColor(.white)

            let unlocked = gameState.achievements.filter { $0.isUnlocked }

            if unlocked.isEmpty {
                GlassmorphicCard {
                    HStack(spacing: 12) {
                        Image(systemName: "trophy")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.3))
                        Text("Complete lessons and quizzes to earn achievements")
                            .font(FLFont.body(13))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(16)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(unlocked) { ach in
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(ach.rarity.color.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    Circle()
                                        .stroke(ach.rarity.color, lineWidth: 1.5)
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "trophy.fill")
                                        .foregroundColor(ach.rarity.color)
                                }
                                Text(ach.title)
                                    .font(FLFont.body(10))
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineLimit(1)
                            }
                            .frame(width: 70)
                        }
                    }
                }
            }
        }
    }
}
