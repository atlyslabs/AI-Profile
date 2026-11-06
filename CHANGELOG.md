# Changelog

All notable changes to ATAIProfile. Versions are git tags on `master`; hosts depend on them with
`.package(url: "https://github.com/atlyslabs/AI-Profile.git", from: "<version>")`.

## Unreleased

### Added

- City profile (Figma `6739:7548` and the frames around it), wired to the backend from
  `vdc-k8s#24000`. The board tile (`agent_type: "city"`, `next: {go: "city_profiles"}`) opens it
  as a page sheet.
  - The intro (`GET /board/cities`) is a carousel of plane-window cities, each with its purpose,
    ending in an "Add" window that shows the headline and the three-card sample deck from
    `6739:8232`. Selecting a city loads its screen (`GET /board/cities/{id}`), with a retry if it
    fails: the purpose chip and its pencil, the server's "Found 3/6 preferences" and sources
    summary, a tab strip, six notched cards (airlines, class, seat, timings, pick-up, hotels) and
    custom rules.
  - The tab strip pins under the header once it scrolls up there. A tap scrolls the page so the
    section's card starts just under the pinned strip, and the strip scrolls the selected tab into
    view. Scrolling by hand moves the highlight to the last section that has reached the strip
    (the first tab at the top); for the moment a tap's own scroll runs, crossings are ignored, so
    the highlight stays on the tapped tab.
  - The cards reuse the agent form fields. Each city is a `ProfileV3AgentForm` edited by
    `ProfileV3AgentFormViewModel`, so the pickers, sources, custom rules and "save changes" bar
    work as they do for agents. A save sends the whole city (`save_city_preferences`, every card
    plus `avoid_non_reclining`, `no_pickup` and `no_stay`), then reloads it.
  - Layouts: logo chips with the airline picker, seat tiles (the server's images when it sends
    them, else the bundled seat art), option chips with the server's time-of-day orbs, and hotel
    rows. Opt-outs ("Do not book stay in this city") dim a card and keep its chips.
  - Hotels are a free list of names, up to 20 of 120 characters. With the host's `placesAPIKey`,
    the picker searches Google Places for lodging as you type, like KYC's address search: in the
    city's country, with the city's name added to the query, 300 ms after the last keystroke. Your
    saved hotels that match come first, then up to five found ones with their area; picking one
    adds its name. "+Add …" stays at the end for a name Places doesn't know, and is the only way
    to add a hotel without a key.
  - Adding a city: a paged picker (`GET /board/cities/search`, 250 ms debounce, late replies to an
    older search dropped, flags, "POPULAR CITIES" before typing), then the purpose sheet
    (`GET /board/cities/purpose`). Home, Work and Leisure are once each and show greyed out when
    used; Other asks for a name that no other city uses, checked as you type. The same city can be
    added again with another purpose. The pencil opens the same sheet with Save and a delete that
    confirms first. The server's messages show for a refused write.
  - Four client strings were hand-added (`mo-aiprofile-agents-*city*`); add them in Ditto.
  - In DEBUG builds, Settings' debug section has a "City profile" row that opens the live flow.
    It replaces the KYC state menu, whose board override
    (`ProfileV3DebugKYCScenario`) is gone, so a scenario picked earlier no longer rewrites boards.
- The option picker shows a subtitle next to a row's title ("Bangkok (BKK) · Thailand"), a hotel
  or map thumbnail, and an optional list label ("Popular locations"). A picker with nothing to list
  stays blank until you type, rather than showing the no-results message.
- `ProfileV3HostActions.placesAPIKey` (optional) and a GooglePlaces dependency (`ios-places-sdk`
  from 10.1.0, the version range KYC uses) for the hotel search. Hosts pass the key they give KYC;
  the package calls `GMSPlacesClient.provideAPIKey` with it once.
- Loyalty programmes can be edited. In the programmes page's edit mode (where cards are picked for
  deletion), every card has an "Edit" pill where "View insight" sits. It opens the add flow's
  details sheet, filled from `GET /board/loyalty/edit/{program_id}?profile_id=` (slashes in the id
  are kept), with the server's title ("EDIT DETAILS") and button ("Save"), no back button or step
  dots, and an optional membership number. Save turns on once a value changes and sends
  `edit_loyalty_program` with only the changed fields (a cleared field goes as `null`) and the
  form's `program_id`. The sheet then closes, the programmes page reloads and the hub refreshes. A
  failed save keeps the sheet open with "Couldn't save your changes. Try again." A reload now also
  drops selected cards that are no longer on the page, so Delete counts only cards that are there.
- The add and edit forms take a loyalty tier. For a programme with a tier list, the backend's
  `tier` field (`single_select`) shows as a dropdown of its tiers plus "I don't know", and
  `tier_valid_until` (`month_year`) as a field that formats "MM/YY" as you type.
  - A month that is unreadable or already past shows "Enter the month as MM/YY, this month or
    later." and blocks saving, but only when the month would be sent.
  - Adding sends the picked tier's value, with the month only for a real tier; left blank, the
    server sets 12 months from today.
  - Editing sends the tier and its month together whenever either changes, so a new tier keeps the
    saved month. "I don't know" clears both.
  - The new key `mo-aiprofile-loyalty-error-tier-valid-until-invalid` was added by hand; add it in
    Ditto.
- A benefit's detail shows a "Learn more" button when `GET /board/benefits/{id}` sends
  `learn_more: {label, next: {go: "ai_chat", prompt}}` and the host opens chat
  (`ProfileV3AppHost.opensChat`). The button shows the server's label in the footer (design
  `5648:13079`), over a fade to light grey. A tap closes the detail (and the benefits list, if it is
  open) and then calls `openChat(prompt:)` with the server's prompt. A missing label, a blank prompt
  or any other `go` hides the button. The tap logs `profile_cta_clicked` with origin
  `benefit_detail` and the benefit's id. When "Got it" or "Redeem" also shows, the two buttons
  stack, with Learn more on top.
- Connecting Instagram opens on an intro (Figma `6595:15220`): under "Turn your travel Reels into an
  actual plan.", five reels shrink into pins on a map, the map fades in and a place card pops up.
  It runs once (3.4 s), holds for a second, then moves on to the explainer; a tap skips ahead.
  With Reduce Motion the designed still shows instead. The photos, map and pin glyph are bundled
  (`profile_v3_instagram_*`, `profile_v3_pin_distance`, about 0.8 MB). Three keys were hand-added
  (`mo-aiprofile-agents-title-instagram-reels-plan`, `-label-instagram-sample-place` and
  `-sample-place-detail`); add them in Ditto.
- "Send a message" on the waiting Instagram card plays the redirect from Figma `6595:14302` over
  App access before opening the chat with @ayl.chat. The orb assembles from 44 particles over 2 s
  above a white fade and the green wash, with "...Come say hi!", "Follow us, drop in a text" and
  "Redirecting you to instagram...". Touches are blocked while it plays, a second tap is ignored,
  and closing Settings cancels it. The redirect after linking a username, inside the sheet, is
  unchanged.

### Changed

- While Instagram waits for its first DM, a pen next to the handle edits it (Figma `6595:16405`,
  node `7196:11333`: a 20pt grey chip with Material's `pen_size_4`). It opens the same username
  sheet as the Connected panel's Edit, from App access itself, and a save re-links the new handle,
  which waits for its own DM; the page stays put. VoiceOver gets an Edit action on the card.
- Agent orbs follow Figma `6592:8147`. Flight shows the plane window and airport logistics the
  spoon: the CDN has those two files the other way round (`agent_flight.png` is the spoon), so
  `ProfileV3PlaceholderArt.agentFlight` and `.agentAirport` point at each other's file, and a
  known agent's tile now uses that art unless the server sends a full URL; an `orb_<name>` token
  still resolves to `agent_<name>.png` for agents the app doesn't know. City profile's orb is
  `agent_city.png` on the CDN, like the rest.
- The hub shows every agent tile the board sends, so a new agent needs no app update. City profile
  now shows (the `isCityProfileEnabled` flag is gone, and `city_profiles` always opens it). A tile
  whose `go` is `agent` opens the agent screen for any `agent_type`, where an unknown type used to
  do nothing. Tile art comes from the `icon` URL, or an `orb_<name>` token resolves to
  `profile-v3/agent_<name>.png` on the CDN (`agent_city.png` isn't uploaded yet).
- While Instagram waits for its first DM, its App access card follows the design: the saved handle
  as the title ("@grukhs"), "Send a message" (was "Send a DM"), and "Get to know @ayl.chat" over
  "Drop in a message or just share something funny..." in place of the one-line status. The
  bundled Instagram logo is cropped to its circle, so it fills its round frame like the other app
  logos. Keys: `mo-aiprofile-agents-button-send-dm` is now `mo-aiprofile-agents-button-send-message`,
  `mo-aiprofile-agents-status-instagram-awaiting-message` is gone, and
  `mo-aiprofile-agents-title-instagram-get-to-know` and
  `mo-aiprofile-agents-description-instagram-get-to-know` are new; add them in Ditto with the other
  Instagram keys.
- Saving a login in the credential store (or app credentials) only calls the API: iOS no longer
  offers to save it to the user's Passwords. The sheet's fields aren't tagged as a username and
  password any more (the password field is a one-time-code field), so the system "Save Password"
  prompt doesn't fire for these third-party logins. The password stays masked in session replay.
- Strings are back in sync with Ditto. The 44 strings that had been added by hand are now in
  Ditto, the six copy edits (the Atlys → Ayl strings and the "How you pay" text) are applied there,
  and 23 unused strings are gone (16 of them deleted from Ditto). `ProfileV3Localizable.xcstrings`
  and `ProfileV3L10n` are rebuilt from Ditto. No accessor or value changed, and the generated
  fallbacks now say "Ayl" too.
- The flight and stay agents take the backend's new fields (deployed 2026-10-31):
  - The flight agent's "Fast or affordable?" slider (`time_value_per_hour`, `display: "money"`)
    shows its value as the currency symbol, a compact amount and the unit (`₹10K/hour`,
    `$120/hour`). Its track (`min`, `max`, `step`) comes from the field, so it follows the
    account's currency, and it saves the plain number.
  - Avoid airlines (`avoid_airlines`) uses the same add-picker as Preferred airlines. Hotel class
    (`hotel_class`) shows each option's label and saves its value. The 100 hotel groups stay in
    the "+ Add" picker, with only the chosen ones shown inline.
  - A slider whose value is `null` now saves `null` until it is moved, instead of the midpoint it
    shows.
- The hub refreshes its board quietly when it comes back on screen (the Profile tab again, or the
  app returning from the background) if the board it shows is more than a minute old. It also
  shows straight away a newer board another screen has already fetched. Programmes that reach the
  server another way (the Gmail import, chat, another device) now appear on the pass's back face
  without relaunching. This refresh shows no spinner and no error.
- The Control panel's connector deck, where Gmail and apps are disconnected, now heads its
  "CONNECTORS" label with the plug icon (`plugConnect`), the same icon as the Settings card,
  instead of the database icon.
- The Instagram explainer moves on after 7 seconds (was 15).
- App access's Connected panel shows only connected apps, and Information access's shows only the
  email connectors; both used to show one deck with every card. App access shows "Connected" only
  once an app is connected (an email connector no longer counts). The apps deck is the new settings
  route `connectedApps`, and `ProfileV3AppAccessModel` no longer takes the connectors model.
- "Complete KYC" on a locked glove box now starts Gmail linking (the `gmail_connect` capture, the
  same flow as Information access's Gmail card) instead of KYC onboarding.
- A connected Instagram stays listed on App access, as a row like Splits' "auto connected" one:
  its logo, the @handle and a green "connected". It is also under Connected, where Edit lives.
  Instagram is the only app in release, so once the DM to @ayl.chat registered the page used to
  show nothing below the heading. Other connected apps still move to Connected only.
- Saving an edit from App access's Connected panel goes back to App access once the edit sheet has
  closed. A relinked Instagram waits for a new DM, so it leaves the panel, which used to stay open
  and empty.
- A field's sources row draws every icon the server lists in `source.icons` (Gmail, you, then each
  AI assistant), where it used to stop at two, and the sources sheet is fetched for the field's
  `next.profile_id` when one is sent.
- Spidey Sense rows draw the row's `icon` when the server sends one: a Gmail row's on the grey tile
  at the Gmail glyph's size, any other row's (you, an AI assistant) filling the tile. Rows without
  `icon` draw by `kind` as before.

### Fixed

- Adding a traveller from the profile home page (or the add-traveller link) opened the travellers
  list underneath, so the sheet had a back button that led to editing travellers (Vijay). It now
  opens on the add form alone, with only the close button; from Settings → Travellers the form
  keeps its back button. After a save the sheet shows the travellers list with the "added" toast,
  as before.
- Changing the travel persona sent no analytics event (aadi, 2026-10-30). Each knob change the
  autosave sends, and each action on a trait's screen ("Ignore", "Ignore all", "Undo"), now sends
  `profile_agent_preference_changed` with `agentName: travel_person_agent`, the trait as
  `sectionName`, and the new score or the server action name as `changedValue`.
- The Travel persona tile kept its "+" ring after the persona was edited. From the first saved knob
  change or trait action it now shows the green ring, like an agent with saved preferences, and
  the hub refetches its board as it does after the other agents save. ai-kyc always sends the
  tile's `updated_label` empty, so the app remembers which travelers' personas were saved on this
  device (`ProfileV3HubHints.personaSavedProfileIDs`) until the board sends a label for it.
- Saving contact info (email or phone) in Settings made no request when the host has no selected
  traveller, which is always the case in Ayl: the save failed before
  `PATCH /api/pensieve/v1/profile/edit` and only the error haptic played. The save, and the
  residence push, now fall back to the board's main profile ID, the same `traveller_id` the package
  already sends when it edits a traveller.
- A long Instagram handle no longer pushes "Send a message" onto two lines on the waiting App
  access card. Card actions ("Send a message", "Connect", "Add email", the credentials buttons)
  keep to one line, and the title before them is cut short with an ellipsis ("@aravindh_…").
- QA-2007: The glove box stays locked while the main traveler's KYC isn't done, even when the
  account already has a Glove box address. Before, only an account without an address was
  checked, so after disconnecting the KYC email the inbox still opened. Now every open checks the
  board's KYC alongside Jaqen's `/me` (which doesn't check KYC): without KYC it shows "Your Glove box
  is ready to unlock" with Complete KYC and loads no emails. The check uses the cached board only
  when it is less than a minute old and otherwise fetches the latest one. If that fetch fails, it
  falls back to the cached board, and then to unlocked. The Settings card shows its ACTIVATE pill
  while the glove box is locked this way too.

QA-2008 (iOS profile new changes):

- QA-2009: The custom rule editor's trash button draws Figma's Material Symbols bin, the one with
  two slots (`profile_v3_delete`). ATUIKit's `delete` is a plain bin. The "delete your rule" sheet
  now has its icon, `text_snippet` in a grey 40pt circle, with the buttons 23pt under the title, as
  in Figma `6006:50380`.
- QA-2011: Scrolled to the end, the AI connector's detail step leaves 54pt between the last
  disclaimer and "Get started", as in Figma `6473:6991`. Before, the save bar's 158pt fade counted
  towards the bottom inset and left about 134pt. `ProfileV3SaveBar(reservesFade: false)` draws the
  fade without taking space; other save bars are unchanged.
- QA-2043: The prompt to copy into the AI assistant scrolls inside its card, so the whole prompt
  can be read before copying. At rest the card looks as before. Scrolled lines fade out under the
  card's top edge, and the last line can scroll clear of the bottom fade.
- QA-2050: The Instagram explainer has the green wash from Figma `5836:33608` (`6595:14300`) in
  place of the rainbow glow: the redirect step's colours at 56%, at Figma's angle, from 310pt down.
  Figma's noise texture isn't reproduced.
- QA-2042: A 500 with no envelope `code` (FastAPI's bare `{"detail": "Internal server error"}`)
  now shows "Something went wrong. Please try again." instead of the server's text, on every
  screen. The Instagram link failure itself is in snapmap, not the app.

## 1.0.21 — 2026-10-31

### Changed

- The glove box Virtual card no longer shows the "No-show fee · Asks you first" row; Works at and
  Your own card remain. Its keys `mo-aiprofile-glovebox-label-card-no-show-fee` and
  `mo-aiprofile-glovebox-label-card-asks-first` are gone from the catalog; if they were added to
  Ditto, delete them there too.
- Six strings that named Atlys now say Ayl: the email-taken error, the credential store's two
  descriptions, the vault's sign-in-again error, the glove box account error and the "Ayl pays, we
  bill you" option. Every host shows this copy, the Atlys app included. The virtual card's Works at
  value is now "Browser payments" (was "Restaurant only"). Make the same changes in Ditto.
- Information access shows the AI assistants again: every one the overview sends (in production,
  Claude, ChatGPT, Gemini and Grok). 1.0.20 hid them; `ProfileV3FeatureFlags.isAIConnectorsEnabled`
  is now true. Their backend (PR #23552: the assistant rows, `ai_connector`, `ai_connector_connect`
  and `connect_ai_connector`) has been deployed since 2026-10-30.

## 1.0.20 — 2026-10-31

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
