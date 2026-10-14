import ATUIKit
import SwiftUI

struct ProfileV3SettingsDestinationView: View {
    let destination: ProfileV3SettingsDestination
    let viewModel: ProfileV3SettingsViewModel

    var body: some View {
        switch destination {
        case .residence, .citizenship, .currency, .contactInfo:
            ProfileV3SettingsFieldScreen(
                destination: destination,
                model: viewModel.fields,
                title: viewModel.title,
                onBack: viewModel.pop
            )
        case .controlPanel:
            ProfileV3SettingsControlPanelScreen(
                model: viewModel.connectors,
                title: viewModel.title,
                onBack: viewModel.pop
            )
        case .connectors, .appAccess:
            EmptyView()
        case .editTravellers, .editTraveller, .deleteTravellerConfirm, .addTraveller, .addTravellerCitizenship:
            ProfileV3SettingsTravellersScreen(
                destination: destination,
                model: viewModel.travellers,
                onBack: viewModel.pop,
                onClose: viewModel.tapClose
            )
        case .logout, .deleteAccount, .deleteReason:
            ProfileV3SettingsAccountScreen(destination: destination, settings: viewModel, model: viewModel.account)
        case .permissions:
            ProfileV3PermissionsView(model: viewModel.permissions, onClose: viewModel.tapClose)
        }
    }
}

private struct ProfileV3SettingsLoadState: View {
    let title: String
    let phase: ProfileV3LoadPhase
    let onBack: () -> Void
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetChrome(title: title, onBack: onBack)
            ProfileV3LoadStateView(phase: phase, retry: retry)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite))
    }
}

private struct ProfileV3SettingsFieldScreen: View {
    let destination: ProfileV3SettingsDestination
    @ObservedObject var model: ProfileV3ProfileFieldsModel
    let title: String
    let onBack: () -> Void

    var body: some View {
        if let field = model.editField, model.editFieldPhase == .loaded {
            loaded(field)
        } else {
            ProfileV3SettingsLoadState(
                title: title,
                phase: model.editFieldPhase,
                onBack: onBack,
                retry: model.retryEditField
            )
        }
    }

    @ViewBuilder
    private func loaded(_ field: ProfileV3EditField) -> some View {
        switch destination {
        case .residence:
            ProfileV3CountryPickerView(
                title: field.title,
                icon: ATIcon.SwiftUIImage.flag,
                selected: field.currentCountry ?? model.residence,
                onBack: onBack,
                onSelect: model.selectResidence
            )
        case .citizenship:
            ProfileV3CountryPickerView(
                title: field.title,
                icon: ATIcon.SwiftUIImage.language,
                selected: field.currentCountry ?? model.citizenship,
                confirmTitle: ProfileV3Strings.confirmEdit,
                onBack: onBack,
                onSelect: model.selectCitizenship
            )
        case .currency:
            ProfileV3CountryPickerView(
                title: field.title,
                icon: ATIcon.SwiftUIImage.storage,
                selected: field.currentCountry ?? model.currencyCountry,
                trailing: ProfileV3CurrencyCodes.code(for:),
                searchText: ProfileV3CurrencyCodes.searchText(for:),
                confirmTitle: ProfileV3Strings.confirmEdit,
                onBack: onBack,
                onSelect: model.selectCurrency
            )
        case .contactInfo:
            ProfileV3ContactInfoView(
                initial: field.currentContact ?? model.contactDetails,
                onBack: onBack,
                onSave: model.saveContact
            )
        default:
            EmptyView()
        }
    }
}

private struct ProfileV3SettingsControlPanelScreen: View {
    @ObservedObject var model: ProfileV3ConnectorsSettingsModel
    let title: String
    let onBack: () -> Void

    var body: some View {
        if model.controlPanelPhase == .loaded {
            ProfileV3ConnectorDeckView(
                entries: model.deckEntries,
                confirm: model.disconnectConfirm,
                onBack: onBack,
                onEngage: { model.loadDisconnectConfirm($0.id) },
                onDisconnect: { model.tapDeckDisconnect($0.id) }
            )
            .id(model.deckResetToken)
        } else {
            ProfileV3SettingsLoadState(
                title: title,
                phase: model.controlPanelPhase,
                onBack: onBack,
                retry: model.loadControlPanel
            )
        }
    }
}

struct ProfileV3DisconnectEmailHost: View {
    @ObservedObject var model: ProfileV3ConnectorsSettingsModel
    let onClose: () -> Void

    var body: some View {
        ProfileV3DisconnectEmailView(
            confirm: model.pendingConfirm,
            isDisconnecting: model.isDisconnecting,
            onBack: onClose,
            onDisconnect: model.confirmDisconnect,
            onStop: model.stopDisconnecting
        )
    }
}

private struct ProfileV3SettingsTravellersScreen: View {
    let destination: ProfileV3SettingsDestination
    @ObservedObject var model: ProfileV3TravellersSettingsModel
    let onBack: () -> Void
    let onClose: () -> Void

    var body: some View {
        switch destination {
        case .editTravellers:
            ProfileV3EditTravellersView(
                travellers: model.rows,
                worldPassLabel: model.worldPassLabel,
                worldPassIconURL: model.worldPassIconURL,
                relationshipPicker: model.relationshipPicker,
                savingRelationshipID: model.savingRelationshipID,
                phase: model.phase,
                toast: model.toast,
                onBack: onBack,
                onClose: onClose,
                onRetry: model.load,
                onSelect: model.select,
                onSelectRelationship: model.selectRelationship,
                onAdd: model.tapAdd
            )
        case .editTraveller:
            ProfileV3EditTravellerFormView(
                traveller: $model.editingTraveller,
                isSaving: model.isSavingTraveller,
                isPhoneValid: model.isEditedPhoneValid,
                passportError: model.editedPassportError,
                canRemove: model.canDelete(id: model.editingTraveller.id),
                onBack: onBack,
                onClose: onClose,
                onRemove: model.tapRemove,
                onConfirm: model.confirmEdit
            )
        case .deleteTravellerConfirm:
            ProfileV3DeleteTravellerConfirmView(
                traveller: model.editingTraveller,
                confirm: model.deleteConfirm,
                isDeleting: model.isDeletingTraveller,
                onBack: onBack,
                onProceed: model.confirmDelete
            )
        case .addTraveller:
            ProfileV3AddTravellerView(
                screen: model.addScreen,
                submission: $model.newTraveller,
                phase: model.addPhase,
                isSaving: model.isAddingTraveller,
                canSubmit: model.canSubmitNewTraveller,
                passportError: model.newTravellerPassportError,
                onBack: onBack,
                onClose: onClose,
                onRetry: model.loadAddScreen,
                onCitizenshipTap: model.tapAddCitizenship,
                onConfirm: model.confirmAdd
            )
        case .addTravellerCitizenship:
            ProfileV3CountryPickerView(
                title: ProfileV3Strings.citizenship,
                icon: ATIcon.SwiftUIImage.language,
                selected: model.newTraveller.citizenship,
                onBack: onBack,
                onSelect: model.selectAddCitizenship
            )
        default:
            EmptyView()
        }
    }
}

private struct ProfileV3SettingsAccountScreen: View {
    let destination: ProfileV3SettingsDestination
    @ObservedObject var settings: ProfileV3SettingsViewModel
    @ObservedObject var model: ProfileV3AccountSettingsModel

    var body: some View {
        switch destination {
        case .logout:
            ProfileV3ConfirmationView.logout(
                isLoggingOut: model.isLoggingOut,
                onBack: settings.pop,
                onLogout: model.confirmLogout
            )
        case .deleteAccount:
            ProfileV3ConfirmationView.deleteAccount(onBack: settings.pop, onProceed: model.tapProceedToDelete)
        case .deleteReason:
            ProfileV3DeleteReasonView(
                isSubmitting: model.isSubmittingDeletion,
                errorMessage: model.deletionError,
                onBack: settings.pop,
                onReasonChange: model.clearDeletionError,
                onSubmit: model.submitDeletion
            )
        default:
            EmptyView()
        }
    }
}
