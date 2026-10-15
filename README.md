# AIProfile

**Not yet versioned** — the Atlys AI Profile: the profile hub with its world-pass cards and globe,
settings, travellers and their relationships, loyalty programmes, past trips, KYC capture and the
profile agents, extracted from the VDC app's `Modules/ProfileV3` into a standalone SPM package. The
module is `ATAIProfile`; its types keep the app's `ProfileV3` prefix. There is no release tag yet,
so hosts track `master`.

```swift
.package(url: "https://github.com/atlyslabs/AI-Profile.git", branch: "master")
.product(name: "ATAIProfile", package: "AI-Profile")
```

iOS 17+, Swift 6 language mode with the `ApproachableConcurrency` upcoming feature, and
`swift-tools-version: 6.4`, so it needs Xcode 27. It depends on ATCore 1.0.16, ATUIKit 1.3.7,
ATAuthKit 1.0.44, DittoRuntimeStrings (ditto-migrate-toolkit 0.0.1), PhoneNumberKit 3.6.0, Nuke
12.0.0 and Moya 14.0.0, all `from:`. A host that already uses them resolves one copy of each.

Architecture rule this package follows: **only the profile surface lives here.** Sign-in and user
data, KYC onboarding, identity capture, the globe's land, the coupons screen, logout, restart and
the navigation chrome are the host app's job. The package reaches each of them through a host
protocol — see "Deliberately out of scope" below.

## What's in here

- `Sources/ATAIProfile/Domain`, `Data`, `Presentation`, `Views` and `Components` — the profile
  feature itself, ported from the app's `Modules/ProfileV3`: board, traveller, agent and settings
  models, DTOs and mappers, repositories, view models and presenters, the hub, settings and agent
  screens, and the cards, globes and controls they are built from.
- `Sources/ATAIProfile/Host` — the host bridge: every protocol the host implements, the value types
  that cross it, and `ProfileV3Environment`, which carries them in. DEBUG-only placeholders stand in
  for the KYC host, analytics and field validation, and a dotted placeholder draws the globe, so
  SwiftUI previews run without `configure`.
- `Sources/ATAIProfile/Networking` — the API on ATCore: a Moya target for the gmail-connector board
  and KYC endpoints, the Slack alert and the pensieve profile edit, the network client, and the
  board's disk cache (ATCore's persistent cache, seven-day expiry).
- `Sources/ATAIProfile/Support`, `Resources` and `Generated` — theme, strings, analytics and
  helpers; the asset catalog and the `ProfileV3Localizable` string catalog; the SwiftGen string
  accessors, which read through a `DittoRuntimeStrings` loader for the Ditto project `ai-profile`.
- `AppIntegration/ProfileV3Host` — the VDC app's own implementation of every host (`VDCProfileV3*`)
  and `VDCProfileV3Composition.configure()`. It is not compiled by the package; the app keeps its
  copy in `VDCApp/Modules/ProfileV3Host`.

## Bootstrapping a host

1. Implement the host protocols (see "What the host must still provide") and pass them to
   `ProfileV3EntryPoint.configure(_:)` once at launch, on the main actor, before any other entry
   point. Until then every entry point stops with a `preconditionFailure`.

   ```swift
   import ATAIProfile

   ProfileV3EntryPoint.configure(ProfileV3Environment(
       baseProvider: MyBaseProvider(),
       session: MySession(),
       kyc: MyKYCHost(),
       identityCapture: MyCaptureHost(),
       globe: MyGlobeRenderer(),
       analytics: MyAnalytics(),
       validation: MyFieldValidator(),
       account: MyAccountHost(),
       coupons: MyCouponsHost(),
       app: MyAppHost(),
       countries: myCountries
   ))
   ```

   `appVersion` (sent as `x-app-version`, defaulting to the bundle's short version) and extra Moya
   `plugins` are optional.

2. Show the profile. The package pushes, pops and presents on the navigation controller passed in,
   and the hub draws its own chrome, so push it with the navigation bar hidden, as the VDC app does:

   ```swift
   let hub = ProfileV3EntryPoint.makeHub(navCon: navigationController, entrySource: .accountSettings)
   navigationController.pushViewController(hub, animated: true)
   ```

   `makeHubSurface(navCon:onClose:)` returns the same hub as an `AnyView` for a SwiftUI host — the
   VDC app embeds it as the chat funnel's profile tab. `presentAddTraveller(navCon:)` opens the
   add-traveller sheet straight from a deep link, and `prefetchBoard()` warms the board cache before
   the hub opens. `ProfileV3EntrySource` (`.chat`, `.accountSettings`, `.deepLink`) is sent with the
   hub's analytics.

   `makeHub` and `prefetchBoard` are `nonisolated`, so a Swift 5 caller reaches them without
   `await`. `makeHub` still has to run on the main thread and traps anywhere else. `configure`,
   `makeHubSurface` and `presentAddTraveller` are main-actor.

## Auth-token flow

Every request goes through `ProfileV3NetworkClient`, built on ATCore's request executor with three
plugins. `ATCoreAuthPlugin` stamps `Authorization: Bearer …` from the base provider's `userToken`;
every Profile V3 target requires auth. A headers plugin adds `x-platform: ios` and `x-app-version`.
An envelope plugin copies the gmail-connector error message into `ATCoreServerError`, so the screens
show the backend's own text. On a 401 the package refreshes the Firebase ID token through
`ATAuthKit.currentUser` and retries the request once. Beyond ATAuthKit the package takes no auth
dependency; the host only supplies the current token.

## What the host must still provide

| Parameter | Type | What it covers |
|---|---|---|
| `baseProvider` | `ATCoreBaseProvider` | Base URL, user token and residency code for ATCore networking |
| `session` | `ProfileV3SessionProviding` | Current user id, and whether the session is a guest |
| `kyc` | `ProfileV3KYCHost` | KYC onboarding, minimal capture, the Gmail, ITR, passport and selfie step screens, Gmail authorization, KYC events |
| `identityCapture` | `ProfileV3IdentityCaptureHost` | Passport and photo capture with a `verify` closure, full screen or embedded |
| `globe` | `ProfileV3GlobeRendering` | Preparing and drawing the globe's land |
| `analytics` | `ProfileV3AnalyticsReporting` | Every Profile V3 event |
| `validation` | `ProfileV3FieldValidating` | Email and passport-number checks |
| `account` | `ProfileV3AccountHost` | A snapshot of the signed-in user, saving residence, citizenship and contact, the duplicate-contact check, and a notice when a traveller changes |
| `coupons` | `ProfileV3CouponsHost` | Presenting the host's coupons screen |
| `app` | `ProfileV3AppHost` | Status messages, logout, app restart, and the bottom clearance of a floating tab bar |
| `countries` | `[ProfileV3Country]` | The country list for pickers, currency and lookups: ISO code plus English name |

- Two images in the host's asset catalog, `WhatsApp` and `reserve_logo_clear`. Every other image
  ships in the package bundle, and remote art loads with Nuke from
  `ik.imagekit.io/atlys/b2c/profile-v3`.
- The Inter, Denton and Dotline fonts, registered by the host. Inter and Denton go through
  ATUIKit's `Font.inter` and `Font.denton`, which also carry their own copies. Without Dotline the
  world-pass number falls back to the system font.
- A navigation controller already on screen, with its bar hidden while the hub shows.

## Also public

- `ProfileV3NetworkClient`, exposed as `ProfileV3Environment.client` — the client the package
  builds from `baseProvider`, `appVersion` and `plugins`.
- The value types that cross the host protocols: `ProfileV3KYC`, `ProfileV3IdentityCapture`,
  `ProfileV3Globe`, `ProfileV3AccountSnapshot`, `ProfileV3StoredTraveller`, `ProfileV3Country`,
  `ProfileV3FlowOutcome` and `ProfileV3PassportSide`, plus the KYC capture screen data
  (`ProfileV3Capture*` and `ProfileV3ConnectorState`).

## Deliberately out of scope

- **KYC onboarding and the KYC step screens.** The app's KYC module stays in the app. The package
  keeps its own capture state machine and API (`ProfileV3KYCCaptureViewModel`) and asks
  `ProfileV3KYCHost` for onboarding, the minimal capture flow and the four step screens.
- **Identity capture.** The passport and photo camera flow is the host's, through
  `ProfileV3IdentityCaptureHost`. The package may later depend on the ATCaptureKit package for it
  instead.
- **The globe's land.** The host draws land through `ProfileV3GlobeRendering`. The package owns the
  pose, the projection, the ocean, shading and markers, and the hand-off between the card, hero and
  detail globes.
- **User data and the country catalogue.** The host maps its user model into
  `ProfileV3AccountSnapshot` and its countries into `[ProfileV3Country]`. The package keeps the
  phone parsing, the contact-update outcome and the two profile writes to pensieve.
- **The coupons screen.** `ProfileV3CouponsHost` presents the host's own screen. The package's
  `ProfileV3CouponsListView` is the hub's coupon list, a different screen.
- **Logout, restart, status messages and the floating tab bar.** `ProfileV3AppHost` owns them. A
  restart is a request to the host; the package draws no splash of its own. For status messages the
  package plays the haptic and the host shows the text.
- **Navigation chrome.** The package works on any `UINavigationController` and never changes its
  bar or swipe-back gesture; it only hides the bars of its own SwiftUI navigation stacks. Custom
  bars, swipe-back policy and restart screens stay with the host.

## Building and testing

```sh
xcodebuild -scheme ATAIProfile -destination 'generic/platform=iOS Simulator' build
xcodebuild -scheme ATAIProfile -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```

The tests use swift-testing.
