# Nevis Mobile Authentication SDK iOS Example App

## Project Overview

A native iOS (Swift 6, UIKit) example app that shows how to integrate the Nevis Mobile Authentication SDK, a FIDO UAF 1.1 based SDK for passwordless authentication. It is meant as a learning resource and a source of integration code for customer apps. It is not a production-ready app.

The repository contains three apps that work together:

- **`NevisExampleApp`**: the iPhone app. It runs every SDK operation.
- **`NevisExampleShareExtension`**: a share extension (SwiftUI) that authenticates with the accounts registered in the containing app, through a shared keychain access group.
- **`NevisExampleWatchApp`**: a watchOS app (SwiftUI). The SDK is not available on watchOS, so the watch delegates authentication to the iPhone app over WatchConnectivity.

Flows demonstrated in the iPhone app:

- Client initialization (`MobileAuthenticationClientInitializer`)
- Registration
  - in-app with Authentication Cloud (`authCloudApiRegistration`, using an enrollment response or an `appLinkUri`)
  - in-app with an Identity Suite backend (`registration` with a `CookieAuthorizationProvider` after a username/password login)
  - out-of-band through a QR code, a deep link or pending operations
- Authentication: in-band, out-of-band (QR code / deep link), and transaction confirmation
- Deregistration of one account or all accounts, and deleting local authenticators
- Changing the PIN and the password
- Changing device information
- Fetching pending out-of-band operations
- Reading local data and `MetaData` (SDK version, facet ID)
- Authentication without the app's screens (`HeadlessAuthentication`), used by the share extension and on behalf of the watch

Paradigm: **MVP with a coordinator**, wired up with Swinject. The SDK has a callback-based Swift API, and the app uses it directly:

- Presenters (`Screens/<Name>/<Name>Presenter`) start the SDK operations with the builders of `client.operations` and pass the interaction objects (selectors, enrollers, verifiers) that Swinject injects.
- When the SDK needs user input, an interaction implementation (`Interaction/`) wraps the SDK **handler** in a navigation parameter and calls `AppCoordinator`. The target screen's presenter completes the handler with the user's input.
- The headless flows (share extension, watch) wrap the operation in `async`/`await` with `withCheckedThrowingContinuation`.

For a reactive (RxSwift) variant of the iPhone app, see the [RxSwift iOS example](https://github.com/nevissecurity/nevis-mobile-authentication-sdk-example-app-ios-rx). It has no share extension or watch app.

The example covers only part of the SDK. For features that are not shown here, use the documentation at https://docs.nevis.net/mobilesdk. Don't infer SDK behavior from memory.

## SDK & Related Resources

How the SDK is consumed:

- **Swift Package Manager**, from https://github.com/nevissecurity/nevis-mobile-authentication-sdk-ios-package, pinned to an **exact version** (currently `4.6.0`, see the package references in `NevisExampleApp.xcodeproj`). The package has two products, and SPM can't link per build configuration, so there are **two iPhone app targets**:
  - `NevisExampleApp-Debug` links `NevisMobileAuthentication-Debug`. This is the **debug flavor**: it runs on devices and simulators, has logging, and only a subset of the protection mechanisms.
  - `NevisExampleApp` links `NevisMobileAuthentication`. This is the **release flavor**: all protection mechanisms are on, and it **runs on physical devices only**.
  - Both targets compile the same sources, have the same bundle ID, and embed the same share extension and watch app. The share extension doesn't link the SDK itself; it uses the framework embedded in the containing app (`LD_RUNPATH_SEARCH_PATHS` contains `@executable_path/../../Frameworks`).
- Other dependencies (also SPM): Swinject, SwinjectAutoregistration, Then, FittedSheets, KRProgressHUD, QRScanner, and the local `Packages/NevisExampleShared` package.
- See the [iOS installation guide](https://docs.nevis.net/mobilesdk/guide/installation/ios-installation) and [SDK flavors](https://docs.nevis.net/mobilesdk/guide/introduction#sdk-flavors).

Documentation (https://docs.nevis.net):

- [Quickstart: build the example and use it](https://docs.nevis.net/mobilesdk/quickstart)
- [Requirements](https://docs.nevis.net/mobilesdk/guide/requirements)
- [Configuration](https://docs.nevis.net/mobilesdk/guide/configuration) (Authentication Cloud, Identity Suite, custom backend, facet ID)
- [Initialization](https://docs.nevis.net/mobilesdk/guide/initialization)
- Operations: [registration](https://docs.nevis.net/mobilesdk/guide/operation/registration), [authentication](https://docs.nevis.net/mobilesdk/guide/operation/authentication), [deregistration](https://docs.nevis.net/mobilesdk/guide/operation/deregistration), [other operations](https://docs.nevis.net/mobilesdk/guide/operation/other-operations)
- [iOS App Extensions](https://docs.nevis.net/mobilesdk/concept/concept-description/ios-app-extensions) (keychain sharing, extension-specific `Configuration`)
- [Error handling](https://docs.nevis.net/mobilesdk/guide/error-handling), [best practices](https://docs.nevis.net/mobilesdk/guide/best-practices), [troubleshooting](https://docs.nevis.net/mobilesdk/appendixes/troubleshooting)
- Integration scenarios: [Authentication Cloud](https://docs.nevis.net/mobilesdk/integration-scenarios/authentication-cloud), [Identity Suite](https://docs.nevis.net/mobilesdk/integration-scenarios/identity-suite)
- [Push support](https://docs.nevis.net/mobilesdk/guide/push_support) (not implemented in this example)
- [Swift API reference (DocC)](https://docs.nevis.net/mobilesdk/api-references/swift/documentation/nevismobileauthentication/), [all API references](https://docs.nevis.net/mobilesdk/reference/api-references)
- [iOS release notes](https://docs.nevis.net/mobilesdk/release_notes/ios-release-notes)
- [Authentication Cloud documentation](https://docs.nevis.net/authcloud/)

Example apps on other platforms (same core feature set, useful for comparison):

- iOS, RxSwift: https://github.com/nevissecurity/nevis-mobile-authentication-sdk-example-app-ios-rx
- Android: https://github.com/nevissecurity/nevis-mobile-authentication-sdk-example-app-android
- Android, Kotlin Coroutines: https://github.com/nevissecurity/nevis-mobile-authentication-sdk-example-app-android-coroutines
- Flutter: https://github.com/nevissecurity/nevis-mobile-authentication-sdk-example-app-flutter
- React Native: https://github.com/nevissecurity/nevis-mobile-authentication-sdk-example-app-react

## Prerequisites & Configuration

Backend: either a **Nevis Authentication Cloud** instance (with an access key to start enrollments), or an **Identity Suite** setup (nevisFIDO behind nevisProxy/nevisAuth). See `README.md` § "Getting Started".

All configuration is **build-time only**. To point the app at your own environment:

1. **Pick the environment.** It is set in two places, and both must match:
   - `NevisExampleApp/Dependency Provider/AppAssembly.swift`: the `ConfigurationLoaderImpl(environment: .authenticationCloud)` registration (iPhone app and watch flow);
   - `NevisExampleShareExtension/Presentation/Screens/ShareScreen.swift`: the extension doesn't use Swinject and creates its own `ConfigurationLoaderImpl`.

   The environment selects which plist gets loaded (`Configuration/Model/Environment.swift`).
2. **Backend settings.** These live in `NevisExampleApp/Resources/`. The plists are copied into both the app and the share extension.
   - `ConfigAuthenticationCloud.plist`: replace `myinstance.mauth.nevis.cloud` in `sdk.hostName` (and in `login.loginRequestURL`).
   - `ConfigIdentitySuite.plist`: set `sdk.baseUrl` and, if your setup differs from the defaults, the endpoint paths (`registrationRequestPath`, `authenticationRequestPath`, …), timeouts and retries. Also set `login.loginRequestURL`.
   - `authenticatorAllowlist` lists the AAIDs that may be offered: `F1D0#1001` PIN, `#1002` Touch ID, `#1003` Face ID, `#1004` device passcode, `#1005` password.
   - The plist is decoded in `Configuration/Model/AppConfiguration.swift`. If `sdk.hostName` is present, the app uses `Configuration(authCloudHostname:)`; otherwise it decodes a full `Configuration`. The `sdk.appExtension` part is applied only when the code runs in the extension (`Bundle.main.isAppExtension`). See [Configuration](https://docs.nevis.net/mobilesdk/guide/configuration).
3. **Share extension keychain access.** In `sdk.appExtension` of the plist, set `applicationIdentifier` to the bundle ID of the containing app and `keychainAccessGroup` to `<TEAM_ID>.<applicationIdentifier>` (the `myteam` prefix is a placeholder). The group must match `keychain-access-groups` in `NevisExampleShareExtension/Resources/NevisExampleShareExtension.entitlements`. See [iOS App Extensions](https://docs.nevis.net/mobilesdk/concept/concept-description/ios-app-extensions).
4. **Identity Suite login (in-app registration only).** `Utility/Login/LoginServiceImpl.swift` posts to `loginRequestURL` with nevisAuth form fields (`isiwebuserid` / `isiwebpasswd`, see `Utility/Login/Model/LoginRequest.swift`). `UsernamePasswordLoginPresenter` turns the cookies into a `CookieAuthorizationProvider`. Adapt this to your login flow.
5. **Deep links.** In `NevisExampleApp/Resources/Info.plist`, change the `nevisaccess` custom URL scheme (`CFBundleURLTypes` → `CFBundleURLSchemes`) to your scheme.
   - `SceneDelegate` forwards incoming URLs. `DeepLink(url:)` only accepts URLs that carry a `dispatchTokenResponse` query parameter, and `OutOfBandOperationHandlerImpl` decodes the payload and starts the out-of-band operation.
   - Universal Links are not set up in this example. For them, add the Associated Domains capability and an `apple-app-site-association` file on your domain.
6. **Bundle IDs and facet ID.** The app bundle ID is `ch.nevis.mobile.authentication.sdk.ios.example`; the extension uses `<app>.extension`, the watch app `<app>.watchapp`. The iOS facet ID is `ios:bundle-id:<app bundle id>`, and the backend must list it, or operations fail with an untrusted facet ID error. The Home screen shows the facet ID of the running build (from `MetaData`). If you change the app bundle ID, also update the backend facet list, the `applicationIdentifier` / `keychainAccessGroup` in the plists and the extension entitlements. See [Facet ID](https://docs.nevis.net/mobilesdk/guide/configuration#facet-id).
7. **Signing.** `DEVELOPMENT_TEAM` is empty, and signing is automatic. Set your own team on all targets to run on a device. The watch app needs a provisioning profile for its own bundle ID.

## Build & Run Commands

`README.md` has the full setup. Quick reference:

```bash
open NevisExampleApp.xcodeproj   # Xcode resolves the SPM packages automatically (File > Packages to retry)
# Simulator: run the NevisExampleApp-Debug scheme. Device: either scheme.

# Command-line build check (no signing):
xcodebuild -project NevisExampleApp.xcodeproj -scheme NevisExampleApp-Debug \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build

# Unit tests of the shared package (messages, models, localization).
# Use xcodebuild: plain `swift test` doesn't compile the .xcstrings catalogs, so the localization tests fail.
cd Packages/NevisExampleShared && xcodebuild test -scheme NevisExampleShared -destination 'platform=macOS'

# Lint (the same rules the build phases apply):
swift format lint --strict --parallel --recursive \
  NevisExampleApp NevisExampleShareExtension NevisExampleWatchApp Packages/NevisExampleShared
```

Requirements: Xcode 26.2 or later (Swift 6). Deployment targets: iOS 15.6 (app and extension) and watchOS 10. Every target has a "Swift Format" build phase that runs `swift format --in-place` on its sources, so a build can reformat files; the rules are in `.swift-format` (tabs, line length 250). Apart from the shared package tests, there are no unit or UI test targets; to verify changes, run the app against a backend.

## Architecture

### Source layout

```
NevisExampleApp/
  AppDelegate, SceneDelegate     app entry (activates the watch session), URL handling
  Dependency Provider/           AppAssembly (Swinject registrations), DependencyProvider
  Configuration/                 ConfigurationLoader(+Impl), AppConfiguration, Environment, LoginConfiguration (shared with the extension)
  Coordinator/App/               AppCoordinator(+Impl): all navigation
  Screens/<Name>/                <Name>Screen (UIViewController) + <Name>Presenter; SDK operations start here
  Interaction/                   SDK callback implementations: AccountSelector, AuthenticatorSelector,
                                 Biometric/DevicePasscode user verifiers, Pin/ and Password/ enrollers, verifiers, changers,
                                 OutOfBandOperationHandler(+Impl) (QR code, deep link, pending operations)
  Headless/                      HeadlessAuthentication + headless selector/verifiers (shared with the extension)
  Watch/                         WatchSessionDelegate, WatchMessageHandler, WatchMessageSender (iPhone side of the watch flow)
  Model/                         Operation, OperationError, DeepLink, AuthenticatorItem
  Error/                         ErrorHandlerChain, NevisErrorHandler, GeneralErrorHandler
  Utility/                       Client Initializer/Provider, Login (Identity Suite), Validation, Extensions, UI, Logger, Localization
  Resources/                     Info.plist, Config*.plist, localization, launch screen
NevisExampleShareExtension/
  Presentation/Screens/          ShareScreen (principal class) → ShareView + ShareModel (SwiftUI)
  Service/                       AuthenticationService(+Impl): initializes the SDK, lists accounts, runs HeadlessAuthentication
  Resources/                     Info.plist (NSExtensionActivationRule), entitlements (keychain-access-groups)
NevisExampleWatchApp/
  Connection/                    PhoneSession(+Impl): WatchConnectivity on the watch side
  Presentation/, Model/          SwiftUI screens, WatchModel, state
Packages/NevisExampleShared/     platform-independent code used by all three targets:
                                 WatchMessage / PhoneMessage + MessageCoder, RegisteredAccount, AuthenticatorKind,
                                 CredentialPrompt, shared localizations; Tests/
```

Each target has a `Documentation.docc` catalog. The watch ↔ iPhone protocol is described in `Packages/NevisExampleShared/Sources/NevisExampleShared/NevisExampleShared.docc/MessageFlow.md`, the iPhone side in `NevisExampleApp/Documentation.docc/WatchCompanion.md`.

### How SDK callbacks reach the UI (iPhone app)

1. A presenter starts the operation, for example `SelectAccountPresenter` → `client.operations.authentication.username(...)...execute()`, with the injected interaction objects.
2. When the SDK needs user input, an interaction implementation (for example `AuthenticatorSelectorImpl`, `PinEnrollerImpl`) hops to the main actor (`Task { @MainActor in … }`) and calls `AppCoordinator.navigateTo…` with a parameter enum that carries the SDK context data and the **handler**.
3. The target screen's presenter completes the handler with the user's input, for example `SelectAuthenticatorPresenter` → `handler.aaid(...)`, `CredentialPresenter` → `handler.pin(...)`. Cancelling the screen calls `handler.cancel()`.
4. `onSuccess` / `onError` of the operation navigate to the result screen, or pass the error to `ErrorHandlerChain`.

Other details:

- **Named registrations**: there are two `AuthenticatorSelector` instances, `RegistrationAuthenticatorSelectorName` (`auth_selector_reg`) and `AuthenticationAuthenticatorSelectorName` (`auth_selector_auth`). They filter differently through `AuthenticatorValidator`.
- **Main actor**: screens, presenters and the coordinator are `@MainActor`. `AppAssembly` registers them with the `registerOnMain` / `autoregisterOnMain` helpers, which assume that resolution happens on the main thread.
- **Scopes**: `ClientProvider`, `ClientInitializer`, `AppCoordinator`, `WatchSessionDelegate` and `WatchMessageHandler` are registered with `.inObjectScope(.container)`, so they are singletons.
- **Initialization**: `HomePresenter.initClient` calls `ClientInitializerImpl.initialize()`, which loads the configuration, initializes the client once and stores it in `ClientProvider`. Concurrent calls share the same task. `WatchMessageHandlerImpl` calls the same initializer, because the system may launch the app in the background to deliver a watch message.
- **Environment-specific behavior**: with Identity Suite, deregistration first goes through account selection and in-band authentication, because the deregistration endpoint needs an `AuthorizationProvider`. With Authentication Cloud, deregistration is called directly (see `HomePresenter.deregister()`).

### Share extension and watch app

- **`HeadlessAuthentication.authenticate(...)`** runs an in-band authentication without the app's screens. The authenticator is chosen up front (`HeadlessAuthenticatorSelector`). The PIN or password is requested through a `CredentialProvider` closure. Face ID, Touch ID and device passcode use the system prompt. Lockout and cancel are mapped to `HeadlessAuthenticationError`.
- **Share extension**: `ShareModel` drives the SwiftUI UI, `AuthenticationServiceImpl` initializes its own SDK client with the extension `Configuration` (including `appExtension`), lists the accounts of the containing app and authenticates. A locked-out authenticator can be deleted. Registering and deregistering is not possible from the extension.
- **Watch app**: the watch sends `WatchMessage`s (`.accounts`, `.authenticate`, `.credential`, `.cancel`) as JSON with `sendMessageData`. `WatchSessionDelegateImpl` decodes them on the iPhone, and `WatchMessageHandlerImpl` replies immediately and pushes the progress (`.credentialRequired`, `.continueOnPhone`, `.authenticated`, `.failed`) with `WatchMessageSender`. PIN and password are entered on the watch; biometric and device passcode verification happens on the iPhone, so the handler waits (up to 25 s) until the iPhone app is in the foreground. Only one authentication can run at a time.

## Integration Guidance

When moving code into your own app:

| If you want to… | Look at | Notes |
|---|---|---|
| Add the SDK dependency | Package references in `NevisExampleApp.xcodeproj` | Use a separate debug target for the debug flavor; see [installation](https://docs.nevis.net/mobilesdk/guide/installation/ios-installation). |
| Configure the backend | `Resources/Config*.plist`, `AppConfiguration`, `ConfigurationLoaderImpl` | Or construct `Configuration` in code; see [Configuration](https://docs.nevis.net/mobilesdk/guide/configuration). |
| Initialize the SDK once | `ClientInitializerImpl`, `ClientProviderImpl` | `async` wrapper around `MobileAuthenticationClientInitializer`. |
| Bridge SDK callbacks to UI | `Interaction/`, `AppCoordinator`, the presenters | Reusable pattern; replace the coordinator and screens with your own. |
| Register with Authentication Cloud | `AuthCloudApiRegistrationPresenter` | Your backend gets the enrollment response / `appLinkUri` from Authentication Cloud. |
| Register with Identity Suite | `UsernamePasswordLoginPresenter`, `LoginServiceImpl` | Replace the login call with your own; keep the `AuthorizationProvider` idea. |
| Handle QR codes / deep links / pending operations | `OutOfBandOperationHandlerImpl`, `DeepLink`, `SceneDelegate`, `HomePresenter.fetchPendingOperations()` | QR scanning (`Screens/Qr Scanner/`, QRScanner) is demo scaffolding. |
| Authenticate in-band | `SelectAccountPresenter` | |
| Authenticate without UI / with `async`/`await` | `Headless/` | Reusable as is for extensions and companion devices. |
| Pick the authenticator | `AuthenticatorSelectorImpl`, `AuthenticatorValidator` | Reusable filtering logic; replace the UI. |
| Enroll, verify or change a PIN/password | `Interaction/Pin/`, `Interaction/Password/`, `CredentialPresenter` | Recoverable errors and protection status (lockout/cool-down) come with the contexts. |
| Face ID / Touch ID / device passcode | `BiometricUserVerifierImpl`, `DevicePasscodeUserVerifierImpl` | Customize the prompt texts. |
| Transaction confirmation | `AccountSelectorImpl`, `TransactionConfirmationPresenter` | [Transaction confirmation](https://docs.nevis.net/mobilesdk/concept/operations/transaction-confirmation) |
| Deregister / delete authenticators / device info | `HomePresenter`, `SelectAccountPresenter`, `ChangeDeviceInformationPresenter` | |
| Use registrations in an app extension | `NevisExampleShareExtension/`, `AppConfiguration`, the extension entitlements | Shared keychain access group + `Configuration.AppExtension`; see [iOS App Extensions](https://docs.nevis.net/mobilesdk/concept/concept-description/ios-app-extensions). |
| Authenticate from an Apple Watch | `NevisExampleApp/Watch/`, `NevisExampleWatchApp/`, `Packages/NevisExampleShared` | The SDK runs on the iPhone only; the watch is a remote UI. |
| Push notifications | Not implemented | See [Push support](https://docs.nevis.net/mobilesdk/guide/push_support). |

Demo-only code that should not be copied as is:

- the logging screen (`Screens/Logging/`)
- showing raw technical errors to users (see [Error handling](https://docs.nevis.net/mobilesdk/guide/error-handling))
- the hard-coded login request
- the UI components and styling (`Utility/UI/`, the SwiftUI components of the extension and the watch app)
- the placeholder URL scheme, host names and keychain access group
- the share extension's `NSExtensionActivationRule`, which accepts text, a web URL or an image without processing the content
- sending the PIN or password from the watch to the iPhone in plain text over WatchConnectivity (see the warning in `README.md`)

If something isn't covered here, check https://docs.nevis.net (guide + DocC API reference) before you write code. Don't guess the API.

## Conventions & Gotchas

- **Simulator vs. device**: only the `NevisExampleApp-Debug` target (debug flavor) runs on simulators. The `NevisExampleApp` target links the release flavor, which **does not run on simulators**, regardless of the build configuration.
- **Keep the two app targets in sync**: a new app source file, resource or package product must be added to both `NevisExampleApp` and `NevisExampleApp-Debug`. Files used by the extension (`Configuration/`, `Headless/`, some `Utility/Extensions/`) are also members of `NevisExampleShareExtension`. A file that exists on disk but is missing from a target is not compiled there.
- **Environment in two places**: changing the environment only in `AppAssembly` leaves the share extension on the other plist (see Configuration step 1).
- **Extension configuration**: the containing app must not use `Configuration.AppExtension`; `AppConfiguration` strips it unless `Bundle.main.isAppExtension`. Keep that check when you change the decoding.
- **Device passcode prerequisite**: biometric and device passcode authenticators need a device passcode to be set. Face ID / Touch ID also need enrolled biometrics. On the simulator, enroll and trigger Face ID / Touch ID through *Features → Face ID / Touch ID*. See [Device lock screen](https://docs.nevis.net/mobilesdk/concept/concept-description/key-protection/device-lock-screen).
- **`NSFaceIDUsageDescription` and `NSCameraUsageDescription`** must stay in the app's `Info.plist` (and `NSFaceIDUsageDescription` in the extension's). Without them, iOS terminates the process when Face ID or the QR scanner is used.
- **Watch flow**: the iPhone app must be launched once after installation before the watch can reach it. The system prompt for biometrics can only appear while the iPhone app is in the foreground.
- **Handlers are single-use**: every SDK handler must be completed or cancelled exactly once, or the operation hangs. The same applies to the continuations in the `async` wrappers: resume each one exactly once (see `WatchMessageHandlerImpl.resumeCredential` / `resumeActive`).
- **Concurrency**: the project uses Swift 6 strict concurrency. SDK callbacks are not guaranteed to arrive on the main thread; hop to the main actor (`Task { @MainActor in … }`) before touching UI or `@MainActor` state, as the interaction implementations do.
- **SDK version**: the SDK package is pinned to an exact version in the project. When upgrading, update the package reference (and `Package.resolved`), and check the [iOS release notes](https://docs.nevis.net/mobilesdk/release_notes/ios-release-notes).
- **Code style**: `swift format` with `.swift-format` (tab indentation). Document types and members with `///` comments; DocC sources are in the `Documentation.docc` catalogs.
- **Never commit secrets** (signing certificates, provisioning profiles, tokens, a real team ID in the plists) or personal Xcode state (`xcuserdata/`).
