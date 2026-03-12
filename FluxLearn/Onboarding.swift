import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @EnvironmentObject var gameState: GameState
    @AppStorage("onboardingDone") private var onboardingDone = false
    @State private var step = 0
    @State private var skillAnswers = 0
    @State private var selectedDays = 5
    @State private var selectedAvatar = 0
    @State private var nameText = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var slideOffset: CGFloat = 0

    private let avatarIcons = ["fish.fill", "tortoise.fill", "hare.fill", "ant.fill", "ladybug.fill", "leaf.fill"]

    var body: some View {
        ZStack {
            AuroraBackground()
            VStack(spacing: 0) {
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                TabView(selection: $step) {
                    cinematicStep.tag(0)
                    skillQuizStep.tag(1)
                    commitmentStep.tag(2)
                    avatarStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5), value: step)
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                ParallelogramShape()
                    .fill(Color.white.opacity(0.1))
                ParallelogramShape()
                    .fill(FLColor.biolumGradient)
                    .frame(width: geo.size.width * CGFloat(step + 1) / 4.0)
                    .animation(.spring(), value: step)
            }
        }
        .frame(height: 6)
    }

    private var cinematicStep: some View {
        VStack(spacing: 30) {
            Spacer()
            Image(systemName: "clock.arrow.2.circlepath")
                .font(.system(size: 80))
                .foregroundStyle(FLColor.biolumGradient)
                .symbolEffect(.pulse)
            Text("Your journey\nstarts here")
                .font(FLFont.display(30))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            Text("Explore the science of time through\nthe depths of a bioluminescent ocean")
                .font(FLFont.body(16))
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            nextButton { step = 1 }
        }
        .padding(24)
    }

    private var skillQuizStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Quick Skill Check")
                .font(FLFont.display(26))
                .foregroundColor(.white)
            GlassmorphicCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("What is a gnomon?")
                        .font(FLFont.body(18))
                        .foregroundColor(.white)
                    ForEach(["Shadow-casting part of a sundial", "A type of gear", "A water vessel", "A pendulum weight"], id: \.self) { opt in
                        Button {
                            if opt.contains("Shadow") { skillAnswers += 1 }
                            HapticEngine.impact()
                        } label: {
                            Text(opt)
                                .font(FLFont.body(14))
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(FLColor.glassFill)
                                .clipShape(CutCornerShape(topRightCut: 8, bottomLeftCut: 8))
                        }
                        .fluxButton()
                    }
                }
                .padding(20)
            }

            HStack(spacing: 12) {
                ForEach(["Beginner", "Intermediate", "Expert"], id: \.self) { tier in
                    Button {
                        gameState.skillTier = tier == "Beginner" ? 0 : tier == "Intermediate" ? 1 : 2
                        HapticEngine.impact()
                    } label: {
                        Text(tier)
                            .font(FLFont.body(12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                gameState.skillTier == (tier == "Beginner" ? 0 : tier == "Intermediate" ? 1 : 2)
                                ? FLColor.biolumCyan.opacity(0.3) : FLColor.glassFill
                            )
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(FLColor.glassStroke, lineWidth: 1))
                    }
                    .fluxButton()
                }
            }
            Spacer()
            nextButton { step = 2 }
        }
        .padding(24)
    }

    private var commitmentStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Set Your Goal")
                .font(FLFont.display(26))
                .foregroundColor(.white)
            Text("Days per week")
                .font(FLFont.body(16))
                .foregroundColor(.white.opacity(0.6))
            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    Button {
                        selectedDays = day
                        gameState.daysPerWeekGoal = day
                        HapticEngine.impact(.light)
                    } label: {
                        Text("\(day)")
                            .font(FLFont.mono(16))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(day <= selectedDays ? FLColor.auroraA.opacity(0.5) : FLColor.glassFill)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(day == selectedDays ? FLColor.biolumCyan : FLColor.glassStroke, lineWidth: 1))
                    }
                    .fluxButton()
                }
            }
            GlassmorphicCard {
                HStack {
                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                        let idx = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"].firstIndex(of: day)!
                        VStack(spacing: 4) {
                            Text(day)
                                .font(FLFont.body(10))
                                .foregroundColor(.white.opacity(0.5))
                            Circle()
                                .fill(idx < selectedDays ? FLColor.biolumCyan : Color.white.opacity(0.1))
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .padding(16)
            }
            Spacer()
            nextButton { step = 3 }
        }
        .padding(24)
    }

    private var avatarStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Choose Your Identity")
                .font(FLFont.display(26))
                .foregroundColor(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(0..<6, id: \.self) { i in
                    Button {
                        selectedAvatar = i
                        gameState.avatarIndex = i
                        HapticEngine.impact()
                    } label: {
                        Image(systemName: avatarIcons[i])
                            .font(.title)
                            .foregroundStyle(FLColor.biolumGradient)
                            .frame(width: 70, height: 70)
                            .background(i == selectedAvatar ? FLColor.biolumCyan.opacity(0.2) : FLColor.glassFill)
                            .clipShape(HexagonShape())
                            .overlay(
                                HexagonShape()
                                    .stroke(i == selectedAvatar ? FLColor.biolumCyan : FLColor.glassStroke, lineWidth: 1.5)
                            )
                    }
                    .fluxButton()
                }
            }
            .padding(.horizontal)

            PhotosPicker(selection: $photoItem, matching: .images) {
                Label("Use Photo", systemImage: "photo.on.rectangle")
                    .font(FLFont.body(14))
                    .foregroundColor(FLColor.biolumCyan)
            }

            TextField("Your Name", text: $nameText)
                .font(FLFont.body(18))
                .foregroundColor(.white)
                .padding(14)
                .background(FLColor.glassFill)
                .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
                .overlay(CutCornerShape(topRightCut: 12, bottomLeftCut: 12).stroke(FLColor.glassStroke, lineWidth: 1))
                .autocorrectionDisabled()

            Spacer()
            Button {
                gameState.userName = nameText.isEmpty ? "Explorer" : nameText
                onboardingDone = true
                HapticEngine.impact(.heavy)
            } label: {
                Text("Begin Exploration")
                    .font(FLFont.display(18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(FLColor.auroraGradient)
                    .clipShape(CutCornerShape(topRightCut: 16, bottomLeftCut: 16))
            }
            .fluxButton()
        }
        .padding(24)
    }

    private func nextButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text("Continue")
                    .font(FLFont.body(18))
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(FLColor.biolumGradient)
            .clipShape(CutCornerShape(topRightCut: 16, bottomLeftCut: 16))
        }
        .fluxButton()
    }
}
