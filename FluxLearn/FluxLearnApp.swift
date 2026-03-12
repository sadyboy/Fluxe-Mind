// Competitors: 1) World Clock Time Widget (blue/white, grid of clocks, widget-centric)
// 2) Clockology (dark watch-face builder, customization-heavy, no gamification)
// 3) Time Zone Pro (green tint, list-based, utility-first). Differentiators: aurora bioluminescent theme, hexagonal lesson map, drawing-input quiz, constellation achievement map.

import SwiftUI
import CoreData

@main
struct FluxLearnApp: App {
    @AppStorage("onboardingDone") private var onboardingDone = false
    @AppStorage("showSplash") private var showSplash = true
    private let coreDataStack = CoreDataStack.shared
    @StateObject private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            showSplash = false
                        }
                    }
                } else if !onboardingDone {
                    OnboardingView()
                        .environmentObject(gameState)
                } else {
                    GestureNavigationContainer()
                        .environmentObject(gameState)
                        .environment(\.managedObjectContext, coreDataStack.container.viewContext)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
