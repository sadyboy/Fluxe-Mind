import SwiftUI

enum FLColor {
    static let abyss = Color(red: 0.02, green: 0.04, blue: 0.12)
    static let deepSea = Color(red: 0.03, green: 0.08, blue: 0.22)
    static let biolumCyan = Color(red: 0.0, green: 0.92, blue: 0.82)
    static let biolumGreen = Color(red: 0.15, green: 0.95, blue: 0.55)
    static let biolumViolet = Color(red: 0.55, green: 0.2, blue: 0.95)
    static let biolumPink = Color(red: 0.95, green: 0.25, blue: 0.65)
    static let auroraA = Color(red: 0.08, green: 0.72, blue: 0.65)
    static let auroraB = Color(red: 0.35, green: 0.15, blue: 0.85)
    static let auroraC = Color(red: 0.1, green: 0.85, blue: 0.45)
    static let warmEmber = Color(red: 0.95, green: 0.45, blue: 0.15)
    static let moltenGold = Color(red: 1.0, green: 0.85, blue: 0.3)
    static let frostedWhite = Color.white.opacity(0.88)
    static let glassStroke = Color.white.opacity(0.18)
    static let glassFill = Color.white.opacity(0.06)

    static let auroraGradient = LinearGradient(
        colors: [auroraB, auroraA, auroraC],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let biolumGradient = LinearGradient(
        colors: [biolumCyan, biolumGreen, biolumViolet],
        startPoint: .leading, endPoint: .trailing
    )
    static let cardGradient = LinearGradient(
        colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

enum FLFont {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    static func mono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }
    static func body(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
}

struct HapticEngine {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { HapticEngine.impact() }
            }
    }
}

extension View {
    func fluxButton() -> some View {
        self.buttonStyle(ScaleButtonStyle())
    }
}
