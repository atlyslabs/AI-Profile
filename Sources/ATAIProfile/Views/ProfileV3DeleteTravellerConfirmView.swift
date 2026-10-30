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
                ProfileV3ConfirmationCopy(title: confirm?.title ?? "", message: confirm?.body.nonEmpty)
            }
            .padding(.top, ProfileV3Theme.Sizes.Traveller.formNameTop)
            actions
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
    }

    private var actions: some View {
        ProfileV3ConfirmationActions(
            primaryTitle: confirm?.proceedLabel ?? "",
            secondaryTitle: confirm?.cancelLabel ?? "",
            isPrimaryLoading: isDeleting,
            onPrimary: onProceed,
            onSecondary: onBack
        )
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
