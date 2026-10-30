import ATUIKit
import PostHog
import SwiftUI

struct ProfileV3EditTravellerFormView: View {
    @Binding var traveller: ProfileV3Traveller
    var isSaving = false
    var isPhoneValid = true
    var passportError: String?
    var canRemove = true
    var relationshipLabel: String?
    var relationshipValue: String?
    let onBack: () -> Void
    let onClose: () -> Void
    let onRemove: () -> Void
    var onRelationshipTap: () -> Void = {}
    let onConfirm: () -> Void

    private enum Field: Hashable {
        case firstName
        case lastName
        case phone
        case passport
    }

    @FocusState private var isPhoneFocused: Bool
    @State private var focusedField: Field?
    @State private var showsDialPicker = false

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetChrome(
                icon: ATIcon.SwiftUIImage.assignmentInd,
                title: ProfileV3Strings.editTravellers,
                onBack: onBack,
                onClose: onClose
            )
            ProfileV3FadingScroll(focused: focusedField, fillsViewport: true) {
                VStack(spacing: 0) {
                    Text(traveller.shortName)
                        .typoGraphy(.H6InterMedium18)
                        .foregroundStyle(Color(at: .pureBlack))
                        .padding(.top, ProfileV3Theme.Sizes.Traveller.formNameTop)
                    ProfileV3TravellerCardLip()
                        .padding(.top, ProfileV3Theme.Space.s24)
                    fields
                        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                        .padding(.top, ProfileV3Theme.Space.s48)
                    Spacer(minLength: ProfileV3Theme.Space.s48)
                    if canRemove {
                        ProfileV3DashedDivider()
                            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                        removeRow
                            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                            .padding(.top, ProfileV3Theme.Space.s24)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { confirmBar }
        .onChange(of: isPhoneFocused) { _, focused in track(.phone, isFocused: focused) }
        .profileV3DialCodePicker(isPresented: $showsDialPicker, selected: traveller.phoneOption) { option in
            traveller.selectDial(option)
        }
    }

    private func track(_ field: Field, isFocused: Bool) {
        if isFocused {
            focusedField = field
        } else if focusedField == field {
            focusedField = nil
        }
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s48) {
            HStack(alignment: .top, spacing: ProfileV3Theme.Space.s32) {
                ProfileV3LabelledField(
                    label: ProfileV3Strings.firstNameLabel,
                    placeholder: ProfileV3Strings.firstNamePlaceholder,
                    text: $traveller.firstName,
                    width: ProfileV3Theme.Sizes.Traveller.fieldColumnWidth,
                    onFocusChange: { track(.firstName, isFocused: $0) }
                )
                .id(Field.firstName)
                ProfileV3LabelledField(
                    label: ProfileV3Strings.lastNameLabel,
                    placeholder: ProfileV3Strings.lastNamePlaceholder,
                    text: $traveller.lastName,
                    width: ProfileV3Theme.Sizes.Traveller.fieldColumnWidth,
                    onFocusChange: { track(.lastName, isFocused: $0) }
                )
                .id(Field.lastName)
            }
            if let relationshipLabel {
                ProfileV3PickerField(label: relationshipLabel, value: relationshipValue, action: onRelationshipTap)
            }
            ProfileV3PhoneField(
                label: ProfileV3Strings.numberLabel,
                regionISO: traveller.regionISO,
                dialCode: traveller.dialCode,
                digits: $traveller.phoneDigits,
                isFocused: $isPhoneFocused,
                isValid: isPhoneValid,
                onDialTap: { showsDialPicker = true }
            )
            .id(Field.phone)
            ProfileV3LabelledField(
                label: ProfileV3Strings.passportNumber,
                placeholder: ProfileV3Strings.typeHere,
                text: $traveller.passportNumber,
                autocapitalization: .characters,
                error: passportError,
                onFocusChange: { track(.passport, isFocused: $0) }
            )
            .postHogMask()
            .id(Field.passport)
        }
    }

    private var removeRow: some View {
        Button(action: onRemove) {
            HStack(spacing: ProfileV3Theme.Space.s12) {
                ATIcon.SwiftUIImage.deleteOutline
                    .profileV3Icon(ProfileV3Theme.Icon.md)
                Text(ProfileV3Strings.removeTraveller)
                    .typoGraphy(.B1InterMedium14)
                Spacer(minLength: 0)
                ATIcon.SwiftUIImage.chevronRight
                    .profileV3Icon(ProfileV3Theme.Sizes.settingsRowIcon)
            }
            .foregroundStyle(ProfileV3Theme.Palette.destructive)
            .frame(height: ProfileV3Theme.Sizes.settingsRowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ProfileV3Strings.removeTraveller)
    }

    private var confirmBar: some View {
        ProfileV3ContinueButton(
            title: ProfileV3Strings.confirmEdit,
            isLoading: isSaving,
            isEnabled: traveller.canSave && isPhoneValid && passportError == nil,
            action: onConfirm
        )
        .profileV3CTABar()
    }
}

#if DEBUG
private struct ProfileV3EditTravellerFormPreview: View {
    @State private var traveller: ProfileV3Traveller
    private let isSaving: Bool
    private let canRemove: Bool

    init(
        traveller: ProfileV3Traveller = ProfileV3Fixtures.travellers[1],
        isSaving: Bool = false,
        canRemove: Bool = true
    ) {
        _traveller = State(initialValue: traveller)
        self.isSaving = isSaving
        self.canRemove = canRemove
    }

    var body: some View {
        ProfileV3EditTravellerFormView(
            traveller: $traveller,
            isSaving: isSaving,
            canRemove: canRemove,
            relationshipLabel: traveller.isMain ? nil : "Relationship",
            relationshipValue: traveller.isMain ? nil : "Sibling",
            onBack: {},
            onClose: {},
            onRemove: {},
            onConfirm: {}
        )
    }
}

#Preview("Edit traveller form") {
    ProfileV3EditTravellerFormPreview()
}

#Preview("Edit traveller form · saving") {
    ProfileV3EditTravellerFormPreview(isSaving: true)
}

#Preview("Edit traveller form · main traveller") {
    ProfileV3EditTravellerFormPreview(traveller: ProfileV3Fixtures.travellers[0], canRemove: false)
}

#Preview("Edit traveller form · invalid") {
    ProfileV3EditTravellerFormPreview(traveller: ProfileV3Fixtures.incompleteTraveller)
}
#endif
