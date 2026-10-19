//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation
import NevisExampleShared

/// The state of an authentication running on the iPhone on behalf of the watch.
enum AuthenticationState: Equatable {
	/// Waiting for the iPhone to answer or to report the next step.
	case waitingForPhone
	/// The PIN or password must be entered on the watch.
	///
	/// - Parameters:
	///   - prompt: The credential request.
	///   - coolDownEnd: When input is allowed again. `nil` if there is no cool down.
	case credentialRequired(CredentialPrompt, coolDownEnd: Date?)
	/// The user must verify on the iPhone (biometric or device passcode).
	///
	/// - Parameter authenticator: The authenticator to verify with.
	case continueOnPhone(AuthenticatorKind)
	/// The authentication succeeded.
	///
	/// - Parameter username: The authenticated account.
	case succeeded(username: String)
	/// The authentication failed or was cancelled.
	///
	/// - Parameter error: The reason of the failure.
	case failed(WatchError)

	// MARK: - Properties

	/// Whether the authentication is over. No more messages are expected from the iPhone.
	var isFinished: Bool {
		switch self {
			case .succeeded, .failed:
				true
			case .waitingForPhone, .credentialRequired, .continueOnPhone:
				false
		}
	}
}
