import ATUIKit
import SwiftUI

enum ProfileV3SheetControl {
    case back(() -> Void)
    case close(() -> Void)
}

struct ProfileV3AgentSheetChrome<Title: View, Accessory: View>: View {
    let control: ProfileV3SheetControl
    var isEnabled = true
    var showsGrabber = true
    @ViewBuilder let title: Title
    @ViewBuilder let accessory: Accessory

    var body: some View {
        ZStack(alignment: .top) {
            if showsGrabber {
                ProfileV3SheetGrabber.agent
            }
            accessory
            ZStack {
                title
                HStack {
                    if case .back(let action) = control {
                        ProfileV3CircleIconButton.back(action: action)
                    }
                    Spacer()
                    if case .close(let action) = control {
                        ProfileV3CircleIconButton.close(action: action)
                    }
                }
                .disabled(!isEnabled)
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Sizes.Agent.backTop)
        }
    }
}

extension ProfileV3AgentSheetChrome where Accessory == EmptyView {
    init(
        control: ProfileV3SheetControl,
        isEnabled: Bool = true,
        showsGrabber: Bool = true,
        @ViewBuilder title: () -> Title
    ) {
        self.init(control: control, isEnabled: isEnabled, showsGrabber: showsGrabber, title: title, accessory: { EmptyView() })
    }
}

extension ProfileV3AgentSheetChrome where Title == EmptyView {
    init(control: ProfileV3SheetControl, isEnabled: Bool = true, @ViewBuilder accessory: () -> Accessory) {
        self.init(control: control, isEnabled: isEnabled, title: { EmptyView() }, accessory: accessory)
    }
}

extension ProfileV3AgentSheetChrome where Title == EmptyView, Accessory == EmptyView {
    init(control: ProfileV3SheetControl, isEnabled: Bool = true) {
        self.init(control: control, isEnabled: isEnabled, title: { EmptyView() }, accessory: { EmptyView() })
    }
}

struct ProfileV3AgentSheetHeader: View {
    let tag: String
    var avatarURL: URL?
    var showsOrb = true
    var isEnabled = true
    let control: ProfileV3SheetControl

    init(tag: String, avatarURL: URL? = nil, showsOrb: Bool = true, onBack: @escaping () -> Void) {
        self.init(tag: tag, avatarURL: avatarURL, showsOrb: showsOrb, control: .back(onBack))
    }

    init(
        tag: String,
        avatarURL: URL? = nil,
        showsOrb: Bool = true,
        isEnabled: Bool = true,
        control: ProfileV3SheetControl
    ) {
        self.tag = tag
        self.avatarURL = avatarURL
        self.showsOrb = showsOrb
        self.isEnabled = isEnabled
        self.control = control
    }

    var body: some View {
        ProfileV3AgentSheetChrome(control: control, isEnabled: isEnabled, accessory: {
            ProfileV3TagLabel(text: tag)
                .padding(.top, ProfileV3Theme.Sizes.Agent.tagTop)
            if showsOrb {
                ProfileV3AvatarOrb(imageURL: avatarURL, size: ProfileV3Theme.Sizes.Agent.orbLarge)
                    .padding(.top, ProfileV3Theme.Sizes.Agent.orbTop)
                    .accessibilityHidden(true)
            }
        })
        .frame(maxWidth: .infinity)
        .frame(height: height, alignment: .top)
    }

    private var height: CGFloat { Self.height(showsOrb: showsOrb) }

    static func height(showsOrb: Bool) -> CGFloat {
        showsOrb
            ? ProfileV3Theme.Sizes.Agent.orbTop + ProfileV3Theme.Sizes.Agent.orbLarge
            : ProfileV3Theme.Sizes.Agent.backTop + ProfileV3Theme.Sizes.circleButton
    }
}

struct ProfileV3AgentStickyHeader: View {
    let tag: String
    let pin: ProfileV3HeaderPin
    let onBack: () -> Void

    var body: some View {
        let progress = pin.progress
        ZStack(alignment: .top) {
            backdrop(progress)
            Group {
                ProfileV3SheetGrabber.agent
                ProfileV3TagLabel(text: tag)
                    .padding(.top, ProfileV3Theme.Sizes.Agent.tagTop)
                    .offset(y: ProfileV3Theme.Sizes.Agent.stickyTagDrop * progress)
            }
            .allowsHitTesting(false)
            HStack {
                ProfileV3CircleIconButton.back(action: onBack)
                Spacer()
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Sizes.Agent.backTop)
        }
        .frame(maxWidth: .infinity)
    }

    private func backdrop(_ progress: CGFloat) -> some View {
        ProfileV3FadeBand(
            solid: ProfileV3Theme.Sizes.Agent.stickyBarHeight,
            fade: ProfileV3Theme.Sizes.Agent.stickyFadeHeight,
            blocksTouches: progress > 0
        )
        .opacity(progress)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Agent sheet header") {
    VStack(spacing: ProfileV3Theme.Space.s32) {
        ProfileV3AgentSheetHeader(tag: "Flight agent", avatarURL: ProfileV3PlaceholderArt.agentFlight.url, onBack: {})
        ProfileV3AgentSheetHeader(tag: "+Add preferred airlines", showsOrb: false, onBack: {})
    }
    .background(Color(at: .pureWhite))
}
#endif
