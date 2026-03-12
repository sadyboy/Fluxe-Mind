import SwiftUI

struct GestureNavigationContainer: View {
    @EnvironmentObject var gameState: GameState
    @State private var currentTab = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showScreenPicker = false
    @State private var pickerDragOffset: CGFloat = 0

    private let tabCount = 5
    private let tabIcons = ["sparkles", "book.closed.fill", "puzzlepiece.fill", "chart.bar.fill", "trophy.fill"]
    private let tabNames = ["Dashboard", "Library", "Gauntlet", "Observatory", "Legacy"]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                AuroraBackground()

                tabContent(for: currentTab)
                    .frame(width: geo.size.width)
                    .offset(x: dragOffset)

                VStack {
                    dotIndicator
                        .padding(.top, 8)
                    Spacer()
                }

                if showScreenPicker {
                    screenPickerOverlay(geo: geo)
                }

                ConfettiCanvasView(isActive: $gameState.showConfetti)

                if gameState.showLevelUp {
                    levelUpOverlay
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.startLocation.y < 60 {
                            pickerDragOffset = value.translation.height
                            if pickerDragOffset > 40 { showScreenPicker = true }
                        } else {
                            let resistance: CGFloat = (currentTab == 0 && value.translation.width > 0) ||
                                (currentTab == tabCount - 1 && value.translation.width < 0) ? 0.3 : 1.0
                            dragOffset = value.translation.width * resistance
                        }
                    }
                    .onEnded { value in
                        if value.startLocation.y < 60 {
                            withAnimation(.spring()) { pickerDragOffset = 0 }
                            return
                        }
                        let threshold: CGFloat = geo.size.width * 0.2
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if value.translation.width < -threshold && currentTab < tabCount - 1 {
                                currentTab += 1
                                HapticEngine.impact(.light)
                            } else if value.translation.width > threshold && currentTab > 0 {
                                currentTab -= 1
                                HapticEngine.impact(.light)
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
        .onAppear { gameState.updateStreak() }
    }

    @ViewBuilder
    private func tabContent(for index: Int) -> some View {
        switch index {
        case 0: DashboardView()
        case 1: LessonBrowserView()
        case 2: QuizView()
        case 3: StatsView()
        case 4: ProfileView()
        default: EmptyView()
        }
    }

    private var dotIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<tabCount, id: \.self) { i in
                Capsule()
                    .fill(i == currentTab
                          ? LinearGradient(colors: [FLColor.biolumCyan, FLColor.biolumGreen],
                                           startPoint: .leading, endPoint: .trailing)
                          : LinearGradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.3)],
                                           startPoint: .leading, endPoint: .trailing))
                    .frame(width: i == currentTab ? 28 : 8, height: 4)
                    .animation(.spring(response: 0.35), value: currentTab)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial.opacity(0.5))
        .clipShape(Capsule())
    }

    private func screenPickerOverlay(geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<tabCount, id: \.self) { i in
                        Button {
                            withAnimation(.spring(response: 0.4)) {
                                currentTab = i
                                showScreenPicker = false
                            }
                            HapticEngine.impact()
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: tabIcons[i])
                                    .font(.title2)
                                    .foregroundStyle(FLColor.biolumGradient)
                                    .frame(width: 60, height: 44)
                                    .background(i == currentTab ? FLColor.glassFill : Color.clear)
                                    .clipShape(CutCornerShape(topRightCut: 10, bottomLeftCut: 10))
                                    .overlay(
                                        CutCornerShape(topRightCut: 10, bottomLeftCut: 10)
                                            .stroke(i == currentTab ? FLColor.biolumCyan.opacity(0.6) : Color.clear, lineWidth: 1)
                                    )
                                Text(tabNames[i])
                                    .font(FLFont.body(10))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .fluxButton()
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 90)
            .background(.ultraThinMaterial)
            .clipShape(CutCornerShape(topRightCut: 0, bottomLeftCut: 20))
            .overlay(
                CutCornerShape(topRightCut: 0, bottomLeftCut: 20)
                    .stroke(FLColor.glassStroke, lineWidth: 0.5)
            )
            .transition(.move(edge: .top).combined(with: .opacity))

            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) { showScreenPicker = false }
                }
        }
    }

    private var levelUpOverlay: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) { gameState.showLevelUp = false }
                }
            VStack(spacing: 20) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(colors: [FLColor.moltenGold, FLColor.warmEmber],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .scaleEffect(1.2)
                Text("LEVEL UP!")
                    .font(FLFont.display(34))
                    .foregroundStyle(FLColor.biolumGradient)
                Text(gameState.newLevelName)
                    .font(FLFont.display(28))
                    .foregroundColor(FLColor.moltenGold)
                Text("Tier \(gameState.currentLevel + 1) of 10")
                    .font(FLFont.mono(16))
                    .foregroundColor(.white.opacity(0.6))
                Button {
                    withAnimation(.spring()) { gameState.showLevelUp = false }
                    HapticEngine.impact()
                } label: {
                    Text("Continue")
                        .font(FLFont.body(18))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(FLColor.auroraGradient)
                        .clipShape(CutCornerShape(topRightCut: 14, bottomLeftCut: 14))
                }
                .fluxButton()
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(CutCornerShape(topRightCut: 30, bottomLeftCut: 30))
            .overlay(
                CutCornerShape(topRightCut: 30, bottomLeftCut: 30)
                    .stroke(FLColor.moltenGold.opacity(0.5), lineWidth: 1.5)
            )
        }
    }
}
