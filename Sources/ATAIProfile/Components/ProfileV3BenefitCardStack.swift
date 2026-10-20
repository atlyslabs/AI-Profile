import ATUIKit
import SwiftUI

struct ProfileV3BenefitCardStack: View {
    let benefits: [ProfileV3Benefit]
    var isVisible = true
    let viewAllLabel: String
    var onSelect: ((ProfileV3Benefit) -> Void)?
    var expandedID: String?
    let onViewAll: () -> Void
    var onFrontImpression: ((ProfileV3Benefit, Int) -> Void)?

    @State private var frontPosition = 0
    @State private var isOnScreen = false
    @State private var width: CGFloat = ProfileV3Theme.Sizes.stackFallbackWidth
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var layerCount: Int { min(benefits.count, ProfileV3Theme.Counts.stackLayers) }
    private var isRotating: Bool { benefits.count > 1 && expandedID == nil && isVisible }

    private var rotation: ProfileV3StackRotation {
        ProfileV3StackRotation(benefitIDs: benefits.map(\.id), isRotating: isRotating)
    }

    private var positions: [Int] {
        Array((frontPosition..<(frontPosition + layerCount)).reversed())
    }

    var body: some View {
        VStack(spacing: ProfileV3Theme.Space.s20) {
            ZStack(alignment: .top) {
                ForEach(layerCount..<ProfileV3Theme.Counts.stackLayers, id: \.self) { layer in
                    placeholder(layer: layer)
                }
                ForEach(positions, id: \.self) { position in
                    card(at: position)
                }
            }
            .padding(.bottom, ProfileV3Theme.Sizes.stackThirdPeek)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
            if !viewAllLabel.isEmpty {
                ProfileV3PillButton(title: viewAllLabel, action: onViewAll)
            }
        }
        .profileV3OnImpression {
            isOnScreen = true
            reportFront()
        }
        .onChange(of: frontPosition) { _, _ in
            if isOnScreen { reportFront() }
        }
        .onChange(of: rotation.benefitIDs) { _, _ in frontPosition = 0 }
        .task(id: rotation) {
            guard rotation.isRotating else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.stackRotateSeconds))
                guard !Task.isCancelled, !benefits.isEmpty else { return }
                withAnimation(reduceMotion ? nil : ProfileV3Theme.Motion.stackRotate) {
                    frontPosition += 1
                }
            }
        }
    }

    private func reportFront() {
        guard !benefits.isEmpty else { return }
        let index = frontPosition % benefits.count
        onFrontImpression?(benefits[index], index)
    }

    private func card(at position: Int) -> some View {
        let layer = position - frontPosition
        let benefit = benefits[position % benefits.count]
        let isFront = layer == 0
        return ProfileV3BenefitCard(
            benefit: benefit,
            contentOpacity: contentOpacity(for: layer),
            onSelect: onSelect.map { select in { select(benefit) } }
        )
        .scaleEffect(scale(for: layer), anchor: .bottom)
        .offset(y: peek(for: layer))
        .allowsHitTesting(isFront)
        .accessibilityHidden(!isFront)
        .zIndex(Double(-position))
        .transition(.asymmetric(insertion: entrance, removal: exit))
    }

    private func placeholder(layer: Int) -> some View {
        Color(at: .pureWhite)
            .frame(maxWidth: .infinity)
            .frame(height: ProfileV3Theme.Sizes.Benefit.cardHeight)
            .profileV3Card()
            .scaleEffect(scale(for: layer), anchor: .bottom)
            .offset(y: peek(for: layer))
            .zIndex(Double(-(frontPosition + layer)))
            .accessibilityHidden(true)
    }

    private var entrance: AnyTransition {
        .opacity.animation(ProfileV3Theme.Motion.stackEnter)
    }

    private var exit: AnyTransition {
        let fade = AnyTransition.opacity
        let lift = reduceMotion ? fade : fade.combined(with: .offset(y: ProfileV3Theme.Motion.stackExitOffset))
        return lift.animation(ProfileV3Theme.Motion.stackExit)
    }

    private func scale(for layer: Int) -> CGFloat {
        guard width > 0 else { return 1 }
        return 1 - 2 * inset(for: layer) / width
    }

    private func inset(for layer: Int) -> CGFloat {
        switch layer {
        case 0: return 0
        case 1: return ProfileV3Theme.Space.s12
        default: return ProfileV3Theme.Sizes.stackThirdInset
        }
    }

    private func contentOpacity(for layer: Int) -> Double {
        switch layer {
        case 0: return 1
        case 1: return ProfileV3Theme.Opacity.stackSecondLayer
        default: return ProfileV3Theme.Opacity.stackThirdLayer
        }
    }

    private func peek(for layer: Int) -> CGFloat {
        switch layer {
        case 0: return 0
        case 1: return ProfileV3Theme.Sizes.stackSecondPeek
        default: return ProfileV3Theme.Sizes.stackThirdPeek
        }
    }
}

private struct ProfileV3StackRotation: Hashable {
    let benefitIDs: [String]
    let isRotating: Bool
}

#if DEBUG
#Preview("Benefit card stack") {
    ProfileV3BenefitCardStack(
        benefits: Array(ProfileV3BenefitCatalogue.all.prefix(4)),
        viewAllLabel: ProfileV3Strings.viewAllBenefits(24),
        onSelect: { _ in },
        onViewAll: {}
    )
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
