//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import NevisExampleShared

/// SF Symbols used by the extension.
enum Icon {
	/// Initialization in progress.
	case initializing
	/// Authentication in progress.
	case authenticating
	/// Authentication succeeded.
	case authenticated
	/// Authenticator locked out.
	case lockedOut
	/// Generic success.
	case success
	/// Warning, e.g. missing accounts or authenticators.
	case warning
	/// Generic failure.
	case error
	/// Selected row marker.
	case checkmark
	/// Credential cooldown in progress.
	case cooldown
	/// Delete action.
	case trash
	/// The icon of an authenticator, see `AuthenticatorKind.systemImage`.
	case authenticator(AuthenticatorKind)

	/// The SF Symbol name of the icon.
	var systemName: String {
		switch self {
			case .initializing:
				"arrow.triangle.2.circlepath"
			case .authenticating:
				"key.shield"
			case .authenticated:
				"checkmark.seal.fill"
			case .lockedOut:
				"lock.slash.fill"
			case .success:
				"checkmark.circle"
			case .warning:
				"exclamationmark.triangle.fill"
			case .error:
				"xmark.circle"
			case .checkmark:
				"checkmark"
			case .cooldown:
				"hourglass"
			case .trash:
				"trash"
			case let .authenticator(authenticator):
				authenticator.systemImage
		}
	}
}
