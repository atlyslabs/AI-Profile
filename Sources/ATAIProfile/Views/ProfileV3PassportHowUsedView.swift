import ATUIKit
import SwiftUI

struct ProfileV3PassportHowUsedView: View {
    @ObservedObject var viewModel: ProfileV3PassportHowUsedViewModel
    let onScan: (ProfileV3Directive?) -> Void
    var onHeightChange: ((CGFloat) -> Void)?

    @State private var measured = Measured()
    @State private var headerPin = ProfileV3HeaderPin()

    private typealias HowUsed = ProfileV3Theme.Sizes.HowUsed

    private struct Measured: Equatable {
        var content: CGFloat = 0
        var footer: CGFloat = 0
    }

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetGrabber(
                width: ProfileV3Theme.Sizes.Agent.sheetGrabberWidth,
                color: Color(at: .neutralGrey200),
                top: ProfileV3Theme.Space.s10
            )
            if let content = viewModel.content {
                ScrollView(showsIndicators: false) {
                    loaded(content)
                        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { measured.content = $0 }
                        .profileV3HeaderFadeAnchor(headerPin)
                }
                .profileV3HeaderFade(headerPin)
                .scrollBounceBehavior(.basedOnSize)
                .trackScroll(.passportHowUsed)
                .safeAreaInset(edge: .bottom) {
                    footer(content)
                        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { measured.footer = $0 }
                }
            } else {
                ProfileV3LoadStateView(phase: viewModel.phase, retry: viewModel.load)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .onChange(of: measured) { _, measured in
            guard measured.content > 0, measured.footer > 0 else { return }
            let grabber = ProfileV3Theme.Space.s10 + ProfileV3Theme.Sizes.sheetGrabberHeight
            onHeightChange?(grabber + measured.content + measured.footer)
        }
        .onDisappear(perform: viewModel.cancel)
    }

    private func loaded(_ content: ProfileV3PassportHowUsed) -> some View {
        VStack(spacing: 0) {
            orbs
                .padding(.top, HowUsed.clusterTop)
            Text(content.title)
                .typoGraphy(.T2InterBold12)
                .textCase(.uppercase)
                .foregroundStyle(Color(at: .backgroundDarkTheme))
                .multilineTextAlignment(.center)
                .padding(.top, HowUsed.titleTop)
            ProfileV3DashedDivider()
                .padding(.top, HowUsed.sectionGap)
            VStack(spacing: 0) {
                ForEach(Array(content.steps.enumerated()), id: \.element.id) { index, step in
                    if index > 0 {
                        separator
                    }
                    row(step)
                }
            }
            .padding(.top, HowUsed.sectionGap)
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
    }

    private var orbs: some View {
        ZStack(alignment: .topLeading) {
            ProfileV3GlassOrb(
                imageURL: ProfileV3PlaceholderArt.agentItinerary.url,
                size: HowUsed.mediumOrb,
                isTilted: true
            )
            .offset(x: HowUsed.mediumOrbOrigin.x, y: HowUsed.mediumOrbOrigin.y)
            ProfileV3GlassOrb(imageURL: ProfileV3AgentArt.howUsedOrb.url, size: HowUsed.smallOrb, isTilted: true)
                .offset(x: HowUsed.smallOrbOrigin.x, y: HowUsed.smallOrbOrigin.y)
            ProfileV3GlassOrb(imageURL: ProfileV3PlaceholderArt.agentPersonal.url, size: HowUsed.largeOrb)
                .offset(x: HowUsed.largeOrbOrigin.x, y: HowUsed.largeOrbOrigin.y)
        }
        .frame(width: HowUsed.clusterSize.width, height: HowUsed.clusterSize.height, alignment: .topLeading)
    }

    private func row(_ step: ProfileV3PassportHowUsedStep) -> some View {
        HStack(spacing: HowUsed.tileSpacing) {
            glyph(step.icon)
                .profileV3Icon(HowUsed.tileGlyph)
                .foregroundStyle(Color(at: .pureBlack))
                .frame(width: HowUsed.tile, height: HowUsed.tile)
                .background(Circle().fill(Color(at: .backgroundLightTheme)))
                .overlay(
                    Circle().strokeBorder(Color(at: .borderLightLight200), lineWidth: ProfileV3Theme.Stroke.hairline)
                )
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: HowUsed.textSpacing) {
                Text(step.title)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(Color(at: .pureBlack))
                if !step.body.isEmpty {
                    Text(step.body)
                        .typoGraphy(.B2InterSemibold12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    private var separator: some View {
        ProfileV3HorizontalRule()
            .stroke(
                Color(at: .borderLightLight200),
                style: StrokeStyle(lineWidth: ProfileV3Theme.Stroke.hairline, dash: HowUsed.separatorDash)
            )
            .frame(height: ProfileV3Theme.Stroke.hairline)
            .padding(.leading, HowUsed.tile + HowUsed.tileSpacing)
            .padding(.vertical, HowUsed.sectionGap)
    }

    @ViewBuilder
    private func footer(_ content: ProfileV3PassportHowUsed) -> some View {
        if let scanLabel = content.scanLabel {
            scanButton(scanLabel, scan: content.scan)
        }
    }

    private func scanButton(_ label: String, scan: ProfileV3Directive?) -> some View {
        Button {
            onScan(scan)
        } label: {
            HStack(spacing: HowUsed.buttonSpacing) {
                ATIcon.SwiftUIImage.cropFree
                    .profileV3Icon(HowUsed.buttonIcon)
                Text(label)
                    .typoGraphy(.B1InterSemibold14)
            }
            .foregroundStyle(Color(at: .pureWhite))
            .frame(maxWidth: .infinity)
            .frame(height: ProfileV3Theme.Control.regular)
            .profileV3CapsuleChrome(
                fill: Color(at: .backgroundDarkTheme),
                border: Color(at: .borderLightLight200),
                lineWidth: ProfileV3Theme.Stroke.hairline,
                shadowRadius: 0,
                shadowY: 0
            )
        }
        .buttonStyle(.profileV3Pressable)
        .profileV3CTABar(top: HowUsed.buttonTop)
    }

    private func glyph(_ key: String?) -> Image {
        switch key {
        case "grading": return ATIcon.SwiftUIImage.grading
        case "access_time": return ATIcon.SwiftUIImage.accessTime
        case "autorenew": return ATIcon.SwiftUIImage.autorenew
        default: return ATIcon.SwiftUIImage.contactPage
        }
    }
}

struct ProfileV3PassportHowUsedSheet: View {
    let viewModel: ProfileV3PassportHowUsedViewModel
    let onScan: (ProfileV3Directive?) -> Void

    @State private var fittedHeight: CGFloat?

    var body: some View {
        ProfileV3PassportHowUsedView(viewModel: viewModel, onScan: onScan, onHeightChange: { height in
            guard height.rounded() != fittedHeight?.rounded() else { return }
            fittedHeight = height
        })
        .profileV3FittedDetent(fittedHeight)
        .presentationCornerRadius(ProfileV3Theme.Sizes.Agent.sheetCornerRadius)
        .presentationDragIndicator(.hidden)
    }
}

struct ProfileV3HorizontalRule: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

#if DEBUG
#Preview("Passport · how this is used") {
    let viewModel = ProfileV3PassportHowUsedViewModel(repository: ProfileV3MockRepository())
    return ProfileV3PassportHowUsedView(viewModel: viewModel, onScan: { _ in })
        .task { viewModel.load() }
}
#endif
