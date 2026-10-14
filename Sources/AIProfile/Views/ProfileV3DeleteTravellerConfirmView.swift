import ATUIKit
import SwiftUI

struct ProfileV3DeleteTravellerConfirmView: View {
    let traveller: ProfileV3Traveller
    var confirm: ProfileV3DeleteTravellerConfirm?
    var isDeleting = false
    let onBack: () -> Void
    let onProceed: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetChrome(title: "", onBack: onBack)
                .disabled(isDeleting)
            VStack(spacing: ProfileV3Theme.Space.s28) {
                VStack(spacing: ProfileV3Theme.Space.s20) {
                    Text(confirm?.name.nonEmpty ?? traveller.shortName)
                        .typoGraphy(.H6InterMedium18)
                        .foregroundStyle(Color(at: .pureBlack))
                    ProfileV3TravellerCardLip()
                }
                VStack(spacing: ProfileV3Theme.Space.s12) {
                    Text(confirm?.title ?? ProfileV3Strings.deleteTravellerTitle)
                        .typoGraphy(.H6InterMedium18)
                        .foregroundStyle(Color(at: .pureBlack))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: ProfileV3Theme.Sizes.Confirmation.titleWidth)
                    Text(confirm?.body.nonEmpty ?? ProfileV3Strings.deleteConfirmBody)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: ProfileV3Theme.Sizes.Confirmation.bodyWidth)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.top, ProfileV3Theme.Sizes.Traveller.formNameTop)
            actions
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
    }

    private var actions: some View {
        VStack(spacing: ProfileV3Theme.Sizes.Traveller.cardSpacing) {
            ProfileV3ContinueButton(
                title: confirm?.proceedLabel ?? ProfileV3Strings.proceedToDelete,
                tint: ProfileV3Theme.Palette.destructive,
                isLoading: isDeleting,
                action: onProceed
            )
            ProfileV3ContinueButton(
                title: confirm?.cancelLabel ?? ProfileV3Strings.dontDelete,
                isEnabled: !isDeleting,
                action: onBack
            )
        }
        .profileV3CTABar(top: ProfileV3Theme.Sizes.Confirmation.buttonsTop)
    }
}

#if DEBUG
#Preview("Delete traveller") {
    ProfileV3DeleteTravellerConfirmView(
        traveller: ProfileV3Fixtures.travellers[1],
        onBack: {},
        onProceed: {}
    )
}

#Preview("Delete traveller · server copy") {
    ProfileV3DeleteTravellerConfirmView(
        traveller: ProfileV3Fixtures.travellers[1],
        confirm: ProfileV3Fixtures.deleteTravellerConfirm(ProfileV3Fixtures.travellers[1].id),
        onBack: {},
        onProceed: {}
    )
}

#Preview("Delete traveller · deleting") {
    ProfileV3DeleteTravellerConfirmView(
        traveller: ProfileV3Fixtures.travellers[1],
        isDeleting: true,
        onBack: {},
        onProceed: {}
    )
}
#endif
