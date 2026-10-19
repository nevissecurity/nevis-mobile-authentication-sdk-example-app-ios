//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2024 Nevis Security AG. All rights reserved.
//

import NevisExampleShared
import NevisMobileAuthentication

/// Information about the `PasswordAuthenticatorProtectionStatus`.
extension PasswordAuthenticatorProtectionStatus {
	/// The platform independent representation of the status.
	var credentialProtection: CredentialProtection {
		switch self {
			case let .LastAttemptFailed(remainingTries, coolDown):
				.lastAttemptFailed(remainingTries: remainingTries, coolDown: coolDown)
			case .LockedOut:
				.lockedOut
			case .Unlocked:
				.unlocked
			@unknown default:
				.unlocked
		}
	}

	/// Returns the localized description.
	var localizedDescription: String {
		credentialProtection.localizedDescription(for: .password)
	}
}
