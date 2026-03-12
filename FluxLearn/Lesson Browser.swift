import SwiftUI

struct LessonBrowserView: View {
    @EnvironmentObject var gameState: GameState
    @State private var searchText = ""
    @State private var filterDifficulty: Lesson.Difficulty? = nil
    @State private var selectedLesson: Lesson? = nil

    private var filteredLessons: [Lesson] {
        LessonRepository.all.filter { lesson in
            let matchesSearch = searchText.isEmpty || lesson.title.localizedCaseInsensitiveContains(searchText)
            let matchesDifficulty = filterDifficulty == nil || lesson.difficulty == filterDifficulty
            return matchesSearch && matchesDifficulty
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                Text("Deep Dive Library")
                    .font(FLFont.display(28))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)

                searchBar
                filterChips

                if filteredLessons.isEmpty {
                    emptyState
                } else {
                    HexGridLayout(hexWidth: 80, spacing: 10) {
                        ForEach(filteredLessons) { lesson in
                            hexCell(lesson: lesson)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .fullScreenCover(item: $selectedLesson) { lesson in
            LessonDetailView(lesson: lesson)
                .environmentObject(gameState)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(FLColor.biolumGradient)
            TextField("Search lessons", text: $searchText)
                .font(FLFont.body(16))
                .foregroundColor(.white)
        }
        .padding(12)
        .background(FLColor.glassFill)
        .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
        .overlay(CutCornerShape(topRightCut: 12, bottomLeftCut: 12).stroke(FLColor.glassStroke, lineWidth: 1))
        .accessibilityLabel("Search lessons")
    }

    private var filterChips: some View {
        HStack(spacing: 8) {
            chipButton("All", isSelected: filterDifficulty == nil) { filterDifficulty = nil }
            chipButton("Beginner", isSelected: filterDifficulty == .beginner) { filterDifficulty = .beginner }
            chipButton("Intermediate", isSelected: filterDifficulty == .intermediate) { filterDifficulty = .intermediate }
            chipButton("Expert", isSelected: filterDifficulty == .expert) { filterDifficulty = .expert }
        }
    }

    private func chipButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
            HapticEngine.impact(.light)
        } label: {
            Text(title)
                .font(FLFont.body(12))
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? FLColor.biolumCyan.opacity(0.25) : FLColor.glassFill)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isSelected ? FLColor.biolumCyan.opacity(0.5) : FLColor.glassStroke, lineWidth: 1))
        }
        .fluxButton()
    }

    private func hexCell(lesson: Lesson) -> some View {
        let state = gameState.lessonStates.first(where: { $0.id == lesson.id })
        let isLocked = state?.isLocked ?? true
        let isCompleted = state?.isCompleted ?? false

        return Button {
            guard !isLocked else { return }
            selectedLesson = lesson
            HapticEngine.impact()
        } label: {
            ZStack {
                HexagonShape()
                    .fill(
                        LinearGradient(colors: isLocked ? [Color.gray.opacity(0.2)] : lesson.gradient,
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .opacity(isLocked ? 0.2 : 1.0)
                HexagonShape()
                    .stroke(isCompleted ? FLColor.moltenGold : (isLocked ? Color.gray.opacity(0.3) : FLColor.glassStroke),
                            lineWidth: isCompleted ? 2 : 1)

                VStack(spacing: 2) {
                    Image(systemName: isLocked ? "lock.fill" : lesson.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isLocked ? .gray : .white)
                    Text(lesson.abbreviation)
                        .font(FLFont.mono(9))
                        .foregroundColor(isLocked ? .gray.opacity(0.5) : .white.opacity(0.8))
                }
            }
            .frame(width: 80, height: 80)
        }
        .fluxButton()
        .disabled(isLocked)
        .accessibilityLabel("\(lesson.title), \(isLocked ? "locked" : isCompleted ? "completed" : "available")")
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 60))
                .foregroundStyle(FLColor.biolumGradient)
                .symbolEffect(.pulse)
            Text("No lessons found")
                .font(FLFont.display(20))
                .foregroundColor(.white)
            Text("Try a different search or filter")
                .font(FLFont.body(14))
                .foregroundColor(.white.opacity(0.5))
            Button {
                searchText = ""
                filterDifficulty = nil
                HapticEngine.impact()
            } label: {
                Text("Clear Filters")
                    .font(FLFont.body(14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(FLColor.auroraGradient)
                    .clipShape(CutCornerShape(topRightCut: 10, bottomLeftCut: 10))
            }
            .fluxButton()
        }
        .padding(.top, 60)
    }
}
