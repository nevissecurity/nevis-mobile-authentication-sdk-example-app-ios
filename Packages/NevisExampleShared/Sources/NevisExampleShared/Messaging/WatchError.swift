//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

/// Errors of the watch ↔ iPhone communication.
public enum WatchError: Error, Codable, Sendable, Equatable {
	/// The counterpart app is not reachable.
	case unreachable
	/// The counterpart did not reply in time.
	case timeout
	/// The operation was cancelled.
	case cancelled
	/// The SDK could not be initialized on the iPhone.
	case initializationFailed
	/// The account is not registered on the iPhone.
	case accountNotFound
	/// Another authentication is already in progress.
	case operationInProgress
	/// The iPhone app was not brought to the foreground in time for a biometric or device passcode verification.
	case phoneAppNotOpened
	/// The authenticator is locked out after too many failed attempts.
	///
	/// - Parameter authenticator: The locked out authenticator.
	case lockedOut(authenticator: AuthenticatorKind)
	/// The message could not be encoded or decoded.
	case invalidMessage
	/// Any other error.
	///
	/// - Parameter description: The localized description of the underlying error, created on the sender's side.
	case other(description: String)
}

// MARK: - LocalizedError

extension WatchError: LocalizedError {
	public var errorDescription: String? {
		switch self {
			case .unreachable:
				L10n.Error.unreachable
			case .timeout:
				L10n.Error.timeout
			case .cancelled:
				L10n.Error.cancelled
			case .initializationFailed:
				L10n.Error.initializationFailed
			case .accountNotFound:
				L10n.Error.accountNotFound
			case .operationInProgress:
				L10n.Error.operationInProgress
			case .phoneAppNotOpened:
				L10n.Error.phoneAppNotOpened
			case let .lockedOut(authenticator):
				L10n.Error.lockedOut(authenticator)
			case .invalidMessage:
				L10n.Error.invalidMessage
			case let .other(description):
				description
		}
	}
}
