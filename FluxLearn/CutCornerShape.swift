import SwiftUI

struct CutCornerShape: Shape {
    var topRightCut: CGFloat
    var bottomLeftCut: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { .init(topRightCut, bottomLeftCut) }
        set { topRightCut = newValue.first; bottomLeftCut = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - topRightCut, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + topRightCut))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + bottomLeftCut, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeftCut))
        p.closeSubpath()
        return p
    }
}

struct ParallelogramShape: Shape {
    var skew: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + skew, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - skew, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct DiamondIndicatorShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX, cy = rect.midY
        p.move(to: CGPoint(x: cx, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: cy))
        p.addLine(to: CGPoint(x: cx, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: cy))
        p.closeSubpath()
        return p
    }
}

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let cx = rect.midX, cy = rect.midY
        let r = min(w, h) / 2
        var p = Path()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let pt = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}
