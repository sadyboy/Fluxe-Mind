import SwiftUI

// MARK: - Spaced Repetition Data

struct FlashcardState: Codable {
    let termID: String
    var easeFactor: Double       // starts at 2.5, adjusts per response
    var interval: Int            // days until next review
    var repetitions: Int         // consecutive correct recalls
    var nextReviewDate: Double   // timeIntervalSince1970
}

enum FlashcardRating: Int {
    case forgot = 0     // couldn't recall
    case hard = 1       // recalled with difficulty
    case good = 2       // recalled correctly
    case easy = 3       // instant recall
}

// MARK: - Flashcard View

struct FlashcardView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    @State private var deck: [GlossaryTerm] = []
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero
    @State private var sessionScore = 0
    @State private var sessionTotal = 0
    @State private var showSummary = false
    @State private var cardRotation: Double = 0

    private let sessionSize = 15

    var body: some View {
        ZStack {
            AuroraBackground()

            if showSummary {
                summaryView
            } else if deck.isEmpty {
                loadingView
            } else {
                cardSessionView
            }
        }
        .onAppear { buildDeck() }
    }

    // MARK: - Card Session

    private var cardSessionView: some View {
        VStack(spacing: 16) {
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

                Text("\(currentIndex + 1) / \(deck.count)")
                    .font(FLFont.mono(14))
                    .foregroundColor(.white.opacity(0.5))

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(FLColor.biolumGreen)
                    Text("\(sessionScore)")
                        .font(FLFont.mono(14))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // Progress
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(FLColor.biolumGradient)
                        .frame(width: geo.size.width * CGFloat(currentIndex) / CGFloat(max(deck.count, 1)))
                        .animation(.spring(), value: currentIndex)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 20)

            Spacer()

            // Card
            if currentIndex < deck.count {
                flashcard(term: deck[currentIndex])
                    .padding(.horizontal, 20)
            }

            Spacer()

            // Instructions / Rating
            if !isFlipped {
                Text("Tap the card to reveal the definition")
                    .font(FLFont.body(13))
                    .foregroundColor(.white.opacity(0.35))
            } else {
                ratingButtons
            }

            Spacer().frame(height: 30)
        }
    }

    // MARK: - Flashcard

    private func flashcard(term: GlossaryTerm) -> some View {
        ZStack {
            // Back (definition)
            cardFace(isBack: true) {
                VStack(spacing: 14) {
                    HStack {
                        Image(systemName: term.topic.icon)
                            .foregroundColor(term.topic.color)
                        Text(term.topic.rawValue)
                            .font(FLFont.mono(11))
                            .foregroundColor(term.topic.color)
                        Spacer()
                    }

                    Text(term.definition)
                        .font(FLFont.body(15))
                        .foregroundColor(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 0)

                    if !term.relatedTerms.isEmpty {
                        let related = term.relatedTerms.compactMap { relID in
                            GlossaryRepository.all.first(where: { $0.id == relID })?.term
                        }
                        if !related.isEmpty {
                            HStack {
                                Text("Related: \(related.joined(separator: ", "))")
                                    .font(FLFont.body(10))
                                    .foregroundColor(.white.opacity(0.3))
                                    .lineLimit(2)
                                Spacer()
                            }
                        }
                    }
                }
                .padding(24)
            }
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))

            // Front (term)
            cardFace(isBack: false) {
                VStack(spacing: 20) {
                    Image(systemName: term.topic.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(colors: [term.topic.color, term.topic.color.opacity(0.6)],
                                           startPoint: .top, endPoint: .bottom)
                        )

                    Text(term.term)
                        .font(FLFont.display(26))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("What is this?")
                        .font(FLFont.body(13))
                        .foregroundColor(.white.opacity(0.35))
                }
                .padding(24)
            }
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        }
        .frame(height: 320)
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
            HapticEngine.impact(.light)
        }
    }

    private func cardFace<Content: View>(isBack: Bool, @ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(FLColor.glassFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.06), Color.clear],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isBack ? FLColor.biolumGreen.opacity(0.3) : FLColor.biolumCyan.opacity(0.2),
                        lineWidth: 1.5
                    )
            )
    }

    // MARK: - Rating Buttons

    private var ratingButtons: some View {
        VStack(spacing: 8) {
            Text("How well did you know this?")
                .font(FLFont.body(12))
                .foregroundColor(.white.opacity(0.4))

            HStack(spacing: 10) {
                ratingButton(.forgot, label: "Forgot", icon: "xmark", color: Color(red: 1, green: 0.3, blue: 0.2))
                ratingButton(.hard, label: "Hard", icon: "tortoise.fill", color: FLColor.warmEmber)
                ratingButton(.good, label: "Good", icon: "checkmark", color: FLColor.biolumGreen)
                ratingButton(.easy, label: "Easy", icon: "bolt.fill", color: FLColor.biolumCyan)
            }
            .padding(.horizontal, 20)
        }
    }

    private func ratingButton(_ rating: FlashcardRating, label: String, icon: String, color: Color) -> some View {
        Button {
            rateAndAdvance(rating)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(color)
                Text(label)
                    .font(FLFont.body(10))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.25), lineWidth: 1)
            )
        }
        .fluxButton()
    }

    // MARK: - Summary

    private var summaryView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "rectangle.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(FLColor.biolumGradient)

            Text("Session Complete")
                .font(FLFont.display(26))
                .foregroundColor(.white)

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: CGFloat(sessionScore) / CGFloat(max(sessionTotal, 1)))
                    .stroke(FLColor.biolumGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("\(sessionScore)")
                        .font(FLFont.display(28))
                        .foregroundColor(.white)
                    Text("of \(sessionTotal)")
                        .font(FLFont.body(12))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            let xp = sessionScore * 5
            Text("+\(xp) XP")
                .font(FLFont.mono(18))
                .foregroundColor(FLColor.moltenGold)

            Text("Cards rated 'Good' or 'Easy' will appear\nless frequently. Keep practicing!")
                .font(FLFont.body(12))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    resetSession()
                    HapticEngine.impact()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("New Session")
                    }
                    .font(FLFont.body(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(FLColor.auroraGradient)
                    .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
                }
                .fluxButton()

                Button {
                    dismiss()
                    HapticEngine.impact()
                } label: {
                    Text("Done")
                        .font(FLFont.body(14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .tint(.white)
            Text("Preparing cards…")
                .font(FLFont.body(14))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    // MARK: - Logic

    private func buildDeck() {
        let states = loadFlashcardStates()
        let now = Date().timeIntervalSince1970

        // Due cards: those whose nextReviewDate has passed
        var dueTermIDs = states
            .filter { $0.nextReviewDate <= now }
            .sorted { $0.easeFactor < $1.easeFactor } // harder cards first
            .map { $0.termID }

        // New cards: terms without a state yet
        let stateIDs = Set(states.map(\.termID))
        let newTermIDs = GlossaryRepository.all
            .filter { !stateIDs.contains($0.id) }
            .shuffled()
            .map(\.id)

        // Build deck: due first, then new, capped at sessionSize
        var deckIDs = Array((dueTermIDs + newTermIDs).prefix(sessionSize))

        // If still not enough, add random from all
        if deckIDs.count < sessionSize {
            let remaining = GlossaryRepository.all
                .filter { !deckIDs.contains($0.id) }
                .shuffled()
                .prefix(sessionSize - deckIDs.count)
                .map(\.id)
            deckIDs.append(contentsOf: remaining)
        }

        deck = deckIDs.compactMap { id in
            GlossaryRepository.all.first(where: { $0.id == id })
        }
        currentIndex = 0
        sessionScore = 0
        sessionTotal = deck.count
        isFlipped = false
        showSummary = false
    }

    private func rateAndAdvance(_ rating: FlashcardRating) {
        guard currentIndex < deck.count else { return }
        let term = deck[currentIndex]

        // Update spaced repetition state
        updateSpacedRepetition(termID: term.id, rating: rating)

        if rating == .good || rating == .easy {
            sessionScore += 1
        }

        HapticEngine.impact(.light)

        // Advance
        if currentIndex < deck.count - 1 {
            withAnimation(.spring(response: 0.3)) {
                isFlipped = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                currentIndex += 1
            }
        } else {
            // Session complete
            let xp = sessionScore * 5
            gameState.addXP(xp)
            gameState.flashcardSessions += 1
            gameState.flashcardTotalReviewed += sessionTotal

            CoreDataStack.shared.saveLog(
                category: "flashcard",
                score: Int16(sessionScore),
                maxScore: Int16(sessionTotal),
                xp: Int32(xp),
                seconds: 0
            )

            gameState.checkAutoAchievements()

            withAnimation(.spring()) {
                showSummary = true
            }
        }
    }

    private func resetSession() {
        buildDeck()
    }

    // MARK: - Spaced Repetition (SM-2 variant)

    private func loadFlashcardStates() -> [FlashcardState] {
        guard let data = UserDefaults.standard.data(forKey: "flashcardStates"),
              let decoded = try? JSONDecoder().decode([FlashcardState].self, from: data)
        else { return [] }
        return decoded
    }

    private func saveFlashcardStates(_ states: [FlashcardState]) {
        if let data = try? JSONEncoder().encode(states) {
            UserDefaults.standard.set(data, forKey: "flashcardStates")
        }
    }

    private func updateSpacedRepetition(termID: String, rating: FlashcardRating) {
        var states = loadFlashcardStates()
        let now = Date().timeIntervalSince1970

        if let idx = states.firstIndex(where: { $0.termID == termID }) {
            var s = states[idx]
            applyRating(&s, rating: rating, now: now)
            states[idx] = s
        } else {
            var s = FlashcardState(
                termID: termID,
                easeFactor: 2.5,
                interval: 0,
                repetitions: 0,
                nextReviewDate: now
            )
            applyRating(&s, rating: rating, now: now)
            states.append(s)
        }

        saveFlashcardStates(states)
    }

    private func applyRating(_ state: inout FlashcardState, rating: FlashcardRating, now: Double) {
        let q = Double(rating.rawValue)

        if rating == .forgot {
            // Reset
            state.repetitions = 0
            state.interval = 1
            state.easeFactor = max(1.3, state.easeFactor - 0.2)
        } else {
            // SM-2 algorithm
            if state.repetitions == 0 {
                state.interval = 1
            } else if state.repetitions == 1 {
                state.interval = 3
            } else {
                state.interval = Int(Double(state.interval) * state.easeFactor)
            }
            state.repetitions += 1

            // Adjust ease factor
            let newEF = state.easeFactor + (0.1 - (3.0 - q) * (0.08 + (3.0 - q) * 0.02))
            state.easeFactor = max(1.3, newEF)

            // Easy bonus
            if rating == .easy {
                state.interval = Int(Double(state.interval) * 1.3)
            }
        }

        state.nextReviewDate = now + Double(state.interval) * 86400.0
    }
}
