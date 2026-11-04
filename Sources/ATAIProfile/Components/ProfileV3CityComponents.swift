import ATMaterialIcons
import ATUIKit
import SwiftUI

@MainActor
enum ProfileV3CityIcon {
    private static var cache: [String: Image] = [:]

    static func image(_ name: String?) -> Image? {
        guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty else { return nil }
        if let cached = cache[name] { return cached }
        guard let icon = ATMaterialIcon(named: name) else { return nil }
        let image = icon.image()
        cache[name] = image
        return image
    }
}

struct ProfileV3CityWindow: View {
    enum Content: Equatable {
        case city(code: String, name: String, imageURL: URL?)
        case add(label: String, detail: String)
    }

    let content: Content
    var isPhotoSharp = false
    var isAnimating = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        ZStack(alignment: .top) {
            ring
            Capsule(style: .continuous)
                .fill(ProfileV3Theme.cityWindowBezelGradient)
                .frame(width: Sizes.windowBezel.width, height: Sizes.windowBezel.height)
                .opacity(ProfileV3Theme.Opacity.cityWindowBezel)
                .padding(.top, Sizes.windowBezelTop)
            Capsule(style: .continuous)
                .fill(ProfileV3Theme.cityWindowFrameGradient)
                .frame(width: Sizes.windowFrame.width, height: Sizes.windowFrame.height)
                .padding(.top, Sizes.windowFrameTop)
            glass
                .frame(width: Sizes.windowGlass.width, height: Sizes.windowGlass.height)
                .clipShape(Capsule(style: .continuous))
                .padding(.top, Sizes.windowGlassTop)
        }
        .frame(width: Sizes.window.width, height: Sizes.window.height, alignment: .top)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        switch content {
        case .city(let code, let name, _): return "\(name), \(code)"
        case .add(let label, let detail): return "\(label), \(detail)"
        }
    }

    @ViewBuilder
    private var ring: some View {
        switch content {
        case .city:
            Capsule(style: .continuous)
                .strokeBorder(ProfileV3Theme.Palette.cityWindowRing, lineWidth: Sizes.windowRing)
                .opacity(ProfileV3Theme.Opacity.cityWindowBezel)
                .frame(width: Sizes.window.width, height: Sizes.window.height)
        case .add:
            if reduceMotion {
                addRing(.rest)
            } else {
                TimelineView(.animation(paused: !isAnimating)) { context in
                    addRing(ProfileV3CityRingPulse(at: context.date.timeIntervalSinceReferenceDate))
                }
            }
        }
    }

    private func addRing(_ pulse: ProfileV3CityRingPulse) -> some View {
        Capsule(style: .continuous)
            .strokeBorder(ProfileV3Theme.Palette.cityAddAccent, lineWidth: pulse.width)
            .frame(width: Sizes.window.width, height: Sizes.window.height)
            .scaleEffect(pulse.scale)
            .opacity(pulse.opacity)
    }

    @ViewBuilder
    private var glass: some View {
        switch content {
        case .city(let code, let name, let imageURL):
            ZStack {
                ProfileV3Theme.Palette.cityWindowGlass
                ProfileV3RemoteImage(url: imageURL, placeholder: .clear)
                    .blur(radius: isPhotoSharp ? 0 : Sizes.windowPhotoBlur)
                    .opacity(isPhotoSharp ? ProfileV3Theme.Opacity.cityWindowPhotoSharp : ProfileV3Theme.Opacity.cityWindowPhoto)
                glare
                VStack(spacing: Sizes.windowTextGap) {
                    Text(code)
                        .font(.Inter.get(size: Sizes.windowCodeSize, weight: .medium))
                        .tracking(Sizes.windowCodeTracking)
                    Text(name)
                        .typoGraphy(.B2InterSemibold12)
                        .opacity(ProfileV3Theme.Opacity.cityWindowName)
                }
                .foregroundStyle(Color(at: .pureWhite))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, ProfileV3Theme.Space.s12)
            }
        case .add(let label, let detail):
            ZStack {
                ProfileV3Theme.Palette.cityAddGlass
                glare
                VStack(spacing: 0) {
                    ATIcon.SwiftUIImage.add
                        .profileV3Icon(ProfileV3Theme.Icon.xl)
                        .foregroundStyle(ProfileV3Theme.Palette.cityAddAccent)
                    Text(label)
                        .typoGraphy(.T1InterBold11)
                        .textCase(.uppercase)
                        .foregroundStyle(ProfileV3Theme.Palette.cityAddAccent)
                        .padding(.top, Sizes.addLabelTop)
                    Text(detail)
                        .typoGraphy(.B2InterSemibold12)
                        .foregroundStyle(Color(at: .pureWhite).opacity(ProfileV3Theme.Opacity.cityAddDetail))
                        .multilineTextAlignment(.center)
                        .padding(.top, Sizes.addDetailTop)
                        .frame(width: Sizes.addDetailWidth)
                }
            }
        }
    }

    private var glare: some View {
        Capsule(style: .continuous)
            .fill(ProfileV3Theme.cityWindowGlareGradient)
            .frame(width: Sizes.windowGlare.width, height: Sizes.windowGlare.height)
            .blur(radius: Sizes.windowGlareBlur)
            .opacity(ProfileV3Theme.Opacity.cityWindowGlare)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, Sizes.windowGlareTop)
            .allowsHitTesting(false)
    }
}

private struct ProfileV3CityRingPulse {
    var scale: CGFloat
    var width: CGFloat
    var opacity: Double

    static let rest = ProfileV3CityRingPulse(
        scale: 1,
        width: ProfileV3Theme.Sizes.City.windowRing,
        opacity: ProfileV3Theme.Opacity.cityAddRingRest
    )
    private static let peak = ProfileV3CityRingPulse(
        scale: ProfileV3Theme.Motion.cityRingPeakScale,
        width: ProfileV3Theme.Sizes.City.addRingPulseWidth,
        opacity: 1
    )
    private static let settle = ProfileV3CityRingPulse(
        scale: ProfileV3Theme.Motion.cityRingSettleScale,
        width: ProfileV3Theme.Sizes.City.addRingSettleWidth,
        opacity: ProfileV3Theme.Opacity.cityAddRingFade
    )

    init(scale: CGFloat, width: CGFloat, opacity: Double) {
        self.scale = scale
        self.width = width
        self.opacity = opacity
    }

    init(at seconds: TimeInterval) {
        let local = seconds.truncatingRemainder(dividingBy: ProfileV3Theme.Motion.cityRingSeconds)
        let rise = ProfileV3Theme.Motion.cityRingRiseSeconds
        let spread = ProfileV3Theme.Motion.cityRingSpreadSeconds
        if local < rise {
            self = Self.blend(.rest, .peak, local / rise)
        } else if local < rise + spread {
            self = Self.blend(.peak, .settle, (local - rise) / spread)
        } else {
            self = Self.blend(.settle, .rest, (local - rise - spread) / (ProfileV3Theme.Motion.cityRingSeconds - rise - spread))
        }
    }

    private static func blend(_ from: Self, _ to: Self, _ progress: Double) -> Self {
        let eased = UnitCurve.easeInOut.value(at: min(max(progress, 0), 1))
        return Self(
            scale: from.scale + (to.scale - from.scale) * eased,
            width: from.width + (to.width - from.width) * eased,
            opacity: from.opacity + (to.opacity - from.opacity) * eased
        )
    }
}

struct ProfileV3CityCardShape: InsettableShape {
    var cornerRadius = ProfileV3Theme.Sizes.City.cardRadius
    var notchHalfWidth = ProfileV3Theme.Sizes.City.notchHalfWidth
    var notchDepth = ProfileV3Theme.Sizes.City.notchDepth
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let radius = min(cornerRadius, rect.width / 2, rect.height / 2)
        let centre = rect.midX
        let top = rect.minY
        let sx = notchHalfWidth / 65.5
        let sy = notchDepth / 12.6592
        func point(_ dx: CGFloat, _ dy: CGFloat) -> CGPoint {
            CGPoint(x: centre + dx * sx, y: top + dy * sy)
        }
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + radius, y: top))
        path.addLine(to: point(-65.5, 0))
        path.addCurve(to: point(-9.971, 12.1531), control1: point(-48.931, 0), control2: point(-26.45, 10.4367))
        path.addCurve(to: point(0, 12.6592), control1: point(-6.808, 12.4825), control2: point(-3.462, 12.6592))
        path.addCurve(to: point(9.971, 12.1531), control1: point(3.462, 12.6592), control2: point(6.808, 12.4825))
        path.addCurve(to: point(65.5, 0), control1: point(26.45, 10.4367), control2: point(48.931, 0))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: top))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: top), tangent2End: CGPoint(x: rect.maxX, y: top + radius), radius: radius)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
            tangent2End: CGPoint(x: rect.maxX - radius, y: rect.maxY),
            radius: radius
        )
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addArc(
            tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
            tangent2End: CGPoint(x: rect.minX, y: rect.maxY - radius),
            radius: radius
        )
        path.addLine(to: CGPoint(x: rect.minX, y: top + radius))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: top), tangent2End: CGPoint(x: rect.minX + radius, y: top), radius: radius)
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> ProfileV3CityCardShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}

struct ProfileV3CitySectionCard<Content: View>: View {
    let icon: String?
    let isComplete: Bool
    @ViewBuilder let content: Content

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, Sizes.cardBottom)
            .background {
                ProfileV3CityCardShape()
                    .fill(Color(at: .pureWhite))
                    .shadow(color: ProfileV3Theme.Palette.shadow, radius: Sizes.cardShadowRadius, y: Sizes.cardShadowY)
                    .overlay(ProfileV3CityCardShape().strokeBorder(ProfileV3Theme.Palette.cityCardBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
            }
            .padding(.top, Sizes.notchHeight)
            .background(alignment: .top) {
                Ellipse()
                    .fill(isComplete ? ProfileV3Theme.Palette.cityGlowComplete : ProfileV3Theme.Palette.cityGlowPending)
                    .frame(width: Sizes.glow.width, height: Sizes.glow.height)
                    .blur(radius: Sizes.glowBlur)
                    .padding(.top, Sizes.glowTop)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .overlay(alignment: .top) {
                if let image = ProfileV3CityIcon.image(icon) {
                    image
                        .profileV3Icon(Sizes.notchIcon)
                        .foregroundStyle(isComplete ? ProfileV3Theme.Palette.cityNotchComplete : ProfileV3Theme.Palette.cityNotchPending)
                        .padding(.top, Sizes.notchIconTop)
                        .accessibilityHidden(true)
                }
            }
    }
}

struct ProfileV3CityOrb: View {
    let optionID: String
    let isSelected: Bool

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        if let gradient = ProfileV3Theme.cityOrbGradient(optionID) {
            Circle()
                .fill(gradient)
                .overlay(Circle().strokeBorder(ProfileV3Theme.Palette.cityOptionBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
                .opacity(isSelected ? 1 : ProfileV3Theme.Opacity.cityOrbIdle)
                .overlay {
                    if isSelected {
                        ATIcon.SwiftUIImage.check
                            .profileV3Icon(Sizes.optionOrbCheck)
                            .foregroundStyle(ProfileV3Theme.cityOrbCheckTint(optionID))
                    }
                }
                .frame(width: Sizes.optionOrb, height: Sizes.optionOrb)
                .accessibilityHidden(true)
        }
    }

    static func exists(for optionID: String) -> Bool {
        ProfileV3Theme.cityOrbGradient(optionID) != nil
    }
}

struct ProfileV3CityOptionChip: View {
    enum Style {
        case outline
        case ink
    }

    let title: String
    let isSelected: Bool
    var style = Style.outline
    var icon: Image?
    var orbID: String?
    let action: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.City

    private var hasOrb: Bool { orbID.map(ProfileV3CityOrb.exists) ?? false }
    private var isInk: Bool { style == .ink && isSelected }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Sizes.optionIconGap) {
                if let orbID, hasOrb {
                    ProfileV3CityOrb(optionID: orbID, isSelected: isSelected)
                } else if let icon {
                    icon
                        .profileV3Icon(Sizes.optionOrb)
                        .foregroundStyle(isInk ? Color(at: .pureWhite) : ProfileV3Theme.Palette.cityOptionText)
                }
                Text(title)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .padding(.leading, hasOrb ? Sizes.optionOrbLeading : Sizes.optionLeading)
            .padding(.trailing, Sizes.optionTrailing)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: Sizes.optionHeight)
            .background { background }
            .contentShape(RoundedRectangle(cornerRadius: Sizes.optionRadius, style: .continuous))
            .animation(ProfileV3Theme.Motion.selection, value: isSelected)
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(title)
    }

    private var foreground: Color {
        if isInk { return Color(at: .pureWhite) }
        if style == .ink { return Color(at: .neutralGrey900) }
        return isSelected ? Color(at: .neutralGrey900) : ProfileV3Theme.Palette.cityOptionText
    }

    @ViewBuilder
    private var background: some View {
        let shape = RoundedRectangle(cornerRadius: Sizes.optionRadius, style: .continuous)
        if isInk {
            shape
                .fill(ProfileV3Theme.cityInkGradient)
                .overlay(shape.fill(ProfileV3Theme.cityInkShade))
        } else {
            shape
                .fill(Color(at: .pureWhite))
                .overlay(shape.strokeBorder(
                    isSelected && style == .outline
                        ? ProfileV3Theme.Palette.cityOptionSelectedBorder
                        : ProfileV3Theme.Palette.cityOptionBorder,
                    lineWidth: ProfileV3Theme.Stroke.hairline
                ))
        }
    }
}

struct ProfileV3CityOptionGrid<Option: Identifiable, Cell: View>: View {
    let options: [Option]
    @ViewBuilder let cell: (Option) -> Cell

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        Grid(horizontalSpacing: Sizes.optionGap, verticalSpacing: Sizes.optionGap) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                GridRow {
                    ForEach(row) { option in
                        cell(option)
                    }
                    if row.count == 1 {
                        Color.clear
                            .frame(height: Sizes.optionHeight)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
    }

    private var rows: [[Option]] {
        stride(from: 0, to: options.count, by: 2).map { Array(options[$0..<min($0 + 2, options.count)]) }
    }
}

struct ProfileV3CityLogoChip: View {
    let option: ProfileV3ChipOption
    let isSelected: Bool
    let action: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        Button(action: action) {
            HStack(spacing: Sizes.optionIconGap) {
                ProfileV3RemoteImage(url: option.logoURL, contentMode: .fit, placeholder: ProfileV3Theme.Palette.imagePlaceholder)
                    .frame(width: Sizes.logoChipLogo, height: Sizes.logoChipLogo)
                    .clipShape(Circle())
                Text(option.title)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(isSelected ? Color(at: .neutralGrey900) : ProfileV3Theme.Palette.cityOptionText)
                    .lineLimit(1)
            }
            .padding(.leading, Sizes.logoChipLeading)
            .padding(.trailing, Sizes.optionTrailing)
            .frame(height: Sizes.optionHeight)
            .profileV3CapsuleChrome(
                border: isSelected ? ProfileV3Theme.Palette.cityOptionSelectedBorder : ProfileV3Theme.Palette.cityOptionBorder,
                lineWidth: ProfileV3Theme.Stroke.hairline,
                shadowRadius: ProfileV3Theme.Shadow.chipRadius,
                shadowY: ProfileV3Theme.Shadow.chipY
            )
            .animation(ProfileV3Theme.Motion.selection, value: isSelected)
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(option.title)
    }
}

struct ProfileV3CityClassCard: View {
    let option: ProfileV3CardOption
    let isSelected: Bool
    let action: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Sizes.optionRadius, style: .continuous)
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                art
                    .frame(width: Sizes.classArt.width, height: Sizes.classArt.height)
                    .offset(x: Sizes.classArtOffset.width, y: Sizes.classArtOffset.height)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                Text(option.code)
                    .tracking(Sizes.tightTracking)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(isSelected ? Color(at: .pureBlack) : ProfileV3Theme.Palette.cityOptionText)
                    .frame(width: Sizes.classCardTitleWidth, alignment: .leading)
                    .padding(Sizes.classCardTitle)
            }
            .frame(width: Sizes.classCard.width, height: Sizes.classCard.height)
            .background(shape.fill(Color(at: .pureWhite)))
            .clipShape(shape)
            .overlay(shape.strokeBorder(
                isSelected ? ProfileV3Theme.Palette.cityOptionSelectedBorder : ProfileV3Theme.Palette.cityOptionBorder,
                lineWidth: ProfileV3Theme.Stroke.hairline
            ))
            .shadow(
                color: isSelected ? ProfileV3Theme.Palette.shadow : .clear,
                radius: ProfileV3Theme.Shadow.chipRadius,
                y: ProfileV3Theme.Shadow.chipY
            )
            .animation(ProfileV3Theme.Motion.selection, value: isSelected)
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(option.code)
    }

    @ViewBuilder
    private var art: some View {
        if let url = option.imageURL {
            ProfileV3RemoteImage(url: url, contentMode: .fit, placeholder: .clear)
                .opacity(isSelected ? 1 : ProfileV3Theme.Opacity.cityClassArt)
        } else if let seat = ProfileV3SeatArt(rawValue: option.id) {
            seat.image(isSelected: isSelected)
                .resizable()
                .scaledToFit()
                .opacity(isSelected ? 1 : ProfileV3Theme.Opacity.cityClassArt)
        }
    }
}

struct ProfileV3PlaceThumbnail: View {
    let place: ProfileV3ChipOption.Place
    let size: CGFloat

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: min(ProfileV3Theme.Sizes.City.placeThumbRadius, size / 2), style: .continuous)
    }

    var body: some View {
        Group {
            switch place {
            case .hotel:
                shape
                    .fill(ProfileV3Theme.Palette.cityPlaceThumb)
                    .overlay {
                        ProfileV3CityIcon.image("apartment")?
                            .profileV3Icon(min(ProfileV3Theme.Icon.xl, size * 0.6))
                            .foregroundStyle(Color(at: .neutralGrey400))
                    }
            case .location:
                ProfileV3CityArt.locationMap.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(shape)
                    .overlay(shape.strokeBorder(ProfileV3Theme.Palette.cityPlaceBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct ProfileV3CityPlaceRow: View {
    let option: ProfileV3ChipOption
    let action: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        Button(action: action) {
            HStack(spacing: Sizes.placeTextGap) {
                thumbnail
                VStack(alignment: .leading, spacing: Sizes.placeLineGap) {
                    Text(option.title)
                        .typoGraphy(.H7InterMedium16)
                        .foregroundStyle(Color(at: .pureBlack))
                    if let subtitle = option.subtitle?.nonEmpty {
                        Text(subtitle)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(Color(at: .neutralGrey900).opacity(ProfileV3Theme.Opacity.cityPlaceSubtitle))
                    }
                }
                .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, Sizes.placeThumbInset)
            .frame(height: Sizes.placeHeight)
            .background(RoundedRectangle(cornerRadius: Sizes.placeRadius, style: .continuous).fill(ProfileV3Theme.Palette.cityPlace))
            .contentShape(RoundedRectangle(cornerRadius: Sizes.placeRadius, style: .continuous))
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let logoURL = option.logoURL {
            ProfileV3RemoteImage(url: logoURL)
                .frame(width: Sizes.placeThumb, height: Sizes.placeThumb)
                .clipShape(RoundedRectangle(cornerRadius: Sizes.placeThumbRadius, style: .continuous))
        } else {
            ProfileV3PlaceThumbnail(place: option.place ?? .hotel, size: Sizes.placeThumb)
        }
    }
}

struct ProfileV3CityOptOutRow: View {
    let optOut: ProfileV3OptOut
    let onToggle: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        VStack(alignment: .leading, spacing: Sizes.optOutGap) {
            ProfileV3DashedRule(color: ProfileV3Theme.Palette.dashedRule)
            Button(action: onToggle) {
                HStack(spacing: Sizes.optOutRowGap) {
                    ProfileV3CheckboxMark(isSelected: optOut.isOn, size: Sizes.optOutBox)
                    Text(optOut.title)
                        .tracking(Sizes.tightTracking)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(ProfileV3Theme.Palette.cityOptionText)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.profileV3Pressable(.selection))
            .accessibilityAddTraits(optOut.isOn ? [.isButton, .isSelected] : .isButton)
            ProfileV3DashedRule(color: ProfileV3Theme.Palette.dashedRule)
        }
    }
}

struct ProfileV3CityTabStrip: View {
    let tabs: [ProfileV3CitySectionStyle.Tab]
    let selectedID: String?
    let onSelect: (String) -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Sizes.tabSpacing) {
                ForEach(tabs) { tab in
                    chip(tab, isSelected: tab.id == (selectedID ?? tabs.first?.id))
                }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.vertical, ProfileV3Theme.Space.s10)
        }
        .scrollClipDisabled()
    }

    private func chip(_ tab: ProfileV3CitySectionStyle.Tab, isSelected: Bool) -> some View {
        let tint = isSelected ? Color(at: .pureBlack) : ProfileV3Theme.Palette.cityOptionText
        return Button { onSelect(tab.id) } label: {
            HStack(spacing: Sizes.tabGap) {
                ProfileV3CityIcon.image(tab.icon)?
                    .profileV3Icon(Sizes.tabIcon)
                Text(tab.title)
                    .typoGraphy(.T1InterBold11)
                    .textCase(.uppercase)
                    .lineLimit(1)
            }
            .foregroundStyle(tint)
            .padding(.leading, Sizes.tabLeading)
            .padding(.trailing, Sizes.tabTrailing)
            .frame(height: Sizes.tabHeight)
            .profileV3CapsuleChrome(
                border: isSelected ? ProfileV3Theme.Palette.cityOptionSelectedBorder : ProfileV3Theme.Palette.cityOptionBorder,
                lineWidth: ProfileV3Theme.Stroke.hairline,
                shadowRadius: ProfileV3Theme.Shadow.chipRadius,
                shadowY: ProfileV3Theme.Shadow.chipY
            )
            .animation(ProfileV3Theme.Motion.selection, value: isSelected)
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

struct ProfileV3CityTagChip: View {
    let label: String
    let icon: String?
    let onEdit: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        HStack(spacing: Sizes.tagRowGap) {
            Button(action: onEdit) {
                HStack(spacing: Sizes.tagChipGap) {
                    ProfileV3CityIcon.image(icon)?
                        .profileV3Icon(Sizes.tagChipIcon)
                    Text(label)
                        .typoGraphy(.B1InterMedium14)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .foregroundStyle(Color(at: .pureWhite))
                .padding(.leading, Sizes.tagChipLeading)
                .padding(.trailing, Sizes.tagChipTrailing)
                .frame(maxWidth: Sizes.tagChipMaxWidth)
                .frame(height: Sizes.tagChipHeight)
                .background(ink)
                .fixedSize(horizontal: true, vertical: false)
            }
            .buttonStyle(.profileV3Pressable(.selection))
            .accessibilityLabel(label)
            .accessibilityHint(ProfileV3Strings.editCityTag)
            Button(action: onEdit) {
                ATIcon.SwiftUIImage.edit
                    .profileV3Icon(ProfileV3Theme.Icon.xl)
                    .foregroundStyle(Color(at: .pureWhite))
                    .frame(width: Sizes.tagEditWidth, height: Sizes.tagChipHeight)
                    .background(ink)
            }
            .buttonStyle(.profileV3Pressable(.selection))
            .accessibilityLabel(ProfileV3Strings.editCityTag)
        }
    }

    private var ink: some View {
        Capsule()
            .fill(ProfileV3Theme.cityInkGradient)
            .overlay(Capsule().fill(ProfileV3Theme.cityInkShade))
    }
}

struct ProfileV3CityShimmerText: View {
    let text: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            label(phase: 0.5)
        } else {
            TimelineView(.animation) { context in
                let seconds = context.date.timeIntervalSinceReferenceDate
                let progress = seconds.truncatingRemainder(dividingBy: ProfileV3Theme.Motion.cityShimmerSeconds)
                    / ProfileV3Theme.Motion.cityShimmerSeconds
                label(phase: CGFloat(progress) * 1.6 - 0.3)
            }
        }
    }

    private func label(phase: CGFloat) -> some View {
        Text(text)
            .typoGraphy(.B2InterSemibold12)
            .foregroundStyle(ProfileV3Theme.cityShimmerGradient(phase: phase))
            .accessibilityLabel(text)
    }
}

struct ProfileV3CityAddButton: View {
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ATIcon.SwiftUIImage.add
                .profileV3Icon(ProfileV3Theme.Icon.xl)
                .foregroundStyle(Color(at: .pureBlack))
                .frame(width: ProfileV3Theme.Sizes.City.addButton, height: ProfileV3Theme.Sizes.City.addButton)
                .overlay(Circle().strokeBorder(Color(at: .pureBlack), lineWidth: ProfileV3Theme.Stroke.thin))
                .contentShape(Circle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityLabel(accessibilityLabel)
    }
}

struct ProfileV3CityHeaderButton: View {
    let icon: Image
    let accessibilityLabel: String
    var isLime = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            icon
                .profileV3Icon(ProfileV3Theme.Icon.xl)
                .foregroundStyle(ProfileV3Theme.Palette.floatingControlInk)
                .frame(width: ProfileV3Theme.Sizes.circleButton, height: ProfileV3Theme.Sizes.circleButton)
                .background {
                    if isLime {
                        Circle()
                            .fill(Color(at: .pureWhite))
                            .overlay(Circle().fill(ProfileV3Theme.cityAddButtonGradient))
                            .overlay(Circle().strokeBorder(ProfileV3Theme.Palette.floatingControlShadow, lineWidth: ProfileV3Theme.Stroke.hairline))
                    } else {
                        ProfileV3FloatingControlBackground()
                    }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityLabel(accessibilityLabel)
    }
}

struct ProfileV3CityInkButton: View {
    let title: String
    var isLoading = false
    var isEnabled = true
    let action: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(Color(at: .pureWhite))
                } else {
                    Text(title)
                        .typoGraphy(.B1InterSemibold14)
                        .foregroundStyle(Color(at: .pureWhite))
                }
            }
            .frame(maxWidth: Sizes.tagSheetButtonWidth)
            .frame(height: Sizes.tagSheetButtonHeight)
            .background {
                Capsule()
                    .fill(ProfileV3Theme.cityInkGradient)
                    .overlay(Capsule().fill(ProfileV3Theme.cityInkShade))
                    .shadow(color: ProfileV3Theme.Palette.cityButtonGlow, radius: ProfileV3Theme.Shadow.floatingRadius, y: ProfileV3Theme.Shadow.savedY)
            }
            .contentShape(Capsule())
            .animation(ProfileV3Theme.Motion.saveState, value: isLoading)
        }
        .buttonStyle(.profileV3Pressable(.impact(weight: .medium)))
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1 : ProfileV3Theme.Opacity.disabled)
        .accessibilityLabel(title)
        .accessibilityValue(isLoading ? ProfileV3Strings.loading : "")
    }
}
