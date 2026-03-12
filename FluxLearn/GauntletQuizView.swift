import SwiftUI

// MARK: - Difficulty Mode

enum GauntletDifficulty: String, CaseIterable {
    case normal = "Normal"
    case hard = "Hard"
    case extreme = "Extreme"

    var questionCount: Int {
        switch self {
        case .normal: return 10
        case .hard: return 15
        case .extreme: return 20
        }
    }

    var timePerQuestion: Int {
        switch self {
        case .normal: return 30
        case .hard: return 20
        case .extreme: return 12
        }
    }

    var xpMultiplier: Double {
        switch self {
        case .normal: return 1.0
        case .hard: return 1.5
        case .extreme: return 2.5
        }
    }

    var bonusQuestionRatio: Double {
        switch self {
        case .normal: return 0.1
        case .hard: return 0.25
        case .extreme: return 0.4
        }
    }

    var icon: String {
        switch self {
        case .normal: return "bolt.fill"
        case .hard: return "bolt.trianglebadge.exclamationmark.fill"
        case .extreme: return "flame.fill"
        }
    }

    var colors: [Color] {
        switch self {
        case .normal: return [FLColor.biolumCyan, FLColor.biolumGreen]
        case .hard: return [Color(red: 0.95, green: 0.55, blue: 0.1), FLColor.warmEmber]
        case .extreme: return [Color(red: 1.0, green: 0.2, blue: 0.1), Color(red: 0.8, green: 0.1, blue: 0.4)]
        }
    }
}

// MARK: - Answer Record

struct GauntletAnswerRecord: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctIndex: Int
    let selectedIndex: Int
    var isCorrect: Bool { selectedIndex == correctIndex }
}

/// Standalone "Gauntlet" quiz mode — random questions from all unlocked lessons
struct QuizView: View {
    @EnvironmentObject var gameState: GameState

    // Quiz state
    @State private var allQuestions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var score = 0
    @State private var answered = false
    @State private var showResult = false
    @State private var started = false

    // Difficulty
    @State private var difficulty: GauntletDifficulty = .normal

    // Timer
    @State private var timeRemaining = 30
    @State private var timerActive = false
    @State private var timerTask: Task<Void, Never>? = nil

    // Streak multiplier
    @State private var consecutiveCorrect = 0
    @State private var totalXPEarned = 0

    // Answer history for review
    @State private var answerHistory: [GauntletAnswerRecord] = []

    // Result tab
    @State private var showReviewDetail = false

    var body: some View {
        ZStack {
            if !started {
                startScreen
            } else if allQuestions.isEmpty {
                noQuestionsView
            } else if showResult {
                resultScreen
            } else {
                questionView
            }
        }
    }

    // MARK: - Start Screen

    private var startScreen: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer().frame(height: 50)

                Image(systemName: "puzzlepiece.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(FLColor.biolumGradient)
                    .symbolEffect(.pulse)

                Text("The Gauntlet")
                    .font(FLFont.display(30))
                    .foregroundColor(.white)

                Text("Test your knowledge across\nall unlocked lessons")
                    .font(FLFont.body(15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.6))

                // Difficulty selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("Difficulty")
                        .font(FLFont.display(16))
                        .foregroundColor(.white)

                    ForEach(GauntletDifficulty.allCases, id: \.self) { mode in
                        difficultyRow(mode)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Stats preview
                gauntletStatsPreview
                    .padding(.horizontal, 24)

                // Start button
                Button {
                    startGauntlet()
                    HapticEngine.impact(.heavy)
                } label: {
                    HStack {
                        Image(systemName: difficulty.icon)
                        Text("Begin \(difficulty.rawValue)")
                    }
                    .font(FLFont.display(18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(colors: difficulty.colors,
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(CutCornerShape(topRightCut: 16, bottomLeftCut: 16))
                }
                .fluxButton()
                .padding(.horizontal, 24)

                Spacer().frame(height: 40)
            }
        }
    }

    private func difficultyRow(_ mode: GauntletDifficulty) -> some View {
        let isSelected = difficulty == mode
        return Button {
            difficulty = mode
            HapticEngine.impact(.light)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: mode.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(FLFont.body(15))
                        .foregroundColor(.white)
                    Text("\(mode.questionCount) questions · \(mode.timePerQuestion)s timer · \(String(format: "%.1f", mode.xpMultiplier))× XP")
                        .font(FLFont.mono(10))
                        .foregroundColor(.white.opacity(0.45))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(
                            LinearGradient(colors: mode.colors,
                                           startPoint: .top, endPoint: .bottom)
                        )
                }
            }
            .padding(12)
            .background(isSelected ? Color.white.opacity(0.08) : FLColor.glassFill)
            .clipShape(CutCornerShape(topRightCut: 10, bottomLeftCut: 10))
            .overlay(
                CutCornerShape(topRightCut: 10, bottomLeftCut: 10)
                    .stroke(isSelected
                            ? LinearGradient(colors: mode.colors, startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [FLColor.glassStroke], startPoint: .leading, endPoint: .trailing),
                            lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var gauntletStatsPreview: some View {
        let runs = gameState.gauntletRuns
        let best = gameState.gauntletBestScore
        let avgPct = gameState.gauntletRuns > 0
            ? Int(Double(gameState.gauntletTotalCorrect) / Double(gameState.gauntletTotalAnswered) * 100)
            : 0

        return GlassmorphicCard {
            HStack(spacing: 0) {
                miniStat(icon: "flame.fill", value: "\(runs)", label: "Runs")
                miniStat(icon: "trophy.fill", value: "\(best)", label: "Best")
                miniStat(icon: "chart.bar.fill", value: "\(avgPct)%", label: "Accuracy")
            }
            .padding(12)
        }
    }

    private func miniStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(FLColor.biolumGradient)
            Text(value)
                .font(FLFont.mono(16))
                .foregroundColor(.white)
            Text(label)
                .font(FLFont.body(9))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - No Questions

    private var noQuestionsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.3))
            Text("Complete some lessons first")
                .font(FLFont.display(20))
                .foregroundColor(.white)
            Text("Unlock lessons in the Library\nto generate quiz questions")
                .font(FLFont.body(14))
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.5))
        }
    }

    // MARK: - Question View

    private var questionView: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text(difficulty.rawValue)
                    .font(FLFont.mono(12))
                    .foregroundColor(difficulty == .extreme ? Color(red: 1, green: 0.3, blue: 0.2) :
                                        difficulty == .hard ? FLColor.warmEmber : FLColor.biolumCyan)
                Spacer()
                Text("\(currentIndex + 1)/\(allQuestions.count)")
                    .font(FLFont.mono(13))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(FLColor.moltenGold)
                    Text("\(totalXPEarned)")
                        .font(FLFont.mono(14))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(LinearGradient(colors: difficulty.colors,
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(currentIndex + 1) / CGFloat(max(allQuestions.count, 1)))
                        .animation(.spring(), value: currentIndex)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 20)

            // Timer + streak row
            HStack {
                // Timer
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .foregroundColor(timerColor)
                    Text("\(timeRemaining)s")
                        .font(FLFont.mono(16))
                        .foregroundColor(timerColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(timerColor.opacity(0.1))
                .clipShape(Capsule())

                Spacer()

                // Streak indicator
                if consecutiveCorrect > 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(FLColor.moltenGold)
                        Text("×\(currentMultiplier)")
                            .font(FLFont.mono(14))
                            .foregroundColor(FLColor.moltenGold)
                        Text("streak")
                            .font(FLFont.body(10))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(FLColor.moltenGold.opacity(0.1))
                    .clipShape(Capsule())
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .animation(.spring(response: 0.3), value: consecutiveCorrect)

            // Question
            Text(allQuestions[currentIndex].question)
                .font(FLFont.display(19))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 20)

            // Options
            VStack(spacing: 10) {
                ForEach(allQuestions[currentIndex].options.indices, id: \.self) { index in
                    gauntletAnswerButton(index: index)
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // Next button
            if answered {
                Button {
                    advanceQuestion()
                    HapticEngine.impact(.light)
                } label: {
                    Text(currentIndex < allQuestions.count - 1 ? "Next" : "Results")
                        .font(FLFont.body(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(LinearGradient(colors: difficulty.colors,
                                                   startPoint: .leading, endPoint: .trailing))
                        .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
                }
                .fluxButton()
                .padding(.horizontal, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.bottom)
        .animation(.spring(response: 0.3), value: answered)
    }

    private var timerColor: Color {
        if timeRemaining <= 5 { return Color(red: 1.0, green: 0.3, blue: 0.2) }
        if timeRemaining <= 10 { return FLColor.warmEmber }
        return FLColor.biolumCyan
    }

    private var currentMultiplier: Int {
        if consecutiveCorrect >= 7 { return 4 }
        if consecutiveCorrect >= 4 { return 3 }
        if consecutiveCorrect >= 2 { return 2 }
        return 1
    }

    private func gauntletAnswerButton(index: Int) -> some View {
        let isCorrect = index == allQuestions[currentIndex].correctIndex
        let isSelected = selectedAnswer == index

        return Button {
            guard !answered else { return }
            selectAnswer(index)
        } label: {
            HStack {
                Text(allQuestions[currentIndex].options[index])
                    .font(FLFont.body(15))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                Spacer()
                if answered {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(FLColor.biolumGreen)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(FLColor.biolumPink)
                    }
                }
            }
            .padding(14)
            .background(answered && isCorrect ? FLColor.biolumGreen.opacity(0.12) :
                            answered && isSelected ? FLColor.biolumPink.opacity(0.12) : FLColor.glassFill)
            .clipShape(CutCornerShape(topRightCut: 10, bottomLeftCut: 10))
            .overlay(
                CutCornerShape(topRightCut: 10, bottomLeftCut: 10)
                    .stroke(answered && isCorrect ? FLColor.biolumGreen :
                                answered && isSelected ? FLColor.biolumPink : FLColor.glassStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Result Screen

    private var resultScreen: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)

                // Score ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 12)
                        .frame(width: 140, height: 140)
                    Circle()
                        .trim(from: 0, to: CGFloat(score) / CGFloat(max(allQuestions.count, 1)))
                        .stroke(
                            LinearGradient(colors: difficulty.colors,
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(score)/\(allQuestions.count)")
                            .font(FLFont.display(30))
                            .foregroundColor(.white)
                        Text(resultGrade)
                            .font(FLFont.body(12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                Text(resultMessage)
                    .font(FLFont.display(22))
                    .foregroundColor(.white)

                // XP breakdown
                GlassmorphicCard {
                    VStack(spacing: 8) {
                        xpRow(label: "Base XP (\(score) correct)", value: score * 25)
                        xpRow(label: "Difficulty bonus (×\(String(format: "%.1f", difficulty.xpMultiplier)))", value: Int(Double(score * 25) * (difficulty.xpMultiplier - 1.0)))
                        xpRow(label: "Streak bonuses", value: totalXPEarned - Int(Double(score * 25) * difficulty.xpMultiplier))
                        Divider().background(Color.white.opacity(0.2))
                        HStack {
                            Text("Total")
                                .font(FLFont.body(14))
                                .foregroundColor(.white)
                            Spacer()
                            Text("+\(totalXPEarned) XP")
                                .font(FLFont.mono(16))
                                .foregroundColor(FLColor.moltenGold)
                        }
                    }
                    .padding(16)
                }
                .padding(.horizontal, 24)

                // Answer review
                VStack(alignment: .leading, spacing: 10) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            showReviewDetail.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet.clipboard")
                                .foregroundStyle(FLColor.biolumGradient)
                            Text("Review Answers")
                                .font(FLFont.display(16))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: showReviewDetail ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    .buttonStyle(.plain)

                    if showReviewDetail {
                        ForEach(Array(answerHistory.enumerated()), id: \.element.id) { idx, record in
                            reviewRow(index: idx, record: record)
                        }
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 24)

                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        startGauntlet()
                        HapticEngine.impact(.heavy)
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("New Gauntlet")
                        }
                        .font(FLFont.body(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(LinearGradient(colors: difficulty.colors,
                                                   startPoint: .leading, endPoint: .trailing))
                        .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
                    }
                    .fluxButton()

                    Button {
                        resetToMenu()
                        HapticEngine.impact()
                    } label: {
                        Text("Back to Menu")
                            .font(FLFont.body(14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 40)
            }
        }
    }

    private func xpRow(label: String, value: Int) -> some View {
        HStack {
            Text(label)
                .font(FLFont.body(12))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text("+\(max(0, value))")
                .font(FLFont.mono(12))
                .foregroundColor(.white.opacity(0.8))
        }
    }

    private func reviewRow(index: Int, record: GauntletAnswerRecord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: record.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(record.isCorrect ? FLColor.biolumGreen : FLColor.biolumPink)
                    .font(.caption)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Q\(index + 1): \(record.question)")
                        .font(FLFont.body(12))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(3)

                    if !record.isCorrect {
                        if record.selectedIndex < 0 {
                            Text("Time's up!")
                                .font(FLFont.body(11))
                                .foregroundColor(FLColor.warmEmber.opacity(0.8))
                        } else {
                            Text("Your answer: \(record.options[record.selectedIndex])")
                                .font(FLFont.body(11))
                                .foregroundColor(FLColor.biolumPink.opacity(0.7))
                        }
                        Text("Correct: \(record.options[record.correctIndex])")
                            .font(FLFont.body(11))
                            .foregroundColor(FLColor.biolumGreen.opacity(0.8))
                    }
                }
            }
        }
        .padding(10)
        .background(FLColor.glassFill)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var resultGrade: String {
        let pct = Double(score) / Double(max(allQuestions.count, 1))
        if pct >= 0.9 { return "S Rank" }
        if pct >= 0.8 { return "A Rank" }
        if pct >= 0.6 { return "B Rank" }
        if pct >= 0.4 { return "C Rank" }
        return "D Rank"
    }

    private var resultMessage: String {
        let pct = Double(score) / Double(max(allQuestions.count, 1))
        if pct >= 0.9 { return "Chronos Master!" }
        if pct >= 0.8 { return "Excellent!" }
        if pct >= 0.6 { return "Good effort!" }
        if pct >= 0.4 { return "Keep practicing!" }
        return "Keep learning!"
    }

    // MARK: - Logic

    private func startGauntlet() {
        let states = gameState.lessonStates
        let unlockedIDs = states.filter { !$0.isLocked }.map { $0.id }
        let lessons = LessonRepository.all.filter { unlockedIDs.contains($0.id) }

        var pool: [QuizQuestion] = []
        for lesson in lessons {
            pool.append(contentsOf: QuizContent.questions(for: lesson.title))
        }

        // Mix in bonus questions based on difficulty
        let bonusCount = Int(Double(difficulty.questionCount) * difficulty.bonusQuestionRatio)
        let bonusQuestions = Array(QuizContent.gauntletBonusQuestions.shuffled().prefix(bonusCount))

        pool.append(contentsOf: bonusQuestions)

        allQuestions = Array(pool.shuffled().prefix(difficulty.questionCount))
        currentIndex = 0
        selectedAnswer = nil
        score = 0
        answered = false
        showResult = false
        showReviewDetail = false
        started = true
        consecutiveCorrect = 0
        totalXPEarned = 0
        answerHistory = []
        timeRemaining = difficulty.timePerQuestion
        startTimer()
    }

    private func resetToMenu() {
        stopTimer()
        started = false
        showResult = false
    }

    private func selectAnswer(_ index: Int) {
        selectedAnswer = index >= 0 ? index : nil
        answered = true
        stopTimer()

        let q = allQuestions[currentIndex]
        let correct = index >= 0 && index == q.correctIndex

        // Record answer (use -1 for timeout)
        answerHistory.append(GauntletAnswerRecord(
            question: q.question,
            options: q.options,
            correctIndex: q.correctIndex,
            selectedIndex: index
        ))

        if correct {
            score += 1
            consecutiveCorrect += 1
            let baseXP = 25
            let multiplied = Int(Double(baseXP * currentMultiplier) * difficulty.xpMultiplier)
            totalXPEarned += multiplied
            HapticEngine.notification(.success)
        } else {
            consecutiveCorrect = 0
            if index < 0 {
                // Timeout — distinct haptic
                HapticEngine.notification(.warning)
            } else {
                HapticEngine.notification(.error)
            }
        }
    }

    private func advanceQuestion() {
        if currentIndex < allQuestions.count - 1 {
            currentIndex += 1
            selectedAnswer = nil
            answered = false
            timeRemaining = difficulty.timePerQuestion
            startTimer()
        } else {
            finishGauntlet()
        }
    }

    private func finishGauntlet() {
        stopTimer()
        showResult = true
        gameState.addXP(totalXPEarned)

        // Update gauntlet stats
        gameState.gauntletRuns += 1
        gameState.gauntletTotalCorrect += score
        gameState.gauntletTotalAnswered += allQuestions.count
        if score > gameState.gauntletBestScore {
            gameState.gauntletBestScore = score
        }

        CoreDataStack.shared.saveLog(
            category: "gauntlet",
            score: Int16(score),
            maxScore: Int16(allQuestions.count),
            xp: Int32(totalXPEarned),
            seconds: 0
        )

        // Check gauntlet achievements
        checkGauntletAchievements()
    }

    private func checkGauntletAchievements() {
        var achs = gameState.achievements

        // Perfect gauntlet
        if score == allQuestions.count {
            if let idx = achs.firstIndex(where: { $0.id == "perfect_gauntlet" && !$0.isUnlocked }) {
                achs[idx].isUnlocked = true
                achs[idx].progress = 1.0
                HapticEngine.notification(.success)
            }
        }

        // Gauntlet veteran (10 runs)
        if gameState.gauntletRuns >= 10 {
            if let idx = achs.firstIndex(where: { $0.id == "gauntlet_veteran" && !$0.isUnlocked }) {
                achs[idx].isUnlocked = true
                achs[idx].progress = 1.0
                HapticEngine.notification(.success)
            }
        }
        if let idx = achs.firstIndex(where: { $0.id == "gauntlet_veteran" && !$0.isUnlocked }) {
            achs[idx].progress = min(1.0, Double(gameState.gauntletRuns) / 10.0)
        }

        // Extreme survivor (complete Extreme)
        if difficulty == .extreme && score > 0 {
            if let idx = achs.firstIndex(where: { $0.id == "extreme_survivor" && !$0.isUnlocked }) {
                achs[idx].isUnlocked = true
                achs[idx].progress = 1.0
                HapticEngine.notification(.success)
            }
        }

        gameState.achievements = achs
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        timerActive = true
        timerTask = Task { @MainActor in
            while timerActive && timeRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard timerActive else { return }
                timeRemaining -= 1
            }
            if timerActive && timeRemaining <= 0 && !answered {
                // Time's up — auto-answer wrong
                selectAnswer(-1)
            }
        }
    }

    private func stopTimer() {
        timerActive = false
        timerTask?.cancel()
        timerTask = nil
    }
}
