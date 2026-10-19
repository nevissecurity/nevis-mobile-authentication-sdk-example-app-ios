# Message Flow

The protocol between the watch app and the iPhone app.

## Overview

The watch app cannot use the SDK, so it delegates every operation to the iPhone app. The apps exchange JSON encoded
messages with `WCSession.sendMessageData(_:replyHandler:errorHandler:)`:

* The watch sends ``WatchMessage``s, the iPhone sends ``PhoneMessage``s.
* ``MessageCoder`` encodes and decodes the messages, `WCSession.send(_:replyType:)` sends a message and waits for the
  reply.
* Every message is answered with a reply immediately. Failures are reported with ``PhoneMessage/failed(_:)`` and
  ``WatchError``.

### Requesting the accounts

```
watch: .accounts  →  phone: .accounts([RegisteredAccount])
```

The iPhone initializes the SDK on the first message, so the request also works if the system launched the iPhone app
in the background to deliver it.

### Authenticating

User interaction can take longer than the reply timeout, so an authentication is only acknowledged in the reply. The
progress is pushed by the iPhone with separate messages, which the watch acknowledges.

With a PIN or password authenticator the credential is entered on the watch:

```
watch: .authenticate(username, .pin)  →  phone: .acknowledged
                                          phone: .credentialRequired(prompt)  →  watch: .acknowledged
watch: .credential("1234")            →  phone: .acknowledged
                                          phone: .authenticated(username)     →  watch: .acknowledged
```

After a failed attempt the iPhone sends ``PhoneMessage/credentialRequired(_:)`` again, with the remaining tries and the
cool down in ``CredentialPrompt/protection``. The cool down is transferred as a duration, because the clocks of the
devices may differ, see ``CredentialPrompt/coolDownEnd(from:)``.

Biometric and device passcode verification is presented by the system, so it must happen on the iPhone
(``AuthenticatorKind/requiresLocalVerification``):

```
watch: .authenticate(username, .faceRecognition)  →  phone: .acknowledged
                                                      phone: .continueOnPhone          →  watch: .acknowledged
                                                      phone: .authenticated(username)  →  watch: .acknowledged
```

If the iPhone app is not in the foreground, the verification starts when the user opens it. If the user does not open
it in time, the authentication fails with ``WatchError/phoneAppNotOpened``.

### Cancelling

The watch sends ``WatchMessage/cancel`` to cancel the ongoing authentication. A pending credential request or the wait
for the iPhone app is cancelled immediately, and the authentication fails with ``WatchError/cancelled``. A system
prompt that is already presented on the iPhone must be cancelled there.

Only one authentication can run at a time, another ``WatchMessage/authenticate(username:authenticator:)`` fails with
``WatchError/operationInProgress``.
