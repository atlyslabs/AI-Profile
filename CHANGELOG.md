# Changelog

All notable changes to ATAIProfile. Versions are git tags on `master`; hosts depend on them with
`.package(url: "https://github.com/atlyslabs/AI-Profile.git", from: "<version>")`.

## Unreleased

### Added

- `ProfileV3EntryPoint.open(_:)` with `ProfileV3Destination.addTraveller` and
  `.addLoyaltyProgramme`, for deep links. The hub opens the sheet once it is on screen with its board
  loaded; a loyalty programme is added for the main traveller, behind the usual KYC gate.
- Agent forms have custom rules: "+ Custom" opens a note editor, saved rules show in a CUSTOM
  RULES section, and tapping one edits or deletes it. Saving a new rule closes the editor and
  scrolls the form down to the rule, first in the row. With the keyboard up, the editor keeps
  Save at least 16pt above it, closing the gaps and then shortening the note on smaller phones.
  Until the backend supports them, rules are kept on the device per signed-in user, traveler and
  agent (`ProfileV3FeatureFlags.isAgentCustomRulesEnabled`). Eight new `mo-aiprofile-agents-*`
  string keys need adding in Ditto.

### Changed

- Loyalty programmes: edit mode selects programs to delete. Every card gets a checkbox and slides
  right, a "Delete N program(s)" bar appears once one is selected, and a confirmation sheet
  ("Are you sure you want to delete N program(s)", Confirm / Cancel) removes them one by one. A
  program that fails stays selected with the error shown. The back button leaves edit mode before
  the page. The per-card Remove pill is gone. Six new string keys need adding in Ditto:
  `mo-aiprofile-loyalty-button-delete-programs-one`/`-other`,
  `mo-aiprofile-loyalty-confirmation-delete-programs-one`/`-other`,
  `mo-aiprofile-loyalty-button-confirm-delete` and `mo-aiprofile-general-button-cancel`.
  `mo-aiprofile-loyalty-button-remove-program` and `mo-aiprofile-loyalty-button-done-editing` are
  now unused.
- The loyalty programmes page no longer shows the number of programs connected or the points/miles
  total and estimated value; only the server's subtitle is left under the pass tabs.
  `GET …/board/loyalty/page/{profile_id}` is no longer read for `count` or `stats` (`points_total`,
  `est_value`). `mo-aiprofile-loyalty-label-estimated-value` is now unused and can be deleted from
  Ditto. The pass back face still shows its own programme count.
- A phone number stored without a country code is read against the host's residence
  (`ATCoreBaseProvider.userResidencyCode`, from the registered configuration provider) instead of
  the device's region. The device region, then India, are used only when the host gives none.
- The hub's add-traveller sheet closes Settings first when Settings is open, instead of opening a
  second settings presenter.
- The travel persona radar and its loading dial have no title. The "Traveler profile" heading is
  gone from both, and `profile.title` in `GET …/board/travel_persona` is no longer read.
- The persona loading caption ("Decoding your travel choices…") uses the edit hint's grey gradient
  instead of the shimmer that faded its middle words to white.
- Secure credential store card: the shield and padlock are the design's own render
  (`profile_v3_credential_card_art`), glass included, where they used to be drawn natively 11pt high.
- Glove box: the cabinet's and the Settings card's dials use the design's mail, call and credit card
  glyphs. The credit card is filled and rounded, as designed, instead of ATUIKit's outline.
- Glove box: while the main traveler's KYC isn't done (from the board), the intro is the locked
  "Your Glove box is ready to unlock" with "Complete KYC", which closes Settings and starts KYC
  onboarding. Three new string keys (`mo-aiprofile-glovebox-title-unlock`,
  `-description-unlock`, `-button-complete-kyc`) need adding in Ditto.
- Past trips are added by country only. The add sheet is one step: it selects several countries,
  and "Done" adds them all, undated, in one `/board/submit` with a `countries` list (ISO-2). The
  backend saves all of them or none, so a refusal keeps the sheet open with its message and the
  selection for a retry. The month and year picker, Edit on a dated trip, and "+ Add dates" are
  gone. Dated trips the server sends still show their month and year, and a trip's actions sheet
  offers only Delete. `ProfileV3AppHost.addsPastTripsWithoutDate` is removed; a host that still
  implements it keeps compiling and can drop it.
- Secure credential store: a Face ID unlock of the vault also covers revealing passwords while the
  vault stays open. Closing the vault or leaving the app ends that, and unlocking with the passcode
  still asks for Face ID on each reveal.
- KYC onboarding started from the hub surface (`makeHubSurface`), from the hub or from Settings ›
  Connectors, runs in its own navigation controller presented full screen over the host's tab bar,
  as the Gmail connector does. It used to be pushed onto the surface's navigation controller, inside
  the host's tab, so the tab bar stayed on top of it. The host's `startOnboarding(on:)` gets that
  empty container to push onto; if the flow doesn't close it, the package does before reporting
  back. `makeHub(navCon:)` and `presentAddTraveller(navCon:)` still push onto the host's own
  controller.

### Analytics

Profile events follow the profile analytics spec.

- `screen_view` for the hub (`aiProfile`) is sent each time the hub appears, not once per hub
  instance. Settings is `aiSettings`. An agent sends one screen view named after the agent
  (`flight_agent`, `personal_info_agent`, `travel_person_agent` and so on). A benefit's screen
  view is named from its ID (`aiFlightBenefit`, `aiFTIBenefit` and so on, else `aiProfileBenefit`).
- New: `profile_worldpass_tapped`, `profile_card_connect_clicked`, `profile_view_benefits_clicked`,
  `profile_benefits_screen_viewed`, the `profile_connector_*` card events and
  `profile_loyalty_card_clicked`, `profile_agent_preference_changed`, and the `settings_*` click,
  update, permission, back and logout events.
- Renamed: `profile_benefit_clicked` → `profile_benefits_clicked`, `profile_traveller_*` →
  `settings_traveller_*`, `profile_field_saved` → `settings_residence_updated` /
  `settings_citizenship_updated` / `settings_currency_updated`, `profile_contact_saved` →
  `settings_contact_info_updated`, `profile_logout` → `settings_logout_clicked` and
  `settings_logged_out`, `profile_agent_option_toggled` → `profile_agent_preference_changed`.
  `profile_pass_switched` sends `travellerId` instead of `passId`, and the disconnect events send
  `connectorName` instead of `connectorKey`.
- Removed: `profile_pass_viewed`, `profile_agent_card_viewed`, `profile_benefit_viewed`,
  `profile_coupon_viewed`, `profile_programme_viewed`, `profile_settings_row_clicked` and
  `profile_pass_expanded`.
- Several events now carry dictionaries or arrays (`changedSections`, `oldSections`,
  `loyaltyDetails`, `benefitList`, `cardsName`, the traveller and contact details). Hosts forward
  them as they come.
- New `ProfileV3KYC.Event.photoUploaded(_:)` reports each passport page and selfie the profile
  uploads, from KYC capture and from "Upload new passport". Hosts map it to their
  `passport_front_uploaded`, `passport_back_uploaded` and `selfie_uploaded` events and the
  co-traveller variants. A host whose own KYC screens already send them can skip the `.capture` flow.
- `profile_connector_program_card_scrolled` reports the quarter the selected card is in, rounded
  up, so the first swipe sends `"25"`. It used to round down, so a long catalogue sent nothing
  until a quarter of its cards had gone by.
- New: the credential store's `pass_vault_clicked` (`actionSource: settings`),
  `pass_vault_add_credentials_clicked`, `pass_vault_website_selected` (`website`, `cardName`;
  "Other website" sends `other_website`), `pass_vault_credentials_added` (`website`, `cardName`,
  `emailAdded`) and `pass_vault_website_clicked`; the glove box's `glove_box_opened` and
  `glove_box_item_clicked` (`itemType` `mail` / `phone` / `card`, `activated`).
- Removed: `profile_programme_selected`, `profile_programme_added` and
  `profile_programme_edit_toggled`.
- `profile_connector_card_remove_clicked` is sent for each selected card when a multi-select
  deletion is confirmed, rather than on a card's Remove pill.

### Strings

- The Ditto project `ai-profile` matches the client again. It drops the 68 keys whose copy now comes
  from the server, adds the 44 keys earlier releases listed as "to add in Ditto", and spells
  "traveler" like the catalogue. The library folder `profilev3strings` mirrors the project.
- Ten keys are renamed from `traveller` to `traveler`, for example
  `mo-aiprofile-account-settings-button-add-traveler`, and the persona loader title reads
  "Traveler profile".
- Glove Box copy, credential store messages, the Face ID prompt reasons and the household "Confirm"
  fallback were hard-coded; they are now 57 Ditto keys (`mo-aiprofile-glovebox-*`,
  `mo-aiprofile-agents-error-vault-*`, `mo-aiprofile-agents-prompt-face-id-*`,
  `mo-aiprofile-agents-button-household-confirm`), so they can change through runtime overrides.
- `ProfileV3Localizable.xcstrings` and `ProfileV3L10n+Generated.swift` are rebuilt from Ditto (366 keys).
  The persona loader caption and the page-load error subtitle now use a straight apostrophe.

## 1.0.9 — 2026-10-23

### Added

- Glove Box: delivery status, attention and sender logos on each message, a banner when forwarding
  blocks delivery, and attachments as chips; the persona sheet waits behind the processing dial
  (first tagged as 1.0.8, which was cut off master; 1.0.9 carries it).

### Changed

- Analytics: the five events on the fe_ayl_ migration sheet drop their `b2c_` / `b2c_ai_` prefix
  (`account_deletion_reason_submitted`, `kyc_screen_seen`, `complete_kyc_clicked`,
  `kyc_decision_on_gmail_connector`, `kyc_onboarding_completed`); the host adds its own prefix
  (`fe_ayl_` in Ayl). The `b2c_ai_profile_*` and `b2c_gmail_connector_*` events drop their prefix by the
  same rule (`b2c_ai_profile_logout` → `profile_logout`).

## 1.0.1 — 2026-10-20

### Added

- Credential store in Settings, under Connectors. It is on in DEBUG builds only
  (`ProfileV3FeatureFlags.isCredentialStoreEnabled`). The store opens after Face ID or the
  passcode and lists the saved logins from the fort-knox vault (`/api/fort-knox/v1`).
  - "+ Add credentials" opens a website picker built from the vault's site list, with an "Other
    website" row for anything else. A known site is saved by its slug; any other website by host
    and address.
  - A saved login shows its website and full username. The eye shows the password after Face ID;
    a copied password is local-only and leaves the pasteboard after 30 seconds.
  - "Delete account" asks for confirmation in its own sheet, then deletes the login.
  - A reveal or save that fails says why under the password field. Revealing on a phone that isn't
    registered yet needs a sign-in in the last 10 minutes; that is checked before Face ID.

### Changed

- App access shows "Coming soon" in every build (`isAppAccessEnabled` is `false`). Its demo page
  stays in the source. App access no longer lists vault logins; those live in the credential store.
- Settings and the programmes page pause the hub's globe and card hover while they cover it, so
  the hidden hub stops redrawing every frame. The settings view model is `@Observable`, the menu
  loads once per presentation, and the hidden logout, delete-account and permissions sheets are
  measured once instead of on every render.

### Host changes

- Add `NSFaceIDUsageDescription` to the host's Info.plist before turning the credential store on.

### Strings

- Seven new catalogue keys, to add in Ditto: `mo-aiprofile-agents-label-credential-store`,
  `-description-credential-store`, `-description-credential-store-sheet`,
  `-button-add-stored-credentials`, `-button-delete-credentials`,
  `-confirmation-delete-credentials` and `-button-other-website`.

## 1.0.0 — 2026-10-19

First tagged release. The profile hub with its world-pass cards and globe, settings, travellers and
their relationships, loyalty programmes, past trips (served by the board endpoints), the travel
persona, the profile agents' forms (including saving to several household travellers), KYC capture,
and the App access page. Hosts register a configuration provider and their host actions on
`ProfileV3Runtime`; see the README.
