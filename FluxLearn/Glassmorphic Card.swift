import SwiftUI

struct GlassmorphicCard<Content: View>: View {
    let topRightCut: CGFloat
    let bottomLeftCut: CGFloat
    let borderGradient: LinearGradient
    let content: () -> Content

    init(
        topRightCut: CGFloat = 22,
        bottomLeftCut: CGFloat = 22,
        borderGradient: LinearGradient = FLColor.biolumGradient,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.topRightCut = topRightCut
        self.bottomLeftCut = bottomLeftCut
        self.borderGradient = borderGradient
        self.content = content
    }

    var body: some View {
        content()
            .background(
                ZStack {
                    CutCornerShape(topRightCut: topRightCut, bottomLeftCut: bottomLeftCut)
                        .fill(.ultraThinMaterial)
                    CutCornerShape(topRightCut: topRightCut, bottomLeftCut: bottomLeftCut)
                        .fill(FLColor.glassFill)
                }
            )
            .clipShape(CutCornerShape(topRightCut: topRightCut, bottomLeftCut: bottomLeftCut))
            .overlay(
                CutCornerShape(topRightCut: topRightCut, bottomLeftCut: bottomLeftCut)
                    .stroke(borderGradient, lineWidth: 1)
            )
    }
}
