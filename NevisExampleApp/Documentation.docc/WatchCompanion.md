# Watch Companion

How the iPhone app authenticates on behalf of the watch app.

## Overview

The Nevis Mobile Authentication SDK is not available on watchOS, so the watch app (`NevisExampleWatchApp`) delegates
the operations to the iPhone app over WatchConnectivity. The messages are the typed `WatchMessage`s and
`PhoneMessage`s of the `NevisExampleShared` package. The protocol is described in the *Message Flow* article of the
package, the watch side in the documentation of the watch app.

### Components

- ``WatchSessionDelegate`` is the iPhone side of the WatchConnectivity session. ``WatchSessionDelegateImpl`` is
  activated by the ``AppDelegate`` on launch, decodes the messages of the watch, lets ``WatchMessageHandler`` process
  them and replies with the result.
- ``WatchMessageHandlerImpl`` initializes the SDK client on the first message, because the system may launch the app in
  the background to deliver it. It returns the registered accounts and runs the authentication.
- ``WatchMessageSender`` pushes the progress of the authentication to the watch, because user interaction can take
  longer than the reply timeout of a message.

### Authentication

The authentication runs with ``HeadlessAuthentication``, the same implementation the share extension uses. It does not
use the screens of the app:

- The authenticator chosen on the watch is selected by ``HeadlessAuthenticatorSelector``.
- The PIN or password is requested from the watch through a ``CredentialProvider``. The watch has 60 seconds to answer.
- Face ID, Touch ID and Device Passcode are verified on the iPhone with the system prompt. The prompt can only be
  presented in the foreground, so if the app is not active, the handler waits until the user opens it.

Only one authentication can run at a time. The app is kept running in the background with a background task until the
result is sent to the watch.

## Topics

### Watch

- ``WatchSessionDelegate``
- ``WatchSessionDelegateImpl``
- ``WatchMessageHandler``
- ``WatchMessageHandlerImpl``
- ``WatchMessageSender``
- ``WatchMessageSenderImpl``

### Headless Authentication

- ``HeadlessAuthentication``
- ``CredentialProvider``
