// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable function_parameter_count identifier_name line_length type_body_length
internal enum ProfileV3L10n {
  /// Button to confirm proceeding with account deletion.
  internal static var moAiprofileAccountButtonConfirmDelete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-button-confirm-delete", fallback: "Proceed to delete") }
  /// Button to initiate account deletion flow.
  internal static var moAiprofileAccountButtonDelete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-button-delete", fallback: "Delete account") }
  /// Action to cancel logout and remain in account.
  internal static var moAiprofileAccountButtonStaySignedIn: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-button-stay-signed-in", fallback: "Stay signed in") }
  /// Confirmation message for logout action.
  internal static var moAiprofileAccountConfirmationLogout: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-confirmation-logout", fallback: "Are you sure you want to logout") }
  /// Helper text explaining why contact info is requested.
  internal static var moAiprofileAccountContactHelperText: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-contact-helper-text", fallback: "We need your phone number to provide urgent status updates on your visa application.") }
  /// Error when saving contact info fails.
  internal static var moAiprofileAccountErrorContactSaveFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-contact-save-failed", fallback: "We couldn't sync your contact info. Please try again.") }
  /// Error when the account deletion request fails.
  internal static var moAiprofileAccountErrorDeleteRequestFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-delete-request-failed", fallback: "We couldn't submit your request. Please try again.") }
  /// Error message when email address is already in use.
  internal static var moAiprofileAccountErrorEmailTaken: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-email-taken", fallback: "This email is already linked to another Atlys account") }
  /// ErrorMessage displayed when email sync fails.
  internal static var moAiprofileAccountErrorGmailSyncTimeout: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-gmail-sync-timeout", fallback: "Syncing your emails is taking longer than expected. Please try again.") }
  /// Validation error for malformed email.
  internal static var moAiprofileAccountErrorInvalidEmail: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-invalid-email", fallback: "Enter a valid email address") }
  /// Validation error for malformed phone number.
  internal static var moAiprofileAccountErrorInvalidPhone: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-invalid-phone", fallback: "Enter a valid phone number") }
  /// Error when adding a household traveler fails.
  internal static var moAiprofileAccountErrorTravelerAddFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-traveler-add-failed", fallback: "Couldn't add that traveler. Please try again.") }
  /// Error when removing a household traveler fails.
  internal static var moAiprofileAccountErrorTravelerDeleteFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-error-traveler-delete-failed", fallback: "Couldn't delete that traveler. Please try again.") }
  /// Header title for permissions section.
  internal static var moAiprofileAccountHeaderPermissions: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-header-permissions", fallback: "Permissions") }
  /// Header title for settings section.
  internal static var moAiprofileAccountHeaderSettings: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-header-settings", fallback: "Settings") }
  /// Phone country code selection label.
  internal static func moAiprofileAccountInputCountryCode(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-input-country-code", String(describing: p1), String(describing: p2), fallback: "Country code, +%1$@, %2$@")
  }
  /// Label for email input field.
  internal static var moAiprofileAccountInputEmailLabel: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-input-email-label", fallback: "Email address*") }
  /// Placeholder for email input field.
  internal static var moAiprofileAccountInputEmailPlaceholder: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-input-email-placeholder", fallback: "name@example.com") }
  /// Label for phone number input field.
  internal static var moAiprofileAccountInputPhoneLabel: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-input-phone-label", fallback: "Number") }
  /// Placeholder for phone number input field.
  internal static var moAiprofileAccountInputPhonePlaceholder: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-input-phone-placeholder", fallback: "Phone number") }
  /// Height measurement label in centimeters.
  internal static func moAiprofileAccountMeasurementHeightCm(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-measurement-height-cm", String(describing: p1), fallback: "(%1$@cm)")
  }
  /// Height measurement label in feet.
  internal static func moAiprofileAccountMeasurementHeightFeet(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-measurement-height-feet", String(describing: p1), fallback: "%1$@ ft.")
  }
  /// Height shown in feet and inches.
  internal static func moAiprofileAccountMeasurementHeightFeetInches(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-measurement-height-feet-inches", String(describing: p1), String(describing: p2), fallback: "%1$@ ft. %2$@ in")
  }
  /// Button to add a new traveler profile.
  internal static var moAiprofileAccountSettingsButtonAddTraveler: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-add-traveler", fallback: "+ Add traveler") }
  /// Action button to edit a single traveler's details.
  internal static var moAiprofileAccountSettingsButtonEditTraveler: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-edit-traveler", fallback: "Edit Traveler") }
  /// Action button to edit a list of travelers.
  internal static var moAiprofileAccountSettingsButtonEditTravelers: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-edit-travelers", fallback: "Edit travelers") }
  /// Button to sign out of the account.
  internal static var moAiprofileAccountSettingsButtonLogout: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-logout", fallback: "Logout") }
  /// Action button to remove a traveler from the household.
  internal static var moAiprofileAccountSettingsButtonRemoveTraveler: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-remove-traveler", fallback: "Remove traveler from household") }
  /// Button to trigger car selection interface.
  internal static var moAiprofileAccountSettingsButtonSelectCar: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-button-select-car", fallback: "Select my car") }
  /// Label for the first name input field.
  internal static var moAiprofileAccountSettingsInputFirstName: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-input-first-name", fallback: "FIRST NAME*") }
  /// Label for the last name input field.
  internal static var moAiprofileAccountSettingsInputLastName: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-input-last-name", fallback: "LAST NAME*") }
  /// Title for the household management section.
  internal static var moAiprofileAccountSettingsLabelBuildHousehold: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-build-household", fallback: "Build your household") }
  /// Label for the citizenship field in user profile.
  internal static var moAiprofileAccountSettingsLabelCitizenship: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-citizenship", fallback: "Citizenship") }
  /// Two-line note shown when citizenship is locked to the passport.
  internal static var moAiprofileAccountSettingsLabelCitizenshipFromPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-citizenship-from-passport", fallback: "Citizenship is set\nfrom your passport") }
  /// Label for the country of residence field in user profile.
  internal static var moAiprofileAccountSettingsLabelCountryOfResidence: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-country-of-residence", fallback: "Country of residence") }
  /// Fallback display name for a traveler.
  internal static var moAiprofileAccountSettingsLabelDefaultName: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-default-name", fallback: "Traveler") }
  /// Descriptive subtitle for household management perks.
  internal static var moAiprofileAccountSettingsLabelHouseholdSubtitle: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-household-subtitle", fallback: "Add family members to extend WorldPass perks and automate their travel") }
  /// Link label for legal terms of service.
  internal static var moAiprofileAccountSettingsLabelTermsOfService: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-label-terms-of-service", fallback: "Terms of Service") }
  /// Loading state specifically for user preference retrieval.
  internal static var moAiprofileAccountSettingsLoadingPreferences: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-loading-preferences", fallback: "Getting your preferences ready") }
  /// Loading state for profile dashboard.
  internal static var moAiprofileAccountSettingsLoadingProfile: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-loading-profile", fallback: "Loading your profile") }
  /// Placeholder text for the first name field.
  internal static var moAiprofileAccountSettingsPlaceholderFirstName: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-placeholder-first-name", fallback: "Enter first name") }
  /// Placeholder text for the last name field.
  internal static var moAiprofileAccountSettingsPlaceholderLastName: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-placeholder-last-name", fallback: "Enter last name") }
  /// Confirmation message for staged ride status.
  internal static var moAiprofileAccountSettingsStatusRideStaged: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-status-ride-staged", fallback: "Your ride is staged") }
  /// Status message indicating an ongoing process for airport pickup.
  internal static var moAiprofileAccountSettingsStatusStagingPickup: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-settings-status-staging-pickup", fallback: "Staging your airport pickup") }
  /// Status label indicating pending account deletion.
  internal static var moAiprofileAccountStatusDeletionPending: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-status-deletion-pending", fallback: "Account Deletion in Request") }
  /// Label indicating successful KYC status completion.
  internal static var moAiprofileAccountStatusKycComplete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-status-kyc-complete", fallback: "KYC complete") }
  /// Label indicating incomplete KYC verification status.
  internal static var moAiprofileAccountStatusKycIncomplete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-status-kyc-incomplete", fallback: "KYC incomplete") }
  /// Label indicating a document or section requires user review.
  internal static var moAiprofileAccountStatusNeedsAttention: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-status-needs-attention", fallback: "Needs attention") }
  /// Status message while navigating to KYC completion.
  internal static var moAiprofileAccountStatusRedirectingToKyc: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-status-redirecting-to-kyc", fallback: "Redirecting you to KYC completion...") }
  /// Confirmation message for added user profiles.
  internal static func moAiprofileAccountSuccessAddedTraveler(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-success-added-traveler", String(describing: p1), fallback: "Traveler profile: %1$@ was added")
  }
  /// Confirmation after updating contact information.
  internal static var moAiprofileAccountSuccessContactUpdated: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-success-contact-updated", fallback: "Contact information updated") }
  /// Confirmation message for deleted user profiles.
  internal static func moAiprofileAccountSuccessDeletedTraveler(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-success-deleted-traveler", String(describing: p1), fallback: "Traveler profile: %1$@ was deleted")
  }
  /// Success message after requesting account deletion.
  internal static var moAiprofileAccountSuccessDeletionSubmitted: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-account-success-deletion-submitted", fallback: "Account deletion request submitted. Our team will email you.") }
  /// Error message requiring KYC verification for agent activation.
  internal static var moAiprofileAgentErrorKycRequired: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-error-kyc-required", fallback: "A quick verification is needed before this agent can be activated.") }
  /// Error message for unavailable agent.
  internal static var moAiprofileAgentErrorUnavailable: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-error-unavailable", fallback: "This agent is taking a break. Try again in a bit.") }
  /// Configuration option for AI agent to always ask for permission.
  internal static var moAiprofileAgentSettingsAlwaysAsk: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-settings-always-ask", fallback: "Always ask") }
  /// Configuration option for AI agent action behavior.
  internal static var moAiprofileAgentSettingsAskForActions: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-settings-ask-for-actions", fallback: "Ask for some actions") }
  /// Description for the always-ask configuration setting.
  internal static var moAiprofileAgentSettingsBeforeActionDescription: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-settings-before-action-description", fallback: "Before any action") }
  /// Settings category for default connector configurations.
  internal static var moAiprofileAgentSettingsConnectorDefaults: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-settings-connector-defaults", fallback: "Connector defaults") }
  /// Explanation of access permission levels for AI agents.
  internal static var moAiprofileAgentSettingsPermissionDescription: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-settings-permission-description", fallback: "You can give read only or read and write access") }
  /// Settings category for default web access configurations.
  internal static var moAiprofileAgentSettingsWebAccessDefaults: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-settings-web-access-defaults", fallback: "Web access defaults") }
  /// Refers to an AI agent suffix or label.
  internal static var moAiprofileAgentSuffix: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-suffix", fallback: "agent") }
  /// Tag label used to identify agent-based entries.
  internal static func moAiprofileAgentTagLabel(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agent-tag-label", String(describing: p1), String(describing: p2), fallback: "%1$@ %2$@")
  }
  /// App access row button that adds credentials for a pending app.
  internal static var moAiprofileAgentsButtonAddCredentials: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-add-credentials", fallback: "+ credentials") }
  /// Floating App access button that adds a new password.
  internal static var moAiprofileAgentsButtonAddNewPassword: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-add-new-password", fallback: "+ Add new") }
  /// Credential store sheet button that starts adding a saved login.
  internal static var moAiprofileAgentsButtonAddStoredCredentials: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-add-stored-credentials", fallback: "+ Add credentials") }
  /// Button to trigger the flow for adding additional email accounts.
  internal static var moAiprofileAgentsButtonConnectEmails: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-connect-emails", fallback: "Connect other emails") }
  /// Floating button on an agent form that opens the custom rule editor.
  internal static var moAiprofileAgentsButtonCustomRule: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-custom-rule", fallback: "Custom") }
  /// Saved login row that deletes the stored credentials.
  internal static var moAiprofileAgentsButtonDeleteCredentials: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-delete-credentials", fallback: "Delete account") }
  /// Accessibility label of the delete button in the custom rule editor.
  internal static var moAiprofileAgentsButtonDeleteRule: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-delete-rule", fallback: "Delete rule") }
  /// Connectors deck action that disconnects a connected app.
  internal static var moAiprofileAgentsButtonDisconnectApp: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-disconnect-app", fallback: "Disconnect app") }
  /// Household apply sheet confirm button, used when the server sends no label.
  internal static var moAiprofileAgentsButtonHouseholdConfirm: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-household-confirm", fallback: "Confirm") }
  /// Website picker row for a site that isn't listed.
  internal static var moAiprofileAgentsButtonOtherWebsite: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-other-website", fallback: "Other website") }
  /// Button that saves a new custom rule.
  internal static var moAiprofileAgentsButtonSaveRule: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-button-save-rule", fallback: "Save") }
  /// Confirmation title before deleting a saved login.
  internal static var moAiprofileAgentsConfirmationDeleteCredentials: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-confirmation-delete-credentials", fallback: "Are you sure you want to delete your password credentials?") }
  /// Description for the app connector vault feature.
  internal static var moAiprofileAgentsDescriptionAppVault: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-app-vault", fallback: "A secure vault for your apps") }
  /// Settings card subtitle for the secure credential store.
  internal static var moAiprofileAgentsDescriptionCredentialStore: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-credential-store", fallback: "A secure vault for your passwords") }
  /// Credential store sheet subtitle.
  internal static var moAiprofileAgentsDescriptionCredentialStoreSheet: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-credential-store-sheet", fallback: "Securely store your passwords so Atlys can access the services you authorise when needed.") }
  /// Note on the credentials sheet about how the saved credentials are used.
  internal static var moAiprofileAgentsDescriptionCredentialsUse: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-credentials-use", fallback: "Atlys only uses them to access the services you authorise, keeping you in control at every step.") }
  /// Description for the source connector vault feature.
  internal static var moAiprofileAgentsDescriptionDataVault: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-data-vault", fallback: "A secure vault for your sources") }
  /// Introductory blurb for the Gmail connector functionality.
  internal static var moAiprofileAgentsDescriptionGmailConnector: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-gmail-connector", fallback: "Your travel details, bookings and updates are already there. Connecting email helps the agent understand and act on them without asking you to find or share everything manually.") }
  /// Introductory blurb for the ITR connector functionality.
  internal static var moAiprofileAgentsDescriptionItrConnector: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-description-itr-connector", fallback: "Your filings confirm income and travel history, so the agent can prefill applications without asking you to dig up documents.") }
  /// Error when disconnecting a connector fails.
  internal static var moAiprofileAgentsErrorDisconnectFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-error-disconnect-failed", fallback: "Couldn't disconnect. Please try again.") }
  /// Shown when the user declines photo library access while connecting the Photos connector.
  internal static var moAiprofileAgentsErrorPhotosAccess: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-error-photos-access", fallback: "Allow photo access in Settings so we can find the countries you've been to.") }
  /// Error under the password when showing it needs a recent sign-in.
  internal static var moAiprofileAgentsErrorVaultConfirmItsYou: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-error-vault-confirm-its-you", fallback: "For your security, sign in to Atlys again, then show the password within 10 minutes.") }
  /// Saved login status when the site needs a one-time code.
  internal static var moAiprofileAgentsErrorVaultOtpUnsupported: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-error-vault-otp-unsupported", fallback: "This site asks for a one-time code. Not supported yet.") }
  /// Error when this device can't show a saved password.
  internal static var moAiprofileAgentsErrorVaultRevealNeedsPhone: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-error-vault-reveal-needs-phone", fallback: "Showing a password needs Face ID on an iPhone.") }
  /// Saved login status when the site couldn't be reached.
  internal static var moAiprofileAgentsErrorVaultSiteUnreachable: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-error-vault-site-unreachable", fallback: "Couldn't reach the site. Try again later.") }
  /// Saved login status when the site rejected the password.
  internal static var moAiprofileAgentsErrorVaultWrongPassword: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-error-vault-wrong-password", fallback: "Wrong username or password. Update it.") }
  /// Hint bubble pointing at the Connected button on App access.
  internal static var moAiprofileAgentsHintConnectedApps: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-hint-connected-apps", fallback: "Find your connected apps here") }
  /// Instructional text on how to remove a connector.
  internal static var moAiprofileAgentsHintDisconnectConnector: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-hint-disconnect-connector", fallback: "Drag icon to disconnect") }
  /// Travel persona radar tip: drag a knob to change its score.
  internal static var moAiprofileAgentsHintPersonaDrag: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-hint-persona-drag", fallback: "Drag the circle to edit values") }
  /// Travel persona radar hint under the chart: drag a knob to edit its score, tap it to see how the score was found.
  internal static var moAiprofileAgentsHintPersonaEdit: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-hint-persona-edit", fallback: "Hold and drag circles to edit. Tap on them to know more") }
  /// Travel persona radar tip: tap a knob to see how its score was calculated.
  internal static var moAiprofileAgentsHintPersonaTap: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-hint-persona-tap", fallback: "Tap to see how score is calculated") }
  /// Label for app integration management settings.
  internal static var moAiprofileAgentsLabelAppAccess: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-app-access", fallback: "App access") }
  /// Leading text for the agent capabilities description.
  internal static var moAiprofileAgentsLabelBuildUnderstanding: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-build-understanding", fallback: "Our agents build an understanding of") }
  /// Settings card title for the secure credential store.
  internal static var moAiprofileAgentsLabelCredentialStore: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-credential-store", fallback: "Secure credential store") }
  /// Label for the email connector option.
  internal static var moAiprofileAgentsLabelEmailConnector: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-email-connector", fallback: "Email") }
  /// Label for settings regarding data sources and permissions.
  internal static var moAiprofileAgentsLabelInformationAccess: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-information-access", fallback: "Information access") }
  /// Credentials form field label for the password.
  internal static var moAiprofileAgentsLabelPassword: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-password", fallback: "Password") }
  /// Travel persona loader: trait label on the processing dial.
  internal static var moAiprofileAgentsLabelPersonaAdventure: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-persona-adventure", fallback: "Adventure") }
  /// Travel persona loader: trait label on the processing dial.
  internal static var moAiprofileAgentsLabelPersonaComfort: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-persona-comfort", fallback: "Comfort") }
  /// Travel persona loader: trait label on the processing dial.
  internal static var moAiprofileAgentsLabelPersonaCultureHistory: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-persona-culture-history", fallback: "Culture & History") }
  /// Travel persona loader: trait label on the processing dial.
  internal static var moAiprofileAgentsLabelPersonaLocal: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-persona-local", fallback: "Local") }
  /// Travel persona loader: trait label on the processing dial.
  internal static var moAiprofileAgentsLabelPersonaNewPlaces: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-persona-new-places", fallback: "New places") }
  /// Travel persona loader: trait label on the processing dial.
  internal static var moAiprofileAgentsLabelPersonaNightlife: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-persona-nightlife", fallback: "Nightlife") }
  /// Travel persona loader: trait label on the processing dial.
  internal static var moAiprofileAgentsLabelPersonaOutdoors: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-persona-outdoors", fallback: "Outdoors") }
  /// Travel persona loader: trait label on the processing dial.
  internal static var moAiprofileAgentsLabelPersonaPace: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-persona-pace", fallback: "Pace") }
  /// Travel persona loader: trait label on the processing dial.
  internal static var moAiprofileAgentsLabelPersonaPlanning: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-persona-planning", fallback: "Planning") }
  /// Travel persona loader: trait label on the processing dial.
  internal static var moAiprofileAgentsLabelPersonaSocial: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-persona-social", fallback: "Social") }
  /// Label for the Photos connector, which reads only where photos were taken.
  internal static var moAiprofileAgentsLabelPhotos: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-photos", fallback: "Photos") }
  /// Label for an agent preference slider setting.
  internal static var moAiprofileAgentsLabelPreferenceSlider: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-preference-slider", fallback: "Preference") }
  /// Call to action text related to agent access.
  internal static var moAiprofileAgentsLabelRegainAccess: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-regain-access", fallback: "Regain access to agents and benefits.") }
  /// Label at the top of the custom rule note card.
  internal static var moAiprofileAgentsLabelRuleNote: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-rule-note", fallback: "Note") }
  /// Credentials form field label for the username or email address.
  internal static var moAiprofileAgentsLabelUsernameEmail: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-username-email", fallback: "Username/Email address") }
  /// Credentials form field label for the website.
  internal static var moAiprofileAgentsLabelWebsite: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-label-website", fallback: "Website") }
  /// Privacy reassurance text for agent data integration.
  internal static var moAiprofileAgentsPrivacyTextSecurity: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-privacy-text-security", fallback: "Data stays secure while your agent learns") }
  /// Face ID prompt reason when showing a saved password.
  internal static var moAiprofileAgentsPromptFaceIdShowPassword: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-prompt-face-id-show-password", fallback: "Show password") }
  /// Face ID prompt reason when opening the credential store.
  internal static var moAiprofileAgentsPromptFaceIdUnlockVault: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-prompt-face-id-unlock-vault", fallback: "Unlock your saved passwords") }
  /// Text explaining security and usage of data for connectors.
  internal static var moAiprofileAgentsSecurityNoteAccess: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-security-note-access", fallback: "Access is securely managed and your data is used only to help the agent work for you.") }
  /// Placeholder or status message for pending app integrations.
  internal static var moAiprofileAgentsStatusAppVaultPending: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-status-app-vault-pending", fallback: "A secure vault for your apps is on its way.") }
  /// Status on an app that connected automatically.
  internal static var moAiprofileAgentsStatusAutoConnected: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-status-auto-connected", fallback: "Auto connected") }
  /// Status label indicating a connector is active.
  internal static var moAiprofileAgentsStatusConnected: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-status-connected", fallback: "Connected") }
  /// Travel persona loader caption under the processing dial.
  internal static var moAiprofileAgentsStatusPersonaProcessing: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-status-persona-processing", fallback: "Decoding your travel choices, won't take long...") }
  /// Privacy reassurance subtitle for travel data.
  internal static var moAiprofileAgentsSubtitleTravelSecurity: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-subtitle-travel-security", fallback: "Your travel data stays secure while your agent learns from the sources you trust.") }
  /// Title of the website picker shown before adding credentials.
  internal static var moAiprofileAgentsTitleAddCredentials: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-title-add-credentials", fallback: "Add credentials") }
  /// Title of the add new password sheet.
  internal static var moAiprofileAgentsTitleAddNewPassword: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-title-add-new-password", fallback: "Add new password") }
  /// Title of the custom rule editor when adding a rule.
  internal static var moAiprofileAgentsTitleAddRule: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-title-add-rule", fallback: "Add a rule") }
  /// Heading for the connector integration management screen.
  internal static var moAiprofileAgentsTitleConnectors: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-title-connectors", fallback: "Connectors") }
  /// Agent form section listing the traveler's custom rules.
  internal static var moAiprofileAgentsTitleCustomRules: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-title-custom-rules", fallback: "Custom rules") }
  /// Title of the custom rule editor when editing a rule.
  internal static var moAiprofileAgentsTitleEditRule: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-title-edit-rule", fallback: "Edit a rule") }
  /// Travel persona loader card title.
  internal static var moAiprofileAgentsTitleTravelerProfile: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-title-traveler-profile", fallback: "Traveler profile") }
  /// Toast after saving edited credentials.
  internal static var moAiprofileAgentsToastCredentialsUpdated: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-toast-credentials-updated", fallback: "Credentials updated") }
  /// Confirmation after a custom rule is saved.
  internal static var moAiprofileAgentsToastCustomRuleSaved: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-toast-custom-rule-saved", fallback: "Custom rule saved") }
  /// Toast after adding a password.
  internal static var moAiprofileAgentsToastPasswordAdded: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-toast-password-added", fallback: "Password added successfully") }
  /// Toast after saving travel persona changes.
  internal static var moAiprofileAgentsToastPersonaUpdated: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-toast-persona-updated", fallback: "Travel persona updated") }
  /// Confirmation message after updating agent preferences.
  internal static var moAiprofileAgentsToastPreferencesUpdated: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-agents-toast-preferences-updated", fallback: "Agent preferences updated") }
  /// Action button to add a traveler to a profile or document.
  internal static var moAiprofileDocumentsButtonAddTraveler: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-button-add-traveler", fallback: "Add traveler") }
  /// Generic upload action button.
  internal static var moAiprofileDocumentsButtonUpload: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-button-upload", fallback: "Upload") }
  /// Action button to initiate uploading a new passport.
  internal static var moAiprofileDocumentsButtonUploadNewPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-button-upload-new-passport", fallback: "Upload new passport") }
  /// Action button to initiate passport upload.
  internal static var moAiprofileDocumentsButtonUploadPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-button-upload-passport", fallback: "Upload passport") }
  /// Display name for the country (India).
  internal static var moAiprofileDocumentsCountryNameIndia: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-country-name-india", fallback: "REPUBLIC OF INDIA") }
  /// Country name in Devanagari on the passport card.
  internal static var moAiprofileDocumentsCountryNameIndiaNative: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-country-name-india-native", fallback: "भारत गणराज्य") }
  /// Title shown when no previous passports are available.
  internal static var moAiprofileDocumentsEmptyStateNoPreviousPassports: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-empty-state-no-previous-passports", fallback: "No previous passports yet") }
  /// Description shown when no previous passports are available.
  internal static var moAiprofileDocumentsEmptyStateNoPreviousPassportsDescription: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-empty-state-no-previous-passports-description", fallback: "Once you replace a passport, the older one shows up here") }
  /// Error when the scanned passport page cannot be read.
  internal static var moAiprofileDocumentsErrorPassportUnreadable: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-error-passport-unreadable", fallback: "We couldn't read this page. Try again in better light.") }
  /// Error when updating the passport fails.
  internal static var moAiprofileDocumentsErrorPassportUpdateFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-error-passport-update-failed", fallback: "Couldn't update your passport. Try again.") }
  /// Error when a passport page upload fails.
  internal static var moAiprofileDocumentsErrorPassportUploadFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-error-passport-upload-failed", fallback: "Couldn't upload that page — please try again.") }
  /// Header for a new passport entry form.
  internal static var moAiprofileDocumentsHeaderNewPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-header-new-passport", fallback: "NEW PASSPORT") }
  /// Section header for passport details.
  internal static var moAiprofileDocumentsHeaderPassportDetails: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-header-passport-details", fallback: "PASSPORT DETAILS") }
  /// Label for the passport expiry date input field.
  internal static var moAiprofileDocumentsInputLabelExpiryDate: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-input-label-expiry-date", fallback: "EXPIRY DATE") }
  /// Label for the passport issue date input field.
  internal static var moAiprofileDocumentsInputLabelIssueDate: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-input-label-issue-date", fallback: "ISSUE DATE") }
  /// Label for the passport number input field.
  internal static var moAiprofileDocumentsInputLabelPassportNumber: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-input-label-passport-number", fallback: "PASSPORT NUMBER") }
  /// Status label for an active passport.
  internal static var moAiprofileDocumentsLabelActive: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-label-active", fallback: "ACTIVE") }
  /// Status label for an expired passport.
  internal static var moAiprofileDocumentsLabelExpired: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-label-expired", fallback: "EXPIRED") }
  /// Label used for displaying a specific travel pass identifier.
  internal static func moAiprofileDocumentsLabelPassNumber(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-label-pass-number", String(describing: p1), fallback: "Pass number %1$@")
  }
  /// Reason option for passport replacement (damaged).
  internal static var moAiprofileDocumentsReasonDamaged: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-reason-damaged", fallback: "Damaged") }
  /// Reason option for passport replacement (lost).
  internal static var moAiprofileDocumentsReasonLostPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-reason-lost-passport", fallback: "Lost my passport") }
  /// Reason option for passport replacement (pages full).
  internal static var moAiprofileDocumentsReasonPagesFull: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-reason-pages-full", fallback: "Pages got over") }
  /// Reason option for passport replacement (expired).
  internal static var moAiprofileDocumentsReasonValidityExpired: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-reason-validity-expired", fallback: "Validity expired") }
  /// Part of a sentence explaining data usage policy (emphasis).
  internal static var moAiprofileDocumentsTextHowUsedEmphasis: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-text-how-used-emphasis", fallback: "used") }
  /// Part of a sentence explaining data usage policy.
  internal static var moAiprofileDocumentsTextHowUsedLead: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-text-how-used-lead", fallback: "How this is") }
  /// Marketing or instructional blurb explaining the benefits of uploading a passport.
  internal static var moAiprofileDocumentsTextUploadBlurbStart: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-documents-text-upload-blurb-start", fallback: "Your details are ready whenever you need a visa. No forms, no re-entering information, no repeating yourself.") }
  /// Accessibility label for the button that hides the password.
  internal static var moAiprofileGeneralAccessibilityHidePassword: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-hide-password", fallback: "Hide password") }
  /// Instructional accessibility hint for collapsing content.
  internal static var moAiprofileGeneralAccessibilityHintCollapse: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-hint-collapse", fallback: "Double tap to collapse") }
  /// Instructional accessibility hint for expanding content.
  internal static var moAiprofileGeneralAccessibilityHintExpand: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-hint-expand", fallback: "Double tap to expand") }
  /// Accessibility label combining a nudge message and its action.
  internal static func moAiprofileGeneralAccessibilityNudge(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-nudge", String(describing: p1), String(describing: p2), fallback: "%1$@. %2$@")
  }
  /// Accessibility label for the button that opens the website.
  internal static var moAiprofileGeneralAccessibilityOpenWebsite: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-open-website", fallback: "Open website") }
  /// Accessibility label for the button that shows the password.
  internal static var moAiprofileGeneralAccessibilityShowPassword: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-show-password", fallback: "Show password") }
  /// Accessibility value of a collapsed expandable card.
  internal static var moAiprofileGeneralAccessibilityValueCollapsed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-value-collapsed", fallback: "Collapsed") }
  /// Accessibility value of an expanded expandable card.
  internal static var moAiprofileGeneralAccessibilityValueExpanded: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-accessibility-value-expanded", fallback: "Expanded") }
  /// Common badge or label for upcoming features.
  internal static var moAiprofileGeneralBadgeComingSoon: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-badge-coming-soon", fallback: "Coming soon") }
  /// Generic activation button.
  internal static var moAiprofileGeneralButtonActivate: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-activate", fallback: "Activate") }
  /// Action button to add a new connection.
  internal static var moAiprofileGeneralButtonAdd: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-add", fallback: "+add") }
  /// Generic add item button.
  internal static var moAiprofileGeneralButtonAdd1: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-add-1", fallback: "+ Add") }
  /// Action button to add an item to a list.
  internal static func moAiprofileGeneralButtonAddItem(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-add-item", String(describing: p1), fallback: "Add one %1$@")
  }
  /// Generic add item button pattern.
  internal static func moAiprofileGeneralButtonAddOption(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-add-option", String(describing: p1), fallback: "+Add %1$@")
  }
  /// Navigation back button.
  internal static var moAiprofileGeneralButtonBack: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-back", fallback: "Back") }
  /// Button to cancel an action and go back.
  internal static var moAiprofileGeneralButtonCancel: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-cancel", fallback: "Cancel") }
  /// Navigation close button.
  internal static var moAiprofileGeneralButtonClose: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-close", fallback: "Close") }
  /// Generic confirm button for edits.
  internal static var moAiprofileGeneralButtonConfirm: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-confirm", fallback: "Confirm edit") }
  /// Action button to establish a connection.
  internal static var moAiprofileGeneralButtonConnect: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-connect", fallback: "Connect") }
  /// Primary action button label.
  internal static var moAiprofileGeneralButtonContinue: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-continue", fallback: "Continue") }
  /// Generic edit button.
  internal static var moAiprofileGeneralButtonEdit: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-edit", fallback: "Edit") }
  /// Generic acknowledgment button for UI modals.
  internal static var moAiprofileGeneralButtonGotIt: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-got-it", fallback: "Got it") }
  /// A call-to-action button instruction for the user.
  internal static var moAiprofileGeneralButtonHoldToExplore: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-hold-to-explore", fallback: "Hold to explore") }
  /// Button to learn more details about a feature or offer.
  internal static var moAiprofileGeneralButtonKnowMore: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-know-more", fallback: "Know more") }
  /// Action button to remove an item from a list.
  internal static func moAiprofileGeneralButtonRemoveItem(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-remove-item", String(describing: p1), fallback: "Remove one %1$@")
  }
  /// Retry action button.
  internal static var moAiprofileGeneralButtonRetry: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-retry", fallback: "Retry") }
  /// Generic search button.
  internal static var moAiprofileGeneralButtonSearch: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-search", fallback: "Search") }
  /// Generic try again action button.
  internal static var moAiprofileGeneralButtonTryAgain: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-try-again", fallback: "Try again") }
  /// Action button to view insights.
  internal static var moAiprofileGeneralButtonViewInsight: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-button-view-insight", fallback: "View insight") }
  /// Standard negation choice.
  internal static var moAiprofileGeneralChoiceNo: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-choice-no", fallback: "No") }
  /// Standard confirmation choice.
  internal static var moAiprofileGeneralChoiceYes: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-choice-yes", fallback: "Yes") }
  /// Counter badge indicating additional items.
  internal static func moAiprofileGeneralCounterPlus(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-counter-plus", String(describing: p1), fallback: "+%1$@")
  }
  /// Formatted distance label in kilometers.
  internal static func moAiprofileGeneralDataDistanceKm(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-data-distance-km", String(describing: p1), fallback: "%1$@ km")
  }
  /// Generic message for empty category view.
  internal static var moAiprofileGeneralEmptyStateCategory: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-empty-state-category", fallback: "Nothing in this category yet") }
  /// Empty state for country search.
  internal static var moAiprofileGeneralEmptyStateCountrySearch: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-empty-state-country-search", fallback: "No countries match that search") }
  /// Shown when a tapped action is not available yet.
  internal static var moAiprofileGeneralErrorActionUnavailable: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-action-unavailable", fallback: "That isn't available yet.") }
  /// Error when a screen fails to load.
  internal static var moAiprofileGeneralErrorLoadFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-load-failed", fallback: "Couldn't load this screen. Check your connection and try again.") }
  /// Generic error description text.
  internal static var moAiprofileGeneralErrorMessageGeneral: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-message-general", fallback: "Something went wrong. Please try again.") }
  /// Error when refreshing the profile fails.
  internal static var moAiprofileGeneralErrorRefreshFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-refresh-failed", fallback: "Couldn't refresh your profile. Try again in a moment.") }
  /// Error when saving changes fails.
  internal static var moAiprofileGeneralErrorSaveFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-save-failed", fallback: "Couldn't save your changes. Try again.") }
  /// Specific error explanation regarding connectivity.
  internal static var moAiprofileGeneralErrorSubtitleInternetIssue: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-subtitle-internet-issue", fallback: "Seems like there was an issue with your internet") }
  /// Error state subtitle when a page fails to load.
  internal static var moAiprofileGeneralErrorSubtitlePageLoadFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-subtitle-page-load-failed", fallback: "We couldn't load this page. Let's give it another shot") }
  /// Error state title when a page fails to load.
  internal static var moAiprofileGeneralErrorTitleQuickHiccup: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-title-quick-hiccup", fallback: "Just a quick hiccup") }
  /// Generic error title.
  internal static var moAiprofileGeneralErrorTitleSomethingWentWrong: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-error-title-something-went-wrong", fallback: "oops something went wrong") }
  /// Bullet prefix for list lines.
  internal static func moAiprofileGeneralFormatBulleted(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-format-bulleted", String(describing: p1), fallback: "•  %1$@")
  }
  /// Placeholder text for text inputs.
  internal static var moAiprofileGeneralInputPlaceholderTypeHere: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-input-placeholder-type-here", fallback: "Type here") }
  /// Count followed by a unit label, e.g. 3 Sources.
  internal static func moAiprofileGeneralLabelCountWithLabel(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-count-with-label", String(describing: p1), String(describing: p2), fallback: "%1$@ %2$@")
  }
  /// Label used in search results indicating items found.
  internal static var moAiprofileGeneralLabelFound: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-found", fallback: "Found") }
  /// KYC status label followed by its detail.
  internal static func moAiprofileGeneralLabelKycStatusLine(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-kyc-status-line", String(describing: p1), String(describing: p2), fallback: "%1$@ %2$@")
  }
  /// KYC progress fraction, e.g. 2/3.
  internal static func moAiprofileGeneralLabelKycStepFraction(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-kyc-step-fraction", String(describing: p1), String(describing: p2), fallback: "%1$@/%2$@")
  }
  /// Label indicating a completed section.
  internal static var moAiprofileGeneralLabelSectionComplete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-section-complete", fallback: "Complete") }
  /// Label indicating a pending section.
  internal static var moAiprofileGeneralLabelSectionPending: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-section-pending", fallback: "Pending") }
  /// Indicates the quantity of data sources available.
  internal static func moAiprofileGeneralLabelSourcesCount(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-sources-count", String(describing: p1), fallback: "%1$@ Sources")
  }
  /// Value followed by its unit, e.g. 20 kg.
  internal static func moAiprofileGeneralLabelUnitValue(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-label-unit-value", String(describing: p1), String(describing: p2), fallback: "%1$@ %2$@")
  }
  /// General loading state label.
  internal static var moAiprofileGeneralLoadingText: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-loading-text", fallback: "Loading") }
  /// Masked number display.
  internal static func moAiprofileGeneralMaskedNumber(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-masked-number", String(describing: p1), fallback: "XXX%1$@")
  }
  /// Dynamic timestamp label for status updates.
  internal static func moAiprofileGeneralMetadataUpdatedDynamic(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-metadata-updated-dynamic", String(describing: p1), fallback: "updated %1$@")
  }
  /// Metadata label for update timestamps.
  internal static func moAiprofileGeneralMetadataUpdatedOn(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-metadata-updated-on", String(describing: p1), fallback: "updated on %1$@")
  }
  /// Header for past trip options by country.
  internal static func moAiprofileGeneralPastTripOptions(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-past-trip-options", String(describing: p1), fallback: "%1$@ trip options")
  }
  /// Instructional text displayed when search results are empty.
  internal static var moAiprofileGeneralSearchEmptySubtitle: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-search-empty-subtitle", fallback: "Please try searching for another option or check for any spelling errors") }
  /// Title of the empty search results state.
  internal static var moAiprofileGeneralSearchEmptyTitle: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-search-empty-title", fallback: "Looks like we couldn't find what you are looking for") }
  /// Status update for vehicle or service reservation.
  internal static func moAiprofileGeneralServiceLockedStatus(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-service-locked-status", String(describing: p1), fallback: "%1$@ locked for your airport pickup")
  }
  /// Status while KYC state is being refreshed.
  internal static var moAiprofileGeneralStatusKycUpdating: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-status-kyc-updating", fallback: "Updating…") }
  /// Shown on a household member pass until the account holder completes KYC.
  internal static func moAiprofileGeneralTextCompleteHolderKycFirst(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-text-complete-holder-kyc-first", String(describing: p1), fallback: "Complete %1$@'s KYC first...")
  }
  /// Display label for a specific trip occurrence.
  internal static func moAiprofileGeneralTripDateLabel(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-trip-date-label", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "%1$@, %2$@ %3$@")
  }
  /// Placeholder text for selection inputs.
  internal static var moAiprofileGeneralUiButtonSelect: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-ui-button-select", fallback: "Select") }
  /// Encouraging status text for completion steps.
  internal static var moAiprofileGeneralUiLabelAlmostThere: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-ui-label-almost-there", fallback: "Almost there!") }
  /// Descriptor for progress in a multi-step flow.
  internal static var moAiprofileGeneralUiLabelStepsDone: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-ui-label-steps-done", fallback: "steps done") }
  /// Wizard progress step indicator.
  internal static func moAiprofileGeneralUiStepIndicator(_ p1: Any, _ p2: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-general-ui-step-indicator", String(describing: p1), String(describing: p2), fallback: "Step %1$@ of %2$@")
  }
  /// Email section badge while forwarding is on.
  internal static var moAiprofileGloveboxBadgeActive: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-badge-active", fallback: "Active") }
  /// Phone number section badge.
  internal static var moAiprofileGloveboxBadgeActiveOnTrip: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-badge-active-on-trip", fallback: "Active on trip") }
  /// Badge on a glove box entry whose booking changed.
  internal static var moAiprofileGloveboxBadgeChanged: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-badge-changed", fallback: "Changed") }
  /// Email section badge while forwarding is paused.
  internal static var moAiprofileGloveboxBadgePaused: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-badge-paused", fallback: "Paused") }
  /// Virtual card section button that adds a card.
  internal static var moAiprofileGloveboxButtonAddCard: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-button-add-card", fallback: "Add card") }
  /// Starts KYC from the locked glove box intro.
  internal static var moAiprofileGloveboxButtonCompleteKyc: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-button-complete-kyc", fallback: "Complete KYC") }
  /// Glove box copy button right after copying.
  internal static var moAiprofileGloveboxButtonCopied: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-button-copied", fallback: "Copied") }
  /// Glove box button that copies the address or number.
  internal static var moAiprofileGloveboxButtonCopy: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-button-copy", fallback: "Copy") }
  /// Button that pauses email forwarding.
  internal static var moAiprofileGloveboxButtonPause: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-button-pause", fallback: "Pause") }
  /// Button that resumes email forwarding.
  internal static var moAiprofileGloveboxButtonResume: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-button-resume", fallback: "Resume") }
  /// Button that sends the forwarding confirmation link.
  internal static var moAiprofileGloveboxButtonSendLink: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-button-send-link", fallback: "Send link") }
  /// Opens the full list of a glove box section.
  internal static var moAiprofileGloveboxButtonViewAll: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-button-view-all", fallback: "View all") }
  /// Glove box intro subtitle.
  internal static var moAiprofileGloveboxDescriptionActivate: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-description-activate", fallback: "A travel email that works for you. Your real one stays private.") }
  /// About text in the glove box email section.
  internal static var moAiprofileGloveboxDescriptionEmailAbout: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-description-email-about", fallback: "Follow up, reply, and coordinate with hotels and airlines. Your real inbox stays private.") }
  /// Virtual card section text under How you pay.
  internal static var moAiprofileGloveboxDescriptionHowYouPay: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-description-how-you-pay", fallback: "When the assistant books or buys for you. Change it anytime.") }
  /// About text in the glove box phone number section.
  internal static var moAiprofileGloveboxDescriptionPhoneAbout: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-description-phone-about", fallback: "Agent answers every call, day or night. It handles the simple ones and puts urgent ones through to you.") }
  /// Settings glove box card description. The line break follows the design.
  internal static var moAiprofileGloveboxDescriptionSettingsCard: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-description-settings-card", fallback: "Built for your agent. Get your\nown email, number and virtual card") }
  /// Glove box intro subtitle while the main traveler's KYC isn't done.
  internal static var moAiprofileGloveboxDescriptionUnlock: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-description-unlock", fallback: "A travel email, number and card that work for you. Your real ones stay private.") }
  /// Virtual card section empty state title.
  internal static var moAiprofileGloveboxEmptyStateNoTransactions: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-empty-state-no-transactions", fallback: "No transactions yet...") }
  /// Virtual card section empty state body.
  internal static var moAiprofileGloveboxEmptyStateNoTransactionsBody: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-empty-state-no-transactions-body", fallback: "Once your agent starts handling your travel, confirmations and updates will land here.") }
  /// Glove box error for a guest session.
  internal static var moAiprofileGloveboxErrorAccountRequired: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-error-account-required", fallback: "Glove box needs an Atlys account.") }
  /// Glove box error when the forwarding confirmation email fails.
  internal static var moAiprofileGloveboxErrorEmailNotSent: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-error-email-not-sent", fallback: "The confirmation email didn't send. Try again.") }
  /// Glove box error when forwarding is already set up.
  internal static var moAiprofileGloveboxErrorForwardingExists: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-error-forwarding-exists", fallback: "Forwarding is already on.") }
  /// Glove box error for an invalid forwarding email.
  internal static var moAiprofileGloveboxErrorInvalidEmail: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-error-invalid-email", fallback: "That email address can't be used.") }
  /// Glove box error when there is no glove box address yet.
  internal static var moAiprofileGloveboxErrorNoAddress: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-error-no-address", fallback: "Set up your Glove box email first.") }
  /// Glove box error when an email can't be found.
  internal static var moAiprofileGloveboxErrorNotFound: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-error-not-found", fallback: "That email isn't available.") }
  /// Glove box error when the user is rate limited.
  internal static var moAiprofileGloveboxErrorRateLimited: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-error-rate-limited", fallback: "Too many tries. Wait and try again.") }
  /// Glove box error when the session has expired.
  internal static var moAiprofileGloveboxErrorSignInAgain: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-error-sign-in-again", fallback: "Sign in again to open Glove box.") }
  /// Glove box error when the screen can't load.
  internal static var moAiprofileGloveboxErrorUnavailable: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-error-unavailable", fallback: "Glove box couldn't be opened.") }
  /// Phone number headline, emphasised middle part, drawn in black.
  internal static var moAiprofileGloveboxHeadlineNewNumberEmphasis: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-headline-new-number-emphasis", fallback: "new number") }
  /// Phone number headline, first part. Joined with a space to the emphasis.
  internal static var moAiprofileGloveboxHeadlineNewNumberLead: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-headline-new-number-lead", fallback: "You get a") }
  /// Phone number headline, last part. Joined with a space after the emphasis.
  internal static var moAiprofileGloveboxHeadlineNewNumberTrail: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-headline-new-number-trail", fallback: "every time you travel") }
  /// Virtual card label for the CVC.
  internal static var moAiprofileGloveboxLabelCardCvc: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-label-card-cvc", fallback: "CVC") }
  /// Virtual card label for the expiry date.
  internal static var moAiprofileGloveboxLabelCardExpires: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-label-card-expires", fallback: "Expires") }
  /// Virtual card label for the card holder's name.
  internal static var moAiprofileGloveboxLabelCardName: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-label-card-name", fallback: "Name") }
  /// Separator and date after a glove box email's status line.
  internal static func moAiprofileGloveboxLabelDated(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-label-dated", String(describing: p1), fallback: "·  %1$@")
  }
  /// Label before the forwarding address. Also the forwarding email field placeholder.
  internal static var moAiprofileGloveboxLabelEmailsForwardedTo: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-label-emails-forwarded-to", fallback: "Emails forwarded to") }
  /// Tag on glove box sample entries shown while there is no real data.
  internal static var moAiprofileGloveboxLabelSample: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-label-sample", fallback: "Sample") }
  /// Settings glove box card subtitle.
  internal static var moAiprofileGloveboxLabelVirtualEmail: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-label-virtual-email", fallback: "Your virtual email") }
  /// Label before a forwarding address that still needs confirming.
  internal static var moAiprofileGloveboxLabelWaitingToConfirm: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-label-waiting-to-confirm", fallback: "Waiting for you to confirm") }
  /// Notice shown when the virtual card is tapped.
  internal static var moAiprofileGloveboxNoticeCardProtected: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-notice-card-protected", fallback: "Card details are protected") }
  /// Virtual card section note under Add card.
  internal static var moAiprofileGloveboxNoticeCardSecure: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-notice-card-secure", fallback: "Your card details are securely stored and used only when needed to manage your bookings.") }
  /// Email section notice when no forwarding email is set.
  internal static var moAiprofileGloveboxNoticeForwardingMissing: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-notice-forwarding-missing", fallback: "Add a forwarding email and new emails will reach your inbox.") }
  /// Email section notice when emails weren't forwarded because forwarding is paused.
  internal static var moAiprofileGloveboxNoticeForwardingPaused: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-notice-forwarding-paused", fallback: "Forwarding is paused, so new emails stay here until you resume it.") }
  /// Email section notice when the forwarding email isn't confirmed yet.
  internal static var moAiprofileGloveboxNoticeForwardingPending: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-notice-forwarding-pending", fallback: "Confirm your forwarding email and new emails will reach your inbox.") }
  /// Agent's note in the sample glove box call.
  internal static var moAiprofileGloveboxSampleCallNote: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-call-note", fallback: "I called the hotel and got you an early check-in at 11 am, so your room is ready when you land.") }
  /// Status line of the sample glove box call.
  internal static var moAiprofileGloveboxSampleCallStatus: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-call-status", fallback: "Calendar updated") }
  /// Summary of the sample glove box call.
  internal static var moAiprofileGloveboxSampleCallSummary: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-call-summary", fallback: "Called Marriott Dubai and got you an early check-in at 11 am") }
  /// Title of the sample glove box call.
  internal static var moAiprofileGloveboxSampleCallTitle: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-call-title", fallback: "Marriott Dubai") }
  /// Agent's note in the first sample glove box email.
  internal static var moAiprofileGloveboxSampleEmailFlightNote: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-email-flight-note", fallback: "I found a better seat at the same price and upgraded you. The seat was available, so I grabbed it before it was gone — no extra cost.") }
  /// Sender of the first sample glove box email.
  internal static var moAiprofileGloveboxSampleEmailFlightSender: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-email-flight-sender", fallback: "Emirates") }
  /// Status line of the first sample glove box email.
  internal static var moAiprofileGloveboxSampleEmailFlightStatus: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-email-flight-status", fallback: "change caught") }
  /// Subject of the first sample glove box email.
  internal static var moAiprofileGloveboxSampleEmailFlightSubject: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-email-flight-subject", fallback: "Your flight on 12 Oct now leaves 40 min later") }
  /// Agent's note in the second sample glove box email.
  internal static var moAiprofileGloveboxSampleEmailHotelNote: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-email-hotel-note", fallback: "Your stay qualifies for a free room upgrade. Want me to accept it?") }
  /// Sender of the second sample glove box email.
  internal static var moAiprofileGloveboxSampleEmailHotelSender: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-email-hotel-sender", fallback: "Marriott Dubai") }
  /// Status line of the second sample glove box email.
  internal static var moAiprofileGloveboxSampleEmailHotelStatus: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-email-hotel-status", fallback: "Added to trip") }
  /// Subject of the second sample glove box email.
  internal static var moAiprofileGloveboxSampleEmailHotelSubject: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-email-hotel-subject", fallback: "Free upgrade available") }
  /// Agent's note on the sample virtual card transaction.
  internal static var moAiprofileGloveboxSampleTransactionNote: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-transaction-note", fallback: "I used your virtual card to hold a table for 4. You'll see every charge here.") }
  /// Outcome of the sample virtual card transaction.
  internal static var moAiprofileGloveboxSampleTransactionStatus: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-transaction-status", fallback: "Approved") }
  /// Summary of the sample virtual card transaction.
  internal static var moAiprofileGloveboxSampleTransactionSummary: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-transaction-summary", fallback: "Card check for table of 4") }
  /// Title of the sample virtual card transaction.
  internal static var moAiprofileGloveboxSampleTransactionTitle: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-sample-transaction-title", fallback: "Dinner at SOHO, New York") }
  /// Email row status: the agent handled it.
  internal static var moAiprofileGloveboxStatusHandledForYou: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-status-handled-for-you", fallback: "Handled for you") }
  /// Email row status: the user was added to the thread.
  internal static var moAiprofileGloveboxStatusInTheThread: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-status-in-the-thread", fallback: "You're in the thread") }
  /// Email row status: forwarded to the user's inbox.
  internal static var moAiprofileGloveboxStatusSentToInbox: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-status-sent-to-inbox", fallback: "Sent to your inbox") }
  /// Email row status: the email went to a previous glove box address.
  internal static var moAiprofileGloveboxStatusSentToOldAddress: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-status-sent-to-old-address", fallback: "Sent to an old address") }
  /// Glove box intro title while it warms up.
  internal static var moAiprofileGloveboxTitleActivate: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-title-activate", fallback: "Activate your Glove box") }
  /// Title of the glove box calls list sheet.
  internal static var moAiprofileGloveboxTitleCallsList: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-title-calls-list", fallback: "Glove box  ·  Calls") }
  /// Title of the glove box email section.
  internal static var moAiprofileGloveboxTitleEmail: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-title-email", fallback: "Email") }
  /// Title of the glove box email list sheet.
  internal static var moAiprofileGloveboxTitleEmailList: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-title-email-list", fallback: "Glove box  ·  Email") }
  /// Glove box screen title.
  internal static var moAiprofileGloveboxTitleGloveBox: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-title-glove-box", fallback: "Glove box") }
  /// Virtual card section heading for the payment options.
  internal static var moAiprofileGloveboxTitleHowYouPay: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-title-how-you-pay", fallback: "How you pay") }
  /// Title of the glove box phone number section.
  internal static var moAiprofileGloveboxTitlePhoneNumber: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-title-phone-number", fallback: "Phone number") }
  /// Title of the glove box transactions list sheet.
  internal static var moAiprofileGloveboxTitleTransactionsList: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-title-transactions-list", fallback: "Glove box  ·  Transactions") }
  /// Glove box intro title while the main traveler's KYC isn't done.
  internal static var moAiprofileGloveboxTitleUnlock: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-title-unlock", fallback: "Your Glove box is ready to unlock") }
  /// Title of the glove box virtual card section.
  internal static var moAiprofileGloveboxTitleVirtualCard: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-glovebox-title-virtual-card", fallback: "Virtual card") }
  /// Action button to add airlines to loyalty programs.
  internal static var moAiprofileLoyaltyButtonAddAirlines: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-add-airlines", fallback: "+Add preferred airlines") }
  /// Button to add a new loyalty program.
  internal static var moAiprofileLoyaltyButtonAddProgram: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-add-program", fallback: "Add program") }
  /// Button to confirm deleting the selected loyalty programs.
  internal static var moAiprofileLoyaltyButtonConfirmDelete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-confirm-delete", fallback: "Confirm") }
  /// Call to action to connect additional loyalty programs.
  internal static var moAiprofileLoyaltyButtonConnectMorePrograms: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-connect-more-programs", fallback: "Connect more programs") }
  /// Action button to copy membership information to the clipboard.
  internal static var moAiprofileLoyaltyButtonCopyMembershipNumber: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-copy-membership-number", fallback: "Copy membership number") }
  /// Edit-mode button to delete the selected loyalty programs, singular.
  internal static func moAiprofileLoyaltyButtonDeleteProgramsOne(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-delete-programs-one", String(describing: p1), fallback: "Delete %1$@ program")
  }
  /// Edit-mode button to delete the selected loyalty programs, plural.
  internal static func moAiprofileLoyaltyButtonDeleteProgramsOther(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-delete-programs-other", String(describing: p1), fallback: "Delete %1$@ programs")
  }
  /// Button to exit edit mode.
  internal static var moAiprofileLoyaltyButtonDoneEditing: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-done-editing", fallback: "Done editing") }
  /// Action button to edit connected programs.
  internal static var moAiprofileLoyaltyButtonEditPrograms: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-edit-programs", fallback: "Edit programs") }
  /// Action button for flipping a loyalty card.
  internal static var moAiprofileLoyaltyButtonFlipCard: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-flip-card", fallback: "Flip card") }
  /// Action to redeem rewards or points.
  internal static var moAiprofileLoyaltyButtonRedeem: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-redeem", fallback: "Redeem") }
  /// Action button to remove a program from the list.
  internal static var moAiprofileLoyaltyButtonRemoveProgram: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-remove-program", fallback: "Remove") }
  /// Action button to expand view of loyalty benefits.
  internal static var moAiprofileLoyaltyButtonViewBenefits: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-view-benefits", fallback: "View all benefits") }
  /// Action button to view all benefits available for a loyalty tier.
  internal static func moAiprofileLoyaltyButtonViewBenefits1(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-view-benefits-1", String(describing: p1), fallback: "View all %1$@ benefits")
  }
  /// Button label to view sources.
  internal static var moAiprofileLoyaltyButtonViewSources: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-button-view-sources", fallback: "View sources") }
  /// Category filter label for all programs.
  internal static var moAiprofileLoyaltyCategoryLabelAll: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-category-label-all", fallback: "All") }
  /// Category filter label for credit cards.
  internal static var moAiprofileLoyaltyCategoryLabelCreditCards: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-category-label-credit-cards", fallback: "Credit cards") }
  /// Category filter label for hotels.
  internal static var moAiprofileLoyaltyCategoryLabelHotels: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-category-label-hotels", fallback: "Hotels") }
  /// Category filter label for travel passes.
  internal static var moAiprofileLoyaltyCategoryLabelTravelPasses: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-category-label-travel-passes", fallback: "Travel passes") }
  /// Confirmation before deleting the selected loyalty programs, singular.
  internal static func moAiprofileLoyaltyConfirmationDeleteProgramsOne(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-confirmation-delete-programs-one", String(describing: p1), fallback: "Are you sure you want to delete\n%1$@ program")
  }
  /// Confirmation before deleting the selected loyalty programs, plural.
  internal static func moAiprofileLoyaltyConfirmationDeleteProgramsOther(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-confirmation-delete-programs-other", String(describing: p1), fallback: "Are you sure you want to delete\n%1$@ programs")
  }
  /// Usage display for rewards or coupons.
  internal static func moAiprofileLoyaltyCouponUsedAmount(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-coupon-used-amount", String(describing: p1), fallback: "%1$@ used")
  }
  /// Empty state when the coupons list has no coupons.
  internal static var moAiprofileLoyaltyEmptyStateNoCoupons: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-empty-state-no-coupons", fallback: "No coupons available.") }
  /// Title for no connected programs state.
  internal static var moAiprofileLoyaltyEmptyStateNoProgramsConnected: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-empty-state-no-programs-connected", fallback: "No programs connected yet") }
  /// Body text for no connected programs state.
  internal static var moAiprofileLoyaltyEmptyStateNoProgramsConnectedBody: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-empty-state-no-programs-connected-body", fallback: "Add a program to track points, tiers and expiry in one place.") }
  /// Title for empty program results.
  internal static var moAiprofileLoyaltyEmptyStateNoProgramsFound: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-empty-state-no-programs-found", fallback: "No programs found") }
  /// Error when adding a loyalty program fails.
  internal static var moAiprofileLoyaltyErrorAddProgramFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-add-program-failed", fallback: "Couldn't add this program. Try again.") }
  /// Error message requiring KYC verification for benefit activation.
  internal static var moAiprofileLoyaltyErrorBenefitKycRequired: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-benefit-kyc-required", fallback: "A quick verification is needed before this benefit can be activated.") }
  /// Error when a program insight fails to load.
  internal static var moAiprofileLoyaltyErrorInsightFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-insight-failed", fallback: "Couldn't load this insight. Try again.") }
  /// Message indicating KYC is required to add a program.
  internal static var moAiprofileLoyaltyErrorKycRequired: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-kyc-required", fallback: "A quick verification is needed before you can add a program.") }
  /// Message displayed when search yields no results.
  internal static var moAiprofileLoyaltyErrorNoMatches: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-no-matches", fallback: "No programs match that search") }
  /// Error when switching to another traveler's World Pass fails.
  internal static var moAiprofileLoyaltyErrorPassSwitchFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-pass-switch-failed", fallback: "Couldn't load this World Pass. Showing the previous traveler.") }
  /// Error when redeeming a benefit fails.
  internal static var moAiprofileLoyaltyErrorRedeemFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-redeem-failed", fallback: "Couldn't redeem this benefit. Try again.") }
  /// Error when removing a loyalty program fails.
  internal static var moAiprofileLoyaltyErrorRemoveProgramFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-remove-program-failed", fallback: "Couldn't remove this program. Try again.") }
  /// Error when saving the new program order fails.
  internal static var moAiprofileLoyaltyErrorReorderFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-error-reorder-failed", fallback: "Couldn't save the new order. Try again.") }
  /// Scanning progress line, singular.
  internal static func moAiprofileLoyaltyFoundProgramsLineOne(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-found-programs-line-one", String(describing: p1), fallback: "Found %1$@ program...")
  }
  /// Scanning progress line, plural.
  internal static func moAiprofileLoyaltyFoundProgramsLineOther(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-found-programs-line-other", String(describing: p1), fallback: "Found %1$@ programs...")
  }
  /// Found programs count, singular.
  internal static func moAiprofileLoyaltyFoundProgramsOne(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-found-programs-one", String(describing: p1), fallback: "%1$@ program")
  }
  /// Found programs count, plural.
  internal static func moAiprofileLoyaltyFoundProgramsOther(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-found-programs-other", String(describing: p1), fallback: "%1$@ programs")
  }
  /// Instructional hint for interacting with a card.
  internal static var moAiprofileLoyaltyHintCardInteraction: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-hint-card-interaction", fallback: "Double tap to flip. Use Explore World Pass to open the globe.") }
  /// Form field label for membership number.
  internal static var moAiprofileLoyaltyInputLabelMembershipNumber: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-input-label-membership-number", fallback: "Membership number*") }
  /// Instruction for interacting with a card component.
  internal static var moAiprofileLoyaltyInstructionFlipCard: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-instruction-flip-card", fallback: "Tap to flip the card") }
  /// Instructional text for reordering items.
  internal static var moAiprofileLoyaltyInstructionReorderCards: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-instruction-reorder-cards", fallback: "Hold and drag cards to rearrange") }
  /// Emphasized description of program types that can be connected.
  internal static var moAiprofileLoyaltyLabelConnectProgramsEmphasis: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-connect-programs-emphasis", fallback: "airline and hotel programs, credit card rewards and travel passes") }
  /// Leading text for the connect programs feature.
  internal static var moAiprofileLoyaltyLabelConnectProgramsLead: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-connect-programs-lead", fallback: "Connect your") }
  /// Label for estimated monetary value of points.
  internal static var moAiprofileLoyaltyLabelEstimatedValue: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-estimated-value", fallback: "Est. value") }
  /// Header label to select a loyalty program.
  internal static var moAiprofileLoyaltyLabelPickProgram: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-pick-program", fallback: "Pick a loyalty program") }
  /// Label for points tracking in loyalty programs.
  internal static var moAiprofileLoyaltyLabelPoints: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-points", fallback: "points") }
  /// Label representing points or miles.
  internal static var moAiprofileLoyaltyLabelPointsMiles: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-points-miles", fallback: "Points/miles") }
  /// Status label for connected loyalty programs.
  internal static var moAiprofileLoyaltyLabelProgramsConnected: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-programs-connected", fallback: "programs connected") }
  /// Label referring to data sources.
  internal static var moAiprofileLoyaltyLabelSources: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-label-sources", fallback: "Sources") }
  /// Summary of scanned content from connected programs.
  internal static func moAiprofileLoyaltyProgramSummary(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-program-summary", String(describing: p1), fallback: "Read %1$@ statements, inboxes and checked upcoming trips...")
  }
  /// Label for the coupons section in the app.
  internal static var moAiprofileLoyaltyProgramsLabelCoupons: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-programs-label-coupons", fallback: "Coupons") }
  /// Status label indicating a coupon has been used.
  internal static var moAiprofileLoyaltyProgramsLabelRedeemed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-programs-label-redeemed", fallback: "Redeemed") }
  /// Header title for the loyalty programs section.
  internal static var moAiprofileLoyaltyProgramsLabelTitle: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-programs-label-title", fallback: "Loyalty Programs") }
  /// Second part of a scanning status message.
  internal static var moAiprofileLoyaltyScanningStatusEmphasis: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-scanning-status-emphasis", fallback: "travel benefits together.") }
  /// Loading state during email scanning.
  internal static var moAiprofileLoyaltyScanningStatusGoingThroughEmails: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-scanning-status-going-through-emails", fallback: "Going through emails...") }
  /// First part of a scanning status message.
  internal static var moAiprofileLoyaltyScanningStatusLead: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-scanning-status-lead", fallback: "bringing all your") }
  /// Timestamp indicating a recent redemption.
  internal static var moAiprofileLoyaltyStatusRedeemedJustNow: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-status-redeemed-just-now", fallback: "Redeemed just now") }
  /// Descriptive text for flight cashback offers within loyalty benefits.
  internal static var moAiprofileLoyaltyTextCashbackOfferLead: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-text-cashback-offer-lead", fallback: "Enjoy 5%% off on eligible flight bookings. The offer may apply only to selected airlines, routes, travel dates or fare types and is subject to availability. Additional terms, exclusions and booking conditions may apply.") }
  /// Header title for connected programs list.
  internal static var moAiprofileLoyaltyTitleConnectedPrograms: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-title-connected-programs", fallback: "Connected programs") }
  /// Label for exploring World Pass features.
  internal static var moAiprofileLoyaltyTitleExploreWorldPass: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-title-explore-world-pass", fallback: "Explore World Pass") }
  /// Confirmation message after copying membership number.
  internal static var moAiprofileLoyaltyToastMembershipNumberCopied: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-loyalty-toast-membership-number-copied", fallback: "Membership number copied") }
  /// Accessibility label for the visited countries stat.
  internal static func moAiprofileProfileAccessibilityVisitedCountries(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-accessibility-visited-countries", String(describing: p1), fallback: "Visited countries, %1$@. Add past trips")
  }
  /// Button for adding a single past travel trip.
  internal static var moAiprofileProfileButtonAddPastTrip: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-button-add-past-trip", fallback: "Add past trip") }
  /// Button for adding past travel trips in the user profile.
  internal static var moAiprofileProfileButtonAddPastTrips: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-button-add-past-trips", fallback: "Add past trips") }
  /// Cancel action on the delete past trip / delete account confirmations.
  internal static var moAiprofileProfileButtonDontDelete: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-button-dont-delete", fallback: "Don't delete") }
  /// Button to save user changes.
  internal static var moAiprofileProfileButtonSaveChanges: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-button-save-changes", fallback: "save changes") }
  /// Empty state title when no past trips exist.
  internal static var moAiprofileProfileEmptyStateNoTrips: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-empty-state-no-trips", fallback: "No past trips yet") }
  /// Body text of the empty past trips state.
  internal static var moAiprofileProfileEmptyStateNoTripsBody: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-empty-state-no-trips-body", fallback: "Add the countries you've visited to build your travel map.") }
  /// Error when deleting a past trip fails.
  internal static var moAiprofileProfileErrorPastTripDeleteFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-error-past-trip-delete-failed", fallback: "Couldn't delete this trip. Please try again.") }
  /// Error when the same past trip is added twice.
  internal static var moAiprofileProfileErrorPastTripDuplicate: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-error-past-trip-duplicate", fallback: "You've already added this trip") }
  /// Error when saving a past trip fails.
  internal static var moAiprofileProfileErrorPastTripSaveFailed: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-error-past-trip-save-failed", fallback: "Couldn't save this trip. Please try again.") }
  /// Label for a month selection field.
  internal static var moAiprofileProfileInputLabelMonth: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-input-label-month", fallback: "Month") }
  /// Option for declining to provide information.
  internal static var moAiprofileProfileOptionRatherNotSay: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-option-rather-not-say", fallback: "Rather not say") }
  /// Label for airlines statistic in the profile.
  internal static var moAiprofileProfileStatLabelAirlines: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-stat-label-airlines", fallback: "Airlines") }
  /// Label for airports statistic in the profile.
  internal static var moAiprofileProfileStatLabelAirports: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-stat-label-airports", fallback: "Airports") }
  /// Label for countries statistic in the profile.
  internal static var moAiprofileProfileStatLabelCountries: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-stat-label-countries", fallback: "Countries") }
  /// Label for distance statistic in the profile.
  internal static var moAiprofileProfileStatLabelDistance: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-stat-label-distance", fallback: "Distance") }
  /// Label for flights statistic in the profile.
  internal static var moAiprofileProfileStatLabelFlights: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-profile-stat-label-flights", fallback: "Flights") }
  /// Informational body text shown during the account disconnection process.
  internal static var moAiprofileSettingsBodyDisconnectProgress: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-body-disconnect-progress", fallback: "Removing synced data and access from your agents, this may take a while…") }
  /// Action button for disconnecting an email account.
  internal static var moAiprofileSettingsButtonDisconnectEmail: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-button-disconnect-email", fallback: "Disconnect email") }
  /// Button text to cancel a pending account disconnection.
  internal static var moAiprofileSettingsButtonStopDisconnecting: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-button-stop-disconnecting", fallback: "Stop disconnecting") }
  /// Label for the user profile contact information section.
  internal static var moAiprofileSettingsLabelContactInfo: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-label-contact-info", fallback: "Contact info") }
  /// Label for the user currency preference setting.
  internal static var moAiprofileSettingsLabelCurrency: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-label-currency", fallback: "Currency") }
  /// Display format for phone country codes in user settings.
  internal static func moAiprofileSettingsLabelDialCode(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-label-dial-code", String(describing: p1), fallback: "+%1$@")
  }
  /// Shows the count of configured user preferences.
  internal static func moAiprofileSettingsLabelPreferencesCount(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-label-preferences-count", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "%1$@/%2$@ %3$@ preferences")
  }
  /// Used to denote a required field in a form.
  internal static func moAiprofileSettingsLabelRequiredField(_ p1: Any) -> String {
    return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-label-required-field", String(describing: p1), fallback: "%1$@*")
  }
  /// Header for list of affected data types.
  internal static var moAiprofileSettingsListHeader: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-list-header", fallback: "This may include, where applicable:") }
  /// Title while an email connector is being disconnected.
  internal static var moAiprofileSettingsTitleDisconnectProgress: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-settings-title-disconnect-progress", fallback: "Disconnecting your account…") }
  /// Input label for blood group field.
  internal static var moAiprofileTravelDocsInputLabelBloodGroup: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-docs-input-label-blood-group", fallback: "Blood group") }
  /// Input label for date of birth field.
  internal static var moAiprofileTravelDocsInputLabelDob: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-docs-input-label-dob", fallback: "D.O.B") }
  /// Input label for emergency contact information.
  internal static var moAiprofileTravelDocsInputLabelEmergencyContact: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-docs-input-label-emergency-contact", fallback: "Emergency contact") }
  /// Input label for organ donor status.
  internal static var moAiprofileTravelDocsInputLabelOrganDonor: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-docs-input-label-organ-donor", fallback: "Organ donor") }
  /// Validation error shown when a passport is already registered to another traveler.
  internal static var moAiprofileTravelDocumentsErrorDuplicatePassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-documents-error-duplicate-passport", fallback: "This passport number is already added to another traveler.") }
  /// Specific error message for invalid Indian passport format.
  internal static var moAiprofileTravelErrorInvalidIndianPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-error-invalid-indian-passport", fallback: "Enter a valid Indian passport number, like A1234567") }
  /// Error message when passport input is invalid.
  internal static var moAiprofileTravelErrorInvalidPassport: String { return ProfileV3L10n.tr("ProfileV3Localizable", "mo-aiprofile-travel-error-invalid-passport", fallback: "Enter a valid passport number") }
}
// swiftlint:enable function_parameter_count identifier_name line_length type_body_length

// MARK: - Implementation Details

extension ProfileV3L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = ProfileV3DittoRuntimeStrings.lookup(key, table, value)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
