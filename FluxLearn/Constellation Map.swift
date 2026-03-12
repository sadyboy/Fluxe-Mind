import SwiftUI

struct Star {
    var x: CGFloat
    var y: CGFloat
    var radius: CGFloat
    var brightness: CGFloat
    var twinkleSpeed: CGFloat
    var twinklePhase: CGFloat
}

struct ConstellationMapView: View {
    let starCount: Int

    @State private var stars: [Star] = []
    @State private var lines: [(Int, Int)] = []

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate

                // Draw constellation lines
                for (a, b) in lines {
                    guard a < stars.count, b < stars.count else { continue }
                    let sa = stars[a], sb = stars[b]
                    let alphaA = (0.3 + 0.2 * sin(t * sa.twinkleSpeed + sa.twinklePhase))
                    let alphaB = (0.3 + 0.2 * sin(t * sb.twinkleSpeed + sb.twinklePhase))
                    let lineAlpha = min(alphaA, alphaB)

                    var path = Path()
                    path.move(to: CGPoint(x: sa.x * size.width, y: sa.y * size.height))
                    path.addLine(to: CGPoint(x: sb.x * size.width, y: sb.y * size.height))

                    context.stroke(path,
                                   with: .color(FLColor.biolumCyan.opacity(lineAlpha * 0.5)),
                                   lineWidth: 0.5)
                }

                // Draw stars
                for star in stars {
                    let twinkle = 0.4 + 0.6 * (0.5 + 0.5 * sin(t * star.twinkleSpeed + star.twinklePhase))
                    let alpha = star.brightness * twinkle
                    let r = star.radius * (0.8 + 0.2 * twinkle)

                    let center = CGPoint(x: star.x * size.width, y: star.y * size.height)

                    // Glow
                    let glowRect = CGRect(x: center.x - r * 3, y: center.y - r * 3, width: r * 6, height: r * 6)
                    context.fill(Path(ellipseIn: glowRect),
                                 with: .color(FLColor.biolumCyan.opacity(alpha * 0.15)))

                    // Core
                    let coreRect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
                    context.fill(Path(ellipseIn: coreRect),
                                 with: .color(Color.white.opacity(alpha)))
                }
            }
        }
        .onAppear { generateField() }
        .allowsHitTesting(false)
    }

    private func generateField() {
        stars = (0..<starCount).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                radius: CGFloat.random(in: 0.8...2.5),
                brightness: CGFloat.random(in: 0.3...1.0),
                twinkleSpeed: CGFloat.random(in: 0.5...3.0),
                twinklePhase: CGFloat.random(in: 0...(.pi * 2))
            )
        }

        // Create some constellation lines between nearby stars
        var constellationLines: [(Int, Int)] = []
        for i in 0..<stars.count {
            for j in (i + 1)..<stars.count {
                let dx = stars[i].x - stars[j].x
                let dy = stars[i].y - stars[j].y
                let dist = sqrt(dx * dx + dy * dy)
                if dist < 0.18 && constellationLines.count < starCount / 2 {
                    constellationLines.append((i, j))
                }
            }
        }
        lines = constellationLines
    }
}
