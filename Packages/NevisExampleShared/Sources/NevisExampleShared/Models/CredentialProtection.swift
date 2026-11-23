//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// The protection status of a PIN or password authenticator.
///
/// Mirrors the SDK's `PinAuthenticatorProtectionStatus` and `PasswordAuthenticatorProtectionStatus`.
public enum CredentialProtection: Codable, Sendable, Equatable {
	/// No failed attempts.
	case unlocked
	/// The last attempt failed.
	///
	/// - Parameters:
	///   - remainingTries: The number of tries left before the authenticator is locked out.
	///   - coolDown: Seconds to wait before the next attempt. 0 if none.
	case lastAttemptFailed(remainingTries: Int, coolDown: Int)
	/// Too many failed attempts, the authenticator cannot be used anymore.
	case lockedOut

	// MARK: - Properties

	/// Seconds to wait before the next attempt. 0 if none.
	public var coolDown: Int {
		if case let .lastAttemptFailed(_, coolDown) = self {
			coolDown
		} else {
			0
		}
	}

	// MARK: - Public Interface

	/// Returns the localized remaining tries and cool down message.
	///
	/// - Parameter kind: The kind of credential the status belongs to.
	/// - Returns: The localized message. Empty if there is nothing to show.
	public func localizedDescription(for kind: CredentialKind) -> String {
		switch self {
			case .unlocked:
				""
			case .lockedOut:
				L10n.Protection.lockedOut(kind)
			case let .lastAttemptFailed(remainingTries, coolDown):
				switch (remainingTries, coolDown) {
					case (1, 0):
						L10n.Protection.lastRetryWithoutCoolDown(kind, remainingTries)
					case (1, 1...):
						L10n.Protection.lastRetryWithCoolDown(kind, remainingTries, coolDown)
					case (2..., 1...):
						L10n.Protection.retriesWithCoolDown(kind, remainingTries, coolDown)
					default:
						L10n.Protection.retriesWithoutCoolDown(kind, remainingTries)
				}
		}
	}
}
