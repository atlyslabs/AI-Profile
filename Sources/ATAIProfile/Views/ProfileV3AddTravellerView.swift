import ATUIKit
import SwiftUI

struct ProfileV3AddTravellerView: View {
    let screen: ProfileV3AddTravellerScreen?
    @Binding var submission: ProfileV3AddTravellerSubmission
    var phase: ProfileV3LoadPhase = .loaded
    var isSaving = false
    var canSubmit = false
    var passportError: String?
    let onBack: () -> Void
    let onClose: () -> Void
    var onRetry: () -> Void = {}
    var onCitizenshipTap: () -> Void = {}
    let onConfirm: () -> Void

    @State private var focusedKey: String?
    @State private var showsDialPicker = false
    @FocusState private var isPhoneFocused: Bool

    private static let nameKeys = [ProfileV3AddTravellerField.firstNameKey, ProfileV3AddTravellerField.lastNameKey]

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetChrome(
                icon: ATIcon.SwiftUIImage.assignmentInd,
                title: screen?.title ?? "",
                onBack: onBack,
                onClose: onClose
            )
            if phase == .loaded, let screen {
                content(screen)
            } else {
                ProfileV3LoadStateView(phase: phase, retry: onRetry)
                    .frame(height: ProfileV3Theme.Sizes.settingsLoadStateHeight)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { confirmBar }
        .onChange(of: isPhoneFocused) { _, focused in track(ProfileV3AddTravellerField.mobileNumberKey, focused) }
        .sheet(isPresented: $showsDialPicker) {
            LoginCountryPickerSheet(
                countries: LoginCountryOption.profileV3Options,
                selected: submission.phoneOption,
                onSelect: { option in
                    submission.selectDial(option)
                    showsDialPicker = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private func content(_ screen: ProfileV3AddTravellerScreen) -> some View {
        ProfileV3FocusScroll(focused: focusedKey) {
            VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s40) {
                if !screen.subtitle.isEmpty {
                    Text(screen.subtitle)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(Color(at: .neutralGrey500))
                }
                nameRow(screen)
                ForEach(textFields(screen).filter { !Self.nameKeys.contains($0.key) }) { field in
                    textField(field)
                }
                if let field = screen.field(ProfileV3AddTravellerField.mobileNumberKey) {
                    phoneField(field)
                }
                if let field = screen.field(ProfileV3AddTravellerField.passportNumberKey) {
                    textField(field)
                }
                if let field = screen.field(ProfileV3AddTravellerField.citizenshipKey) {
                    citizenshipField(field)
                }
                ForEach(screen.fields.filter { $0.input == .singleSelect }) { field in
                    selectField(field)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Space.s32)
            .padding(.bottom, ProfileV3Theme.Sizes.settingsSheetBottom)
        }
    }

    @ViewBuilder
    private func nameRow(_ screen: ProfileV3AddTravellerScreen) -> some View {
        let names = textFields(screen).filter { Self.nameKeys.contains($0.key) }
        if names.count > 1 {
            HStack(alignment: .top, spacing: ProfileV3Theme.Space.s32) {
                ForEach(names) { field in
                    textField(field, width: ProfileV3Theme.Sizes.Traveller.fieldColumnWidth)
                }
            }
        } else {
            ForEach(names) { field in
                textField(field)
            }
        }
    }

    private func textField(_ field: ProfileV3AddTravellerField, width: CGFloat? = nil) -> some View {
        ProfileV3LabelledField(
            label: label(for: field),
            placeholder: placeholder(for: field),
            text: Binding(get: { submission[text: field.key] }, set: { submission[text: field.key] = $0 }),
            autocapitalization: field.key == ProfileV3AddTravellerField.passportNumberKey ? .characters : .sentences,
            width: width,
            error: field.key == ProfileV3AddTravellerField.passportNumberKey ? passportError : nil,
            onFocusChange: { track(field.key, $0) }
        )
        .id(field.key)
    }

    private func selectField(_ field: ProfileV3AddTravellerField) -> some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s12) {
            ProfileV3FieldLabel(text: label(for: field))
            ProfileV3FlowLayout {
                ForEach(field.options) { option in
                    ProfileV3Chip(
                        title: option.title,
                        isSelected: submission.selections[field.key] == option.value,
                        action: { submission.toggle(option, in: field) }
                    )
                }
            }
        }
    }

    private func phoneField(_ field: ProfileV3AddTravellerField) -> some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s12) {
            ProfileV3FieldLabel(text: label(for: field))
            ProfileV3PhoneInput(
                regionISO: submission.regionISO,
                dialCode: submission.dialCode,
                digits: $submission.phoneDigits,
                isFocused: $isPhoneFocused,
                isError: !submission.isPhoneValid,
                onDialTap: { showsDialPicker = true }
            )
            if !submission.isPhoneValid {
                Text(ProfileV3Strings.phoneInvalid)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(ProfileV3Theme.Palette.error)
            }
        }
        .id(ProfileV3AddTravellerField.mobileNumberKey)
    }

    private func citizenshipField(_ field: ProfileV3AddTravellerField) -> some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s12) {
            ProfileV3FieldLabel(text: label(for: field))
            Button(action: onCitizenshipTap) {
                HStack(spacing: ProfileV3Theme.Space.s12) {
                    if let code = submission.citizenship?.code, let country = ATCountry(isoCode: code) {
                        ATCountryFlagView(country: country)
                            .frame(
                                width: ProfileV3Theme.Sizes.Contact.dialFlag,
                                height: ProfileV3Theme.Sizes.Contact.dialFlag
                            )
                            .clipShape(Circle())
                    }
                    Text(submission.citizenship?.name ?? ProfileV3Strings.selectPlaceholder)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(
                            submission.citizenship == nil ? Color(at: .neutralGrey200) : Color(at: .pureBlack)
                        )
                    Spacer(minLength: 0)
                    ATIcon.SwiftUIImage.expandMore
                        .profileV3Icon(ProfileV3Theme.Icon.md)
                        .foregroundStyle(Color(at: .neutralGrey400))
                }
                .padding(.bottom, ProfileV3Theme.Space.s8)
                .atFormFieldBottomLine(isError: false, isFocused: false, style: .dashed, tintsOnFocus: false)
                .contentShape(Rectangle())
            }
            .buttonStyle(.profileV3Pressable)
            .accessibilityLabel(label(for: field))
            .accessibilityValue(submission.citizenship?.name ?? "")
        }
        .id(field.key)
    }

    private func textFields(_ screen: ProfileV3AddTravellerScreen) -> [ProfileV3AddTravellerField] {
        screen.fields.filter { $0.input == .text && !ProfileV3AddTravellerField.dedicatedKeys.contains($0.key) }
    }

    private func track(_ key: String, _ isFocused: Bool) {
        if isFocused {
            focusedKey = key
        } else if focusedKey == key {
            focusedKey = nil
        }
    }

    private func label(for field: ProfileV3AddTravellerField) -> String {
        guard !field.label.isEmpty else { return "" }
        return field.isRequired ? ProfileV3Strings.requiredLabel(field.label) : field.label
    }

    private func placeholder(for field: ProfileV3AddTravellerField) -> String {
        switch field.key {
        case ProfileV3AddTravellerField.firstNameKey: return ProfileV3Strings.firstNamePlaceholder
        case ProfileV3AddTravellerField.lastNameKey: return ProfileV3Strings.lastNamePlaceholder
        default: return ProfileV3Strings.typeHere
        }
    }

    @ViewBuilder
    private var confirmBar: some View {
        if let submitLabel = screen?.submitLabel.nonEmpty {
            ProfileV3ContinueButton(
                title: submitLabel,
                isLoading: isSaving,
                isEnabled: canSubmit,
                action: onConfirm
            )
            .profileV3CTABar()
        }
    }
}

#if DEBUG
private struct ProfileV3AddTravellerPreview: View {
    var phase: ProfileV3LoadPhase = .loaded
    var isSaving = false
    @State var submission = ProfileV3AddTravellerSubmission(regionISO: "IN", dialCode: "91")

    var body: some View {
        ProfileV3AddTravellerView(
            screen: ProfileV3Fixtures.addTraveller,
            submission: $submission,
            phase: phase,
            isSaving: isSaving,
            canSubmit: submission.canSubmit(fields: ProfileV3Fixtures.addTraveller.fields) && submission.isPhoneValid
                && submission.passportError == nil,
            passportError: submission.passportError,
            onBack: {},
            onClose: {},
            onConfirm: {}
        )
    }
}

#Preview("Add traveller") {
    ProfileV3AddTravellerPreview()
}

#Preview("Add traveller · loading") {
    ProfileV3AddTravellerPreview(phase: .loading)
}

#Preview("Add traveller · saving") {
    ProfileV3AddTravellerPreview(
        isSaving: true,
        submission: ProfileV3AddTravellerSubmission(
            firstName: "Alex",
            lastName: "Rivera",
            regionISO: "IN",
            dialCode: "91"
        )
    )
}

#Preview("Add traveller · invalid phone") {
    ProfileV3AddTravellerPreview(
        submission: ProfileV3AddTravellerSubmission(regionISO: "IN", dialCode: "91", phoneDigits: "123")
    )
}
#endif
