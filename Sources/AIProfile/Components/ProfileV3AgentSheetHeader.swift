import ATUIKit
import SwiftUI

struct ProfileV3AgentSheetHeader: View {
    let tag: String
    var avatarURL: URL?
    var showsOrb = true
    let onBack: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            ProfileV3SheetGrabber(
                width: ProfileV3Theme.Sizes.Agent.sheetGrabberWidth,
                color: Color(at: .neutralGrey200),
                top: ProfileV3Theme.Space.s10
            )
            ProfileV3TagLabel(text: tag)
                .padding(.top, ProfileV3Theme.Sizes.Agent.tagTop)
            HStack {
                ProfileV3CircleIconButton.back(action: onBack)
                Spacer()
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Sizes.Agent.backTop)
            if showsOrb {
                ProfileV3AvatarOrb(imageURL: avatarURL, size: ProfileV3Theme.Sizes.Agent.orbLarge)
                    .padding(.top, ProfileV3Theme.Sizes.Agent.orbTop)
            }
        }
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
                ProfileV3SheetGrabber(
                    width: ProfileV3Theme.Sizes.Agent.sheetGrabberWidth,
                    color: Color(at: .neutralGrey200),
                    top: ProfileV3Theme.Space.s10
                )
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
        VStack(spacing: 0) {
            Color(at: .pureWhite)
                .frame(height: ProfileV3Theme.Sizes.Agent.stickyBarHeight)
                .allowsHitTesting(progress > 0)
            ProfileV3Theme.whiteToClearFade
                .frame(height: ProfileV3Theme.Sizes.Agent.stickyFadeHeight)
                .allowsHitTesting(false)
        }
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
