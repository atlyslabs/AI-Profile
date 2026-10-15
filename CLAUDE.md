# AIProfile package: working context

This folder is the Swift package `AIProfile`, extracted from the Atlys iOS app's ProfileV3 module so it can build on its own and then be linked back into the app. This file carries the working context between sessions.

## Keeping this file current

Update this file in the same turn whenever a fix lands, a decision is made, the app's ProfileV3 changes, or a finding changes the plan. Move finished items to Done, correct anything that turned out wrong, and keep the Status date current.

A Stop hook enforces this. `.claude/settings.local.json` runs `.claude/hooks/claude-md-freshness.sh` at the end of every turn, and sends Claude back once to update this file when:

- package files (`Sources`, `Tests`, `AppIntegration`, `Package.swift`, `Package.resolved`) were edited after this file was last saved
- the package has a new commit
- the app's ProfileV3 has a new commit, or a different set of files with uncommitted changes

The hook stores what it last saw in `.claude/hooks/.last-seen-state`. The hook script and settings are personal and gitignored.

## Locations

| What | Path |
|---|---|
| Package | `/Users/aravindh/Desktop/Atlys/AI-Profile`, git on `master` (latest commit: `git log -1`), remote `origin` = `https://github.com/atlyslabs/AI-Profile.git` |
| Identity Capture package | `/Users/aravindh/Desktop/Atlys/IdentityCapture`, copied from `vdcios/VDCApp/Modules/IdentityCapture`, no commits yet |
| Package sources | `Sources/AIProfile` |
| App-side bridge code, not built by the package | `AppIntegration/ProfileV3Host` |
| App repo | `/Users/aravindh/Desktop/Atlys/vdcios`, integration on `feature-profile-ai-spm` (commits `c2228520b`, `50ce1e9e1`); `feature-profile-ai` still compiles `Modules/ProfileV3` |
| Original module | `vdcios/VDCApp/Modules/ProfileV3` |
| Session that set up the package | `~/.claude/projects/-Users-aravindh-Desktop-Atlys/562aacfd-6df3-4c4d-972e-1fb38abede25.jsonl` |
| Session that inventoried the blockers | `~/.claude/projects/-Users-aravindh-Desktop-Atlys-AI-Profile/79b4da81-fe75-45a8-9cb4-3ca92753dd62.jsonl` |

Since vdcios `50ce1e9e1` (2026-10-14, on `feature-profile-ai-spm`) that branch links this package as the remote `atlyslabs/AI-Profile`, tracking branch `master` (`Package.resolved` revision `b611483`), and no longer compiles `Modules/ProfileV3`. Package edits reach it only after they are pushed to `master` and the app re-resolves. The old branch `feature-profile-ai` still builds `Modules/ProfileV3`, and on 2026-10-15 the user asked for Profile V3 changes to land there too, so a package change may need the same edit in the app copy (see Upstream drift). That folder is still on disk. The package was last synced to app commit `19c657bd7` (2026-10-14 12:48, "Keep the pass globe through expansion and drop the Reserve intro gate"), then `9e92cb981` (14:40, "Align card art to its logo and fix agent orb states") was ported on top. The app's ProfileV3 HEAD on that branch is `9e92cb981`. Later app changes are listed under Upstream drift in Status.

## Package setup

`Package.swift` uses tools 6.4, iOS 17, Swift 6 language mode, and the `ApproachableConcurrency` upcoming feature. The `Resources` folder is processed, which ships `ProfileV3.xcassets` and `ProfileV3Localizable.xcstrings` in the package bundle. `Tests/AIProfileTests` holds the init scaffold and `ProfileV3TravellerRelationshipTests` (swift-testing, 7 tests).

| Package | Requirement | Resolved | Product |
|---|---|---|---|
| atlyslabs/ATCore | from 1.0.16 | 1.0.16 | ATCore |
| Moya/Moya | from 14.0.0 | 14.0.1 | Moya |
| atlyslabs/ATUIKit | from 1.3.7 | 1.3.7 | ATUIKit |
| atlyslabs/ATAuthKit | from 1.0.44 | 1.0.44 | ATAuthKit |
| atlyslabs/ditto-migrate-toolkit | from 0.0.1 | 0.0.1 | DittoRuntimeStrings |
| marmelroy/PhoneNumberKit | from 3.6.0 | 3.8.0 | PhoneNumberKit |
| kean/Nuke | from 12.0.0 | 12.9.0 | Nuke |

These match the app's SwiftPM pins in `vdcios/VDCApp.xcworkspace/xcshareddata/swiftpm/Package.resolved`, so the app resolves one copy of each. Remote images go through Nuke. The app's SDWebImage 5.17.0 pod stays the app's own dependency.

## Building

The package builds. The 2026-10-14 `xcodebuild` exited 0 with no warnings. Without `-IDEBuildingContinueBuildingAfterErrors=YES`, Xcode stops after the first failing batch and hides most errors. A cold build, including package resolution, takes about two minutes.

```sh
cd /Users/aravindh/Desktop/Atlys/AI-Profile
xcodebuild -IDEBuildingContinueBuildingAfterErrors=YES -scheme AIProfile \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/aiprofile-dd \
  -skipPackagePluginValidation -skipMacroValidation ONLY_ACTIVE_ARCH=YES ARCHS=arm64 \
  build > /tmp/aiprofile-build.log 2>&1
grep -cE '^/.*error:' /tmp/aiprofile-build.log
grep -hoE "cannot find (type )?'[^']+' in scope" /tmp/aiprofile-build.log | sort | uniq -c | sort -rn
```

To run the tests, add `-clonedSourcePackagesDirPath /tmp/aiprofile-dd/SourcePackages` to skip resolution, and use a throwaway simulator, never the user's booted one. `simctl create <name> com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro com.apple.CoreSimulator.SimRuntime.iOS-26-5`, then `xcodebuild -scheme AIProfile -destination "id=<udid>" … test`, then `simctl delete <udid>`. On 2026-10-14 all 8 tests passed this way.

That count understates the work. An unresolved type hides other errors in the same expression, and Swift 6's data-race checks (`sending '…' risks causing data races`) only run in a file once it type-checks. To see everything, build a scratch copy with stand-ins:

1. Copy `Package.swift`, `Package.resolved`, `Sources` and `Tests` into a scratch folder. Without `Tests`, SwiftPM reports overlapping sources.
2. Add stand-ins with the real signatures of every missing app symbol, and patch the A3 items.
3. Build it with its own `-derivedDataPath`, and `-clonedSourcePackagesDirPath /tmp/aiprofile-dd/SourcePackages` to reuse the checkouts.

On 2026-10-14 the scratch copy reached zero errors once the data-race errors in A3 were patched there too, so the A lists in Status cover all of the existing code. The stand-ins were scratch-only.

Before refactoring a package file, check whether the app changed it since the last sync:

```sh
cd /Users/aravindh/Desktop/Atlys
diff -rq --exclude='.DS_Store' vdcios/VDCApp/Modules/ProfileV3 AI-Profile/Sources/AIProfile
git -C vdcios log --oneline -5 -- VDCApp/Modules/ProfileV3
git -C vdcios status --short -- VDCApp/Modules/ProfileV3
```

These differences are intentional package edits. Anything else that differs is upstream drift to port.

- Changed: `Components/` HeroGlobe, InteractiveGlobe, WorldPassCard, WorldPassCarousel; `Data/` APIErrorMapper, BoardStore, LiveRepository, `Mappers/` CaptureMapper and PassportMapper; `Domain/` KYCCapture, Passport; `Presentation/` HubStage, KYCCaptureViewModel, SettingsSheetPresenter; top-level AgentFlowHostingController, EntryPoint, HubHostingController, HubSurface, PassportScanLauncher; `Support/` Analytics, Theme+Globe; `Views/` HubChrome, HubView, KYCCaptureView, WorldPassDetailView. All file names carry the `ProfileV3` prefix.
- Removed: `Networking/ProfileV3APIEndpoint.swift`, `Presentation/ProfileV3KYCCaptureViewModel+KYCModule.swift`.
- Added: `Host/`, `Components/ProfileV3CardGlobe.swift`, `Networking/` API, DiskCache, ErrorEnvelope, Multipart, NetworkClient, `Presentation/ProfileV3KYCCaptureViewModel+HostScreens.swift`, `Support/ProfileV3Collection+NonEmpty.swift`.

## Architecture decisions

### Networking runs on ATCore

This replaces the app's `APIEndpoint`, `DataManager`, `NetworkError` and `MultipartUploadHelper`.

- `Networking/ProfileV3API.swift` is a Moya enum conforming to `ATCoreTargetType` with 34 endpoints under `/api/gmail-connector/kyc/v2/board` and `/api/gmail-connector/kyc/v1`, plus the Slack alert and the pensieve profile edit (PATCH). Its `baseURL` is a placeholder, because `ATCoreMoyaProviderFactory` builds URLs from the host's `ATCoreBaseProvider.baseURL` plus the path.
- `Networking/ProfileV3NetworkClient.swift` is public. It wraps `ATCoreRequestExecutor` built with `ATCoreAuthPlugin`, a plugin adding `x-platform: ios` and `x-app-version`, and a plugin that copies the gmail-connector error envelope's message into `ATCoreServerError`. It decodes responses itself through `requestRaw`, which avoids an isolated-conformance warning. Decode failures still surface as `ATCoreError.decoding`.
- `Networking/ProfileV3DiskCache.swift` stores the board snapshot in `ATCoreCacheService.persistent` with deterministic keys.
- `Data/ProfileV3APIErrorMapper.swift` maps ATCore server statuses 401, 409, 422, 501 and 502 to 504 onto `ProfileV3Error`. On 401 it refreshes the Firebase ID token through ATAuthKit and retries once.
- `Data/ProfileV3BoardStore.swift` and `Data/ProfileV3LiveRepository.swift` take the client, session and cache by injection. The `BoardStore.shared` singleton is gone.

### App features are consumed through host seams in `Sources/AIProfile/Host`

KYC onboarding, identity capture and the land globe stay in the app. The package defines protocols, and the app passes implementations into `ProfileV3Environment`.

- **`ProfileV3KYCHost`** with value types in `ProfileV3KYC`. It covers `startOnboarding(on:completion:)`, `presentMinimalCapture(from:completion:)`, four step screens that take screen data and actions and return `AnyView` (Gmail, ITR, passport, selfie), `authorizeGmail()`, and `track(_:)` for analytics events. ProfileV3 keeps its own capture state machine and API in `ProfileV3KYCCaptureViewModel`, and builds the screens in `ProfileV3KYCCaptureViewModel+HostScreens.swift`.
- **`ProfileV3IdentityCaptureHost`** with value types in `ProfileV3IdentityCapture`. It covers `presentCapture(_:from:completion:)` for full screen and `captureView(_:completion:)` for embedding. A request carries the photos to capture, per-photo copy, progress, an optional header view, and a `verify` closure that returns verified, rejected or failed. The passport rescan in `ProfileV3PassportScanLauncher` uses the full-screen form. The embeddable form is meant for an upcoming profile agent and nothing calls it yet.
- **`ProfileV3GlobeRendering`** with value types in `ProfileV3Globe`. The host only implements `prepare(_:)` and `drawLand(_:in:projection:)`. The package owns the pose (`ProfileV3GlobePose`), projection math, the card globe (`Components/ProfileV3CardGlobe.swift`), ocean, shading, markers and the hand-off between card, hero and detail globes. The renderer travels through the `profileV3Globe` SwiftUI environment value, set by `ProfileV3HubRoot` at the bottom of `ProfileV3HubHostingController.swift`. The default is a dotted placeholder so previews work. The card constants in `Support/ProfileV3Theme+Globe.swift` match the app's KYC particle globe.
- **`ProfileV3SessionProviding`** supplies `currentUserID` and a main-actor `isGuestSession`.
- **`ProfileV3FlowOutcome`** is `.completed` or `.cancelled` for every host-owned flow.
- **`ProfileV3AccountHost`** with `ProfileV3AccountSnapshot`. The app keeps `UserData`. The host returns the first name, residence code, citizenship, passport nationality, contact, and selected traveller id, and it writes residence, citizenship, and a saved contact. `isContactTaken` wraps `mergeAccounts`. `travellerProfileDidChange()` posts `ProfileUpdatedNotification` with `showsConfirmation: false`. The package still parses the phone, decides `ContactUpdateOutcome`, and sends the two profile updates through `ProfileV3API.editProfile`.
- **`ProfileV3CouponsHost`** presents the app's coupons screen. `presentCoupons(from:)` receives the view controller already on screen. The app builds `CouponsView(viewModel: CouponsViewModel(), onBack:)` inside a full-screen `UIHostingController` and dismisses it from `onBack`. The package's `ProfileV3CouponsListView` is not this screen.
- **`ProfileV3AppHost`** covers logout, status flashes, app restart, and the floating tab bar. `showStatusMessage(_:isSuccess:)` is `FlashMessageGenerator`; the package still plays the haptic. `logOut()` is `LoginCoordinator.logOutUser()`. `restartApp()` posts `AVNavigationViewController.RestartApp`, and the app's own restart flow draws the restart screen; the package shows no cover of its own. `floatingBarClearance` is `AVTabBarController.floatingBarClearance` (68pt). `ProfileV3HubRoot` puts that value in the `profileV3FloatingBarClearance` environment, which defaults to 68 so previews match. An environment value set outside the hub would not reach it, because the hub has its own hosting controller.
- **`ProfileV3Environment(baseProvider:session:kyc:identityCapture:globe:analytics:validation:account:coupons:app:countries:appVersion:plugins:)`** is passed to the public `ProfileV3EntryPoint.configure(_:)`. The hub, settings presenter, capture view model and agent flow read their hosts from it. It hands the base provider to the network client and doesn't keep it. It does keep the analytics reporter, the field validator, the account host, the coupons host, and the app host. It installs analytics, validation, and the country list into nonisolated sinks. Pickers and currency lookup read that list while drawing.
- A DEBUG-only `ProfileV3PlaceholderKYCHost` stands in for KYC screens in SwiftUI previews.

### App-side bridge code in `AppIntegration/ProfileV3Host`

These files are written for the app target and move into `vdcios/VDCApp/Modules/ProfileV3Host` at integration.

- `VDCProfileV3Composition.configure()` builds the environment. AppDelegate calls it once at launch, before any ProfileV3 entry point.
- `VDCProfileV3BaseProvider` reads the base URL from `APIConstants.BaseURL.getBaseURL()`. It captures AppDelegate's `authTokenProvider` once on the main actor, takes residency from `HomeIdentityProvider` and sends analytics to `AnalyticsEventManager`.
- `VDCProfileV3Session` reads `UserData.currentUser?.userUid` and `GuestSession.firebaseResolver()`.
- `VDCProfileV3KYCHost` wraps `KYCOnboardingCoordinator`, `KYCFactory.presentMinimal`, the four KYC views with their step-model mapping, `KYCGmailOAuth` and `KYCOnboardingAnalytics`.
- `VDCProfileV3IdentityCaptureHost` wraps `IDCFactory.makeViewController` in a hidden-bar navigation controller presented over full screen with a cross-dissolve, the same as the old launcher. Its embeddable view owns an `IDCFlowViewModel`.
- `VDCProfileV3GlobeRenderer` wraps `GlobePoints.load`, `GlobePoints.cache`, `KYCParticleGlobe.drawLand` and `GlobeProjection`.
- `VDCProfileV3Analytics` forwards `ProfileV3AnalyticsReporting` to `AnalyticsEventManager`. `VDCProfileV3BaseProvider.sendEvent` still forwards ATCore's own events.
- `VDCProfileV3FieldValidator` forwards email checks to `InputValidator` and passport checks to `PassportDataHandler`.
- `VDCProfileV3Countries.catalogue` maps `Country.allCountries` to `ProfileV3Country` (ISO code plus the English `rawValue`). `allCountries` drops the multi-country trip case. Composition passes that array into the environment.
- `VDCProfileV3AccountHost` reads `UserData.currentUser`. Residence is `Locale.current.avRegionCode`. Citizenship and passport nationality are mapped from `Country` into `ProfileV3Country`. Saving citizenship assigns both `user.citizenship` and `citizenshipCountryCode`. Saving residence sets `userOverriddenRegionCode`. Both sync and post `citizenshipResidenceUpdated`. Contact saves post `UserDataCacheUpdated`. `isContactTaken` treats a `mergeAccounts` token as taken.
- `VDCProfileV3CouponsHost` presents `CouponsView` full screen over the view controller the settings presenter passes in. Back dismisses that host.
- `VDCProfileV3AppHost` forwards status text to `FlashMessageGenerator`, logout to `LoginCoordinator.logOutUser()`, restart to a `RestartApp` notification, and the hub's bottom clearance to `AVTabBarController.floatingBarClearance`.

## Status as of 2026-10-15

### Done

1. Created the package, copied ProfileV3, and declared resources and the iOS 17 platform.
2. Declared the dependencies above. The private atlyslabs repos resolve with the existing git credentials.
3. Moved networking onto ATCore.
4. Moved KYC, identity capture and the globe behind host seams, and wrote the app-side hosts.
5. Synced the globe and hub files to app commit `19c657bd7` before the globe refactor.
6. Typechecked the app-side hosts against the seams. See Verifying the app-side code.
7. Re-inventoried the blockers with a fresh build and a stub build (see Building), and set up the Stop hook that keeps this file current.
8. Circle icon buttons use `ProfileV3Theme.Palette.floatingControlInk` (RGB 0.09, 0.09, 0.11) and `ProfileV3FloatingControlBackground`. The iOS 26 glass modifier is inlined there; `ChatTheme` is not copied.
9. Package helpers, all internal: `Color(hex:)` (6-digit RGB, 8-digit RGBA with alpha last, invalid input is black), `Font.Inter.get` / `Font.Denton.get` forwarding to ATUIKit's `Font.inter` / `Font.denton`, and `Collection[safe:]` in `ProfileV3Collection+NonEmpty.swift`.
10. The unsupported-capture log in `ProfileV3KYCCaptureViewModel` goes through `ATCoreLogger.info`. That writes console and file only; the PostHog log record from `AppLog` is not wired.
11. Copied `HapticFeedbackGenerator` into `Support/`, marked `@MainActor`. ATCore 1.0.16 has no haptic API. ATUIKit's `HapticsManager` has light, medium, heavy, success and error, but no `.rigid` and no 0.65-intensity light. Connector haptics use both as fallbacks.
12. `PhoneCodeResolver` lives in the package and owns the only `PhoneNumberKit` instance (`nonisolated(unsafe) static let`). PhoneNumberKit was already a package dependency. `resolve` takes `fallbackRegion`, defaulting to `Locale.current.region` and then `"IN"`, and does not read `Locale.avRegionCode`. `isValidPhoneNumber` and `e164` replace `AppPhoneNumberKit`.
13. ProfileV3 events go through `ProfileV3AnalyticsReporting`. `ProfileV3Environment` keeps the reporter and installs it into a lock, because `ProfileV3Analytics.log` is nonisolated. `VDCProfileV3Analytics` forwards to `AnalyticsEventManager`. This does not use `ATCoreBaseProvider.sendEvent`.
14. Callers pass the app's `AVNavigationViewController` in as a `UINavigationController`, and the package pushes, pops and presents on that instance. Restart goes through `ProfileV3AppHost.restartApp()`; the separate `ProfileV3NavigationHost` was removed (item 39). The app still downcasts in `VDCProfileV3KYCHost`. The presenter's `afterDismiss` is `@MainActor () -> Void` so it can call `restartApp()`. `close(then:)` still takes a plain closure and runs it on the main actor.
15. Email and passport-number checks go through `ProfileV3FieldValidating`. The package still trims input and treats an empty passport number as valid. `nationality` is the country's English name, such as `"India"`. A DEBUG stand-in matches the app's two regexes so previews work before `configure`.
16. The pass number uses `ProfileV3Theme.Typography.worldPassNumberFont` (`"Dotline"`). `AVTextConfig` is not copied. Previews fall back to the system font until the app registers Dotline.
17. `ContactUpdateOutcome` is an internal package enum with `success`, `duplicateEmail` and `failure`, next to `ProfileV3ContactDetails`. The app keeps its own enum on `AccountSettingsViewModel`.
18. `LoginCountryOption`, `LoginCountryPickerSheet` and `SettingsSearchField` are internal package types. The option pairs `ATCountry` with a dial code. India is 10 digits, every other country is 7...15, and an unknown region falls back to `LoginCountryOption.india` (`+91`). The picker maps `LoginTheme` onto `ProfileV3Theme` and uses `HapticsManager.shared.selection()`. The search field keeps the account-settings hairline `#D6D9DC`. `ATSearchField` is not used.
19. The app's `Country` enum stays in the app. `ProfileV3Country` is a public code-and-name value, and `ProfileV3Countries` holds the list installed at `configure`. Lookups are by ISO code and by English name. India checks compare with `ProfileV3Country.india` (`code == "IN"`). Flags stay `ATCountry(isoCode:)`. `ProfileV3CurrencyCodes` rebuilds from that list. Package previews have an empty list until something calls `install`.
20. Account data goes through `ProfileV3AccountHost`. `ProfileV3SettingsDependencies.live(account:session:client:)` builds the settings closures from it, so the `static let live` singleton is gone. The hub first name, passport nationality, and airport-pickup region read the same snapshot. Currency still uses `accountSettings.preferredCurrencyCountryCode`, falling back to the residence code. The account-deletion flag stays in `UserDefaults`, keyed by the session user id. The package sends residence and contact with `ProfileV3API.editProfile`.
21. The extraction commit `a8d78af` (2026-10-14 15:23, "Extract ProfileV3 into the AIProfile package.") was removed. The tree was recommitted as `b611483` (2026-10-14 16:27, "Extract ProfileV3 into the AIProfile Swift package"), 369 files, and it includes the fixes in item 22. `master` has no remote.
22. Fixed after `a8d78af` and included in `b611483`: `ProfileV3SettingsRouting.swift` imports `Foundation`, and `ProfileV3KYCCaptureViewModel` spells its concurrency tasks as `Swift.Task`. `import ATCore` brings Moya's non-generic `Task` into scope. The 401 refresh calls `getIDTokenForcingRefresh` on the main actor and resumes from Firebase's main-queue completion, which does not capture the user. `ATAuthKit.idToken(forceRefresh:)` on the main thread returns the cached token, which is the one the server just rejected.
23. Coupons are presented by `ProfileV3CouponsHost`. The settings presenter finds the top view controller and calls `presentCoupons(from:)`. `VDCProfileV3CouponsHost` builds the app's `CouponsView`.
24. The two board timestamp parsers are `OSAllocatedUnfairLock`s around the same `ISO8601DateFormatter`s. `ProfileV3BoardStore.decode` is nonisolated, so two fetches can parse at once. The lock is what makes the static safe; parsing options are unchanged.
25. Logout, status flashes, app restart, and the floating tab bar go through `ProfileV3AppHost`. The package no longer names `FlashMessageGenerator`, `LoginCoordinator`, `AICSplash`, or `AVTabBarController`.
26. `makeHubSurface` is `@MainActor`, inherited from `ProfileV3EntryPoint`. It was `nonisolated` and passed the non-Sendable `onClose` into the main-actor `ProfileV3HubSurface`. The app's call at `ProfileTabBarManager.swift:300` needs `MainActor.assumeIsolated` at integration.
27. Comments are removed from `Sources`, `Tests`, `AppIntegration`, and `Package.swift`, except `// MARK` lines. `// swift-tools-version: 6.4` stays, because SwiftPM reads it. SwiftGen will put the `///` notes and `swiftlint` lines back into `ProfileV3L10n+Generated.swift` the next time that file is generated.
28. The residence `legacy` closure passed to `async let` is `@Sendable`. `pushResidenceToServer` is `@Sendable` too. The field save and the legacy profile edit still run together.
29. The relative date formatter is an `OSAllocatedUnfairLock` around the same `RelativeDateTimeFormatter` (`dateTimeStyle` `.named`, `unitsStyle` `.full`). The package build now exits 0.
30. `ProfileV3DateInput.onChange` and `ProfileV3FormSectionView.onTextChange` are `@MainActor`. `Binding`'s setter is `@Sendable`, and the plain closures were the two remaining warnings. The build is clean.
31. App commit `9e92cb981` is ported: agent `hasData`, orb `state`, programme art aspect and logo inset, and `ProfileV3RemoteImage.onLoad`. The new mapper test stays in `VDCAppTests` until B6.
32. `makeHub`, `makeHubSurface`, `presentAddTraveller` and `prefetchBoard` are public and take no repository. The repository comes from `environment.makeRepository()`. `ProfileV3EntrySource` is public; `ProfileV3Analytics.EntrySource` is a typealias to it. There is no internal `makeHub` that still takes a repository, because previews build the views directly.
33. `profile_v3_*` images and the Ditto loader use `.module`. `WhatsApp` and `reserve_logo_clear` stay on `.main`, because those two assets live in the app catalog.
34. `ProfileV3RemoteImage` loads through Nuke 12.9.0 (`ImagePipeline.shared` and `cache.cachedImage`). `onLoad` is unchanged. SDWebImage is gone from `Package.swift`.
35. `feature-profile-ai-spm` links the local package at `../AI-Profile`. `Modules/ProfileV3Host` is the copied bridge and is a synchronized root on the VDCApp target. `AppDelegate` calls `VDCProfileV3Composition.configure()` at the start of `didFinishLaunching`. The three call sites import `AIProfile` and drop `repository:`. `makeHubSurface` is wrapped in `MainActor.assumeIsolated`. The old ProfileV3 group `A11EFA112F99000000000B01` is off the target. The folder is still on disk. `ProfileV3MapperTests.swift` is excluded from the VDCAppTests synchronized membership so that target does not compile it against the removed module.
36. Identity Capture is copied to `/Users/aravindh/Desktop/Atlys/IdentityCapture`. AIProfile can depend on that package for the capture flow once the app-only files are out of it. The visa funnel stays in the app and calls the same package. See the IdentityCapture package's working notes for the seams.
37. **Relationship moved into each traveller's editor (backend note, 2026-10-14; package-only change, not in the app's ProfileV3).** `GET board/edit-traveler` no longer sends `relationship_picker`; each co-traveller row carries `edit_relationship {label, next:{go:"edit_field", field:"relationship", profile_id}}` plus `relationship` (current value). The main traveller gets neither.
    - Decoding: `ProfileV3TravellerRowDTO.editRelationship` maps to `ProfileV3TravellerRow.relationshipEntry` (`ProfileV3RelationshipEntry`, label and profile id). Main rows, and CTAs for another field, map to nil. The picker DTO, `ProfileV3RelationshipPicker`, the list chips, `savingRelationshipID`, and the three `Traveller.relationship*` size tokens are deleted.
    - Editor: `ProfileV3API.editField(_:profileID:)` adds `?profile_id=`. Only `loadTravellerRelationship(profileID:)` passes one. Residence, citizenship and contact still send none, because settings always opens for the main traveller and the note says the editor returns 409 for the main. `ProfileV3EditField` gained `.singleSelect`, `options` (`Option` value/title/isSelected, decoded from `value` + `title`/`label` + `selected`), `selectedValue` (selected option, else `current` if it is an option) and `submitProfileID` (`submit.profile_id`).
    - UI: `ProfileV3EditTravellerFormView` shows a Relationship row under the names (server label, value from the option titles cached after the editor loads, else the humanised value), styled like the add-traveller citizenship field. Tapping pushes `.travellerRelationship(profileID)` (full height): `ProfileV3TravellerRelationshipView` with flow-layout `ProfileV3Chip`s and the server's submit label, falling back to `confirmEdit`. Confirm saves through `saveTravellerRelationship` (`edit_profile_field`, unchanged), re-fetches `edit-traveler`, then pops back to the editor. Failure flashes `saveFailed`. Load errors (422 missing id, 409 main, 404 unknown) show the retry state. No new strings.
    - Verified: package build-for-testing clean, and `ProfileV3TravellerRelationshipTests` (7) passed on a throwaway iOS 26.5 simulator. Not run in the app.
38. **Full-height sheet screens fill their stack; connector deck colours match Figma (2026-10-14 evening, package-only).**
    - `ProfileV3TravellerRelationshipView` and `ProfileV3AddTravellerView` now end in `.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)`. Both are `isFullHeight` destinations whose loading state is a fixed-height `ProfileV3LoadStateView`; the `NavigationStack` centred the short VStack, which showed as a large gap above the chrome while loading. The edit-traveller form never had this because `ProfileV3FocusScroll(fillsViewport: true)` fills.
    - `ProfileV3ConnectorDeckCard`: the rim outer ellipse is `Palette.connectorRim` (#D9D9D9, was the beige `podiumShadowStart`); `rim(mouth:)` takes the inner gradient: the rest near rim keeps `connectorDeckPodiumRim` (#666→black), the far rim (the top opening once risen) uses `connectorDeckWellMouth` (black→#666, the Figma asset is mirrored), the second podium uses `connectorDeckPodiumMouth` (#F5F5F5→#999797). Both bodies get `connectorDeckPodiumSheen` (horizontal, #C3BBBB at 20% centred) as an overlay, and the 731pt well body uses `connectorDeckWellBody`, lit at both ends, so the paired stage's visible end no longer renders black. Values come from the SVG assets in Figma frame `765:24259` and pixel samples of the final-state mock. The same edit made earlier in the app's dead `Modules/ProfileV3` was reverted there.
    - Verified: `xcodebuild … build` exits 0 with no warnings. Not run on device.
39. **Restart goes through the app host (package-only).** `ProfileV3NavigationHost`, its placeholder, and `ProfileV3RestartCover` are deleted, and `ProfileV3Environment` lost its `navigation:` parameter. `ProfileV3AppHost.restartSplash(onFinish:)` became `restartApp()`. The settings presenter waits for pending writes, closes, then calls `app.restartApp()`; the package no longer draws a splash cover over the restart. In `AppIntegration`, `VDCProfileV3NavigationHost` is deleted and `VDCProfileV3AppHost.restartApp()` posts `RestartApp`. This is a breaking public change: the app's `Modules/ProfileV3Host` on `feature-profile-ai-spm` still passes `navigation:` and implements `restartSplash`, so it needs the same three-file change before it resolves a package `master` that has this commit. Verified on 2026-10-15: `xcodebuild … build` exits 0 with no warnings.

The 2026-10-14 build (`xcodebuild`, continue-after-errors) of the extracted tree had 24 error lines. No `UserData`, `Country`, or other account symbols remain. A later build of the working tree exits 0 with no warnings. The `URL`, Moya `Task`, and 401 token-refresh fixes are in `b611483`; see item 22.

### Upstream drift

As of 2026-10-14 (evening) the app's ProfileV3 is at `9e92cb981` and its working tree is clean; a connector-deck colour edit made there by mistake was ported into the package (Done item 38) and reverted in the app. The last three ProfileV3 commits were checked. `69d7cc023` (relationship chips, ITR capture, connector badge) and `19c657bd7` (globe hand-off, Reserve intro gate removed) were already in the package. `9e92cb981` is now ported; see Done item 31. Its mapper test is the piece still only in the app.

On 2026-10-15, at the user's request ("this is the old branch, the changes are needed here too"), Done item 37 (relationship editor) was ported into the app's `Modules/ProfileV3` on `feature-profile-ai`, uncommitted. The app copy now differs from the package only by the existing `Country`/`ProfileV3Country` lines and the networking layer: `ProfileV3APIEndpoint.editField(_:profileID:)` adds the `profile_id` query item. `VDCAppTests/ProfileV3MapperTests.swift` drops `testEditTravellersReadsRelationshipChips` and adds six relationship tests, 67 in all; they typecheck but were not run in the app. Porting recipe: run `git diff --relative=Sources/AIProfile -- <files>` here, then `git apply --directory=VDCApp/Modules/ProfileV3` in vdcios. Hunks that touch `Country` lines fail and are ported by hand.

Later on 2026-10-15 the user asked for the "tunnel animation" changes too. Those are the connector-deck colours from Done item 38: `ProfileV3ConnectorDeckCard`, five `Palette.connector*` colours, and the `connectorDeckWellMouth`/`PodiumMouth`/`WellBody`/`PodiumSheen` gradients in `Theme+Settings`. They were re-applied to the app copy on `feature-profile-ai` (uncommitted) from `git diff HEAD` here, which covers staged and unstaged work. The deck card, `Theme+Settings` and every other connector, motion and size file are now identical in both copies. `Theme+Palette` differs only by the package-only `floatingControlInk`. The app's Profile V3 typechecks in debug and release. Not ported: the `ProfileV3AddTravellerView` full-height frame fix from item 38, and the package-only host refactor (navigation host and restart cover removal).

### A. Compile blockers

None. The package builds with no warnings.

### B. App integration

Committed in vdcios on `feature-profile-ai-spm`: `c2228520b` (host copy, `configure()`, the three call sites, local link) and `50ce1e9e1` (switch to the remote repo). See Done items 32–35. The 2026-10-14 `xcodebuild` of the VDCApp scheme succeeded.

Still open:

1. **CI and distribution.** Resolved for CI by vdcios `50ce1e9e1`: the app references `https://github.com/atlyslabs/AI-Profile` on branch `master`. Still open: a branch reference moves with every push, so switch to a tagged version before release.
2. **Xcode on CI.** The CI workflows run on self-hosted Mac minis and don't pin Xcode. If any of them is on Xcode 26, lower `swift-tools-version` to 6.2. `ApproachableConcurrency` needs 6.2, and the manifest's trailing commas need 6.1.
3. **Tests.** `VDCAppTests/ProfileV3MapperTests.swift` (812 lines at `9e92cb981`) is excluded from the test target so it does not compile against the removed module. Move it into `Tests/AIProfileTests`, switch it to `@testable import AIProfile`, and retype the `Country?` at line 489 to `ProfileV3Country?`. Drop `testEditTravellersReadsRelationshipChips`: the picker it covers was removed (Done item 37), and `ProfileV3TravellerRelationshipTests` replaces it.
4. **Delete the old module.** `Modules/ProfileV3` is unlinked and still on disk. The VDCApp build succeeded without it. Delete the folder, then freeze that copy.
5. **Sync the app's host copy.** `vdcios/VDCApp/Modules/ProfileV3Host` on `feature-profile-ai-spm` predates Done item 39. Before that branch resolves a package `master` that includes item 39, copy `AppIntegration/ProfileV3Host/VDCProfileV3AppHost.swift` and `VDCProfileV3Composition.swift` over, and delete `VDCProfileV3NavigationHost.swift`.

### Decisions pending

1. **Distribution:** decided in vdcios `50ce1e9e1`: the remote atlyslabs repo, branch `master`. Pending: when to pin a version tag instead.
2. **Identity Capture inside AIProfile:** depend on the `IdentityCapture` package directly for `IDCFactory`, `IDCFlowView`, and `IDCConfiguration`. Do not keep `ProfileV3IdentityCaptureHost` once those types are in the package. `Application/` and the OCR verifiers are in `IdentityCapture/AppIntegration` and are not compiled. The debug screen, the on-device checkers, the KYC passport guide, analytics, and `AVNavigationViewController` still need to leave the package sources.
3. **Settings status messages:** `FlashMessageGenerator` returns early unless DEBUG, so in Release only the haptic plays. Either keep that through the host, or show the text in Release with `ProfileV3Toast`, which first needs a failure style.

### Known trade-offs

- The backend error `code` from the gmail-connector envelope is lost, because `ATCoreServerError` carries only a message and a status. User-facing messages survive through the envelope plugin. Analytics reports `conflict` and `server` instead of the specific code. Restoring it needs ATCore to carry the response body.
- `ATCoreCacheConfig` defaults to an expiration of `7 * 24 * 60` seconds, about 2.8 hours, which looks like a units slip. The package passes an explicit seven-day expiry. Worth raising with the ATCore owners.
- On the first launch after switchover the board comes from the network, because its cache moves from `DataManager` to ATCore's persistent cache. The old `DataManager` entries are orphaned.

## Gotchas

- The app's ProfileV3 is still changing, so diff before editing. See Building.
- Errors hide errors. See the stub build in Building.
- The main app target builds in Swift 5.0 without approachable concurrency. The `SWIFT_APPROACHABLE_CONCURRENCY` lines in the pbxproj belong to a different target.
- `ATCoreCacheService.shared` sweeps entries older than 15 minutes, and it hashes plain `String` keys with a per-process `Hasher`. Use `.persistent` with `ATCoreDeterministicCacheKeyProvider` keys.
- ATCore only reads flat `message` or `error` strings from error bodies.
- `KYCOnboardingCoordinator` starts its flow from a task that holds the coordinator weakly, so the caller must keep it alive until the flow ends.
- The settings presenter defers `onFinish` while KYC onboarding runs, and reports it exactly once.
- Four files use ATUIKit's `Color(at:)` without `import ATUIKit`: `ProfileV3PassportScanLauncher`, `Components/ProfileV3DurationWheel`, `Support/ProfileV3Theme+SettingsPage` and `Support/ProfileV3Theme+PastTripsSizes`. They compile only because extension members leak across files, and would break under `MemberImportVisibility`.
- In Claude Code, parallel shell commands share one working directory, so use absolute paths. zsh doesn't split unquoted variables into words, so put flag arrays in bash scripts.

## Verifying the app-side code

The app-side files can't build inside the package. They were typechecked with a two-stage harness before the local package was linked. The harness needs a refresh against the real package once the VDCApp build has run.

1. Build a stand-in `AIProfile` module in Swift 6 mode with `ApproachableConcurrency`. Use the `Host/*.swift` files except `ProfileV3Environment.swift`, the public types from `Domain/ProfileV3KYCCapture.swift` plus `ProfileV3PassportSide`, and a stub with the real public signatures of `ProfileV3Environment` and `ProfileV3EntryPoint.configure`.
2. Typecheck `AppIntegration/ProfileV3Host/*.swift` against it in Swift 5 mode. Include these real app sources: KYC `Domain/Models/` KYCConnectorStep, KYCPassportStep, KYCPassportUpload and KYCMinimal; `KYCCaptureCopy` extracted from `KYCStep.swift`; the particle-globe section of `KYCValueCardView.swift`; IdentityCapture `Domain/` IDCConfiguration, IDCCallbacks, IDCPiece and IDCVerifier. Add stubs copied from the real signatures for the KYC views, coordinator, factory, OAuth and analytics, the IDC factory, view model and view, `IDCStrings`, `IDCTheme`, AppDelegate, `APIConstants`, `HomeIdentityProvider`, `AnalyticsEventManager`, `UserData` and `GuestSession`.

Both stages passed with no errors or warnings. The harness needs `-I` and `-F` pointing at the package build products, and `-Xcc -fmodule-map-file=` for every module map in `GeneratedModuleMaps-iphonesimulator` except `AIProfile.modulemap`. It also needs the CocoaLumberjack include directories. The original script was `harness-build.sh` in a temporary session scratchpad and may be gone.
