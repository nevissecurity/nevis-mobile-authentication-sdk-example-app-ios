# ``NevisExampleShareExtension``

A share extension demonstrating how to authenticate with the Nevis Mobile Authentication SDK from an app extension.

## Overview

The extension runs the SDK in companion mode: it uses the registrations created by the containing app instead of
having its own. Registering or deregistering accounts is only possible in the containing app.

You can read more about using the SDK in app extensions in the
[iOS App Extensions](https://docs.nevis.net/mobilesdk/concept/concept-description/ios-app-extensions) concept description.

The extension demonstrates:

* Initializing the SDK with an app extension specific configuration.
* Listing the accounts registered in the containing app, together with their usable authenticators.
* Authenticating the selected account with Face ID, Touch ID, Device Passcode, PIN or password.
* Showing the remaining tries and the cooldown of the PIN and Password authenticators.
* Deleting a locked out authenticator from the device. The registration on the server is not removed.

### Configuration

The configuration is shared with the containing app, see ``ConfigurationLoaderImpl``. The `appExtension` part of the
configuration file must point to the keychain access group of the containing app, in the
`<TEAM_ID>.<applicationIdentifier>` form, and the same group must be listed in the `keychain-access-groups`
entitlement of the extension.

### Architecture

- ``ShareScreen`` is the principal class of the extension. It hosts ``ShareView`` and completes the extension request.
- ``ShareModel`` drives the flow and exposes its state as a ``Status``.
- ``AuthenticationService`` wraps the SDK operations with async functions. Its ``AuthenticationServiceImpl``
  implementation runs the authentication with ``HeadlessAuthentication``, which is shared with the iPhone app (it
  authenticates on behalf of the watch the same way).
- PIN and password entry is bridged from the SDK callbacks to the UI with a ``CredentialProvider``: the verifier
  sends a `CredentialPrompt` and waits until the user submits or cancels the credential in the ``CredentialCard``.
- The platform independent models (`RegisteredAccount`, `AuthenticatorKind`, `CredentialKind`, `CredentialPrompt`)
  and their localizations come from the `NevisExampleShared` package, which is shared with the watch app.

## Topics

### Extension

- ``ShareScreen``

### Configuration

- ``ConfigurationLoader``
- ``ConfigurationLoaderImpl``
- ``AppConfiguration``
- ``LoginConfiguration``
- ``Environment``

### Headless Authentication

- ``HeadlessAuthentication``
- ``HeadlessAuthenticationError``
- ``HeadlessAuthenticatorSelector``
- ``HeadlessBiometricUserVerifier``
- ``HeadlessDevicePasscodeUserVerifier``
- ``HeadlessPasswordUserVerifier``
- ``HeadlessPinUserVerifier``

### Models

- ``CredentialProvider``
- ``ExtensionError``
- ``Status``

### Components

- ``CardHeader``
- ``CardStyle``
- ``CheckmarkModifier``
- ``CredentialCard``
- ``Icon``
- ``InfoCard``
- ``OutlinedButton``
- ``OutlinedButtonStyle``
- ``SingleSelectionList``

### UI

- ``ShareView``
- ``ShareModel``

### Service

- ``AuthenticationService``
- ``AuthenticationServiceImpl``
- ``AuthenticationServiceError``

### Localization

- ``L10n``
