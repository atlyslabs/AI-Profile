# Changelog

All notable changes to ATAIProfile. Versions are git tags on `master`; hosts depend on them with
`.package(url: "https://github.com/atlyslabs/AI-Profile.git", from: "<version>")`.

## Unreleased

### Changed

- App access now links Instagram to Ayl through the snapmap service, so places from posts the user
  DMs to @ayl.chat save to their Ayl map. "+ user name" opens an explainer (shown for 15 seconds, or
  until tapped; its sample handle reads "ayl"), then a username sheet that saves with
  `POST /api/snapmap/instagram/accounts` (the username normalised and checked on the
  device first: no leading `@`, lowercase, 1–30 letters, numbers, dots or underscores), then "Follow
  us, drop in a text" before opening a chat with @ayl.chat (`https://ig.me/m/ayl.chat`). The page
  reads the link from `GET /api/snapmap/instagram/accounts`: until that account has messaged
  @ayl.chat (`dm_connected` false), Instagram stays in the list with the saved handle and a "Send a
  DM" action, and the page refreshes when the app becomes active again; once it has, Instagram
  moves to Connected. A username linked to another Ayl account shows the server's 409 message.
  Editing the username from the Connected panel links the new one, which then needs a DM again.
  Instagram can't be disconnected, because snapmap has no unlink endpoint yet. Both calls send the
  host's `currentUserID` as `user_id`, which must be the signed-in Firebase uid. For now App access
  lists only Instagram, in every build, and hides "+ Add new": the other apps are DEBUG demo data
  behind `ProfileV3FeatureFlags.isAppAccessOtherAppsEnabled` (false). In release builds of
  1.0.17–1.0.19 the page couldn't load its list (`notImplemented`); it now reads it from snapmap.
  Four more keys need adding in Ditto: `mo-aiprofile-agents-description-instagram`,
  `-button-send-dm`, `-error-instagram-username-invalid` and `-status-instagram-awaiting-message`.
- App access shows auto-connected apps (Splits) at the top of the same list as the other apps,
  with "auto connected" in green where the action would be; the separate auto-connected cards and
  the dashed divider are gone. Every row is now a white card with a soft shadow, and the list starts
  44pt under the subtitle, as in the "1981" frame. Only Instagram shows for now (see above).
  `mo-aiprofile-agents-label-instagram-sample-handle` is now "ayl" (was "Johndoe"); change it in
  Ditto too.
- Information access hides the AI assistants for now: it drops every row whose `next` is
  `ai_connector` while `ProfileV3FeatureFlags.isAIConnectorsEnabled` is false.
- More pieces share one component each: sheet settings and fitted confirmation sheets, back and
  close controls, page top bars, confirmations, page headings (access pages, shield sheets, "Coming
  soon", the agent "Found …" title), the load-more footer, bottom toast, error alerts and error
  lines, header and bottom fades, dashed rules, uppercase labels, outlined boxes, the sources
  caption, segmented tracks, the pass pill, the traveler card, the card tab, tooltip bubbles and
  frosted backdrops. Four screen loaders, four save states, the signed-in request wrapper, the ISO
  date parsers and the sheet-window guards are shared too. The theme defines each colour once and
  uses the ATUIKit colour wherever one matches; it has one soft shadow, named easing curves and one
  value per repeated timing, its spacing, radius and control-height tokens use the shared scales,
  and 13 unused tokens are gone, as is the duplicate `profile_v3_glovebox_bolt` image. Screens look
  the same, except that the pass detail's flag pill casts its shadow from the pill only, and agent
  forms with an empty summary no longer leave a gap under the title.

## 1.0.19 — 2026-10-30

### Changed

- **The invite card is one supplied image.** Its rounded corners and drop shadow are baked into
  the art, so the card no longer draws a shape, border or shadow of its own, and the layered
  foil reconstruction is gone.

## 1.0.18 — 2026-10-30

### Added

- **Invite code sheet** behind the settings row `go: "invite_friends"` / `"invite_code"` — the
  foil card, the spaced code, invites-left pips and a share CTA. The data comes from the host
  through the new `ProfileV3InviteHost` seam; with no host conformer the sheet shows its empty
  state, so hosts on an older build are unaffected.
- The row takes its envelope from `ATMS.drafts`, which adds **ATMaterialIcons** to the package.

## 1.0.17 — 2026-10-30

### Added

- The personal agent shows the passport's back page beside the front, in a sideways FRONT/BACK
  row, when the passport card sends any of `father`, `mother`, `spouse` or `address` (up to three
  lines). Each row's label comes from the card's `labels`; a missing value keeps its label and an
  empty underline. Previous passports show their own back pages the same way.
  `ProfileV3FeatureFlags.isPassportBackPageEnabled` turns the back page off. The passport card now
  uses the server's `labels` for the front too, falling back to the client copy. Two new keys need
  adding in Ditto: `mo-aiprofile-documents-label-passport-front-page` and
  `mo-aiprofile-documents-label-passport-back-page`.
- The loyalty picker shows an IN / World market pill before the chips, on the chips the catalogue
  lists in `market.chips`. The first catalogue request sends no `market` and preselects the served
  one; every later request (filters, search) sends the selected `market`.
- Information access lists the AI assistants the overview sends (Claude, ChatGPT, Gemini, Grok, or
  any other entry), with `connect_label`, or `status_label` with `{date}` filled from `synced_at`
  in the phone's time zone. A row opens the assistant's sheet: its benefits and disclaimers
  (`GET …/settings/connectors/ai/{connector}`), then the two steps
  (`…/connect`): copy the prompt, paste the answer, Save (`connect_ai_connector` with `text`). A
  refusal shows the server's message; a save reloads the list. The page's title and blurb come
  from the overview. `ProfileV3SettingsRepository` gained the `ProfileV3AIConnectorRepository`
  methods.
- App access has an Instagram flow, UI only: "+ user name" opens an explainer, then a username
  sheet, then "Follow us, drop in a text" before opening Instagram. The Instagram destination is a
  placeholder until Ayl's handle is known. App access is turned on in this release
  (`isAppAccessEnabled`), but its list isn't implemented in release builds yet, so there the page
  shows its error state. Sixteen new keys need adding in Ditto: `mo-aiprofile-agents-button-add-username`,
  `-title-add-username`, `-label-username`, `-toast-username-added`,
  `-title-instagram-step-username`/`-redirect`/`-follow`,
  `-description-instagram-step-username`/`-redirect`/`-follow`, `-label-instagram-sample-handle`,
  `-label-instagram-follow`, `-label-instagram-hi`, `-title-instagram-come-say-hi`,
  `-title-instagram-follow-us` and `-status-instagram-redirecting`.

### Changed

- Agent forms' custom rules now come from the agent screen's `custom_rules` field (flight, stay,
  airport logistics, food and itinerary) and save with the agent. Rules kept on the device in
  1.0.13–1.0.16 are not carried over. The rules show as note cards, newest first, under the
  field's label; "+ Custom" (`add_label`) stays at the bottom left, next to "save changes" when
  there are unsaved edits, and hides once the list has `max_rules`. Tapping a card edits it, and
  its delete button asks first (`delete_confirm`). The editor's titles, note label, Save label and
  saved toast come from `editor`, and its text stops at `max_chars`. Adding, editing or deleting a
  rule saves like any other field: the list goes into the agent's `save_agent_preferences` with
  the whole form, through the household sheet when `save.household` is served. A refusal (422
  `invalid_custom_rules`) shows the server's message in the editor. Saving a new rule closes the
  editor and scrolls the form down to the rule, first in the row. With the keyboard up, the editor
  keeps Save at least 16pt above it, closing the gaps and then shortening the note on smaller
  phones. `ProfileV3FeatureFlags.isAgentCustomRulesEnabled` turns the section off. Only
  `mo-aiprofile-agents-button-delete-rule` (the delete button's accessibility label) is client
  copy; the other seven custom rule keys added earlier are unused and don't need adding to Ditto.
- Elements that were built several times now share one component each: the agent-style sheet
  header and grabber, the save bar and the continue-spinner-toast control, the dark and white pill
  buttons, the round country flag, the traveler phone field, picker row and dial-code sheet, the
  copy button and its reset timer, the scroll view that fades under a fixed header, and the rainbow
  glow with its gradient and blur. Screens look the same, pixel for pixel, except "+ Custom" on
  agent forms, which now uses the save button's spacing: its icon sits 0.4pt further left.
- Save buttons that appear once there is something to save now rise into place: "save changes" on
  agent forms, the saved login and app edit sheets, and the custom rule editor's Save and "save
  changes". With custom rules, "+ Custom" stays still while the save button enters beside it. On
  agent forms the save button now also fades out when an edit is undone or after "saved"; before,
  it vanished at once.
- Settings cards are in the order Accounts center, Connectors, Glove box, Secure credential store
  (the concierge card, when served, stays after Accounts center), all 25pt apart.
- Glove box: an empty inbox shows only the Emirates sample email; any real email still replaces
  it. The Virtual card section shows three facts (Works at, Your own card, No-show fee) and How you
  pay ("When the agent books for you.") with two options, chosen on the device only (no API yet).
  Add card opens a "Coming soon" sheet. The stats tiles stay off, and the card's transactions and
  View all are hidden behind `ProfileV3FeatureFlags.isGloveBoxCardTransactionsEnabled` (false).
  The card shows the main traveler's name from the board, shortened to first name and last initial
  ("Mohak N."), and last four digits derived from the user's glove box address, so they stay the
  same on every open until the backend issues real cards.
  New keys to add in Ditto: `mo-aiprofile-glovebox-label-card-works-at`, `-restaurant-only`,
  `-own-card`, `-never-shared`, `-no-show-fee`, `-asks-first`,
  `mo-aiprofile-glovebox-title-pay-atlys`, `-pay-link`,
  `mo-aiprofile-glovebox-description-pay-atlys`, `-pay-link` and
  `mo-aiprofile-glovebox-status-card-link-pending`; `mo-aiprofile-glovebox-description-how-you-pay`
  needs its new text. The four `mo-aiprofile-glovebox-sample-email-hotel-*` keys are unused.

## 1.0.16 — 2026-10-30

### Changed

- **One permission-changed event instead of two.** `settings_connector_permission_changed` and
  `settings_action_permission_changed` are replaced by `settings_permission_changed`, which names
  the kind in a `source` property (`connector` / `action` / `call`). The two old events are gone.

### Added

- **`settings_permission_closed`** — reports what changed while the permission screen was up, with
  `newPermission` and `oldPermission` each keyed by source. Silent when nothing changed.

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
- The personal agent shows a passport placeholder when no passport is on file. The agent screen
  sends `passport_empty` (`title`, `body`, `cta_label`) instead of `passport`, and the card shows
  that copy under the traveler's name, with an Upload button that scans a passport for that
  traveler. A first passport skips "What happened to your old passport" and the card refreshes.
  The client strings `mo-aiprofile-documents-button-upload-passport`,
  `mo-aiprofile-documents-text-upload-blurb-start` and `mo-aiprofile-documents-button-upload` are
  now unused and can be deleted from Ditto.
- The travel persona's loading dial plays a soft tap each time its colour wave lights a trait
  label, and a success tap when the radar replaces it.

### Changed

- Permissions read from the harness service: `GET /api/harness/v1/permissions`, saved one at a
  time with `PUT /api/harness/v1/permissions/{key}` and `{"value": …}`. The board's
  `/permissions` screen and the `save_permissions` submit are no longer used. Each top-level
  permission is a card (its `label` as the tag, its `description` above a segmented control), and
  a permission with a `parent_key` is another row in its parent's card under a dashed divider. The
  sheet title is the client "Permissions". Option values get client labels: `on` "Yes", `off` "No",
  `ask` "Always ask", `always` "Always", `when_needed` "When needed"; anything else is shown with
  its underscores as spaces. Two new keys need adding in Ditto: `mo-aiprofile-agent-settings-always`
  and `mo-aiprofile-agent-settings-when-needed`. The keys
  `mo-aiprofile-agent-settings-connector-defaults`, `-web-access-defaults`, `-ask-for-actions`,
  `-permission-description` and `-before-action-description` are now unused and can be deleted
  from Ditto.
- Medical card: the holder's name stops short of the caduceus and wraps between words, so a long
  name no longer runs under the emblem's wings. The country flag lines up with the name's first
  line.
- The hub doesn't scroll while the "Build your household" card is selected, and scrolls back to
  the top if it was partway down. The pass carousel still swipes.
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
