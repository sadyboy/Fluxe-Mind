import SwiftUI

struct GlossaryView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedTopic: GlossaryTopic? = nil
    @State private var expandedTermID: String? = nil
    @State private var showFlashcards = false

    private var filteredTerms: [GlossaryTerm] {
        GlossaryRepository.all.filter { term in
            let matchesSearch = searchText.isEmpty ||
                term.term.localizedCaseInsensitiveContains(searchText) ||
                term.definition.localizedCaseInsensitiveContains(searchText)
            let matchesTopic = selectedTopic == nil || term.topic == selectedTopic
            return matchesSearch && matchesTopic
        }
    }

    private var groupedTerms: [(letter: String, terms: [GlossaryTerm])] {
        let grouped = Dictionary(grouping: filteredTerms) { term in
            String(term.term.prefix(1)).uppercased()
        }
        return grouped.sorted { $0.key < $1.key }
            .map { (letter: $0.key, terms: $0.value.sorted { $0.term < $1.term }) }
    }

    var body: some View {
        ZStack {
            AuroraBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    searchBar
                    topicFilters
                    flashcardButton

                    Text("\(filteredTerms.count) terms")
                        .font(FLFont.mono(11))
                        .foregroundColor(.white.opacity(0.35))
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    ForEach(groupedTerms, id: \.letter) { group in
                        sectionView(letter: group.letter, terms: group.terms)
                    }

                    if filteredTerms.isEmpty {
                        emptyState
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $showFlashcards) {
            FlashcardView()
                .environmentObject(gameState)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(10)
                    .background(FLColor.glassFill)
                    .clipShape(Circle())
            }
            Spacer()
            Text("Glossary")
                .font(FLFont.display(24))
                .foregroundColor(.white)
            Spacer()
            // Balance the X button
            Color.clear.frame(width: 38, height: 38)
        }
        .padding(.top, 16)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(FLColor.biolumGradient)
            TextField("Search terms…", text: $searchText)
                .font(FLFont.body(15))
                .foregroundColor(.white)
                .autocorrectionDisabled()
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .padding(12)
        .background(FLColor.glassFill)
        .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
        .overlay(CutCornerShape(topRightCut: 12, bottomLeftCut: 12).stroke(FLColor.glassStroke, lineWidth: 1))
    }

    // MARK: - Topic Filters

    private var topicFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                topicChip(nil, label: "All", icon: "square.grid.2x2.fill")
                ForEach(GlossaryTopic.allCases) { topic in
                    topicChip(topic, label: topic.rawValue, icon: topic.icon)
                }
            }
        }
    }

    private func topicChip(_ topic: GlossaryTopic?, label: String, icon: String) -> some View {
        let isSelected = selectedTopic == topic
        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedTopic = topic
            }
            HapticEngine.impact(.light)
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(label)
                    .font(FLFont.body(11))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? (topic?.color ?? FLColor.biolumCyan).opacity(0.25) : FLColor.glassFill)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(
                    isSelected ? (topic?.color ?? FLColor.biolumCyan).opacity(0.5) : FLColor.glassStroke,
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Flashcard Button

    private var flashcardButton: some View {
        Button {
            showFlashcards = true
            HapticEngine.impact()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.on.rectangle.angled")
                    .foregroundStyle(FLColor.biolumGradient)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Flashcard Mode")
                        .font(FLFont.body(14))
                        .foregroundColor(.white)
                    Text("Spaced repetition · \(GlossaryRepository.all.count) cards")
                        .font(FLFont.mono(10))
                        .foregroundColor(.white.opacity(0.4))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(14)
            .background(FLColor.glassFill)
            .clipShape(CutCornerShape(topRightCut: 12, bottomLeftCut: 12))
            .overlay(CutCornerShape(topRightCut: 12, bottomLeftCut: 12).stroke(FLColor.biolumCyan.opacity(0.3), lineWidth: 1))
        }
        .fluxButton()
    }

    // MARK: - Term Sections

    private func sectionView(letter: String, terms: [GlossaryTerm]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(letter)
                .font(FLFont.display(20))
                .foregroundStyle(FLColor.biolumGradient)
                .padding(.leading, 4)

            ForEach(terms) { term in
                termCard(term)
            }
        }
    }

    private func termCard(_ term: GlossaryTerm) -> some View {
        let isExpanded = expandedTermID == term.id

        return Button {
            withAnimation(.spring(response: 0.3)) {
                expandedTermID = isExpanded ? nil : term.id
            }
            HapticEngine.impact(.light)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Title row
                HStack(spacing: 10) {
                    Image(systemName: term.topic.icon)
                        .font(.caption)
                        .foregroundColor(term.topic.color)
                        .frame(width: 24)

                    Text(term.term)
                        .font(FLFont.body(15))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)

                // Expanded content
                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        Divider().background(Color.white.opacity(0.1))

                        Text(term.definition)
                            .font(FLFont.body(13))
                            .foregroundColor(.white.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)

                        // Topic badge
                        HStack(spacing: 6) {
                            Image(systemName: term.topic.icon)
                                .font(.system(size: 9))
                            Text(term.topic.rawValue)
                                .font(FLFont.mono(10))
                        }
                        .foregroundColor(term.topic.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(term.topic.color.opacity(0.12))
                        .clipShape(Capsule())

                        // Related terms
                        if !term.relatedTerms.isEmpty {
                            let relatedFull = term.relatedTerms.compactMap { relID in
                                GlossaryRepository.all.first(where: { $0.id == relID })
                            }
                            if !relatedFull.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Related")
                                        .font(FLFont.mono(10))
                                        .foregroundColor(.white.opacity(0.35))
                                    FlowLayout(spacing: 6) {
                                        ForEach(relatedFull) { related in
                                            Button {
                                                withAnimation(.spring(response: 0.3)) {
                                                    expandedTermID = related.id
                                                }
                                            } label: {
                                                Text(related.term)
                                                    .font(FLFont.body(11))
                                                    .foregroundColor(FLColor.biolumCyan)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(FLColor.biolumCyan.opacity(0.1))
                                                    .clipShape(Capsule())
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
                }
            }
            .background(FLColor.glassFill)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isExpanded ? term.topic.color.opacity(0.3) : FLColor.glassStroke, lineWidth: isExpanded ? 1.2 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(FLColor.biolumGradient)
            Text("No terms found")
                .font(FLFont.display(18))
                .foregroundColor(.white)
            Text("Try a different search or topic")
                .font(FLFont.body(13))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.top, 40)
    }
}

// MARK: - Flow Layout (for related term chips)

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
