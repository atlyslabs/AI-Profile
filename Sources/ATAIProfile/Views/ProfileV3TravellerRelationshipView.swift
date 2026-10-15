import ATUIKit
import SwiftUI

struct ProfileV3TravellerRelationshipView: View {
    let field: ProfileV3EditField?
    var fallbackTitle = ""
    let selection: String?
    var phase: ProfileV3LoadPhase = .loaded
    var isSaving = false
    var canSave = false
    let onBack: () -> Void
    let onClose: () -> Void
    var onRetry: () -> Void = {}
    let onSelect: (String) -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetChrome(
                icon: ATIcon.SwiftUIImage.assignmentInd,
                title: field?.title.nonEmpty ?? fallbackTitle,
                onBack: onBack,
                onClose: onClose
            )
            if phase == .loaded, let field {
                options(field)
            } else {
                ProfileV3LoadStateView(phase: phase, retry: onRetry)
                    .frame(height: ProfileV3Theme.Sizes.settingsLoadStateHeight)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { confirmBar }
    }

    private func options(_ field: ProfileV3EditField) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s24) {
                if let subtitle = field.subtitle?.nonEmpty {
                    Text(subtitle)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(Color(at: .neutralGrey500))
                }
                ProfileV3FlowLayout {
                    ForEach(field.options) { option in
                        ProfileV3Chip(title: option.title, isSelected: option.value == selection) {
                            onSelect(option.value)
                        }
                    }
                }
                .disabled(isSaving)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Space.s32)
            .padding(.bottom, ProfileV3Theme.Sizes.settingsSheetBottom)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var confirmBar: some View {
        ProfileV3ContinueButton(
            title: field?.submitLabel?.nonEmpty ?? ProfileV3Strings.confirmEdit,
            isLoading: isSaving,
            isEnabled: canSave,
            action: onConfirm
        )
        .profileV3CTABar()
    }
}

#if DEBUG
private struct ProfileV3TravellerRelationshipPreview: View {
    var phase: ProfileV3LoadPhase = .loaded
    var isSaving = false
    @State private var selection: String? = "sibling"

    var body: some View {
        ProfileV3TravellerRelationshipView(
            field: ProfileV3Fixtures.relationshipField(profileID: "p2", selected: "sibling"),
            selection: selection,
            phase: phase,
            isSaving: isSaving,
            canSave: selection != "sibling",
            onBack: {},
            onClose: {},
            onSelect: { selection = $0 },
            onConfirm: {}
        )
    }
}

#Preview("Traveller relationship") {
    ProfileV3TravellerRelationshipPreview()
}

#Preview("Traveller relationship · loading") {
    ProfileV3TravellerRelationshipPreview(phase: .loading)
}

#Preview("Traveller relationship · failed") {
    ProfileV3TravellerRelationshipPreview(phase: .failed)
}
#endif
