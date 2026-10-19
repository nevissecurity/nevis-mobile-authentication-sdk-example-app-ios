# ``NevisExampleWatchApp``

A watchOS companion app demonstrating how to authenticate with the Nevis Mobile Authentication SDK from an Apple Watch.

## Overview

The SDK is not available on watchOS, and the watch cannot access the keychain of the iPhone, so the watch app has no
registrations of its own. It delegates every operation to the iPhone app over WatchConnectivity, the iPhone app runs
the SDK operations on its behalf.

The watch app demonstrates:

* Listing the accounts registered in the iPhone app, together with their usable authenticators.
* Authenticating the selected account:
  * PIN and password are entered on the watch, including the remaining tries and the cool down after a failed
    attempt.
  * Face ID, Touch ID and Device Passcode are verified on the iPhone, the watch asks the user to continue there.
* Cancelling the ongoing authentication.

The iPhone app must have been launched at least once after the installation. Afterwards the system launches it in the
background to deliver the messages of the watch, except for biometric and device passcode verification, which needs the
iPhone app in the foreground.

### Architecture

- ``WatchApp`` creates and activates the ``PhoneSession`` on launch, and hosts the ``WatchView``.
- ``PhoneSession`` is the watch side of the WatchConnectivity session. Its ``PhoneSessionImpl`` implementation is the
  `WCSessionDelegate`: it sends the `WatchMessage`s, waits for the activation if needed, and exposes the reachability
  and the messages pushed by the iPhone as async streams.
- ``WatchModel`` drives the UI. It loads the accounts, keeps the selection and runs the authentication, its state is
  described by ``WatchState`` and ``AuthenticationState``.
- ``WatchView`` shows the accounts and the authenticators of the selected account, ``AuthenticationView`` shows the
  progress and the result of the authentication in a sheet.

The messages, the models and the shared localizations come from the `NevisExampleShared` package. The message flow is
described in its *Message Flow* article.

### Message flow

1. When the app becomes active, ``WatchModel`` requests the accounts. The request is repeated when the iPhone becomes
   reachable after a failure.
2. Tapping an authenticator sends `WatchMessage.authenticate(username:authenticator:)`. The iPhone acknowledges it, and
   pushes the progress as separate `PhoneMessage`s, which ``WatchModel`` receives from ``PhoneSession/messages``.
3. `PhoneMessage.credentialRequired(_:)` shows the ``CredentialEntry``, the entered credential is sent with
   `WatchMessage.credential(_:)`. `PhoneMessage.continueOnPhone` asks the user to continue on the iPhone.
4. `PhoneMessage.authenticated(username:)` or `PhoneMessage.failed(_:)` finishes the authentication. Closing the
   sheet before sends `WatchMessage.cancel`.

## Topics

### Application

- ``WatchApp``

### Connection

- ``PhoneSession``
- ``PhoneSessionImpl``

### Model

- ``WatchState``
- ``AuthenticationState``

### Screens

- ``WatchView``
- ``WatchModel``
- ``AuthenticationView``

### Components

- ``AccountRow``
- ``CredentialEntry``
- ``MessageView``
- ``Icon``
