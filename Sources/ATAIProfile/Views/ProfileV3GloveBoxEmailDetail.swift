import ATUIKit
import SwiftUI

struct ProfileV3GloveBoxEmailDetail: View {
    let email: ProfileV3GloveBoxEmail
    let onBack: () -> Void
    let onFollowUp: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProfileV3SheetGrabber()
            ProfileV3CircleIconButton.back(action: onBack)
                .padding(.top, Layout.detailBackTop)
                .padding(.leading, ProfileV3Theme.Sizes.screenHorizontalMargin)
            Group {
                header
                    .padding(.top, Layout.detailHeaderTop)
                ProfileV3DashedDivider()
                    .padding(.top, Layout.detailDividerTop)
                if let note = email.note, !note.isEmpty {
                    HStack(alignment: .top, spacing: ProfileV3Theme.Space.s16) {
                        Text(note)
                            .typoGraphy(.H7InterMedium16)
                            .foregroundStyle(Color(at: .pureBlack))
                            .frame(maxWidth: Layout.detailNoteWidth, alignment: .leading)
                        Spacer(minLength: 0)
                        ProfileV3AtlysOrb(ring: .still, metrics: .insight)
                    }
                    .padding(.top, Layout.detailNoteTop)
                }
            }
            .padding(.horizontal, Layout.detailInset)
            if let followUp = email.followUpTitle, !followUp.isEmpty {
                ProfileV3ContinueButton(title: followUp, action: onFollowUp)
                    .profileV3CTABar(top: Layout.detailCTATop)
            } else {
                Color.clear.frame(height: Layout.detailCTATop)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: Layout.detailRadius,
                topTrailingRadius: Layout.detailRadius,
                style: .continuous
            )
            .fill(Color(at: .pureWhite))
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private var header: some View {
        HStack(alignment: .top, spacing: ProfileV3Theme.Space.s16) {
            VStack(alignment: .leading, spacing: Layout.detailMetaTop) {
                VStack(alignment: .leading, spacing: Layout.detailTitleSpacing) {
                    Text(email.sender)
                        .typoGraphy(.H6InterMedium18)
                        .foregroundStyle(Color(at: .pureBlack))
                    Text(email.summary)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(
                            Color(at: .pureBlack).opacity(ProfileV3Theme.GloveBox.Palette.summaryOpacity)
                        )
                        .fixedSize(horizontal: false, vertical: true)
                }
                ProfileV3GloveBoxMeta(email: email)
                    .fixedSize()
            }
            .frame(maxWidth: Layout.rowTextWidth, alignment: .leading)
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 0) {
                ProfileV3GloveBoxLogo(url: email.logoURL)
                Spacer(minLength: ProfileV3Theme.Space.s16)
                if let badge = email.badge, !badge.isEmpty {
                    Text(badge)
                        .typoGraphy(.T1InterBold11)
                        .textCase(.uppercase)
                        .foregroundStyle(Color(at: .pureWhite))
                        .padding(.leading, Layout.badgeLeading)
                        .padding(.trailing, Layout.badgeTrailing)
                        .frame(height: Layout.badgeHeight)
                        .background(
                            RoundedRectangle(cornerRadius: Layout.badgeRadius, style: .continuous)
                                .fill(ProfileV3Theme.GloveBox.badgeGradient)
                        )
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
