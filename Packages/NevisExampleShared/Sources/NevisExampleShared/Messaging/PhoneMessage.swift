//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// A message sent from the iPhone to the watch, either as a reply to a ``WatchMessage`` or pushed during an authentication.
///
/// A typical authentication:
/// ```
/// watch: .authenticate(username, .pin)  →  phone: .acknowledged
///                                           phone: .credentialRequired(prompt)
/// watch: .credential("1234")            →  phone: .acknowledged
///                                           phone: .authenticated(username)
/// ```
/// With a biometric or device passcode authenticator the phone pushes ``continueOnPhone`` instead of
/// ``credentialRequired(_:)``.
public enum PhoneMessage: Codable, Sendable, Equatable {
	/// Reply to ``WatchMessage/accounts``.
	case accounts([RegisteredAccount])
	/// Reply to a message that has no result of its own.
	case acknowledged
	/// The PIN or password must be entered on the watch. Answer with ``WatchMessage/credential(_:)``.
	case credentialRequired(CredentialPrompt)
	/// The user must continue on the iPhone (biometric or device passcode verification).
	///
	/// If the iPhone app is not in the foreground, the verification starts when the user opens it.
	case continueOnPhone
	/// The authentication succeeded.
	///
	/// - Parameter username: The authenticated account.
	case authenticated(username: String)
	/// The request or the authentication failed.
	case failed(WatchError)
}
