//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation
import NevisExampleShared

/// The states the extension flow moves through, from SDK initialization to an authentication result.
enum Status: Equatable {
	/// The SDK client is being initialized in companion mode.
	case initializing
	/// The SDK client is initialized.
	case ready
	/// An authentication is in progress.
	///
	/// - Parameter username: The account being authenticated.
	case authenticating(username: String)
	/// The SDK asked for a PIN or password.
	///
	/// - Parameters:
	///   - prompt: The pending credential prompt.
	///   - coolDownEnd: When input is allowed again. `nil` if there is no cool down.
	case awaitingCredential(prompt: CredentialPrompt, coolDownEnd: Date?)
	/// The locked out authenticator is being deleted.
	///
	/// - Parameters:
	///   - username: The account used for deletion.
	///   - authenticator: The locked out authenticator to delete.
	case deleting(username: String, authenticator: AuthenticatorKind)
	/// The authentication succeeded.
	///
	/// - Parameters:
	///   - username: The authenticated account.
	///   - jwt: The issued JWT. `nil` for cookie-based setups.
	case authenticated(username: String, jwt: String?)
	/// The authenticator is locked out after too many failed attempts. It can be deleted with
	/// ``ShareModel/deleteLockedRegistration()``.
	///
	/// - Parameters:
	///   - username: The account used for authentication.
	///   - authenticator: The selected authenticator.
	case lockedOut(username: String, authenticator: AuthenticatorKind)
	/// The flow failed.
	///
	/// - Parameter cause: The localized error message.
	case failed(cause: String)
}
