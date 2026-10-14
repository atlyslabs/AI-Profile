import ATUIKit
import SwiftUI

struct ProfileV3BaggagePicker: View {
    let field: ProfileV3BaggageField
    let selectedTabID: String?
    let onSelectTab: (String) -> Void
    let onToggle: (String) -> Void
    let onStep: (String, Int) -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.Baggage

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Sizes.gridSpacing), count: 2)
    }

    var body: some View {
        let tab = field.tab(id: selectedTabID)
        VStack(spacing: Sizes.gridTop) {
            if field.tabs.count > 1 {
                ProfileV3BaggageTabs(tabs: field.tabs, selectedID: tab?.id, onSelect: onSelectTab)
            }
            if let tab {
                LazyVGrid(columns: columns, spacing: Sizes.gridSpacing) {
                    ForEach(tab.items) { item in
                        ProfileV3BaggageTile(
                            item: item,
                            quantity: tab.quantity(of: item.id),
                            onToggle: { onToggle(item.id) },
                            onStep: { onStep(item.id, $0) }
                        )
                    }
                }
                .id(tab.id)
                .transition(.opacity)
            }
        }
    }
}

private struct ProfileV3BaggageTabs: View {
    let tabs: [ProfileV3BaggageTab]
    let selectedID: String?
    let onSelect: (String) -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.Baggage

    @Namespace private var pill

    var body: some View {
        HStack(spacing: Sizes.tabSpacing) {
            ForEach(tabs) { tab in
                let isSelected = tab.id == selectedID
                Button { onSelect(tab.id) } label: {
                    label(tab.title, isSelected: isSelected)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(Color(at: .pureBlack))
                                    .matchedGeometryEffect(id: Self.pillID, in: pill)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.profileV3Pressable(.selection))
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(.horizontal, Sizes.tabInsetHorizontal)
        .padding(.vertical, Sizes.tabInsetVertical)
        .frame(height: Sizes.tabHeight)
        .background(Capsule().fill(ProfileV3Theme.Palette.tabTrack))
    }

    private static let pillID = "pill"

    private func label(_ title: String, isSelected: Bool) -> some View {
        let split = title.range(of: " (")
        let lead = split.map { String(title[..<$0.lowerBound]) } ?? title
        let detail = split.map { String(title[$0.lowerBound...]) } ?? ""
        let tint = isSelected ? Color(at: .pureWhite) : Color(at: .pureBlack)
        let detailFont = Font.Inter.get(size: ProfileV3Theme.Typography.baggageTabDetailSize, weight: .medium)
        return Text("\(Text(lead))\(Text(detail).font(detailFont).foregroundStyle(tint.opacity(0.6)))")
            .typoGraphy(.B2InterSemibold12)
            .foregroundStyle(tint)
            .lineLimit(1)
            .minimumScaleFactor(ProfileV3Theme.Typography.baggageTabMinScale)
    }
}

private struct ProfileV3BaggageTile: View {
    let item: ProfileV3BaggageItem
    let quantity: Int
    let onToggle: () -> Void
    let onStep: (Int) -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.Baggage

    private var isSelected: Bool { quantity > 0 }
    private var showsStepper: Bool { item.isCountable && isSelected }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Sizes.cornerRadius, style: .continuous)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Button(action: onToggle) {
                header
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(alignment: .bottomTrailing) {
                        ProfileV3RemoteImage(url: item.imageURL, contentMode: .fit, placeholder: .clear)
                            .frame(width: Sizes.art.width, height: Sizes.art.height)
                    }
                    .frame(height: Sizes.tileHeight)
                    .contentShape(shape)
            }
            .buttonStyle(.profileV3Pressable(.selection))
            .accessibilityLabel(accessibilityTitle)
            .accessibilityValue(showsStepper ? "\(quantity)" : "")
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            if showsStepper {
                stepper
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(height: Sizes.tileHeight)
        .clipShape(shape)
        .profileV3TileChrome(shape, border: ProfileV3Theme.Palette.optionTileBorder)
        .animation(ProfileV3Theme.Motion.selection, value: quantity)
    }

    private var accessibilityTitle: String {
        guard let detail = item.detail else { return item.title }
        return "\(item.title), \(detail)"
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: Sizes.detailTop) {
                Text(item.title)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(Color(at: .pureBlack))
                    .fixedSize(horizontal: false, vertical: true)
                if let detail = item.detail {
                    Text(detail)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.baggageDetail))
                }
            }
            .frame(maxWidth: Sizes.titleWidth, alignment: .leading)
            .padding(.top, Sizes.titleNudge)
            Spacer(minLength: ProfileV3Theme.Space.s8)
            mark
        }
        .padding(.leading, Sizes.contentInset)
        .padding(.trailing, Sizes.markTrailing)
        .padding(.top, Sizes.contentInset)
    }

    @ViewBuilder
    private var mark: some View {
        if isSelected {
            ProfileV3StatusDot(kind: .complete)
        } else {
            Circle()
                .strokeBorder(Color(at: .neutralGrey200), lineWidth: ProfileV3Theme.Stroke.hairline)
                .frame(width: Sizes.mark, height: Sizes.mark)
                .accessibilityHidden(true)
        }
    }

    private var stepper: some View {
        HStack(spacing: 0) {
            stepButton(ProfileV3Strings.stepperDecrease, delta: -1)
                .accessibilityLabel(ProfileV3Strings.removeOne(item.title))
            Spacer(minLength: 0)
            Text("\(quantity)")
                .typoGraphy(.T1InterBold11)
                .foregroundStyle(Color(at: .pureBlack))
                .monospacedDigit()
                .contentTransition(.numericText())
                .accessibilityHidden(true)
            Spacer(minLength: 0)
            stepButton(ProfileV3Strings.stepperIncrease, delta: 1)
                .disabled(quantity >= Sizes.maxCount)
                .accessibilityLabel(ProfileV3Strings.addOne(item.title))
        }
        .padding(.horizontal, Sizes.stepperInset)
        .frame(maxWidth: .infinity)
        .frame(height: Sizes.stepperHeight)
        .background {
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                ProfileV3Theme.Palette.stepperWash
            }
        }
    }

    private func stepButton(_ glyph: String, delta: Int) -> some View {
        Button { onStep(delta) } label: {
            Text(glyph)
                .typoGraphy(.H7InterSemibold16)
                .foregroundStyle(Color(at: .pureWhite))
                .frame(width: Sizes.stepperButton, height: Sizes.stepperButton)
                .background(Circle().fill(ProfileV3Theme.Palette.stepperButton))
                .padding(Sizes.stepperHitInset)
                .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .padding(-Sizes.stepperHitInset)
    }
}

#if DEBUG
private struct ProfileV3BaggagePickerPreview: View {
    @State private var field: ProfileV3BaggageField = {
        guard let section = ProfileV3AgentFixtures.airportLogistics.sections.first(where: { $0.id == "baggage" }),
              case .baggage(let field) = section.control else { return ProfileV3BaggageField(tabs: []) }
        return field
    }()
    @State private var tabID: String?

    var body: some View {
        ScrollView {
            ProfileV3BaggagePicker(
                field: field,
                selectedTabID: tabID,
                onSelectTab: { id in withAnimation(ProfileV3Theme.Motion.selection) { tabID = id } },
                onToggle: { id in
                    field.updateTab(id: tabID) { $0.setQuantity($0.quantity(of: id) > 0 ? 0 : 1, of: id) }
                },
                onStep: { id, delta in
                    field.updateTab(id: tabID) { $0.setQuantity($0.quantity(of: id) + delta, of: id) }
                }
            )
            .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        }
        .background(Color(at: .pureWhite))
    }
}

#Preview("Baggage picker") {
    ProfileV3BaggagePickerPreview()
}
#endif
