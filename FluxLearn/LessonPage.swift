import SwiftUI

struct LessonPage: Identifiable {
    let id = UUID()
    let title: String
    let explanation: String
    let codeExample: String?
    let hint: String?
}

struct LessonPageView: View {
    let page: LessonPage
    @State private var showHint = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(page.title)
                    .font(FLFont.display(22))
                    .foregroundColor(.white)

                Text(page.explanation)
                    .font(FLFont.body(15))
                    .foregroundColor(.white.opacity(0.75))
                    .lineSpacing(5)

                if let code = page.codeExample {
                    codeBlock(code)
                }

                if let hint = page.hint {
                    hintSection(hint)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal)
            .padding(.top, 24)
        }
    }

    // MARK: - Code Block

    private func codeBlock(_ code: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.caption.weight(.semibold))
                Text("Example")
                    .font(FLFont.body(12))
                Spacer()
                Button {
                    UIPasteboard.general.string = code
                    HapticEngine.impact(.light)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                }
            }
            .foregroundColor(FLColor.biolumCyan.opacity(0.7))

            Text(code)
                .font(.system(.callout, design: .monospaced))
                .foregroundColor(FLColor.biolumGreen)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(FLColor.abyss.opacity(0.8))
                .clipShape(CutCornerShape(topRightCut: 10, bottomLeftCut: 10))
                .overlay(
                    CutCornerShape(topRightCut: 10, bottomLeftCut: 10)
                        .stroke(FLColor.biolumCyan.opacity(0.3), lineWidth: 0.5)
                )
        }
    }

    // MARK: - Hint Section

    private func hintSection(_ hint: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { showHint.toggle() }
            HapticEngine.impact(.light)
        } label: {
            VStack(alignment: .leading, spacing: showHint ? 8 : 0) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(FLColor.moltenGold)
                    Text("Hint")
                        .font(FLFont.body(14))
                        .foregroundColor(FLColor.moltenGold)
                    Spacer()
                    Image(systemName: showHint ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(FLColor.moltenGold.opacity(0.6))
                }

                if showHint {
                    Text(hint)
                        .font(FLFont.body(13))
                        .foregroundColor(.white.opacity(0.7))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(14)
            .background(FLColor.moltenGold.opacity(0.08))
            .clipShape(CutCornerShape(topRightCut: 8, bottomLeftCut: 8))
            .overlay(
                CutCornerShape(topRightCut: 8, bottomLeftCut: 8)
                    .stroke(FLColor.moltenGold.opacity(0.2), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}
