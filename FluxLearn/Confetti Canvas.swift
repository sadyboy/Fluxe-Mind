import SwiftUI

struct Particle {
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var rotation: CGFloat
    var rotationSpeed: CGFloat
    var color: Color
    var size: CGFloat
    var life: CGFloat
    var shapeType: Int
}

struct ConfettiCanvasView: View {
    @Binding var isActive: Bool
    @State private var particles: [Particle] = []
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                if canvasSize != size { canvasSize = size }
                for i in particles.indices {
                    particles[i].vy += 180 * (1.0 / 60.0)
                    particles[i].x += particles[i].vx * (1.0 / 60.0)
                    particles[i].y += particles[i].vy * (1.0 / 60.0)
                    particles[i].rotation += particles[i].rotationSpeed * (1.0 / 60.0)
                    particles[i].life -= (1.0 / 60.0) / 3.0

                    guard particles[i].life > 0 else { continue }

                    let p = particles[i]
                    let alpha = max(0, min(1, p.life))
                    let s = p.size

                    context.opacity = alpha
                    context.translateBy(x: p.x, y: p.y)
                    context.rotate(by: .radians(Double(p.rotation)))

                    let rect = CGRect(x: -s/2, y: -s/4, width: s, height: s/2)
                    let shape: Path
                    switch p.shapeType % 3 {
                    case 0: shape = Path(rect)
                    case 1: shape = Path(ellipseIn: rect)
                    default:
                        var tri = Path()
                        tri.move(to: CGPoint(x: 0, y: -s/2))
                        tri.addLine(to: CGPoint(x: s/2, y: s/2))
                        tri.addLine(to: CGPoint(x: -s/2, y: s/2))
                        tri.closeSubpath()
                        shape = tri
                    }

                    context.fill(shape, with: .color(p.color))
                    context.rotate(by: .radians(Double(-p.rotation)))
                    context.translateBy(x: -p.x, y: -p.y)
                    context.opacity = 1
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: isActive) { _, active in
            if active { emit() }
        }
    }

    private func emit() {
        let colors: [Color] = [FLColor.biolumCyan, FLColor.biolumGreen, FLColor.biolumViolet,
                                FLColor.biolumPink, FLColor.moltenGold, FLColor.warmEmber]
        particles = (0..<130).map { i in
            Particle(
                x: canvasSize.width / 2,
                y: canvasSize.height * 0.3,
                vx: CGFloat.random(in: -300...300),
                vy: CGFloat.random(in: -600 ... -100),
                rotation: CGFloat.random(in: 0...(.pi * 2)),
                rotationSpeed: CGFloat.random(in: -8...8),
                color: colors[i % colors.count],
                size: CGFloat.random(in: 4...10),
                life: 1.0,
                shapeType: i % 3
            )
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            isActive = false
            particles = []
        }
    }
}
