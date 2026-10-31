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
| Ditto toolkit | `/Users/aravindh/Downloads/ditto-migrate-toolkit-main` |
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
- Tests are swift-testing. As of 2026-10-31: 276 tests in 42 suites, 273 pass. The `feature/photos-visited-countries` branch adds `ProfileV3PhotoPlacesTests` (18, never run; Done item 176). The same three fail every run:
  - `ProfileV3DestinationTests.theHubOpensALinkOnlyWhileItIsOnScreen` (lines 68–69): a link posted while the hub's tab is hidden still opens. Either `onDisappear` doesn't clear `isSettled` on a tab switch in a test window, or the hidden-tab guard doesn't work. Not investigated.
  - `ProfileV3OnboardingPresentationTests.theHubsOwnSurfaceRunsOnboardingOverTheTabBar` and `aFlowThatClosesItsOwnContainerIsReportedOnce`: the dismissal never completes in a window with no scene. Probably the harness, not the launcher.
- Checking a design against Figma:
  - Render the real view in a throwaway probe test: a hosted `UIWindow` 440pt wide, drawn with `layer.render` at 2–3x. Use `ImageRenderer` when blur matters; it can't draw `ScrollView` content.
  - Download Figma's raster with `download_assets` (`defaultScale: 2`). Measure card-relative ink bands with a small Swift ImageIO script (PIL isn't installed). Delete the probe afterwards.
  - Inter text renders 0.5–1.5pt higher than Figma's; that's systematic, so don't offset single views.
  - `layer.render` draws no blur and a stray straight segment at capsule ends. Animations jump to their end in tests, because the window has no scene.
  - To fill a Figma line box, pad the text vertically by `TypographyStyle.<style>.lineSpacingAdjustment / 2`.

## Architecture

### Networking (ATCore)

- `Networking/ProfileV3API.swift` is a Moya `ATCoreTargetType` enum. Its base paths:
  - board `/api/gmail-connector/kyc/v2/board` and KYC `/api/gmail-connector/kyc/v1`;
  - vault `/api/fort-knox/v1`, glove box `/gateway/jaqen/v1`, permissions `/api/harness/v1` and Instagram `/api/snapmap`;
  - plus the Slack alert and the pensieve profile edit.
- Its `baseURL` is a placeholder: ATCore builds URLs from the host's `ATCoreBaseProvider.baseURL`.
- `ProfileV3NetworkClient` (public) wraps `ATCoreRequestExecutor` with the auth plugin, the `x-platform`/`x-app-version` headers and the error-envelope plugin, and decodes responses itself. Its `request`, `requestData` and `perform(_:action:)` refresh the Firebase token and retry once on a 401.
- `ProfileV3APIErrorMapper` maps 401, 409, 422, 501 and 502–504 onto `ProfileV3Error`. The envelope's `code` reaches it through `ProfileV3ServerFailureBox` (see Known trade-offs).
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
  - `ProfileV3AccountHost`: name, residence, citizenship and contact.
  - `ProfileV3CouponsHost`.
  - `ProfileV3AppHost`: logout, flash, restart, floating-bar clearance, `opensChat`/`openChat(prompt:)`.
  - `ProfileV3InviteHost` (optional): the invite code sheet.
  - Also: the analytics reporter, the field validator and the country list.
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
  bash <toolkit>/Scripts/ditto-pipeline.sh --skip-scan
  ```

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
- Analytics events (`Support/ProfileV3Analytics.swift`) follow the spec agreed on 2026-10-27: no default properties, personal data as specified. Tests record through the `@TaskLocal` `ProfileV3Analytics.scopedReporter`.
- Session replay: views with personal data use `.postHogMask()`.

## State (2026-10-31)

### Release

- `master` is at `550b009`, one commit ahead of `origin/master` (`df4009c`, tag `1.0.21`). The CHANGELOG split for `1.0.21` and this cleanup are uncommitted.
- Tags `1.0.0` and `1.0.2`–`1.0.21` are on GitHub; `1.0.1` is local only. Tags are often cut straight from a commit with no release commit. When that happens, move the tag's "Unreleased" body into a `## <version> — <date>` section and keep only later changes under Unreleased (done for 1.0.17, 1.0.20 and 1.0.21).
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

- Board: home, settings, agents, loyalty, past trips, travel persona, passports and AI connectors. Writes go to `/board/submit` and echo the served action object.
  - Past trips are country-only; several countries go as one `countries` list.
  - The personal agent's `passport_empty` shows the placeholder card, and the passport card's `father`/`mother`/`spouse`/`address` keys feed the back page.
  - AI connectors: `settings/connectors/ai/{connector}` and its `/connect`, saved with `connect_ai_connector`. Its `synced_at` comes as Python `isoformat()` (microseconds, `+00:00`).
  - Custom rules are the agent screen's `custom_rules` field and save with the agent.
- Vault (fort-knox): a login is sealed with AES-GCM under a key wrapped by the server's RSA key (OAEP-SHA256). A reveal opens an ECDH/HKDF box with the phone's Keychain key after Face ID.
- Glove box (jaqen): `/me`, `/messages` (status, attention, action, sender logo) and the forwarding endpoints.
- Permissions (harness): `GET /permissions` and `PUT /permissions/{key}` `{value}`.
- Instagram (snapmap):
  - Read with `GET /instagram/accounts?user_id=`; link with a `POST` of `{username, user_id}`. `user_id` must be the signed-in Firebase uid.
  - A 409 means the username is linked to another account.
  - The link counts only once that account has DMed @ayl.chat, and there is no unlink endpoint.

### Product decisions that constrain changes

- One package serves two hosts, Ayl and the Atlys app, so catalog copy shows in both. Six strings now say "Ayl".
- App access in release lists only Instagram. Its waiting-for-a-DM card follows Figma `6595:16405`, and "Send a message" opens `https://ig.me/m/ayl.chat`.
- Vault:
  - Opening it with Face ID covers reveals until it is closed or the app goes to the background.
  - Saving a login only calls the API, and the sheet's fields aren't tagged as a username and password, so iOS doesn't offer to save them.
- The glove box opens from the Settings card. Without KYC it shows the locked intro. An empty inbox shows one sample email. The virtual card shows the main traveler's short name and digits derived from the address.
- Travel persona: the delight loader shows for the first five loads, and a drag saves on release.

### Ditto owes

- The last full sync matched `c8afbc3` (385 keys, 2026-10-27).
- Since then, by hand: 51 keys added, 6 values changed (the Atlys → Ayl copy and the "How you pay" text), and 23 catalog keys unused (16 exist in Ditto: delete them there; 7 were hand-added: drop them locally).
- Recompute: compare the catalog with `git show c8afbc3:Sources/ATAIProfile/Resources/ProfileV3Localizable.xcstrings`. A key is unused when nothing in `Sources` or `Tests` references its generated accessor.
- Five of the "Ayl" values still say "Atlys" in their generated fallbacks; a pipeline rebuild fixes that.

### Unverified (needs Ayl or a device)

- Saving a vault login shows no iOS "Save Password" sheet.
- Instagram linking against snapmap in production, and the waiting card in Ayl.
- KYC onboarding presented full screen over Ayl's tab bar.
- Motion that tests can't show: the save button's entry and exit, the persona loader's haptics, the glove box entrances, the hero and globe transitions.

### Open work

- vdcios integration:
  - Pin a version instead of `branch: master`.
  - Check that CI's Xcode supports tools 6.4; if it's Xcode 26, lower to 6.2.
  - Move `VDCAppTests/ProfileV3MapperTests.swift` (69 tests, on `feature-profile-ai`) into the package.
  - Delete the unlinked `Modules/ProfileV3`.
  - The vdcios hosts don't implement `ProfileV3InviteHost`.
  - `VDCProfileV3KYCHost.startOnboarding` asserts on `AVNavigationViewController`, so onboarding from `makeHubSurface` fails there.
- Ayl follow-ups, open as of 2026-10-28 (verify first):
  - Drop `addsPastTripsWithoutDate` from `AYLProfileV3AppHost`; nothing reads it.
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
- Known trade-offs:
  - `ProfileV3ServerFailureBox` keeps one envelope, so concurrent failures can swap codes.
  - `ATCoreCacheConfig`'s default expiry looks like a units slip; the package passes seven days.
  - The old `DataManager` board cache is orphaned.

### Photos connector branch (`feature/photos-visited-countries`, PR #1)

Not on `master`. This section exists only on the branch and carries the photos item forward; Done items 1–175 are in `git show 550b009:CLAUDE.md`.

176. **Photos connector reads only where photos were taken (Mohak, 2026-10-17; branch `feature/photos-visited-countries`, draft PR atlyslabs/AI-Profile#1; package-only). Numbered 53 on the branch until `master` was merged in on 2026-10-26, then 118 until the merge of `85dba88` on 2026-10-27, then 122 until the merge of `e94a37e` the same day, then 125 until the merge of `7ec88f0` the same day, then 134 until the merge of `3de2dd3` on 2026-10-28, then 137 until the merge of `55e2cff` the same day, then 144 until the merge of `b7dff0f` the same day, then 145 until the merge of `528b9a5` on 2026-10-29, then 150 until the merge of `7caacee` on 2026-10-30, then 166 until the merge of `1e3c6e3` on 2026-10-31, then 172 until the merge of `df4009c` the same day, then 174 until the merge of `b9e925b` the same day.**
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
    - Merged with `master` at `43de805` on 2026-10-26 (merge commit, no rebase), also on Linux without a toolchain, so the merge is unbuilt too. Conflicts were in the connectors mapper, settings strings, the generated L10n file and catalogue, feature flags, the live repository, the connectors, hub and settings models, the settings presenter, the hub hosting controller, hub chrome, hub view and README. Run `xcodebuild … test` before merging the PR.
    - Merged with `master` at `85dba88` on 2026-10-27 (merge commit), again without a toolchain. Only this file conflicted (the test count line); the string catalogue and generated L10n file merged cleanly with the two photos keys kept. Unbuilt.
    - Merged with `master` at `e94a37e` on 2026-10-27 (merge commit), again without a toolchain. Conflicts: this file, and the `ProfileV3HubViewModel` initializer and its call in `ProfileV3HubHostingController`, where master added `addsTripsWithoutDate` and the branch `photoPlaces`; both parameters are kept, `addsTripsWithoutDate` first. Unbuilt.
    - Merged with `master` at `7ec88f0` on 2026-10-27 (merge commit), again without a toolchain, so unbuilt. Master moved `ProfileV3HubViewModel` to Observation (no `@Published`), so the hub now copies `ProfileV3PhotoPlacesSync.countryCodes` into a plain `photoCountryCodes` through a Combine `sink` kept in an `@ObservationIgnored` `AnyCancellable`, in place of `assign(to: &$photoCountryCodes)`. `ProfileV3ConnectorsSettingsModel.init` takes master's `travellerID` and the branch's `photoPlaces`, and `ProfileV3SettingsViewModel` passes both. The photos disconnect hook sits after master's renamed `connectorDisconnected(connectorName:)` call.
    - Merged with `master` at `3de2dd3` on 2026-10-28 (merge commit), again without a toolchain, so unbuilt. Conflicts: this file, and `ProfileV3FeatureFlags`, where master added `isPastTripAddDatesEnabled` and `isAgentCustomRulesEnabled`; all three flags are kept, master's first. `ProfileV3Environment` merged cleanly with master's `PhoneCodeResolver.install` and the branch's `photoPlaces`.
    - Merged with `master` at `55e2cff` on 2026-10-28 (merge commit), again without a toolchain, so unbuilt. Conflicts: this file, and the `ProfileV3HubViewModel` initializer and its call in `ProfileV3HubHostingController`, where master removed `addsTripsWithoutDate` (past trips are country-only, item 142); only the branch's `photoPlaces` is kept there, and the hosting controller keeps master's new `onboarding` parameter.
    - Merged with `master` at `b7dff0f` on 2026-10-28 (merge commit), again without a toolchain, so unbuilt. Only this file conflicted (the test count line); master's loyalty multi-select delete merged cleanly, and the photos item moved to 145 after master's item 144.
    - Merged with `master` at `528b9a5` on 2026-10-29 (merge commit), again without a toolchain, so unbuilt. Only this file conflicted (the test count line). Master split `loadPermissions`/`savePermission(_:for:)` into a new `ProfileV3PermissionsRepository` that `ProfileV3SettingsRepository` refines; `syncPhotoPlaces` stays on the settings repository in all four implementations, and the photos item moved to 150 after master's item 149.
    - Merged with `master` at `7caacee` on 2026-10-30 (merge commit), again without a toolchain, so unbuilt. Conflicts: this file (the test count line); `ProfileV3LiveRepository`, where master added the AI connector loads and connect next to the branch's `syncPhotoPlaces` (all kept); `ProfileV3Models`, where master gave `ProfileV3Connector` `next`, `connectLabel`, `statusLabel`, `syncedAt` and `aiConnector`, so the branch's `withStatus` now copies those too (master's `reconciled` rebuilt the connector without them, and the branch's version still goes through `withStatus`); `ProfileV3ConnectorsSettingsModel.tapConnect`, which tries master's AI connector route first, then photos, then the capture step, with `connectPhotos` and master's `openAIConnector` both kept, and a connector marked disconnected is rebuilt exactly as master does (keeping only id, name, icon and account email, so `next`, `connectLabel`, `statusLabel`, `syncedAt` and with them `aiConnector` are dropped), so disconnect now follows master; `ProfileV3FeatureFlags`, with master's `isPassportBackPageEnabled` and the branch's `isPhotoPlacesEnabled` both kept; and `ProfileV3InformationAccessView`, which takes master's served `connectLabel` title with the branch's `canConnect` action. The photos item moved to 166 after master's item 165.
    - Merged with `master` at `cd6a5ce` (1.0.18) on 2026-10-30 (merge commit), again without a toolchain, so unbuilt. Master added the Invite Friends row and invite code sheet (`ProfileV3InviteHost`, `invites` on the environment and host actions) and left this file alone, so the photos item stays 166. Conflicts: the `ProfileV3SettingsViewModel` initializer and its call in `ProfileV3SettingsSheetPresenter`, where master added `invites` and the branch `photoPlaces`; both are kept, master's `invites` first and `photoPlaces` last (both defaulted).
    - Merged with `master` at `1e3c6e3` on 2026-10-31 (merge commit), again without a toolchain, so unbuilt. Master added Done items 166–171 (the reuse audit's shared pieces and theme tokens, Instagram to snapmap, App access trimmed, the AI assistant rows behind `isAIConnectorsEnabled = false`, and the 1.0.19 merge repair), so the photos item moved to 172. Conflicts: this file; the string catalogue and generated L10n file, where master's new `mo-aiprofile-agents-error-instagram-username-invalid` sat next to the branch's `mo-aiprofile-agents-error-photos-access` (master's files taken with both photos keys added back in key order); and `ProfileV3ConnectorsSettingsModel`, where master added `showsAIConnectors` beside the branch's `photoPlaces` (both kept, master's first, `photoPlaces` last) and filters AI assistant rows in `apply(_:)` before the branch's `withPhotoPlaces` step, which is kept: `reconciled(withPhotoPlaces(screen.connectors.filter { showsAIConnectors || $0.aiConnector == nil }))`.
    - Merged with `master` at `df4009c` on 2026-10-31 (merge commit), again without a toolchain, so unbuilt. Master added Done items 172 (the glove box card drops its No-show fee row, and Atlys copy becomes Ayl) and 173 (every AI assistant the server sends shows on Information access), so the photos item moved to 174. Only this file conflicted (the test count line and the Done list); the Swift sources, the string catalogue and the generated L10n file merged cleanly, with both photos keys kept.
    - Merged with `master` at `b9e925b` on 2026-10-31 (merge commit), again without a toolchain, so unbuilt. Master added Done items 174 (the waiting Instagram card follows Figma) and 175 (saving a vault login no longer offers the keychain save), then cut this file down to current context and moved Done items 1–175 to `git show 550b009:CLAUDE.md`, so the photos item moved to 176 and now lives in its own section under State. Only this file conflicted: master's trimmed file was taken, with the photos tests sentence added to Build and test and this section added. The Swift sources, the string catalogue and the generated L10n file merged cleanly, with both photos keys kept; master's changes near the photos code (`ProfileV3ConnectorAction` gained a `style` parameter, and `ProfileV3SettingsStrings` swapped two Instagram strings) don't touch the photos lines.

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
- Concurrency:
  - Under `ApproachableConcurrency` a `nonisolated async` function runs on its caller's actor; use `@concurrent` for off-main work.
  - `import ATCore` brings Moya's `Task` into scope; write `Swift.Task`.
- `TimelineSchedule` lives in SwiftUICore, so leading-dot extensions on it aren't found. Construct `ProfileV3AmbientSchedule(isPaused:)`.
- Assets:
  - Asset-catalog SVGs drop filters, `foreignObject` and backdrop blur.
  - SVGs with `preserves-vector-representation` draw nothing through a `Canvas`'s `context.resolve`; use ATUIKit's 1x-SVG imageset form.
- ATCore:
  - `ATCoreCacheService.shared` sweeps entries after 15 minutes and hashes keys per process; use `.persistent` with deterministic keys.
  - ATCore only reads flat `message`/`error` strings from error bodies.
- The generated L10n Swift has one out-of-order pair (`glovebox-label-dated` before `glovebox-label-card-*`).
- `ATBottomSheetWindowPresenter` needs a connected window scene, so sheet windows can't be presented in the test bundle.
- Four files use `Color(at:)` without `import ATUIKit`. That only compiles because extension members leak across files, and would break under `MemberImportVisibility`.
- Ayl resolves AI-Profile from GitHub. To try local package changes there, add a local package reference, or patch the checkout under Ayl's DerivedData and build with `-disableAutomaticPackageResolution`.
- In the vdcios app target (Swift 5, no approachable concurrency), `KYCOnboardingCoordinator` holds its flow weakly, so keep it alive until the flow ends.
