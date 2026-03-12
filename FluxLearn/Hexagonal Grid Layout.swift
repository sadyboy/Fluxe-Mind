import SwiftUI

struct HexGridLayout: Layout {
    var hexWidth: CGFloat = 80
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let cols = max(1, Int((proposal.width ?? 350) / (hexWidth + spacing)))
        let rows = (subviews.count + cols - 1) / cols
        let rowHeight = hexWidth * 0.87 + spacing
        return CGSize(width: proposal.width ?? 350, height: CGFloat(rows) * rowHeight + hexWidth * 0.5)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let cols = max(1, Int(bounds.width / (hexWidth + spacing)))
        let rowHeight = hexWidth * 0.87 + spacing

        for (index, subview) in subviews.enumerated() {
            let row = index / cols
            let col = index % cols
            let xOffset: CGFloat = (row % 2 == 1) ? (hexWidth + spacing) * 0.5 : 0
            let x = bounds.minX + CGFloat(col) * (hexWidth + spacing) + xOffset + hexWidth / 2
            let y = bounds.minY + CGFloat(row) * rowHeight + hexWidth / 2

            subview.place(at: CGPoint(x: x, y: y), anchor: .center, proposal: .init(width: hexWidth, height: hexWidth))
        }
    }
}
