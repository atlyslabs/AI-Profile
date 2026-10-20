
import Foundation


// MARK: - Strings

internal enum ProfileV3L10n {
  internal static var moAiprofileAccountButtonConfirmDelete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-button-confirm-delete", fallback: "Proceed to delete") }
  internal static var moAiprofileAccountButtonDelete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-button-delete", fallback: "Delete account") }
  internal static var moAiprofileAccountButtonReconnect: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-button-reconnect", fallback: "Reconnect") }
  internal static var moAiprofileAccountButtonReconnectGmail: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-button-reconnect-gmail", fallback: "Reconnect Gmail") }
  internal static var moAiprofileAccountButtonStaySignedIn: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-button-stay-signed-in", fallback: "Stay signed in") }
  internal static var moAiprofileAccountConfirmationDelete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-confirmation-delete", fallback: "Are you sure you want to delete your Atlys account?") }
  internal static var moAiprofileAccountConfirmationLogout: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-confirmation-logout", fallback: "Are you sure you want to logout") }
  internal static var moAiprofileAccountContactHelperText: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-contact-helper-text", fallback: "We need your phone number to provide urgent status updates on your visa application.") }
  internal static var moAiprofileAccountDeletionDetails: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-deletion-details", fallback: "Deleting your account will delete all of its data. You will have to re-enter your documents to apply for a visa again.") }
  internal static var moAiprofileAccountDeletionReasonDescription: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-deletion-reason-description", fallback: "We would like to know so we can improve things in our mission to making travel seamless") }
  internal static var moAiprofileAccountDeletionReasonTitle: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-deletion-reason-title", fallback: "Tell us why you want to delete your Atlys account") }
  internal static var moAiprofileAccountErrorContactSaveFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-contact-save-failed", fallback: "We couldn't sync your contact info. Please try again.") }
  internal static var moAiprofileAccountErrorDeleteRequestFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-delete-request-failed", fallback: "We couldn't submit your request. Please try again.") }
  internal static var moAiprofileAccountErrorEmailTaken: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-email-taken", fallback: "This email is already linked to another Atlys account") }
  internal static var moAiprofileAccountErrorGmailSyncTimeout: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-gmail-sync-timeout", fallback: "Syncing your emails is taking longer than expected. Please try again.") }
  internal static var moAiprofileAccountErrorInvalidEmail: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-invalid-email", fallback: "Enter a valid email address") }
  internal static var moAiprofileAccountErrorInvalidPhone: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-invalid-phone", fallback: "Enter a valid phone number") }
  internal static var moAiprofileAccountErrorTravellerAddFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-traveller-add-failed", fallback: "Couldn't add that traveller. Please try again.") }
  internal static var moAiprofileAccountErrorTravellerDeleteFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-traveller-delete-failed", fallback: "Couldn't delete that traveller. Please try again.") }
  internal static var moAiprofileAccountHeaderPastTrips: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-header-past-trips", fallback: "Your past trips") }
  internal static var moAiprofileAccountHeaderPermissions: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-header-permissions", fallback: "Permissions") }
  internal static var moAiprofileAccountHeaderSettings: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-header-settings", fallback: "Settings") }
  internal static func moAiprofileAccountInputCountryCode(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-input-country-code", String(describing: p1), String(describing: p2), fallback: "Country code, +%1$@, %2$@")
  }
  internal static var moAiprofileAccountInputEmailLabel: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-input-email-label", fallback: "Email address*") }
  internal static var moAiprofileAccountInputEmailPlaceholder: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-input-email-placeholder", fallback: "name@example.com") }
  internal static var moAiprofileAccountInputPhoneLabel: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-input-phone-label", fallback: "Number") }
  internal static var moAiprofileAccountInputPhonePlaceholder: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-input-phone-placeholder", fallback: "Phone number") }
  internal static var moAiprofileAccountInputReason: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-input-reason", fallback: "Enter your reason here") }
  internal static func moAiprofileAccountMeasurementHeightCm(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-measurement-height-cm", String(describing: p1), fallback: "(%1$@cm)")
  }
  internal static func moAiprofileAccountMeasurementHeightFeet(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-measurement-height-feet", String(describing: p1), fallback: "%1$@ ft.")
  }
  internal static func moAiprofileAccountMeasurementHeightFeetInches(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-measurement-height-feet-inches", String(describing: p1), String(describing: p2), fallback: "%1$@ ft. %2$@ in")
  }
  internal static var moAiprofileAccountReconnectInstruction: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-reconnect-instruction", fallback: "Reconnect Gmail to keep your profile up to date.") }
  internal static var moAiprofileAccountSettingsButtonAddTraveller: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-add-traveller", fallback: "+ Add traveller") }
  internal static var moAiprofileAccountSettingsButtonAirportPickup: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-airport-pickup", fallback: "Select your airport pickup") }
  internal static var moAiprofileAccountSettingsButtonEditTraveller: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-edit-traveller", fallback: "Edit Traveller") }
  internal static var moAiprofileAccountSettingsButtonEditTravellers: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-edit-travellers", fallback: "Edit travellers") }
  internal static var moAiprofileAccountSettingsButtonLogout: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-logout", fallback: "Logout") }
  internal static var moAiprofileAccountSettingsButtonRemoveTraveller: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-remove-traveller", fallback: "Remove traveller from household") }
  internal static var moAiprofileAccountSettingsButtonSelectCar: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-select-car", fallback: "Select my car") }
  internal static var moAiprofileAccountSettingsInputFirstName: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-input-first-name", fallback: "FIRST NAME*") }
  internal static var moAiprofileAccountSettingsInputLastName: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-input-last-name", fallback: "LAST NAME*") }
  internal static var moAiprofileAccountSettingsLabelAccountSubtitle: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-account-subtitle", fallback: "Residence, Citizenship, Currency & Contact Info") }
  internal static var moAiprofileAccountSettingsLabelAccountsCenter: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-accounts-center", fallback: "Accounts center") }
  internal static var moAiprofileAccountSettingsLabelBuildHousehold: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-build-household", fallback: "Build your household") }
  internal static var moAiprofileAccountSettingsLabelCitizenship: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-citizenship", fallback: "Citizenship") }
  internal static var moAiprofileAccountSettingsLabelCitizenshipFromPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-citizenship-from-passport", fallback: "Citizenship is set\nfrom your passport") }
  internal static var moAiprofileAccountSettingsLabelCountryOfResidence: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-country-of-residence", fallback: "Country of residence") }
  internal static var moAiprofileAccountSettingsLabelDefaultName: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-default-name", fallback: "Traveller") }
  internal static var moAiprofileAccountSettingsLabelDeleteConfirmation: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-delete-confirmation", fallback: "Are you sure you want to delete traveller profile") }
  internal static var moAiprofileAccountSettingsLabelHouseholdSubtitle: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-household-subtitle", fallback: "Add family members to extend WorldPass perks and automate their travel") }
  internal static var moAiprofileAccountSettingsLabelTermsOfService: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-terms-of-service", fallback: "Terms of Service") }
  internal static var moAiprofileAccountSettingsLoadingPreferences: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-loading-preferences", fallback: "Getting your preferences ready") }
  internal static var moAiprofileAccountSettingsLoadingProfile: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-loading-profile", fallback: "Loading your profile") }
  internal static var moAiprofileAccountSettingsNoteEligibleRegions: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-note-eligible-regions", fallback: "Available only in eligible regions") }
  internal static var moAiprofileAccountSettingsPlaceholderFirstName: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-placeholder-first-name", fallback: "Enter first name") }
  internal static var moAiprofileAccountSettingsPlaceholderLastName: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-placeholder-last-name", fallback: "Enter last name") }
  internal static var moAiprofileAccountSettingsStatusRideStaged: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-status-ride-staged", fallback: "Your ride is staged") }
  internal static var moAiprofileAccountSettingsStatusStagingPickup: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-status-staging-pickup", fallback: "Staging your airport pickup") }
  internal static var moAiprofileAccountSettingsTextCarMembership: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-text-car-membership", fallback: "Included with membership. Switch models anytime") }
  internal static var moAiprofileAccountSettingsTextPickupBenefits: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-text-pickup-benefits", fallback: "Bypass standard taxi queues with an on-demand exotic transfer waiting at arrival") }
  internal static var moAiprofileAccountStatusDeletionPending: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-status-deletion-pending", fallback: "Account Deletion in Request") }
  internal static var moAiprofileAccountStatusKycComplete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-status-kyc-complete", fallback: "KYC complete") }
  internal static var moAiprofileAccountStatusKycExpired: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-status-kyc-expired", fallback: "KYC expired") }
  internal static var moAiprofileAccountStatusKycIncomplete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-status-kyc-incomplete", fallback: "KYC incomplete") }
  internal static var moAiprofileAccountStatusNeedsAttention: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-status-needs-attention", fallback: "Needs attention") }
  internal static var moAiprofileAccountStatusRedirectingToKyc: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-status-redirecting-to-kyc", fallback: "Redirecting you to KYC completion...") }
  internal static func moAiprofileAccountSuccessAddedTraveller(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-success-added-traveller", String(describing: p1), fallback: "Traveller profile: %1$@ was added")
  }
  internal static var moAiprofileAccountSuccessContactUpdated: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-success-contact-updated", fallback: "Contact information updated") }
  internal static func moAiprofileAccountSuccessDeletedTraveller(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-success-deleted-traveller", String(describing: p1), fallback: "Traveller profile: %1$@ was deleted")
  }
  internal static var moAiprofileAccountSuccessDeletionSubmitted: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-success-deletion-submitted", fallback: "Account deletion request submitted. Our team will email you.") }
  internal static func moAiprofileAgentConnectorTitle(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-connector-title", String(describing: p1), fallback: "Atlys x %1$@")
  }
  internal static var moAiprofileAgentDefaultLabel: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-default-label", fallback: "Agent") }
  internal static var moAiprofileAgentErrorKycRequired: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-error-kyc-required", fallback: "A quick verification is needed before this agent can be activated.") }
  internal static var moAiprofileAgentErrorUnavailable: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-error-unavailable", fallback: "This agent is taking a break. Try again in a bit.") }
  internal static var moAiprofileAgentImpactWarning: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-impact-warning", fallback: "Your agents will lose access to everything this connection provides. You can reconnect a supported service at any time.") }
  internal static var moAiprofileAgentSettingsAlwaysAsk: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-settings-always-ask", fallback: "Always ask") }
  internal static var moAiprofileAgentSettingsAskForActions: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-settings-ask-for-actions", fallback: "Ask for some actions") }
  internal static var moAiprofileAgentSettingsBeforeActionDescription: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-settings-before-action-description", fallback: "Before any action") }
  internal static var moAiprofileAgentSettingsConnectorDefaults: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-settings-connector-defaults", fallback: "Connector defaults") }
  internal static var moAiprofileAgentSettingsPermissionDescription: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-settings-permission-description", fallback: "You can give read only or read and write access") }
  internal static var moAiprofileAgentSettingsWebAccessDefaults: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-settings-web-access-defaults", fallback: "Web access defaults") }
  internal static var moAiprofileAgentSuffix: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-suffix", fallback: "agent") }
  internal static func moAiprofileAgentTagLabel(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-tag-label", String(describing: p1), String(describing: p2), fallback: "%1$@ %2$@")
  }
  internal static var moAiprofileAgentsButtonAddCredentials: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-add-credentials", fallback: "+ credentials") }
  internal static var moAiprofileAgentsButtonAddNewPassword: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-add-new-password", fallback: "+ Add new") }
  internal static var moAiprofileAgentsButtonAddStoredCredentials: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-add-stored-credentials", fallback: "+ Add credentials") }
  internal static var moAiprofileAgentsButtonConnectEmails: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-connect-emails", fallback: "Connect other emails") }
  internal static var moAiprofileAgentsButtonDeleteCredentials: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-delete-credentials", fallback: "Delete account") }
  internal static var moAiprofileAgentsButtonDisconnectApp: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-disconnect-app", fallback: "Disconnect app") }
  internal static var moAiprofileAgentsButtonDontDisconnect: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-dont-disconnect", fallback: "Don't disconnect") }
  internal static var moAiprofileAgentsButtonOtherWebsite: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-other-website", fallback: "Other website") }
  internal static var moAiprofileAgentsConfirmationDeleteCredentials: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-confirmation-delete-credentials", fallback: "Are you sure you want to delete your password credentials?") }
  internal static var moAiprofileAgentsDescriptionAppVault: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-app-vault", fallback: "A secure vault for your apps") }
  internal static var moAiprofileAgentsDescriptionCredentialStore: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-credential-store", fallback: "A secure vault for your passwords") }
  internal static var moAiprofileAgentsDescriptionCredentialStoreSheet: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-credential-store-sheet", fallback: "Securely store your passwords so Atlys can access the services you authorise when needed.") }
  internal static var moAiprofileAgentsDescriptionCredentialsUse: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-credentials-use", fallback: "Atlys only uses them to access the services you authorise, keeping you in control at every step.") }
  internal static var moAiprofileAgentsDescriptionDataVault: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-data-vault", fallback: "A secure vault for your sources") }
  internal static var moAiprofileAgentsDescriptionGmailConnector: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-gmail-connector", fallback: "Your travel details, bookings and updates are already there. Connecting email helps the agent understand and act on them without asking you to find or share everything manually.") }
  internal static var moAiprofileAgentsDescriptionItrConnector: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-itr-connector", fallback: "Your filings confirm income and travel history, so the agent can prefill applications without asking you to dig up documents.") }
  internal static var moAiprofileAgentsErrorDisconnectFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-error-disconnect-failed", fallback: "Couldn't disconnect. Please try again.") }
  internal static var moAiprofileAgentsHintConnectedApps: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-hint-connected-apps", fallback: "Find your connected apps here") }
  internal static var moAiprofileAgentsHintDisconnectConnector: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-hint-disconnect-connector", fallback: "Drag icon to disconnect") }
  internal static var moAiprofileAgentsLabelAppAccess: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-app-access", fallback: "App access") }
  internal static var moAiprofileAgentsLabelBuildUnderstanding: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-build-understanding", fallback: "Our agents build an understanding of") }
  internal static var moAiprofileAgentsLabelCredentialStore: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-credential-store", fallback: "Secure credential store") }
  internal static var moAiprofileAgentsLabelEmailConnector: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-email-connector", fallback: "Email") }
  internal static var moAiprofileAgentsLabelGmail: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-gmail", fallback: "Gmail") }
  internal static var moAiprofileAgentsLabelInformationAccess: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-information-access", fallback: "Information access") }
  internal static var moAiprofileAgentsLabelItr: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-itr", fallback: "ITR") }
  internal static var moAiprofileAgentsLabelPassword: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-password", fallback: "Password") }
  internal static var moAiprofileAgentsLabelPreferenceSlider: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-preference-slider", fallback: "Preference") }
  internal static var moAiprofileAgentsLabelRegainAccess: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-regain-access", fallback: "Regain access to agents and benefits.") }
  internal static var moAiprofileAgentsLabelTravelPreferences: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-travel-preferences", fallback: "your travel preferences") }
  internal static var moAiprofileAgentsLabelUsernameEmail: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-username-email", fallback: "Username/Email address") }
  internal static var moAiprofileAgentsLabelWebsite: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-website", fallback: "Website") }
  internal static var moAiprofileAgentsPrivacyTextSecurity: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-privacy-text-security", fallback: "Data stays secure while your agent learns") }
  internal static var moAiprofileAgentsSecurityNoteAccess: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-security-note-access", fallback: "Access is securely managed and your data is used only to help the agent work for you.") }
  internal static var moAiprofileAgentsStatusAppVaultPending: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-status-app-vault-pending", fallback: "A secure vault for your apps is on its way.") }
  internal static var moAiprofileAgentsStatusAutoConnected: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-status-auto-connected", fallback: "Auto connected") }
  internal static var moAiprofileAgentsStatusConnected: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-status-connected", fallback: "Connected") }
  internal static var moAiprofileAgentsStatusPersonaProcessing: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-status-persona-processing", fallback: "Decoding your travel choices, won’t take long...") }
  internal static var moAiprofileAgentsSubtitleTravelSecurity: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-subtitle-travel-security", fallback: "Your travel data stays secure while your agent learns from the sources you trust.") }
  internal static var moAiprofileAgentsTitleAddCredentials: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-title-add-credentials", fallback: "Add credentials") }
  internal static var moAiprofileAgentsTitleAddNewPassword: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-title-add-new-password", fallback: "Add new password") }
  internal static var moAiprofileAgentsTitleConnectors: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-title-connectors", fallback: "Connectors") }
  internal static var moAiprofileAgentsToastCredentialsUpdated: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-toast-credentials-updated", fallback: "Credentials updated") }
  internal static var moAiprofileAgentsToastPasswordAdded: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-toast-password-added", fallback: "Password added successfully") }
  internal static var moAiprofileAgentsToastPersonaUpdated: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-toast-persona-updated", fallback: "Travel persona updated") }
  internal static var moAiprofileAgentsToastPreferencesUpdated: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-toast-preferences-updated", fallback: "Agent preferences updated") }
  internal static var moAiprofileAgentsWarningDisconnectImpact: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-warning-disconnect-impact", fallback: "Disconnecting means your agents lose access to the travel history, preferences, documents and rewards that help make every trip more personal.") }
  internal static var moAiprofileDocumentsActionScan: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-action-scan", fallback: "Scan") }
  internal static var moAiprofileDocumentsButtonAddTraveller: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-button-add-traveller", fallback: "Add traveller") }
  internal static var moAiprofileDocumentsButtonUpdatePassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-button-update-passport", fallback: "Update passport") }
  internal static var moAiprofileDocumentsButtonUpload: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-button-upload", fallback: "Upload") }
  internal static var moAiprofileDocumentsButtonUploadNewPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-button-upload-new-passport", fallback: "Upload new passport") }
  internal static var moAiprofileDocumentsButtonUploadPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-button-upload-passport", fallback: "Upload passport") }
  internal static var moAiprofileDocumentsButtonViewPrevious: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-button-view-previous", fallback: "VIEW PREVIOUS") }
  internal static var moAiprofileDocumentsCountryNameIndia: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-country-name-india", fallback: "REPUBLIC OF INDIA") }
  internal static var moAiprofileDocumentsCountryNameIndiaNative: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-country-name-india-native", fallback: "भारत गणराज्य") }
  internal static var moAiprofileDocumentsEmptyStateNoPreviousPassports: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-empty-state-no-previous-passports", fallback: "No previous passports yet") }
  internal static var moAiprofileDocumentsEmptyStateNoPreviousPassportsDescription: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-empty-state-no-previous-passports-description", fallback: "Once you replace a passport, the older one shows up here") }
  internal static func moAiprofileDocumentsErrorKycExpired(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-error-kyc-expired", String(describing: p1), fallback: "KYC expired on %1$@")
  }
  internal static var moAiprofileDocumentsErrorPassportUnreadable: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-error-passport-unreadable", fallback: "We couldn't read this page. Try again in better light.") }
  internal static var moAiprofileDocumentsErrorPassportUpdateFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-error-passport-update-failed", fallback: "Couldn't update your passport. Try again.") }
  internal static var moAiprofileDocumentsErrorPassportUploadFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-error-passport-upload-failed", fallback: "Couldn't upload that page — please try again.") }
  internal static var moAiprofileDocumentsHeaderNewPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-header-new-passport", fallback: "NEW PASSPORT") }
  internal static var moAiprofileDocumentsHeaderPassportDetails: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-header-passport-details", fallback: "PASSPORT DETAILS") }
  internal static var moAiprofileDocumentsHeaderPassportReason: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-header-passport-reason", fallback: "What happened to your old passport") }
  internal static var moAiprofileDocumentsHeaderPreviousPassports: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-header-previous-passports", fallback: "PREVIOUS PASSPORTS") }
  internal static var moAiprofileDocumentsInputLabelExpiryDate: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-input-label-expiry-date", fallback: "EXPIRY DATE") }
  internal static var moAiprofileDocumentsInputLabelIssueDate: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-input-label-issue-date", fallback: "ISSUE DATE") }
  internal static var moAiprofileDocumentsInputLabelPassportNumber: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-input-label-passport-number", fallback: "PASSPORT NUMBER") }
  internal static var moAiprofileDocumentsLabelActive: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-label-active", fallback: "ACTIVE") }
  internal static func moAiprofileDocumentsLabelActiveUntil(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-label-active-until", String(describing: p1), fallback: "Active till %1$@")
  }
  internal static var moAiprofileDocumentsLabelExpired: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-label-expired", fallback: "EXPIRED") }
  internal static func moAiprofileDocumentsLabelExpiredOn(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-label-expired-on", String(describing: p1), fallback: "Expired on %1$@")
  }
  internal static func moAiprofileDocumentsLabelPassNumber(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-label-pass-number", String(describing: p1), fallback: "Pass number %1$@")
  }
  internal static var moAiprofileDocumentsPromptPassportReason: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-prompt-passport-reason", fallback: "Please specify reason for a new passport") }
  internal static var moAiprofileDocumentsReasonDamaged: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-reason-damaged", fallback: "Damaged") }
  internal static var moAiprofileDocumentsReasonLostPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-reason-lost-passport", fallback: "Lost my passport") }
  internal static var moAiprofileDocumentsReasonPagesFull: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-reason-pages-full", fallback: "Pages got over") }
  internal static var moAiprofileDocumentsReasonValidityExpired: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-reason-validity-expired", fallback: "Validity expired") }
  internal static var moAiprofileDocumentsTextHowUsedEmphasis: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-text-how-used-emphasis", fallback: "used") }
  internal static var moAiprofileDocumentsTextHowUsedLead: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-text-how-used-lead", fallback: "How this is") }
  internal static var moAiprofileDocumentsTextUploadBlurbStart: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-text-upload-blurb-start", fallback: "Your details are ready whenever you need a visa. No forms, no re-entering information, no repeating yourself.") }
  internal static var moAiprofileGeneralAccessibilityHidePassword: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-hide-password", fallback: "Hide password") }
  internal static var moAiprofileGeneralAccessibilityHintCollapse: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-hint-collapse", fallback: "Double tap to collapse") }
  internal static var moAiprofileGeneralAccessibilityHintExpand: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-hint-expand", fallback: "Double tap to expand") }
  internal static func moAiprofileGeneralAccessibilityNudge(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-nudge", String(describing: p1), String(describing: p2), fallback: "%1$@. %2$@")
  }
  internal static var moAiprofileGeneralAccessibilityOpenWebsite: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-open-website", fallback: "Open website") }
  internal static var moAiprofileGeneralAccessibilityShowPassword: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-show-password", fallback: "Show password") }
  internal static var moAiprofileGeneralAccessibilityValueCollapsed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-value-collapsed", fallback: "Collapsed") }
  internal static var moAiprofileGeneralAccessibilityValueExpanded: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-value-expanded", fallback: "Expanded") }
  internal static var moAiprofileGeneralBadgeComingSoon: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-badge-coming-soon", fallback: "Coming soon") }
  internal static var moAiprofileGeneralButtonActivate: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-activate", fallback: "Activate") }
  internal static var moAiprofileGeneralButtonAdd: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-add", fallback: "+add") }
  internal static var moAiprofileGeneralButtonAdd1: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-add-1", fallback: "+ Add") }
  internal static func moAiprofileGeneralButtonAddItem(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-add-item", String(describing: p1), fallback: "Add one %1$@")
  }
  internal static func moAiprofileGeneralButtonAddOption(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-add-option", String(describing: p1), fallback: "+Add %1$@")
  }
  internal static var moAiprofileGeneralButtonBack: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-back", fallback: "Back") }
  internal static var moAiprofileGeneralButtonClose: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-close", fallback: "Close") }
  internal static var moAiprofileGeneralButtonConfirm: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-confirm", fallback: "Confirm edit") }
  internal static var moAiprofileGeneralButtonConnect: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-connect", fallback: "Connect") }
  internal static var moAiprofileGeneralButtonContinue: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-continue", fallback: "Continue") }
  internal static var moAiprofileGeneralButtonDelete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-delete", fallback: "Delete") }
  internal static var moAiprofileGeneralButtonDone: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-done", fallback: "Done") }
  internal static var moAiprofileGeneralButtonEdit: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-edit", fallback: "Edit") }
  internal static var moAiprofileGeneralButtonGotIt: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-got-it", fallback: "Got it") }
  internal static var moAiprofileGeneralButtonHoldToExplore: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-hold-to-explore", fallback: "Hold to explore") }
  internal static var moAiprofileGeneralButtonKnowMore: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-know-more", fallback: "Know more") }
  internal static func moAiprofileGeneralButtonRemoveItem(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-remove-item", String(describing: p1), fallback: "Remove one %1$@")
  }
  internal static var moAiprofileGeneralButtonRetry: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-retry", fallback: "Retry") }
  internal static var moAiprofileGeneralButtonSave: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-save", fallback: "Save") }
  internal static var moAiprofileGeneralButtonSearch: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-search", fallback: "Search") }
  internal static var moAiprofileGeneralButtonTryAgain: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-try-again", fallback: "Try again") }
  internal static var moAiprofileGeneralButtonViewInsight: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-view-insight", fallback: "View insight") }
  internal static var moAiprofileGeneralChoiceNo: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-choice-no", fallback: "No") }
  internal static var moAiprofileGeneralChoiceYes: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-choice-yes", fallback: "Yes") }
  internal static func moAiprofileGeneralCounterPlus(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-counter-plus", String(describing: p1), fallback: "+%1$@")
  }
  internal static func moAiprofileGeneralDataDistanceKm(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-data-distance-km", String(describing: p1), fallback: "%1$@ km")
  }
  internal static var moAiprofileGeneralEmptyStateCategory: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-empty-state-category", fallback: "Nothing in this category yet") }
  internal static var moAiprofileGeneralEmptyStateCountrySearch: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-empty-state-country-search", fallback: "No countries match that search") }
  internal static var moAiprofileGeneralErrorActionUnavailable: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-action-unavailable", fallback: "That isn't available yet.") }
  internal static var moAiprofileGeneralErrorLoadFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-load-failed", fallback: "Couldn't load this screen. Check your connection and try again.") }
  internal static var moAiprofileGeneralErrorMessageGeneral: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-message-general", fallback: "Something went wrong. Please try again.") }
  internal static var moAiprofileGeneralErrorRefreshFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-refresh-failed", fallback: "Couldn't refresh your profile. Try again in a moment.") }
  internal static var moAiprofileGeneralErrorSaveFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-save-failed", fallback: "Couldn't save your changes. Try again.") }
  internal static var moAiprofileGeneralErrorSubtitleInternetIssue: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-subtitle-internet-issue", fallback: "Seems like there was an issue with your internet") }
  internal static var moAiprofileGeneralErrorTitleSomethingWentWrong: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-title-something-went-wrong", fallback: "oops something went wrong") }
  internal static func moAiprofileGeneralFormatBulleted(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-format-bulleted", String(describing: p1), fallback: "•  %1$@")
  }
  internal static var moAiprofileGeneralInputPlaceholderSearchForCountry: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-input-placeholder-search-for-country", fallback: "Search for country") }
  internal static var moAiprofileGeneralInputPlaceholderTypeHere: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-input-placeholder-type-here", fallback: "Type here") }
  internal static func moAiprofileGeneralLabelCountWithLabel(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-count-with-label", String(describing: p1), String(describing: p2), fallback: "%1$@ %2$@")
  }
  internal static var moAiprofileGeneralLabelEnterDetails: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-enter-details", fallback: "Enter details") }
  internal static var moAiprofileGeneralLabelFound: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-found", fallback: "Found") }
  internal static func moAiprofileGeneralLabelKycStatusLine(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-kyc-status-line", String(describing: p1), String(describing: p2), fallback: "%1$@ %2$@")
  }
  internal static func moAiprofileGeneralLabelKycStepFraction(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-kyc-step-fraction", String(describing: p1), String(describing: p2), fallback: "%1$@/%2$@")
  }
  internal static var moAiprofileGeneralLabelSectionComplete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-section-complete", fallback: "Complete") }
  internal static var moAiprofileGeneralLabelSectionPending: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-section-pending", fallback: "Pending") }
  internal static func moAiprofileGeneralLabelSourcesCount(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-sources-count", String(describing: p1), fallback: "%1$@ Sources")
  }
  internal static var moAiprofileGeneralLabelTermsConditions: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-terms-conditions", fallback: "Terms & Conditions") }
  internal static func moAiprofileGeneralLabelUnitValue(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-unit-value", String(describing: p1), String(describing: p2), fallback: "%1$@ %2$@")
  }
  internal static var moAiprofileGeneralLoadingText: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-loading-text", fallback: "Loading") }
  internal static func moAiprofileGeneralMaskedNumber(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-masked-number", String(describing: p1), fallback: "XXX%1$@")
  }
  internal static func moAiprofileGeneralMetadataUpdatedDynamic(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-metadata-updated-dynamic", String(describing: p1), fallback: "updated %1$@")
  }
  internal static func moAiprofileGeneralMetadataUpdatedOn(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-metadata-updated-on", String(describing: p1), fallback: "updated on %1$@")
  }
  internal static func moAiprofileGeneralPastTripOptions(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-past-trip-options", String(describing: p1), fallback: "%1$@ trip options")
  }
  internal static var moAiprofileGeneralSearchEmptySubtitle: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-search-empty-subtitle", fallback: "Please try searching for another option or check for any spelling errors") }
  internal static var moAiprofileGeneralSearchEmptyTitle: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-search-empty-title", fallback: "Looks like we couldn't find what you are looking for") }
  internal static func moAiprofileGeneralServiceLockedStatus(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-service-locked-status", String(describing: p1), fallback: "%1$@ locked for your airport pickup")
  }
  internal static var moAiprofileGeneralStatusKycUpdating: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-status-kyc-updating", fallback: "Updating…") }
  internal static func moAiprofileGeneralTextCompleteHolderKycFirst(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-text-complete-holder-kyc-first", String(describing: p1), fallback: "Complete %1$@'s KYC first...")
  }
  internal static func moAiprofileGeneralTripDateLabel(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-trip-date-label", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "%1$@, %2$@ %3$@")
  }
  internal static var moAiprofileGeneralUiButtonContactConcierge: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-ui-button-contact-concierge", fallback: "Contact concierge") }
  internal static var moAiprofileGeneralUiButtonSelect: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-ui-button-select", fallback: "Select") }
  internal static var moAiprofileGeneralUiLabelAlmostThere: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-ui-label-almost-there", fallback: "Almost there!") }
  internal static var moAiprofileGeneralUiLabelStepsDone: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-ui-label-steps-done", fallback: "steps done") }
  internal static func moAiprofileGeneralUiStepIndicator(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-ui-step-indicator", String(describing: p1), String(describing: p2), fallback: "Step %1$@ of %2$@")
  }
  internal static var moAiprofileLoyaltyButtonAddAirlines: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-add-airlines", fallback: "+Add preferred airlines") }
  internal static var moAiprofileLoyaltyButtonAddProgram: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-add-program", fallback: "Add program") }
  internal static var moAiprofileLoyaltyButtonConnectMorePrograms: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-connect-more-programs", fallback: "Connect more programs") }
  internal static var moAiprofileLoyaltyButtonCopyMembershipNumber: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-copy-membership-number", fallback: "Copy membership number") }
  internal static var moAiprofileLoyaltyButtonDoneEditing: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-done-editing", fallback: "Done editing") }
  internal static var moAiprofileLoyaltyButtonEditPrograms: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-edit-programs", fallback: "Edit programs") }
  internal static var moAiprofileLoyaltyButtonFlipCard: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-flip-card", fallback: "Flip card") }
  internal static var moAiprofileLoyaltyButtonRedeem: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-redeem", fallback: "Redeem") }
  internal static var moAiprofileLoyaltyButtonRemoveProgram: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-remove-program", fallback: "Remove") }
  internal static var moAiprofileLoyaltyButtonViewBenefits: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-view-benefits", fallback: "View all benefits") }
  internal static func moAiprofileLoyaltyButtonViewBenefits1(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-view-benefits-1", String(describing: p1), fallback: "View all %1$@ benefits")
  }
  internal static var moAiprofileLoyaltyButtonViewSources: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-view-sources", fallback: "View sources") }
  internal static var moAiprofileLoyaltyCategoryLabelAll: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-category-label-all", fallback: "All") }
  internal static var moAiprofileLoyaltyCategoryLabelCreditCards: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-category-label-credit-cards", fallback: "Credit cards") }
  internal static var moAiprofileLoyaltyCategoryLabelHotels: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-category-label-hotels", fallback: "Hotels") }
  internal static var moAiprofileLoyaltyCategoryLabelTravelPasses: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-category-label-travel-passes", fallback: "Travel passes") }
  internal static func moAiprofileLoyaltyCouponUsedAmount(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-coupon-used-amount", String(describing: p1), fallback: "%1$@ used")
  }
  internal static var moAiprofileLoyaltyEmptyStateNoProgramsConnected: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-empty-state-no-programs-connected", fallback: "No programs connected yet") }
  internal static var moAiprofileLoyaltyEmptyStateNoProgramsConnectedBody: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-empty-state-no-programs-connected-body", fallback: "Add a program to track points, tiers and expiry in one place.") }
  internal static var moAiprofileLoyaltyEmptyStateNoProgramsFound: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-empty-state-no-programs-found", fallback: "No programs found") }
  internal static var moAiprofileLoyaltyErrorAddProgramFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-add-program-failed", fallback: "Couldn't add this program. Try again.") }
  internal static var moAiprofileLoyaltyErrorBenefitKycRequired: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-benefit-kyc-required", fallback: "A quick verification is needed before this benefit can be activated.") }
  internal static var moAiprofileLoyaltyErrorInsightFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-insight-failed", fallback: "Couldn't load this insight. Try again.") }
  internal static var moAiprofileLoyaltyErrorKycRequired: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-kyc-required", fallback: "A quick verification is needed before you can add a program.") }
  internal static var moAiprofileLoyaltyErrorNoMatches: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-no-matches", fallback: "No programs match that search") }
  internal static var moAiprofileLoyaltyErrorPassSwitchFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-pass-switch-failed", fallback: "Couldn't load this World Pass. Showing the previous traveller.") }
  internal static var moAiprofileLoyaltyErrorRedeemFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-redeem-failed", fallback: "Couldn't redeem this benefit. Try again.") }
  internal static var moAiprofileLoyaltyErrorRemoveProgramFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-remove-program-failed", fallback: "Couldn't remove this program. Try again.") }
  internal static var moAiprofileLoyaltyErrorReorderFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-reorder-failed", fallback: "Couldn't save the new order. Try again.") }
  internal static func moAiprofileLoyaltyFoundProgramsLineOne(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-found-programs-line-one", String(describing: p1), fallback: "Found %1$@ program...")
  }
  internal static func moAiprofileLoyaltyFoundProgramsLineOther(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-found-programs-line-other", String(describing: p1), fallback: "Found %1$@ programs...")
  }
  internal static func moAiprofileLoyaltyFoundProgramsOne(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-found-programs-one", String(describing: p1), fallback: "%1$@ program")
  }
  internal static func moAiprofileLoyaltyFoundProgramsOther(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-found-programs-other", String(describing: p1), fallback: "%1$@ programs")
  }
  internal static var moAiprofileLoyaltyHintCardInteraction: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-hint-card-interaction", fallback: "Double tap to flip. Use Explore World Pass to open the globe.") }
  internal static var moAiprofileLoyaltyInputLabelMembershipNumber: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-input-label-membership-number", fallback: "Membership number*") }
  internal static var moAiprofileLoyaltyInstructionFlipCard: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-instruction-flip-card", fallback: "Tap to flip the card") }
  internal static var moAiprofileLoyaltyInstructionReorderCards: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-instruction-reorder-cards", fallback: "Hold and drag cards to rearrange") }
  internal static var moAiprofileLoyaltyLabelBenefitsTagline: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-benefits-tagline", fallback: "Every visa, flight and hotel on one pass") }
  internal static var moAiprofileLoyaltyLabelConnectProgramsEmphasis: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-connect-programs-emphasis", fallback: "airline and hotel programs, credit card rewards and travel passes") }
  internal static var moAiprofileLoyaltyLabelConnectProgramsLead: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-connect-programs-lead", fallback: "Connect your") }
  internal static var moAiprofileLoyaltyLabelEstimatedValue: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-estimated-value", fallback: "Est. value") }
  internal static var moAiprofileLoyaltyLabelPickProgram: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-pick-program", fallback: "Pick a loyalty program") }
  internal static var moAiprofileLoyaltyLabelPoints: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-points", fallback: "points") }
  internal static var moAiprofileLoyaltyLabelPointsMiles: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-points-miles", fallback: "Points/miles") }
  internal static var moAiprofileLoyaltyLabelProgramsConnected: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-programs-connected", fallback: "programs connected") }
  internal static var moAiprofileLoyaltyLabelSources: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-sources", fallback: "Sources") }
  internal static func moAiprofileLoyaltyProgramSummary(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-program-summary", String(describing: p1), fallback: "Read %1$@ statements, inboxes and checked upcoming trips...")
  }
  internal static var moAiprofileLoyaltyProgramsLabelCoupons: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-programs-label-coupons", fallback: "Coupons") }
  internal static var moAiprofileLoyaltyProgramsLabelRedeemed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-programs-label-redeemed", fallback: "Redeemed") }
  internal static var moAiprofileLoyaltyProgramsLabelTitle: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-programs-label-title", fallback: "Loyalty Programs") }
  internal static var moAiprofileLoyaltyProgramsLabelWorldpassName: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-programs-label-worldpass-name", fallback: "atlys worldpass") }
  internal static var moAiprofileLoyaltyScanningStatusEmphasis: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-scanning-status-emphasis", fallback: "travel benefits together.") }
  internal static var moAiprofileLoyaltyScanningStatusGoingThroughEmails: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-scanning-status-going-through-emails", fallback: "Going through emails...") }
  internal static var moAiprofileLoyaltyScanningStatusLead: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-scanning-status-lead", fallback: "bringing all your") }
  internal static var moAiprofileLoyaltyStatusRedeemedJustNow: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-status-redeemed-just-now", fallback: "Redeemed just now") }
  internal static var moAiprofileLoyaltyTextBenefitTermsHeader: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-text-benefit-terms-header", fallback: "Available to active World Pass members. Eligibility, exclusions and booking conditions may apply.") }
  internal static var moAiprofileLoyaltyTextCashbackOfferLead: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-text-cashback-offer-lead", fallback: "Enjoy 5%% off on eligible flight bookings. The offer may apply only to selected airlines, routes, travel dates or fare types and is subject to availability. Additional terms, exclusions and booking conditions may apply.") }
  internal static var moAiprofileLoyaltyTitleConnectedPrograms: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-title-connected-programs", fallback: "Connected programs") }
  internal static var moAiprofileLoyaltyTitleExploreWorldPass: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-title-explore-world-pass", fallback: "Explore World Pass") }
  internal static var moAiprofileLoyaltyToastMembershipNumberCopied: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-toast-membership-number-copied", fallback: "Membership number copied") }
  internal static func moAiprofileProfileAccessibilityVisitedCountries(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-accessibility-visited-countries", String(describing: p1), fallback: "Visited countries, %1$@. Add past trips")
  }
  internal static var moAiprofileProfileButtonAddCountry: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-button-add-country", fallback: "Add country") }
  internal static var moAiprofileProfileButtonAddPastTrip: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-button-add-past-trip", fallback: "Add past trip") }
  internal static var moAiprofileProfileButtonAddPastTrips: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-button-add-past-trips", fallback: "Add past trips") }
  internal static var moAiprofileProfileButtonCompleteKyc: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-button-complete-kyc", fallback: "Complete KYC") }
  internal static var moAiprofileProfileButtonDontDelete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-button-dont-delete", fallback: "Don't delete") }
  internal static var moAiprofileProfileButtonSaveChanges: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-button-save-changes", fallback: "save changes") }
  internal static var moAiprofileProfileConfirmationDeleteDestination: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-confirmation-delete-destination", fallback: "Are you sure you want to delete your past destination?") }
  internal static var moAiprofileProfileEmptyStateNoTrips: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-empty-state-no-trips", fallback: "No past trips yet") }
  internal static var moAiprofileProfileEmptyStateNoTripsBody: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-empty-state-no-trips-body", fallback: "Add the countries you've visited to build your travel map.") }
  internal static var moAiprofileProfileErrorPastTripDeleteFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-error-past-trip-delete-failed", fallback: "Couldn't delete this trip. Please try again.") }
  internal static var moAiprofileProfileErrorPastTripDuplicate: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-error-past-trip-duplicate", fallback: "You've already added this trip") }
  internal static var moAiprofileProfileErrorPastTripSaveFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-error-past-trip-save-failed", fallback: "Couldn't save this trip. Please try again.") }
  internal static var moAiprofileProfileInputLabelMonth: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-input-label-month", fallback: "Month") }
  internal static var moAiprofileProfileInputLabelSelectDuration: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-input-label-select-duration", fallback: "Select duration") }
  internal static var moAiprofileProfileInputLabelYear: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-input-label-year", fallback: "Year") }
  internal static var moAiprofileProfileOptionRatherNotSay: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-option-rather-not-say", fallback: "Rather not say") }
  internal static var moAiprofileProfileStatLabelAirlines: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-stat-label-airlines", fallback: "Airlines") }
  internal static var moAiprofileProfileStatLabelAirports: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-stat-label-airports", fallback: "Airports") }
  internal static var moAiprofileProfileStatLabelCountries: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-stat-label-countries", fallback: "Countries") }
  internal static var moAiprofileProfileStatLabelDistance: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-stat-label-distance", fallback: "Distance") }
  internal static var moAiprofileProfileStatLabelFlights: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-stat-label-flights", fallback: "Flights") }
  internal static var moAiprofileSettingsBodyDisconnectProgress: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-body-disconnect-progress", fallback: "Removing synced data and access from your agents, this may take a while…") }
  internal static var moAiprofileSettingsButtonDisconnectEmail: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-button-disconnect-email", fallback: "Disconnect email") }
  internal static var moAiprofileSettingsButtonStopDisconnecting: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-button-stop-disconnecting", fallback: "Stop disconnecting") }
  internal static var moAiprofileSettingsCheckboxDisconnectConsent: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-checkbox-disconnect-consent", fallback: "I have read and agree to the terms") }
  internal static var moAiprofileSettingsDialogTitleDisconnect: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-dialog-title-disconnect", fallback: "Are you sure you want to disconnect your email?") }
  internal static var moAiprofileSettingsDisconnectionDisclaimer: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-disconnection-disclaimer", fallback: "Once disconnected, agents may no longer be able to use this information to personalise recommendations, identify relevant benefits, prepare trips, complete workflows or provide context-aware assistance. Previously synced information may also need to be reconnected or provided again before certain features can be restored.") }
  internal static var moAiprofileSettingsDisconnectionTermsIntro: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-disconnection-terms-intro", fallback: "By proceeding with disconnection, the selected account connection will be revoked and the associated data will no longer be available to your agents for future use.") }
  internal static var moAiprofileSettingsFeatureLossItem: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-feature-loss-item", fallback: "No automated slot booking") }
  internal static var moAiprofileSettingsFeatureLossItem1: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-feature-loss-item-1", fallback: "No visa applications") }
  internal static var moAiprofileSettingsFeatureLossItem2: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-feature-loss-item-2", fallback: "No personalised offers") }
  internal static var moAiprofileSettingsHeaderTerms: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-header-terms", fallback: "Terms and Conditions") }
  internal static var moAiprofileSettingsImpactListItem: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-impact-list-item", fallback: "Flight and travel history") }
  internal static var moAiprofileSettingsImpactListItem1: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-impact-list-item-1", fallback: "Hotel stays and booking preferences") }
  internal static var moAiprofileSettingsImpactListItem2: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-impact-list-item-2", fallback: "Loyalty programs, points and rewards") }
  internal static var moAiprofileSettingsImpactListItem3: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-impact-list-item-3", fallback: "Credit card benefits and travel-related offers") }
  internal static var moAiprofileSettingsImpactListItem4: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-impact-list-item-4", fallback: "Travel documents, passes and credentials") }
  internal static var moAiprofileSettingsImpactListItem5: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-impact-list-item-5", fallback: "Itineraries, bookings and trip information") }
  internal static var moAiprofileSettingsImpactListItem6: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-impact-list-item-6", fallback: "Saved food preferences and dietary requirements") }
  internal static var moAiprofileSettingsImpactListItem7: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-impact-list-item-7", fallback: "Personal preferences and agent-learned travel context") }
  internal static var moAiprofileSettingsImpactListItem8: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-impact-list-item-8", fallback: "Medical information and documents previously shared for travel-related assistance") }
  internal static var moAiprofileSettingsImpactListItem9: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-impact-list-item-9", fallback: "Airport, immigration and other travel logistics information") }
  internal static var moAiprofileSettingsLabelContactInfo: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-label-contact-info", fallback: "Contact info") }
  internal static var moAiprofileSettingsLabelCurrency: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-label-currency", fallback: "Currency") }
  internal static func moAiprofileSettingsLabelDialCode(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-label-dial-code", String(describing: p1), fallback: "+%1$@")
  }
  internal static func moAiprofileSettingsLabelPreferencesCount(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-label-preferences-count", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "%1$@/%2$@ %3$@ preferences")
  }
  internal static func moAiprofileSettingsLabelRequiredField(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-label-required-field", String(describing: p1), fallback: "%1$@*")
  }
  internal static var moAiprofileSettingsLegalDisclaimerPart1: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-legal-disclaimer-part-1", fallback: "Disconnection revokes future access to the connected source. Processing, retention and deletion of previously received data will continue in accordance with the applicable privacy policy, consent settings and legal or operational requirements.") }
  internal static var moAiprofileSettingsListHeader: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-list-header", fallback: "This may include, where applicable:") }
  internal static var moAiprofileSettingsReconnectionNotice: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-reconnection-notice", fallback: "You may reconnect supported services at any time. Reconnecting does not guarantee that previously available data, preferences or agent context will be automatically restored.") }
  internal static var moAiprofileSettingsTitleDisconnectProgress: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-title-disconnect-progress", fallback: "Disconnecting your account…") }
  internal static var moAiprofileTravelDocsInputLabelBloodGroup: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-docs-input-label-blood-group", fallback: "Blood group") }
  internal static var moAiprofileTravelDocsInputLabelDob: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-docs-input-label-dob", fallback: "D.O.B") }
  internal static var moAiprofileTravelDocsInputLabelEmergencyContact: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-docs-input-label-emergency-contact", fallback: "Emergency contact") }
  internal static var moAiprofileTravelDocsInputLabelOrganDonor: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-docs-input-label-organ-donor", fallback: "Organ donor") }
  internal static var moAiprofileTravelDocsLabelMedicalCardLocked: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-docs-label-medical-card-locked", fallback: "Open medical card when phone is locked") }
  internal static var moAiprofileTravelDocumentsErrorDuplicatePassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-documents-error-duplicate-passport", fallback: "This passport number is already added to another traveller.") }
  internal static var moAiprofileTravelErrorInvalidIndianPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-error-invalid-indian-passport", fallback: "Enter a valid Indian passport number, like A1234567") }
  internal static var moAiprofileTravelErrorInvalidPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-error-invalid-passport", fallback: "Enter a valid passport number") }
}

// MARK: - Implementation Details

extension ProfileV3L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = ProfileV3DittoRuntimeStrings.lookup(key, table, value)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
