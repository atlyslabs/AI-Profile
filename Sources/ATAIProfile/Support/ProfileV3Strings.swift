import Foundation

enum ProfileV3Strings {
    static var activate: String { ProfileV3L10n.moAiprofileGeneralButtonActivate }
    static var addChip: String { ProfileV3L10n.moAiprofileGeneralButtonAdd1 }
    static func addOption(_ label: String) -> String { ProfileV3L10n.moAiprofileGeneralButtonAddOption(label.lowercased()) }
    static func maskedNumber(_ lastDigits: String) -> String { ProfileV3L10n.moAiprofileGeneralMaskedNumber(lastDigits) }
    static var settings: String { ProfileV3L10n.moAiprofileAccountHeaderSettings }
    static var permissions: String { ProfileV3L10n.moAiprofileAccountHeaderPermissions }
    static var addPastTrips: String { ProfileV3L10n.moAiprofileProfileButtonAddPastTrips }
    static var addPastTrip: String { ProfileV3L10n.moAiprofileProfileButtonAddPastTrip }
    static var tripMonth: String { ProfileV3L10n.moAiprofileProfileInputLabelMonth }
    static var pastTripDuplicate: String { ProfileV3L10n.moAiprofileProfileErrorPastTripDuplicate }
    static var pastTripSaveFailed: String { ProfileV3L10n.moAiprofileProfileErrorPastTripSaveFailed }
    static var pastTripDeleteFailed: String { ProfileV3L10n.moAiprofileProfileErrorPastTripDeleteFailed }
    static var noPastTripsTitle: String { ProfileV3L10n.moAiprofileProfileEmptyStateNoTrips }
    static var noPastTripsBody: String { ProfileV3L10n.moAiprofileProfileEmptyStateNoTripsBody }
    static let statPlaceholder = "--"
    static var statFlights: String { ProfileV3L10n.moAiprofileProfileStatLabelFlights }
    static var statDistance: String { ProfileV3L10n.moAiprofileProfileStatLabelDistance }
    static var statCountries: String { ProfileV3L10n.moAiprofileProfileStatLabelCountries }
    static var statAirports: String { ProfileV3L10n.moAiprofileProfileStatLabelAirports }
    static var statAirlines: String { ProfileV3L10n.moAiprofileProfileStatLabelAirlines }
    static func visitedCountries(_ count: Int) -> String { ProfileV3L10n.moAiprofileProfileAccessibilityVisitedCountries(count) }
    static func pastTripOptions(_ country: String) -> String { ProfileV3L10n.moAiprofileGeneralPastTripOptions(country) }
    static func pastTripLabel(country: String, month: String, year: Int) -> String { ProfileV3L10n.moAiprofileGeneralTripDateLabel(country, month, year) }
    static var connectorDefaults: String { ProfileV3L10n.moAiprofileAgentSettingsConnectorDefaults }
    static var webAccessDefaults: String { ProfileV3L10n.moAiprofileAgentSettingsWebAccessDefaults }
    static var askForSomeActions: String { ProfileV3L10n.moAiprofileAgentSettingsAskForActions }
    static var askForSomeActionsDetail: String { ProfileV3L10n.moAiprofileAgentSettingsPermissionDescription }
    static var alwaysAsk: String { ProfileV3L10n.moAiprofileAgentSettingsAlwaysAsk }
    static var alwaysAskDetail: String { ProfileV3L10n.moAiprofileAgentSettingsBeforeActionDescription }
    static var back: String { ProfileV3L10n.moAiprofileGeneralButtonBack }
    static var close: String { ProfileV3L10n.moAiprofileGeneralButtonClose }
    static var search: String { ProfileV3L10n.moAiprofileGeneralButtonSearch }
    static var ratherNotSay: String { ProfileV3L10n.moAiprofileProfileOptionRatherNotSay }
    static var saveChanges: String { ProfileV3L10n.moAiprofileProfileButtonSaveChanges }
    static var countryOfResidence: String { ProfileV3L10n.moAiprofileAccountSettingsLabelCountryOfResidence }
    static var citizenship: String { ProfileV3L10n.moAiprofileAccountSettingsLabelCitizenship }
    static var citizenshipFromPassport: String { ProfileV3L10n.moAiprofileAccountSettingsLabelCitizenshipFromPassport }
    static var editTraveller: String { ProfileV3L10n.moAiprofileAccountSettingsButtonEditTraveller }
    static var editTravellers: String { ProfileV3L10n.moAiprofileAccountSettingsButtonEditTravellers }
    static var addTravellerPill: String { ProfileV3L10n.moAiprofileAccountSettingsButtonAddTraveller }
    static var householdTitle: String { ProfileV3L10n.moAiprofileAccountSettingsLabelBuildHousehold }
    static var householdSubtitle: String { ProfileV3L10n.moAiprofileAccountSettingsLabelHouseholdSubtitle }
    static var travellerFallbackName: String { ProfileV3L10n.moAiprofileAccountSettingsLabelDefaultName }
    static var firstNameLabel: String { ProfileV3L10n.moAiprofileAccountSettingsInputFirstName }
    static var lastNameLabel: String { ProfileV3L10n.moAiprofileAccountSettingsInputLastName }
    static var firstNamePlaceholder: String { ProfileV3L10n.moAiprofileAccountSettingsPlaceholderFirstName }
    static var lastNamePlaceholder: String { ProfileV3L10n.moAiprofileAccountSettingsPlaceholderLastName }
    static var removeTraveller: String { ProfileV3L10n.moAiprofileAccountSettingsButtonRemoveTraveller }
    static func travellerDeleted(_ name: String) -> String { ProfileV3L10n.moAiprofileAccountSuccessDeletedTraveller(name) }
    static func travellerAdded(_ name: String) -> String { ProfileV3L10n.moAiprofileAccountSuccessAddedTraveller(name) }
    static var travellerDeleteFailed: String { ProfileV3L10n.moAiprofileAccountErrorTravellerDeleteFailed }
    static var travellerAddFailed: String { ProfileV3L10n.moAiprofileAccountErrorTravellerAddFailed }
    static var passportInUse: String { ProfileV3L10n.moAiprofileTravelDocumentsErrorDuplicatePassport }
    static var selectPlaceholder: String { ProfileV3L10n.moAiprofileGeneralUiButtonSelect }
    static var coupons: String { ProfileV3L10n.moAiprofileLoyaltyProgramsLabelCoupons }
    static var noCoupons: String { ProfileV3L10n.moAiprofileLoyaltyEmptyStateNoCoupons }
    static var gloveBoxCopy: String { ProfileV3L10n.moAiprofileGloveboxButtonCopy }
    static var gloveBoxCopied: String { ProfileV3L10n.moAiprofileGloveboxButtonCopied }
    static func gloveBoxDated(_ date: String) -> String { ProfileV3L10n.moAiprofileGloveboxLabelDated(date) }
    static func couponUsed(_ amount: String) -> String { ProfileV3L10n.moAiprofileLoyaltyCouponUsedAmount(amount) }
    static var loyaltyProgrammes: String { ProfileV3L10n.moAiprofileLoyaltyProgramsLabelTitle }
    static var termsOfService: String { ProfileV3L10n.moAiprofileAccountSettingsLabelTermsOfService }
    static var logout: String { ProfileV3L10n.moAiprofileAccountSettingsButtonLogout }
    static var redeemed: String { ProfileV3L10n.moAiprofileLoyaltyProgramsLabelRedeemed }
    static var agentsHeadingLead: String { ProfileV3L10n.moAiprofileAgentsLabelBuildUnderstanding + " " }
    static var kycRegainAccess: String { ProfileV3L10n.moAiprofileAgentsLabelRegainAccess }
    static var kycAlmostThere: String { ProfileV3L10n.moAiprofileGeneralUiLabelAlmostThere }
    static var kycStepsDone: String { " " + ProfileV3L10n.moAiprofileGeneralUiLabelStepsDone }
    static func kycStepFraction(done: Int, total: Int) -> String { ProfileV3L10n.moAiprofileGeneralLabelKycStepFraction(done, total) }
    static var holdToExplore: String { ProfileV3L10n.moAiprofileGeneralButtonHoldToExplore }
    static var flights: String { ProfileV3L10n.moAiprofileProfileStatLabelFlights }
    static var distance: String { ProfileV3L10n.moAiprofileProfileStatLabelDistance }
    static var countries: String { ProfileV3L10n.moAiprofileProfileStatLabelCountries }
    static var airports: String { ProfileV3L10n.moAiprofileProfileStatLabelAirports }
    static var airlines: String { ProfileV3L10n.moAiprofileProfileStatLabelAirlines }
    static var addTraveller: String { ProfileV3L10n.moAiprofileDocumentsButtonAddTraveller }
    static var redeem: String { ProfileV3L10n.moAiprofileLoyaltyButtonRedeem }
    static var flightCashbackTerms: String { ProfileV3L10n.moAiprofileLoyaltyTextCashbackOfferLead }
    static var programmesConnected: String { ProfileV3L10n.moAiprofileLoyaltyLabelProgramsConnected }
    static var knowMore: String { ProfileV3L10n.moAiprofileGeneralButtonKnowMore }
    static var addProgramme: String { ProfileV3L10n.moAiprofileLoyaltyButtonAddProgram }
    static var points: String { ProfileV3L10n.moAiprofileLoyaltyLabelPoints }
    static var pointsMiles: String { ProfileV3L10n.moAiprofileLoyaltyLabelPointsMiles }
    static var estimatedValue: String { ProfileV3L10n.moAiprofileLoyaltyLabelEstimatedValue }
    static var connectMoreProgrammes: String { ProfileV3L10n.moAiprofileLoyaltyButtonConnectMorePrograms }
    static var editProgrammes: String { ProfileV3L10n.moAiprofileLoyaltyButtonEditPrograms }
    static var doneEditing: String { ProfileV3L10n.moAiprofileLoyaltyButtonDoneEditing }
    static var removeProgramme: String { ProfileV3L10n.moAiprofileLoyaltyButtonRemoveProgram }
    static var copyMembershipNumber: String { ProfileV3L10n.moAiprofileLoyaltyButtonCopyMembershipNumber }
    static var membershipNumberCopied: String { ProfileV3L10n.moAiprofileLoyaltyToastMembershipNumberCopied }
    static var reorderProgrammesHint: String { ProfileV3L10n.moAiprofileLoyaltyInstructionReorderCards }
    static var programmeTileHint: String { ProfileV3L10n.moAiprofileLoyaltyInstructionFlipCard }
    static var programmesTitle: String { ProfileV3L10n.moAiprofileLoyaltyTitleConnectedPrograms }
    static func programmesSummary(statements: Int) -> String { ProfileV3L10n.moAiprofileLoyaltyProgramSummary(statements) }
    static var connectProgrammesLead: String { ProfileV3L10n.moAiprofileLoyaltyLabelConnectProgramsLead + " " }
    static var connectProgrammesEmphasis: String { ProfileV3L10n.moAiprofileLoyaltyLabelConnectProgramsEmphasis }
    static var found: String { ProfileV3L10n.moAiprofileGeneralLabelFound + " " }
    static var agentPreferencesUpdated: String { ProfileV3L10n.moAiprofileAgentsToastPreferencesUpdated }
    static var preferenceSlider: String { ProfileV3L10n.moAiprofileAgentsLabelPreferenceSlider }
    static var searchEmptyTitle: String { ProfileV3L10n.moAiprofileGeneralSearchEmptyTitle }
    static var searchEmptySubtitle: String { ProfileV3L10n.moAiprofileGeneralSearchEmptySubtitle }
    static var stagingAirportPickup: String { ProfileV3L10n.moAiprofileAccountSettingsStatusStagingPickup }
    static var selectMyCar: String { ProfileV3L10n.moAiprofileAccountSettingsButtonSelectCar }
    static var rideStaged: String { ProfileV3L10n.moAiprofileAccountSettingsStatusRideStaged }
    static func carLocked(_ name: String) -> String { ProfileV3L10n.moAiprofileGeneralServiceLockedStatus(name) }
    static var dateOfBirth: String { ProfileV3L10n.moAiprofileTravelDocsInputLabelDob }
    static var bloodGroup: String { ProfileV3L10n.moAiprofileTravelDocsInputLabelBloodGroup }
    static var emergencyContact: String { ProfileV3L10n.moAiprofileTravelDocsInputLabelEmergencyContact }
    static var organDonor: String { ProfileV3L10n.moAiprofileTravelDocsInputLabelOrganDonor }
    static var yes: String { ProfileV3L10n.moAiprofileGeneralChoiceYes }
    static var no: String { ProfileV3L10n.moAiprofileGeneralChoiceNo }
    static let medicalEmptyValue = "--"
    static var loading: String { ProfileV3L10n.moAiprofileGeneralLoadingText }
    static var loadingAgent: String { ProfileV3L10n.moAiprofileAccountSettingsLoadingPreferences }
    static var refreshFailed: String { ProfileV3L10n.moAiprofileGeneralErrorRefreshFailed }
    static var passSwitchFailed: String { ProfileV3L10n.moAiprofileLoyaltyErrorPassSwitchFailed }
    static var removeProgrammeFailed: String { ProfileV3L10n.moAiprofileLoyaltyErrorRemoveProgramFailed }
    static var reorderProgrammesFailed: String { ProfileV3L10n.moAiprofileLoyaltyErrorReorderFailed }
    static var viewInsight: String { ProfileV3L10n.moAiprofileGeneralButtonViewInsight }
    static var insightFailed: String { ProfileV3L10n.moAiprofileLoyaltyErrorInsightFailed }
    static var addPreferredAirlines: String { ProfileV3L10n.moAiprofileLoyaltyButtonAddAirlines }
    static func heightFeet(_ feet: Int) -> String { ProfileV3L10n.moAiprofileAccountMeasurementHeightFeet(feet) }
    static func heightFeetInches(_ feet: Int, _ inches: Int) -> String { ProfileV3L10n.moAiprofileAccountMeasurementHeightFeetInches(feet, inches) }
    static func heightCentimetres(_ centimetres: Int) -> String { ProfileV3L10n.moAiprofileAccountMeasurementHeightCm(centimetres) }
    static func stepIndicator(current: Int, total: Int) -> String { ProfileV3L10n.moAiprofileGeneralUiStepIndicator(current, total) }
    static func dialCode(_ code: String, region: String) -> String { ProfileV3L10n.moAiprofileAccountInputCountryCode(code, region) }
    static func dialCodeDisplay(_ code: String) -> String { ProfileV3L10n.moAiprofileSettingsLabelDialCode(code) }
    static func requiredLabel(_ label: String) -> String { ProfileV3L10n.moAiprofileSettingsLabelRequiredField(label) }
    static var sectionComplete: String { ProfileV3L10n.moAiprofileGeneralLabelSectionComplete }
    static var sectionPending: String { ProfileV3L10n.moAiprofileGeneralLabelSectionPending }
    static var agentUnavailable: String { ProfileV3L10n.moAiprofileAgentErrorUnavailable }
    static var retry: String { ProfileV3L10n.moAiprofileGeneralButtonRetry }
    static var tryAgain: String { ProfileV3L10n.moAiprofileGeneralButtonTryAgain }
    static var loadingHome: String { ProfileV3L10n.moAiprofileAccountSettingsLoadingProfile }
    static var loadFailedTitle: String { ProfileV3L10n.moAiprofileGeneralErrorTitleSomethingWentWrong }
    static var actionUnavailable: String { ProfileV3L10n.moAiprofileGeneralErrorActionUnavailable }
    static var somethingWentWrong: String { ProfileV3L10n.moAiprofileGeneralErrorMessageGeneral }
    static var disconnectFailed: String { ProfileV3L10n.moAiprofileAgentsErrorDisconnectFailed }
    static var loadFailedSubtitle: String { ProfileV3L10n.moAiprofileGeneralErrorSubtitleInternetIssue }
    static var loadFailed: String { ProfileV3L10n.moAiprofileGeneralErrorLoadFailed }
    static var saveFailed: String { ProfileV3L10n.moAiprofileGeneralErrorSaveFailed }
    static var redeemFailed: String { ProfileV3L10n.moAiprofileLoyaltyErrorRedeemFailed }
    static var countrySearchEmpty: String { ProfileV3L10n.moAiprofileGeneralEmptyStateCountrySearch }
    static var agentSuffix: String { ProfileV3L10n.moAiprofileAgentSuffix }
    static func agentTag(_ name: String) -> String { ProfileV3L10n.moAiprofileAgentTagLabel(name, agentSuffix) }
    static var flipCard: String { ProfileV3L10n.moAiprofileLoyaltyButtonFlipCard }
    static var explorePass: String { ProfileV3L10n.moAiprofileLoyaltyTitleExploreWorldPass }
    static var worldPassCardHint: String { ProfileV3L10n.moAiprofileLoyaltyHintCardInteraction }
    static var collapsed: String { ProfileV3L10n.moAiprofileGeneralAccessibilityValueCollapsed }
    static var expanded: String { ProfileV3L10n.moAiprofileGeneralAccessibilityValueExpanded }
    static var expandHint: String { ProfileV3L10n.moAiprofileGeneralAccessibilityHintExpand }
    static var collapseHint: String { ProfileV3L10n.moAiprofileGeneralAccessibilityHintCollapse }
    static var redeemedJustNow: String { ProfileV3L10n.moAiprofileLoyaltyStatusRedeemedJustNow }
    static var addProgrammeKYCRequired: String { ProfileV3L10n.moAiprofileLoyaltyErrorKycRequired }
    static var redirectingToKYC: String { ProfileV3L10n.moAiprofileAccountStatusRedirectingToKyc }
    static var agentKYCRequired: String { ProfileV3L10n.moAiprofileAgentErrorKycRequired }
    static var benefitKYCRequired: String { ProfileV3L10n.moAiprofileLoyaltyErrorBenefitKycRequired }
    static var kycUpdating: String { ProfileV3L10n.moAiprofileGeneralStatusKycUpdating }
    static var passportUploadFailed: String { ProfileV3L10n.moAiprofileDocumentsErrorPassportUploadFailed }
    static func completeHolderKYCFirst(_ name: String) -> String { ProfileV3L10n.moAiprofileGeneralTextCompleteHolderKycFirst(name) }
    static var scanningLead: String { ProfileV3L10n.moAiprofileLoyaltyScanningStatusLead + " " }
    static var scanningEmphasis: String { ProfileV3L10n.moAiprofileLoyaltyScanningStatusEmphasis }
    static var goingThroughEmails: String { ProfileV3L10n.moAiprofileLoyaltyScanningStatusGoingThroughEmails }
    static var foundLead: String { ProfileV3L10n.moAiprofileGeneralLabelFound }
    static var pickLoyaltyProgramme: String { ProfileV3L10n.moAiprofileLoyaltyLabelPickProgram }
    static var membershipNumber: String { ProfileV3L10n.moAiprofileLoyaltyInputLabelMembershipNumber }
    static var typeHere: String { ProfileV3L10n.moAiprofileGeneralInputPlaceholderTypeHere }
    static var continueTitle: String { ProfileV3L10n.moAiprofileGeneralButtonContinue }
    static var addProgrammeFailed: String { ProfileV3L10n.moAiprofileLoyaltyErrorAddProgramFailed }
    static var noProgrammesMatch: String { ProfileV3L10n.moAiprofileLoyaltyErrorNoMatches }
    static var noProgrammesTitle: String { ProfileV3L10n.moAiprofileLoyaltyEmptyStateNoProgramsFound }
    static var noProgrammesConnectedTitle: String { ProfileV3L10n.moAiprofileLoyaltyEmptyStateNoProgramsConnected }
    static var noProgrammesConnectedBody: String { ProfileV3L10n.moAiprofileLoyaltyEmptyStateNoProgramsConnectedBody }
    static var noProgrammesInCategory: String { ProfileV3L10n.moAiprofileGeneralEmptyStateCategory }
    static var categoryAll: String { ProfileV3L10n.moAiprofileLoyaltyCategoryLabelAll }
    static var categoryCreditCards: String { ProfileV3L10n.moAiprofileLoyaltyCategoryLabelCreditCards }
    static var categoryHotels: String { ProfileV3L10n.moAiprofileLoyaltyCategoryLabelHotels }
    static var categoryTravelPasses: String { ProfileV3L10n.moAiprofileLoyaltyCategoryLabelTravelPasses }
    static func sourcesCount(_ count: Int) -> String { ProfileV3L10n.moAiprofileGeneralLabelSourcesCount(count) }
    static var sources: String { ProfileV3L10n.moAiprofileLoyaltyLabelSources }
    static let stepperDecrease = "-"
    static let stepperIncrease = "+"
    static func removeOne(_ item: String) -> String { ProfileV3L10n.moAiprofileGeneralButtonRemoveItem(item) }
    static func addOne(_ item: String) -> String { ProfileV3L10n.moAiprofileGeneralButtonAddItem(item) }
    static func sourcesCount(_ count: Int, label: String) -> String { ProfileV3L10n.moAiprofileGeneralLabelCountWithLabel(count, label) }
    static var viewSources: String { ProfileV3L10n.moAiprofileLoyaltyButtonViewSources }
    static func bulleted(_ text: String) -> String { ProfileV3L10n.moAiprofileGeneralFormatBulleted(text) }
    static func nudgeAccessibility(message: String, action: String) -> String { ProfileV3L10n.moAiprofileGeneralAccessibilityNudge(message, action) }
    static var gotIt: String { ProfileV3L10n.moAiprofileGeneralButtonGotIt }
    static func preferencesFound(_ found: Int, of total: Int, noun: String) -> String { ProfileV3L10n.moAiprofileSettingsLabelPreferencesCount(found, total, noun) }
    static var viewAllBenefits: String { ProfileV3L10n.moAiprofileLoyaltyButtonViewBenefits }
    static func passNumberLabel(_ number: String) -> String { ProfileV3L10n.moAiprofileDocumentsLabelPassNumber(number) }
    static func viewAllBenefits(_ count: Int) -> String { ProfileV3L10n.moAiprofileLoyaltyButtonViewBenefits1(count) }
    static func kycStatusLine(_ status: String, _ detail: String) -> String { ProfileV3L10n.moAiprofileGeneralLabelKycStatusLine(status, detail) }
    static var kycComplete: String { ProfileV3L10n.moAiprofileAccountStatusKycComplete }
    static var kycIncomplete: String { ProfileV3L10n.moAiprofileAccountStatusKycIncomplete }
    static var gmailSyncTimedOut: String { ProfileV3L10n.moAiprofileAccountErrorGmailSyncTimeout }
    static func updatedOn(_ text: String) -> String { ProfileV3L10n.moAiprofileGeneralMetadataUpdatedOn(text) }
    static func distanceKilometres(_ kilometres: Int) -> String { ProfileV3L10n.moAiprofileGeneralDataDistanceKm(kilometres.formatted()) }
    static func unitValue(_ value: Int, unit: String) -> String { ProfileV3L10n.moAiprofileGeneralLabelUnitValue(value, unit) }
    static func moreCount(_ count: Int) -> String { ProfileV3L10n.moAiprofileGeneralCounterPlus(count) }
    static func updatedAgo(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.lowercased().hasPrefix("updated") ? trimmed : ProfileV3L10n.moAiprofileGeneralMetadataUpdatedDynamic(trimmed)
    }
    static func programmeCount(_ count: Int) -> String { String(format: "%02d", count) }
    static func foundProgrammes(_ count: Int) -> String {
        count == 1 ? ProfileV3L10n.moAiprofileLoyaltyFoundProgramsOne(count) : ProfileV3L10n.moAiprofileLoyaltyFoundProgramsOther(count)
    }
    static func foundProgrammesLine(_ count: Int) -> String {
        count == 1 ? ProfileV3L10n.moAiprofileLoyaltyFoundProgramsLineOne(count) : ProfileV3L10n.moAiprofileLoyaltyFoundProgramsLineOther(count)
    }
}
