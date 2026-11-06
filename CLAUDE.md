# ATAIProfile package: working context

This folder is the Swift package `ATAIProfile` (repo `atlyslabs/AI-Profile`), the profile module ("ProfileV3") that Ayl and the Atlys app link. Claude Code loads this file into every session, so keep it short.

## Keeping this file current

- When a change lands, update the facts it affects (State, flags, contracts, open work, gotchas) in the same turn. Don't add per-change history: `CHANGELOG.md` and git log hold that.
- Keep only what the code can't tell you: decisions and why, contracts and design sources, open work, unverified behaviour, and gotchas.
- History: the full file before the 2026-10-31 cleanup, including Done items 1–175 with each feature's contract, Figma nodes and user decisions, is `git show 550b009:CLAUDE.md`. Grep it for an item number or a feature name.
- A Stop hook (`.claude/hooks/claude-md-freshness.sh`, run from `.claude/settings.local.json`; both personal and gitignored) asks for an update when package files change after this file was saved, the package gets a new commit, or the app's ProfileV3 changes. When it fires, update State; if nothing needs recording, say so.

## Locations

| What | Path |
|---|---|
| Package | `/Users/aravindh/Desktop/Atlys/AI-Profile`, git `master`, remote `origin` = `https://github.com/atlyslabs/AI-Profile.git` |
| Sources, tests | `Sources/ATAIProfile`, `Tests/ATAIProfileTests` |
| App-side bridge for vdcios (not built by the package) | `AppIntegration/ProfileV3Host` |
| Ayl app | `/Users/aravindh/Desktop/Atlys/AI-Native` (scheme `Ayl`) |
| Atlys app | `/Users/aravindh/Desktop/Atlys/vdcios` |
| Capture package | `/Users/aravindh/Desktop/Atlys/IdentityCapture` (`ATCaptureKit`) |
| AI-Chat | `/Users/aravindh/Desktop/Atlys/AI-Chat` |
| Ditto toolkit | The package's own dependency, checked out at `/tmp/aiprofile-dd/SourcePackages/checkouts/ditto-migrate-toolkit` (0.0.1, `582e7fc`; re-resolve if `/tmp` was cleaned). An older copy is in `~/Downloads/ditto-migrate-toolkit-main`. |
| Backend | `atlyslabs/vdc-k8s` (`services/ai-kyc` and others); check PRs and deploys with `gh` |

## Package

- `Package.swift`: tools 6.4, iOS 17, Swift 6 language mode, `ApproachableConcurrency`. Resources ship `ProfileV3.xcassets` and `ProfileV3Localizable.xcstrings`.
- Package, product, target and module are `ATAIProfile`; tests are `ATAIProfileTests`. The repo and folder keep the name `AI-Profile`, so the SwiftPM identity is `ai-profile`. `README.md` is the integration guide for host teams.
- Hosts: Ayl pins tagged releases. vdcios `feature-profile-ai-spm` links the package from GitHub `master`. vdcios `feature-profile-ai` still compiles an old copy in `Modules/ProfileV3` (last mirrored 2026-10-16, `c23411ed3`); every change since is package-only.

| Package | Requirement | Resolved | Product |
|---|---|---|---|
| atlyslabs/ATCore | from 1.0.16 | 1.0.16 | ATCore |
| Moya/Moya | from 14.0.0 | 14.0.1 | Moya |
| atlyslabs/ATUIKit | from 1.3.7 | 1.3.7 | ATUIKit |
| atlyslabs/ATMaterialIcons | from 1.0.1 | 1.0.1 | ATMaterialIcons |
| atlyslabs/ATAuthKit | from 1.0.44 | 1.0.44 | ATAuthKit |
| atlyslabs/ditto-migrate-toolkit | from 0.0.1 | 0.0.1 | DittoRuntimeStrings |
| marmelroy/PhoneNumberKit | from 3.6.0 | 3.8.0 | PhoneNumberKit |
| kean/Nuke | from 12.0.0 | 12.9.0 | Nuke |
| PostHog/posthog-ios | from 3.71.0 | 3.92.0 | PostHog |
| googlemaps/ios-places-sdk | from 10.1.0 | 10.15.0 | GooglePlaces |

## Build and test

```sh
cd /Users/aravindh/Desktop/Atlys/AI-Profile
xcodebuild -IDEBuildingContinueBuildingAfterErrors=YES -scheme ATAIProfile \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/aiprofile-dd \
  -skipPackagePluginValidation -skipMacroValidation ONLY_ACTIVE_ARCH=YES ARCHS=arm64 \
  build > /tmp/aiprofile-build.log 2>&1      # add -configuration Release for the Release check
grep -c 'error:' /tmp/aiprofile-build.log

UDID=$(xcrun simctl create aiprofile-test com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro \
  com.apple.CoreSimulator.SimRuntime.iOS-26-5)
xcodebuild -scheme ATAIProfile -destination "id=$UDID" -derivedDataPath /tmp/aiprofile-dd \
  -clonedSourcePackagesDirPath /tmp/aiprofile-dd/SourcePackages \
  -skipPackagePluginValidation -skipMacroValidation test     # -only-testing:ATAIProfileTests/<Suite> for one suite
xcrun simctl delete "$UDID"
```

- Use a throwaway simulator, never the user's booted one. A cold build with package resolution takes about two minutes. Without `-IDEBuildingContinueBuildingAfterErrors=YES`, Xcode stops after the first failing batch.
- Tests are swift-testing. As of 2026-11-05: 342 tests in 50 suites, 339 pass. The `feature/photos-visited-countries` branch adds `ProfileV3PhotoPlacesTests` (18, never run; Done item 176). The same three fail every run:
  - `ProfileV3DestinationTests.theHubOpensALinkOnlyWhileItIsOnScreen` (lines 68–69): a link posted while the hub's tab is hidden still opens. Either `onDisappear` doesn't clear `isSettled` on a tab switch in a test window, or the hidden-tab guard doesn't work. Not investigated.
  - `ProfileV3OnboardingPresentationTests.theHubsOwnSurfaceRunsOnboardingOverTheTabBar` and `aFlowThatClosesItsOwnContainerIsReportedOnce`: the dismissal never completes in a window with no scene. Probably the harness, not the launcher.
- Checking a design against Figma:
  - Render the real view in a throwaway probe test: a hosted `UIWindow` 440pt wide, drawn with `layer.render` at 2–3x. Use `ImageRenderer` when blur matters; it can't draw `ScrollView` content.
  - Download Figma's raster with `download_assets` (`defaultScale: 2`). Measure card-relative ink bands with a small Swift ImageIO script (PIL isn't installed). Delete the probe afterwards.
  - Inter text renders 0.5–1.5pt higher than Figma's; that's systematic, so don't offset single views.
  - `layer.render` draws no blur and a stray straight segment at capsule ends. Animations jump to their end in tests, because the window has no scene.
  - An animated `ScrollViewProxy.scrollTo` never moves in a test window; an unanimated one does. `layer.render` also draws a scrolled page shifted and without its top overlay, and `drawHierarchy` draws nothing, so check scroll positions as numbers (scroll view offsets and frames in window coordinates).
  - To fill a Figma line box, pad the text vertically by `TypographyStyle.<style>.lineSpacingAdjustment / 2`.

## Architecture

### Networking (ATCore)

- `Networking/ProfileV3API.swift` is a Moya `ATCoreTargetType` enum. Its base paths:
  - board `/api/gmail-connector/kyc/v2/board` and KYC `/api/gmail-connector/kyc/v1`;
  - vault `/api/fort-knox/v1`, glove box `/gateway/jaqen/v1`, permissions `/api/harness/v1` and Instagram `/api/snapmap`;
  - plus the Slack alert and the pensieve profile edit.
- Its `baseURL` is a placeholder: ATCore builds URLs from the host's `ATCoreBaseProvider.baseURL`.
- `ProfileV3NetworkClient` (public) wraps `ATCoreRequestExecutor` with the auth plugin, the `x-platform`/`x-app-version` headers and the error-envelope plugin, and decodes responses itself. Its `request`, `requestData` and `perform(_:action:)` refresh the Firebase token and retry once on a 401.
- `ProfileV3APIErrorMapper` maps 401, 409, 422, 501 and 502–504 onto `ProfileV3Error`; a 500 with no envelope `code` gets client copy, never the server's text. The envelope's `code` reaches it through `ProfileV3ServerFailureBox` (see Known trade-offs), and the envelope plugin swaps ATCore's message for the envelope's `message` or FastAPI `detail`.
- Data:
  - `ProfileV3BoardStore` caches in `ATCoreCacheService.persistent` with deterministic keys per user, and its `fetch`/`restore` are `@concurrent`.
  - `ProfileV3LiveRepository` is the real implementation.
  - `ProfileV3MockRepository` (DEBUG stores and fixtures) backs previews and tests, and `ProfileV3FailingRepository` exists for error states.

### Host seams (`Sources/ATAIProfile/Host`)

- Registration: `ProfileV3Runtime.registerConfigurationProvider` takes an `ATCoreBaseProvider` that also conforms to `ProfileV3SessionProviding` (`currentUserID`, `isGuestSession`, residency). `registerHostActions(ProfileV3HostActions(...))` takes the hosts below. Every entry point stops with `preconditionFailure` until both are registered.
- Hosts:
  - `ProfileV3KYCHost`: onboarding, minimal capture, the four step screens, Gmail auth, `track`. From the hub surface, onboarding is presented full screen by `ProfileV3OnboardingLauncher`.
  - `ProfileV3IdentityCaptureHost`: the passport rescan.
  - `ProfileV3GlobeRendering`: land drawing only; the package owns the pose, projection and globes.
  - `ProfileV3AccountHost`: name, residence, citizenship and contact. The contact save and the residence push send its `selectedTravellerID`, else the board's main `profile_id` (`ProfileV3SettingsDependencies.travellerID`); Ayl's host sends none.
  - `ProfileV3CouponsHost`.
  - `ProfileV3AppHost`: logout, flash, restart, floating-bar clearance, `opensChat`/`openChat(prompt:)`.
  - `ProfileV3InviteHost` (optional): the invite code sheet.
  - Also: the analytics reporter, the field validator, the country list and the optional `placesAPIKey` (the city hotel search; `ProfileV3Environment.placeSearch` is nil without it).
- Entry points (`ProfileV3EntryPoint`): `makeHub`, `makeHubSurface`, `presentAddTraveller`, `prefetchBoard`, and `open(_:)` for deep links (`ProfileV3Destination`).
- `AppIntegration/ProfileV3Host` holds the vdcios implementations (`VDCProfileV3Composition.configure()` plus one file per host). They are copied into `vdcios/VDCApp/Modules/ProfileV3Host` and aren't compiled here. Ayl's hosts live in AI-Native.

### Strings (Ditto)

- Client copy comes from the Ditto project `ai-profile` (`mo-aiprofile-*`) and mirrors the library folder `profilev3strings` (keys without the prefix, in subfolders `account-settings`, `agents`, `general-ui`, `glovebox`, `loyalty-programs`, `travel-documents`). Project items are standalone copies, so every create, edit or delete goes to both (`/v2/components` and `/v2/textItems`). Server copy is the backend's `ai-profile-board` (`be-aiprofile-*`); leave it alone.
- `Resources/ProfileV3Localizable.xcstrings` and `Generated/ProfileV3L10n+Generated.swift` are generated by the toolkit; code reads them through `ProfileV3Strings`, `ProfileV3GloveBoxCopy` and `ProfileV3VaultStrings`. Rebuild from Ditto (the token isn't stored anywhere; keep `DIST_DIR` out of the repo):

  ```sh
  PLATFORM=ios DITTO_TOKEN=… RUN_SCAN=no PROJECT_ID=ai-profile \
  RESOURCES_DIR=Sources/ATAIProfile/Resources XCSTRINGS_NAME=ProfileV3Localizable.xcstrings \
  GENERATED_DIR=Sources/ATAIProfile/Generated SWIFT_OUT_NAME=ProfileV3L10n+Generated.swift \
  ENUM_NAME=ProfileV3L10n LOOKUP_FUNCTION=ProfileV3DittoRuntimeStrings.lookup DIST_DIR=<scratch>/Dist \
  bash /tmp/aiprofile-dd/SourcePackages/checkouts/ditto-migrate-toolkit/Scripts/ditto-pipeline.sh --skip-scan < /dev/null
  ```

  The toolkit's Python helpers (`ditto_copy_folder_to_project.build_item`, `ditto_check_component_issues.py profilev3strings`) sit next to it. Calls that worked on 2026-10-31: `POST /v2/components {components}`, `POST /v2/textItems {projectId, textItems}`, `PATCH /v2/components` and `PATCH /v2/textItems` with `{updates: [{developerId, text}]}`, `DELETE /v2/textItems {projectId, developerIds}`, then `DELETE /v2/components {developerIds}`. Library folders: `profilev3strings` and its six subfolders; a key's folder follows its first segment (`agent-settings-*` goes to `agents`, `documents-*` to `travel-documents`). Count variables use the existing `count` variable (`{{count}}`, exported as `%1$@`).

- To add a string:
  - In Ditto: create the component first, named as its id in title case, with the catalog comment as its notes and a tag only for buttons, input labels and empty, error or success states. Then create the project item from it.
  - Without a token: hand-add the key in the toolkit's format. The catalog round-trips through `json.dumps(indent=2, ensure_ascii=False)`, and the generated accessor goes right after the accessor of the key before it in sorted order. Record that Ditto owes the key (see State).
- To delete a string: `DELETE /v2/textItems` (project), then `DELETE /v2/components`, then rebuild.
- Ditto quirks:
  - Its iOS export turns `’` into `'`.
  - Pieces that code joins into one line are stored without the joining space.
  - Variables export as `%1$@`; check the `fallback:` for the argument order.
  - `ditto_check_component_issues.py` flags `(180cm)` falsely.

### Conventions

- No comments in `Sources`, `Tests`, `AppIntegration` or `Package.swift`, except `// MARK` lines and SwiftGen's own output. Type names carry the `ProfileV3` prefix.
- Client configs the user asks for live in `Support/ProfileV3FeatureFlags.swift` (values in State).
- Show server labels as sent: a label the server can send isn't given a client fallback, and the element hides without it. Client copy covers errors, toasts, accessibility, input placeholders and static headers.
- Theme (`ProfileV3Theme`): each colour is defined once, using the ATUIKit colour where one matches. Spacing, radius and control tokens use the shared scales. There is one soft shadow, motion uses named curves, and opacities live in `Opacity`.
- Reuse the shared pieces before building new ones:
  - sheets: `profileV3Sheet`, `ProfileV3SheetChrome`, `ProfileV3AgentSheetChrome`, `ProfileV3SheetSlot`;
  - bars and buttons: `ProfileV3SaveBar`, `ProfileV3SubmitControl`, `ProfileV3InkPill`, `ProfileV3IconPillButton`, `ProfileV3SaveButton`, `ProfileV3ContinueButton`;
  - scrolling and loading: `ProfileV3FadingScroll`, `ProfileV3ScreenLoader`, `ProfileV3PhasedLoad`, `ProfileV3SavePhase`;
  - cards and decoration: `profileV3AccessCard`, `ProfileV3FadeBand`, `ProfileV3Rule`/`ProfileV3DashedRule`, `ProfileV3RainbowGlow`;
  - small pieces: `ProfileV3CountryFlag`, `ProfileV3CopyButton`, `ProfileV3ErrorText`, `ProfileV3TagLabel`, `ProfileV3SegmentTrack`.
  - motion: `ProfileV3Keyframes` plays a Figma keyframe track (holds, per-segment `UnitCurve`s) from a `TimelineView`'s elapsed time.
- Analytics events (`Support/ProfileV3Analytics.swift`) follow the spec agreed on 2026-10-27: no default properties, personal data as specified. Tests record through the `@TaskLocal` `ProfileV3Analytics.scopedReporter`.
- Session replay: views with personal data use `.postHogMask()`.

## State (2026-11-05)

### Release

- `master` is at `95e54c5` (Instagram motion, the split Connected panels, the connected Instagram row and the return after a panel edit, the glove box's Gmail route, source icons, and the city profile's sticky tabs with the highlight that follows scrolling), one commit ahead of `origin/master` at `6471164` (the travel persona ring) and not pushed. `6471164` is on `f97c8dc` (the plug icon on the connector deck), `75a363c` (travel persona analytics), `723ffb1` (city profile behind its flag, the contact save fix, and the Settings debug City profile row that replaced the KYC state menu) and `64506d3` (benefit Learn more, the long Instagram handle fix and QA-2007), all pushed outside this session. `1.0.23` is on `e434d81` (Manav's Support row routing) and `1.0.22` on `8cc91dc`; nothing after `e434d81` is tagged.
- Uncommitted: the city profile's live wiring to `vdc-k8s#24000` (2026-11-05 evening; see Backend contracts and the City profile decision), server-driven agent tiles (the city flag is gone; see Product decisions), and the city hotel search on Google Places (see the City profile decision). Full suite 339/342 (the known three) and a Release build pass; nothing ran against the real backend or Google Places.
- Tags `1.0.0` and `1.0.2`–`1.0.23` are on GitHub; `1.0.1` is local only. Tags are often cut straight from a commit with no release commit. When that happens, move the tag's "Unreleased" body into a `## <version> — <date>` section and keep only later changes under Unreleased (done for 1.0.17, 1.0.20 and 1.0.21; not yet for 1.0.22 and 1.0.23).
- `README.md` still says "Version 1.0.1".

### Feature flags (`ProfileV3FeatureFlags`)

| Flag | Value | Gates |
|---|---|---|
| `isBenefitRedeemEnabled`, `isCouponRedeemEnabled` | false | Benefit and coupon redeem |
| `isPassAddTravellerEnabled` | false | Adding a traveler from the pass |
| `isProgrammeInsightContinueEnabled` | false | The insight's Continue into the flight agent; a chat prompt opens chat regardless |
| `isConnectOtherEmailsEnabled`, `isITRDisconnectEnabled` | false | Connecting other emails; disconnecting ITR |
| `isAgentSourcesPillEnabled` | false | The sources pill in agent form headers |
| `isProgrammeScanLoaderEnabled` | false | The programme scan loader |
| `isPersonaEditingEnabled` | true | Dragging persona knobs (autosaves on release) |
| `isAppAccessEnabled` | true | App access (false shows "Coming soon") |
| `isAppAccessOtherAppsEnabled` | false | Apps other than Instagram (DEBUG demo data) and "+ Add new" |
| `isAIConnectorsEnabled` | true | The AI assistant rows the overview sends |
| `isVaultRecentSignInCheckEnabled` | false | The vault's 10-minute sign-in check before enrolling a phone |
| `isGlobeEnabled` | true | All pass globes |
| `isGlobeRimEnabled` | false | The lit rim around globes |
| `isFloatingControlGlassEnabled` | true | iOS 26 glass on floating controls |
| `isCredentialStoreEnabled` | true | The Secure credential store card in Settings |
| `isEmptyProgrammeSlotEnabled` | false | Grey empty slots on the pass back face |
| `isGloveBoxPhoneNumberEnabled`, `isGloveBoxVirtualCardEnabled` | true | The glove box Phone and Virtual card sections |
| `isGloveBoxCardTransactionsEnabled` | false | The virtual card's transactions and View all |
| `isAgentCustomRulesEnabled` | true | Custom rules on agent forms |
| `isPassportBackPageEnabled` | true | The FRONT/BACK passport row |

### Backend contracts

- City profile (Abhishek, 2026-11-05; `vdc-k8s#24000`, merged 2026-11-05; needs ai-memory's `city_profiles` table deployed before ai-kyc):
  - Tile: an agent tile `{agent_type: "city", icon: "orb_city", next: {go: "city_profiles", profile_id}, activate?}` before Travel persona. No art exists for `orb_city`.
  - Screens (`GET` under `/board/cities`): intro `?profile_id=` (portholes, `add`, `headline`, three static samples); picker `/search?profile_id=&q=&offset=` (pages of 20, `q` echoed, `next_offset` null at the end; the client debounces 250 ms and drops a reply whose `q` isn't the current text); purpose sheet `/purpose?code=&profile_id=` to add, `?code=&city_id=` for the pencil; city `/{city_id}?profile_id=`; card history `/{city_id}/sources/{field_key}` (the sources sheet shape).
  - Purpose sheet: home, work and leisure once each per traveller (`disabled`); `other` takes a name (`input`, max 30), unique ignoring case and spacing, checked against `used_labels` while typing (`label_taken` inline). Writes echo `submit` with `purpose` and `label`: `create_city_profile` replies `{city_id}`, `update_city_purpose` too; the pencil's `delete` (`delete_city_profile`) carries `confirm {title, body, confirm_label, cancel_label}`. Errors come with ready messages: 409 `purpose_taken`/`label_taken`, 422 `label_required`/`label_too_long`/`unknown_city_code`, 404 `unknown_city`, 503 `city_profiles_unavailable`. The same city can be added again with another purpose.
  - City screen: `purpose` (with `edit.next`), `found {count, total, label}`, `sources {count, label, icons}` (no `next`, so the summary isn't tappable), `tabs`, six cards and `custom_rules`, and `save {action: save_city_preferences, city_id}`. Cards are agent fields plus `subtitle`, `footer`, `icon {active_url, inactive_url, active}`, `found`, `layout` (`chips_with_icon` with `add` = logo chips, without = the timing orbs; `tiles` = class with `image_url`/`selected_image_url`, empty for now; `chips`; `rows` = hotels), `add {search: airlines|client_hotels}`, `optout {key, label, value}` and `source {count, icons, next: {go: city_preference_sources}}`. Every card sends `tab` as an object, so the agent field DTO's `tab` (the baggage tab title) is lossy.
  - Hotels are `input: "free_list"`: a list of one-line names (`max_items` 20, `max_chars` 120). `add.search: "client_hotels"` means the app searches hotels itself (Ashish: "a general search using the Places SDK"); see the City profile decision.
  - Save sends the complete city (`ProfileV3CitySubmission`): every card's list, each opt-out key as a bool, and `custom_rules`.
- Board: home, settings, agents, loyalty, past trips, travel persona, passports and AI connectors. Writes go to `/board/submit` and echo the served action object.
  - Past trips are country-only; several countries go as one `countries` list.
  - Loyalty edit (`vdc-k8s#23247`, 2026-10-26; ai-kyc is deployed, ai-memory's `PATCH /profile/loyalty` deploy wasn't confirmed):
    - `GET /board/loyalty/edit/{program_id}?profile_id=` (slashes in the id kept) returns the enter-details form with each field's saved `value`: "EDIT DETAILS", "Save", and an optional membership number.
    - `edit_loyalty_program` changes only the fields sent; `null` clears one, and `tier: "unknown"` clears the tier.
    - The form's `program_id` is the catalogue id, and the save must send it. A Gmail-found programme's row id is its name, and an edit can change that row's id.
  - Loyalty tier (same PR): for a programme with a tier list (never cards), the add and edit forms serve `tier` (`single_select`, tiers lowest first, then `unknown` = "I don't know") and `tier_valid_until` (`month_year`, placeholder `MM/YY`).
    - `add_loyalty_program` and `edit_loyalty_program` take both. `unknown` or no tier saves none, and a blank month with a tier means 12 months from today (UTC).
    - In an edit, a sent `tier` resets the month to the sent one (or that default). A month sent alone keeps the saved tier, and a blank one is ignored.
    - 422 `kyc_invalid_request` with "Pick a tier from the list." or "Enter the month as MM/YY, this month or later."
  - The personal agent's `passport_empty` shows the placeholder card, and the passport card's `father`/`mother`/`spouse`/`address` keys feed the back page.
  - An agent tile's ring follows its `updated_label`: blank shows the gradient arc with "+", any text shows the green ring. ai-kyc sends the label once the traveller has saved that agent (`agents_meta` in `api/board.py`), but `travel_persona.grid_tile` hard-codes `""`, so the persona tile never turns green.
  - AI connectors: `settings/connectors/ai/{connector}` and its `/connect`, saved with `connect_ai_connector`. Its `synced_at` comes as Python `isoformat()` (microseconds, `+00:00`).
  - Custom rules are the agent screen's `custom_rules` field and save with the agent.
  - Benefit detail (`GET /board/benefits/{id}`) can send `learn_more: {label, next: {go: "ai_chat", prompt}}`. Only a label with an `ai_chat` prompt is kept (`ProfileV3BenefitLearnMore`).
  - Agent fields from `vdc-k8s#23629` (deployed 2026-10-31):
    - Flight `avoid_airlines` is `multi_select_add` with the airline options.
    - Flight `time_value_per_hour` is a slider with `display: "money"`, `currency {code, symbol}` and `unit: "/hour"`. Its track follows the residence's currency, and its `value` is `null` until set.
    - Stay `hotel_class` is `single_select` with `{value, label}` options.
    - Stay `preferred_hotels` has 100 groups with logos.
    - The field's `assist` is the subline under the control.
  - Source icons (Abhishek, 2026-11-05; `vdc-k8s#23991`, merged 2026-11-05):
    - A field's `source` is `{icon, icons, next: {go: "preference_sources", agent_type, field_key, profile_id}}`. `icons` lists one URL per kind of source, in this order: Gmail, you (`kyc/you.png?v=1`), then each AI assistant's Connectors icon. `icon` equals `icons[0]`. It shows on any field with a history.
    - The sources row draws every icon (`ProfileV3SourceIconStack` `.logo`). The header pill's `.badge` keeps its two-icon cap. The sources call sends `next.profile_id` when present (`ProfileV3SectionSource.profileID`), else the form's traveller.
    - The icons don't share a style: Gmail's is a bare 22pt logo, while you and the assistants send whole round badges (#EFEFEF tile, black ChatGPT disc). Spidey Sense rows (`ProfileV3PersonaTrait.Row.iconURL`) therefore draw by `kind`: a `gmail` row's icon sits on the grey tile at the Gmail glyph's size, and any other row's icon fills the 48pt tile. Without `icon`, rows draw the local art as before.
    - The sources sheet's steps have no `kind`, so it still draws every icon at 22pt on its tile, and the you and assistant badges show small there. Open with BE: send `kind` on steps, or a Gmail badge, so every icon can fill its tile. Never match on the URLs.
    - A stored value with no matching chip arrives as an extra option with `selected: true`, and shows as a selected chip with no client change.
  - Food `dietary_style` (same day, corrected the same evening): `single_select` with a new first chip "Non-vegetarian"; one diet, no "+ Add". The client already draws it as choose-one chips; a diet saved earlier that isn't a chip comes as an extra selected option.
- Vault (fort-knox): a login is sealed with AES-GCM under a key wrapped by the server's RSA key (OAEP-SHA256). A reveal opens an ECDH/HKDF box with the phone's Keychain key after Face ID.
- Glove box (jaqen): `/me`, `/messages` (status, attention, action, sender logo) and the forwarding endpoints.
- Permissions (harness): `GET /permissions` and `PUT /permissions/{key}` `{value}`.
- Instagram (snapmap):
  - Read with `GET /instagram/accounts?user_id=`; link with a `POST` of `{username, user_id}`. `user_id` must be the signed-in Firebase uid.
  - A 409 means the username is linked to another account.
  - The link counts only once that account has DMed @ayl.chat, and there is no unlink endpoint.
  - The link's upsert needs snapmap migration `043_social_account_username.sql` (`vdc-k8s#23612`), applied by hand outside staging. Without it, `POST` returns 500 `{"detail": "Internal server error"}` (QA-2042, 2026-11-02; the environment wasn't confirmed).

### Product decisions that constrain changes

- One package serves two hosts, Ayl and the Atlys app, so catalog copy shows in both. Six strings now say "Ayl".
- Agent tiles are server-driven (user, 2026-11-05: "there shouldn't be any client update if any of the agent is added in future"). The grid shows every tile the board sends, and `go: agent` opens the generic agent screen (`/board/agent/{agent_type}`) for any `agent_type`, known to `ProfileV3AgentID` or not. A tile's `icon` is a URL, or an `orb_<name>` token that resolves to `ik.imagekit.io/atlys/b2c/profile-v3/agent_<name>.png`; upload new art there under that name. The seven current agents have art; `agent_city.png` is missing, so the city orb is blank. A new `go` value still needs client code for its screen; until then the tile shows and a tap does nothing.
- App access in release lists only Instagram. Its waiting-for-a-DM card follows Figma `6595:16405`. A long handle is cut short with an ellipsis so the action stays on one line (grukhs, 2026-11-04); `ProfileV3ConnectorAction` never wraps.
  - Once connected (snapmap's `dm_connected`), Instagram stays in the list as well as under CONNECTED (user, 2026-11-05). Otherwise the release page is empty below the heading, since Instagram is its only app. The row is `listedConnectedApps`, drawn like the auto-connected row: logo, @handle and a green `connectorConnected`. Other connected apps leave the list, as in Figma 1917 (`3338:12183`).
- Instagram motion (Vijay's design gaps, 2026-11-05; the user: "two animations - one is as it's there and the new addition is when send message is clicked"):
  - The connect sheet opens on an intro, Figma `6595:15220`: reels fly into map pins, then a place card pops up. It plays once (3.4 s), holds 1 s (the frame's note), then shows the explainer, which now moves on after 7 s (was 15). Taps skip ahead. Reduce Motion shows the designed still.
  - "Send a message" plays Figma `6595:14302` over App access (`ProfileV3InstagramRedirectOverlay`, the orb assembling from 44 particles) and opens `https://ig.me/m/ayl.chat` when the 2 s assembly ends. The redirect after linking stays in the sheet, unchanged.
  - Both run on `ProfileV3Keyframes` tracks (Figma's keyframes and curves, `Motion.fastOutSlowIn` for cubic-bezier(0.4, 0, 0.2, 1)) evaluated in a `TimelineView`; the geometry tables are in `Theme+InstagramConnect`.
  - Not matched: the 2pt backdrop blur under the overlay's white fade isn't drawn, and the wash keeps the sheet's top-to-bottom `instagramFollowWash` (the frame's is 195°). The shared `ProfileV3AylOrb` draws a white mark where `6595:14302` shows a lime one. The intro's shield and title sit at the shared sheet positions, 7pt above the frame, like the other steps.
- Connected panels (Vijay, 2026-11-05): App access's Connected opens only the connected apps (route `.connectedApps`) and shows only once an app is connected; Information access's opens only the email connectors (`.controlPanel`). They used to share one deck.
  - A successful edit from the apps panel pops back to App access once the edit sheet has closed (`editorDidDismiss`, chained through the sheet's `onDismiss`) (user, 2026-11-05). An Instagram relink resets `dm_connected`, so the panel used to sit empty. Closing the sheet without saving stays on the panel.
- Vault:
  - Opening it with Face ID covers reveals until it is closed or the app goes to the background.
  - Saving a login only calls the API, and the sheet's fields aren't tagged as a username and password, so iOS doesn't offer to save them.
- The glove box opens from the Settings card. Without KYC it shows the locked intro, even when Jaqen already has an address (QA-2007, 2026-11-04): Jaqen's `/me` doesn't check KYC (`eligible` is always true), so the client check is the board's main-traveler `kycStatus`.
  - Its "Complete KYC" starts Gmail linking, the `gmail_connect` connector capture (Vijay, 2026-11-05: "for glove box we need to redirect to email linking flow, not all KYC flow"), not onboarding. If KYC is incomplete for another reason, linking Gmail alone may not unlock it; the capture continues with whatever step the server returns.
  - `ProfileV3SettingsViewModel.isMainTravellerKYCComplete()` uses the cached board only while it is younger than `ProfileV3HubViewModel.staleBoardAge`, else `loadLatestBoard()`. A failed fetch falls back to the cached board, then to unlocked.
  - The glove box runs that check alongside `/me` on every load. The Settings card's ACTIVATE pill shows for no address or no KYC.
  - An empty inbox shows one sample email. The virtual card shows the main traveler's short name and digits derived from the address.
- Travel persona: the delight loader shows for the first five loads, and a drag saves on release. Its edits report as `profile_agent_preference_changed` (`travel_person_agent`, the trait as `sectionName`): a knob change as it is submitted, with the score, and a trait-screen action after it succeeds, with the server action name (2026-11-04, aadi's report of 2026-10-30). It sends no `profile_agent_form_saved`, since it has no Save. After the first saved knob change or trait action the tile counts as saved, like the other agents (user, 2026-11-04): each success calls the hub's `travelPersonaSaved(profileID:)` through `makeTravelPersona(onSaved:)`, which refetches the board and records the traveller in `ProfileV3HubHints.personaSavedProfileIDs`. `ProfileV3HubViewModel.agents` shows a persona tile with no label as saved for those travellers; the grid reads it instead of `home.agents`.
- Loyalty edit (user's call, 2026-11-01):
  - It starts from an "Edit" pill on each card in the programmes edit mode (the delete selection), where "View insight" sits.
  - It reuses the add flow's details sheet: `ProfileV3AddProgrammeViewModel(editing:)`, which skips the loader, back button and step dots.
  - Save turns on after a change and sends only the changed fields. The tier and its month always go together, so a new tier keeps the saved month.
- Loyalty tier fields (2026-11-01, no Figma): the dropdown is `ProfileV3MenuField`, a native `Menu` drawn with the picker field's row (`ProfileV3PickerFieldRow`, "Select" placeholder). The month field formats `MM/YY` as you type (`ProfileV3MonthYear`). A complete but unreadable or past month shows an inline error, and any bad month blocks saving, but only when the month would be sent (with a real tier; in an edit, only when the tier fields change).
  - The pill sits inside the row's selection button: the tile turns off its face's hit testing for `Pill.edit`, and VoiceOver gets an Edit action on the row.
- Benefit Learn more (2026-11-04, Figma `5648:13079`): the detail's footer shows it only when the host opens chat. A tap closes the detail and the benefits list, then opens chat through `afterOverlaysClose`, once the hub's cover is down. With "Got it" or "Redeem" it stacks on top (no design for both).
- City profile (2026-11-04, Figma `6592:8147`, `6739:7548`, `6739:8232`, `6739:15148`, `6739:16063`, `6805:7626`, `6766:17091`, `6766:17366`, `6766:18995`, `6739:16294`, `6805:7463`):
  - Each city's preferences are a `ProfileV3AgentForm` edited by `ProfileV3AgentFormViewModel` (one per city, kept while dirty), so pickers, sources, custom rules and the save bar match the agents. `ProfileV3CityAgentRepository` sends its saves and source loads to the city.
  - The intro's portholes come from `GET /board/cities`; selecting one loads its screen (`ProfileV3CityProfileViewModel.screens`, with its own load state and retry), and a save reloads it. Purpose chips, tab icons and the sample deck draw the server's icons as tinted templates (`ProfileV3RemoteImage(tint:)`, the PNGs are grey glyphs); card notches draw `icon.active_url`/`inactive_url` as sent, picked by the card's live value. Logo chips show only selected options and a tap removes one; hotel rows open the picker. An opt-out dims the section but keeps its chips.
  - The picker sheet closes before the purpose sheet opens (chained through `onDismiss`). "Other" moves to the name step on the same sheet; Back there with no name cancels the choice, and Back on the first step cancels the add. Delete confirms in a fitted sheet over the purpose sheet.
  - Class tiles fall back to the bundled seat art (`ProfileV3SeatArt(optionValue:)`) while the server's images are empty; timing chips draw the server's orb, dimmed when unpicked, with a tick (dark on "Morning").
  - The tab strip is sticky (user, 2026-11-04; Figma `6739:16294` has no pinned state): the in-page strip reports when its top reaches `Sizes.City.pinnedTabsTop` (under the back button), then hides while the header draws a copy on a solid band with a 16pt fade. A tap scrolls to `sectionAnchorID(section)`, a clear view `sectionScrollInset` tall above each card, so the card lands under the pinned strip.
  - The highlighted tab follows the scroll (user, 2026-11-04): each card reports when its top passes `sectionReachedLine` (8pt below the pinned strip), and `sectionReached` highlights the last tabbed section past it, else none (the first tab shows). For `cityTabFollowPauseSeconds` after a tap, crossings are recorded but don't move the highlight, so it doesn't step through the sections in between; a tap on a section that can't reach the strip keeps its highlight until the next crossing.
  - Not matched: Host Grotesk (city codes, intro title) isn't bundled, so Inter Medium stands in; Figma's `eraser_size_1` is Material `edit`; the plane-window and deck blurs can't be checked in probes. The seat art is cropped from the two sprite frames (`6736:5443`, `6736:5447`) into `profile_v3_seat_*`.
  - Hotel search (user, 2026-11-05: "check for onboarding flow, whether they have this handling, if you find that - need to handle it here too"): the hotels picker searches Google Places as AI-KYC's `KYCAddressPlacesService` does, through `ProfileV3PlaceSearching` (`ProfileV3GooglePlaceSearch`). It runs only when `TypedEntry.search` (the city's name and `country_code`) is set and the host passed `placesAPIKey`; otherwise hotels are typed only ("+Add …").
    - Request: legacy `findAutocompletePredictions` (KYC's call; the new `fetchAutocompleteSuggestions` needs Places API (New) on the key, which nobody confirmed), `types = ["lodging"]`, `countries = [country_code]`, the city's name appended unless typed, 300 ms debounce, up to 8 results.
    - Only the name is saved, and a prediction's primary text is the place's name, so there's no session token and no place details call (a session that ends without details bills per request anyway).
    - The list: saved hotels that match the text first, then suggestions, deduped by name ignoring case and spacing. A suggestion whose name is already saved takes that option's id, so picking one checks it in place. "+Add …" goes last while searching.
    - Keys: Ayl must pass `AppSecrets.googlePlacesAPIKey` (the key it gives KYC in `KYCFeature`); `AppIntegration`'s vdcios composition passes `AppConfiguration.shared.googleMapsSDKAPIKey`. `GMSPlacesClient.provideAPIKey` runs once per process; KYC and vdcios's AppDelegate call it too, which the 10.x docs allow.
- Agent sliders:
  - A slider whose server value is `null` saves `null` until it is moved, or until "rather not say" is turned off (`ProfileV3SliderField.isSet`). It still shows its midpoint.
  - Money values read as symbol + compact amount + unit (`₹10K/hour`; a letter symbol gets a space: `AED 50/hour`).
  - The Figma mock puts the assist under the heading and writes "₹ 10K"; the app keeps the assist under the control and follows the spec's "₹10K".

### Ditto

- In sync as of 2026-10-31. Ditto's project and library hold the catalog's 413 keys with identical values, and the catalog and generated Swift were rebuilt from Ditto by the pipeline. The rebuild is in `2ad3c52`, which is the comparison base for later drift.
- Ditto owes hand-added keys (catalog now 421):
  - 2026-11-01: `mo-aiprofile-loyalty-error-tier-valid-until-invalid` ("Enter the month as MM/YY, this month or later.", folder `loyalty-programs`, error tag).
  - 2026-11-04, City profile, folder `agents`: `mo-aiprofile-agents-header-city-profile`, `-header-add-city-profile`, `-accessibility-add-city`, `-accessibility-edit-city-tag`. Three more (`-label-city-tag-count`, `-loading-city-updating`, `-accessibility-delete-city`) were dropped on 2026-11-05 when the live wiring made them unused; they never reached Ditto.
  - 2026-11-05, Instagram intro, folder `agents`: `mo-aiprofile-agents-title-instagram-reels-plan`, `-label-instagram-sample-place`, `-label-instagram-sample-place-detail`.
- That sync, at the user's request:
  - added the 44 hand-added keys that are in use;
  - pushed the 6 local value edits (the Atlys → Ayl copy and the "How you pay" text);
  - deleted the 16 unused keys from Ditto;
  - dropped the 7 unused hand-added custom-rule keys.
- No accessor name, signature or value changed. The toolkit check flags only the known `(180cm)` false positive. With the rebuilt files the suite (bar the known three) and a Release build pass.
- To find drift later: compare the catalog with the base commit's catalog. A key is unused when nothing in `Sources` or `Tests` references its generated accessor; match generated `static func` accessors across lines, because strings with variables are functions.

### Unverified (needs Ayl or a device)

- Saving a vault login shows no iOS "Save Password" sheet.
- Instagram linking against snapmap in production, and the waiting card in Ayl.
- The Instagram intro and Send a message redirect running on a device: probes checked frames rendered at fixed times and the overlay's layout (within 0.5pt of `6595:14302`), not the `TimelineView` playback, the blurs or the hand-off to Instagram.
- KYC onboarding presented full screen over Ayl's tab bar.
- Loyalty edit and tier on a device against production: that the Edit pill takes the tap rather than the row's selection button, that the tier `Menu` opens from inside the sheet window, and that a saved edit or tier shows after the reload.
- QA-2008 fixes on a device: the AI connector prompt scrolling inside the sheet's own scroll view, and the Instagram explainer's green wash without Figma's noise.
- Benefit Learn more in Ayl opens chat, but the chat then freezes (see Open work).
- QA-2007 against the backend: that the board reports KYC not done right after a Gmail disconnect, so the glove box locks.
- City profile against the live backend (the hub's tile, or Settings' debug row in DEBUG): every screen and write, the 409/422 messages, paging and the stale-reply check, and that the hotel card's typed names save. Also in Ayl: the sticky tab strip and its animated scrolls (a probe checked positions with the scrolls unanimated), the carousel's selection and side-window scaling, the chained picker → purpose sheets, the fitted purpose sheet with the keyboard, the deck and ring animations, and the window and deck blurs.
- The city hotel search against Google Places with each host's key: lodging results in the city, the country filter, and the key's API restrictions.
- Motion that tests can't show: the save button's entry and exit, the persona loader's haptics, the glove box entrances, the hero and globe transitions.

### Open work

- Benefit Learn more freezes chat in Ayl (Vijay, 1.0.1 (32), 2026-11-05; reproducible). The profile side completes: the cover closes and `openChat(prompt:)` runs. The 15:04 watchdog report of 2026-11-04 (build 30, `0x8BADF00D`, failed to terminate in 5 s) caught the main thread looping in AI-Chat's transcript: `AICTranscriptView`'s content-end preference calls `ChatScrollController.contentChanged(end:)`, which writes the observed `markerContentEnd` during a render and schedules another. Likely trigger: `ChatDeepLinkView` sends the prompt on boot while its sheet is still presenting. The fix belongs in AI-Chat; nothing to change here. Build 32 was built from local `../AI-Chat` (`feat/browser-session-card`) and `../AI-Profile` (Ayl's working tree overrides the 1.0.23 pin). Confirm with Crashlytics (user ID `wHiPLaavFHdJSROXCPYEZuZey8z1`).
- QA-2007 (glove box KYC lock) is fixed in `64506d3`, pushed but not tagged.
- Travel persona analytics (aadi, 2026-10-30): fixed in `75a363c`, pushed but not tagged; Ayl needs a tag with it.
- Source icon follow-up with BE (2026-11-05, see Backend contracts): send `kind` on the sources sheet's steps, or a Gmail badge, so every icon can fill its tile.
- Travel persona ring (2026-11-04, `6471164`, pushed but not tagged): the client marks the tile saved on this device after the first save. That marker is device-local, so a reinstall or another device shows "+" again. BE owes a sticky "saved" signal: `grid_tile` should send `be-aiprofile-board-updated-label` once the traveller has saved a score or ignore action. Persona `user` rows can disappear (a drag back merges to zero), so it needs its own marker. Android needs the same refetch after a save; its screenshot showed the bug.
- Contact save in Ayl (2026-11-04): every tag up to `1.0.23` takes the traveller only from the host, and Ayl's host sends none, so Confirm fails before `PATCH /api/pensieve/v1/profile/edit` and plays only the error haptic. Ayl pins `1.0.20`. The board fallback (`ProfileV3SettingsDependencies.travellerID`) is in `723ffb1`, pushed but not tagged; a probe confirmed it sends the PATCH from a cached or refetched board. Ayl needs a tag with it.
- QA-2008 (2026-11-02): QA-2009, -2011, -2043 and -2050 are fixed in `a53e774` (pushed, not tagged). QA-2042 needs snapmap migration 043 on the environment QA tested; the app now shows client copy for that 500.
- vdcios integration:
  - Pin a version instead of `branch: master`.
  - Check that CI's Xcode supports tools 6.4; if it's Xcode 26, lower to 6.2.
  - Move `VDCAppTests/ProfileV3MapperTests.swift` (69 tests, on `feature-profile-ai`) into the package.
  - Delete the unlinked `Modules/ProfileV3`.
  - The vdcios hosts don't implement `ProfileV3InviteHost`.
  - `VDCProfileV3KYCHost.startOnboarding` asserts on `AVNavigationViewController`, so onboarding from `makeHubSurface` fails there.
- Ayl follow-ups, open as of 2026-10-28 (verify first):
  - Drop `addsPastTripsWithoutDate` from `AYLProfileV3AppHost`; nothing reads it.
  - `AYLProfileV3AppHost.showStatusMessage` only logs, so a failed settings save (contact, residence) shows nothing in Ayl beyond the error haptic.
  - Pass `actionSource: "profile_card"` in `openChat` once AI-Chat releases its `feat/deeplink-action-source` branch.
  - Release AI-KYC's `KYCITRConnectScreen`.
- Decisions pending:
  - Move Identity Capture into the package by depending on `ATCaptureKit` directly.
  - Settings status messages in Release (`FlashMessageGenerator` is DEBUG-only).
  - The README version line.
- Reuse audit leftovers:
  - Left on purpose: AddProgrammeView's own load states, non-white fades, two non-backdrop materials, and the rainbow near-copies.
  - Possible: `ProfileV3LossyDTO` triples as a property wrapper.
  - Bugs: `ProfileV3GloveBoxViewModel.loadTask` is reassigned without cancelling the previous task, and `PhoneCodeResolver`'s residence is a global with no lock.
  - Waiting on design: the three failure styles, the dark pill shadows and fills, the two ACTIVATE fills, the KYC overlay glow, and contact info's phone row.
- GPU, profiled 2026-10-27 on an iPhone 15 Plus:
  - At rest, the card globe is all of Ayl's GPU (about 4.5ms a frame at 24 fps), and the card hover is most of backboardd's.
  - Options, undecided: drop the card's `landTint`, spin at 12 fps, Metal point sprites, or a still card globe. The hover's offscreen pass is still to find.
  - Ayl's PostHog screenshot replay costs about 0.5s of CPU per second.
- Hub board freshness (found 2026-11-01):
  - The pass back face shows `pass.programmes`, which is the profile's `loyalty_card.programs` in the hub's own `/board`.
  - Fixed in `2ad3c52`: `ProfileV3HubViewModel.refreshIfStale(now:)` runs on every appearance (via `loadIfNeeded`) and on `willEnterForeground` while the hub is on screen (`isSettled`).
    - It first shows a newer board another screen put in `ProfileV3BoardStore` (`cachedBoardFetchedAt`, no network).
    - If the shown board is older than `staleBoardAge` (60 s), it refetches with `loadLatestBoard()`.
    - There is no spinner, and a failure stays silent. This replaced the one-shot `needsRevalidation`.
  - Still open:
    - Closing the programmes page after only viewing it doesn't refresh the hub; that page loads `/loyalty/page/{id}` itself.
    - The KYC sync stops polling when the KYC steps clear, so a Gmail import that lands later shows only on the next stale refresh.
- Loyalty edit leftover: the insight screen's `edit` button (`program_insight.edit` → `loyalty_edit_details`) isn't decoded or shown.
- City profile: wired to the live backend on 2026-11-05 and shown whenever the board sends its tile (uncommitted; the flag is gone). Builds before this change still drop or ignore the tile; in 1.0.20, Ayl's pin, it shows and a tap does nothing. Still open: Ayl passing `placesAPIKey` (until it does, hotels are typed only there), art for the tile's `orb_city` (upload `agent_city.png`, see the agent tiles decision), and the class tile images (empty on the server). The server tracks the city events (`ai_profile_city_*`), so the client sends none. The older frames (`6592:8685`, `6593:10316`, `6595:10925`, `6595:11473`: a "Never book · N Airlines" row and sheet) weren't in this round.
- Known trade-offs:
  - `ProfileV3ServerFailureBox` keeps one envelope, so concurrent failures can swap codes.
  - `ATCoreCacheConfig`'s default expiry looks like a units slip; the package passes seven days.
  - The old `DataManager` board cache is orphaned.

### Photos connector branch (`feature/photos-visited-countries`, PR #1)

Not on `master`. This section exists only on the branch; Done items 1–175 are in `git show 550b009:CLAUDE.md`.

176. **Photos connector reads only where photos were taken (Mohak, 2026-10-17; branch `feature/photos-visited-countries`, draft PR atlyslabs/AI-Profile#1; package-only).**
    - `ProfileV3ConnectorKey.photos`. A server `connectors[]` row with `key: "photos"` now renders (unknown keys were dropped); with `ProfileV3FeatureFlags.isPhotoPlacesEnabled` (default false) the client appends the row itself. Its status comes from the device (`ProfileV3PhotoPlacesSync.isConnected`), not the server's `connected`. `ProfileV3Connector.canConnect` lets Connect work without a KYC capture step.
    - Connect: `ProfileV3PhotoPlacesSync.connect()` asks for `.readWrite` photo access (full or limited). Declined shows the `photosAccessDenied` flash. `ProfileV3PhotoLibrary` fetches `PHAsset` images and reads only `location` and `creationDate`, never image data.
    - On device: `ProfileV3PhotoPlaceTally` dedupes coordinates into 0.01° cells. `ProfileV3CountryLocator` does point-in-polygon with a bounding-box prefilter on `Resources/ProfileV3CountryShapes.geojson` (Natural Earth 50m admin-0, public domain, 237 ISO codes, simplified to 0.02° and rounded to 2 decimals, 794 KB; Somaliland→SO, N. Cyprus→CY, Siachen→IN). Points within 0.25° of a coast snap to the nearest country. The scan runs in a `@concurrent` function, off the main actor.
    - State per user in `UserDefaults` (`profileV3.photoPlaces.<uid>`): connected flag, `scannedThrough`, per-country totals, `needsUpload`. Full access re-scans only `creationDate > scannedThrough` and merges. Limited access re-scans the selection every time. Raw coordinates are never stored or sent.
    - Upload: `POST board/submit` `{"action":"sync_photo_places","access","scanned_through","countries":[{"country_code","photo_count","first_seen","last_seen"}]}` (ISO-8601 dates, full totals each time). A failed upload retries on the next sync. The backend action does not exist yet (Abhishek).
    - Triggers: hub `viewDidLoad` calls `syncIfConnected()`. Revoked permission, or a server disconnect of `photos` from the control panel, calls `disconnect()`, which stops the scan and clears local state.
    - Globe: `ProfileV3HubViewModel.latestPasses` (item 60) appends the photo countries to the main pass's `visitedCountryCodes`, so the expanded detail globe and flag list show them. The branch first did this with `extraVisitedCodes` and `mergingVisited`, which item 60 removed. The Countries stat number still comes from the server.
    - Host: needs `NSPhotoLibraryUsageDescription` (AYL updated in its own PR). New strings `mo-aiprofile-agents-label-photos` and `mo-aiprofile-agents-error-photos-access` (add to Ditto).
    - Names: server rows show the served `label` as is (item 75: no client fallbacks or normalising). Only the row the client appends behind `isPhotoPlacesEnabled` uses the local `photosConnector` string, because no server label exists for it. The two keys were added to the catalogue and the generated file by hand, against the Ditto rule above; regenerate after adding them in Ditto.
    - Disconnect: a `photos` disconnect clears local state first, then reports through `connectorDidDisconnect` (item 84), so the hub's `refreshAfterDisconnecting` also runs for it. `reflects` settles on the first board for any key but Gmail.
    - Tests: `ProfileV3PhotoPlacesTests` (18). Not built or run: written on Linux without a Swift toolchain. The locator algorithm and bundled data were checked with a Python mirror (32 city points).
    - Unbuilt: the branch has been merged with `master` many times without a Swift toolchain, so it needs an `xcodebuild … test` run before the PR is merged.

## Gotchas

- Shell:
  - zsh doesn't split unquoted variables, so use bash scripts or `xargs`.
  - Parallel shell commands share one working directory, so use absolute paths.
- macOS's `/tmp` cleanup empties `/tmp/aiprofile-dd/SourcePackages/checkouts`, and resolution then fails ("the package manifest … cannot be accessed"). Delete `/tmp/aiprofile-dd/SourcePackages` and resolve again.
- `ProfileV3MockRepository` defaults to `session: .shared`, which is one process-wide store shared by parallel suites. A test that writes and then reloads should pass `session: ProfileV3SessionStore()`.
- swift-testing:
  - `#expect`/`#require` around a rethrowing call with a closure or key path (`allSatisfy`, `first(where: \.x)`) doesn't compile. Use a local.
  - That error line starts with `macro expansion #expect`, so grep for `error:` anywhere in the line.
- A stalled simulator pasteboard (the vault clipboard test) blocks the main actor, and dozens of tests then hit their 60-second limit. Re-run before suspecting the change.
- An `.animation(_:value:)` outside a `safeAreaInset` doesn't reach the inset's own transitions. Put it on a persistent root inside the inset.
- `ScrollViewProxy.scrollTo(id)` scrolls the first scroll view that holds `id`, and a `ForEach` element's identity counts. A nested horizontal `ForEach` (a tab strip) keyed by the same ids as the page's targets takes the scroll, so namespace the page's ids. The view that carries `.id` must itself have the frame you want; padding applied after `.id` doesn't move the target.
- Concurrency:
  - Under `ApproachableConcurrency` a `nonisolated async` function runs on its caller's actor; use `@concurrent` for off-main work.
  - `import ATCore` brings Moya's `Task` into scope; write `Swift.Task`.
- `ProfileV3PlaceSearch.swift` builds with four deprecation warnings for the legacy Places autocomplete; AI-KYC's address search has the same ones.
- `TimelineSchedule` lives in SwiftUICore, so leading-dot extensions on it aren't found. Construct `ProfileV3AmbientSchedule(isPaused:)`.
- Assets:
  - Asset-catalog SVGs drop filters, `foreignObject` and backdrop blur.
  - SVGs with `preserves-vector-representation` draw nothing through a `Canvas`'s `context.resolve`; use ATUIKit's 1x-SVG imageset form.
- ATCore:
  - `ATCoreCacheService.shared` sweeps entries after 15 minutes and hashes keys per process; use `.persistent` with deterministic keys.
  - ATCore only reads flat `message`/`error` strings from error bodies.
- `ATBottomSheetWindowPresenter` needs a connected window scene, so sheet windows can't be presented in the test bundle.
- Four files use `Color(at:)` without `import ATUIKit`. That only compiles because extension members leak across files, and would break under `MemberImportVisibility`.
- Ayl resolves AI-Profile from GitHub. To try local package changes there, add a local package reference, or patch the checkout under Ayl's DerivedData and build with `-disableAutomaticPackageResolution`.
- In the vdcios app target (Swift 5, no approachable concurrency), `KYCOnboardingCoordinator` holds its flow weakly, so keep it alive until the flow ends.
