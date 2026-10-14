import ATUIKit
import SwiftUI

struct ProfileV3WorldPassBackFace: View {
    let pass: ProfileV3WorldPass
    var onAddProgramme: (() -> Void)?
    var onOpenProgrammes: (() -> Void)?
    var onFlip: (() -> Void)?
    var showsFlipTab = false
    var flipTabOpacity: Double = 1

    private var isEmpty: Bool { pass.programmes.isEmpty }

    var body: some View {
        ZStack(alignment: .top) {
            if let onFlip {
                Button(action: onFlip) {
                    Color(at: .pureWhite)
                        .frame(width: ProfileV3Theme.Sizes.worldPassWidth, height: ProfileV3Theme.Sizes.worldPassHeight)
                }
                .buttonStyle(.profileV3Pressable)
                .accessibilityLabel(ProfileV3Strings.flipCard)
            } else {
                Color(at: .pureWhite)
            }
            ProfileV3BackFaceWash()
            if isEmpty {
                emptyContent
            } else {
                connectedContent
            }
            plusButton
                .padding(
                    .top,
                    isEmpty ? ProfileV3Theme.Sizes.BackFace.emptyPlusTop : ProfileV3Theme.Space.s24
                )
                .padding(.trailing, isEmpty ? 0 : ProfileV3Theme.Space.s20)
                .frame(maxWidth: .infinity, alignment: isEmpty ? .center : .trailing)
                .opacity(onAddProgramme == nil ? 0 : 1)
                .allowsHitTesting(onAddProgramme != nil)
        }
        .frame(width: ProfileV3Theme.Sizes.worldPassWidth, height: ProfileV3Theme.Sizes.worldPassHeight)
        .clipShape(RoundedRectangle(cornerRadius: ProfileV3Theme.Sizes.worldPassCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ProfileV3Theme.Sizes.worldPassCornerRadius, style: .continuous)
                .stroke(ProfileV3Theme.Palette.backFaceBorder, lineWidth: ProfileV3Theme.Stroke.regular)
        )
        .overlay(alignment: .topLeading) {
            if showsFlipTab {
                ProfileV3FlipAffordance(face: .back)
                    .opacity(flipTabOpacity)
                    .transition(.opacity)
            }
        }
    }

    private var plusButton: some View {
        Button(action: { onAddProgramme?() }) {
            ATIcon.SwiftUIImage.add
                .profileV3Icon(ProfileV3Theme.Icon.md)
                .foregroundStyle(Color(at: .pureBlack))
                .frame(
                    width: ProfileV3Theme.Sizes.BackFace.plusButton,
                    height: ProfileV3Theme.Sizes.BackFace.plusButton
                )
                .background(
                    Circle()
                        .fill(Color(at: .pureWhite))
                        .shadow(
                            color: ProfileV3Theme.Palette.plusShadow,
                            radius: ProfileV3Theme.Shadow.plusRadius,
                            y: ProfileV3Theme.Shadow.plusY
                        )
                )
                .overlay(
                    Circle()
                        .strokeBorder(ProfileV3Theme.plusRingGradient, lineWidth: ProfileV3Theme.Stroke.thin)
                        .padding(-ProfileV3Theme.Stroke.thin)
                )
                .contentShape(Circle())
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(ProfileV3Strings.addProgramme)
    }

    private var emptyContent: some View {
        VStack(spacing: 0) {
            (Text(ProfileV3Strings.connectProgrammesLead).foregroundStyle(Color(at: .neutralGrey500))
                + Text(ProfileV3Strings.connectProgrammesEmphasis).foregroundStyle(Color(at: .pureBlack)))
                .typoGraphy(.B1InterMedium14)
                .multilineTextAlignment(.center)
                .frame(width: ProfileV3Theme.Sizes.BackFace.copyWidth)
                .padding(.top, ProfileV3Theme.Sizes.BackFace.copyTop)
            Spacer(minLength: 0)
            ProfileV3RemoteImage(
                url: ProfileV3PlaceholderArt.programmeCardsEmpty.url,
                contentMode: .fit,
                placeholder: .clear
            )
            .frame(width: ProfileV3Theme.Sizes.worldPassWidth, height: ProfileV3Theme.Sizes.BackFace.emptyArtHeight)
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity)
    }

    private var connectedContent: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                Text(ProfileV3Strings.programmeCount(pass.connectedProgrammeCount))
                    .typoGraphy(.H5InterSemibold20)
                    .foregroundStyle(ProfileV3Theme.Palette.backFaceText)
                Text(ProfileV3Strings.programmesConnected)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(ProfileV3Theme.Palette.backFaceText)
                    .padding(.top, ProfileV3Theme.Space.s16)
                if let updated = pass.programmesUpdate {
                    Text(ProfileV3Strings.updatedAgo(updated.text()))
                        .typoGraphy(.T1InterMedium11)
                        .foregroundStyle(Color(at: .neutralGrey400))
                        .padding(.top, ProfileV3Theme.Space.s4)
                }
            }
            .padding(.top, ProfileV3Theme.Space.s28)
            .padding(.leading, ProfileV3Theme.Space.s28)
            .frame(maxWidth: .infinity, alignment: .leading)
            programmeStack
            if onOpenProgrammes != nil, !isSingleProgramme {
                moreIndicator
            }
        }
    }

    @ViewBuilder
    private var programmeStack: some View {
        if let onOpenProgrammes {
            Button(action: onOpenProgrammes) {
                programmeCards
            }
            .buttonStyle(.profileV3Pressable)
            .accessibilityLabel(ProfileV3Strings.programmesTitle)
        } else {
            programmeCards
        }
    }

    private var isSingleProgramme: Bool { pass.programmes.count == 1 }

    private var programmeCards: some View {
        let widths = isSingleProgramme
            ? ProfileV3Theme.Sizes.BackFace.singleStackWidths
            : ProfileV3Theme.Sizes.Programme.cardWidths
        let tops = isSingleProgramme
            ? ProfileV3Theme.Sizes.BackFace.singleStackTops
            : ProfileV3Theme.Sizes.BackFace.stackTops
        let visible = Array(pass.programmes.suffix(widths.count))
        let emptySlots = widths.count - visible.count
        return ZStack(alignment: .top) {
            ForEach(0..<widths.count, id: \.self) { slot in
                Group {
                    if slot < emptySlots {
                        emptySlot(width: widths[slot], isBack: slot == 0)
                    } else {
                        ProfileV3ProgrammeCard(programme: visible[slot - emptySlots], width: widths[slot])
                    }
                }
                .padding(.top, tops[slot])
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: ProfileV3Theme.Sizes.worldPassHeight, alignment: .top)
    }

    private func emptySlot(width: CGFloat, isBack: Bool) -> some View {
        RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.md, style: .continuous)
            .fill(ProfileV3Theme.Palette.emptySlot)
            .frame(
                width: width,
                height: isBack && isSingleProgramme
                    ? ProfileV3Theme.Sizes.BackFace.backSlotHeight
                    : ProfileV3Theme.Sizes.Programme.cardHeight
            )
            .opacity(isBack ? ProfileV3Theme.Opacity.backSlot : 1)
            .accessibilityHidden(true)
    }

    private var moreIndicator: some View {
        VStack(spacing: 0) {
            Spacer()
            LinearGradient(
                colors: [Color(at: .pureWhite).opacity(0), Color(at: .pureWhite)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: ProfileV3Theme.Sizes.BackFace.fadeHeight)
            .allowsHitTesting(false)
            .overlay(alignment: .bottom) {
                Button(action: { onOpenProgrammes?() }) {
                    ATIcon.SwiftUIImage.keyboardArrowDown
                        .profileV3Icon(ProfileV3Theme.Icon.lg)
                        .foregroundStyle(Color(at: .pureBlack))
                        .frame(
                            width: ProfileV3Theme.Sizes.BackFace.plusButton,
                            height: ProfileV3Theme.Sizes.BackFace.plusButton
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.profileV3Pressable)
                .accessibilityHidden(true)
            }
        }
    }
}

#if DEBUG
#Preview("World Pass back faces") {
    VStack(spacing: ProfileV3Theme.Space.s24) {
        ProfileV3WorldPassBackFace(pass: ProfileV3Fixtures.worldPass, onAddProgramme: {}, onOpenProgrammes: {})
        ProfileV3WorldPassBackFace(pass: ProfileV3Fixtures.coTravellerPass)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(ProfileV3Theme.Palette.background)
}
#endif
