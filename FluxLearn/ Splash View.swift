import SwiftUI

struct SplashView: View {
    let onComplete: () -> Void
    @State private var revealedLetters = 0
    @State private var logoScale: CGFloat = 0.3
    @State private var arcProgress: CGFloat = 0
    @State private var opacity: Double = 1

    private let appName = "FluxLearn"

    var body: some View {
        ZStack {
            AuroraBackground()
            ConstellationMapView(starCount: 30)
                .opacity(0.6)

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .trim(from: 0, to: arcProgress)
                        .stroke(FLColor.biolumGradient, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    Image(systemName: "hourglass.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            LinearGradient(colors: [FLColor.biolumCyan, FLColor.biolumGreen],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .scaleEffect(logoScale)
                }

                HStack(spacing: 0) {
                    ForEach(0..<appName.count, id: \.self) { i in
                        let ch = String(appName[appName.index(appName.startIndex, offsetBy: i)])
                        Text(ch)
                            .font(FLFont.mono(32))
                            .foregroundColor(i < revealedLetters ? .white : .clear)
                    }
                }
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                logoScale = 1.0
            }
            withAnimation(.linear(duration: 3)) {
                arcProgress = 1.0
            }
            for i in 0..<appName.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.12) {
                    withAnimation(.easeOut(duration: 0.15)) { revealedLetters = i + 1 }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.4)) { opacity = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { onComplete() }
            }
        }
    }
}
