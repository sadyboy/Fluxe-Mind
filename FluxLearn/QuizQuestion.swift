import SwiftUI

struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctIndex: Int
}

struct LessonQuizView: View {
    let lesson: Lesson
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    @State private var currentQuestion = 0
    @State private var selectedAnswer: Int? = nil
    @State private var score = 0
    @State private var showResult = false
    @State private var answered = false

    var questions: [QuizQuestion] {
        QuizContent.questions(for: lesson.title)
    }

    var body: some View {
        ZStack {
            AuroraBackground()

            if questions.isEmpty {
                emptyState
            } else if showResult {
                resultView
            } else {
                questionView
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(FLColor.biolumGradient)
            Text("No quiz available yet")
                .font(FLFont.display(20))
                .foregroundColor(.white)
            Button { dismiss() } label: {
                Text("Go Back")
                    .font(FLFont.body(16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(FLColor.auroraGradient)
                    .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
            }
            .fluxButton()
        }
    }

    // MARK: - Question View

    private var questionView: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(10)
                        .background(FLColor.glassFill)
                        .clipShape(Circle())
                }
                Spacer()
                Text("Question \(currentQuestion + 1) of \(questions.count)")
                    .font(FLFont.mono(13))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(FLColor.moltenGold)
                    Text("\(score)")
                        .font(FLFont.mono(16))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)

            // Progress
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(LinearGradient(colors: lesson.gradient, startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(currentQuestion + 1) / CGFloat(max(questions.count, 1)))
                        .animation(.spring(response: 0.4), value: currentQuestion)
                }
            }
            .frame(height: 4)
            .padding(.horizontal)

            // Question text
            Text(questions[currentQuestion].question)
                .font(FLFont.display(20))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)

            // Options
            VStack(spacing: 10) {
                ForEach(questions[currentQuestion].options.indices, id: \.self) { index in
                    answerButton(index: index)
                }
            }
            .padding(.horizontal)

            Spacer()

            // Next Button
            if answered {
                Button {
                    nextQuestion()
                    HapticEngine.impact(.light)
                } label: {
                    HStack {
                        Text(currentQuestion < questions.count - 1 ? "Next Question" : "See Results")
                        Image(systemName: currentQuestion < questions.count - 1 ? "arrow.right" : "flag.checkered")
                    }
                    .font(FLFont.body(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(LinearGradient(colors: lesson.gradient, startPoint: .leading, endPoint: .trailing))
                    .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
                }
                .fluxButton()
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.bottom)
        .animation(.spring(response: 0.3), value: answered)
    }

    // MARK: - Answer Button

    private func answerButton(index: Int) -> some View {
        let isCorrect = index == questions[currentQuestion].correctIndex
        let isSelected = selectedAnswer == index

        return Button {
            guard !answered else { return }
            selectedAnswer = index
            answered = true
            if isCorrect {
                score += 1
                HapticEngine.notification(.success)
            } else {
                HapticEngine.notification(.error)
            }
        } label: {
            HStack {
                Text(questions[currentQuestion].options[index])
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
            .padding(16)
            .background(answerBackground(isCorrect: isCorrect, isSelected: isSelected))
            .clipShape(CutCornerShape(topRightCut: 10, bottomLeftCut: 10))
            .overlay(
                CutCornerShape(topRightCut: 10, bottomLeftCut: 10)
                    .stroke(answerBorder(isCorrect: isCorrect, isSelected: isSelected), lineWidth: answered ? 1.5 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func answerBackground(isCorrect: Bool, isSelected: Bool) -> Color {
        guard answered else { return FLColor.glassFill }
        if isCorrect { return FLColor.biolumGreen.opacity(0.15) }
        if isSelected { return FLColor.biolumPink.opacity(0.15) }
        return FLColor.glassFill
    }

    private func answerBorder(isCorrect: Bool, isSelected: Bool) -> Color {
        guard answered else { return FLColor.glassStroke }
        if isCorrect { return FLColor.biolumGreen }
        if isSelected { return FLColor.biolumPink }
        return FLColor.glassStroke
    }

    // MARK: - Next Question

    private func nextQuestion() {
        if currentQuestion < questions.count - 1 {
            currentQuestion += 1
            selectedAnswer = nil
            answered = false
        } else {
            showResult = true
            let xpEarned = score * 20
            gameState.addXP(xpEarned)
            gameState.completeLesson(lesson.id)
            CoreDataStack.shared.saveLog(
                category: "quiz",
                score: Int16(score),
                maxScore: Int16(questions.count),
                xp: Int32(xpEarned),
                seconds: 0
            )

            // Check achievements
            var achs = gameState.achievements
            if score == questions.count {
                if let idx = achs.firstIndex(where: { $0.id == "perfect_quiz" && !$0.isUnlocked }) {
                    achs[idx].isUnlocked = true
                    achs[idx].progress = 1.0
                    gameState.achievements = achs
                }
            }
            if let idx = achs.firstIndex(where: { $0.id == "first_lesson" && !$0.isUnlocked }) {
                achs[idx].isUnlocked = true
                achs[idx].progress = 1.0
                gameState.achievements = achs
            }
        }
    }

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 160, height: 160)
                Circle()
                    .trim(from: 0, to: CGFloat(score) / CGFloat(max(questions.count, 1)))
                    .stroke(
                        LinearGradient(colors: lesson.gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(score)/\(questions.count)")
                        .font(FLFont.display(36))
                        .foregroundColor(.white)
                    Text("correct")
                        .font(FLFont.body(13))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Text(resultMessage)
                .font(FLFont.display(24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("+\(score * 20) XP earned")
                .font(FLFont.mono(16))
                .foregroundColor(FLColor.moltenGold)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    currentQuestion = 0
                    selectedAnswer = nil
                    score = 0
                    answered = false
                    showResult = false
                    HapticEngine.impact()
                } label: {
                    Text("Try Again")
                        .font(FLFont.body(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(FLColor.glassFill)
                        .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
                        .overlay(CutCornerShape(topRightCut: 12, bottomLeftCut: 12).stroke(FLColor.glassStroke, lineWidth: 1))
                }
                .fluxButton()

                Button {
                    dismiss()
                    HapticEngine.impact()
                } label: {
                    Text("Done")
                        .font(FLFont.body(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(LinearGradient(colors: lesson.gradient, startPoint: .leading, endPoint: .trailing))
                        .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
                }
                .fluxButton()
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private var resultMessage: String {
        let percentage = Double(score) / Double(max(questions.count, 1))
        if percentage >= 0.8 { return "Excellent!" }
        if percentage >= 0.5 { return "Good effort!" }
        return "Keep learning!"
    }
}
