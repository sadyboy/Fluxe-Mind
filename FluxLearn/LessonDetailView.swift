import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @EnvironmentObject var gameState: GameState
    @State private var currentPage = 0
    @State private var showQuiz = false
    @Environment(\.dismiss) private var dismiss

    var pages: [LessonPage] {
        LessonContent.pages(for: lesson.title)
    }

    var body: some View {
        ZStack {
            AuroraBackground()

            VStack(spacing: 0) {
                headerView
                progressBar

                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        LessonPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                navigationButtons
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showQuiz) {
            LessonQuizView(lesson: lesson)
                .environmentObject(gameState)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(FLColor.glassFill)
                    .clipShape(Circle())
            }

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: lesson.icon)
                    .foregroundStyle(
                        LinearGradient(colors: lesson.gradient, startPoint: .leading, endPoint: .trailing)
                    )
                Text(lesson.title)
                    .font(FLFont.body(16))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }

            Spacer()

            Text("\(currentPage + 1)/\(pages.count)")
                .font(FLFont.mono(12))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                ParallelogramShape()
                    .fill(Color.white.opacity(0.1))
                ParallelogramShape()
                    .fill(LinearGradient(colors: lesson.gradient, startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * CGFloat(currentPage + 1) / CGFloat(max(pages.count, 1)))
                    .animation(.spring(response: 0.4), value: currentPage)
            }
        }
        .frame(height: 4)
        .padding(.horizontal)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentPage > 0 {
                Button {
                    currentPage -= 1
                    HapticEngine.impact(.light)
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(FLFont.body(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(FLColor.glassFill)
                    .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
                    .overlay(CutCornerShape(topRightCut: 12, bottomLeftCut: 12).stroke(FLColor.glassStroke, lineWidth: 1))
                }
                .fluxButton()
            }

            Button {
                if currentPage < pages.count - 1 {
                    currentPage += 1
                    HapticEngine.impact(.light)
                } else {
                    showQuiz = true
                    HapticEngine.impact(.medium)
                }
            } label: {
                HStack {
                    Text(currentPage < pages.count - 1 ? "Next" : "Take Quiz")
                    Image(systemName: currentPage < pages.count - 1 ? "chevron.right" : "checkmark.circle")
                }
                .font(FLFont.body(16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(LinearGradient(colors: lesson.gradient, startPoint: .leading, endPoint: .trailing))
                .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
            }
            .fluxButton()
        }
        .padding()
    }
}
