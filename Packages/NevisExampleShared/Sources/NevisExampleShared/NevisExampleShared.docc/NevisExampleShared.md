# ``NevisExampleShared``

The platform independent models, the watch ↔ iPhone messages and the shared localizations of the example apps.

## Overview

The package is used by the iPhone app, the share extension and the watch app. It does not depend on the Nevis Mobile
Authentication SDK, because the SDK is not available on watchOS. The SDK types are mapped to the models of the
package on the iPhone (e.g. `Authenticator` to ``AuthenticatorKind``, `Account` to ``RegisteredAccount``).

The package contains:

* The models describing the registered accounts and the credential requests: ``RegisteredAccount``,
  ``AuthenticatorKind``, ``CredentialKind``, ``CredentialPrompt`` and ``CredentialProtection``.
* The typed messages exchanged between the watch and the iPhone over WatchConnectivity, see <doc:MessageFlow>.
* The localized strings shared by the targets, e.g. the authenticator titles, the remaining tries and cool down
  messages and the texts of the system prompts (``SystemPrompt``).

## Topics

### Essentials

- <doc:MessageFlow>

### Models

- ``RegisteredAccount``
- ``AuthenticatorKind``
- ``CredentialKind``
- ``CredentialPrompt``
- ``CredentialProtection``

### Messaging

- ``WatchMessage``
- ``PhoneMessage``
- ``WatchError``
- ``MessageCoder``

### Localization

- ``SystemPrompt``
