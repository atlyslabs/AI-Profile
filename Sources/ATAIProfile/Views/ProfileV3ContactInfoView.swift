import ATUIKit
import PostHog
import SwiftUI

struct ProfileV3ContactInfoView: View {
    private enum Field {
        case email
        case phone
    }

    @StateObject private var viewModel: ProfileV3ContactInfoViewModel
    @FocusState private var focusedField: Field?

    init(
        initial: ProfileV3ContactDetails,
        onBack: @escaping () -> Void,
        onSave: @escaping (ProfileV3ContactDetails) async -> ContactUpdateOutcome
    ) {
        self.init(viewModel: ProfileV3ContactInfoViewModel(details: initial, onBack: onBack, onSave: onSave))
    }

    init(viewModel: @escaping @autoclosure () -> ProfileV3ContactInfoViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetChrome(
                icon: ATIcon.SwiftUIImage.phone,
                title: ProfileV3Strings.contactInfo,
                onBack: viewModel.tapBack
            )
            ProfileV3FadingScroll(focused: focusedField) {
                VStack(spacing: 0) {
                    Text(ProfileV3Strings.contactHelper)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: ProfileV3Theme.Sizes.Contact.helperWidth)
                        .padding(.top, ProfileV3Theme.Sizes.Contact.helperTop)
                    VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Contact.fieldSpacing) {
                        emailField
                            .id(Field.email)
                        phoneField
                            .id(Field.phone)
                    }
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.top, ProfileV3Theme.Sizes.Contact.fieldsTop)
                    .disabled(viewModel.isSaving)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color(at: .pureWhite))
        .safeAreaInset(edge: .bottom) {
            ProfileV3ContinueButton(
                title: ProfileV3Strings.confirmEdit,
                isLoading: viewModel.isSaving,
                isEnabled: viewModel.canSave
            ) {
                viewModel.save()
            }
            .profileV3CTABar()
        }
        .sensoryFeedback(.error, trigger: viewModel.serverEmailError) { _, error in error != nil }
        .profileV3DialCodePicker(
            isPresented: $viewModel.showsDialPicker,
            selected: viewModel.countryOption,
            onSelect: viewModel.selectCountry
        )
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Contact.labelSpacing) {
            ProfileV3TagLabel(text: ProfileV3Strings.emailLabel)
            TextField(ProfileV3Strings.emailPlaceholder, text: $viewModel.details.email)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureBlack))
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .postHogNoMask()
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .focused($focusedField, equals: .email)
                .padding(.bottom, ProfileV3Theme.Space.s8)
                .atFormFieldBottomLine(
                    isError: viewModel.emailError != nil,
                    isFocused: focusedField == .email,
                    style: .dashed,
                    tintsOnFocus: false
                )
            if let emailError = viewModel.emailError {
                fieldError(emailError)
            }
        }
    }

    private var phoneField: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Contact.labelSpacing) {
            ProfileV3TagLabel(text: ProfileV3Strings.numberLabel)
            HStack(spacing: ProfileV3Theme.Space.s12) {
                ProfileV3DialCodeButton(
                    regionISO: viewModel.details.regionISO,
                    dialCode: viewModel.details.dialCode
                ) {
                    viewModel.showsDialPicker = true
                }
                TextField(ProfileV3Strings.numberPlaceholder, text: $viewModel.details.phoneDigits)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(Color(at: .pureBlack))
                    .keyboardType(.numberPad)
                    .textContentType(.telephoneNumber)
                    .postHogNoMask()
                    .focused($focusedField, equals: .phone)
            }
            .padding(.bottom, ProfileV3Theme.Space.s8)
            .atFormFieldBottomLine(
                isError: viewModel.phoneError != nil,
                isFocused: focusedField == .phone,
                style: .dashed,
                tintsOnFocus: false
            )
            if let phoneError = viewModel.phoneError {
                fieldError(phoneError)
            }
        }
    }

    private func fieldError(_ text: String) -> some View {
        Text(text)
            .typoGraphy(.B2InterMedium12)
            .foregroundStyle(ProfileV3Theme.Palette.error)
    }
}

#if DEBUG
#Preview("Contact info") {
    ProfileV3ContactInfoView(initial: ProfileV3Fixtures.contactDetails, onBack: {}, onSave: { _ in .success })
}

#Preview("Contact info · saving") {
    ProfileV3ContactInfoView(viewModel: .preview(ProfileV3Fixtures.contactDetails, isSaving: true))
}

#Preview("Contact info · email taken") {
    ProfileV3ContactInfoView(
        viewModel: .preview(ProfileV3Fixtures.contactDetails, serverEmailError: ProfileV3Strings.emailTaken)
    )
}

#Preview("Contact info · invalid") {
    ProfileV3ContactInfoView(
        initial: ProfileV3ContactDetails(
            email: "not-an-email",
            phoneDigits: "12",
            regionISO: "IN",
            dialCode: "91"
        ),
        onBack: {},
        onSave: { _ in .duplicateEmail }
    )
}
#endif
