//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// A message sent from the watch to the iPhone.
///
/// Every message is sent with a reply handler. The iPhone replies with a ``PhoneMessage``:
/// - ``accounts`` with ``PhoneMessage/accounts(_:)``.
/// - The others with ``PhoneMessage/acknowledged`` (or ``PhoneMessage/failed(_:)``). The progress of the
///   authentication is pushed later as separate ``PhoneMessage``s, because user interaction can exceed the reply timeout.
public enum WatchMessage: Codable, Sendable, Equatable {
	/// Requests the registered accounts.
	case accounts
	/// Starts an authentication.
	///
	/// - Parameters:
	///   - username: The account to authenticate.
	///   - authenticator: The authenticator to use.
	case authenticate(username: String, authenticator: AuthenticatorKind)
	/// The credential entered for a ``PhoneMessage/credentialRequired(_:)``.
	case credential(String)
	/// Cancels the ongoing authentication.
	case cancel
}
