import SwiftUI

struct AuroraBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let w = size.width, h = size.height

                context.fill(Path(CGRect(origin: .zero, size: size)),
                             with: .color(FLColor.abyss))

                for layer in 0..<4 {
                    let fl = CGFloat(layer)
                    let speed = 0.15 + fl * 0.08
                    let yOffset = h * (0.2 + fl * 0.15)
                    let amplitude = h * (0.08 + fl * 0.04)

                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: h))
                    for x in stride(from: 0, through: w, by: 2) {
                        let normalizedX = x / w
                        let y = yOffset
                            + sin(normalizedX * 3.0 + t * speed) * amplitude
                            + cos(normalizedX * 1.5 - t * speed * 0.7) * amplitude * 0.6
                            + sin(normalizedX * 5.0 + t * speed * 1.3 + fl) * amplitude * 0.3
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.closeSubpath()

                    let colors: [Color]
                    switch layer {
                    case 0: colors = [FLColor.biolumViolet.opacity(0.25), FLColor.auroraB.opacity(0.1)]
                    case 1: colors = [FLColor.auroraA.opacity(0.2), FLColor.biolumCyan.opacity(0.1)]
                    case 2: colors = [FLColor.biolumGreen.opacity(0.15), FLColor.auroraC.opacity(0.08)]
                    default: colors = [FLColor.biolumPink.opacity(0.1), FLColor.biolumViolet.opacity(0.05)]
                    }

                    context.fill(path, with: .linearGradient(
                        Gradient(colors: colors),
                        startPoint: CGPoint(x: 0, y: yOffset - amplitude),
                        endPoint: CGPoint(x: 0, y: h)
                    ))
                }
            }
        }
        .ignoresSafeArea()
    }
}
